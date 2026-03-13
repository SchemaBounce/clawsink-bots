---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: consulting
  displayName: Management Consulting
  version: "1.0.0"
  description: "Engagement tracking, time entries, deliverables, and knowledge management for consulting firms"
  category: industry
  tags:
    - consulting
    - professional-services
    - time-tracking
    - knowledge-management
    - engagements
    - deliverables
  author: SchemaBounce
compatibility:
  teams:
    - consulting-firm
  composableWith:
    - crm-contacts
    - financial-ops
    - project-management
entityPrefix: "con_"
entityCount: 5
graphEdgeTypes:
  - CLIENT_OF
  - CREATED_FROM
  - USES
vectorCollections:
  - con_knowledge_artifacts
---

# Management Consulting

Full-stack data kit for management consulting firms covering the complete engagement lifecycle: client relationships, time tracking, deliverable management, and knowledge reuse.

## What's Included

- **Engagements** -- Active consulting projects with scope, timeline, and billing details
- **Time Entries** -- Consultant time tracking with billable/non-billable classification
- **Deliverables** -- Work products tied to engagements with approval workflows
- **Clients** -- Client organizations with contract and relationship history
- **Knowledge Artifacts** -- Reusable frameworks, templates, and methodologies

## Graph Relationships

- `CLIENT_OF` links engagements to their client organizations
- `CREATED_FROM` tracks which deliverables were built from knowledge artifacts
- `USES` connects engagements to the knowledge artifacts they leverage

## Semantic Search

Knowledge artifacts are vector-indexed by title, content summary, and methodology tags, enabling consultants to discover relevant prior work across the firm's collective expertise.

## Key Metrics

The memory bootstrap includes industry benchmarks for utilization rate (75-85% target), revenue per consultant, project margin, client satisfaction (NPS), and knowledge reuse rate.

## Composability

Pairs naturally with `crm-contacts` for client contact management, `financial-ops` for invoicing and revenue recognition, and `project-management` for Gantt-style milestone tracking.
