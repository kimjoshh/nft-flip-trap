# 🧠 NFT Flip Trap
## 🚨 Overview
This Drosera trap contract is designed to detect suspicious NFT flipping behavior immediately after minting. It specifically targets scenarios where an NFT is:

Minted (from address(0)) to a wallet.

Flipped immediately (sent to another wallet right after minting).

This trap is highly useful for identifying potential botting, front-running, or wash trading activities that occur rapidly following an NFT's initial mint.

## ✅ Deployment Status
Deployed and verified on Holesky Etherscan.

## 🧠 How It Works
The core detection logic resides in the shouldRespond(bytes[] calldata data) function, which receives encoded logs from a Drosera relay node.

The function performs the following steps:

Decodes the log data into a list of TransferEvent structs.

For each mint event (where from is address(0)), it looks for a subsequent transfer of the same tokenId originating from the same minter.

If such an immediate flip is detected (i.e., the token is transferred to another wallet that is not the minter and not a burn), it returns:

should = true

reason = "Suspicious: Token X minted to 0x... and immediately flipped to 0x..."

If no suspicious pattern is found across the logs, the function returns false.

## 🔍 Trap Contract Interface
Solidity

function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);

struct TransferEvent {
    address from;
    address to;
    uint256 tokenId;
}
These logs mimic the Transfer event emitted by ERC721-compatible NFT contracts.

## 🔎 Detection Logic (Pseudocode)
Decode TransferEvent[] from data[0]

For every event where from == address(0) (mint):
    Loop through subsequent logs to find:
        Same tokenId
        from == minter
        to != minter && to != address(0) (not a burn)

    If found, respond:
        return (
            true,
            bytes("Suspicious: Token X minted to 0x... and immediately flipped to 0x...")
        );

If no suspicious pattern is found, return false.
## 🧪 Example: Test Simulation
Consider the following simulated logs used in tests:

Solidity

logs[0] = Transfer(address(0), A, 1);   // Mint
logs[1] = Transfer(A, B, 1);           // Immediate flip
The trap correctly detects this pattern and returns:

Solidity

should = true;
reason = "Suspicious: Token 1 minted to 0xAAA... and immediately flipped to 0xBBB...";
## 🛠️ Contract Details
Item

Value

Contract Name

NFTFlipTrap

Network

Holesky

Address

0x3e0A13AD70b1e705f4cEfDccd5dDd199953Cc41d

Verified

**✅ Yes**

Solidity

^0.8.20

EVM Version

Cancun

Framework

Foundry (forge, forge-std)

## 🔬 Testing
Unit tests for the NFTFlipTrap are implemented using Foundry. These tests ensure:

**✅ Flipping is detected correctly**

**✅ Non-flipping transfers are ignored**

**✅ reason values are descriptive**

To run the tests:

Bash

forge test
## 📦 drosera.toml Configuration
Ini, TOML

name = "NFT Flip Trap"
description = "Detects suspicious NFT flipping behavior after minting and immediate resale."
contract_address = "0x3e0A13AD70b1e705f4cEfDccd5dDd199953Cc41d"
## 👤 Author
**KIM JOSH**

Submitted for the Drosera Network Trap Contest.

GitHub: github.com/yourhandle

Twitter: @yourhandle (optional)

## 💡 Future Improvements
Add time-window constraint: Implement a time-based condition (e.g., flips within 2 blocks) for more refined detection.

Support batch mints: Extend compatibility to handle batch mints, such as those in ERC721A-style contracts.

Emit Drosera-compatible event output: Generate event outputs that are directly consumable by the Drosera Network for better integration.

## 🔗 Resources
Drosera Network

Holesky Etherscan

Foundry Docs