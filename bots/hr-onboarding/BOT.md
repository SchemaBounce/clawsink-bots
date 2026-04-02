---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: hr-onboarding
  displayName: "HR Onboarding"
  version: "1.0.1"
  description: "Employee onboarding checklist and tracking."
  category: hr
  tags: ["hr", "onboarding", "employees"]
agent:
  capabilities: ["hr_management", "onboarding"]
  hostingMode: "openclaw"
  defaultDomain: "hr"
  instructions: |
    ## Operating Rules
    - ALWAYS read `onboarding_templates` before creating a new checklist — use the template matching the employee's role and department
    - ALWAYS track checklist completion status in `onboarding_metrics` memory to identify bottlenecks across onboarding processes
    - ALWAYS include clear due dates and responsible parties for every `hr_tasks` item created
    - NEVER store personal employee information (SSN, bank details, health records) in findings or memory — reference by employee ID only
    - NEVER skip checklist items even if they seem redundant — compliance requires complete audit trails
    - NEVER auto-complete checklist items — only the human operator or n8n workflow confirmation can mark tasks done
    - Escalation: onboarding delays exceeding SLA or blocked employees trigger finding to executive-assistant
    - Use n8n-workflow plugin for automated provisioning (accounts, equipment, training enrollment) — do not attempt manual coordination
    - Use gog plugin for scheduling orientation sessions on Google Calendar and sharing documents via Drive
    - Track completion rates in `completion_rates` memory to identify recurring onboarding bottlenecks
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
presence:
  email:
    required: true
    provider: agentmail
  web:
    search: true
    browsing: true
  voice:
    required: false
    provider: elevenlabs
egress:
  mode: "none"
skills:
  - ref: "skills/follow-up-tracking@1.0.0"
  - ref: "skills/task-management@1.0.0"
  - ref: "skills/notification-dispatch@1.0.0"
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send onboarding welcome emails, checklist reminders, and task notifications to new hires"
  - ref: "tools/exa"
    required: true
    reason: "Search for onboarding best practices and compliance requirements by role"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse HR platforms and benefits portals to verify onboarding resource links"
  - ref: "tools/composio"
    required: false
    reason: "Connect to HRIS, payroll, and benefits SaaS platforms for onboarding automation"
  - ref: "tools/elevenlabs"
    required: false
    reason: "Generate voice welcome messages and onboarding orientation audio guides"
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
