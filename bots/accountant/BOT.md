---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: accountant
  displayName: "Accountant"
  version: "1.0.7"
  description: "Invoice categorization, expense tracking, budget monitoring, billing anomaly detection."
  category: finance
  tags: ["finance", "invoices", "expenses", "budget", "billing"]
agent:
  capabilities: ["finance", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "finance"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star `budget_constraints` at run start — every spending assessment must compare against these limits
    - ALWAYS categorize every new transaction and invoice — nothing stays uncategorized after a run
    - ALWAYS check for duplicate invoices by matching vendor, amount, and date before processing
    - NEVER modify transaction amounts or invoice totals — flag discrepancies as `acct_findings`, do not correct them
    - NEVER expose raw financial figures in messages to non-finance bots — use percentage deviations and categories only
    - NEVER delete or archive financial records — only add status flags and findings
    - Escalation: payment failures and billing system errors trigger immediate alert to executive-assistant
    - Budget anomalies and overspend trends go to business-analyst as type=finding for cross-domain context
    - Store learned categorization rules in `learned_patterns` memory to improve accuracy over time
    - Store budget threshold overrides in `thresholds` memory — update when North Star budget_constraints change
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
  default: "@daily"
  recommendations:
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 12h"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "business-analyst"] }
    - { type: "finding", from: ["inventory-manager"] }
  sendsTo:
    - { type: "finding", to: ["business-analyst", "executive-assistant"], when: "budget anomaly or overspend detected" }
    - { type: "alert", to: ["executive-assistant"], when: "critical billing issue or payment failure" }
data:
  entityTypesRead: ["transactions", "invoices", "inv_findings"]
  entityTypesWrite: ["acct_findings", "acct_alerts", "transactions", "invoices"]
  memoryNamespaces: ["working_notes", "learned_patterns", "thresholds"]
zones:
  zone1Read: ["mission", "budget_constraints", "industry"]
  zone2Domains: ["finance", "operations"]
presence:
  email:
    required: true
    provider: agentmail
  web:
    search: false
    browsing: false
    crawling: false
mcpServers:
  - ref: "tools/stripe"
    required: false
    reason: "Reconciles invoices, tracks payments, monitors billing disputes"
  - ref: "tools/agentmail"
    required: true
    reason: "Send invoice notifications, payment reminders, and budget alerts to stakeholders"
  - ref: "tools/composio"
    required: false
    reason: "Connect to accounting SaaS tools like QuickBooks, Xero, and expense management platforms"
  - ref: "tools/quickbooks"
    required: false
    reason: "Create invoices, record payments, track expenses, and generate financial reports"
  - ref: "tools/xero"
    required: false
    reason: "Manage invoices, contacts, bank transactions, and accounting reports"
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/data-ops@1.0.0"
  - ref: "skills/invoice-categorization@1.0.0"
  - ref: "skills/expense-tracking@1.0.0"
  - ref: "skills/budget-monitoring@1.0.0"
toolPacks:
  - ref: "packs/financial-toolkit@1.0.0"
    reason: "Calculate budget variance, financial ratios, and amortization for expense analysis"
  - ref: "packs/data-transform@1.0.0"
    reason: "Parse CSV bank statements and transform transaction data for categorization"
  - ref: "packs/document-gen@1.0.0"
    reason: "Generate invoice summaries, expense reports, and budget comparison documents"
automations:
  triggers:
    - name: "Categorize new transaction"
      entityType: "transactions"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "A new transaction was recorded. Categorize it, check against budget thresholds, and flag if it exceeds category limits."
    - name: "Match invoice to purchase order"
      entityType: "invoices"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "A new invoice arrived. Match it to existing purchase orders, verify amounts, and flag discrepancies or duplicates."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-budget-constraints
      name: "Define budget constraints"
      description: "Monthly or quarterly budget limits by spending category"
      type: north_star
      key: budget_constraints
      group: configuration
      priority: required
      reason: "Cannot monitor spending or detect overspend without budget limits"
      ui:
        inputType: text
        placeholder: '{"engineering": 50000, "marketing": 25000, "operations": 15000}'
        helpUrl: "https://docs.schemabounce.com/bots/accountant/budgets"
    - id: set-industry
      name: "Set business industry"
      description: "Industry context shapes expense categorization and compliance rules"
      type: north_star
      key: industry
      group: configuration
      priority: required
      reason: "Categorization rules and financial compliance vary by industry"
      ui:
        inputType: select
        options:
          - { value: saas, label: "SaaS / Software" }
          - { value: ecommerce, label: "E-commerce / Retail" }
          - { value: fintech, label: "FinTech / Payments" }
          - { value: healthcare, label: "Healthcare" }
          - { value: professional_services, label: "Professional Services" }
        prefillFrom: "workspace.industry"
    - id: connect-accounting
      name: "Connect accounting platform"
      description: "Links your accounting software for transaction and invoice data"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: recommended
      reason: "Automated sync with QuickBooks, Xero, or other accounting platforms"
      ui:
        icon: accounting
        actionLabel: "Connect Accounting Software"
        helpUrl: "https://docs.schemabounce.com/integrations/accounting"
    - id: connect-stripe
      name: "Connect Stripe for billing"
      description: "Reconciles invoices and tracks payment disputes"
      type: mcp_connection
      ref: tools/stripe
      group: connections
      priority: recommended
      reason: "Automated invoice reconciliation and billing dispute monitoring"
      ui:
        icon: stripe
        actionLabel: "Connect Stripe"
    - id: import-transactions
      name: "Import historical transactions"
      description: "Past transactions enable better categorization and anomaly baselines"
      type: data_presence
      entityType: transactions
      minCount: 10
      group: data
      priority: recommended
      reason: "Historical data improves categorization accuracy and anomaly detection"
      ui:
        actionLabel: "Import Transactions"
        emptyState: "No transactions found. Import from your accounting platform or CSV."
    - id: setup-email
      name: "Verify email identity"
      description: "Bot sends invoice notifications, payment reminders, and budget alerts"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Sends invoice notifications, payment reminders, and budget alerts to stakeholders"
      ui:
        icon: email
        actionLabel: "Verify Email"
goals:
  - name: categorize_transactions
    description: "Every transaction categorized within one run cycle"
    category: primary
    metric:
      type: rate
      numerator: { entity: transactions, filter: { category: { "$exists": true } } }
      denominator: { entity: transactions }
    target:
      operator: ">"
      value: 0.99
      period: daily
      condition: "no transaction remains uncategorized overnight"
  - name: detect_anomalies
    description: "Flag billing anomalies and duplicate invoices"
    category: primary
    metric:
      type: count
      entity: acct_findings
      filter: { category: ["billing_anomaly", "duplicate_invoice", "budget_overspend"] }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when anomalies exist in financial data"
  - name: categorization_accuracy
    description: "Transactions correctly categorized based on user feedback"
    category: secondary
    metric:
      type: rate
      numerator: { entity: acct_findings, filter: { feedback: "correct" } }
      denominator: { entity: acct_findings, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.9
      period: monthly
    feedback:
      enabled: true
      entityType: acct_findings
      actions:
        - { value: correct, label: "Correct categorization" }
        - { value: wrong_category, label: "Wrong category" }
        - { value: missed, label: "Missed anomaly" }
  - name: budget_monitoring
    description: "Track spending against budget limits and alert on overspend"
    category: secondary
    metric:
      type: boolean
      check: "budget_comparison_completed"
    target:
      operator: "=="
      value: 1
      period: per_run
  - name: categorization_learning
    description: "Build categorization rules from confirmed patterns"
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

# Accountant

Monitors financial health by tracking invoices, categorizing expenses, monitoring budgets, and detecting billing anomalies. Runs daily to keep financial data organized.

## What It Does

- Categorizes new invoices and transactions
- Tracks spending against budget constraints
- Detects billing anomalies (unexpected charges, duplicate invoices)
- Monitors payment patterns and cash flow indicators
- Flags overdue invoices and upcoming payment deadlines

## Escalation Behavior

- **Critical**: Payment failure, billing system error → alerts executive-assistant
- **High**: Budget overspend, large unexpected charge → finding to business-analyst
- **Medium**: Invoice categorization uncertainty → logged as acct_findings
- **Low**: Routine transaction processing → memory update only

## Recommended Setup

Set these North Star keys:
- `budget_constraints` — Monthly/quarterly budget limits by category
