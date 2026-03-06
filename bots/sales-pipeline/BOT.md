---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: sales-pipeline
  displayName: "Sales Pipeline"
  version: "1.0.0"
  description: "Analyzes sales funnel and identifies bottlenecks."
  category: sales
  tags: ["sales", "funnel", "pipeline"]
agent:
  capabilities: ["sales_analysis", "forecasting"]
  hostingMode: "openclaw"
  defaultDomain: "sales"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "@daily"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant insight discovered" }
data:
  entityTypesRead: ["deals", "pipeline_stages"]
  entityTypesWrite: ["pipeline_reports", "deal_insights"]
  memoryNamespaces: ["conversion_rates", "stage_durations"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["sales"]
skills:
  - inline: "core-analysis"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: true
    reason: "OAuth access to CRM platforms (Salesforce, HubSpot, Pipedrive) for reading deal stages and pipeline data"
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
