---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: engineering
  displayName: Engineering
  version: "1.0.0"
  description: "Engineering operations data covering incidents, deployments, services, runbooks, tasks, sprints, and project risks for software teams"
  domain: engineering
  category: domain
  tags:
    - engineering
    - devops
    - sre
    - incidents
    - deployments
    - runbooks
    - sprints
    - product
    - software-development
  author: SchemaBounce
compatibility:
  teams:
    - engineering-team
  composableWith:
    - hr
    - finance
entityPrefix: "eng_"
entityCount: 7
graphEdgeTypes:
  - AFFECTS
  - DEPLOYED_TO
  - DEPENDS_ON
  - BLOCKED_BY
  - PART_OF
  - RUNS_ON
vectorCollections:
  - eng_incidents
  - eng_runbooks
---

# Engineering

A domain data kit for software engineering teams. Merges IT operations and project management coverage into a single cohesive set: incident lifecycle, deployment tracking, service catalog, runbooks, sprint planning, task management, and project risk tracking.

## What's Included

- **Incidents** - Production incidents with severity, timeline, root cause, and postmortem tracking
- **Deployments** - Release deployments with version, strategy, environment, and rollback data
- **Services** - Service catalog with health status, SLA targets, and ownership
- **Runbooks** - Operational runbooks searchable by symptom and service
- **Tasks** - Engineering work items with estimates, sprint assignment, and status
- **Sprints** - Time-boxed iterations with velocity and goal tracking
- **Risks** - Project risks with probability, impact, and mitigation plans

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| MTTR (Mean Time to Resolve) | <4 hours | Incident response effectiveness |
| Deployment Frequency | Daily+ | Delivery velocity |
| Change Failure Rate | <15% | Release quality |
| Service Availability | >99.9% | SLA compliance |
| Sprint Velocity | Stable trend | Predictable delivery |
| Blocked Task Ratio | <5% | Flow efficiency |
| On-Time Milestone Rate | >90% | Reliability to stakeholders |

## Graph Relationships

- **AFFECTS** links incidents to the services they impact
- **DEPLOYED_TO** links deployments to the services they update
- **DEPENDS_ON** links services to other services for blast radius analysis
- **BLOCKED_BY** links tasks to tasks that must complete first
- **PART_OF** links tasks to the sprints they belong to
- **RUNS_ON** links services to the infrastructure that hosts them

## Composability

Pairs with:
- **hr** - correlate team headcount and onboarding velocity with delivery throughput
- **finance** - map engineering spend to deployment frequency and incident cost
