---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: legal-compliance
  displayName: Legal & Compliance
  version: "1.0.0"
  description: "Legal and compliance data covering matters, controls, policies, audit findings, deadlines, and regulatory changes for in-house legal and compliance teams"
  domain: legal-compliance
  category: domain
  tags:
    - legal
    - compliance
    - audit
    - regulatory
    - governance
    - risk-management
    - policies
    - matters
    - controls
  author: SchemaBounce
compatibility:
  teams:
    - legal-compliance-team
  composableWith:
    - finance
    - hr
entityPrefix: "leg_"
entityCount: 6
graphEdgeTypes:
  - FINDING_FOR
  - SATISFIES
  - AFFECTS
  - DEADLINE_FOR
vectorCollections:
  - leg_policies
  - leg_regulatory_changes
---

# Legal & Compliance

A domain data kit for in-house legal and compliance teams. Merges matter management and compliance governance into a unified data foundation: legal matters, compliance controls, policies, audit findings, deadlines, and regulatory change tracking.

## What's Included

- **Matters** - Legal matters and cases with status, practice area, billing, and attorney assignment
- **Controls** - Compliance controls mapped to frameworks (SOC 2, ISO 27001, HIPAA, PCI DSS, GDPR)
- **Policies** - Organizational policies with approval workflows and review schedules
- **Audit Findings** - Internal and external audit findings with remediation tracking
- **Deadlines** - Court dates, regulatory deadlines, and statute of limitations with alert thresholds
- **Regulatory Changes** - Regulatory updates with impact assessment and response tracking

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Control Effectiveness Rate | >95% | Compliance posture strength |
| Audit Finding Closure Time | <30 days | Remediation responsiveness |
| Statute of Limitations Miss Rate | 0% | Malpractice and penalty prevention |
| Policy Review Currency | 100% reviewed on schedule | Governance discipline |
| Regulatory Change Response Time | <14 days initial assessment | Proactive compliance |
| Open Critical Findings | Decreasing trend | Risk reduction trajectory |

## Graph Relationships

- **FINDING_FOR** links an audit finding to the control it relates to
- **SATISFIES** links a control to the regulatory requirement it addresses
- **AFFECTS** links a regulatory change to the policies it impacts
- **DEADLINE_FOR** links a deadline to the matter it applies to

## Composability

Pairs with:
- **finance** - connect contract disputes and fraud findings to financial impact tracking
- **hr** - link employment matters, workplace compliance, and policy acknowledgment
