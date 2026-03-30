---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: revops
  displayName: "Revenue Operations"
  version: "1.0.0"
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
egress:
  mode: "restricted"
  allowedDomains: ["api.stripe.com"]
requirements:
  minTier: "team"
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
