---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: product
  displayName: "Product"
  version: "1.0.0"
  description: "Product management data covering features, experiments, sprints, user segments, and research sessions"
  domain: product
  category: domain
  tags:
    - product
    - features
    - experiments
    - sprints
    - user-research
    - segments
  author: SchemaBounce
compatibility:
  teams:
    - product-team
  composableWith:
    - hr
    - engineering
entityPrefix: "prd_"
entityCount: 5
graphEdgeTypes:
  - VALIDATED_BY
  - TARGETS_SEGMENT
vectorCollections:
  - prd_research_sessions
---

# Product

A domain data kit for product management teams tracking features, running experiments, managing sprints, understanding user segments, and synthesizing research. Provides the entity foundation for the Product team bots.

## What's Included

- **Features** - product feature records with status, priority, and roadmap positioning
- **Experiments** - A/B test definitions with hypothesis, variants, metrics, and results
- **Sprints** - time-boxed delivery iterations with velocity, goals, and completion tracking
- **User Segments** - defined audience groups with behavioral and demographic characteristics
- **Research Sessions** - user interview and usability test records with findings and insights

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Sprint Velocity Variance | <20% | High variance signals estimation or scope problems |
| Experiment Win Rate | Track trend | Win rate informs quality of hypotheses |
| Feature Cycle Time | Measure trend | Time from idea to shipped informs process efficiency |
| Research Coverage | >1 session per segment per quarter | Ensures decisions are grounded in real user signals |
| Sprint Rollover Rate | <15% | Frequent rollover erodes stakeholder trust in commitments |

## Graph Relationships

- `VALIDATED_BY` links features to the experiments that informed or validated their design
- `TARGETS_SEGMENT` links experiments and features to the user segments they are designed for

## Composability

Pairs with the HR People kit for team capacity context, and with the Project Management kit for milestone and risk tracking across the roadmap.
