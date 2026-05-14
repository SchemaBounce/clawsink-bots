---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: leadership
  displayName: "Leadership"
  version: "1.0.0"
  description: "Executive management data covering strategic goals, OKRs, executive briefings, and decision records"
  domain: leadership
  category: domain
  tags:
    - leadership
    - strategy
    - okrs
    - executive
    - briefings
    - decisions
  author: SchemaBounce
compatibility:
  teams:
    - leadership-team
  composableWith:
    - hr
    - product
    - operations
entityPrefix: "ldr_"
entityCount: 4
graphEdgeTypes:
  - SUPPORTS_GOAL
  - INFORMED_BY
vectorCollections:
  - ldr_exec_briefings
---

# Leadership

A domain data kit for executive and leadership teams tracking strategic goals, OKRs, consolidated briefings, and decision records. Provides the entity foundation for the Leadership team bots.

## What's Included

- **Strategic Goals** - long-horizon objectives with owners, timelines, and progress indicators
- **OKRs** - quarterly objectives and key results with progress tracking and status
- **Executive Briefings** - consolidated cross-functional briefings with key signals and action items
- **Decision Log** - records of significant decisions with context, rationale, and outcomes

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| OKR Achievement Rate | >70% green per quarter | Consistent under-achievement signals goal-setting or execution problems |
| Briefing Freshness | Daily for critical functions | Stale briefings leave leadership acting on outdated information |
| Decision Documentation Rate | >90% | Undocumented decisions create institutional knowledge gaps |
| Strategic Goal Progress | Review monthly | Lagging goals need early intervention, not quarter-end surprises |

## Graph Relationships

- `SUPPORTS_GOAL` links OKRs and decisions to the strategic goals they advance, enabling alignment tracing
- `INFORMED_BY` links decisions to the briefings or data sources that provided the supporting evidence

## Composability

Pairs with the HR People kit for headcount and organizational context, with the Product kit for roadmap alignment, and with the Operations kit for operational performance inputs into strategic briefings.
