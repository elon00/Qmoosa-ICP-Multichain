# 14-Blockchain Integrations Reference

This document outlines the 14 integrated blockchain networks, their integration tier, cryptographic signing scheme, and the 8-step lifecycle.

## 3-Tier Classification

| Tier | Category | Networks | Integration Pattern | Trust Model |
|---|---|---|---|---|
| **Tier 1** | Native Direct | **Bitcoin, Dogecoin** | Native ICP canister UTXO state query & threshold ECDSA/Schnorr | Direct on-chain validation without external RPC servers |
| **Tier 2** | Dedicated RPC | **Ethereum, EVM (Base/Arb), Solana** | Dedicated EVM RPC Canister & SOL RPC Canister with threshold signatures | Trust-minimized RPC consensus with threshold Ed25519 / ECDSA |
| **Tier 3** | Extended Fusion | **Aptos, Avalanche, Cardano, Cosmos, NEAR, Polkadot, Stellar, TON, XRP** | Chain-key threshold signatures + ICP HTTPS Outcalls to consensus endpoints | Threshold cryptographic signatures with outcall consensus voting |

---

## 8-Step Definition of Done per Adapter

Each adapter implements the following standard 8-step lifecycle:

1. **Address Generation**: Derives chain-specific address from public key and derivation path.
2. **Balance Read**: Queries confirmed on-chain balance and native asset decimals.
3. **Network Status**: Checks node health, block height, and round-trip latency.
4. **Fee Estimation**: Returns slow, standard, and priority gas/fee estimates.
5. **Unsigned Tx Building**: Assembles raw binary payload and produces cryptographic digest.
6. **Chain-Key Signing**: Signs digest using ICP Management Canister threshold ECDSA/Ed25519.
7. **Broadcast**: Submits serialized signed transaction to network RPC.
8. **Transaction Verification**: Confirms receipt, block height, and confirmation count.
