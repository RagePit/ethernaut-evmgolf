// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface ILevel {
    function validate(address solution) external returns(bool validated, bytes memory returnData);
    function name() external pure returns(string memory);
}
