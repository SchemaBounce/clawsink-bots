---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: sales-pipeline
  displayName: "Sales Pipeline"
  version: "1.0.5"
  description: "Analyzes sales funnel and identifies bottlenecks."
  category: sales
  tags: ["sales", "funnel", "pipeline"]
agent:
  capabilities: ["sales_analysis", "forecasting"]
  hostingMode: "openclaw"
  defaultDomain: "sales"
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 key (mission) before analyzing pipeline data — align all forecasts and recommendations with the company's current stage and goals.
    - ALWAYS compare current pipeline metrics against conversion_rates and stage_durations memory baselines before flagging anomalies. Only escalate deviations exceeding 15% from baseline.
    - NEVER modify deal records in the source CRM. Your role is analysis and insight generation — write pipeline_reports and deal_insights entities, not deal modifications.
    - NEVER include customer PII (names, emails, company names) in pipeline_reports or findings sent to other bots. Use anonymized deal IDs and segment labels only.
    - When a deal closes successfully, immediately send a finding to customer-onboarding with the deal ID, product tier, and any special requirements noted during the sales process.
    - When a deal is lost with a feature-related reason, send a finding to market-intelligence with the feature gap description and deal stage at loss — this feeds the feature parity analysis.
    - Send pipeline stage velocity data and deal conversion metrics to revops for revenue forecasting and operations alignment.
    - Escalate to executive-assistant only for pipeline health alerts: forecast deviation >20%, pipeline coverage ratio dropping below 3x, or a critical deal stalled beyond 2x average stage duration.
    - Update conversion_rates memory each run with stage-to-stage conversion percentages and stage_durations memory with average days per stage.
    - When receiving onboarding feedback from customer-onboarding, log patterns in stage_durations memory to identify whether sales handoff quality affects onboarding success.
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
  default: "@daily"
  recommendations:
    light: "@every 2d"
    standard: "@daily"
    intensive: "@every 12h"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["revops", "customer-onboarding"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "pipeline health alert or forecast deviation" }
    - { type: "finding", to: ["customer-onboarding"], when: "deal closed — new customer ready for onboarding" }
    - { type: "finding", to: ["revops"], when: "pipeline stage data or deal velocity metrics" }
    - { type: "finding", to: ["market-intelligence"], when: "deal loss reason or feature gap from prospect feedback" }
data:
  entityTypesRead: ["deals", "pipeline_stages"]
  entityTypesWrite: ["pipeline_reports", "deal_insights"]
  memoryNamespaces: ["conversion_rates", "stage_durations"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["sales", "revenue"]
egress:
  mode: "restricted"
  allowedDomains: ["api.hubspot.com", "*.salesforce.com", "api.pipedrive.com"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: true
    reason: "OAuth access to CRM platforms (Salesforce, HubSpot, Pipedrive) for reading deal stages and pipeline data"
mcpServers:
  - ref: "tools/stripe"
    required: false
    reason: "Verifies deal payments and tracks payment-linked revenue"
  - ref: "tools/agentmail"
    required: true
    reason: "Send deal alerts and pipeline health summaries to sales stakeholders"
  - ref: "tools/exa"
    required: false
    reason: "Research prospect companies and competitive intelligence for deal qualification"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse prospect websites and LinkedIn profiles for deal enrichment"
  - ref: "tools/composio"
    required: true
    reason: "Connect to CRM platforms (Salesforce, HubSpot, Pipedrive) for deal data sync"
  - ref: "tools/salesforce"
    required: false
    reason: "Query accounts, contacts, opportunities, and cases in Salesforce CRM"
  - ref: "tools/hubspot"
    required: false
    reason: "Manage contacts, deals, companies, and pipeline stages in HubSpot"
  - ref: "tools/google-calendar"
    required: false
    reason: "Schedule demo calls and follow-up meetings with prospects"
  - ref: "tools/gmail"
    required: false
    reason: "Send personalized follow-up emails to prospects and buyers"
presence:
  email:
    required: true
    provider: agentmail
  web:
    browsing: true
    search: true
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-crm
      name: "Connect CRM platform"
      description: "Links your CRM so the bot can read deals, pipeline stages, and conversion data"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Primary data source — deal stage data and pipeline metrics come from the CRM"
      ui:
        icon: composio
        actionLabel: "Connect CRM"
        helpUrl: "https://docs.schemabounce.com/integrations/crm"
    - id: connect-email
      name: "Connect email for deal alerts"
      description: "Send pipeline health summaries and stalled deal alerts to sales leadership"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Sales stakeholders need real-time alerts on pipeline health and critical deal changes"
      ui:
        icon: email
        actionLabel: "Connect Email"
    - id: set-mission
      name: "Set company mission and stage"
      description: "Aligns pipeline analysis with your company's current goals and growth stage"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Pipeline recommendations differ for seed-stage vs growth-stage companies"
      ui:
        inputType: text
        placeholder: "e.g., Series B SaaS company targeting mid-market enterprise"
    - id: set-pipeline-coverage
      name: "Set pipeline coverage target"
      description: "Minimum pipeline-to-quota ratio before the bot triggers a health alert"
      type: config
      group: configuration
      target: { namespace: conversion_rates, key: coverage_target }
      priority: recommended
      reason: "Industry standard is 3x coverage — adjust based on your sales cycle and win rate"
      ui:
        inputType: slider
        min: 2.0
        max: 5.0
        step: 0.5
        default: 3.0
    - id: import-deals
      name: "Import historical deals"
      description: "Past deal data establishes conversion rate baselines and stage duration norms"
      type: data_presence
      entityType: deals
      minCount: 50
      group: data
      priority: recommended
      reason: "At least 50 closed deals needed for meaningful stage-to-stage conversion baselines"
      ui:
        actionLabel: "Import Deals"
        emptyState: "No deal history found. Connect your CRM first to pull historical data."
        helpUrl: "https://docs.schemabounce.com/data/import"
    - id: connect-stripe
      name: "Connect Stripe for payment verification"
      description: "Verify deal payments and track payment-linked revenue"
      type: mcp_connection
      ref: tools/stripe
      group: connections
      priority: recommended
      reason: "Payment verification closes the loop between pipeline and actual revenue"
      ui:
        icon: stripe
        actionLabel: "Connect Stripe"
goals:
  - name: pipeline_health_monitoring
    description: "Produce daily pipeline health reports with conversion and velocity metrics"
    category: primary
    metric:
      type: count
      entity: pipeline_reports
    target:
      operator: ">="
      value: 1
      period: daily
  - name: stalled_deal_detection
    description: "Identify deals stalled beyond 2x average stage duration"
    category: primary
    metric:
      type: count
      entity: deal_insights
      filter: { insight_type: "stalled_deal" }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when stalled deals exist"
  - name: conversion_baseline_accuracy
    description: "Stage-to-stage conversion rates tracked and updated each run"
    category: secondary
    metric:
      type: count
      source: memory
      namespace: conversion_rates
    target:
      operator: ">"
      value: 0
      period: daily
      condition: "updated each run"
  - name: handoff_quality
    description: "Closed-won deals trigger onboarding handoff within the same run"
    category: health
    metric:
      type: boolean
      check: onboarding_handoff_sent
    target:
      operator: "=="
      value: true
      period: per_run
      condition: "when deals close"
---

# Sales Pipeline

Analyzes the sales pipeline daily. Identifies stalled deals, conversion bottlenecks, and forecasts quarterly performance.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
