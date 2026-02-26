---
apiVersion: openclaw.schemabounce.com/v1
kind: SkillPack
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
  maxTokenBudget: 50000
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
