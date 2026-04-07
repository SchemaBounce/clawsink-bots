---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: sre-devops
  displayName: "SRE / DevOps Bot"
  version: "1.0.5"
  description: "Monitors infrastructure health, pipeline status, incident patterns, and SLA compliance."
  category: operations
  tags: ["infrastructure", "monitoring", "incidents", "pipelines", "sla"]
agent:
  capabilities: ["dev_devops", "operations"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
  instructions: |
    ## Operating Rules
    - ALWAYS check North Star keys `tech_stack` and `sla_targets` before evaluating any metric — thresholds are workspace-specific, never assume defaults.
    - ALWAYS correlate anomalies with recent deployments and upstream pipeline changes before raising severity.
    - NEVER raise a critical alert without confirming the issue persists across at least two consecutive metric reads or independent signals.
    - Escalate to executive-assistant ONLY for confirmed SLA breaches or data-loss-risk incidents — everything else stays as findings.
    - Route infrastructure-related code issues to devops-automator, NOT to code-reviewer — devops-automator owns deployment pipelines.
    - Route suspicious activity or misconfigurations with security implications to security-agent immediately.
    - When an incident is created, cross-reference `de_findings` from data-engineer to check for upstream pipeline root causes before concluding root cause.
    - Update `thresholds` memory namespace whenever a false-positive alert is identified so future runs avoid the same noise.
    - On each scheduled run, compare current metrics against `learned_patterns` to detect drift — do not treat every threshold crossing as novel.
    - When sending alerts to uptime-manager, include affected service names, duration, and customer-facing impact assessment.
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
  default: "@every 4h"
  recommendations:
    light: "@every 8h"
    standard: "@every 4h"
    intensive: "@every 1h"
messaging:
  listensTo:
    - { type: "alert", from: ["*"] }
    - { type: "request", from: ["executive-assistant", "customer-support"] }
    - { type: "finding", from: ["data-engineer"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical incident or SLA breach" }
    - { type: "alert", to: ["uptime-manager"], when: "service outage or degradation affecting status page" }
    - { type: "finding", to: ["business-analyst"], when: "anomaly detected or trend identified" }
    - { type: "finding", to: ["data-engineer"], when: "pipeline infrastructure issue" }
    - { type: "finding", to: ["devops-automator"], when: "deployment-related infrastructure issue" }
    - { type: "finding", to: ["security-agent"], when: "suspicious infrastructure activity or misconfiguration" }
data:
  entityTypesRead: ["pipeline_status", "incidents", "infrastructure_metrics", "de_findings"]
  entityTypesWrite: ["sre_findings", "sre_alerts", "incidents"]
  memoryNamespaces: ["working_notes", "learned_patterns", "thresholds"]
zones:
  zone1Read: ["mission", "tech_stack", "sla_targets"]
  zone2Domains: ["operations", "infrastructure"]
egress:
  mode: "restricted"
  allowedDomains: ["api.pagerduty.com", "api.datadoghq.com", "api.opsgenie.com"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/workflow-ops@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/incident-triage@1.0.0"
  - ref: "skills/pipeline-monitoring@1.0.0"
  - ref: "skills/sla-compliance@1.0.0"
mcpServers:
  - ref: "tools/slack"
    required: false
    reason: "Posts incident alerts and status updates to operations channels"
  - ref: "tools/exa"
    required: false
    reason: "Search for known outage reports, CVE advisories, and infrastructure incident patterns"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse cloud provider status pages and monitoring dashboards for incident correlation"
  - ref: "tools/composio"
    required: false
    reason: "Connect to PagerDuty, Datadog, and OpsGenie for incident management workflows"
  - ref: "tools/firebase"
    required: false
    reason: "Monitor Firebase logs, analytics, and Crashlytics crash reports"
  - ref: "tools/datadog"
    required: false
    reason: "Query metrics, search logs, and monitor incidents via Datadog"
  - ref: "tools/aws-cloudwatch"
    required: false
    reason: "Query CloudWatch logs, metrics, and alarms"
  - ref: "tools/grafana"
    required: false
    reason: "Search dashboards and query Prometheus metrics via Grafana"
  - ref: "tools/pagerduty"
    required: false
    reason: "Manage incidents, check on-call schedules, and trigger alerts"
  - ref: "tools/sentry"
    required: false
    reason: "Track errors, search issues, and monitor release health"
presence:
  web:
    browsing: true
    search: true
automations:
  triggers:
    - name: "Runbook lookup on new incident"
      entityType: "incidents"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "A new incident was reported. Look up matching runbooks, assess severity, and recommend immediate remediation steps."
    - name: "Anomaly alert on metric change"
      entityType: "infrastructure_metrics"
      eventType: "updated"
      targetAgent: "self"
      condition: '{"anomaly_score": {"$gt": 0.8}}'
      promptTemplate: "Infrastructure metric anomaly detected. Correlate with recent deployments, check for cascading failures, and determine if escalation is needed."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-tech-stack
      name: "Define tech stack"
      description: "Your infrastructure components, cloud providers, and key services"
      type: north_star
      key: tech_stack
      group: configuration
      priority: required
      reason: "Cannot evaluate infrastructure health without knowing what to monitor"
      ui:
        inputType: text
        placeholder: "e.g., AWS EKS, PostgreSQL, Redis, Datadog, ArgoCD"
    - id: set-sla-targets
      name: "Define SLA targets"
      description: "Uptime, latency, and data freshness targets for your services"
      type: north_star
      key: sla_targets
      group: configuration
      priority: required
      reason: "Cannot detect SLA breaches without defined targets"
      ui:
        inputType: text
        placeholder: '{"uptime": "99.9%", "p99_latency": "500ms", "freshness": "5min"}'
    - id: import-pipeline-status
      name: "Connect pipeline monitoring"
      description: "Pipeline health metrics feed the bot's monitoring loop"
      type: data_presence
      entityType: pipeline_status
      minCount: 1
      group: data
      priority: required
      reason: "No pipeline data means no infrastructure monitoring capability"
      ui:
        actionLabel: "Import Pipeline Status"
        emptyState: "No pipeline data found. Set up a data pipeline or import metrics."
    - id: connect-slack
      name: "Connect Slack for incident alerts"
      description: "Posts incident alerts and status updates to operations channels"
      type: mcp_connection
      ref: tools/slack
      group: connections
      priority: recommended
      reason: "Real-time incident alerting to your ops team"
      ui:
        icon: slack
        actionLabel: "Connect Slack"
    - id: connect-pagerduty
      name: "Connect PagerDuty / OpsGenie"
      description: "Integrates with incident management for automated escalation"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: recommended
      reason: "Enables automated incident creation and on-call notification"
      ui:
        icon: pagerduty
        actionLabel: "Connect Incident Management"
        helpUrl: "https://docs.schemabounce.com/integrations/incident-management"
    - id: set-alert-thresholds
      name: "Configure alert thresholds"
      description: "Error rate and latency thresholds for anomaly detection"
      type: config
      group: configuration
      target: { namespace: thresholds, key: alert_thresholds }
      priority: recommended
      reason: "Custom thresholds reduce false positive alerts"
      ui:
        inputType: text
        placeholder: '{"error_rate": 0.05, "latency_p99_ms": 500, "dlq_depth": 100}'
        default: '{"error_rate": 0.05, "latency_p99_ms": 500, "dlq_depth": 100}'
goals:
  - name: detect_incidents
    description: "Identify infrastructure incidents from metric anomalies"
    category: primary
    metric:
      type: count
      entity: incidents
      filter: { detected_by: "sre-devops" }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when anomalies exist in infrastructure metrics"
  - name: sla_compliance
    description: "Track and maintain SLA compliance across all services"
    category: primary
    metric:
      type: rate
      numerator: { entity: pipeline_status, filter: { sla_breached: false } }
      denominator: { entity: pipeline_status }
    target:
      operator: ">"
      value: 0.99
      period: weekly
  - name: false_alert_reduction
    description: "Reduce noise by learning from false positive alerts"
    category: secondary
    metric:
      type: rate
      numerator: { entity: sre_findings, filter: { feedback: "confirmed" } }
      denominator: { entity: sre_findings, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.9
      period: monthly
    feedback:
      enabled: true
      entityType: sre_findings
      actions:
        - { value: confirmed, label: "Real issue" }
        - { value: false_positive, label: "False alarm" }
  - name: incident_correlation
    description: "Correlate incidents with upstream causes before escalating"
    category: health
    metric:
      type: boolean
      check: "correlated_with_upstream_before_escalation"
    target:
      operator: "=="
      value: 1
      period: per_run
  - name: threshold_calibration
    description: "Improve detection thresholds from operational experience"
    category: health
    metric:
      type: count
      source: memory
      namespace: learned_patterns
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# SRE / DevOps Bot

Monitors infrastructure health across pipelines, services, and environments. Detects incidents, tracks SLA compliance, and identifies reliability patterns over time.

## What It Does

- Checks pipeline health metrics (throughput, latency, error rates)
- Detects incident patterns and correlates across services
- Tracks SLA compliance against configured targets
- Monitors DLQ depth and retry exhaustion rates
- Identifies infrastructure drift and configuration anomalies

## Escalation Behavior

- **Critical**: Pipeline down, SLA breach, data loss risk → alerts executive-assistant
- **High**: Latency spike, error rate increase → finding to business-analyst
- **Medium**: DLQ growth, config drift → logged as sre_findings
- **Low**: Minor threshold adjustments → memory update only

## Recommended Setup

Set these North Star keys for best results:
- `tech_stack` — Your infrastructure components
- `sla_targets` — Uptime, latency, and freshness targets
