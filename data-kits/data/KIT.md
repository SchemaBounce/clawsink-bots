---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: data
  displayName: "Data Engineering"
  version: "1.0.0"
  description: "Data platform metadata covering pipelines, quality checks, anomalies, schemas, and data lineage"
  domain: data
  category: domain
  tags:
    - data-engineering
    - pipelines
    - data-quality
    - anomaly-detection
    - schema-registry
    - lineage
  author: SchemaBounce
compatibility:
  teams:
    - data-team
  composableWith:
    - operations
    - product
entityPrefix: "dat_"
entityCount: 5
graphEdgeTypes:
  - DEPENDS_ON
  - DETECTED_IN
vectorCollections:
  - dat_schemas
---

# Data Engineering

A domain data kit for data engineering teams tracking pipeline health, quality check results, detected anomalies, schema definitions, and lineage relationships. Provides the entity foundation for the Data team bots.

## What's Included

- **Pipelines** - data pipeline definitions with source, sink, schedule, status, and health metrics
- **Quality Checks** - data quality rule executions with pass/fail results and row counts
- **Anomalies** - detected data anomalies with severity, affected pipeline, and resolution status
- **Schemas** - schema registry records with version history and compatibility status
- **Lineage Nodes** - data lineage graph nodes representing datasets, transforms, and endpoints

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Pipeline Success Rate | >99% | Failed pipelines cause data gaps downstream |
| Data Freshness | Within SLA per source | Stale data leads to bad decisions |
| Quality Check Pass Rate | >99.5% | Failures indicate upstream data problems |
| Anomaly Resolution Time | <4 hours for critical | Unresolved anomalies cascade into business impacts |
| Schema Compatibility Rate | 100% | Breaking schema changes can take down downstream consumers |

## Graph Relationships

- `DEPENDS_ON` links lineage nodes to their upstream dependencies, enabling impact analysis for schema changes or failures
- `DETECTED_IN` links anomaly records to the pipeline or quality check where they were found

## Composability

Pairs with the Operations kit to monitor operational data pipelines end-to-end, and with the Project Management kit for tracking data infrastructure improvement initiatives.
