// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NFTFlipTrap {

    struct TransferEvent {
        address from;
        address to;
        uint256 tokenId;
    }

    /**
     * @notice Analyzes log data to detect "flip after mint" patterns.
     * @param _data Array of bytes, where each element is expected to contain
     * abi.encode(TransferEvent[]).
     * @return should be True if a suspicious pattern was detected, false otherwise.
     * @return reason A message explaining why the decision was made.
     */
    function shouldRespond(bytes[] memory _data) public pure returns (bool should, bytes memory reason) {
        // Verify input data is not empty
        require(_data.length > 0, "Input data must not be empty.");
        // Assumption: _data[0] contains an encoded TransferEvent array
        TransferEvent[] memory logs = abi.decode(_data[0], (TransferEvent[]));

        // Logic to detect "flip after mint":
        // Loop through each transfer log.
        // If we find a mint (from address(0)),
        // we then check the next log in the same batch
        // to see if the same token was immediately transferred out
        // by the original minter.
        for (uint i = 0; i < logs.length; i++) {
            TransferEvent memory currentLog = logs[i];

            // Mint event detection (from address zero)
            if (currentLog.from == address(0)) {
                // Token has been minted. Now look for the next transfer from this minter.
                for (uint j = i + 1; j < logs.length; j++) {
                    TransferEvent memory subsequentLog = logs[j];

                    // Check if:
                    // 1. TokenId is the same
                    // 2. Transfer is from 'to' address (original minter) from mint log
                    // 3. Transfer is not to address(0) (not burn)
                    if (subsequentLog.tokenId == currentLog.tokenId &&
                        subsequentLog.from == currentLog.to &&
                        subsequentLog.to != address(0))
                    {
                        // "flip" pattern detected!
                        should = true;
                        reason = abi.encodePacked(
                            "Suspicious: Token ",
                            _uint256ToString(currentLog.tokenId),
                            " minted to ",
                            _addressToString(currentLog.to),
                            " and immediately flipped to ",
                            _addressToString(subsequentLog.to)
                        );
                        return (should, reason); // Return as soon as detected
                    }
                }
            }
        }

        // If no suspicious patterns are detected after checking all logs
        should = false;
        reason = "No suspicious NFT flips detected.";
    }

    // Simple helper function to convert uint256 to string for messages
    function _uint256ToString(uint256 value) internal pure returns (bytes memory) {
        if (value == 0) {
            return abi.encodePacked("0");
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + value % 10)); // 48 adalah ASCII untuk '0'
            value /= 10;
        }
        return buffer;
    }

    // Simple helper function to convert address to hexadecimal string for message
    function _addressToString(address addr) internal pure returns (bytes memory) {
        bytes memory s = new bytes(42); // 0x + 20 bytes * 2 chars/byte = 42 chars
        s[0] = '0';
        s[1] = 'x';
        bytes20 b = bytes20(addr);
        for (uint i = 0; i < 20; i++) {
            uint8 byteValue = uint8(b[i]);
            s[2 + i*2] = _toAsciiChar(uint8(byteValue >> 4));
            s[3 + i*2] = _toAsciiChar(uint8(byteValue & 0x0f));
        }
        return s;
    }

    function _toAsciiChar(uint8 value) internal pure returns (bytes1) {
        if (value < 10) {
            return bytes1(uint8(48 + value)); // '0' to '9'
        } else {
            return bytes1(uint8(87 + value)); // 'a' to 'f' for 10-15 (87 = 'a' - 10)
        }
    }
}