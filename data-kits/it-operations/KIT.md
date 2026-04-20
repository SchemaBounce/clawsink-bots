---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: it-operations
  displayName: IT Operations
  version: "1.0.0"
  description: IT operations kit covering incidents, deployments, services, and runbooks for SRE and DevOps teams.
  category: horizontal
  tags:
    - it-operations
    - devops
    - sre
    - incidents
    - deployments
    - runbooks
    - service-management
  author: SchemaBounce
compatibility:
  teams: []
  composableWith:
    - saas-growth
    - manufacturing-ops
entityPrefix: ops_
entityCount: 4
graphEdgeTypes:
  - AFFECTS
  - DEPLOYED_TO
  - DEPENDS_ON
vectorCollections:
  - ops_incidents
  - ops_runbooks
useCases:
  - "Open an incident, track the timeline, and write the postmortem in the same place"
  - "Record every deployment with service, version, and environment"
  - "Map services to their dependencies and on-call owner"
  - "Keep runbooks next to the services they apply to, searchable by symptom"
---

# IT Operations

A horizontal data kit for IT operations, site reliability engineering, and DevOps teams. Tracks the full incident lifecycle, deployment pipeline, service dependency mapping, and operational runbooks for SaaS platforms and infrastructure teams.

## What's Included

- **Incidents** -- Production incidents with severity, timeline, root cause, and resolution tracking
- **Deployments** -- Release deployments with status, rollback capability, and change tracking
- **Services** -- Service catalog with health status, SLA definitions, and dependency mapping
- **Runbooks** -- Operational runbooks with step-by-step procedures and automation status

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| MTTR (Mean Time to Resolve) | <4 hours | Incident response effectiveness |
| Deployment Frequency | Daily+ | Delivery velocity |
| Change Failure Rate | <15% | Release quality |
| Service Availability | >99.9% | SLA compliance |
| Incident Recurrence Rate | <10% | Root cause quality |
| Runbook Coverage | >80% | Operational readiness |

## Graph Relationships

- **AFFECTS** links incidents to the services they impact
- **DEPLOYED_TO** links deployments to the services they update
- **DEPENDS_ON** links services to other services for dependency and blast radius analysis

## Composability

Pairs naturally with:
- **saas-growth** -- Correlate uptime and deployment velocity with growth metrics
- **manufacturing-ops** -- Industrial system monitoring and operational procedures
