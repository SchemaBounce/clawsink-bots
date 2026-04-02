---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: customer-onboarding
  displayName: "Customer Onboarding"
  version: "1.0.1"
  description: "Triggers and manages onboarding workflows for new customers."
  category: saas
  tags: ["onboarding", "customers", "workflow", "cdc"]
agent:
  capabilities: ["onboarding", "customer_success"]
  hostingMode: "openclaw"
  defaultDomain: "customer_success"
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 key (mission) before generating onboarding content — welcome sequences and task assignments must reflect the company's current value proposition and tone.
    - ALWAYS check onboarding_progress memory for the customer's current onboarding state before creating new tasks. Never duplicate tasks for a customer already in-progress.
    - NEVER access or store customer payment details, passwords, or authentication tokens. Your scope is onboarding workflow management — sensitive data stays in the CRM and secrets manager.
    - NEVER skip the onboarding_templates entity lookup. Every onboarding sequence must be generated from an approved template, customized with customer-specific context from the trigger event.
    - When triggered by a new customer entity (CDC event), immediately create the full onboarding_tasks sequence and the initial welcome_messages entity within the same run.
    - When a customer stalls (no progress for 48+ hours on a task), send a finding to customer-support requesting human intervention with the stalled task details.
    - When onboarding completes successfully, send a finding to churn-predictor with the completion timeline and engagement scores to establish the customer's churn baseline.
    - Send onboarding process improvement feedback to sales-pipeline when patterns emerge (e.g., customers from a specific deal type consistently stall at the same onboarding step).
    - Escalate to executive-assistant only for critical failures: onboarding system errors, blocked customers with no workaround, or customers explicitly requesting cancellation during onboarding.
    - Update completion_rates memory at the end of each run with aggregate metrics: completion rate, average time to complete, most common stall points.
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
trigger:
  entityType: "customers"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["sales-pipeline"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical onboarding failure or blocked customer" }
    - { type: "finding", to: ["customer-support"], when: "onboarding issue requiring support intervention" }
    - { type: "finding", to: ["churn-predictor"], when: "onboarding completion or stall signal for churn baseline" }
    - { type: "finding", to: ["sales-pipeline"], when: "onboarding feedback relevant to sales process improvement" }
data:
  entityTypesRead: ["customers", "onboarding_templates"]
  entityTypesWrite: ["onboarding_tasks", "welcome_messages"]
  memoryNamespaces: ["onboarding_progress", "completion_rates"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["customer_success", "sales"]
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
  - ref: "tools/agentmail"
    required: true
    reason: "Send welcome emails, onboarding step instructions, and progress updates to new customers"
  - ref: "tools/exa"
    required: false
    reason: "Search for customer company information and industry context to personalize onboarding"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse customer websites to understand their business for tailored onboarding"
  - ref: "tools/elevenlabs"
    required: false
    reason: "Generate voice-based onboarding walkthroughs and tutorial narrations"
  - ref: "tools/agentphone"
    required: false
    reason: "Make onboarding check-in calls and send SMS reminders for stalled customers"
  - ref: "tools/composio"
    required: true
    reason: "Sync onboarding status with CRM and customer success platforms"
egress:
  mode: "none"
skills:
  - ref: "skills/cdc-event-analysis@1.0.0"
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
