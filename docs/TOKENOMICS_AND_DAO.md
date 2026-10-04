# Qmoosa ICP — Global Standard Tokenomics & SNS DAO Model

## 1. Tokenomics Specifications

| Parameter | Value |
|---|---|
| **Token Name** | Qmoosa ICP |
| **Token Symbol** | `QMOOSA` |
| **Token Standards** | ICRC-1 (Fungible), ICRC-2 (Approve/Allowance), ICRC-3 (Transaction Logs) |
| **Decimals** | 8 (1 QMOOSA = 100,000,000 e8s) |
| **Transfer Fee** | 10,000 e8s (0.0001 QMOOSA) |
| **Genesis Circulating Supply** | 1,000,000,000 QMOOSA |
| **Max Cap** | Uncapped, Strictly DAO-Governed |
| **Minting Controller** | `dao_governance` canister only |

---

## 2. Genesis Allocation Breakdown

```
┌────────────────────────────────────────────────────────┐
│  Ecosystem & Builder Incentives : 30% (300,000,000)   │
│  Community & DAO Treasury       : 20% (200,000,000)   │
│  Neuron Staking Rewards Reserve : 15% (150,000,000)   │
│  Core Protocol Development      : 15% (150,000,000)   │
│  x402 Liquidity & Market Making : 10% (100,000,000)   │
│  Strategic Partnerships         :  5% ( 50,000,000)   │
│  Marketing & Communications     :  5% ( 50,000,000)   │
└────────────────────────────────────────────────────────┘
```

---

## 3. The Uncapped DAO-Controlled Issuance Model

### The Danger of Traditional Hard Caps vs. Blind Inflation:
- **Hardcoded Infinite Integer**: Reckless and vulnerable to unauthorized runaway inflation.
- **Fixed Hard Cap**: Can stifle dynamic ecosystem rewards and compute subsidy expansions over decades.

### The Qmoosa Solution:
QMOOSA implements an **uncapped, programmatic governance-controlled issuance model**:
1. At Genesis, circulating supply is initialized to 1 Billion tokens.
2. The `dao_mint()` method on the `token` canister can **only** be triggered by the `dao_governance` canister.
3. Any new issuance requires:
   - A formal on-chain DAO proposal specifying recipient, exact amount, and purpose.
   - A minimum 3-day token-holder voting period.
   - A strict 50,000,000 QMOOSA voting quorum.
   - A mandatory 24-hour on-chain execution timelock.
4. All minting events are immutably appended to the ICRC-3 ledger audit log.

---

## 4. SNS Neuron Staking (Proof-of-Stake Governance)

Token holders stake QMOOSA into **SNS Governance Neurons** to earn voting power and protocol yield:

$$\text{Voting Power} = \text{Staked Amount} \times \left(1 + \frac{\text{Dissolve Delay (Months)}}{12} \times 0.5\right)$$

- **Minimum Stake**: 1 QMOOSA.
- **Dissolve Delay Range**: 1 month (1.04x) to 24 months (2.0x).
- **Followee Delegation**: Neurons can delegate voting power to specialized sub-DAOs (e.g., Security Council, AI Research Guild).
