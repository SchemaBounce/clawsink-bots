---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: fintech-fraud-prevention
  displayName: "FinTech Fraud Prevention"
  version: "1.0.0"
  description: "Real-time fraud detection, compliance auditing, and anomaly monitoring for financial services."
  tags: ["fintech", "fraud", "compliance", "cdc"]
  targetMarket: "fintech"
bots:
  - fraud-detector
  - compliance-auditor
  - anomaly-detector
  - revenue-analyst
skills:
  - anomaly-detection
  - notification-dispatch
  - data-validation
requirements:
  minTier: "starter"
---

# FinTech Fraud Prevention

A complete fraud prevention team for financial services. Combines real-time transaction scoring, regulatory compliance checks, anomaly detection, and revenue analysis.

## Included Bots

- **Fraud Detector** — CDC-triggered, scores every new transaction
- **Compliance Auditor** — CDC-triggered, validates regulatory compliance
- **Anomaly Detector** — CDC-triggered, detects statistical anomalies in metrics
- **Revenue Analyst** — Scheduled daily, tracks revenue trends and forecasts

## Target Market

FinTech, payments, banking, and financial services companies that need real-time fraud detection with sub-second response times.
