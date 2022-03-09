// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import {VM} from "./VM.sol";
import {ExampleLevel} from "./ExampleLevel.sol";

contract ExampleLevelTest is DSTest {
    VM vm = VM(HEVM_ADDRESS);
    ExampleLevel level;
    function setUp() public {
        level = new ExampleLevel();
    }

    function test_validate_pass() public {
        //https://twitter.com/0xnibbler/status/1500526695693967361
        vm.etch(address(0xbeef), bytes.concat(bytes6(0x4334525934f3)));
        
        (bool success, bytes memory data) = level.validate(address(0xbeef));

        assertEq(string(data), "Passed Checks");
        assertTrue(success);
    }

    function test_validate_fail() public {
        //Incorrect return as long as block number isnt 0xff
        vm.etch(address(0xbeef), bytes.concat(bytes10(0x60ff60005260206000F3)));
        
        (bool success, bytes memory data) = level.validate(address(0xbeef));

        assertEq(string(data), "Failed Block Number Check");
        assertTrue(!success);
    }

    function test_validate_call_fail() public {
        //Reverts
        vm.etch(address(0xbeef), bytes.concat(bytes5(0x60006000FD)));
        
        (bool success, bytes memory data) = level.validate(address(0xbeef));

        assertEq(string(data), "Call Failed");
        assertTrue(!success);
    }

    function test_name() public {
        assertEq(level.name(), "Example Level");
    }
    
}
