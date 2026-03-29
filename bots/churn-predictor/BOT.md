---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: churn-predictor
  displayName: "Churn Predictor"
  version: "1.0.0"
  description: "Analyzes user activity patterns to predict and flag churn risk."
  category: saas
  tags: ["churn", "retention", "analytics", "cdc"]
agent:
  capabilities: ["churn_analysis", "retention"]
  hostingMode: "openclaw"
  defaultDomain: "analytics"
  instructions: |
    ## Operating Rules
    - ALWAYS read `activity_baselines` memory before scoring — compare current activity against the stored baseline to detect deviations, not absolute values.
    - ALWAYS include the account identifier and time window in every churn_scores record so downstream consumers can deduplicate and trend.
    - NEVER assign a churn risk score without at least two corroborating signals (e.g., login drop + feature usage decline). Single-signal scores produce false positives.
    - NEVER send an alert to executive-assistant for medium or low severity — only high churn risk accounts requiring immediate intervention qualify.
    - Escalate to customer-support (finding) when an at-risk account would benefit from proactive outreach before the risk crystallizes.
    - Escalate to customer-onboarding (finding) when churn signals appear within the first 30 days — these are onboarding failures, not retention failures.
    - Forward churn risk cohort data to revops (finding) when aggregate churn patterns affect revenue forecast accuracy.
    - Update `churn_indicators` memory with every new pattern discovered — future runs must build on learned patterns, not re-derive from scratch.
    - When processing CDC events from customer-onboarding or customer-support findings, cross-reference with existing churn_scores before creating duplicates.
    - Respect token budget — if the event batch is large, prioritize high-activity-drop accounts over minor fluctuations.
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
  - ref: "skills/cdc-event-analysis@1.0.0"
requirements:
  minTier: "starter"
---

# Churn Predictor

Predicts customer churn by analyzing activity pattern changes. Flags accounts showing disengagement signals and recommends retention actions.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
