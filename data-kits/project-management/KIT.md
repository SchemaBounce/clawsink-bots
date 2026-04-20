---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: project-management
  displayName: Project Management
  version: "1.0.0"
  description: Agile project management kit covering tasks, milestones, sprints, and risk tracking for software teams.
  category: horizontal
  tags:
    - project-management
    - agile
    - sprints
    - tasks
    - milestones
    - risk-management
  author: SchemaBounce
compatibility:
  teams: []
  composableWith:
    - consulting-firm
    - saas-growth
    - software-dev-team
entityPrefix: pm_
entityCount: 4
graphEdgeTypes:
  - BLOCKED_BY
  - PART_OF
  - DEPENDS_ON
vectorCollections:
  - pm_tasks
useCases:
  - "Plan a sprint from the backlog, move tasks across states, and chart burndown"
  - "Link tasks to milestones and surface anything blocked"
  - "Identify dependencies between work and schedule around them"
  - "Maintain a risk register with owner, probability, and mitigation"
---

# Project Management

A horizontal data kit for agile project management. Tracks tasks through sprints, organizes work into milestones, manages inter-task dependencies, and surfaces project risks before they become blockers.

## What's Included

- **Tasks** -- Work items with assignments, estimates, acceptance criteria, and status tracking
- **Milestones** -- Major project checkpoints with delivery dates and completion tracking
- **Sprints** -- Time-boxed iterations with velocity metrics and goal tracking
- **Risks** -- Project risks with probability, impact scoring, and mitigation plans

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Sprint Velocity | Stable trend | Predictability of delivery |
| On-Time Delivery Rate | >90% | Milestone reliability |
| Scope Creep Rate | <10% | Requirement discipline |
| Blocked Task Ratio | <5% | Flow efficiency |
| Bug-to-Feature Ratio | <20% | Technical debt indicator |
| Cycle Time | Decreasing | Process improvement signal |

## Graph Relationships

- **BLOCKED_BY** links tasks to other tasks that must complete first
- **PART_OF** links tasks to the milestones they contribute to
- **DEPENDS_ON** links milestones to other milestones for critical path analysis

## Composability

Pairs naturally with:
- **consulting-firm** -- Track client project delivery and engagement milestones
- **saas-growth** -- Align product development sprints with growth objectives
- **software-dev-team** -- Full development lifecycle with CI/CD integration
