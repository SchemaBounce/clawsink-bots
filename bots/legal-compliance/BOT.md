---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: legal-compliance
  displayName: "Legal & Compliance"
  version: "1.0.6"
  description: "Contract review queue, GDPR/SOC2 compliance tracking, regulatory change monitoring."
  category: legal
  tags: ["legal", "compliance", "gdpr", "soc2", "contracts", "regulatory"]
agent:
  capabilities: ["legal_compliance", "research"]
  hostingMode: "openclaw"
  defaultDomain: "compliance"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star `compliance_requirements` and `industry` at run start to scope which regulatory frameworks to monitor
    - ALWAYS check `compliance_calendar` memory for approaching deadlines before analyzing new items
    - ALWAYS flag contracts expiring within 30 days as high-priority findings
    - NEVER provide definitive legal advice — frame all findings as "requires human legal review" with supporting analysis
    - NEVER store full contract text in findings — reference by entity ID and summarize relevant clauses only
    - NEVER skip compliance frameworks listed in North Star `compliance_requirements` even if no new data exists — confirm continued compliance
    - Escalation: compliance violations and regulatory deadline breaches trigger immediate alert to executive-assistant
    - Send compliance risk findings to both business-analyst and executive-assistant for cross-domain awareness
    - Track regulatory change patterns in `learned_patterns` memory to anticipate future compliance requirements
    - Maintain `compliance_calendar` memory with all known deadlines (contract renewals, certification expirations, filing dates)
  toolInstructions: |
    ## Tool Usage — Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state` — get last run timestamp
    - Step 2: `adl_read_messages` — check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}` — ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 8000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@weekly"
    intensive: "@every 3d"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "compliance violation or regulatory deadline" }
    - { type: "finding", to: ["business-analyst", "executive-assistant"], when: "compliance risk or contract issue" }
data:
  entityTypesRead: ["contracts", "companies"]
  entityTypesWrite: ["legal_findings", "legal_alerts", "contracts"]
  memoryNamespaces: ["working_notes", "learned_patterns", "compliance_calendar"]
zones:
  zone1Read: ["mission", "industry", "compliance_requirements"]
  zone2Domains: ["compliance", "finance"]
presence:
  email:
    required: true
    provider: agentmail
egress:
  mode: "none"
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send compliance alerts, contract renewal reminders, and regulatory deadline notifications"
  - ref: "tools/composio"
    required: false
    reason: "Connect to contract management and compliance tracking SaaS platforms"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
toolPacks:
  - ref: "packs/legal-toolkit@1.0.0"
    reason: "Contract deadlines, GDPR data mapping, and retention policies"
  - ref: "packs/security-compliance@1.0.0"
    reason: "PII detection and data masking for privacy compliance"
  - ref: "packs/datetime-toolkit@1.0.0"
    reason: "Contract deadline calculations and business day tracking"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-compliance-requirements
      name: "Define compliance frameworks"
      description: "Which regulatory frameworks to actively monitor (GDPR, SOC2, PCI, HIPAA, etc.)"
      type: north_star
      key: compliance_requirements
      group: configuration
      priority: required
      reason: "Cannot scope compliance monitoring without knowing which frameworks apply"
      ui:
        inputType: text
        placeholder: '["GDPR", "SOC2", "PCI-DSS"]'
        helpUrl: "https://docs.schemabounce.com/bots/legal-compliance/frameworks"
    - id: set-industry
      name: "Set business industry"
      description: "Industry determines which regulatory changes are relevant"
      type: north_star
      key: industry
      group: configuration
      priority: required
      reason: "Regulatory monitoring must be scoped to industry-relevant legislation"
      ui:
        inputType: select
        options:
          - { value: saas, label: "SaaS / Software" }
          - { value: fintech, label: "FinTech / Payments" }
          - { value: healthcare, label: "Healthcare" }
          - { value: ecommerce, label: "E-commerce / Retail" }
          - { value: professional_services, label: "Professional Services" }
        prefillFrom: "workspace.industry"
    - id: connect-agentmail
      name: "Verify email identity"
      description: "Bot sends compliance alerts, contract reminders, and deadline notifications"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Compliance deadline alerts and contract renewal reminders require email"
      ui:
        icon: email
        actionLabel: "Verify Email"
    - id: import-contracts
      name: "Import contracts"
      description: "Existing contracts needed for review queue and expiry tracking"
      type: data_presence
      entityType: contracts
      minCount: 1
      group: data
      priority: required
      reason: "Cannot monitor contract deadlines or review queue without contract records"
      ui:
        actionLabel: "Import Contracts"
        emptyState: "No contracts found. Import from your contract management system."
    - id: connect-composio
      name: "Connect contract management platform"
      description: "Links your CLM or legal tech platform for automated contract sync"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: recommended
      reason: "Automated contract data import keeps the review queue current"
      ui:
        icon: composio
        actionLabel: "Connect CLM Platform"
    - id: set-compliance-calendar
      name: "Set initial compliance deadlines"
      description: "Known certification expirations, filing dates, and audit windows"
      type: manual
      instructions: "Enter your key compliance deadlines: certification renewal dates, regulatory filing deadlines, and upcoming audit windows. The bot will track these in its compliance calendar."
      group: configuration
      priority: recommended
      reason: "Pre-loading known deadlines prevents missed compliance dates"
      ui:
        actionLabel: "Enter Deadlines"
goals:
  - name: deadline_monitoring
    description: "No compliance deadlines missed — all tracked and alerted in advance"
    category: primary
    metric:
      type: count
      entity: legal_alerts
      filter: { type: "deadline_breach" }
    target:
      operator: "=="
      value: 0
      period: monthly
      condition: "zero missed compliance deadlines"
  - name: contract_review
    description: "Expiring contracts flagged at least 30 days before deadline"
    category: primary
    metric:
      type: rate
      numerator: { entity: legal_findings, filter: { type: "contract_expiry", advance_days: { "$gte": 30 } } }
      denominator: { entity: contracts, filter: { status: "expiring" } }
    target:
      operator: ">"
      value: 0.95
      period: monthly
      condition: "95% of expiring contracts flagged with 30+ days notice"
  - name: compliance_posture
    description: "All configured frameworks assessed each review cycle"
    category: secondary
    metric:
      type: boolean
      check: "all_frameworks_reviewed"
    target:
      operator: "=="
      value: 1
      period: weekly
  - name: regulatory_tracking
    description: "Regulatory change patterns tracked for anticipatory compliance"
    category: health
    metric:
      type: count
      source: memory
      namespace: learned_patterns
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Legal & Compliance

Monitors compliance posture, tracks contract review queues, and watches for regulatory changes. Uses Sonnet for nuanced analysis of compliance requirements.

## What It Does

- Tracks contract review queue and approaching deadlines
- Monitors compliance status against configured frameworks (GDPR, SOC2, PCI, etc.)
- Identifies regulatory changes relevant to the business industry
- Reviews data handling practices for compliance alignment
- Flags expiring contracts and renewal deadlines

## Escalation Behavior

- **Critical**: Compliance violation, regulatory deadline breach → alerts executive-assistant
- **High**: Contract expiry within 30 days, compliance gap → finding to executive-assistant
- **Medium**: Routine compliance observation → logged as legal_findings
- **Low**: Minor documentation updates → memory update only

## Recommended Setup

Set these North Star keys:
- `compliance_requirements` — Active compliance frameworks (GDPR, SOC2, PCI, etc.)
- `industry` — Used to filter relevant regulatory changes
