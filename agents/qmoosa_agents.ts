/**
 * Qmoosa ICP - AI Agent Definitions & Multi-Model Dispatcher
 *
 * Each agent encapsulates system prompts, authorized canister tools,
 * and safety policy bounds.
 */

export interface AgentTool {
  name: string;
  description: string;
  canister: string;
  method: string;
  requiresApproval: boolean;
}

export interface AgentProfile {
  id: string;
  name: string;
  role: string;
  description: string;
  systemPrompt: string;
  supportedModels: string[];
  tools: AgentTool[];
}

export const QMOOSA_AGENTS: Record<string, AgentProfile> = {
  blockchain: {
    id: 'blockchain-agent',
    name: 'Qmoosa Blockchain Architect',
    role: 'ICRC Ledger & Canister Specialist',
    description: 'Monitors canister balances, ICRC ledger transactions, allowances, and subnet health.',
    systemPrompt: `You are the Qmoosa ICP Blockchain Specialist. You operate directly with ICP canisters, ICRC-1/2/3 tokens, and Internet Identity. You never reveal or request private keys. You verify all canister IDs and provide Candid-compliant call structures.`,
    supportedModels: ['icp-onchain-llm', 'claude-3-5-sonnet', 'gpt-4o'],
    tools: [
      {
        name: 'checkBalance',
        description: 'Fetch ICRC-1 balance for an account',
        canister: 'token',
        method: 'icrc1_balance_of',
        requiresApproval: false
      },
      {
        name: 'transferTokens',
        description: 'Prepare and submit an ICRC-1 token transfer',
        canister: 'token',
        method: 'icrc1_transfer',
        requiresApproval: true
      },
      {
        name: 'queryLedgerHistory',
        description: 'Fetch recent transactions from the ledger',
        canister: 'token',
        method: 'get_transactions',
        requiresApproval: false
      }
    ]
  },

  tokenomics: {
    id: 'tokenomics-agent',
    name: 'Qmoosa Tokenomics & DAO Strategist',
    role: 'Economic Modeling & Governance Policy',
    description: 'Designs uncapped DAO supply policies, staking rewards, neuron dissolve curves, and launchpad allocations.',
    systemPrompt: `You are the Qmoosa Tokenomics Strategist. You ensure transparent, global-standard economic mechanics. You enforce that uncapped token issuance is always backed by SNS DAO proposals and timelocked community votes. No deceptive yield claims are allowed.`,
    supportedModels: ['claude-3-5-sonnet', 'gpt-4o', 'gemini-1-5-pro'],
    tools: [
      {
        name: 'submitDAOProposal',
        description: 'Draft and submit a formal DAO governance proposal',
        canister: 'dao_governance',
        method: 'submit_proposal',
        requiresApproval: true
      },
      {
        name: 'simulateDissolveYield',
        description: 'Compute voting power and staking multiplier for neuron duration',
        canister: 'dao_governance',
        method: 'stake_neuron',
        requiresApproval: false
      }
    ]
  },

  marketing: {
    id: 'marketing-agent',
    name: 'Qmoosa Global Standard Marketing Agent',
    role: 'Web3 & AI Growth Communications',
    description: 'Generates brand assets, technical documentation, whitepapers, launch announcements, and developer tutorials.',
    systemPrompt: `You are the Qmoosa Marketing & Communications Engine. You communicate deep-tech breakthroughs in ICP, Web 4.0, x402 micropayments, and PQC security with absolute technical clarity and zero hype or financial return guarantees.`,
    supportedModels: ['gpt-4o', 'claude-3-5-sonnet', 'gemini-1-5-pro'],
    tools: [
      {
        name: 'generateWhitepaperSection',
        description: 'Produce high-precision markdown documentation for Qmoosa protocols',
        canister: 'agent_orchestrator',
        method: 'dispatch_agent_action',
        requiresApproval: false
      },
      {
        name: 'draftLaunchAnnouncement',
        description: 'Create multi-channel release announcements with verified SHA-256 and canister IDs',
        canister: 'agent_orchestrator',
        method: 'dispatch_agent_action',
        requiresApproval: false
      }
    ]
  },

  security: {
    id: 'security-agent',
    name: 'Qmoosa Quantum & Protocol Sentinel',
    role: 'PQC Audit & Threat Modeling',
    description: 'Verifies FIPS 204 ML-DSA signatures, reviews canister upgrades, monitors cycle depletion, and checks wallet authorization.',
    systemPrompt: `You are the Qmoosa Security Sentinel. You audit smart canister code, verify PQC release manifests, test for cycles exhaustion, ensure rate limits, and enforce cryptographic zero-trust across all agentic tool operations.`,
    supportedModels: ['claude-3-5-sonnet', 'gpt-4o', 'icp-onchain-llm'],
    tools: [
      {
        name: 'verifyPqcSignature',
        description: 'Validate NIST FIPS 204 ML-DSA digital signature for release bytecode',
        canister: 'pqc',
        method: 'verify_signature',
        requiresApproval: false
      },
      {
        name: 'auditCanisterHealth',
        description: 'Inspect cycle reserves and memory consumption',
        canister: 'automation',
        method: 'trigger_now',
        requiresApproval: false
      }
    ]
  },

  deployment: {
    id: 'deployment-agent',
    name: 'Qmoosa Autonomous Deployment Agent',
    role: 'One-Click ICP Mainnet Orchestrator',
    description: 'Compiles canisters, runs PocketIC tests, performs Candid interface checks, and handles SNS launch readiness.',
    systemPrompt: `You are the Qmoosa Deployment Agent. You guide developers through dfx workflows, PocketIC verification, cycle wallet funding, and mainnet canary rollout.`,
    supportedModels: ['claude-3-5-sonnet', 'gpt-4o'],
    tools: [
      {
        name: 'runReadinessAudit',
        description: 'Check Candid interfaces, stable memory, and cycles',
        canister: 'agent_orchestrator',
        method: 'dispatch_agent_action',
        requiresApproval: false
      }
    ]
  }
};
