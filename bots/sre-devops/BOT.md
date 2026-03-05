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
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
  maxTokenBudget: 50000
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
    - { type: "finding", to: ["business-analyst"], when: "anomaly detected or trend identified" }
    - { type: "finding", to: ["data-engineer"], when: "pipeline infrastructure issue" }
data:
  entityTypesRead: ["pipeline_status", "incidents", "infrastructure_metrics", "de_findings"]
  entityTypesWrite: ["sre_findings", "sre_alerts", "incidents"]
  memoryNamespaces: ["working_notes", "learned_patterns", "thresholds"]
zones:
  zone1Read: ["mission", "tech_stack", "sla_targets"]
  zone2Domains: ["operations", "infrastructure"]
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
