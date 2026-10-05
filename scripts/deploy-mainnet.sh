#!/usr/bin/env bash
set -euo pipefail

echo "=== Qmoosa ICP Mainnet Deployment ==="

command -v dfx >/dev/null 2>&1 || { echo "ERROR: dfx is required"; exit 10; }

echo "[preflight] Running strict reality gate..."
node scripts/mainnet-readiness.js --strict

echo "[preflight] Checking ICP connectivity..."
dfx ping ic >/dev/null

echo "[preflight] Active identity: $(dfx identity whoami)"
echo "[preflight] Principal: $(dfx identity get-principal)"

if [[ "${QMOOSA_CONFIRM_MAINNET:-}" != "YES" ]]; then
  echo "ERROR: set QMOOSA_CONFIRM_MAINNET=YES to authorize a real mainnet deployment."
  exit 11
fi

echo "[deploy] Building frontend..."
npm run build

echo "[deploy] Deploying all canisters to ICP mainnet..."
dfx deploy --network ic

mkdir -p deployments
node <<'NODE'
const { execFileSync } = require('node:child_process');
const fs = require('node:fs');
const names = ['token','dao_governance','launchpad','x402_gateway','agent_orchestrator','conway_engine','automation','pqc','frontend'];
const canisters = {};
for (const name of names) {
  canisters[name] = execFileSync('dfx',['canister','id','--network','ic',name],{encoding:'utf8'}).trim();
}
const evidence = {
  network: 'ic',
  deployedAt: new Date().toISOString(),
  canisters,
  frontendUrl: `https://${canisters.frontend}.icp0.io`,
  verification: {
    independentlyVerified: false,
    note: 'Set to true only after ICP Dashboard / independent lookup confirms every canister ID.'
  }
};
fs.writeFileSync('deployments/mainnet-evidence.json', JSON.stringify(evidence,null,2)+'\n');
console.log(JSON.stringify(evidence,null,2));
NODE

echo "Deployment submitted. Independent verification is still REQUIRED before mission completion."
