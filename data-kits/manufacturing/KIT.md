---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: manufacturing
  displayName: Manufacturing Operations
  version: "1.0.0"
  description: "Production runs, quality control, bill of materials, equipment management, and raw materials for manufacturers"
  category: industry
  tags:
    - manufacturing
    - production
    - quality-control
    - bom
    - equipment
    - oee
    - inventory
  author: SchemaBounce
compatibility:
  teams:
    - manufacturing-ops
  composableWith:
    - it-operations
    - compliance-governance
entityPrefix: "mfg_"
entityCount: 5
graphEdgeTypes:
  - COMPONENT_OF
  - CHECKED
  - USES_EQUIPMENT
vectorCollections: []
---

# Manufacturing Operations

Full-stack data kit for small-to-mid-sized manufacturers covering the complete production lifecycle: bill of materials, raw material inventory, production run tracking, quality control, and equipment management.

## What's Included

- **Production Runs** -- Scheduled and active production runs with quantity, status, and output tracking
- **Quality Checks** -- In-process and final quality inspection records with pass/fail and defect categorization
- **Bill of Materials** -- Product BOMs with component lists, quantities, and assembly instructions
- **Equipment** -- Production equipment inventory with maintenance schedules and uptime tracking
- **Raw Materials** -- Raw material inventory with supplier, lot traceability, and reorder management

## Graph Relationships

- `COMPONENT_OF` links raw materials to bill of materials entries, enabling material requirement planning
- `CHECKED` connects quality checks to the production runs they inspect
- `USES_EQUIPMENT` links production runs to the equipment used, enabling utilization and maintenance correlation

## Key Metrics

The memory bootstrap includes industry benchmarks for OEE (overall equipment effectiveness, target >85%), defect rate (target <1%), first pass yield, cycle time, scrap rate, and machine uptime.

## Composability

Pairs with `it-operations` for production system monitoring and alerting, and `compliance-governance` for regulatory compliance tracking (ISO 9001, FDA, etc.).
