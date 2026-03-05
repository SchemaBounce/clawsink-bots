---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: data-quality-monitor
  displayName: "Data Quality Monitor"
  version: "1.0.0"
  description: "Validates data quality rules on incoming records across all entity types."
  category: engineering
  tags: ["data-quality", "validation", "cdc"]
agent:
  capabilities: ["data_quality", "validation"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
trigger:
  entityType: "*"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
data:
  entityTypesRead: ["*"]
  entityTypesWrite: ["dq_findings", "dq_scores"]
  memoryNamespaces: ["quality_rules", "baseline_stats"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Data Quality Monitor

Validates data quality in real-time as records arrive. Checks completeness, consistency, format compliance, and referential integrity.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
