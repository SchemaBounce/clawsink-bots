---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: ecommerce-operations
  displayName: "E-Commerce Operations"
  version: "1.0.0"
  description: "End-to-end e-commerce operations: inventory, orders, pricing, and shipping."
  tags: ["ecommerce", "operations", "inventory", "cdc"]
  targetMarket: "ecommerce"
bots:
  - inventory-alert
  - order-fulfillment
  - price-optimizer
  - shipping-tracker
skills:
  - notification-dispatch
  - trend-analysis
requirements:
  minTier: "starter"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    reason: "Marketplace and platform OAuth for inventory-alert, order-fulfillment, and price-optimizer"
    config:
      scopes: ["marketplace", "orders", "inventory"]
orgChart:
  lead: order-fulfillment
  roles:
    - bot: order-fulfillment
      role: lead
      reportsTo: null
      domain: fulfillment
    - bot: inventory-alert
      role: specialist
      reportsTo: order-fulfillment
      domain: storefront
    - bot: price-optimizer
      role: specialist
      reportsTo: order-fulfillment
      domain: storefront
    - bot: shipping-tracker
      role: support
      reportsTo: order-fulfillment
      domain: customer-ops
  escalation:
    critical: order-fulfillment
    unhandled: order-fulfillment
    paths:
      - name: "Stockout Risk"
        trigger: "low_inventory"
        chain: [inventory-alert, order-fulfillment]
      - name: "Shipping Delay"
        trigger: "shipment_delayed"
        chain: [shipping-tracker, order-fulfillment]
      - name: "Price Anomaly"
        trigger: "price_anomaly"
        chain: [price-optimizer, order-fulfillment]
---

# E-Commerce Operations

A complete operations team for e-commerce businesses. Handles inventory management, order fulfillment, competitive pricing, and shipment tracking — all triggered by real-time data changes.

## Included Bots

- **Inventory Alert** — CDC-triggered on inventory updates, prevents stockouts
- **Order Fulfillment** — CDC-triggered on new orders, orchestrates processing
- **Price Optimizer** — CDC-triggered on market price changes
- **Shipping Tracker** — CDC-triggered on shipment status updates

## Target Market

E-commerce, retail, and marketplace businesses needing automated operations.
