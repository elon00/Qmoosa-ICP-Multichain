#!/usr/bin/env bash
set -euo pipefail

echo "================================================================="
echo " QMOOSA ICP — REALITY-BASED ONE-CLICK BASELINE MISSION"
echo "================================================================="

echo "[1/7] Runtime"
node -v

echo "[2/7] Unit tests"
npm test

echo "[3/7] Frontend production build"
npm run build

echo "[4/7] PQC truth gate"
node scripts/pqc-manifest-signer.js

echo "[5/7] x402 fail-closed truth gate"
node scripts/simulate-x402.js

echo "[6/7] Reality-based readiness report"
node scripts/mainnet-readiness.js

echo "[7/7] Result"
echo "Baseline validation completed."
echo "IMPORTANT: mainnet readiness is only GREEN when: npm run reality:mainnet exits 0."
echo "================================================================="
