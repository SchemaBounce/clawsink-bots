---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: executive-reporter
  displayName: "Executive Reporter"
  version: "1.0.2"
  description: "C-suite executive summaries, KPI dashboards, and cross-domain business intelligence."
  category: analytics
  tags: ["executive", "reports", "KPI", "dashboards", "business-intelligence", "c-suite"]
agent:
  capabilities: ["analytics", "reporting", "cross-domain"]
  hostingMode: "openclaw"
  defaultDomain: "analytics"
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 keys (`mission`, `company_goals`, `reporting_cadence`) before generating any report
    - ALWAYS compare current metrics against stored KPI baselines in `kpi_baselines` memory before reporting trends
    - ALWAYS include both quantitative metrics and qualitative context in executive summaries
    - NEVER report raw numbers without trend direction (improving/declining/stable) and business impact assessment
    - NEVER include operational details — keep summaries at C-suite strategic level
    - NEVER generate a report if insufficient data exists — write a data gap finding to executive-assistant instead
    - Escalation: critical KPI deviations (revenue drop >10%, system outage, compliance breach) trigger immediate finding to executive-assistant
    - Adapt report format over time using `stakeholder_preferences` memory — learn what level of detail the human operator values
    - When multiple domains show correlated trends, call them out as systemic patterns rather than listing separately
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
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: true
    browsing: true
    crawling: true
mcpServers:
  - ref: "tools/agentmail"
    required: false
    reason: "Distribute executive summaries and KPI reports to C-suite stakeholders"
  - ref: "tools/exa"
    required: true
    reason: "Search for industry benchmarks, market data, and competitor intelligence for executive context"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse financial data portals and industry analyst report sites"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl market research publications and industry benchmark databases"
egress:
  mode: "none"
skills:
  - ref: "skills/report-generation@1.0.0"
automations:
  triggers: []
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-company-goals
      name: "Define company goals"
      description: "Current quarter/year business objectives and KPI targets"
      type: north_star
      key: company_goals
      group: configuration
      priority: required
      reason: "Cannot generate meaningful executive reports without business objectives to measure against"
      ui:
        inputType: text
        placeholder: '{"q1_revenue": "$2M", "nps_target": 50, "churn_target": "< 5%"}'
    - id: set-reporting-cadence
      name: "Set reporting cadence"
      description: "Preferred reporting frequency and delivery timing"
      type: north_star
      key: reporting_cadence
      group: configuration
      priority: required
      reason: "Controls when reports are generated and delivered to stakeholders"
      ui:
        inputType: text
        placeholder: '{"frequency": "weekly", "delivery_day": "Monday", "delivery_time": "09:00"}'
    - id: set-mission
      name: "Define company mission"
      description: "Company mission provides strategic context for all executive summaries"
      type: north_star
      key: mission
      group: configuration
      priority: recommended
      reason: "Aligns report narrative with company direction and strategic priorities"
      ui:
        inputType: text
        placeholder: "e.g., Enable real-time data infrastructure for every business"
    - id: connect-exa
      name: "Connect Exa for market context"
      description: "Search for industry benchmarks and market data to contextualize KPIs"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "Executive reports need industry context — benchmarks, competitor signals, market trends"
      ui:
        icon: search
        actionLabel: "Connect Exa"
    - id: connect-agentmail
      name: "Connect email for report delivery"
      description: "Distribute executive summaries and KPI reports to C-suite"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: recommended
      reason: "Primary delivery channel for weekly executive summaries"
      ui:
        icon: mail
        actionLabel: "Connect Email"
    - id: set-kpi-baselines
      name: "Configure KPI baselines"
      description: "Baseline values for key metrics to detect significant deviations"
      type: config
      group: configuration
      target: { namespace: kpi_baselines, key: initial_baselines }
      priority: recommended
      reason: "Trend analysis requires baselines — without them, first reports lack historical context"
      ui:
        inputType: text
        placeholder: '{"mrr": 100000, "nps": 45, "churn_rate": 0.06, "uptime": 0.999}'
goals:
  - name: report_generation
    description: "Generate executive summaries on schedule with cross-domain coverage"
    category: primary
    metric:
      type: count
      entity: executive_summaries
    target:
      operator: ">"
      value: 0
      period: weekly
  - name: kpi_deviation_detection
    description: "Flag KPI deviations beyond threshold before the next reporting cycle"
    category: primary
    metric:
      type: boolean
      check: "critical_kpi_deviations_reported"
    target:
      operator: "=="
      value: 1
      period: per_run
      condition: "when KPI deviation exceeds 10% from baseline"
  - name: report_accuracy
    description: "Include both quantitative metrics and qualitative context in every report"
    category: secondary
    metric:
      type: boolean
      check: "report_includes_metrics_and_context"
    target:
      operator: "=="
      value: 1
      period: per_run
    feedback:
      enabled: true
      entityType: executive_summaries
      actions:
        - { value: useful, label: "Actionable" }
        - { value: too_detailed, label: "Too detailed" }
        - { value: missing_context, label: "Missing context" }
  - name: baseline_maintenance
    description: "Keep KPI baselines current for accurate trend reporting"
    category: health
    metric:
      type: boolean
      check: "kpi_baselines_updated_after_report"
    target:
      operator: "=="
      value: 1
      period: weekly
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
