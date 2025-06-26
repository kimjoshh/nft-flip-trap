# 🧠 NFT Flip Trap

🚨 Trap for detecting suspicious NFT flipping behavior immediately after minting  
✅ Deployed and verified on [Holesky Etherscan](https://holesky.etherscan.io/address/0x3e0A13AD70b1e705f4cEfDccd5dDd199953Cc41d)

---

## 📜 Overview

This Drosera trap contract detects suspicious behavior where an NFT is:

1. **Minted** (from address `0x0`) to a wallet  
2. **Flipped immediately** (sent to another wallet right after minting)

Useful to catch potential botting, front-running, or wash trading activities that occur rapidly after minting.

---

## 🧠 How It Works

The `shouldRespond(bytes[] calldata data)` function receives encoded logs from the Drosera relay node. It:

1. Decodes the log data into a list of `TransferEvent` structs  
2. For each mint event:
   - Looks for a following transfer of the same token ID from the same minter  
3. If such a flip is detected, it returns:
   - `should = true`
   - `reason = Suspicious: Token X minted to 0x... and immediately flipped to 0x...`

---

## 🔍 Trap Contract Interface

``solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);

struct TransferEvent {
    address from;
    address to;
    uint256 tokenId;
}
These logs mimic the Transfer event emitted by ERC721-compatible NFT contracts.

## 🔎 Detection Logic
Decode TransferEvent[] from data[0]

For every event where from == address(0) (mint):

Loop through subsequent logs to find:

Same tokenId

from == minter

to != minter && to != address(0) (not a burn)

If found, respond:

``solidity
Copy code
return (
    true,
    bytes("Suspicious: Token X minted to 0x... and immediately flipped to 0x...")
);
If no suspicious pattern is found, return false.

## 🧪 Example: Test Simulation
Simulated logs in test:

``solidity
Copy code
logs[0] = Transfer(address(0), A, 1);   // Mint
logs[1] = Transfer(A, B, 1);           // Immediate flip
Trap detects the pattern and returns:

``solidity
Copy code
should = true;
reason = "Suspicious: Token 1 minted to 0xAAA... and immediately flipped to 0xBBB...";

## 🛠️ Contract Details
Item	Value
Contract Name	NFTFlipTrap
Network	Holesky
Address	0x3e0A13AD70b1e705f4cEfDccd5dDd199953Cc41d
Verified	✅ Yes
Solidity	^0.8.20
EVM Version	Cancun
Framework	Foundry (forge, forge-std)

## 🔬 Testing
Unit tests using Foundry:

✅ Flipping is detected correctly

✅ Non-flipping transfers are ignored

✅ reason values are descriptive

To run tests:

``bash
Copy code
forge test

## 📦 drosera.toml
``toml
Copy code
name = "NFT Flip Trap"
description = "Detects suspicious NFT flipping behavior after minting and immediate resale."
contract_address = "0x3e0A13AD70b1e705f4cEfDccd5dDd199953Cc41d"

## 👤 Author
KIM JOSH
Submitted for the Drosera Network Trap Contest
GitHub: github.com/yourhandle
Twitter: @yourhandle (optional)

## 💡 Future Improvements
Add time-window constraint (e.g., flips within 2 blocks)

Support batch mints (ERC721A-style)

Emit Drosera-compatible event output

## 🔗 Resources
Drosera Network

Holesky Etherscan

Foundry Docs