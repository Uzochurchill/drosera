# Drosera BatchMint Proof of Concept (V2)

This is a Proof-of-Concept (PoC) for **DroseraNetwork**, showing how a user can batch multiple transactions (e.g., mints) in one call, and how a simple trap can be used to detect suspicious behavior.

## Components

- `BatchMinter.sol` → ERC-721 contract that allows batch minting of NFTs in a single transaction.
- `SimpleMintTrapV2.sol` → example Drosera trap that detects if too many mints happen in one block and responds to Drosera.
- `multiMint.js` → simple frontend script to batch mint using ethers.js.
- `drosera.toml` → configuration for running Drosera with Hoodi testnet, and Defines which contracts to monitor and how traps should respond.

## How to Run

1. Install Foundry and dependencies:
   ```bash
   forge install
   ```

2. Build contracts:
   ```bash
   forge build
   ```

3. Run tests:
   ```bash
   forge test
   ```

4. Connect to Drosera with your `drosera.toml` config.

## Network Config

This repo is configured for Hoodi testnet:
- Chain ID: **560048**
- RPC: `https://ethereum-hoodi-rpc.publicnode.com`
