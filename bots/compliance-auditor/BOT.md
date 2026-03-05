---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: compliance-auditor
  displayName: "Compliance Auditor"
  version: "1.0.0"
  description: "Checks regulatory compliance on new financial records."
  category: fintech
  tags: ["compliance", "audit", "regulatory", "cdc"]
agent:
  capabilities: ["compliance", "regulatory"]
  hostingMode: "openclaw"
  defaultDomain: "compliance"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 10000
  estimatedCostTier: "low"
trigger:
  entityType: "financial_records"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
data:
  entityTypesRead: ["financial_records", "compliance_rules"]
  entityTypesWrite: ["audit_findings", "compliance_reports"]
  memoryNamespaces: ["regulatory_frameworks", "audit_history"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["compliance"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Compliance Auditor

Audits new financial records for regulatory compliance. Checks against configured regulatory frameworks and flags violations.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
