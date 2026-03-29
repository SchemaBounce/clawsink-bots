---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: sre-devops
  displayName: "SRE / DevOps Bot"
  version: "1.0.0"
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
  - ref: "skills/incident-triage@1.0.0"
  - ref: "skills/pipeline-monitoring@1.0.0"
  - ref: "skills/sla-compliance@1.0.0"
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
