---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: hr-onboarding
  displayName: "HR Onboarding"
  version: "1.0.0"
  description: "Employee onboarding checklist and tracking."
  category: hr
  tags: ["hr", "onboarding", "employees"]
agent:
  capabilities: ["hr_management", "onboarding"]
  hostingMode: "openclaw"
  defaultDomain: "hr"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: null
  manual: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant insight discovered" }
data:
  entityTypesRead: ["employees", "onboarding_templates"]
  entityTypesWrite: ["onboarding_checklists", "hr_tasks"]
  memoryNamespaces: ["onboarding_metrics", "completion_rates"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["hr"]
plugins:
  - ref: "n8n-workflow@latest"
    required: true
    reason: "Triggers onboarding workflows (account provisioning, equipment requests, training enrollment)"
  - ref: "gog@latest"
    required: false
    reason: "Google Calendar for scheduling orientation sessions, Drive for sharing onboarding documents"
    config:
      scopes: ["calendar.events", "drive.readonly"]
requirements:
  minTier: "starter"
---

# HR Onboarding

Manages new employee onboarding workflows. Creates personalized checklists and tracks completion across departments.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
