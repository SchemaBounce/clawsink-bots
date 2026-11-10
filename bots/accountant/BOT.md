---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: accountant
  displayName: "Accountant"
  version: "1.0.17"
  description: "Invoice categorization, expense tracking, budget monitoring, billing anomaly detection."
  category: finance
  tags: ["finance", "invoices", "expenses", "budget", "billing"]
agent:
  capabilities: ["finance", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "finance"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star `budget_constraints` at run start. Every spending assessment must compare against these limits
    - ALWAYS categorize every new transaction and invoice. Nothing stays uncategorized after a run
    - ALWAYS check for duplicate invoices by matching vendor, amount, and date before processing
    - NEVER modify transaction amounts or invoice totals. Flag discrepancies as `acct_findings`, do not correct them
    - NEVER expose raw financial figures in messages to non-finance bots. Use percentage deviations and categories only
    - NEVER delete or archive financial records, only add status flags and findings
    - Escalation: payment failures and billing system errors trigger immediate alert to executive-assistant
    - Budget anomalies and overspend trends go to business-analyst as type=finding for cross-domain context
    - Store learned categorization rules in `learned_patterns` memory to improve accuracy over time
    - Store budget threshold overrides in `thresholds` memory. Update when North Star budget_constraints change
    - Budget checks: warn at 80% of a category limit and mark critical at 100%; always state the runway (days to the limit at the current burn rate), never a bare percentage. Reload thresholds from memory every run
    - Duplicate and anomaly checks: flag the same vendor, amount and date within 7 days for invoices and 48 hours for charges; flag a charge above 2x its category average or a new vendor with a large amount. Overdue invoices are severity high regardless of amount
  toolInstructions: |
    ## Tool Usage

    The accounting and payment systems are reached through whatever tools the workspace has connected (a billing tool, an accounting tool, an email tool). Learn each server's tools from its tool list and descriptions, or find one with `adl_tool_search`; read the description, then call it. Never assume a tool name or argument shape ahead of discovery.

    ### Daily / per-run order of operations

    1. `adl_read_memory` namespace `bot:accountant:state` key `last_run_state`. Get last run timestamp and the cursor for each external system (Stripe, QuickBooks, Xero).
    2. `adl_read_memory` namespace `thresholds`. Load budget thresholds, vendor allowlists, and overspend triggers.
    3. `adl_read_messages`. Pick up new `request` messages from executive-assistant or business-analyst, and any `finding` from inventory-manager.
    4. **Pull payments side:** with the connected billing tool, read new charges since the last run, outstanding invoices, and failed or stalled payments.
    5. **Pull accounting side:** with the connected accounting tool(s), read invoices and payments (and bank transactions or reconciliation items) since the last run.
    6. **Reconcile:** match Stripe charges against QuickBooks/Xero invoices by amount + date + customer reference. Flag mismatches as `acct_findings` with `reconciliation_gap` category. Never modify amounts on either side.
    7. **Categorize new transactions:** spawn the `transaction-categorizer` sub-agent with the unmatched/uncategorized batch.
    8. **Anomaly pass:** spawn `anomaly-scanner` for duplicate-invoice and unusual-amount detection.
    9. **Budget pass:** spawn `budget-auditor`. Read `learned_patterns` memory for vendor categorization rules.
    10. **Write findings:** `adl_upsert_record` entity_type=`acct_findings` for each anomaly, mismatch, or budget variance. `adl_upsert_record` entity_type=`acct_alerts` only for critical items (payment failure, billing system error, overspend >20%).
    11. **End-of-month close (when last_run is in a different calendar month):** assemble a one-page summary (Stripe revenue, QuickBooks/Xero booked revenue, reconciliation gap count, top 5 budget variances) and send it to the stakeholder email with the connected email tool, subject "Monthly close summary YYYY-MM", tagged `accountant` and `monthly-close`. Do NOT include raw amounts in messages to other bots; use percentages and categories.
    12. **Routing:**
       - Critical billing failure → `adl_send_message` type=`alert` to `executive-assistant`.
       - Budget anomaly or overspend → `adl_send_message` type=`finding` to `business-analyst`.
    13. `adl_write_memory` namespace `bot:accountant:state` key `last_run_state` with new timestamp and per-system cursors.

    ### Examples

    Pulling invoices issued today: read invoices created today, with amount and customer, from the connected accounting tool.

    Cross-checking a payment against the ledger: read the customer's recent charges from the connected billing tool, then look in the connected accounting tool for a bank transaction matching the amount and customer reference.

    Sending the monthly close summary: send the summary text to the finance contacts with the connected email tool, subject "Monthly close: YYYY-MM", tagged `accountant` and `monthly-close`.

    ### Hard rules

    - Never call a tool you did not first see in a server's tool list or an `adl_tool_search` result.
    - Never paste raw amounts, customer names, or invoice numbers into messages to non-finance bots. Use percentages, categories, and anonymized IDs.
    - Never modify Stripe charges, QuickBooks invoices, or Xero transactions. Read-only on source systems. All findings go into `acct_findings` / `acct_alerts`.
    - Budget for 6-12 tool calls on a normal day, more during month-end close. Do not pad with extra discovery calls if you already know the tool from a prior step in the same run.
model:
  provider: "anthropic"
  preferred: "haiku_latest"
  fallback: "haiku_latest"
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
egress:
  mode: "none"
skills:
  - ref: "skills/schemabounce"
  - ref: "registry:anthropics/knowledge-work-plugins/variance-analysis"
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
    category: secondary
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
    category: primary
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
- `budget_constraints`: Monthly/quarterly budget limits by category
