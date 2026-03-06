---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: fraud-detector
  displayName: "Fraud Detector"
  version: "1.0.0"
  description: "Scores new transactions for fraud risk using pattern analysis and anomaly detection."
  category: fintech
  tags: ["fraud", "transactions", "risk", "cdc"]
agent:
  capabilities: ["fraud_detection", "risk_analysis"]
  hostingMode: "openclaw"
  defaultDomain: "finance"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 6000
  estimatedCostTier: "low"
trigger:
  entityType: "transactions"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["compliance-auditor"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "high-risk fraud detected" }
    - { type: "finding", to: ["compliance-auditor"], when: "suspicious pattern identified" }
data:
  entityTypesRead: ["transactions", "fraud_rules"]
  entityTypesWrite: ["fraud_scores", "fraud_alerts"]
  memoryNamespaces: ["fraud_patterns", "risk_thresholds"]
zones:
  zone1Read: ["mission", "risk_policy"]
  zone2Domains: ["finance"]
skills:
  - ref: "skills/cdc-event-analysis@1.0.0"
requirements:
  minTier: "starter"
---

# Fraud Detector

Scores incoming transactions for fraud risk in real-time. Analyzes transaction patterns, amounts, frequencies, and geographic anomalies to flag suspicious activity.

## What It Does

- Scores each new transaction against learned fraud patterns
- Detects velocity anomalies (unusual frequency or amounts)
- Flags geographic inconsistencies
- Maintains evolving fraud pattern database
- Escalates high-risk transactions immediately

## Escalation Behavior

- **Critical**: High confidence fraud → alert executive-assistant
- **High**: Suspicious pattern → finding to compliance-auditor
- **Medium**: Elevated risk score → logged as fraud_scores
- **Low**: Normal transaction → no action
