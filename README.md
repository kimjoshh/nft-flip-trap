# NFTFlipTrap

A smart contract trap module for detecting suspicious NFT flipping behavior shortly after minting. Built for integration with the [Drosera Network](https://github.com/drosera-network).

---

## 📦 Overview

`NFTFlipTrap` analyzes `Transfer` logs of ERC-721 tokens to identify "flip after mint" patterns — where a freshly minted NFT is immediately resold or transferred to another wallet.

The contract is designed to support two modes:

* ✅ **Non-Emit Version** (simpler, pure-function, testnet-friendly)
* 🔁 **Emit Version** (observable, indexable, production-ready)

---

## 🎯 Use Cases

### 🔍 NFT Marketplace Monitoring

Detect wallets that mint NFTs and flip them within the same block or shortly after minting, which may indicate:

* Wash trading
* Sybil attacks
* Market manipulation

### 🔐 Trap Deployment in Drosera

Use `NFTFlipTrap` as a trap module in Drosera to:

* Flag suspicious operators
* Trigger automated slashing or investigation workflows

### 🧪 Research and Simulation

In testnets or simulation environments:

* Evaluate minter/reseller behavior
* Prototype anti-flip heuristics

---

## 🧠 Flip Detection Logic

1. Detect an ERC-721 `Transfer` event from the zero address (mint).
2. Check for a subsequent transfer of the **same `tokenId`** by the minter to another address.
3. If found, flag as suspicious.

---

## 🔹 Non-Emit Version

```solidity
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
        nftContract = address(0x001234567890abcdef1234567890abcdef12345678);
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
```

### ✅ Advantages

* `shouldRespond()` is a `pure` function (reads no blockchain state).
* No state changes (safe for simulations or local testing).
* Gas efficient and lightweight.

### 🧱 Key Contract Structure

```solidity
function shouldRespond(bytes[] calldata _data) external pure override returns (bool, bytes memory);
```

* Decodes encoded `TransferEvent[]` logs.
* Checks for mint-and-flip pattern.
* Returns `(true, reason)` if detected.

### 📁 Example Reason Payload

```solidity
abi.encode(keccak256("FLIP_DETECTED"), tokenId, from, to);
```

---

## 🔁 Emit Version

```solidity
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

    event FlipDetected(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to
    );

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

    function shouldRespond(bytes[] calldata _data) external override returns (bool should, bytes memory reason) {
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
                        emit FlipDetected(currentLog.tokenId, currentLog.to, subsequentLog.to);

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
```

### ✅ Advantages

* Emits a `FlipDetected` event when a flip pattern is detected.
* Easily trackable by indexers, analytics, or bots.
* Suitable for production deployments.

### 🔔 Event Declaration

```solidity
event FlipDetected(uint256 indexed tokenId, address indexed from, address indexed to);
```

### 🧱 Key Contract Structure

```solidity
function shouldRespond(bytes[] calldata _data) external override returns (bool, bytes memory) {
    ...
    emit FlipDetected(tokenId, from, to);
    return (true, ...);
}
```

* Emits on detection.
* `shouldRespond()` is no longer `pure` or `view` due to the `emit`.

---

## ✍️ Interface

Implements Drosera’s standard interface:

```solidity
interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external returns (bool, bytes memory);
}
```

---

## 🧪 Dummy `collect()`

By default, `collect()` returns placeholder logs:

```solidity
TransferEvent[] memory dummyTransfers;
// filled with mocked values for testing
```

Replace this with real log data from shadowfork or on-chain scans as needed.

---

## 🛠️ Deployment Notes

### Replace NFT Address

```solidity
nftContract = 0x1234567890abcdef1234567890abcdef12345678; // replace before deploy
```

### Foundry Deployment

```bash
forge script script/DeployNFTFlipTrap.s.sol \
  --rpc-url $HOLESKY_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

---

## 📜 License

MIT

---

## 🤝 Credits

Developed for the Drosera Network trap ecosystem.