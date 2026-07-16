---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: crm-hygiene-manager
  displayName: "CRM Hygiene Manager"
  version: "0.1.1"
  description: "Finds stale pipeline records and prepares approval-gated CRM cleanup recommendations."
  category: operations
  tags: ["crm", "sales-operations", "forecasting", "pipeline", "data-quality"]
agent:
  capabilities: ["operations", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
  instructions: |
    ## Operating Rules
    - ALWAYS read crm_hygiene_policy and pipeline_stage_definitions before evaluating a record
    - ALWAYS cite the source field, last activity, and policy rule behind a hygiene finding
    - ALWAYS distinguish an incomplete record from a record with a deliberately blank field
    - NEVER create, edit, merge, delete, reassign, close, or advance a CRM record without a human-approved Inbox Action
    - NEVER overwrite a field when source values conflict or the confidence is below the configured threshold
    - NEVER infer forecast amount, close date, contact consent, or deal stage from text alone
    - Write crm_hygiene_alerts for forecast-critical records or policy-defined ownership gaps; otherwise write crm_hygiene_findings
    - Use one recommendation per record and policy rule so a reviewer can approve or reject it independently
  toolInstructions: |
    ## Tool Usage

    1. Read crm_hygiene_policy, pipeline_stage_definitions, and bot:crm-hygiene-manager:state before a CRM scan.
    2. Use Composio with discover-then-execute for the connected CRM. ALWAYS call search_composio_tools before execute_composio_tool and use only the returned action schema.
    3. Perform read-side CRM queries for deals, companies, contacts, owners, activities, and tasks. Do not execute a mutation during the scan.
    4. Use adl_query_records to find existing crm_hygiene findings and pending external actions so the same recommendation is not created twice.
    5. Write crm_hygiene_findings with stable CRM references, violated policy rule, confidence, and proposed correction. Write crm_hygiene_alerts for forecast-critical or ownerless records.
    6. A CRM update, task creation, owner change, or contact action may only be represented as a pending external_action. Inbox approval is required before execution.
    7. Use adl_add_memory for approved field-mapping conventions and reviewer feedback. Do not retain raw contact notes.
    8. Update scan cursors, policy version, and outstanding recommendation counts with adl_write_memory.
model:
  provider: "anthropic"
  preferred: "haiku_latest"
  fallback: "haiku_latest"
  thinkLevel: "low"
  maxTokenBudget: 7000
cost:
  estimatedTokensPerRun: 4500
  estimatedCostTier: "low"
schedule:
  default: "@daily"
  recommendations:
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 6h"
messaging:
  listensTo: []
  sendsTo: []
data:
  entityTypesRead: ["deals", "companies", "contacts", "tasks", "external_action"]
  entityTypesWrite: ["crm_hygiene_findings", "crm_hygiene_alerts"]
  memoryNamespaces: ["crm_hygiene_policy", "field_mapping", "bot:crm-hygiene-manager:state"]
zones:
  zone1Read: ["crm_hygiene_policy", "pipeline_stage_definitions", "forecast_definition"]
  zone2Domains: ["operations", "finance"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/data-maintenance@1.0.0"
  - ref: "skills/data-validation@1.0.0"
  - ref: "skills/follow-up-tracking@1.0.0"
  - ref: "skills/trend-analysis@1.0.0"
mcpServers:
  - ref: "tools/composio"
    required: true
    reason: "Reads CRM records and prepares approved cleanup actions through the connected CRM toolkit."
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
      reason: "The bot needs CRM records, ownership, and activity data."
      ui:
        icon: crm
        actionLabel: "Connect CRM"
    - id: set-hygiene-policy
      name: "Set CRM hygiene policy"
      description: "Defines required fields, stale-record thresholds, correction confidence, and approvers."
      type: north_star
      key: crm_hygiene_policy
      group: configuration
      priority: required
      reason: "The bot must apply your CRM definitions and governance."
      ui:
        inputType: text
        placeholder: "Example: deals need owner, next step, close date; approval required for every CRM write."
    - id: set-stage-definitions
      name: "Set pipeline stage definitions"
      description: "Defines allowed stages, age limits, and the evidence required to advance a record."
      type: north_star
      key: pipeline_stage_definitions
      group: configuration
      priority: required
      reason: "The bot needs the workspace's own pipeline semantics."
      ui:
        inputType: text
        placeholder: "Example: discovery cannot exceed 30 days without next step; closed won requires signed date."
    - id: set-forecast-definition
      name: "Set forecast definition"
      description: "Defines the records and fields that affect the published forecast."
      type: north_star
      key: forecast_definition
      group: configuration
      priority: recommended
      reason: "Forecast-critical records should receive stronger escalation."
      ui:
        inputType: text
        placeholder: "Example: commit deals closing this quarter with amount and owner are forecast-critical."
goals:
  - name: actionable_hygiene_coverage
    description: "Every policy-violating record receives a deduplicated, reviewable recommendation."
    category: primary
    metric:
      type: count
      entity: crm_hygiene_findings
      filter: { category: policy_violation }
    target:
      operator: ">="
      value: 1
      period: daily
---

# CRM Hygiene Manager

CRM Hygiene Manager turns stale, incomplete, and inconsistent records into a small review queue.
It uses the policy and pipeline definitions you provide to flag missing owners, missing next steps,
stale stages, and fields that weaken forecast confidence.

The bot reads your CRM through Composio and never changes it autonomously. Each correction, task,
or ownership recommendation becomes a separate Inbox Action, so a reviewer can approve the
precise change or reject it without affecting other records.

## Best fit

- Sales operations teams using HubSpot, Salesforce, or another CRM
- Leaders whose forecast quality depends on disciplined deal ownership and next steps
- Teams that need cleanup work to be reviewable instead of hidden in bulk automation

## What it produces

- crm_hygiene_findings with source field, policy violation, confidence, and proposed correction
- crm_hygiene_alerts for forecast-critical or ownerless records
- Approval-gated CRM cleanup actions, never bulk autonomous edits
