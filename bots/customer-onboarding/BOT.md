---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: customer-onboarding
  displayName: "Customer Onboarding"
  version: "1.0.0"
  description: "Triggers and manages onboarding workflows for new customers."
  category: saas
  tags: ["onboarding", "customers", "workflow", "cdc"]
agent:
  capabilities: ["onboarding", "customer_success"]
  hostingMode: "openclaw"
  defaultDomain: "customer_success"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
  maxTokenBudget: 50000
trigger:
  entityType: "customers"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
data:
  entityTypesRead: ["customers", "onboarding_templates"]
  entityTypesWrite: ["onboarding_tasks", "welcome_messages"]
  memoryNamespaces: ["onboarding_progress", "completion_rates"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["customer_success"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Customer Onboarding

Automates customer onboarding when new accounts are created. Generates personalized welcome sequences and tracks completion.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
