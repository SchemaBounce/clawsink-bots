---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: data-quality-monitor
  displayName: "Data Quality Monitor"
  version: "1.0.5"
  description: "Validates data quality rules on incoming records across all entity types."
  category: engineering
  tags: ["data-quality", "validation", "cdc"]
agent:
  capabilities: ["data_quality", "validation"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS process incoming CDC events promptly -- this bot is trigger-driven on entityType=* eventType=created, so every new record must be validated
    - ALWAYS read `quality_rules` memory namespace before validation to apply the latest learned rules and configured thresholds
    - ALWAYS check completeness (required fields non-null), format compliance (regex/type checks), and consistency (cross-field logic) for every record
    - NEVER skip referential integrity checks -- verify foreign key references resolve to existing records via `adl_query_records`
    - NEVER suppress a critical data quality finding -- alert executive-assistant (type=alert) immediately for data corruption or systemic failures
    - Send data quality degradation patterns to data-engineer (type=finding) when issues indicate a pipeline-level problem (e.g., all records from one source failing)
    - Send data quality issues affecting analytics accuracy to business-analyst (type=finding) so downstream reports are flagged
    - Consume findings from data-engineer about pipeline changes that may require quality rule updates
    - Continuously update `baseline_stats` memory with field-level distribution statistics to improve anomaly detection over time
    - Write `dq_scores` for every validated batch to maintain a running quality scorecard per entity type
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
  entityType: "*"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["data-engineer"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical data quality issue detected" }
    - { type: "finding", to: ["data-engineer"], when: "data quality degradation indicating pipeline issue" }
    - { type: "finding", to: ["business-analyst"], when: "data quality issue affecting analytics accuracy" }
data:
  entityTypesRead: ["*"]
  entityTypesWrite: ["dq_findings", "dq_scores"]
  memoryNamespaces: ["quality_rules", "baseline_stats"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/data-ops@1.0.0"
  - ref: "skills/cdc-event-analysis@1.0.0"
  - ref: "skills/data-validation@1.0.0"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: configure-quality-rules
      name: "Define quality rules"
      description: "Seed the quality_rules memory namespace with validation rules (required fields, format patterns, cross-field logic) for your entity types."
      type: config
      group: configuration
      priority: required
      reason: "The bot reads quality_rules before every validation pass. Without rules, it falls back to generic null/type checks only."
      ui:
        target:
          namespace: "quality_rules"
          key: "rules"
    - id: seed-entity-records
      name: "Ensure records exist"
      description: "Have at least a few records of any entity type so the bot can establish baseline statistics on first run."
      type: data_presence
      group: data
      priority: required
      reason: "The bot is CDC-triggered on entityType=* created events. It needs existing records to build baseline_stats for distribution analysis."
      ui:
        entityType: "*"
        minCount: 10
    - id: set-north-star-mission
      name: "Define North Star mission"
      description: "Set the workspace mission so the bot understands which entity types and quality dimensions are highest priority."
      type: north_star
      group: configuration
      priority: required
      reason: "The bot reads zone1 mission to prioritize which data quality failures warrant critical alerts vs informational findings."
      ui:
        key: "mission"
    - id: verify-data-engineer-active
      name: "Ensure Data Engineer bot is active"
      description: "The data quality monitor sends pipeline-level degradation findings to data-engineer. Confirm that bot is deployed."
      type: manual
      group: external
      priority: recommended
      reason: "Pipeline-level quality issues are routed to data-engineer for root cause analysis. Without it, those findings go unprocessed."
      ui:
        instructions: "Deploy the data-engineer bot from the marketplace, or confirm it is already active in your workspace."
    - id: configure-dq-thresholds
      name: "Set quality score thresholds"
      description: "Optionally configure what dq_scores levels constitute critical, warning, and healthy quality for each entity type."
      type: config
      group: configuration
      priority: recommended
      reason: "Custom thresholds let you tune when the bot escalates vs logs. Defaults use 90% healthy, 70% warning, below 70% critical."
      ui:
        target:
          namespace: "quality_rules"
          key: "score_thresholds"
goals:
  - id: records-validated
    name: "Records validated"
    description: "Total records processed through quality validation rules."
    metricType: count
    target: "> 0 per day"
    category: primary
    feedback:
      question: "Are the quality checks catching real data issues?"
      options: ["yes", "mostly", "too many false positives", "missing real problems"]
  - id: quality-score-coverage
    name: "Quality score coverage"
    description: "Percentage of entity types with active dq_scores being maintained."
    metricType: rate
    target: "> 90%"
    category: primary
  - id: critical-issue-detection
    name: "Critical issue detection"
    description: "Critical data quality issues are detected and escalated within one run cycle."
    metricType: boolean
    target: "true"
    category: health
  - id: baseline-stats-freshness
    name: "Baseline stats freshness"
    description: "The baseline_stats memory is updated with current field distributions after each run."
    metricType: boolean
    target: "updated within last 24h"
    category: health
---

# Data Quality Monitor

Validates data quality in real-time as records arrive. Checks completeness, consistency, format compliance, and referential integrity.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
