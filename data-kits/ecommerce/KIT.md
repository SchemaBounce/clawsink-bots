---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: ecommerce
  displayName: E-Commerce Operations
  version: "1.0.0"
  description: Online retail data kit covering products, orders, customers, returns, and price history.
  category: industry
  tags:
    - ecommerce
    - retail
    - online-store
    - orders
    - products
    - returns
    - pricing
  author: SchemaBounce
compatibility:
  teams:
    - ecommerce-operations
  composableWith:
    - customer-feedback
    - financial-ops
entityPrefix: ec_
entityCount: 5
graphEdgeTypes:
  - ORDERED
  - CONTAINS
  - RETURN_OF
vectorCollections:
  - ec_products
useCases:
  - "Track every order from cart through fulfillment and return"
  - "Keep a running catalog with variants, stock, and current plus historical price"
  - "Segment customers by purchase frequency, LTV, and return rate"
  - "Flag products with high return rates for quality review"
---

# E-Commerce Operations

A full-stack data kit for online retail businesses. Covers the complete e-commerce lifecycle from product catalog through purchase, fulfillment, and returns. Designed for DTC brands, Shopify merchants, and online retailers who need AI-powered insights into conversion, pricing, and customer behavior.

## What's Included

- **Products** — Product catalog with pricing, inventory, categories, and tags
- **Orders** — Purchase orders with line items, shipping, and fulfillment status
- **Customers** — Customer profiles with acquisition channel and lifetime metrics
- **Returns** — Return and refund tracking with reason codes and resolution
- **Price History** — Historical price changes for competitive analysis and margin tracking

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| Conversion Rate | 2-4% | Site/funnel effectiveness |
| Cart Abandonment Rate | <70% | Checkout friction indicator |
| Return Rate | <10% | Product quality and description accuracy |
| Average Order Value | Varies by vertical | Revenue per transaction |
| Customer Lifetime Value | 3x acquisition cost | Long-term profitability |
| Inventory Turnover | 4-6x per year | Cash flow and demand alignment |

## Graph Relationships

- **ORDERED** links customers to products they have purchased (via orders)
- **CONTAINS** links orders to the specific products they include
- **RETURN_OF** links return records back to the original order

## Composability

Pairs naturally with:
- **customer-feedback** — Connect product reviews to purchase and return data
- **financial-ops** — Reconcile order revenue with accounting ledger
