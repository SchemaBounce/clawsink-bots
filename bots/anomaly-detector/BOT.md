---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: anomaly-detector
  displayName: "Anomaly Detector"
  version: "1.0.0"
  description: "Detects statistical anomalies in time-series metrics data."
  category: engineering
  tags: ["anomaly", "metrics", "monitoring", "cdc"]
agent:
  capabilities: ["anomaly_detection", "monitoring"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
  maxTokenBudget: 50000
trigger:
  entityType: "metrics"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
data:
  entityTypesRead: ["metrics", "alert_rules"]
  entityTypesWrite: ["anomaly_findings", "anomaly_alerts"]
  memoryNamespaces: ["metric_baselines", "detection_models"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Anomaly Detector

Detects anomalies in incoming metrics using statistical analysis. Identifies spikes, drops, trend breaks, and seasonal deviations.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
