---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: fraud-detector
  displayName: "Fraud Detector"
  version: "1.0.7"
  description: "Scores new transactions for fraud risk using pattern analysis and anomaly detection."
  category: fintech
  tags: ["fraud", "transactions", "risk", "cdc"]
agent:
  capabilities: ["fraud_detection", "risk_analysis"]
  hostingMode: "openclaw"
  defaultDomain: "finance"
  instructions: |
    ## Operating Rules
    - ALWAYS score every incoming transaction. CDC-triggered runs must process the triggering transaction completely with no exceptions
    - ALWAYS check `fraud_patterns` memory for known fraud signatures before scoring, learned patterns improve detection accuracy
    - ALWAYS check North Star `risk_policy` at run start to apply the correct risk thresholds
    - NEVER block or modify transactions, only score and flag; the human operator decides on action
    - NEVER lower risk scores retroactively, if a transaction was flagged, the flag persists until human review
    - NEVER store raw transaction amounts or account numbers in memory. Store patterns and anonymized signals only
    - Escalation: high-confidence fraud (score above risk threshold) triggers immediate alert to executive-assistant
    - Suspicious patterns that are not yet conclusive go to compliance-auditor as type=finding for further investigation
    - Flagged fraudulent transactions go to accountant as type=finding for financial impact assessment
    - Update `fraud_patterns` memory when new fraud signatures are confirmed to improve future detection
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
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
trigger:
  entityType: "transactions"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["compliance-auditor"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "high-risk fraud detected" }
    - { type: "finding", to: ["compliance-auditor"], when: "suspicious pattern identified" }
    - { type: "finding", to: ["accountant"], when: "fraudulent transaction flagged for financial review" }
data:
  entityTypesRead: ["transactions", "fraud_rules"]
  entityTypesWrite: ["fraud_scores", "fraud_alerts"]
  memoryNamespaces: ["fraud_patterns", "risk_thresholds"]
zones:
  zone1Read: ["mission", "risk_policy"]
  zone2Domains: ["finance", "revenue"]
presence:
  email:
    required: true
    provider: agentmail
  web:
    search: true
egress:
  mode: "restricted"
  allowedDomains: []
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/data-ops@1.0.0"
  - ref: "skills/cdc-event-analysis@1.0.0"
toolPacks:
  - ref: "packs/financial-toolkit@1.0.0"
    reason: "Calculate financial ratios and detect billing anomalies"
  - ref: "packs/data-transform@1.0.0"
    reason: "Parse and merge transaction datasets for pattern detection"
  - ref: "packs/security-compliance@1.0.0"
    reason: "PII detection, data masking, and audit logging for compliance"
mcpServers:
  - ref: "tools/stripe"
    required: false
    reason: "Monitors charges for suspicious patterns and fraud signals"
  - ref: "tools/agentmail"
    required: true
    reason: "Send fraud alerts and risk reports to compliance and finance teams"
  - ref: "tools/exa"
    required: true
    reason: "Search for known fraud patterns, breach disclosures, and threat intelligence"
  - ref: "tools/composio"
    required: false
    reason: "Connect to payment platforms and financial SaaS tools for fraud signal enrichment"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-payment-processor
      name: "Connect payment processor"
      description: "Links your payment platform so the bot can analyze transactions"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Primary data source for transaction monitoring and fraud pattern analysis"
      ui:
        icon: stripe
        actionLabel: "Connect Payment Processor"
        helpUrl: "https://docs.schemabounce.com/integrations/payments"
    - id: set-risk-policy
      name: "Define risk policy"
      description: "Set your organization's fraud risk tolerance and escalation thresholds"
      type: north_star
      key: risk_policy
      group: configuration
      priority: required
      reason: "Cannot score transactions without defined risk thresholds"
      ui:
        inputType: select
        options:
          - { value: conservative, label: "Conservative (flag more, fewer misses)" }
          - { value: balanced, label: "Balanced (default)" }
          - { value: permissive, label: "Permissive (fewer flags, faster throughput)" }
        default: balanced
    - id: set-industry
      name: "Set business industry"
      description: "Fraud patterns differ significantly across industries"
      type: north_star
      key: industry
      group: configuration
      priority: required
      reason: "Industry-specific fraud detection models and pattern libraries"
      ui:
        inputType: select
        options:
          - { value: fintech, label: "FinTech / Payments" }
          - { value: ecommerce, label: "E-commerce / Retail" }
          - { value: saas, label: "SaaS / Software" }
          - { value: gaming, label: "Gaming / Entertainment" }
        prefillFrom: "workspace.industry"
    - id: fraud-score-threshold
      name: "Set fraud score threshold"
      description: "Transactions scoring above this are flagged for review"
      type: config
      group: configuration
      target: { namespace: risk_thresholds, key: fraud_score_cutoff }
      priority: required
      reason: "Cannot flag transactions without a detection threshold"
      ui:
        inputType: slider
        min: 0.5
        max: 0.99
        step: 0.01
        default: 0.8
    - id: connect-slack
      name: "Connect Slack for alerts"
      description: "Posts critical fraud alerts to your security or finance channel"
      type: mcp_connection
      ref: tools/slack
      group: connections
      priority: recommended
      reason: "Real-time team alerting for high-severity fraud detection"
      ui:
        icon: slack
        actionLabel: "Connect Slack"
    - id: import-transactions
      name: "Import historical transactions"
      description: "Baseline data improves initial detection accuracy and reduces false positives"
      type: data_presence
      entityType: transactions
      minCount: 100
      group: data
      priority: recommended
      reason: "Pattern baseline for anomaly detection. Without history, all transactions look novel"
      ui:
        actionLabel: "Import Transactions"
        emptyState: "No transaction history found. Import via CSV or connect your payment processor first."
        helpUrl: "https://docs.schemabounce.com/data/import"
goals:
  - name: flag_suspicious_transactions
    description: "Identify and flag potentially fraudulent transactions"
    category: primary
    metric:
      type: count
      entity: fraud_scores
      filter: { risk_level: ["high", "critical"] }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when new transactions exist"
  - name: detection_accuracy
    description: "Maximize confirmed fraud rate among flagged transactions"
    category: primary
    metric:
      type: rate
      numerator: { entity: fraud_scores, filter: { feedback: "confirmed" } }
      denominator: { entity: fraud_scores, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.85
      period: weekly
    feedback:
      enabled: true
      entityType: fraud_scores
      actions:
        - { value: confirmed, label: "Confirmed fraud" }
        - { value: false_positive, label: "Not fraud" }
        - { value: needs_review, label: "Needs review" }
  - name: pattern_learning
    description: "Continuously improve by learning new fraud signatures"
    category: health
    metric:
      type: count
      source: memory
      namespace: fraud_patterns
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: escalation_speed
    description: "Critical fraud flagged within minutes of transaction"
    category: secondary
    metric:
      type: threshold
      measurement: avg_minutes_to_flag
    target:
      operator: "<"
      value: 5
      period: per_run
---

# Fraud Detector

Scores incoming transactions for fraud risk in real-time. Analyzes transaction patterns, amounts, frequencies, and geographic anomalies to flag suspicious activity.

## What It Does

- Scores each new transaction against learned fraud patterns
- Detects velocity anomalies (unusual frequency or amounts)
- Flags geographic inconsistencies
- Maintains evolving fraud pattern database
- Escalates high-risk transactions immediately

## Escalation Behavior

- **Critical**: High confidence fraud → alert executive-assistant
- **High**: Suspicious pattern → finding to compliance-auditor
- **Medium**: Elevated risk score → logged as fraud_scores
- **Low**: Normal transaction → no action
