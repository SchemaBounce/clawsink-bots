---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: customer-onboarding
  displayName: "Customer Onboarding"
  version: "1.0.3"
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
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/cdc-event-analysis@1.0.0"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-mission
      name: "Define product mission"
      description: "Value proposition shapes welcome sequences and onboarding messaging"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Onboarding content must reflect the company's current value proposition and tone"
      ui:
        inputType: text
        placeholder: "e.g., Help teams ship data pipelines in minutes, not weeks"
        prefillFrom: "workspace.mission"
    - id: import-onboarding-templates
      name: "Configure onboarding templates"
      description: "Approved onboarding sequence templates for different customer segments"
      type: data_presence
      entityType: onboarding_templates
      minCount: 1
      group: data
      priority: required
      reason: "Every onboarding sequence is generated from an approved template — cannot start without one"
      ui:
        actionLabel: "Check Templates"
        emptyState: "No onboarding templates found. Create at least one template defining the onboarding steps for new customers."
    - id: connect-agentmail
      name: "Verify email identity"
      description: "Bot sends welcome emails, step instructions, and progress updates to customers"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Welcome emails and onboarding instructions are core to the onboarding flow"
      ui:
        icon: email
        actionLabel: "Verify Email"
    - id: connect-composio
      name: "Connect CRM platform"
      description: "Sync onboarding status with your CRM and customer success tools"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "CRM sync ensures onboarding progress is visible to sales and CS teams"
      ui:
        icon: integration
        actionLabel: "Connect CRM"
        helpUrl: "https://docs.schemabounce.com/integrations/crm"
    - id: connect-exa
      name: "Connect Exa for customer research"
      description: "Research customer companies to personalize onboarding content"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: optional
      reason: "Company and industry context enables tailored onboarding experiences"
      ui:
        icon: search
        actionLabel: "Connect Exa"
    - id: connect-agentphone
      name: "Connect phone for check-ins"
      description: "Make onboarding check-in calls and send SMS reminders for stalled customers"
      type: mcp_connection
      ref: tools/agentphone
      group: connections
      priority: optional
      reason: "Phone and SMS outreach helps recover stalled onboarding customers"
      ui:
        icon: phone
        actionLabel: "Connect Phone"
    - id: connect-elevenlabs
      name: "Connect ElevenLabs for voice"
      description: "Generate voice-based onboarding walkthroughs and tutorial narrations"
      type: mcp_connection
      ref: tools/elevenlabs
      group: connections
      priority: optional
      reason: "Voice walkthroughs can improve onboarding completion for complex products"
      ui:
        icon: voice
        actionLabel: "Connect ElevenLabs"
goals:
  - name: onboarding_completion
    description: "New customers complete full onboarding sequence"
    category: primary
    metric:
      type: rate
      numerator: { entity: onboarding_tasks, filter: { status: "completed" } }
      denominator: { entity: onboarding_tasks }
    target:
      operator: ">"
      value: 0.8
      period: monthly
      condition: "at least 80% of onboarding tasks completed"
  - name: welcome_timeliness
    description: "Welcome message sent within the same run as customer creation trigger"
    category: primary
    metric:
      type: rate
      numerator: { entity: welcome_messages, filter: { sent_same_run: true } }
      denominator: { entity: welcome_messages }
    target:
      operator: ">"
      value: 0.99
      period: weekly
  - name: stall_detection
    description: "Detect and escalate stalled customers within 48 hours"
    category: secondary
    metric:
      type: count
      entity: onboarding_tasks
      filter: { status: "stalled", escalated: true }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when stalled customers exist"
  - name: onboarding_quality
    description: "Onboarding experience rated positively by new customers"
    category: secondary
    metric:
      type: rate
      numerator: { entity: onboarding_tasks, filter: { feedback: "helpful" } }
      denominator: { entity: onboarding_tasks, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.8
      period: monthly
    feedback:
      enabled: true
      entityType: onboarding_tasks
      actions:
        - { value: helpful, label: "Helpful onboarding" }
        - { value: confusing, label: "Confusing steps" }
        - { value: too_slow, label: "Too slow" }
        - { value: missing_info, label: "Missing information" }
  - name: completion_rate_tracking
    description: "Track aggregate completion rates and stall point patterns"
    category: health
    metric:
      type: count
      source: memory
      namespace: completion_rates
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Customer Onboarding

Automates customer onboarding when new accounts are created. Generates personalized welcome sequences and tracks completion.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
