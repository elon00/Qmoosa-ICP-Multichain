# Security & Post-Quantum Cryptography

## Core Principles

- **No Plaintext Private Keys**: All multi-chain transactions are signed using ICP threshold cryptography (Threshold ECDSA, Schnorr, Ed25519).
- **No Blind Signing**: Payloads are simulated and validated against spending limits before signature generation.
- **Human-in-the-Loop Approval Gate**: All asset-moving operations require explicit cryptographic approval.
- **Fail-Closed x402 Gateway**: Service requests requiring payment reject unverified proofs by default.

---

## Post-Quantum Cryptography (NIST FIPS 204)

- **ML-DSA (Dilithium)**: Used for software release attestation, package integrity verification, and administrative policy changes.
- **Cryptographic Scope**: PQC secures the application and orchestration plane; external blockchains use their native signature rules (ECDSA/Ed25519) until post-quantum support is natively adopted by those networks.
