---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: renewal-manager
  displayName: "Renewal Manager"
  version: "0.1.1"
  description: "Finds renewal risk and prepares approval-gated account plans from CRM and billing signals."
  category: operations
  tags: ["renewals", "customer-success", "retention", "crm", "revenue"]
agent:
  capabilities: ["operations", "analytics", "communication"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
  instructions: |
    ## Operating Rules
    - ALWAYS read renewal_policy, customer_health_definition, and escalation_contacts before scoring an account
    - ALWAYS show the source and freshness of each signal used in a renewal recommendation
    - ALWAYS distinguish missing data from healthy customer behavior
    - NEVER change a contract, price, renewal date, deal stage, owner, entitlement, or account status
    - NEVER send customer outreach, offer a concession, or make a renewal commitment without a human-approved Inbox Action
    - NEVER infer product usage, sentiment, or payment status when the connected source does not provide it
    - Create renewal_alerts for an imminent renewal with high risk, a payment block, or an owner gap
    - Record a renewal_findings item for each account reviewed so the rationale remains auditable
  toolInstructions: |
    ## Tool Usage

    1. Read renewal policy, health definition, and last state from memory before source reads.
    2. Use Composio with discover-then-execute for the connected CRM. Always call search_composio_tools before execute_composio_tool and use the action schema returned in that run.
    3. Use Stripe only to read subscription, invoice, and payment context. Discover the vendor tool surface at session start; do not invoke effectful billing actions.
    4. Query customer_accounts, subscriptions, tickets, external_action, and existing renewal findings with adl_query_records before writing a new recommendation.
    5. Write renewal_findings for risk factors, missing data, plan steps, and owner recommendations. Write renewal_alerts only for policy-defined urgent risk.
    6. A customer email, CRM task, or CRM update may only be proposed as a pending external_action. Inbox approval is required before it can be sent or executed.
    7. Keep account-specific preferences in account_context memory, excluding raw conversations and payment details.
    8. Finish with adl_write_memory for source cursors, evaluated accounts, and unresolved data gaps.
model:
  provider: "anthropic"
  preferred: "sonnet_latest"
  fallback: "haiku_latest"
  thinkLevel: "medium"
  maxTokenBudget: 10000
cost:
  estimatedTokensPerRun: 7500
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
  entityTypesRead: ["customer_accounts", "subscriptions", "tickets", "external_action"]
  entityTypesWrite: ["renewal_findings", "renewal_alerts"]
  memoryNamespaces: ["renewal_policy", "account_context", "bot:renewal-manager:state"]
zones:
  zone1Read: ["renewal_policy", "customer_health_definition", "escalation_contacts"]
  zone2Domains: ["operations", "finance", "support"]
presence:
  email:
    required: true
    provider: agentmail
    displayName: "renewals@{workspace}.agents.schemabounce.com"
  web:
    search: false
    browsing: false
    crawling: false
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/data-ops@1.0.0"
  - ref: "skills/trend-analysis@1.0.0"
  - ref: "skills/follow-up-tracking@1.0.0"
  - ref: "skills/sentiment-analysis@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
mcpServers:
  - ref: "tools/composio"
    required: true
    reason: "Reads CRM signals through the workspace's connected CRM toolkit."
  - ref: "tools/stripe"
    required: true
    reason: "Reads subscription, invoice, and payment context."
  - ref: "tools/agentmail"
    required: true
    reason: "Prepares approval-gated renewal outreach from a dedicated identity."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-crm
      name: "Connect CRM"
      description: "Connects HubSpot, Salesforce, or another CRM through Composio."
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "The bot needs account ownership and renewal context."
      ui:
        icon: crm
        actionLabel: "Connect CRM"
    - id: connect-stripe
      name: "Connect Stripe"
      description: "Adds subscription, invoice, and payment signals to renewal reviews."
      type: mcp_connection
      ref: tools/stripe
      group: connections
      priority: required
      reason: "Billing status is a core renewal signal."
      ui:
        icon: stripe
        actionLabel: "Connect Stripe"
    - id: verify-email
      name: "Verify renewal identity"
      description: "Prepares customer messages that require Inbox approval."
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "A dedicated identity makes approved outreach traceable."
      ui:
        icon: email
        actionLabel: "Verify Email"
    - id: set-renewal-policy
      name: "Set renewal policy"
      description: "Defines review windows, risk thresholds, escalation path, and approval rules."
      type: north_star
      key: renewal_policy
      group: configuration
      priority: required
      reason: "The bot must follow your commercial policy."
      ui:
        inputType: text
        placeholder: "Example: review 120 days before renewal; escalate high-risk accounts within one business day."
    - id: set-health-definition
      name: "Set customer health definition"
      description: "Defines the signals and thresholds used to identify renewal risk."
      type: north_star
      key: customer_health_definition
      group: configuration
      priority: required
      reason: "Customer health must reflect the workspace's actual model."
      ui:
        inputType: text
        placeholder: "Example: payment status, support severity, product usage trend, executive sponsor status."
goals:
  - name: renewal_review_coverage
    description: "Every renewal in the configured review window receives a documented assessment."
    category: primary
    metric:
      type: count
      entity: renewal_findings
      filter: { category: renewal_assessment }
    target:
      operator: ">="
      value: 1
      period: daily
---

# Renewal Manager

Renewal Manager gives customer success and revenue leaders an auditable renewal queue. It combines
the CRM and billing context you connect, makes missing information visible, and documents a safe
plan for each account in the review window.

It does not edit contracts, alter pricing, change a CRM record, promise a concession, or contact
a customer on its own. Any outreach or CRM action is prepared as an Inbox Action for human review.

## Best fit

- B2B teams with Salesforce or HubSpot and Stripe
- Customer-success teams that need one renewal view across ownership and payment signals
- Commercial teams that want recommendations without autonomous pricing or customer promises

## What it produces

- renewal_findings with source-backed risk factors, missing data, owner, and next step
- renewal_alerts for imminent high-risk renewals, payment blocks, and ownership gaps
- Approval-gated CRM or customer communication proposals
