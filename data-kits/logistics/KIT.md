---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: logistics
  displayName: Logistics & Fulfillment
  version: "1.0.0"
  description: "Shipment tracking, warehouse inventory, carrier management, and fulfillment operations for logistics companies"
  category: industry
  tags:
    - logistics
    - fulfillment
    - warehouse
    - shipping
    - inventory
    - supply-chain
    - carriers
  author: SchemaBounce
compatibility:
  teams:
    - logistics-company
  composableWith:
    - financial-ops
entityPrefix: "log_"
entityCount: 5
graphEdgeTypes:
  - SHIPPED_VIA
  - FULFILLED_FROM
vectorCollections: []
useCases:
  - "Track each shipment from pickup through delivery with every status change"
  - "Manage warehouse inventory by bin, with cycle counts and transfers"
  - "Compare carrier rates and on-time performance per lane"
  - "Measure fulfillment throughput and exception rate"
---

# Logistics & Fulfillment

Full-stack data kit for e-commerce fulfillment warehouses, 3PL providers, and logistics companies covering the complete order-to-delivery lifecycle: inbound receiving, warehouse inventory, fulfillment, carrier selection, and shipment tracking.

## What's Included

- **Shipments** -- Outbound shipment tracking with carrier, tracking number, and delivery status
- **Warehouse Stock** -- Real-time inventory positions by SKU, location, and lot
- **Carriers** -- Carrier profiles with service levels, rates, and performance metrics
- **Fulfillment Orders** -- Customer orders queued for picking, packing, and shipping
- **Receiving** -- Inbound receiving records for purchase orders and returns

## Graph Relationships

- `SHIPPED_VIA` links shipments to their carrier, enabling carrier performance analysis
- `FULFILLED_FROM` connects fulfillment orders to the warehouse stock positions used to fill them

## Key Metrics

The memory bootstrap includes industry benchmarks for on-time delivery rate (target >95%), warehouse utilization, order accuracy, average shipping cost, receiving cycle time, and pick/pack efficiency.

## Composability

Pairs naturally with `financial-ops` for shipping cost accounting, invoice reconciliation, and carrier payment management.
