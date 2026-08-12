---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: sales-pipeline
  displayName: "Sales Pipeline"
  version: "1.0.12"
  description: "Analyzes sales funnel and identifies bottlenecks."
  category: sales
  tags: ["sales", "funnel", "pipeline"]
agent:
  capabilities: ["sales_analysis", "forecasting"]
  hostingMode: "openclaw"
  defaultDomain: "sales"
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 key (mission) before analyzing pipeline data, align all forecasts and recommendations with the company's current stage and goals.
    - ALWAYS compare current pipeline metrics against conversion_rates and stage_durations memory baselines before flagging anomalies. Only escalate deviations exceeding 15% from baseline.
    - NEVER modify deal records in the source CRM. Your role is analysis and insight generation. Write pipeline_reports and deal_insights entities, not deal modifications.
    - NEVER scrape, infer, purchase, or guess contact details. Never send unsolicited outreach. Public demand signals become contactable only after a person voluntarily submits an approved first-party form.
    - NEVER include customer PII (names, emails, company names) in pipeline_reports or findings sent to other bots. Use anonymized deal IDs and segment labels only.
    - When a deal closes successfully, immediately send a finding to customer-onboarding with the deal ID, product tier, and any special requirements noted during the sales process.
    - When a deal is lost with a feature-related reason, send a finding to market-intelligence with the feature gap description and deal stage at loss. This feeds the feature parity analysis.
    - Send pipeline stage velocity data and deal conversion metrics to revops for revenue forecasting and operations alignment.
    - Escalate to executive-assistant only for pipeline health alerts: forecast deviation >20%, pipeline coverage ratio dropping below 3x, or a critical deal stalled beyond 2x average stage duration.
    - Update conversion_rates memory each run with stage-to-stage conversion percentages and stage_durations memory with average days per stage.
    - When receiving onboarding feedback from customer-onboarding, log patterns in stage_durations memory to identify whether sales handoff quality affects onboarding success.
  toolInstructions: |
    ## Tool Usage

    Use only tools exposed in the current run. The required CRM connection is the dedicated HubSpot marketplace server. Its provider may route authentication through Composio, but the runtime exposes the granted HubSpot actions directly. Use only visible read actions for deals, companies, activities, pipelines, and stages. Never assume a generic `composio` connection.

    ### Daily / per-run order of operations

    1. `adl_read_memory` namespace `bot:sales-pipeline:state` key `last_run_state`. Get last run timestamp and per-CRM cursors.
    2. `adl_read_memory` namespace `conversion_rates` and `stage_durations`. Load baselines for anomaly comparison and the `coverage_target` value.
    3. `adl_read_messages`. Pick up `request` from executive-assistant and `finding` from revops or customer-onboarding.
    4. **Pull HubSpot data:** use the granted read-only HubSpot list or search actions for deals updated since the last cursor. Read individual deals, companies, activities, pipelines, and stages only when needed for the report. Keep contact properties out of ADL outputs.
    5. **Verify revenue when available:** if a separate Stripe grant is present, use read-only invoice, charge, or subscription actions for closed-won reconciliation. Skip this step when Stripe is not granted.
    6. **Score and analyze:** spawn `deal-scorer` on active deals, then `bottleneck-detector` on stage transitions, then `at-risk-alerter` on the scored set.
    7. **Follow-up recommendations:** for known first-party CRM records, write a bounded recommendation to `deal_insights`. Do not send email or create calendar events. A separate approved workflow may act under the workspace's ownership and approval policy.
    8. **Write outputs:** `adl_upsert_record` entity_type=`pipeline_reports` (one per run, summary metrics), `adl_upsert_record` entity_type=`deal_insights` (one per stalled deal, at-risk deal, or notable transition). Anonymize: deal IDs and segment labels only, no customer PII.
    9. **Routing:**
       - Closed-won → `adl_send_message` type=`finding` to `customer-onboarding` with deal ID, product tier, special requirements.
       - Lost with feature reason → `adl_send_message` type=`finding` to `market-intelligence` with the gap and stage at loss.
       - Stage velocity / conversion metrics → `adl_send_message` type=`finding` to `revops`.
       - Pipeline health alert (forecast deviation >20%, coverage <3x, critical deal stalled) → `adl_send_message` type=`finding` to `executive-assistant`.
    10. `adl_write_memory` namespace `conversion_rates` (stage-to-stage rates), `stage_durations` (avg days per stage), `bot:sales-pipeline:state` key `last_run_state` with new timestamp.

    ### Hard rules

    - Never write to the source CRM. No create, update, archive, or delete actions on HubSpot deal, company, or contact records. The bot's job is analysis; updates belong to a separately approved workflow.
    - Never include customer PII (names, emails, company names) in `pipeline_reports` or messages to non-sales bots. Anonymized deal IDs and segment labels only.
    - Never send unsolicited email or direct messages, and never turn a public profile into a CRM contact.
    - Budget for 6-12 tool calls on a normal day. End-of-quarter forecasting runs may go higher; do not pad with unnecessary reads.
model:
  provider: "anthropic"
  preferred: "haiku_latest"
  fallback: "haiku_latest"
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
    - { type: "finding", to: ["customer-onboarding"], when: "deal closed, new customer ready for onboarding" }
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
  allowedDomains: ["api.hubspot.com"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: true
    reason: "Managed OAuth access to HubSpot for reading deal stages and pipeline data"
presence:
  email:
    required: false
    provider: agentmail
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-crm
      name: "Connect HubSpot"
      description: "Links HubSpot so the bot can read deals, pipeline stages, and conversion data"
      type: mcp_connection
      ref: tools/hubspot
      group: connections
      priority: required
      reason: "Primary data source, deal stage data and pipeline metrics come from the CRM"
      ui:
        icon: hubspot
        actionLabel: "Connect HubSpot"
        helpUrl: "https://docs.schemabounce.com/integrations/crm"
    - id: connect-email
      name: "Connect email for deal alerts"
      description: "Send pipeline health summaries and stalled deal alerts to sales leadership"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: recommended
      reason: "Optional notifications can alert sales stakeholders without blocking pipeline analysis"
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
      reason: "Industry standard is 3x coverage, adjust based on your sales cycle and win rate"
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
      filter: { insight_type: "stalled" }
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
