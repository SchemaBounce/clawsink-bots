---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: data-engineer
  displayName: "Data Engineer"
  version: "1.0.2"
  description: "Monitors Kolumn schemas, CDC pipeline health, DLQ depth, and sink configuration drift."
  category: engineering
  tags: ["data", "schemas", "cdc", "pipelines", "kolumn", "drift"]
agent:
  capabilities: ["data_engineering", "dev_devops"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS check pipeline throughput, DLQ depth, and error rates for every active pipeline at the start of each run
    - ALWAYS compare current schema definitions against active sink configurations to detect drift -- never assume schemas are stable
    - ALWAYS read `thresholds` memory namespace for freshness and error rate limits before evaluating pipeline health
    - NEVER dismiss DLQ growth without investigating the root cause -- even small DLQ increases can indicate data loss risk
    - NEVER write to `pipeline_status` without including the pipeline ID, current throughput, error rate, and freshness timestamp
    - Escalate to executive-assistant (type=alert) only for critical pipeline failures or confirmed data loss risk
    - Send schema drift and sink config mismatches to sre-devops (type=finding) for infrastructure-level remediation
    - Forward data quality trends to data-quality-monitor (type=finding) when pipeline changes may require rule updates
    - Forward data exposure risks (unencrypted sinks, public endpoints) to security-agent (type=finding)
    - Consume requests from sre-devops and business-analyst and findings from sre-devops -- process these before routine checks
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
  default: "@every 6h"
  recommendations:
    light: "@every 12h"
    standard: "@every 6h"
    intensive: "@every 2h"
messaging:
  listensTo:
    - { type: "request", from: ["sre-devops", "business-analyst"] }
    - { type: "finding", from: ["sre-devops"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical data pipeline failure" }
    - { type: "finding", to: ["business-analyst"], when: "schema drift or data quality issue" }
    - { type: "finding", to: ["sre-devops"], when: "infrastructure-level pipeline issue" }
    - { type: "finding", to: ["data-quality-monitor"], when: "data quality rules need updating based on pipeline changes" }
    - { type: "finding", to: ["security-agent"], when: "data exposure risk or unencrypted pipeline detected" }
data:
  entityTypesRead: ["pipeline_status", "sre_findings"]
  entityTypesWrite: ["de_findings", "de_alerts", "pipeline_status"]
  memoryNamespaces: ["working_notes", "learned_patterns", "thresholds"]
zones:
  zone1Read: ["mission", "tech_stack"]
  zone2Domains: ["engineering", "operations"]
presence:
  web:
    search: true
    browsing: true
    crawling: false
mcpServers:
  - ref: "tools/exa"
    required: false
    reason: "Search for pipeline troubleshooting guides, connector documentation, and data engineering best practices"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse database documentation, cloud provider dashboards, and pipeline monitoring UIs"
  - ref: "tools/composio"
    required: false
    reason: "Integrate with data catalog and pipeline orchestration SaaS tools"
egress:
  mode: "none"
skills:
  - ref: "skills/record-monitoring@1.0.0"
automations:
  triggers:
    - name: "Data quality check on new records"
      entityType: "*"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "New records were created. Run data quality checks — validate required fields, check for duplicates, verify referential integrity, and flag anomalies."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-tech-stack
      name: "Define data stack"
      description: "Your databases, CDC sources, and sink destinations"
      type: north_star
      key: tech_stack
      group: configuration
      priority: required
      reason: "Cannot monitor pipeline health without knowing the source and sink technologies"
      ui:
        inputType: text
        placeholder: "e.g., PostgreSQL CDC, Kafka, BigQuery sink, S3 sink"
    - id: set-freshness-thresholds
      name: "Set data freshness thresholds"
      description: "Maximum acceptable data age per pipeline before alerting"
      type: config
      group: configuration
      target: { namespace: thresholds, key: freshness_limits }
      priority: required
      reason: "Cannot detect stale data without defined freshness targets"
      ui:
        inputType: text
        placeholder: '{"critical_pipelines": "5m", "standard_pipelines": "30m", "batch_pipelines": "6h"}'
        default: '{"critical_pipelines": "5m", "standard_pipelines": "30m", "batch_pipelines": "6h"}'
    - id: import-pipeline-status
      name: "Connect pipeline monitoring data"
      description: "Pipeline throughput, error rates, and DLQ metrics"
      type: data_presence
      entityType: pipeline_status
      minCount: 1
      group: data
      priority: required
      reason: "No pipeline data means no health monitoring capability"
      ui:
        actionLabel: "Import Pipeline Data"
        emptyState: "No pipeline data found. Set up a CDC pipeline or import pipeline metrics."
    - id: connect-exa
      name: "Connect Exa for troubleshooting research"
      description: "Search connector docs and pipeline troubleshooting guides"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: recommended
      reason: "Enables research into connector issues and data engineering best practices"
      ui:
        icon: search
        actionLabel: "Connect Exa"
    - id: set-dlq-thresholds
      name: "Configure DLQ alert thresholds"
      description: "Dead letter queue depth thresholds per pipeline"
      type: config
      group: configuration
      target: { namespace: thresholds, key: dlq_limits }
      priority: recommended
      reason: "Custom DLQ thresholds reduce false alerts on high-volume pipelines"
      ui:
        inputType: text
        placeholder: '{"warning": 50, "critical": 200}'
        default: '{"warning": 50, "critical": 200}'
goals:
  - name: detect_schema_drift
    description: "Detect schema mismatches between source and sink configurations"
    category: primary
    metric:
      type: count
      entity: de_findings
      filter: { finding_type: "schema_drift" }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when schema changes exist in source databases"
  - name: pipeline_health_coverage
    description: "Monitor all active pipelines every run cycle"
    category: primary
    metric:
      type: rate
      numerator: { entity: pipeline_status, filter: { checked_this_run: true } }
      denominator: { entity: pipeline_status }
    target:
      operator: ">"
      value: 0.95
      period: per_run
  - name: dlq_response_time
    description: "Flag DLQ growth within one run cycle of detection"
    category: secondary
    metric:
      type: boolean
      check: "dlq_growth_flagged_same_cycle"
    target:
      operator: "=="
      value: 1
      period: per_run
  - name: data_freshness_compliance
    description: "Maintain data freshness within configured thresholds"
    category: health
    metric:
      type: rate
      numerator: { entity: pipeline_status, filter: { freshness_ok: true } }
      denominator: { entity: pipeline_status }
    target:
      operator: ">"
      value: 0.95
      period: weekly
---

# Data Engineer

Monitors the health and correctness of data pipelines. Tracks Kolumn schema states, CDC pipeline throughput, DLQ depth, sink configuration drift, and data freshness.

## What It Does

- Monitors CDC pipeline health: throughput, latency, error rates
- Tracks DLQ depth and retry exhaustion patterns
- Detects schema drift between source and destination
- Validates sink configurations for consistency
- Monitors data freshness across all active pipelines

## Escalation Behavior

- **Critical**: Pipeline failure, data loss risk → alerts executive-assistant
- **High**: Schema drift, sink config mismatch → finding to sre-devops
- **Medium**: DLQ growth, freshness degradation → logged as de_findings
- **Low**: Minor config observations → memory update only
