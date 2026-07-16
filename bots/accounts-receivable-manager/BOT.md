---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: accounts-receivable-manager
  displayName: "Accounts Receivable Manager"
  version: "0.1.1"
  description: "Prioritizes overdue invoices and prepares approval-gated collection follow-ups."
  category: finance
  tags: ["accounts-receivable", "collections", "invoices", "cash-flow", "finance"]
agent:
  capabilities: ["finance", "analytics", "communication"]
  hostingMode: "openclaw"
  defaultDomain: "finance"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star collection_policy and escalation_contacts before reviewing any invoice
    - ALWAYS distinguish an overdue invoice from a disputed, promised, paid, or credit-hold invoice
    - ALWAYS record the evidence, age band, owner, and next recommended step in ar_findings
    - NEVER send a collection email, change an invoice, apply a credit, or record a payment without a human-approved Inbox Action
    - NEVER contact an account marked disputed, legal_hold, hardship, or do_not_contact
    - NEVER share customer names, invoice numbers, or amounts with bots outside the finance domain
    - Escalate a high-value, disputed, or repeatedly overdue invoice as an ar_alert instead of escalating collection pressure
    - Stop after three source-read failures and create one ar_alert with the connection and failure evidence
  toolInstructions: |
    ## Tool Usage

    1. Read bot:accounts-receivable-manager:state and collection_policy before source queries.
    2. Use Stripe only to read customers, invoices, payment status, and subscription context. Discover the vendor tool surface at session start. Do not invoke effectful Stripe actions.
    3. For QuickBooks or Xero through Composio, ALWAYS call search_composio_tools before execute_composio_tool. Use only the action and argument schema returned in that run.
    4. Query invoices, transactions, and external_action records with adl_query_records to deduplicate a planned follow-up before creating it.
    5. Write one ar_findings record per invoice state change or next-step recommendation. Write ar_alerts only for exceptions requiring a finance owner.
    6. A collection message can only be prepared as a pending external_action through AgentMail. Treat the pending action as the stopping point. Inbox approval is required before any send or reply.
    7. Use adl_add_memory for a concise aging pattern or contact preference. Do not retain raw email content or payment details in memory.
    8. Finish every run with adl_write_memory for the source cursor, evaluated invoice IDs, and open exception count.
model:
  provider: "anthropic"
  preferred: "sonnet_latest"
  fallback: "haiku_latest"
  thinkLevel: "medium"
  maxTokenBudget: 9000
cost:
  estimatedTokensPerRun: 6500
  estimatedCostTier: "medium"
schedule:
  default: "@daily"
  recommendations:
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 12h"
messaging:
  listensTo: []
  sendsTo: []
data:
  entityTypesRead: ["invoices", "transactions", "external_action"]
  entityTypesWrite: ["ar_findings", "ar_alerts"]
  memoryNamespaces: ["collection_policy", "account_preferences", "bot:accounts-receivable-manager:state"]
zones:
  zone1Read: ["collection_policy", "escalation_contacts", "industry"]
  zone2Domains: ["finance", "operations"]
presence:
  email:
    required: true
    provider: agentmail
    displayName: "ar@{workspace}.agents.schemabounce.com"
  web:
    search: false
    browsing: false
    crawling: false
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/data-ops@1.0.0"
  - ref: "skills/invoice-categorization@1.0.0"
  - ref: "skills/follow-up-tracking@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
mcpServers:
  - ref: "tools/stripe"
    required: true
    reason: "Reads live invoice, payment, and subscription context."
  - ref: "tools/composio"
    required: false
    reason: "Reads QuickBooks or Xero when the workspace uses an accounting ledger."
  - ref: "tools/agentmail"
    required: true
    reason: "Prepares approval-gated collection follow-ups from a dedicated identity."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-stripe
      name: "Connect Stripe"
      description: "Provides current invoice, payment, and subscription status."
      type: mcp_connection
      ref: tools/stripe
      group: connections
      priority: required
      reason: "The bot needs a billing source before it can assess receivables."
      ui:
        icon: stripe
        actionLabel: "Connect Stripe"
    - id: connect-ledger
      name: "Connect accounting ledger"
      description: "Adds QuickBooks or Xero context for invoice reconciliation."
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: recommended
      reason: "Ledger status prevents duplicate or already-resolved follow-ups."
      ui:
        icon: accounting
        actionLabel: "Connect Accounting Software"
    - id: verify-email
      name: "Verify collection identity"
      description: "Prepares collection messages that require Inbox approval."
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "A dedicated identity keeps approved follow-ups traceable."
      ui:
        icon: email
        actionLabel: "Verify Email"
    - id: set-collection-policy
      name: "Set collection policy"
      description: "Defines age bands, exclusions, tone, and approval requirements."
      type: north_star
      key: collection_policy
      group: configuration
      priority: required
      reason: "The bot must follow your collections policy instead of assuming one."
      ui:
        inputType: text
        placeholder: "Example: exclude disputed invoices; escalate after 60 days; all sends require approval."
    - id: set-escalation-contacts
      name: "Set escalation contacts"
      description: "Names the finance owners for high-risk collection exceptions."
      type: north_star
      key: escalation_contacts
      group: configuration
      priority: required
      reason: "High-risk receivables need a clear human owner."
      ui:
        inputType: text
        placeholder: "finance-ops@example.com, controller@example.com"
goals:
  - name: overdue_invoice_coverage
    description: "Every eligible overdue invoice receives a documented next step."
    category: primary
    metric:
      type: rate
      numerator: { entity: ar_findings, filter: { category: overdue_invoice } }
      denominator: { entity: invoices, filter: { status: open } }
    target:
      operator: ">="
      value: 0.9
      period: weekly
---

# Accounts Receivable Manager

Accounts Receivable Manager turns open invoices into a clear work queue. It checks invoice age,
payment status, dispute flags, and the workspace collection policy, then prepares the next safe
step for a finance owner.

Every external message is an Inbox Action. The bot does not send payment reminders, change an
invoice, issue credit, or record a payment by itself. Disputed, legal-hold, hardship, and
do-not-contact accounts are escalated rather than chased.

## Best fit

- Finance teams that use Stripe and optionally QuickBooks or Xero
- Companies with recurring invoices and a defined collection policy
- Controllers who need a daily exceptions queue instead of an undifferentiated aging report

## What it produces

- Prioritized ar_findings with invoice age, evidence, owner, and recommended step
- ar_alerts for disputed, high-value, or repeated collection exceptions
- Approval-gated draft follow-ups from its dedicated email identity
