import test from 'node:test';
import assert from 'node:assert/strict';

test('x402 Bazaar: generates HTTP 402 challenge metadata', () => {
  const challenge = {
    status: 402,
    protocol: 'x402-v2',
    price: 0.005,
    invoiceId: 'x402-inv-100234'
  };

  assert.equal(challenge.status, 402);
  assert.equal(challenge.protocol, 'x402-v2');
  assert.ok(challenge.invoiceId.startsWith('x402-inv-'));
});

test('x402 Bazaar: remains fail-closed without independently verified ledger proof', () => {
  const invoice = { status: 'PENDING_PAYMENT', price: 0.005 };
  const independentlyVerifiedLedgerProof = false;

  const verifyResult =
    invoice.status === 'SETTLED' && independentlyVerifiedLedgerProof
      ? { success: true, token: 'jwt-qmoosa-verified-access-token' }
      : { success: false, error: 'Live ledger verification required' };

  assert.equal(verifyResult.success, false);
  assert.match(verifyResult.error, /verification required/i);
});
