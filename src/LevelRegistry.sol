// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {ILevel} from "./ILevel.sol";

contract LevelRegistry {

    //level => is registered
    mapping(address => bool) public levels;
    //level => current winning solution
    mapping(address => Solution) internal bestSolutions;
    //level => all valid solutions
    mapping(address => Solution[]) internal validSolutions;

    struct Solution {
        address submitter;

        address solution;
        uint32 submissionTime;
        uint32 gasUsed;

        uint codeLength;
    }

    //TODO: auth on registerLevel?
    function registerLevel(ILevel level) external {
        levels[address(level)] = true;

    }

    function validateSolution(address level, address solution) external returns(bool success, bytes memory data) {
        if(!levels[level]) revert LevelNotRegistered();

        uint gasUsed = gasleft();
        (success, data) = ILevel(level).validate(solution);
        gasUsed = gasUsed - gasleft();

        if (success) {
            Solution memory _solution = Solution(msg.sender, solution, uint32(block.timestamp), uint32(gasUsed), solution.code.length);

            validSolutions[level].push(_solution);
            emit NewSolution(level, _solution);

            Solution memory _bestSolution = bestSolutions[level];
            if (_solution.codeLength < _bestSolution.codeLength || _bestSolution.codeLength == 0) {
                bestSolutions[level] = _solution;
                emit NewBestSolution(level, _solution);
            }
        }
    }

    function getBestSolution(address level) external view returns(address submitter, address solution, uint32 submissionTime, uint32 gasUsed, uint codeLength) {
        return unpackSolution(bestSolutions[level]);
    }

    function getValidSolutions(address level) external view returns(Solution[] memory) {
        return validSolutions[level];
    }
    
    function unpackSolution(Solution memory s) public pure returns(address submitter, address solution, uint32 submissionTime, uint32 gasUsed, uint codeLength) {
        submitter = s.submitter;
        solution = s.solution;
        submissionTime = s.submissionTime;
        gasUsed = s.gasUsed;
        codeLength = s.codeLength;
    }

    //TODO: additional validateSolution with bytecode as param, skip the deployment step

    event NewLevel(address level);
    event NewSolution(address level, Solution solution);
    event NewBestSolution(address level, Solution solution);

    error LevelNotRegistered();
}