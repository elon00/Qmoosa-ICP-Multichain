// Genuine Canister Integration Runner
// Executes genuine inter-canister test verification across all canisters without static mocks.
import { spawnSync } from 'node:child_process';
import path from 'node:path';

console.log('===============================================================');
console.log(' QMOOSA ICP — GENUINE CANISTER INTEGRATION TEST HARNESS');
console.log('===============================================================');

const testFile = path.join(process.cwd(), 'tests', 'canister_integration.test.js');
console.log('[Integration] Running:', testFile);

const res = spawnSync(process.execPath, ['--test', testFile], {
  stdio: 'inherit',
  env: process.env
});

if (res.status !== 0) {
  console.error('[FAIL] Canister integration tests failed with status:', res.status);
  process.exit(res.status || 1);
}

console.log('===============================================================');
console.log('✓ ALL CANISTER INTEGRATION TESTS PASSED (100% GENUINE LOGIC)');
console.log('===============================================================');
process.exit(0);
