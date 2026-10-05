# Canister Controllership Handoff to SNS Root

## Overview
This document specifies the irreversible process of transferring controllership of the 9 Qmoosa dapp canisters to the decentralized SNS Root canister.

---

## 1. Controlled Canister Inventory
The SNS Root canister must be added as the sole controller for:
1. `token` (ICRC-1/2/3 ledger)
2. `dao_governance` (Proposal & Neuron governance)
3. `launchpad` (Token factory)
4. `x402_gateway` (Micropayments gateway)
5. `agent_orchestrator` (Autonomous agent coordination)
6. `conway_engine` (Cellular automaton)
7. `automation` (Native heartbeat timers)
8. `pqc` (Post-quantum registry & verifier)
9. `frontend` (Asset canister)

---

## 2. Handoff Procedure

### Step 1: Deploy SNS Testflight locally
Verify the full SNS lifecycle in a local testnet before executing on mainnet:
```bash
dfx sns testflight --init-configfile sns/sns_init.yaml
```

### Step 2: Query SNS Root Principal
Once the SNS is created, query the generated SNS Root canister principal:
```bash
SNS_ROOT_PRINCIPAL=$(dfx canister --network ic id sns_root)
```

### Step 3: Add SNS Root as Controller to All 9 Canisters
```bash
for CANISTER in token dao_governance launchpad x402_gateway agent_orchestrator conway_engine automation pqc frontend; do
  dfx canister --network ic update-settings --add-controller "$SNS_ROOT_PRINCIPAL" "$CANISTER"
done
```

### Step 4: Verify Multiple Controllers
Verify that both the developer identity and SNS Root are listed:
```bash
dfx canister --network ic info token
```

### Step 5: Remove Developer Controllers (Irreversible Decentralization)
After testing governance proposals on the newly decentralized canisters, remove the developer identity controller:
```bash
DEV_PRINCIPAL=$(dfx identity get-principal)
for CANISTER in token dao_governance launchpad x402_gateway agent_orchestrator conway_engine automation pqc frontend; do
  dfx canister --network ic update-settings --remove-controller "$DEV_PRINCIPAL" "$CANISTER"
done
```
At this point, only SNS proposals can upgrade canisters or mint tokens.
