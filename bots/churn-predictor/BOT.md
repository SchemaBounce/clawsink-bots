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
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 10000
  estimatedCostTier: "low"
trigger:
  entityType: "user_activity"
  eventType: "updated"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
data:
  entityTypesRead: ["user_activity", "engagement_metrics"]
  entityTypesWrite: ["churn_scores", "retention_alerts"]
  memoryNamespaces: ["activity_baselines", "churn_indicators"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["analytics"]
skills:
  - inline: "core-analysis"
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
