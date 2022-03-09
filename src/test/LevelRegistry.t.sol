// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";

import {LevelRegistry} from "../LevelRegistry.sol";
import {VM} from "./VM.sol";
import {ExampleLevel} from "./ExampleLevel.sol";

contract LevelRegistryTest is DSTest {
    VM vm = VM(HEVM_ADDRESS);
    ExampleLevel level;
    LevelRegistry registry;

    struct Solution {
        address submitter;

        address solution;
        uint32 submissionTime;
        uint32 gasUsed;

        uint codeLength;
    }

    function setUp() public {
        level = new ExampleLevel();
        registry = new LevelRegistry();
        registry.registerLevel(level);
    }

    function test_register_level() public {
        registry.registerLevel(level);
        assertTrue(registry.levels(address(level)));
    }

    function test_validate_pass() public {
        vm.etch(address(0xbeef), bytes.concat(bytes6(0x4334525934f3)));
        
        (bool success, bytes memory data) = registry.validateSolution(address(level), address(0xbeef));

        assertEq(string(data), "Passed Checks");
        assertTrue(success);
    }

    function test_validate_solutions_update() public {
        vm.etch(address(0xbeef), bytes.concat(bytes6(0x4334525934f3)));
        
        registry.validateSolution(address(level), address(0xbeef));

        assertEq(registry.getValidSolutions(address(level)).length, 1);

        registry.validateSolution(address(level), address(0xbeef));

        assertEq(registry.getValidSolutions(address(level)).length, 2);
    }

    function test_validate_discard_fail() public {
        vm.etch(address(0xbeef), bytes.concat(bytes10(0x60ff60005260206000F3)));
        
        registry.validateSolution(address(level), address(0xbeef));

        assertEq(registry.getValidSolutions(address(level)).length, 0);
    }

    function test_validate_best_solution_update() public {
        vm.etch(address(0xbeef), bytes.concat(bytes6(0x4334525934f3)));
        
        registry.validateSolution(address(level), address(0xbeef));

        (address submitter, address solution, uint32 submissionTime, uint32 gasUsed, uint codeLength) = registry.getBestSolution(address(level));

        assertEq(submitter, address(this));
        assertEq(solution, address(0xbeef));
        assertEq(submissionTime, block.timestamp);
        assertTrue(gasUsed > 100);
        assertEq(codeLength, address(0xbeef).code.length);
    }
    
}
