---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: construction
  displayName: Residential Construction
  version: "1.0.0"
  description: "Project management, estimating, materials tracking, crew scheduling, and safety for construction companies"
  category: industry
  tags:
    - construction
    - residential
    - estimating
    - materials
    - crew-scheduling
    - safety
    - trades
  author: SchemaBounce
compatibility:
  teams:
    - tradesman-pack
  composableWith:
    - crm-contacts
    - financial-ops
entityPrefix: "bld_"
entityCount: 5
graphEdgeTypes:
  - ESTIMATE_FOR
  - USED_IN
vectorCollections: []
useCases:
  - "Estimate a job from takeoffs and labor rates, then compare to actual cost"
  - "Track material orders, deliveries, and on-site inventory per project"
  - "Schedule crews across jobs and flag conflicts"
  - "Log safety incidents, inspections, and toolbox-talk attendance"
---

# Residential Construction

Full-stack data kit for residential construction companies, general contractors, and home builders covering the complete project lifecycle: estimating, materials procurement, crew scheduling, project tracking, and safety compliance.

## What's Included

- **Projects** -- Construction projects with phases, timeline, budget, and status tracking
- **Estimates** -- Detailed cost estimates with labor, materials, and markup calculations
- **Materials** -- Material inventory and procurement tracking with supplier details
- **Crew Schedule** -- Daily crew assignments with trade, location, and hours
- **Safety Items** -- Safety observations, incidents, and compliance tracking

## Graph Relationships

- `ESTIMATE_FOR` links estimates to their associated project for cost tracking and variance analysis
- `USED_IN` connects materials to the projects consuming them for cost allocation and waste tracking

## Key Metrics

The memory bootstrap includes industry benchmarks for project gross margin (target 20-35%), change order rate, safety incident rate (target 0), material waste percentage, labor utilization, and schedule variance.

## Composability

Pairs with `crm-contacts` for client and subcontractor relationship management, and `financial-ops` for invoicing, progress billing, and job costing.
