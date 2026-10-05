# Qmoosa SNS Tokenomics Specification

## 1. Overview
- **Token Name**: Qmoosa ICP
- **Symbol**: QMOOSA
- **Standard**: ICRC-1, ICRC-2, ICRC-3
- **Decimals**: 8
- **Transaction Fee**: 0.0001 QMOOSA (10,000 e8s)
- **Genesis Total Supply**: 1,000,000,000 QMOOSA (100,000,000,000,000,000 e8s)

---

## 2. Token Allocation Matrix

| Category | Allocation | Amount (QMOOSA) | Amount (e8s) | Vesting / Staking Terms |
|---|---|---|---|---|
| **Community Decentralization Swap** | 40% | 400,000,000 | 40,000,000,000,000,000 | Distributed in 3 SNS neuron baskets (0, 3, 6 months dissolve delays) |
| **Ecosystem & DAO Treasury** | 25% | 250,000,000 | 25,000,000,000,000,000 | Under strict SNS governance proposal control |
| **Neuron Staking Rewards** | 15% | 150,000,000 | 15,000,000,000,000,000 | Disbursed linearly over 4 years to active voting neurons |
| **Initial Liquidity Pools** | 10% | 100,000,000 | 10,000,000,000,000,000 | Seed liquidity for ICP DEXes (ICPSwap, Sonic) |
| **Core Contributors & Team** | 10% | 100,000,000 | 10,000,000,000,000,000 | 6-month cliff, 24-month linear neuron vesting |
| **Total Genesis Supply** | **100%** | **1,000,000,000** | **100,000,000,000,000,000** | Sovereign on-chain ledger |

---

## 3. Governance Neuron Staking Mechanics

### Voting Power Formula
$$\text{Voting Power} = \text{Staked Amount} \times \text{Dissolve Delay Bonus} \times \text{Age Bonus}$$

1. **Dissolve Delay Bonus**:
   - Minimum dissolve delay: 30 days (Multiplier: 1.0x)
   - 6 months dissolve delay: Multiplier 1.5x
   - Maximum dissolve delay: 8 years (Multiplier: 2.0x)

2. **Neuron Age Bonus**:
   - Multiplier scales from 1.0x to 1.25x for neurons that remain non-dissolving for up to 4 years.

3. **Proposal Rules**:
   - Quorum requirement: 3% of total circulating voting power.
   - Supermajority: Proposals require >50% yes votes to pass.
   - Timelock: 24-hour timelock after passing before execution.
