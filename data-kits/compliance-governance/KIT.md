---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: compliance-governance
  displayName: Compliance & Governance
  version: "1.0.0"
  description: Regulatory compliance kit covering controls, audit findings, policies, and regulatory change tracking.
  category: horizontal
  tags:
    - compliance
    - governance
    - audit
    - regulatory
    - risk-management
    - policies
  author: SchemaBounce
compatibility:
  teams: []
  composableWith:
    - healthcare-practice
    - legal-practice
    - manufacturing-ops
    - fintech-fraud-prevention
entityPrefix: gov_
entityCount: 4
graphEdgeTypes:
  - FINDING_FOR
  - SATISFIES
  - AFFECTS
vectorCollections:
  - gov_policies
  - gov_regulatory_changes
---

# Compliance & Governance

A horizontal data kit for managing regulatory compliance and governance programs. Tracks control frameworks, audit findings, policy lifecycle, and regulatory changes across any regulated industry.

## What's Included

- **Controls** -- Compliance controls mapped to frameworks (SOC 2, ISO 27001, HIPAA, PCI DSS, GDPR)
- **Audit Findings** -- Internal and external audit findings with remediation tracking
- **Policies** -- Organizational policies with approval workflows and review schedules
- **Regulatory Changes** -- Regulatory updates with impact assessment and response tracking

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Control Effectiveness Rate | >95% | Compliance posture strength |
| Audit Finding Closure Time | <30 days | Remediation responsiveness |
| Policy Review Frequency | Annual | Governance currency |
| Regulatory Change Response Time | <14 days | Proactive compliance |
| Compliance Score | >90% | Overall program health |
| Open Findings Count | Decreasing | Risk reduction trajectory |

## Graph Relationships

- **FINDING_FOR** links audit findings to the controls they relate to
- **SATISFIES** links controls to the regulatory requirements they address
- **AFFECTS** links regulatory changes to the policies they impact

## Composability

Pairs naturally with:
- **healthcare-practice** -- HIPAA compliance and patient data governance
- **legal-practice** -- Legal hold management and regulatory advisory
- **manufacturing-ops** -- Quality management system (QMS) compliance
- **fintech-fraud-prevention** -- PCI DSS and financial regulatory compliance
