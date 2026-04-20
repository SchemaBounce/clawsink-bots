---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: healthcare
  displayName: Healthcare Practice
  version: "1.0.0"
  description: Medical practice data kit covering patients, appointments, claims, compliance, and staff credentials.
  category: industry
  tags:
    - healthcare
    - medical
    - practice-management
    - hipaa
    - compliance
    - claims
    - credentialing
  author: SchemaBounce
compatibility:
  teams:
    - healthcare-practice
  composableWith:
    - compliance-governance
    - financial-ops
    - hr-people
entityPrefix: hc_
entityCount: 5
graphEdgeTypes:
  - SEEN_BY
  - FILED_FOR
  - REQUIRED_BY
vectorCollections:
  - hc_compliance_items
useCases:
  - "Book appointments and manage a day-of schedule per provider"
  - "File claims, track denials, and rework them through resubmission"
  - "Log compliance items (HIPAA, OSHA) with owner and next review date"
  - "Track provider credentials and license expirations"
---

# Healthcare Practice

A comprehensive data kit for small to mid-size medical practices, clinics, and healthcare groups. Covers the core operational data needed for patient scheduling, insurance claims processing, regulatory compliance tracking, and staff credential management.

## What's Included

- **Patients** — Patient demographics with insurance and contact information
- **Appointments** — Scheduling with visit type, provider assignment, and status tracking
- **Claims** — Insurance claims with CPT codes, amounts, and denial tracking
- **Compliance Items** — HIPAA, OSHA, and regulatory compliance checklist items
- **Staff Credentials** — Provider licenses, certifications, and expiration tracking

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Patient Wait Time | <15 min | Patient satisfaction and throughput |
| No-Show Rate | <10% | Revenue loss prevention |
| Claim Denial Rate | <5% | Revenue cycle efficiency |
| Credential Expiry Alerts | 90 days advance | Legal compliance and payer requirements |
| HIPAA Compliance Score | 100% | Regulatory requirement, audit readiness |

## Graph Relationships

- **SEEN_BY** links patients to the staff/providers who treated them
- **FILED_FOR** links insurance claims to the patient they were filed for
- **REQUIRED_BY** links compliance items to staff credentials that need them

## Composability

Pairs naturally with:
- **compliance-governance** — Extend compliance tracking to SOX, PCI, or custom frameworks
- **financial-ops** — Connect claims revenue to practice accounting
- **hr-people** — Full HR lifecycle for clinical and administrative staff
