# Qmoosa ICP — Mainnet & Staging Deployment Guide

## 1. Prerequisites
- **Node.js**: v22+ LTS (Node v24 supported)
- **DFX SDK**: v0.24.0+ (or `@icp-sdk/icp-cli`)
- **ICP Cycles Wallet**: Funded principal with at least 15 Trillion cycles (~$20 USD) for canister deployment.

---

## 2. Fast Local Deployment
To start a local replica and deploy all 8 canisters in one step:

```bash
# 1. Start local Internet Computer replica
dfx start --background --clean

# 2. Deploy all canisters locally
dfx deploy

# 3. View canister URLs
dfx canister id frontend
# Open: http://localhost:4943/?canisterId=<frontend_canister_id>
```

---

## 3. Staging and PocketIC Testing
Run the automated validation suite before mainnet:

```bash
# Run unit & mock integration tests
npm test

# Run PocketIC canister tests
npm run test:pocketic
```

---

## 4. Mainnet Deployment Procedure

> [!IMPORTANT]
> Mainnet canister creation consumes real cycles. Ensure your cycles ledger or wallet has adequate reserves.

```bash
# 1. Verify environment and network connection
dfx ping ic

# 2. Deploy core canisters to mainnet
dfx deploy --network ic --with-cycles 2000000000000 token
dfx deploy --network ic --with-cycles 2000000000000 dao_governance
dfx deploy --network ic --with-cycles 2000000000000 launchpad
dfx deploy --network ic --with-cycles 2000000000000 x402_gateway
dfx deploy --network ic --with-cycles 2000000000000 agent_orchestrator
dfx deploy --network ic --with-cycles 2000000000000 conway_engine
dfx deploy --network ic --with-cycles 2000000000000 automation
dfx deploy --network ic --with-cycles 2000000000000 pqc
dfx deploy --network ic --with-cycles 2000000000000 frontend

# 3. Or run the One-Click Master Pipeline
npm run mission
```
