// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/NFTFlipTrap.sol";

contract NFTFlipTrapTest is Test {
    NFTFlipTrap trap;

    function setUp() public {
        trap = new NFTFlipTrap();
    }

    function testShouldRespondWhenFlippedAfterMint() public {
        NFTFlipTrap.TransferEvent[] memory logs = new NFTFlipTrap.TransferEvent[](5);

        address A = address(0xAAA);
        logs[0] = NFTFlipTrap.TransferEvent(address(0), A, 1);
        logs[1] = NFTFlipTrap.TransferEvent(address(0), A, 2);
        logs[2] = NFTFlipTrap.TransferEvent(address(0), A, 3);

        address B = address(0xBBB);
        logs[3] = NFTFlipTrap.TransferEvent(A, B, 1);
        logs[4] = NFTFlipTrap.TransferEvent(A, address(0xCCC), 2);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encode(logs);

        (bool should, bytes memory reason) = trap.shouldRespond(data);

        assertTrue(should, "Trap should respond to suspicious flip");
        emit log_string(string(reason));
    }
}