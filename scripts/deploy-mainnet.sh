#!/usr/bin/env bash
set -e

echo "=== Deploying Qmoosa ICP to Mainnet Subnet ==="
echo "Ensuring mainnet connection..."
dfx ping ic

echo "Deploying canisters to mainnet with cycles..."
dfx deploy --network ic token
dfx deploy --network ic dao_governance
dfx deploy --network ic launchpad
dfx deploy --network ic x402_gateway
dfx deploy --network ic agent_orchestrator
dfx deploy --network ic conway_engine
dfx deploy --network ic automation
dfx deploy --network ic pqc
dfx deploy --network ic frontend

echo "=== Mainnet Deployment Successful! ==="
echo "Frontend Mainnet URL: https://$(dfx canister id --network ic frontend).icp0.io"
