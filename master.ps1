# ============================================================================
# QMOOSA ICP MULTICHAIN — ONE-CLICK MASTER RUNNER (POWERSHELL)
# ============================================================================
$ErrorActionPreference = "Stop"

Write-Host "Starting Qmoosa ICP Master Runner..." -ForegroundColor Cyan
node scripts/master-runner.js
