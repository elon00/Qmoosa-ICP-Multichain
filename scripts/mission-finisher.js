import { execSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

const args = process.argv.slice(2);
const modeIndex = args.indexOf('--mode');
const mode = modeIndex >= 0 ? args[modeIndex + 1] : 'baseline';
if (!['baseline','testnet','mainnet'].includes(mode)) {
  console.error('Unsupported mode: ' + mode);
  process.exit(2);
}

const evidenceDir = path.join(process.cwd(), 'deployments');
const evidenceFile = path.join(evidenceDir, mode + '-evidence.json');

function run(label, command) {
  process.stdout.write('[finisher] ' + label + '... ');
  try {
    execSync(command, { stdio: 'inherit', env: process.env });
    console.log('PASS');
  } catch (error) {
    console.log('FAIL');
    process.exit(error.status || 1);
  }
}

function requireLiveEvidence() {
  if (!fs.existsSync(evidenceFile)) {
    console.error('[finisher] Missing ' + mode + ' evidence file: deployments/' + mode + '-evidence.json');
    process.exit(3);
  }
  const evidence = JSON.parse(fs.readFileSync(evidenceFile, 'utf8'));
  if (!Array.isArray(evidence.transactions) || evidence.transactions.length === 0) {
    console.error('[finisher] No live transactions recorded.');
    process.exit(4);
  }
  if (evidence.verification?.independentlyVerified !== true) {
    console.error('[finisher] Live evidence is not independently verified.');
    process.exit(5);
  }
}

console.log('===============================================================');
console.log(' QMOOSA ICP MULTICHAIN — MISSION FINISHER');
console.log(' Mode: ' + mode.toUpperCase());
console.log('===============================================================');

run('Unit tests', 'npm test');
run('PocketIC baseline harness', 'npm run test:pocketic');
run('Frontend production build', 'npm run build');
run('x402 fail-closed truth gate', 'node scripts/simulate-x402.js');
run('PQC truth gate', 'node scripts/pqc-manifest-signer.js');

if (mode !== 'baseline') {
  requireLiveEvidence();
  console.log('[finisher] ' + mode + ' evidence gate: PASS');
} else {
  console.log('[finisher] Baseline mode skips live deployment by design.');
}

const report = {
  project: 'Qmoosa ICP Multichain',
  mode,
  completedAt: new Date().toISOString(),
  baselineVerified: true,
  liveEvidenceVerified: mode !== 'baseline',
  x402FailClosed: true,
  pqcCryptographicVerifierVerified: false,
  mainnetDeploymentVerified: false,
  status: mode === 'baseline' ? 'AUTOMATION_BASELINE_COMPLETE' : 'LIVE_EVIDENCE_GATE_COMPLETE'
};

fs.mkdirSync(evidenceDir, { recursive: true });
fs.writeFileSync(path.join(evidenceDir, 'mission-finisher-' + mode + '.json'), JSON.stringify(report, null, 2) + '\n', 'utf8');

console.log('===============================================================');
console.log(mode === 'baseline' ? 'MISSION FINISHER BASELINE COMPLETED SUCCESSFULLY' : 'MISSION FINISHER ' + mode.toUpperCase() + ' EVIDENCE GATE COMPLETED SUCCESSFULLY');
console.log('===============================================================');
