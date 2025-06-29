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