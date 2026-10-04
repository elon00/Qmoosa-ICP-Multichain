# Frequently Asked Questions (FAQ)

### 1. Does Qmoosa hold user private keys?
No. Qmoosa uses ICP Chain-Key threshold cryptography (Threshold ECDSA, Schnorr, Ed25519). Key shares are distributed across ICP subnets and transactions are authorized collaboratively by canisters without any single party having access to a private key.

### 2. How does x402 Bazaar work?
x402 uses the standard HTTP status code `402 Payment Required`. When an AI agent or client requests a paid resource, the server returns an invoice challenge. Once payment is settled on-chain (using ICP, ckBTC, ckETH, ckSOL, or USDC), access is unlocked cryptographically.

### 3. What is the difference between local preview and mainnet deployment?
The local preview server (`localhost:3000`) and unit tests demonstrate the functional architecture. Canisters are only considered mainnet deployed when `dfx deploy --network ic` is executed using real cycles and real canister IDs are verifiably published.
