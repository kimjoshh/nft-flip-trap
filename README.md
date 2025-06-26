# 🧠 NFT Flip Trap

🚨 A Drosera trap contract to detect suspicious NFT flipping behavior immediately after minting  
✅ Deployed and verified on [Holesky Etherscan](https://holesky.etherscan.io/address/0x3e0A13AD70b1e705f4cEfDccd5dDd199953Cc41d)

---

## 📌 Problem

NFT marketplaces often suffer from bots and malicious actors who mint NFTs and immediately flip them for profit — sometimes through wash trading or rapid front-running. These patterns are suspicious and may indicate manipulative behavior or sybil activity, especially if done in high frequency.

---

## 🎯 Goal of the Trap

Detect any suspicious behavior where:
1. An NFT is minted (from `address(0)`)
2. The same NFT is **immediately flipped** to another address by the minter

The trap helps identify front-runners or bots that exploit NFT launches.

---

## ✅ What It Solves
1. **Detects bots that immediately flip NFTs after minting**

2. **Helps protocols monitor suspicious trading behavior**

3. **Can be used in launchpad contracts, NFT marketplaces, or curated drops**

---

## 🧠 Example Use Cases
1. **Detect sybil bot NFT farming**

2. **Monitor high-volume NFT flippers**

3. **Secure limited-edition or whitelist-only drops**

## 📘 How to Use This Trap in Production

---

## 🛠 Technical Implementation (PoC in Solidity)

### 📄 `NFTFlipTrap.sol`

```solidity 
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
```

## 🧪 Deployment and Testing Instructions
1. Deploy to Holesky testnet
Use Foundry or Remix to deploy the contract. Ensure Drosera operator is running.

2. Simulate Events
Emit logs that resemble:

```solidity
logs[0] = Transfer(address(0), A, 1);   // Mint
logs[1] = Transfer(A, B, 1);           // Flip
```

3. Run Foundry Test
```bash 
forge test
```

4. Check Response

Expected output:
``` 
should = true;
reason = "Suspicious: Token 1 minted to 0xAAA... and immediately flipped to 0xBBB...";
```

### 🔧 Step 1: Configure Drosera Operator
- Set up relay to call collect() and shouldRespond()

- Provide encoded logs as input to the trap

### 🧪 Step 2: Run Simulation
- Run batch transfers with/without flips

- Observe return value and reason

### 📊 Step 3: Integrate with Drosera Dashboard
- Visualize alerts and trigger logs

- Configure event notifications

### 🧩 Step 4: Extend Functionality
- Add mint timestamp support

- Add per-token history cache

- Integrate with NFT marketplaces

### 📝 Step 5: Document and Share
- Write public doc

- Publish to GitHub & Drosera registry

- Encourage others to fork and improve

## 👤 Author
KIM JOSH(oaksosks)

GitHub: github.com/kimjoshh

## 📚 Resources
**Drosera Network**

**Holesky Etherscan**

**Foundry Book**