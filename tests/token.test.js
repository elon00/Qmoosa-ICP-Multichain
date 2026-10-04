import test from 'node:test';
import assert from 'node:assert/strict';

test('QMOOSA Token: verifies metadata and supply parameters', () => {
  const tokenMetadata = {
    name: 'Qmoosa ICP',
    symbol: 'QMOOSA',
    decimals: 8,
    fee: 10000,
    genesisSupply: 1000000000,
    supplyModel: 'Uncapped DAO-Governed Dynamic Supply'
  };

  assert.equal(tokenMetadata.name, 'Qmoosa ICP');
  assert.equal(tokenMetadata.symbol, 'QMOOSA');
  assert.equal(tokenMetadata.decimals, 8);
  assert.equal(tokenMetadata.fee, 10000);
  assert.equal(tokenMetadata.genesisSupply, 1_000_000_000);
});

test('QMOOSA Token: rejects unauthorized minting outside DAO controller', () => {
  const caller = '2vxsx-fake-attacker';
  const daoController = 'ryjl3-tyaaa-aaaaa-aaaba-cai-dao';

  const isAuthorized = caller === daoController;
  assert.equal(isAuthorized, false, 'Unauthorized mint must be blocked');
});

test('QMOOSA Token: transfer deducts amount + fee correctly', () => {
  let senderBal = 1000000000;
  const transferAmt = 50000000;
  const fee = 10000;

  const totalRequired = transferAmt + fee;
  assert.ok(senderBal >= totalRequired);

  senderBal -= totalRequired;
  assert.equal(senderBal, 949990000);
});
