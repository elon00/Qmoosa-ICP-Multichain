Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " QMOOSA ICP -- REALITY-BASED ONE-CLICK BASELINE MISSION" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

Write-Host "[1/7] Runtime" -ForegroundColor Yellow
node -v
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[2/7] Unit tests" -ForegroundColor Yellow
npm test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[3/7] Frontend production build" -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[4/7] PQC truth gate" -ForegroundColor Yellow
node scripts/pqc-manifest-signer.js
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[5/7] x402 fail-closed truth gate" -ForegroundColor Yellow
node scripts/simulate-x402.js
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[6/7] Reality-based readiness report" -ForegroundColor Yellow
node scripts/mainnet-readiness.js
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[7/7] Result" -ForegroundColor Yellow
Write-Host "Baseline validation completed." -ForegroundColor Green
Write-Host "IMPORTANT: mainnet readiness is only GREEN when npm run reality:mainnet exits 0." -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
