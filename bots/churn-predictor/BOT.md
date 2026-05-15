---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: churn-predictor
  displayName: "Churn Predictor"
  version: "1.0.8"
  description: "Analyzes user activity patterns to predict and flag churn risk."
  category: saas
  tags: ["churn", "retention", "analytics", "cdc"]
agent:
  capabilities: ["churn_analysis", "retention"]
  hostingMode: "openclaw"
  defaultDomain: "analytics"
  instructions: |
    ## Operating Rules
    - ALWAYS read `activity_baselines` memory before scoring, compare current activity against the stored baseline to detect deviations, not absolute values.
    - ALWAYS include the account identifier and time window in every churn_scores record so downstream consumers can deduplicate and trend.
    - NEVER assign a churn risk score without at least two corroborating signals (e.g., login drop + feature usage decline). Single-signal scores produce false positives.
    - NEVER send an alert to executive-assistant for medium or low severity, only high churn risk accounts requiring immediate intervention qualify.
    - Escalate to customer-support (finding) when an at-risk account would benefit from proactive outreach before the risk crystallizes.
    - Escalate to customer-onboarding (finding) when churn signals appear within the first 30 days. These are onboarding failures, not retention failures.
    - Forward churn risk cohort data to revops (finding) when aggregate churn patterns affect revenue forecast accuracy.
    - Update `churn_indicators` memory with every new pattern discovered, future runs must build on learned patterns, not re-derive from scratch.
    - When processing CDC events from customer-onboarding or customer-support findings, cross-reference with existing churn_scores before creating duplicates.
    - Respect token budget, if the event batch is large, prioritize high-activity-drop accounts over minor fluctuations.
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
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
trigger:
  entityType: "user_activity"
  eventType: "updated"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["customer-onboarding", "customer-support"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "high churn risk account requiring immediate intervention" }
    - { type: "finding", to: ["revops"], when: "churn risk cohort data affecting revenue forecast" }
    - { type: "finding", to: ["customer-support"], when: "at-risk account needing proactive outreach" }
    - { type: "finding", to: ["customer-onboarding"], when: "early churn signal during onboarding window" }
data:
  entityTypesRead: ["user_activity", "engagement_metrics"]
  entityTypesWrite: ["churn_scores", "retention_alerts"]
  memoryNamespaces: ["activity_baselines", "churn_indicators"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["analytics", "customer_success"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/data-ops@1.0.0"
  - ref: "skills/cdc-event-analysis@1.0.0"
presence:
  web:
    search: true
    browsing: false
    crawling: true
mcpServers:
  - ref: "tools/stripe"
    required: false
    reason: "Analyzes subscription churn signals from billing data"
  - ref: "tools/exa"
    required: false
    reason: "Search for industry churn benchmarks and retention best practices"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl customer review sites and forums for churn sentiment signals"
  - ref: "tools/google-calendar"
    required: false
    reason: "Schedule proactive check-in calls with at-risk customers"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-mission
      name: "Define product mission"
      description: "Product mission shapes how churn risk is interpreted and prioritized"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Churn risk scoring must align with what the business considers critical retention"
      ui:
        inputType: text
        placeholder: "e.g., Deliver the most reliable real-time data platform for growing teams"
        prefillFrom: "workspace.mission"
    - id: connect-stripe
      name: "Connect Stripe for billing signals"
      description: "Subscription downgrades, failed payments, and cancellation signals from billing"
      type: mcp_connection
      ref: tools/stripe
      group: connections
      priority: recommended
      reason: "Billing churn signals (downgrades, failed payments) are strong predictors"
      ui:
        icon: stripe
        actionLabel: "Connect Stripe"
    - id: import-activity-data
      name: "Import user activity baseline"
      description: "Historical activity data establishes normal engagement patterns for comparison"
      type: data_presence
      entityType: user_activity
      minCount: 50
      group: data
      priority: required
      reason: "Cannot detect activity drops without a baseline of normal engagement"
      ui:
        actionLabel: "Check Activity Data"
        emptyState: "No user activity data found. Connect your product analytics or import activity records."
    - id: import-engagement-metrics
      name: "Import engagement metrics"
      description: "Feature usage and session metrics help identify disengagement patterns"
      type: data_presence
      entityType: engagement_metrics
      minCount: 10
      group: data
      priority: recommended
      reason: "Multi-signal churn prediction requires engagement metrics alongside activity data"
      ui:
        actionLabel: "Check Engagement Data"
        emptyState: "No engagement metrics found. Import feature usage data for better churn predictions."
    - id: connect-exa
      name: "Connect Exa for benchmarks"
      description: "Research industry churn benchmarks and retention best practices"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: optional
      reason: "Industry churn rate benchmarks contextualize your churn scores"
      ui:
        icon: search
        actionLabel: "Connect Exa"
goals:
  - name: churn_risk_scoring
    description: "Score every active account for churn risk on each run"
    category: primary
    metric:
      type: count
      entity: churn_scores
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when user activity data exists"
  - name: multi_signal_accuracy
    description: "Every churn score backed by at least two corroborating signals"
    category: primary
    metric:
      type: rate
      numerator: { entity: churn_scores, filter: { signal_count: { "$gte": 2 } } }
      denominator: { entity: churn_scores }
    target:
      operator: ">"
      value: 0.95
      period: weekly
  - name: prediction_quality
    description: "High-risk predictions confirmed by actual churn or save actions"
    category: secondary
    metric:
      type: rate
      numerator: { entity: churn_scores, filter: { feedback: "confirmed" } }
      denominator: { entity: churn_scores, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.7
      period: monthly
    feedback:
      enabled: true
      entityType: churn_scores
      actions:
        - { value: confirmed, label: "Customer did churn" }
        - { value: false_positive, label: "False alarm - customer stayed" }
        - { value: saved, label: "Intervention saved the account" }
  - name: early_warning_coverage
    description: "Flag at-risk accounts before they reach cancellation"
    category: secondary
    metric:
      type: count
      entity: retention_alerts
      filter: { severity: "high" }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when high-risk accounts exist"
  - name: baseline_learning
    description: "Continuously refine activity baselines and churn indicator patterns"
    category: health
    metric:
      type: count
      source: memory
      namespace: activity_baselines
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Churn Predictor

Predicts customer churn by analyzing activity pattern changes. Flags accounts showing disengagement signals and recommends retention actions.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
