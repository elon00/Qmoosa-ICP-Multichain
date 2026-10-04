// x402 Protocol Machine-to-Machine Simulation Script
console.log('--- Simulating x402 Bazaar Protocol Machine Micropayment ---');

const invoice = {
  serviceId: 'agent-inference-deep',
  price: '0.005 QMOOSA',
  recipientCanister: 'rkp4c-7iaaa-aaaaa-aaaca-cai',
  status: '402 Payment Required'
};
console.log(`[x402-Gateway] Challenge: HTTP 402 - Price: ${invoice.price}`);

const paymentTx = {
  txId: 98124,
  amount: 500000,
  fee: 10000,
  from: '2vxsx-fae-agent',
  to: invoice.recipientCanister,
  status: 'SETTLED_ON_ICRC_LEDGER'
};
console.log(`[ICRC-Ledger] Settled Transfer Tx #${paymentTx.txId} (Fee: 0.0001 QMOOSA)`);

const token = 'eyJhbGciOiJNTF9EU0FfNjUiLCJ0eXAiOiJKV1QifQ.qmoosa_verified_access_token';
console.log(`[x402-Gateway] Verification PASS: JWT Token Issued: ${token.slice(0, 32)}...`);
console.log('✓ x402 Protocol Verification Flow Complete.');
