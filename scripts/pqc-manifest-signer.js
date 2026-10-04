// NIST FIPS 204 manifest truth gate.
// Presence/length checks are metadata checks only; they are NOT ML-DSA verification.
import fs from 'node:fs';

console.log('--- Post-Quantum Manifest Truth Audit ---');

const manifest = {
  version: '1.0.0',
  name: 'Qmoosa ICP Core Canisters Genesis Build',
  algorithm: 'NIST FIPS 204 (ML-DSA-65)',
  targetHash: 'e7b6ed5a8efb2f8177b958cb35778621822b94ba78d5eb578747fa591dfc25bc',
  cryptographicVerifierIntegrated: false,
  independentlyVerified: false
};

if (!/^[a-f0-9]{64}$/i.test(manifest.targetHash)) {
  console.error('[FAIL] Invalid SHA-256 digest metadata');
  process.exit(1);
}

if (manifest.cryptographicVerifierIntegrated || manifest.independentlyVerified) {
  console.error('[FAIL] Baseline manifest must not claim ML-DSA verification before a real verifier exists.');
  process.exit(2);
}

if (!fs.existsSync('canisters/pqc/main.mo')) {
  console.error('[FAIL] PQC canister source missing');
  process.exit(3);
}

console.log('[PASS] PQC metadata/schema present.');
console.log('[PASS] No false claim of ML-DSA cryptographic verification.');
console.log('✓ FIPS 204 verifier integration remains an explicit production gate.');
