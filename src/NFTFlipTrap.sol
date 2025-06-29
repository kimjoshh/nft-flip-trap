// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
}

contract NFTFlipTrap is ITrap {

    address public nftContract;

    struct TransferEvent {
        address from;
        address to;
        uint256 tokenId;
    }

    constructor() {
        // Hard-coded target NFT contract (replace with actual)
        nftContract = 0x1234567890abcdef1234567890abcdef12345678;
    }

    function collect() external view override returns (bytes memory) {
        // Dummy implementation for testing/demo purposes
        bytes32 eventSig = keccak256("Transfer(address,address,uint256)");
        uint256 fromBlock = block.number;
        uint256 toBlock = block.number;

        TransferEvent[] memory foundTransfers;
        uint256 count = 0;

        // Mocked data: populate with placeholder transfers
        for (uint i = 0; i < 10; i++) {
            foundTransfers[count] = TransferEvent({
                from: address(0),
                to: address(0),
                tokenId: 0
            });
            count++;
        }

        return abi.encode(foundTransfers);
    }

    function shouldRespond(bytes[] calldata _data) external pure override returns (bool should, bytes memory reason) {
        // Input must not be empty
        require(_data.length > 0, "Input data must not be empty.");

        // Decode TransferEvent[]
        TransferEvent[] memory logs = abi.decode(_data[0], (TransferEvent[]));

        // Limit to 100 logs to stay within EVM gas limits
        require(logs.length <= 100, "Too many logs.");

        // Check for mint-and-flip pattern
        for (uint i = 0; i < logs.length; i++) {
            TransferEvent memory currentLog = logs[i];

            if (currentLog.from == address(0)) {
                for (uint j = i + 1; j < logs.length; j++) {
                    TransferEvent memory subsequentLog = logs[j];

                    if (
                        subsequentLog.tokenId == currentLog.tokenId &&
                        subsequentLog.from == currentLog.to &&
                        subsequentLog.to != address(0)
                    ) {
                        // Suspicious flip detected
                        should = true;
                        reason = abi.encode(
                            keccak256("FLIP_DETECTED"),
                            currentLog.tokenId,
                            currentLog.to,
                            subsequentLog.to
                        );
                        return (should, reason);
                    }
                }
            }
        }

        // No suspicious activity found
        should = false;
        reason = "No suspicious NFT flips detected.";
    }
}
