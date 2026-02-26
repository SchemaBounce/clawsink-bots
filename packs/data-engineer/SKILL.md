---
apiVersion: openclaw.schemabounce.com/v1
kind: SkillPack
metadata:
  name: data-engineer
  displayName: "Data Engineer"
  version: "1.0.0"
  description: "Monitors Kolumn schemas, CDC pipeline health, DLQ depth, and sink configuration drift."
  category: engineering
  tags: ["data", "schemas", "cdc", "pipelines", "kolumn", "drift"]
agent:
  capabilities: ["data_engineering", "dev_devops"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
  maxTokenBudget: 50000
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
data:
  entityTypesRead: ["pipeline_status", "sre_findings"]
  entityTypesWrite: ["de_findings", "de_alerts", "pipeline_status"]
  memoryNamespaces: ["working_notes", "learned_patterns", "thresholds"]
zones:
  zone1Read: ["mission", "tech_stack"]
  zone2Domains: ["engineering", "operations"]
requirements:
  minTier: "starter"
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
