// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {ILevel} from "../ILevel.sol";

contract ExampleLevel is ILevel {

    // Example level that checks for return data of block.number
    function validate(address solution) external returns(bool, bytes memory) {
        (bool success, bytes memory data) = solution.call("");
        if (!success) return (false, "Call Failed");
        
        //TODO: abi.decode is not useful in scenarios where non abi encoded data is returned. Design a custom solution potentially
        (uint returned) = abi.decode(data, (uint));

        if (returned != block.number) return (false, "Failed Block Number Check");
        return (true, "Passed Checks");
    }

    function name() external pure returns(string memory) {
        return "Example Level";
    }

}