# OISY Wallet Integration

Qmoosa ICP uses OISY as the preferred multichain wallet entry point.

## Production integration choice

For React, use IdentityKit in **ACCOUNTS** mode with OISY enabled. OISY requires explicit user approval for wallet actions, so Qmoosa must never fabricate a connected state or wallet address.

Recommended packages:

```bash
npm install @nfid/identitykit @icp-sdk/auth @icp-sdk/core @icp-sdk/canisters
```

Alternative lower-level integration:

```bash
npm install @icp-sdk/signer
```

OISY production signer URL:

```text
https://oisy.com/sign
```

## Security rules

- Never request, store, log, or transmit seed phrases/private keys.
- Treat the wallet as disconnected until the signer returns an authenticated account/principal.
- Require explicit user confirmation for every value-moving transaction.
- Use ICRC wallet standards and ledger verification for balances/transfers.
- Do not infer payment success from a client-supplied transaction identifier.
- Use ICP Dashboard or ledger queries for independent transaction verification.

## Planned React wiring

```tsx
<IdentityKitProvider
  authType={IdentityKitAuthType.ACCOUNTS}
  signers={[OISY]}
  appName="Qmoosa ICP"
>
  <App />
</IdentityKitProvider>
```

The checked-in UI currently provides a safe OISY hand-off and remains disconnected until the full signer SDK dependency lockfile is updated and the account session is wired.
