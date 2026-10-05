import fs from 'node:fs';

const strict = process.argv.includes('--strict');
const checks = [];
const add = (name, ok, detail) => checks.push({ name, ok, detail });
const read = (p) => fs.existsSync(p) ? fs.readFileSync(p, 'utf8') : '';

const pkg = JSON.parse(read('package.json'));
const pqc = read('canisters/pqc/main.mo');
const x402 = read('canisters/x402_gateway/main.mo');
const dao = read('canisters/dao_governance/main.mo');
const launchpad = read('canisters/launchpad/main.mo');

add('Repository package manifest', !!pkg?.scripts, 'package.json is readable');
add('Unit test command', typeof pkg?.scripts?.test === 'string', pkg?.scripts?.test || 'missing');
add('Frontend build command', typeof pkg?.scripts?.build === 'string', pkg?.scripts?.build || 'missing');
add('DFX manifest', fs.existsSync('dfx.json'), 'dfx.json must exist');
add('Mainnet deploy script', fs.existsSync('scripts/deploy-mainnet.sh'), 'scripts/deploy-mainnet.sh must exist');

add(
  'Real PocketIC/integration harness',
  !String(pkg?.scripts?.['test:pocketic'] || '').includes('pocketic_mock'),
  String(pkg?.scripts?.['test:pocketic'] || 'missing')
);

add(
  'PQC cryptographic verifier',
  !/NOT YET INTEGRATED|No in-canister FIPS 204 verifier is integrated/i.test(pqc),
  'A real verifier must replace metadata-only PQC checks'
);

add(
  'x402 live ledger settlement verifier',
  !/Live settlement verification is not configured|FAIL_CLOSED_PENDING_LEDGER_VERIFIER/i.test(x402),
  'x402 must verify live ledger proof before granting access'
);

add(
  'DAO proposal execution wiring',
  !/Execution adapter is intentionally disabled|LOCKED_PENDING_SNS_INTEGRATION/i.test(dao),
  'Governance execution must be wired and tested'
);

add(
  'Launchpad truthfulness',
  !/mock_canister_id|Deployed & Verified/i.test(launchpad),
  'Launchpad must not generate synthetic deployment IDs or claim unverified deployment'
);

const evidencePath = 'deployments/mainnet-evidence.json';
let evidenceOk = false;
let evidenceDetail = 'missing deployments/mainnet-evidence.json';
if (fs.existsSync(evidencePath)) {
  try {
    const e = JSON.parse(read(evidencePath));
    const ids = e?.canisters && typeof e.canisters === 'object' ? Object.values(e.canisters) : [];
    evidenceOk = e?.verification?.independentlyVerified === true && ids.length >= 9 && ids.every(Boolean);
    evidenceDetail = evidenceOk ? 'verified mainnet canister evidence present' : 'evidence exists but is incomplete/unverified';
  } catch {
    evidenceDetail = 'invalid JSON in mainnet evidence';
  }
}
add('Verified mainnet deployment evidence', evidenceOk, evidenceDetail);

const failed = checks.filter(c => !c.ok);
console.log('=== QMOOSA ICP REALITY-BASED MAINNET READINESS ===');
for (const c of checks) console.log(`${c.ok ? '[GREEN]' : '[BLOCKED]'} ${c.name}: ${c.detail}`);
console.log(`Summary: ${checks.length - failed.length}/${checks.length} gates green; ${failed.length} blocker(s).`);

fs.mkdirSync('deployments', { recursive: true });
fs.writeFileSync('deployments/readiness-report.json', JSON.stringify({
  generatedAt: new Date().toISOString(),
  strict,
  green: failed.length === 0,
  checks
}, null, 2) + '\n');

if (strict && failed.length) process.exit(1);
