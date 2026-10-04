# Qmoosa x402 Bazaar Protocol Specification

## 1. Overview
The **x402 Bazaar Protocol** is an open machine-to-machine micropayment standard implementing HTTP status code `402 Payment Required`. It enables AI agents, automated pipelines, and decentralized applications to discover APIs and pay per call directly using `QMOOSA` tokens on the Internet Computer.

---

## 2. Protocol Flow

```
Agent / Client                        x402 Gateway Canister                  ICRC Token Ledger
      │                                         │                                    │
      │── 1. GET /api/v2/agent/reason ─────────>│                                    │
      │                                         │                                    │
      │<── 2. HTTP 402 Payment Required ────────│                                    │
      │       (Price, Recipient, Invoice ID)    │                                    │
      │                                         │                                    │
      │── 3. icrc1_transfer(amount, recipient) ─────────────────────────────────────>│
      │                                         │                                    │
      │<── 4. Transfer Receipt (tx_id) ──────────────────────────────────────────────│
      │                                         │                                    │
      │── 5. verify_payment(invoice_id, tx_id) ─>│                                    │
      │                                         │── 6. Verify ledger settlement ────>│
      │<── 7. HTTP 200 OK + JWT Access Token ───│                                    │
      │                                         │                                    │
      │── 8. Execute Protected Service ────────>│                                    │
```

---

## 3. Headers Specification

### Request Challenge (`402 Payment Required`)
```http
HTTP/1.1 402 Payment Required
Content-Type: application/json
x-payment-protocol: x402-v2
x-payment-amount: 0.005 QMOOSA
x-payment-recipient: rkp4c-7iaaa-aaaaa-aaaca-cai
x-invoice-id: x402-inv-98124-1029
x-expires-in: 600s
```

### Settlement Header (`Client -> Gateway`)
```http
Authorization: x402 invoice=x402-inv-98124-1029;tx=849102;asset=QMOOSA
```
