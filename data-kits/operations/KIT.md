---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: operations
  displayName: "Operations"
  version: "1.0.0"
  description: "Core operations data covering inventory, orders, shipments, suppliers, and pricing rules"
  domain: operations
  category: domain
  tags:
    - operations
    - inventory
    - orders
    - shipments
    - suppliers
    - pricing
  author: SchemaBounce
compatibility:
  teams:
    - operations-team
  composableWith:
    - hr
    - product
entityPrefix: "ops_"
entityCount: 5
graphEdgeTypes:
  - SUPPLIED_BY
  - SHIPPED_VIA
vectorCollections:
  - ops_suppliers
---

# Operations

A domain data kit for operational teams managing inventory, order fulfillment, shipping, supplier relationships, and pricing. Provides the entity foundation for the Operations team bots.

## What's Included

- **Inventory** - stock levels by SKU with reorder points, location, and supplier linkage
- **Orders** - customer orders with fulfillment status, SLA tracking, and line items
- **Shipments** - outbound shipment records with carrier, tracking, and delivery status
- **Suppliers** - vendor profiles with lead times, reliability scores, and contract terms
- **Price Rules** - active pricing rules with conditions, margins, and effective dates

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Order Fulfillment Rate | >98% on time | SLA breaches erode customer trust |
| Inventory Accuracy | >99% | Inaccurate stock causes overselling and stock-outs |
| Supplier On-Time Delivery | >95% | Late supplier deliveries cascade into fulfillment failures |
| Shipment Exception Rate | <2% | Exceptions require manual intervention and customer communication |
| Gross Margin per SKU | Track trend | Margin erosion may require pricing or sourcing changes |

## Graph Relationships

- `SUPPLIED_BY` links inventory records to their supplier, enabling lead-time and reliability analysis
- `SHIPPED_VIA` links orders to their shipment records for end-to-end fulfillment tracing

## Composability

Pairs with the HR People kit for staffing-to-demand planning, and with the Project Management kit for operational improvement initiatives.
