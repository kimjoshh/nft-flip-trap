# 🚀 Deployment Guide: NFT Flip Trap

This guide walks you through deploying the NFTFlipTrap smart contract on the Holesky testnet using Foundry.

---

## 1️⃣ Prerequisites

### Install dependencies:
```bash
sudo apt update && sudo apt install git curl unzip -y
```

### Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## 2️⃣ Initialize the Project
```bash
forge init nft-flip-trap -t drosera-network/trap-foundry-template
cd nft-flip-trap
```

## 3️⃣ Prepare Contract and Scripts
Your project folder will now look like this:

```bash
nft-flip-trap/
├── scripts/                       # Deployment scripts
├── src/                           # Trap contract
├── test/                          # Unit tests
├── drosera.toml                   # Metadata for Drosera integration
├── foundry.toml                   # Foundry project config
└── README.md                      # Documentation
```

**Smart contract:**
- Edit or create src/NFTFlipTrap.sol

**Test:**
- Write a test file at test/NFTFlipTrapTest.t.sol

**Deployment script:**
- Create scripts/DeployNFTFlipTrap.s.sol

## 4️⃣ Run Unit Tests
```bash
forge test
```

✅ Ensure flip detection logic is correct.

## 5️⃣ Create .env File
```env
HOLESKY_RPC_URL=https://holesky.infura.io/v3/YOUR_KEY
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## 6️⃣ Deploy the Contract
```bash
forge script scripts/DeployNFTFlipTrap.s.sol \
  --rpc-url $HOLESKY_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

## 7️⃣ Verify Deployment
Visit your contract address on Holesky Etherscan:
https://holesky.etherscan.io/address/0xYourContractAddress

## ✅ Done!
You have:

- Created and tested the trap

- Deployed it on Holesky

- Verified it on Etherscan
