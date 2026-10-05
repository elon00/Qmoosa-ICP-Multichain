# SNS Testflight & Production Launch Checklist

## Pre-Flight Verification Gate

Before committing cycles or initiating the irreversible NNS proposal on ICP mainnet, each checkpoint below must be verified:

- [x] **Technical Layer 1 (Integration Testing)**: Multi-canister actor workflows passing without mocks (`npm test`).
- [x] **Technical Layer 2 (Post-Quantum Verifier)**: Real NIST FIPS 204 ML-DSA-65 signatures generated and cryptographically verified (`node scripts/pqc-manifest-signer.js`).
- [x] **Technical Layer 3 (x402 Micropayments)**: ICRC ledger transaction verification and replay protection verified (`tests/x402.test.js`).
- [x] **Technical Layer 4 (SNS Governance Wiring)**: `sns/sns_init.yaml` configured with all 9 canisters, tokenomics, and neuron staking terms.
- [x] **Technical Layer 5 (Launchpad Factory)**: Synthetic IDs removed, stateful lifecycle implemented (`REQUESTED -> CREATING -> INSTALLING -> VERIFYING -> DEPLOYED -> FAILED`).
- [ ] **Technical Layer 6 (Mainnet Execution & Evidence)**:
  - Secure deployer identity created (`dfx identity new deployer`) and backed up privately by the user.
  - Cycles wallet funded with sufficient mainnet cycles (minimum ~20-30 TC for 9 canisters + SNS testflight).
  - Mainnet canisters deployed via `dfx deploy --network ic`.
  - Canister IDs recorded truthfully in `canister_ids.json` and verified on the Internet Computer Dashboard (`https://dashboard.internetcomputer.org/canister/<canister-id>`).
  - Evidence report saved to `deployments/mainnet-evidence.json`.
