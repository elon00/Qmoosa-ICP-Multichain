import test from 'node:test';
import assert from 'node:assert/strict';

test('DAO Governance: calculates neuron voting power with dissolve delay multiplier', () => {
  const calculateVotingPower = (stakedAmount, dissolveDelayMonths) => {
    const bonus = 1 + (dissolveDelayMonths / 12) * 0.5;
    return Math.round(stakedAmount * bonus);
  };

  const vp1Month = calculateVotingPower(10000, 1);
  const vp6Month = calculateVotingPower(10000, 6);
  const vp24Month = calculateVotingPower(10000, 24);

  assert.equal(vp1Month, 10417);
  assert.equal(vp6Month, 12500);
  assert.equal(vp24Month, 20000); // 2x voting power for 2-year lock
});

test('DAO Governance: passes proposal only when quorum and majority are achieved', () => {
  const proposal = {
    yesVotes: 65000000,
    noVotes: 12000000,
    quorum: 50000000
  };

  const hasReachedQuorum = proposal.yesVotes >= proposal.quorum;
  const isMajorityYes = proposal.yesVotes > proposal.noVotes;

  assert.ok(hasReachedQuorum);
  assert.ok(isMajorityYes);
  assert.equal(hasReachedQuorum && isMajorityYes, true);
});
