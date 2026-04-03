---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: revops
  displayName: "Revenue Operations"
  version: "1.0.2"
  description: "CAC/LTV analysis, pipeline-to-revenue attribution, conversion funnel optimization, and revenue forecasting."
  category: finance
  tags: ["revenue-operations", "attribution", "cac-ltv", "forecasting", "conversion"]
agent:
  capabilities: ["analytics", "finance"]
  hostingMode: "openclaw"
  defaultDomain: "finance"
  instructions: |
    ## Operating Rules
    - ALWAYS read `revenue_baselines` and `attribution_models` memory before analysis — every run must compare against established baselines, not compute from zero.
    - ALWAYS check North Star keys (revenue_targets, growth_targets) before producing forecasts — forecasts without targets are meaningless.
    - NEVER publish a revenue forecast without stating the confidence interval and the key assumptions (pipeline coverage ratio, win rate, churn rate used).
    - NEVER send raw data dumps to executive-assistant — synthesize into a briefing with headline metric, trend direction, and recommended action.
    - Escalate to executive-assistant (finding) when LTV:CAC drops below 3:1 or blended CAC exceeds target by >25% — these are critical unit economics signals.
    - Send pipeline health insights to sales-pipeline (finding) when conversion bottlenecks are detected at specific funnel stages.
    - Send channel attribution insights to marketing-growth (finding) when ROI shifts significantly between channels.
    - Cross-reference churn_scores from churn-predictor with revenue data to adjust net revenue retention in forecasts.
    - When ingesting findings from sales-pipeline, marketing-growth, or business-analyst, tag the source in revops_findings metadata for attribution traceability.
    - Spawn sub-agents (attribution-modeler, forecast-builder) for heavy computation — keep the main loop for coordination and synthesis.
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
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 12h"
messaging:
  listensTo:
    - { type: "finding", from: ["sales-pipeline", "marketing-growth", "churn-predictor", "business-analyst"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "revenue briefing, forecast update, or CAC/LTV shift" }
    - { type: "finding", to: ["sales-pipeline"], when: "pipeline health insight or conversion bottleneck" }
    - { type: "finding", to: ["marketing-growth"], when: "channel attribution insight or campaign ROI analysis" }
data:
  entityTypesRead: ["pipeline_reports", "deal_insights", "mktg_findings", "campaigns", "churn_scores", "revenue_data", "ba_findings"]
  entityTypesWrite: ["revops_findings", "revops_alerts", "revops_forecasts", "revops_metrics"]
  memoryNamespaces: ["working_notes", "learned_patterns", "revenue_baselines", "attribution_models"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities", "growth_targets", "revenue_targets"]
  zone2Domains: ["finance", "sales", "marketing"]
skills:
  - ref: "skills/trend-analysis@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: false
    reason: "OAuth access to Stripe and payment processors for revenue data reconciliation"
    config:
      apps: ["stripe"]
      scopes: ["charges:read", "subscriptions:read"]
mcpServers:
  - ref: "tools/stripe"
    required: false
    reason: "Revenue operations analysis including CAC/LTV from payment data"
  - ref: "tools/agentmail"
    required: false
    reason: "Email revenue forecasts, pipeline reports, and CAC/LTV analysis to leadership"
  - ref: "tools/exa"
    required: false
    reason: "Research industry benchmarks and market data for revenue forecasting"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse competitor pricing pages and industry report sites for market intelligence"
  - ref: "tools/composio"
    required: false
    reason: "Connect to CRM and analytics platforms for revenue attribution data"
presence:
  email:
    required: false
    provider: agentmail
  web:
    browsing: true
    search: true
egress:
  mode: "restricted"
  allowedDomains: ["api.stripe.com"]
requirements:
  minTier: "team"
setup:
  steps:
    - id: connect-payment-platform
      name: "Connect payment platform"
      description: "Links your payment processor for revenue reconciliation and subscription data"
      type: mcp_connection
      ref: tools/stripe
      group: connections
      priority: required
      reason: "Revenue operations requires payment data for CAC/LTV calculations and revenue attribution"
      ui:
        icon: stripe
        actionLabel: "Connect Stripe"
        helpUrl: "https://docs.schemabounce.com/integrations/stripe"
    - id: connect-crm
      name: "Connect CRM platform"
      description: "Links your CRM for pipeline data, deal attribution, and conversion tracking"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Pipeline-to-revenue attribution requires CRM deal data — cannot compute CAC or funnel metrics without it"
      ui:
        icon: composio
        actionLabel: "Connect CRM"
    - id: set-revenue-targets
      name: "Set revenue targets"
      description: "ARR, MRR, or revenue growth targets that anchor all forecasts and alerts"
      type: north_star
      key: revenue_targets
      group: configuration
      priority: required
      reason: "Forecasts without targets are meaningless — this is the benchmark for all analysis"
      ui:
        inputType: text
        placeholder: "e.g., $5M ARR, 15% QoQ growth"
    - id: set-growth-targets
      name: "Set growth targets"
      description: "Customer acquisition and expansion targets for CAC/LTV analysis"
      type: north_star
      key: growth_targets
      group: configuration
      priority: required
      reason: "CAC thresholds and LTV:CAC ratio targets depend on growth goals"
      ui:
        inputType: text
        placeholder: "e.g., 500 new customers/quarter, 120% NRR"
    - id: set-attribution-model
      name: "Choose attribution model"
      description: "How pipeline deals are attributed to originating marketing channels"
      type: config
      group: configuration
      target: { namespace: attribution_models, key: attribution_method }
      priority: recommended
      reason: "Attribution method affects all channel ROI calculations"
      ui:
        inputType: select
        options:
          - { value: first_touch, label: "First-touch attribution" }
          - { value: last_touch, label: "Last-touch attribution" }
          - { value: multi_touch, label: "Multi-touch (linear)" }
          - { value: w_shaped, label: "W-shaped (weighted)" }
        default: multi_touch
    - id: import-pipeline-data
      name: "Import pipeline history"
      description: "Historical deal data enables accurate conversion rate baselines and CAC calculations"
      type: data_presence
      entityType: pipeline_reports
      minCount: 50
      group: data
      priority: recommended
      reason: "At least 50 historical deals needed for meaningful conversion and velocity baselines"
      ui:
        actionLabel: "Import Pipeline Data"
        emptyState: "No pipeline history found. Connect your CRM first to pull historical deals."
        helpUrl: "https://docs.schemabounce.com/data/import"
    - id: connect-email
      name: "Connect email for reports"
      description: "Email revenue forecasts and CAC/LTV reports to leadership"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: recommended
      reason: "Automated delivery of revenue briefings to executive stakeholders"
      ui:
        icon: email
        actionLabel: "Connect Email"
goals:
  - name: revenue_forecast_accuracy
    description: "Revenue forecasts within 15% of actual results"
    category: primary
    metric:
      type: rate
      numerator: { entity: revops_forecasts, filter: { accuracy: "within_threshold" } }
      denominator: { entity: revops_forecasts }
    target:
      operator: ">"
      value: 0.85
      period: monthly
  - name: ltv_cac_monitoring
    description: "Track and alert when LTV:CAC ratio drops below healthy threshold"
    category: primary
    metric:
      type: threshold
      measurement: ltv_cac_ratio
    target:
      operator: ">="
      value: 3.0
      period: weekly
  - name: attribution_coverage
    description: "Percentage of closed deals with channel attribution assigned"
    category: secondary
    metric:
      type: rate
      numerator: { entity: revops_findings, filter: { has_attribution: true } }
      denominator: { entity: revops_findings, filter: { finding_type: "deal_closed" } }
    target:
      operator: ">"
      value: 0.90
      period: monthly
  - name: cross_functional_data_flow
    description: "Consistently receiving and processing inputs from sales, marketing, and CS"
    category: health
    metric:
      type: count
      source: memory
      namespace: attribution_models
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "updated from cross-functional inputs"
---

# Revenue Operations

Bridges cross-functional data from sales, marketing, and customer success to optimize the full revenue lifecycle. Calculates CAC/LTV metrics, attributes pipeline deals to originating channels, and produces revenue forecasts grounded in real pipeline health.

## What It Does

- Calculates blended and per-channel CAC using marketing spend and deal attribution
- Tracks LTV and LTV:CAC ratio across customer cohorts
- Attributes pipeline deals to originating marketing channels and campaigns
- Monitors conversion funnels for stage-over-stage drop-off patterns
- Produces monthly and quarterly revenue forecasts from pipeline weighted value
- Detects CAC/LTV shifts and alerts when unit economics deteriorate

## Escalation Behavior

- **Critical**: LTV:CAC ratio drops below 3:1 or blended CAC exceeds target by >25% → finding to executive-assistant
- **High**: Revenue forecast deviation >15% from target → finding to executive-assistant
- **Medium**: Channel attribution shift or conversion bottleneck → finding to sales-pipeline or marketing-growth
- **Low**: Minor baseline recalibration → memory update only

## Recommended Setup

Set these North Star keys for best results:
- `revenue_targets` — ARR, MRR, or revenue growth targets
- `attribution_model` — Preferred attribution method (first-touch, last-touch, multi-touch)
- `growth_targets` — Customer acquisition and expansion targets
