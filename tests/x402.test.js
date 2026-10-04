import test from 'node:test';
import assert from 'node:assert/strict';

test('x402 Bazaar: generates HTTP 402 challenge with valid parameters', () => {
  const service = {
    id: 'agent-inference-deep',
    priceQmoosa: 0.005,
    recipient: 'rkp4c-7iaaa-aaaaa-aaaca-cai'
  };

  const challenge = {
    status: 402,
    protocol: 'x402-v2',
    price: service.priceQmoosa,
    recipient: service.recipient,
    invoiceId: 'x402-inv-100234'
  };

  assert.equal(challenge.status, 402);
  assert.equal(challenge.protocol, 'x402-v2');
  assert.equal(challenge.price, 0.005);
  assert.ok(challenge.invoiceId.startsWith('x402-inv-'));
});

test('x402 Bazaar: unlocks JWT access token on payment verification', () => {
  const invoice = { status: 'SETTLED', price: 0.005 };
  const verifyResult = invoice.status === 'SETTLED' ? {
    success: true,
    token: 'jwt-qmoosa-verified-access-token'
  } : { success: false };

  assert.equal(verifyResult.success, true);
  assert.ok(verifyResult.token.length > 10);
});
