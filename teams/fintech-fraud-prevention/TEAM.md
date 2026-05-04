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
orgChart:
  lead: fraud-detector
  domains:
    - name: "Fraud Detection"
      description: "Real-time transaction scoring and alert routing"
      head: fraud-detector
      children:
        - name: "Anomalies"
          description: "Statistical outlier detection on spend patterns"
          head: anomaly-detector
    - name: "Compliance"
      description: "Regulatory checks, KYC/AML, audit trails"
      head: compliance-auditor
      children:
        - name: "Finance"
          description: "Revenue impact analysis of fraud + chargebacks"
          head: revenue-analyst
  roles:
    - bot: fraud-detector
      role: lead
      reportsTo: null
      domain: fraud-detection
    - bot: compliance-auditor
      role: specialist
      reportsTo: fraud-detector
      domain: compliance
    - bot: anomaly-detector
      role: specialist
      reportsTo: fraud-detector
      domain: fraud-detection
    - bot: revenue-analyst
      role: support
      reportsTo: compliance-auditor
      domain: finance
  escalation:
    critical: fraud-detector
    unhandled: fraud-detector
    paths:
      - name: "Fraud alert"
        trigger: "fraud_alert"
        chain: [anomaly-detector, fraud-detector]
      - name: "Compliance violation"
        trigger: "compliance_violation"
        chain: [compliance-auditor, fraud-detector]
---

# FinTech Fraud Prevention

A complete fraud prevention team for financial services. Combines real-time transaction scoring, regulatory compliance checks, anomaly detection, and revenue analysis.

## Included Bots

- **Fraud Detector**: CDC-triggered, scores every new transaction
- **Compliance Auditor**: CDC-triggered, validates regulatory compliance
- **Anomaly Detector**: CDC-triggered, detects statistical anomalies in metrics
- **Revenue Analyst**: Scheduled daily, tracks revenue trends and forecasts

## Target Market

FinTech, payments, banking, and financial services companies that need real-time fraud detection with sub-second response times.
