# Qmoosa ICP — Official Testing Guide: OISY Wallet + TESTICP Faucet + ICP Dashboard

This document details the official testing workflow for **Qmoosa ICP** using the DFINITY ecosystem's native testing infrastructure: **OISY Wallet**, the **Internet Computer Test Token Faucet**, and the **ICP Dashboard Explorer**.

---

## 1. Why OISY Wallet for Qmoosa ICP?
**OISY Wallet** ([oisy.com](https://oisy.com/)) was incubated at the DFINITY Foundation and is the world's first **fully on-chain digital asset terminal**:
- **Authentication**: Native **Internet Identity** (passkeys, biometric WebAuthn, hardware security keys). Zero seed phrase vulnerabilities.
- **Security**: No decentralized application can move funds without explicit, interactive cryptographic confirmation from the user.
- **Chain Fusion**: Unified support for ICP, Ethereum/EVM, and Bitcoin assets directly on-chain.
- **Standard**: Integrates with dApps via the **ICRC-25 / Signer Standard** ("Connect with OISY").

---

## 2. Testnet Tokens & Canister IDs

| Entity | Description | Official URL / Identifier |
|---|---|---|
| **Free Faucet** | Dispenses 10 TESTICP free test tokens | [faucet.internetcomputer.org](https://faucet.internetcomputer.org/) |
| **TESTICP Ledger Canister** | Official ICRC test ledger canister on ICP | `xafvr-biaaa-aaaai-aql5q-cai` |
| **Ledger Dashboard** | ICP Canister state, cycles, and metrics | [dashboard.internetcomputer.org/canister/xafvr-biaaa-aaaai-aql5q-cai](https://dashboard.internetcomputer.org/canister/xafvr-biaaa-aaaai-aql5q-cai) |
| **Transaction Explorer** | Live block scanner for TESTICP transfers | [dashboard.internetcomputer.org/tokens/xafvr-biaaa-aaaai-aql5q-cai/transactions](https://dashboard.internetcomputer.org/tokens/xafvr-biaaa-aaaai-aql5q-cai/transactions) |

> [!NOTE]
> Unlike Ethereum or Solana which run entirely separate testnet blockchains (Sepolia, Devnet), ICP uses an on-chain **TESTICP Ledger Canister** running directly on the Internet Computer network. TESTICP holds zero monetary value and is designed purely for testing transfers, ICRC approvals, and canister integration.

---

## 3. Step-by-Step Testing Workflow

### Step 1: Obtain your Public Principal ID
You can obtain your public Principal in two ways:

#### Option A: From OISY Wallet (Recommended for End-to-End Testing)
1. Open [https://oisy.com](https://oisy.com).
2. Sign in with your **Internet Identity** (via TouchID, FaceID, Windows Hello, or YubiKey).
3. In OISY, click on your ICP account or the **Receive** button.
4. Copy your **Public Principal ID** (format: `xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxx`).

#### Option B: Generate a Test Principal via Qmoosa Script
Run the local Qmoosa ICP generator script:
```bash
node scripts/generate-test-principal.js
```
Sample generated principal:
`xwaxc-vg2te-sfugg-4ugnj-o6zke-hqfx4-os4rs-fzhlv-3knyj-7audo-oqe`

---

### Step 2: Claim 10 TESTICP from the Faucet
1. Visit the [Internet Computer Faucet](https://faucet.internetcomputer.org/).
2. Select **TESTICP** in the token dropdown menu.
3. Paste your **Public Principal ID** into the recipient box.
4. Complete the verification challenge and click **Claim**.
5. The faucet will transfer **10 TESTICP** to your principal within ~1–2 seconds.

---

### Step 3: Verify on the ICP Dashboard Explorer
1. Navigate to the [TESTICP Live Transactions Explorer](https://dashboard.internetcomputer.org/tokens/xafvr-biaaa-aaaai-aql5q-cai/transactions).
2. Locate your transaction by searching your Public Principal ID.
3. Review the transaction block:
   - **Transaction Hash / Index**
   - **Sender**: Faucet Canister Principal
   - **Recipient**: Your Public Principal
   - **Amount**: 10 TESTICP (1,000,000,000 e8s)
   - **Fee**: 10,000 e8s
   - **Timestamp & Block Height**

---

### Step 4: Interact with Qmoosa ICP
In the Qmoosa ICP Web4 application:
1. Open the **Connect Wallet** menu in the top bar.
2. Select **OISY** (or **Internet Identity**).
3. Test ICRC transfers, SNS DAO neuron staking, no-code token creation, and x402 Bazaar micropayments using your test funds and test identities.

---

## 🛡️ Security Protocol
- **Only share Public Principal IDs or transaction hashes.**
- **Never reveal or share seed phrases, recovery phrases, or private key materials.**
