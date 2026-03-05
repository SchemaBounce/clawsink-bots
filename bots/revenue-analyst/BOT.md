---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: revenue-analyst
  displayName: "Revenue Analyst"
  version: "1.0.0"
  description: "Daily revenue analysis and trend reporting."
  category: finance
  tags: ["revenue", "analytics", "trends"]
agent:
  capabilities: ["revenue_analysis", "forecasting"]
  hostingMode: "openclaw"
  defaultDomain: "finance"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
schedule:
  default: "@daily"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant insight discovered" }
data:
  entityTypesRead: ["revenue_data", "sales_metrics"]
  entityTypesWrite: ["revenue_reports", "trend_findings"]
  memoryNamespaces: ["revenue_baselines", "forecast_models"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["finance"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Revenue Analyst

Analyzes daily revenue streams, identifies trends, and produces actionable financial reports.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
