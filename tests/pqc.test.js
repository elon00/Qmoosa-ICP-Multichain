import { test } from 'node:test';
import assert from 'node:assert/strict';
import { ml_dsa65 } from '@noble/post-quantum/ml-dsa.js';
import crypto from 'node:crypto';

test('PQC ML-DSA-65: generates valid keypair with NIST standard byte lengths', () => {
  const keys = ml_dsa65.keygen();
  assert.equal(keys.publicKey.length, 1952, 'ML-DSA-65 public key must be 1952 bytes per FIPS 204');
  assert.equal(keys.secretKey.length, 4032, 'ML-DSA-65 secret key must be 4032 bytes per FIPS 204');
});

test('PQC ML-DSA-65: signs and cryptographically verifies message digest', () => {
  const keys = ml_dsa65.keygen();
  const testDigest = crypto.createHash('sha256').update('qmoosa-pqc-verification-suite').digest();
  
  const signature = ml_dsa65.sign(testDigest, keys.secretKey);
  assert.equal(signature.length, 3309, 'ML-DSA-65 signature must be 3309 bytes per FIPS 204');

  const isValid = ml_dsa65.verify(signature, testDigest, keys.publicKey);
  assert.equal(isValid, true, 'Valid signature must verify successfully');
});

test('PQC ML-DSA-65: rejects tampered message digest (fail-closed)', () => {
  const keys = ml_dsa65.keygen();
  const testDigest = crypto.createHash('sha256').update('legitimate-canister-binary').digest();
  const signature = ml_dsa65.sign(testDigest, keys.secretKey);

  const tamperedDigest = Buffer.from(testDigest);
  tamperedDigest[0] ^= 0x01; // flip 1 bit

  const isValid = ml_dsa65.verify(signature, tamperedDigest, keys.publicKey);
  assert.equal(isValid, false, 'Tampered digest must NOT verify');
});

test('PQC ML-DSA-65: rejects signature against mismatched public key', () => {
  const keys1 = ml_dsa65.keygen();
  const keys2 = ml_dsa65.keygen();
  const testDigest = crypto.createHash('sha256').update('multichain-manifest').digest();

  const signature = ml_dsa65.sign(testDigest, keys1.secretKey);
  const isValid = ml_dsa65.verify(signature, testDigest, keys2.publicKey);
  assert.equal(isValid, false, 'Signature must fail against alien public key');
});
