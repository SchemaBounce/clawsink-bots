---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: sales-pipeline
  displayName: "Sales Pipeline"
  version: "1.0.1"
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
presence:
  email:
    required: true
    provider: agentmail
  web:
    browsing: true
    search: true
requirements:
  minTier: "starter"
---

# Sales Pipeline

Analyzes the sales pipeline daily. Identifies stalled deals, conversion bottlenecks, and forecasts quarterly performance.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
