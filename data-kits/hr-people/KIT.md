---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: hr-people
  displayName: HR & People
  version: "1.0.0"
  description: "People operations data, employees, onboarding, leave requests, performance reviews, and company policies"
  category: horizontal
  tags:
    - hr
    - human-resources
    - employees
    - onboarding
    - performance
    - leave
    - policies
    - people-ops
  author: SchemaBounce
compatibility:
  teams: []
  composableWith:
    - healthcare
    - consulting
    - manufacturing
entityPrefix: "hr_"
entityCount: 5
graphEdgeTypes:
  - REPORTS_TO
  - REVIEW_OF
vectorCollections:
  - hr_policies
useCases:
  - "Run onboarding as a checklist per new hire with assigned owners"
  - "Capture leave requests, approvals, and balances per employee"
  - "Record performance reviews on a cadence and link them to goals"
  - "Publish and version company policies, with acknowledgement tracking"
---

# HR & People

A horizontal people operations kit for companies of 20-200 employees. Covers the core HR entities: employee records, onboarding task tracking, leave management, performance reviews, and searchable company policies.

## What's Included

- **Employees** — staff records with department, role, compensation, and reporting structure
- **Onboarding Tasks** — checklist-driven new hire onboarding with assignment and deadline tracking
- **Leave Requests** — PTO, sick leave, and other absence requests with approval workflows
- **Performance Reviews** — periodic reviews with ratings, goals, and manager feedback
- **Policies** — company policies and handbooks with semantic search for employee self-service

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Employee Retention Rate | >90% annually | Retention is far cheaper than replacement |
| Time to Hire | <30 days | Measures recruiting efficiency |
| Onboarding Completion Rate | >95% within 30 days | Proper onboarding reduces early turnover |
| Leave Utilization | 70-90% of allowance | Under-utilization signals burnout risk |
| Performance Review Completion | >98% on schedule | Ensures feedback culture |
| Headcount Growth Rate | Track trend | Aligns hiring with business growth |

## Graph Relationships

- `REPORTS_TO` links employees to their managers, forming the org chart
- `REVIEW_OF` links performance reviews to the employees being reviewed

## Composability

Pairs with industry kits where people management is critical. Healthcare teams need it for credentialing and shift management. Consulting firms need it for utilization tracking. Manufacturing companies need it for safety training compliance.
