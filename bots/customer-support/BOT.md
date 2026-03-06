---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: customer-support
  displayName: "Customer Support"
  version: "1.0.0"
  description: "Ticket triage, workspace health monitoring, onboarding progress tracking."
  category: support
  tags: ["support", "tickets", "onboarding", "customer-health", "triage"]
agent:
  capabilities: ["customer_support", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "support"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 10000
  estimatedCostTier: "medium"
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
data:
  entityTypesRead: ["tickets", "contacts", "companies", "sre_findings"]
  entityTypesWrite: ["cs_findings", "cs_alerts", "tickets"]
  memoryNamespaces: ["working_notes", "learned_patterns", "customer_health"]
zones:
  zone1Read: ["mission", "industry", "stage"]
  zone2Domains: ["support"]
skills:
  - inline: "core-analysis"
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
requirements:
  minTier: "starter"
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
