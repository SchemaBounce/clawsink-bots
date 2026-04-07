---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: customer-support
  displayName: "Customer Support"
  version: "1.0.6"
  description: "Ticket triage, workspace health monitoring, onboarding progress tracking."
  category: support
  tags: ["support", "tickets", "onboarding", "customer-health", "triage"]
agent:
  capabilities: ["customer_support", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "support"
  instructions: |
    ## Operating Rules
    - ALWAYS read `customer_health` memory before triaging — prior run context prevents re-triaging resolved issues and enables trend detection.
    - ALWAYS check for SLA breach proximity on every open/pending ticket — approaching SLA breaches take priority over new triage.
    - NEVER close or resolve a ticket without writing the resolution to cs_findings — every resolution is a learning opportunity for pattern detection.
    - NEVER escalate to executive-assistant for non-critical issues — only churn risk and data loss complaints qualify as critical alerts.
    - Send infrastructure-related complaints to sre-devops (request) immediately — do not attempt to diagnose infrastructure issues.
    - Send repeated complaint patterns and disengagement signals to churn-predictor (finding) for churn scoring.
    - Send onboarding struggles to customer-onboarding (finding) — new customers stuck on setup are onboarding failures, not support tickets.
    - Send recurring support themes indicating documentation gaps to knowledge-base-curator (finding) for KB article creation.
    - Send support trend data to business-analyst (finding) for cross-functional pattern analysis.
    - Use automation-first principle: if a ticket type can be triaged deterministically (known pattern + known response), create a trigger with `adl_create_trigger` rather than handling manually every run.
    - Correlate sre_findings with open tickets — if an infra issue explains multiple tickets, batch-update them rather than treating each independently.
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
  default: "@every 2h"
  recommendations:
    light: "@every 4h"
    standard: "@every 2h"
    intensive: "@every 1h"
messaging:
  listensTo:
    - { type: "finding", from: ["sre-devops"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical customer issue or churn risk" }
    - { type: "finding", to: ["business-analyst"], when: "support trend or pattern detected" }
    - { type: "request", to: ["sre-devops"], when: "customer reports infrastructure issue" }
    - { type: "finding", to: ["churn-predictor"], when: "repeated complaints or disengagement signal from account" }
    - { type: "finding", to: ["customer-onboarding"], when: "new customer struggling with setup or onboarding steps" }
    - { type: "finding", to: ["marketing-growth"], when: "recurring support theme suggesting messaging or documentation gap" }
    - { type: "finding", to: ["knowledge-base-curator"], when: "common support question lacking KB article coverage" }
data:
  entityTypesRead: ["tickets", "contacts", "companies", "sre_findings"]
  entityTypesWrite: ["cs_findings", "cs_alerts", "tickets"]
  memoryNamespaces: ["working_notes", "learned_patterns", "customer_health"]
zones:
  zone1Read: ["mission", "industry", "stage"]
  zone2Domains: ["support", "customer_success"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/notification-dispatch@1.0.0"
automations:
  triggers:
    - name: "Triage new ticket"
      entityType: "tickets"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "A new support ticket was submitted. Triage by severity, categorize the issue, and draft an initial response if the issue matches a known pattern."
    - name: "Check SLA on ticket update"
      entityType: "tickets"
      eventType: "updated"
      targetAgent: "self"
      condition: '{"status": {"$in": ["open", "pending"]}}'
      promptTemplate: "A ticket was updated. Check SLA compliance — if approaching breach, escalate. If resolved, update customer health score."
plugins:
  - ref: "voice-call@latest"
    slot: "channel"
    required: false
    reason: "Phone-based escalation for critical customer issues and churn-risk callbacks"
  - ref: "microsoft-teams@latest"
    slot: "channel"
    required: false
    reason: "Sends ticket escalation and SLA breach notifications to support Teams channels"
presence:
  email:
    required: true
    provider: agentmail
  web:
    search: true
    browsing: true
    crawling: false
  voice:
    required: false
    provider: elevenlabs
  phone:
    required: false
    provider: agentphone
mcpServers:
  - ref: "tools/slack"
    required: false
    reason: "Monitors support channels for customer issues and escalations"
  - ref: "tools/agentmail"
    required: true
    reason: "Send ticket updates, resolution confirmations, and follow-up emails to customers"
  - ref: "tools/exa"
    required: false
    reason: "Search knowledge bases and documentation for answers to customer questions"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse product documentation and help center pages to assist with customer issues"
  - ref: "tools/elevenlabs"
    required: false
    reason: "Generate voice responses for phone-based support escalations"
  - ref: "tools/agentphone"
    required: false
    reason: "Make outbound support calls for critical issues and churn-risk callbacks"
  - ref: "tools/composio"
    required: true
    reason: "Sync ticket data with helpdesk, CRM, and customer success platforms"
  - ref: "tools/zendesk"
    required: false
    reason: "Create, update, and search support tickets in Zendesk"
  - ref: "tools/freshdesk"
    required: false
    reason: "Manage helpdesk tickets, contacts, and canned responses"
  - ref: "tools/intercom"
    required: false
    reason: "Handle customer conversations and manage contact records"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-helpdesk
      name: "Connect helpdesk platform"
      description: "Links your helpdesk so the bot can read and triage tickets"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Primary data source for ticket triage and customer health monitoring"
      ui:
        icon: helpdesk
        actionLabel: "Connect Helpdesk"
        helpUrl: "https://docs.schemabounce.com/integrations/helpdesk"
    - id: set-sla-targets
      name: "Define SLA response times"
      description: "Set response time targets by ticket priority level"
      type: config
      group: configuration
      target: { namespace: customer_health, key: sla_targets }
      priority: required
      reason: "Cannot triage by urgency or detect SLA breaches without defined targets"
      ui:
        inputType: text
        placeholder: '{"critical": "1h", "high": "4h", "medium": "24h", "low": "72h"}'
        helpUrl: "https://docs.schemabounce.com/bots/customer-support/sla"
    - id: set-industry
      name: "Set business industry"
      description: "Determines support patterns and triage priorities"
      type: north_star
      key: industry
      group: configuration
      priority: required
      reason: "Industry context shapes triage priorities and escalation sensitivity"
      ui:
        inputType: select
        options:
          - { value: saas, label: "SaaS / Software" }
          - { value: ecommerce, label: "E-commerce / Retail" }
          - { value: fintech, label: "FinTech / Payments" }
          - { value: healthcare, label: "Healthcare" }
        prefillFrom: "workspace.industry"
    - id: connect-slack
      name: "Connect Slack"
      description: "Monitors support channels and posts escalation alerts"
      type: mcp_connection
      ref: tools/slack
      group: connections
      priority: recommended
      reason: "Real-time support channel monitoring and team notifications"
      ui:
        icon: slack
        actionLabel: "Connect Slack"
    - id: import-contacts
      name: "Import customer contacts"
      description: "Customer data enables health scoring and churn detection"
      type: data_presence
      entityType: contacts
      minCount: 1
      group: data
      priority: recommended
      reason: "Customer context improves triage accuracy and enables churn prediction"
      ui:
        actionLabel: "Import Contacts"
        emptyState: "No contacts found. Import from your CRM or helpdesk."
    - id: setup-email
      name: "Verify email identity"
      description: "Bot sends ticket updates and follow-ups via email"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Sends ticket updates, resolution confirmations, and follow-up emails"
      ui:
        icon: email
        actionLabel: "Verify Email"
goals:
  - name: resolve_tickets
    description: "Triage and resolve tickets without human intervention"
    category: primary
    metric:
      type: rate
      numerator: { entity: tickets, filter: { status: "resolved", resolved_by: "bot" } }
      denominator: { entity: tickets, filter: { status: "resolved" } }
    target:
      operator: ">"
      value: 0.5
      period: weekly
    feedback:
      enabled: true
      entityType: cs_findings
      actions:
        - { value: helpful, label: "Helpful resolution" }
        - { value: wrong, label: "Wrong resolution" }
        - { value: incomplete, label: "Incomplete" }
  - name: sla_compliance
    description: "Maintain SLA compliance across all ticket priorities"
    category: primary
    metric:
      type: rate
      numerator: { entity: tickets, filter: { sla_breached: false } }
      denominator: { entity: tickets }
    target:
      operator: ">"
      value: 0.95
      period: weekly
  - name: first_response_time
    description: "Time from ticket creation to first bot triage action"
    category: secondary
    metric:
      type: threshold
      measurement: avg_minutes_to_first_response
    target:
      operator: "<"
      value: 30
      period: daily
  - name: churn_signal_detection
    description: "Identify and escalate churn risk patterns from support data"
    category: secondary
    metric:
      type: count
      entity: cs_findings
      filter: { category: "churn_risk" }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when churn signals exist in ticket data"
  - name: pattern_learning
    description: "Build knowledge from resolved tickets to improve future triage"
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

# Customer Support

Monitors customer health by triaging tickets, tracking onboarding progress, and identifying churn risk patterns. Runs frequently to ensure fast response to customer issues.

## What It Does

- Triages incoming tickets by severity and category
- Tracks customer onboarding progress and identifies stuck users
- Monitors ticket volume trends and resolution times
- Detects churn risk signals (repeated issues, declining engagement)
- Correlates customer complaints with infrastructure issues from SRE

## Escalation Behavior

- **Critical**: Churn risk, data loss complaint → alerts executive-assistant
- **High**: Repeated customer issues, onboarding blockers → finding to business-analyst
- **Medium**: Ticket categorization, support trends → logged as cs_findings
- **Low**: Routine ticket updates → memory update only
