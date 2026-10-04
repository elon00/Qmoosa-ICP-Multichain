#!/usr/bin/env bash
set -e

echo "=== Deploying Qmoosa ICP Canisters to Local Replica ==="
dfx start --background --clean || true
dfx deploy
echo "=== Local Deployment Complete ==="
dfx canister id frontend
