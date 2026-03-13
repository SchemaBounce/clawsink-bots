---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: fitness
  displayName: Fitness Studio
  version: "1.0.0"
  description: "Member management, class scheduling, attendance tracking, and membership billing for fitness studios"
  category: industry
  tags:
    - fitness
    - gym
    - studio
    - memberships
    - classes
    - attendance
    - health
  author: SchemaBounce
compatibility:
  teams:
    - fitness-studio
  composableWith:
    - crm-contacts
    - customer-feedback
entityPrefix: "fit_"
entityCount: 4
graphEdgeTypes:
  - ATTENDS
  - HAS_MEMBERSHIP
vectorCollections: []
---

# Fitness Studio

Full-stack data kit for boutique fitness studios, gyms, and wellness centers covering member lifecycle, class scheduling, attendance tracking, and membership management.

## What's Included

- **Members** -- Member profiles with fitness goals, health details, and engagement status
- **Classes** -- Class schedule with instructor assignments, capacity, and category
- **Attendance** -- Per-class check-in records linking members to classes
- **Memberships** -- Membership plans with billing, duration, and status tracking

## Graph Relationships

- `ATTENDS` links members to classes through attendance records, enabling analysis of class popularity and member engagement patterns
- `HAS_MEMBERSHIP` connects members to their active membership plans

## Key Metrics

The memory bootstrap includes industry benchmarks for member retention (target >80%), class utilization (target 70%), average revenue per member, membership churn rate, and peak hour capacity management.

## Composability

Pairs with `crm-contacts` for lead tracking and prospect management, and `customer-feedback` for NPS surveys and member satisfaction analysis.
