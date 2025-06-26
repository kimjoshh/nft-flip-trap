# 🧠 NFT Flip Trap

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

## 🛠 Technical Implementation (PoC in Solidity)

### 📄 `NFTFlipTrap.sol`
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NFTFlipTrap {

    struct TransferEvent {
        address from;
        address to;
        uint256 tokenId;
    }

    function shouldRespond(bytes[] memory _data) public pure returns (bool should, bytes memory reason) {
        require(_data.length > 0, "Input data must not be empty.");

        TransferEvent[] memory logs = abi.decode(_data[0], (TransferEvent[]));

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
                        should = true;
                        reason = abi.encodePacked(
                            "Suspicious: Token ",
                            _uint256ToString(currentLog.tokenId),
                            " minted to ",
                            _addressToString(currentLog.to),
                            " and immediately flipped to ",
                            _addressToString(subsequentLog.to)
                        );
                        return (should, reason);
                    }
                }
            }
        }

        should = false;
        reason = "No suspicious NFT flips detected.";
    }

    function _uint256ToString(uint256 value) internal pure returns (bytes memory) {
        if (value == 0) return abi.encodePacked("0");
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + value % 10));
            value /= 10;
        }
        return buffer;
    }

    function _addressToString(address addr) internal pure returns (bytes memory) {
        bytes memory s = new bytes(42);
        s[0] = '0';
        s[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            s[2 + i*2] = _toAsciiChar(uint8(uint160(addr) >> (8*(19 - i)) >> 4));
            s[3 + i*2] = _toAsciiChar(uint8(uint160(addr) >> (8*(19 - i)) & 0x0f));
        }
        return s;
    }

    function _toAsciiChar(uint8 value) internal pure returns (bytes1) {
        return value < 10 ? bytes1(value + 48) : bytes1(value + 87);
    }
}
}

## 📬 Contract Address
0x3e0A13AD70b1e705f4cEfDccd5dDd199953Cc41d

## ✅ What It Solves
Detects bots that immediately flip NFTs after minting

Helps protocols monitor suspicious trading behavior

Can be used in launchpad contracts, NFT marketplaces, or curated drops

## 🧪 Deployment and Testing Instructions
1. Deploy to Holesky testnet
Use Foundry or Remix to deploy the contract. Ensure Drosera operator is running.

2. Simulate Events
Emit logs that resemble:

``solidity
{
logs[0] = Transfer(address(0), A, 1);   // Mint
logs[1] = Transfer(A, B, 1);           // Flip
}

3. Run Foundry Test
bash
{
forge test
}

4. Check Response

Expected output:
{
should = true;
reason = "Suspicious: Token 1 minted to 0xAAA... and immediately flipped to 0xBBB...";
}

## 🧠 Example Use Cases
Detect sybil bot NFT farming

Monitor high-volume NFT flippers

Secure limited-edition or whitelist-only drops

## 🚀 Next Steps
### 🔧 Step 1: Configure Drosera Operator
Set up relay to call collect() and shouldRespond()

Provide encoded logs as input to the trap

### 🧪 Step 2: Run Simulation
Run batch transfers with/without flips

Observe return value and reason

### 📊 Step 3: Integrate with Drosera Dashboard
Visualize alerts and trigger logs

Configure event notifications

### 🧩 Step 4: Extend Functionality
Add mint timestamp support

Add per-token history cache

Integrate with NFT marketplaces

### 📝 Step 5: Document and Share
Write public doc

Publish to GitHub & Drosera registry

Encourage others to fork and improve

## 📦 drosera.toml
toml
{
name = "NFT Flip Trap"
description = "Detects suspicious NFT flipping behavior after minting and immediate resale."
contract_address = "0x3e0A13AD70b1e705f4cEfDccd5dDd199953Cc41d"
}
## 👤 Author
KIM JOSH
Submitted for the Drosera Network Trap Contest
GitHub: github.com/kimjoshh

## 📚 Resources
Drosera Network

Holesky Etherscan

Foundry Book

✅ drosera.toml
toml
Copy code
name = "NFT Flip Trap"
description = "Detects suspicious NFT flipping behavior after minting and immediate resale."
contract_address = "0x3e0A13AD70b1e705f4cEfDccd5dDd199953Cc41d"