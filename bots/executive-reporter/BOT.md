---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: executive-reporter
  displayName: "Executive Reporter"
  version: "1.0.0"
  description: "C-suite executive summaries, KPI dashboards, and cross-domain business intelligence."
  category: analytics
  tags: ["executive", "reports", "KPI", "dashboards", "business-intelligence", "c-suite"]
agent:
  capabilities: ["analytics", "reporting", "cross-domain"]
  hostingMode: "openclaw"
  defaultDomain: "analytics"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "medium"
cost:
  estimatedTokensPerRun: 30000
  estimatedCostTier: "medium"
schedule:
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@weekly"
    intensive: "@every 3d"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "accountant", "business-analyst"] }
    - { type: "finding", from: ["accountant", "business-analyst"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "executive summary ready or critical KPI deviation detected" }
data:
  entityTypesRead: ["transactions", "invoices", "acct_findings", "tasks", "stories", "bugs", "velocity_metrics", "experiments", "experiment_metrics", "conversion_funnels", "inventory_items", "support_tickets", "incidents"]
  entityTypesWrite: ["executive_summaries", "kpi_reports"]
  memoryNamespaces: ["reporting_templates", "kpi_baselines", "stakeholder_preferences"]
zones:
  zone1Read: ["mission", "company_goals", "reporting_cadence"]
  zone2Domains: ["analytics", "finance", "operations", "engineering"]
skills:
  - ref: "skills/report-generation@1.0.0"
automations:
  triggers: []
requirements:
  minTier: "starter"
---

# Executive Reporter

Synthesizes data across all domains into concise C-suite executive summaries. Highlights what changed, what matters, and what needs action. Runs weekly to deliver strategic intelligence.

## What It Does

- Aggregates findings from finance, operations, engineering, and analytics domains
- Generates concise executive summaries with clear metrics and trends
- Tracks KPIs against baselines and highlights deviations
- Provides recommended actions prioritized by business impact
- Adapts report format to stakeholder preferences over time

## Escalation Behavior

- **Critical**: Major KPI deviation (revenue drop, system outage, compliance issue) -> immediate finding to executive-assistant
- **High**: Negative trend across multiple domains -> finding to executive-assistant
- **Medium**: Routine weekly summary -> finding to executive-assistant
- **Low**: Baseline updates, template refinement -> memory update only

## Recommended Setup

Set these North Star keys:
- `company_goals` -- Current quarter/year business objectives and targets
- `reporting_cadence` -- Preferred reporting frequency and delivery time
