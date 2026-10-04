# Qmoosa ICP - Agent Guidance & Machine-Readable Knowledge

This repository implements the complete **Qmoosa ICP** architecture: an autonomous Web3 + AI operating platform on the Internet Computer Protocol (ICP).

## Installed Coding Agent Skills
The project leverages official ICP Skills for AI coding agents (`dfinity/icskills`) to ensure verified patterns, up-to-date canister interfaces, and zero deprecated APIs.

### Skill Sources:
- `dfinity/icskills`: Official DFINITY skills for Motoko, Rust, PocketIC, ICRC-1/2/3 tokens, SNS DAO governance, and Internet Identity integration.
- `x402-protocol`: Machine-to-machine HTTP 402 payment specifications.
- `pqc-ml-dsa`: FIPS 204 (ML-DSA) and FIPS 203 (ML-KEM) Post-Quantum Cryptographic verification guidelines.

## Canister Architecture Map

| Canister Name | Type | Purpose | Primary Methods |
|---|---|---|---|
| `token` | Motoko | Native QMOOSA token (ICRC-1/2/3) with uncapped DAO-mintable supply | `icrc1_transfer`, `icrc2_approve`, `dao_mint`, `icrc3_get_blocks` |
| `dao_governance` | Motoko | SNS-style Neuron Staking & Governance | `stake_neuron`, `submit_proposal`, `vote`, `execute_proposal` |
| `launchpad` | Motoko | No-code Token Launchpad & Vesting Factory | `create_token`, `get_all_tokens`, `get_manifest` |
| `x402_gateway` | Motoko | HTTP 402 Payment Required Machine Gateway | `request_invoice`, `verify_payment`, `get_services` |
| `agent_orchestrator` | Motoko | Multi-model AI router & Tool Execution Dispatcher | `dispatch_agent`, `register_tool`, `get_audit_log` |
| `conway_engine` | Motoko | Cellular Automaton AI & Agent Evolution Engine | `step_simulation`, `get_grid`, `mutate_population` |
| `automation` | Motoko | Native Canister Timers & Autonomous Schedulers | `schedule_job`, `cancel_job`, `get_job_status` |
| `pqc` | Motoko | Post-Quantum Signature & Manifest Anchor | `register_manifest`, `verify_ml_dsa_signature` |
| `frontend` | Assets | Responsive React + Vite Web4 Application | Hosted on-chain asset canister |

## Security Commandments
1. **Never allow LLMs or agents direct access to private keys.** All sensitive actions require explicit policy validation and wallet signing.
2. **Timer Resilience**: Timer state must be persisted in stable memory or re-initialized in `postupgrade` hooks.
3. **Uncapped Supply Governance**: Any minting above genesis requires a passed SNS DAO proposal and timelock.
4. **PQC Isolation**: PQC signatures protect application manifests and agent instructions. ICP consensus relies on ICP threshold signatures.
