import test from 'node:test';
import assert from 'node:assert/strict';

class SimulatedX402Gateway {
  constructor() {
    this.invoices = new Map();
    this.settledTxs = new Map();
    this.settledInvoices = new Map();
    this.counter = 0;
    this.recipient = 'qmoosa-x402-gateway-principal';
  }

  requestInvoice(serviceId, price) {
    this.counter++;
    const invoiceId = `x402-inv-${this.counter}`;
    const inv = {
      invoiceId,
      serviceId,
      price,
      recipient: this.recipient,
      status: 'PENDING',
      expiresAt: Date.now() + 600000
    };
    this.invoices.set(invoiceId, inv);
    return { status: 402, invoice: inv };
  }

  settleWithProof({ invoiceId, txId, amount, sender, recipient, memo }) {
    const inv = this.invoices.get(invoiceId);
    if (!inv) return { success: false, error: 'Invoice not found' };
    if (Date.now() > inv.expiresAt) return { success: false, error: 'Invoice expired' };
    if (this.settledInvoices.has(invoiceId)) {
      return { success: true, token: this.settledInvoices.get(invoiceId).token };
    }
    // Replay protection
    if (this.settledTxs.has(txId)) {
      return { success: false, error: `Replay attack detected: tx ${txId} already claimed` };
    }
    // Recipient check
    if (recipient !== inv.recipient) {
      return { success: false, error: 'Recipient mismatch' };
    }
    // Amount check
    if (amount < inv.price) {
      return { success: false, error: 'Insufficient payment' };
    }
    // Memo check
    if (memo && memo !== invoiceId) {
      return { success: false, error: 'Memo mismatch' };
    }

    const token = `x402-token-${invoiceId}-tx${txId}-${Date.now()}`;
    const receipt = { invoiceId, txId, amount, sender, recipient, token, settledAt: Date.now() };
    this.settledTxs.set(txId, receipt);
    this.settledInvoices.set(invoiceId, receipt);
    inv.status = 'SETTLED';
    return { success: true, token, receipt };
  }

  verifyPayment(invoiceId, txId) {
    const receipt = this.settledInvoices.get(invoiceId);
    if (receipt && receipt.txId === txId) {
      return { success: true, token: receipt.token };
    }
    return { success: false, error: 'Unverified transaction proof required' };
  }
}

test('x402 Bazaar: generates HTTP 402 challenge metadata', () => {
  const gw = new SimulatedX402Gateway();
  const challenge = gw.requestInvoice('agent-inference-deep', 500000);

  assert.equal(challenge.status, 402);
  assert.ok(challenge.invoice.invoiceId.startsWith('x402-inv-'));
  assert.equal(challenge.invoice.price, 500000);
  assert.equal(challenge.invoice.status, 'PENDING');
});

test('x402 Bazaar: remains fail-closed without independently verified ledger proof', () => {
  const gw = new SimulatedX402Gateway();
  const { invoice } = gw.requestInvoice('agent-inference-deep', 500000);

  const res = gw.verifyPayment(invoice.invoiceId, 99999);
  assert.equal(res.success, false);
  assert.match(res.error, /Unverified transaction proof/i);
});

test('x402 Bazaar: settles invoice with valid ICRC ledger transaction proof', () => {
  const gw = new SimulatedX402Gateway();
  const { invoice } = gw.requestInvoice('agent-inference-deep', 500000);

  const proof = {
    invoiceId: invoice.invoiceId,
    txId: 1042,
    amount: 500000,
    sender: 'user-principal-abc',
    recipient: 'qmoosa-x402-gateway-principal',
    memo: invoice.invoiceId
  };

  const settleRes = gw.settleWithProof(proof);
  assert.equal(settleRes.success, true);
  assert.ok(settleRes.token.startsWith(`x402-token-${invoice.invoiceId}-tx1042-`));

  const verifyRes = gw.verifyPayment(invoice.invoiceId, 1042);
  assert.equal(verifyRes.success, true);
  assert.equal(verifyRes.token, settleRes.token);
});

test('x402 Bazaar: rejects underpayment', () => {
  const gw = new SimulatedX402Gateway();
  const { invoice } = gw.requestInvoice('agent-inference-deep', 500000);

  const underpaidProof = {
    invoiceId: invoice.invoiceId,
    txId: 1043,
    amount: 250000, // half price
    sender: 'user-principal-abc',
    recipient: 'qmoosa-x402-gateway-principal',
    memo: invoice.invoiceId
  };

  const res = gw.settleWithProof(underpaidProof);
  assert.equal(res.success, false);
  assert.match(res.error, /Insufficient payment/i);
});

test('x402 Bazaar: rejects recipient mismatch', () => {
  const gw = new SimulatedX402Gateway();
  const { invoice } = gw.requestInvoice('agent-inference-deep', 500000);

  const wrongRecipientProof = {
    invoiceId: invoice.invoiceId,
    txId: 1044,
    amount: 500000,
    sender: 'user-principal-abc',
    recipient: 'some-other-address-principal',
    memo: invoice.invoiceId
  };

  const res = gw.settleWithProof(wrongRecipientProof);
  assert.equal(res.success, false);
  assert.match(res.error, /Recipient mismatch/i);
});

test('x402 Bazaar: prevents replay attack (double spending same txId)', () => {
  const gw = new SimulatedX402Gateway();
  const inv1 = gw.requestInvoice('agent-inference-deep', 500000).invoice;
  const inv2 = gw.requestInvoice('chain-fusion-oracle', 250000).invoice;

  const validProof1 = {
    invoiceId: inv1.invoiceId,
    txId: 8888,
    amount: 500000,
    sender: 'payer-principal',
    recipient: 'qmoosa-x402-gateway-principal',
    memo: inv1.invoiceId
  };

  const res1 = gw.settleWithProof(validProof1);
  assert.equal(res1.success, true);

  // Attempt replay with same txId on inv2
  const replayProof = {
    invoiceId: inv2.invoiceId,
    txId: 8888, // REPLAY!
    amount: 250000,
    sender: 'payer-principal',
    recipient: 'qmoosa-x402-gateway-principal',
    memo: inv2.invoiceId
  };

  const res2 = gw.settleWithProof(replayProof);
  assert.equal(res2.success, false);
  assert.match(res2.error, /Replay attack detected/i);
});
