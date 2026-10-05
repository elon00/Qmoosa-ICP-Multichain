# Qmoosa ICP — Mainnet Deployment Pipeline (PowerShell)
$ErrorActionPreference = "Stop"

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host " QMOOSA ICP — MAINNET DEPLOYMENT PIPELINE" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan

# 1. Local Preflight Audits
node scripts/mainnet-preflight.js
node scripts/pqc-manifest-signer.js
node scripts/simulate-x402.js

# 2. Check DFX command
if (-not (Get-Command "dfx" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] dfx is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install dfx (or run inside WSL): https://internetcomputer.org/docs/current/developer-docs/getting-started/install/" -ForegroundColor Yellow
    exit 1
}

# 3. Ping mainnet
Write-Host "[deploy] Pinging Internet Computer mainnet..." -ForegroundColor Green
dfx ping ic

# 4. Check active identity
$CurrentIdentity = (dfx identity whoami).Trim()
$CurrentPrincipal = (dfx identity get-principal).Trim()
Write-Host "[deploy] Active Identity: $CurrentIdentity ($CurrentPrincipal)" -ForegroundColor Green

if ($CurrentPrincipal -eq "2vxsx-anonymous") {
    Write-Host "[ERROR] Cannot deploy to mainnet using anonymous identity." -ForegroundColor Red
    Write-Host "Run: dfx identity new deployer; dfx identity use deployer" -ForegroundColor Yellow
    exit 2
}

# 5. Check Cycles balance
Write-Host "[deploy] Checking cycles balance on mainnet..." -ForegroundColor Green
try {
    $CyclesBalance = dfx cycles balance --network ic
    Write-Host "[deploy] Available cycles: $CyclesBalance" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Unable to fetch cycles balance. Ensure cycles wallet is configured." -ForegroundColor Yellow
}

# 6. Deploy canisters
$canisters = @("token", "dao_governance", "launchpad", "x402_gateway", "agent_orchestrator", "conway_engine", "automation", "pqc", "frontend")
foreach ($canister in $canisters) {
    Write-Host "[deploy] Deploying $canister to ICP mainnet..." -ForegroundColor Cyan
    dfx deploy --network ic $canister
}

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "✓ QMOOSA ICP MAINNET DEPLOYMENT COMPLETE" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Cyan
