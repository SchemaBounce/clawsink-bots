---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: legal
  displayName: Legal Practice
  version: "1.0.0"
  description: Law firm data kit covering matters, time entries, deadlines, documents, and trust accounts.
  category: industry
  tags:
    - legal
    - law-firm
    - practice-management
    - billing
    - deadlines
    - trust-accounts
    - litigation
  author: SchemaBounce
compatibility:
  teams:
    - legal-practice
  composableWith:
    - financial-ops
    - compliance-governance
entityPrefix: law_
entityCount: 5
graphEdgeTypes:
  - FILED_IN
  - CITES
  - DEADLINE_FOR
vectorCollections:
  - law_documents
---

# Legal Practice

A comprehensive data kit for small to mid-size law firms. Covers matter management, time tracking, court deadlines, document organization, and IOLTA/trust account compliance. Designed for general practice, litigation, family law, real estate, and business law firms.

## What's Included

- **Matters** — Client matters/cases with status, practice area, and billing details
- **Time Entries** — Attorney and paralegal billable and non-billable time records
- **Deadlines** — Court deadlines, statute of limitations, and filing dates
- **Documents** — Case documents with classification, versioning, and practice area tagging
- **Trust Accounts** — IOLTA/client trust account transactions for compliance tracking

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Billable Utilization Rate | 70-85% | Attorney productivity and revenue capacity |
| Realization Rate | >90% | Percentage of billed time actually collected |
| Collection Rate | >95% | Cash flow and billing effectiveness |
| Trust Account Compliance | 100% | State bar requirement, no exceptions |
| Statute of Limitations | Zero missed | Malpractice prevention |

## Graph Relationships

- **FILED_IN** links documents to the matter they belong to
- **CITES** links documents to other documents they reference or cite
- **DEADLINE_FOR** links deadlines to the matter they apply to

## Composability

Pairs naturally with:
- **financial-ops** — Connect matter billing to firm accounting
- **compliance-governance** — Extend trust account compliance to broader audit frameworks
