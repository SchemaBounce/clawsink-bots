---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: revenue-leakage-manager
  displayName: "Revenue Leakage Manager"
  version: "0.1.1"
  description: "Finds payment, billing, and entitlement gaps before they become recurring revenue loss."
  category: finance
  tags: ["revenue-leakage", "billing", "payments", "subscriptions", "finance"]
agent:
  capabilities: ["finance", "analytics", "operations"]
  hostingMode: "openclaw"
  defaultDomain: "finance"
  instructions: |
    ## Operating Rules
    - ALWAYS read revenue_leakage_policy and entitlement_source before classifying a billing anomaly
    - ALWAYS verify a suspected gap across at least two available sources or label it unverified
    - ALWAYS distinguish a payment collection issue from a billing, subscription, or entitlement mismatch
    - NEVER issue refunds, credits, write-offs, invoice changes, subscription changes, or cancellation actions
    - NEVER retry a payment, change payment methods, or alter a customer's access
    - NEVER treat a missing source connection as proof of a revenue leak
    - Write leakage_alerts for an active high-impact leak or a recurring failure pattern; write leakage_findings for investigation and reconciliation work
    - Preserve only references and aggregate amounts in cross-domain communication, never raw payment details
  toolInstructions: |
    ## Tool Usage

    1. Read revenue_leakage_policy, entitlement_source, and last state before collecting data.
    2. Use Stripe as the billing source of record for read-side invoices, subscriptions, payment attempts, refunds, and customer status. Discover the vendor tool surface at session start.
    3. If a ledger is connected through Composio, use search_composio_tools before execute_composio_tool and only execute the returned action schema.
    4. Use adl_query_records to correlate invoices, transactions, subscriptions, entitlement records, and existing leakage cases by stable source references.
    5. Write leakage_findings with evidence, verification state, estimated impact range, and recommended owner. Write leakage_alerts only when policy thresholds are met.
    6. Do not call effectful Stripe, accounting, CRM, or entitlement tools. A recommended correction must be a finding, not an external action.
    7. Use adl_add_memory for recurring pattern signatures and source mapping assumptions, never raw payment instruments or customer details.
    8. Update cursors, source coverage, and unresolved mismatches with adl_write_memory.
model:
  provider: "anthropic"
  preferred: "sonnet_latest"
  fallback: "haiku_latest"
  thinkLevel: "medium"
  maxTokenBudget: 9000
cost:
  estimatedTokensPerRun: 7000
  estimatedCostTier: "medium"
schedule:
  default: "@every 12h"
  recommendations:
    light: "@weekly"
    standard: "@every 12h"
    intensive: "@every 4h"
messaging:
  listensTo: []
  sendsTo: []
data:
  entityTypesRead: ["invoices", "transactions", "subscriptions", "entitlements"]
  entityTypesWrite: ["leakage_findings", "leakage_alerts"]
  memoryNamespaces: ["revenue_leakage_policy", "source_mapping", "bot:revenue-leakage-manager:state"]
zones:
  zone1Read: ["revenue_leakage_policy", "entitlement_source", "industry"]
  zone2Domains: ["finance", "operations"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/data-ops@1.0.0"
  - ref: "skills/data-validation@1.0.0"
  - ref: "skills/anomaly-detection@1.0.0"
  - ref: "skills/trend-analysis@1.0.0"
mcpServers:
  - ref: "tools/stripe"
    required: true
    reason: "Reads billing, payment, and subscription state from the connected Stripe account."
  - ref: "tools/composio"
    required: false
    reason: "Adds accounting ledger evidence when a workspace connects QuickBooks or Xero."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-stripe
      name: "Connect Stripe"
      description: "Provides billing, payment, refund, and subscription evidence."
      type: mcp_connection
      ref: tools/stripe
      group: connections
      priority: required
      reason: "The bot needs a live billing source to find leakage."
      ui:
        icon: stripe
        actionLabel: "Connect Stripe"
    - id: connect-ledger
      name: "Connect accounting ledger"
      description: "Adds ledger reconciliation through QuickBooks or Xero."
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: recommended
      reason: "A second source helps verify revenue mismatches."
      ui:
        icon: accounting
        actionLabel: "Connect Accounting Software"
    - id: set-leakage-policy
      name: "Set leakage policy"
      description: "Defines verification, materiality, alert, and escalation thresholds."
      type: north_star
      key: revenue_leakage_policy
      group: configuration
      priority: required
      reason: "The bot must not assume materiality or remediation policy."
      ui:
        inputType: text
        placeholder: "Example: alert on verified recurring gaps above $500 monthly; finance approves all corrections."
    - id: set-entitlement-source
      name: "Describe entitlement source"
      description: "Explains where active customer access or entitlements can be verified."
      type: north_star
      key: entitlement_source
      group: configuration
      priority: recommended
      reason: "Entitlement evidence separates access mismatches from payment issues."
      ui:
        inputType: text
        placeholder: "Example: ADL entity entitlements synced nightly from product database."
goals:
  - name: verified_leakage_coverage
    description: "Every suspected material gap is marked verified or unverified with source evidence."
    category: primary
    metric:
      type: count
      entity: leakage_findings
      filter: { category: verified_gap }
    target:
      operator: ">="
      value: 1
      period: weekly
---

# Revenue Leakage Manager

Revenue Leakage Manager is a finance investigation bot for gaps that lose money after a customer
should have been billed or paid. It looks for failed payment patterns, billing mismatches,
subscription inconsistencies, and entitlement gaps across the sources you connect.

This is distinct from Accounts Receivable Manager. Accounts Receivable Manager prioritizes issued
invoices and collection follow-ups. Revenue Leakage Manager investigates whether the billing or
access process itself is failing and creates a correction queue for finance and operations.

It never changes a payment, invoice, subscription, entitlement, refund, or credit. Each finding
shows whether it is verified across sources, the policy-defined impact, and the human owner for
correction.

## What it produces

- leakage_findings for verified and unverified billing or entitlement mismatches
- leakage_alerts for recurring or high-impact verified gaps
- A source-backed correction queue without autonomous financial changes
