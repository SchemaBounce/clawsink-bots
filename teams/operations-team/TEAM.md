---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: operations-team
  displayName: "Operations"
  version: "1.0.0"
  description: "End-to-end operations automation covering order fulfillment, inventory, shipping, pricing, and workflow coordination"
  domain: operations
  category: operations
  tags: ["operations", "inventory", "fulfillment", "shipping", "pricing", "workflows"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/order-fulfillment@1.0.0"
  - ref: "bots/inventory-manager@1.0.0"
  - ref: "bots/inventory-alert@1.0.0"
  - ref: "bots/shipping-tracker@1.0.0"
  - ref: "bots/price-optimizer@1.0.0"
  - ref: "bots/workflow-designer@1.0.0"
dataKits:
  - ref: "data-kits/operations@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Operations"
  context: "Operations team automating order fulfillment, inventory management, shipping logistics, and pricing strategy"
  requiredKeys:
    - fulfillment_sla_hours
    - reorder_lead_time_days
    - low_stock_threshold_units
    - carrier_accounts
    - pricing_strategy
orgChart:
  lead: order-fulfillment
  domains:
    - name: "Fulfillment"
      description: "Order processing, picking, packing, and dispatch coordination"
      head: order-fulfillment
      children:
        - name: "Shipping"
          description: "Carrier selection, tracking, and delivery monitoring"
          head: shipping-tracker
    - name: "Inventory"
      description: "Stock levels, replenishment, and supplier coordination"
      head: inventory-manager
      children:
        - name: "Alerts"
          description: "Low-stock detection, critical threshold notifications"
          head: inventory-alert
    - name: "Pricing"
      description: "Dynamic pricing rules, margin analysis, and competitive adjustments"
      head: price-optimizer
    - name: "Automation"
      description: "Workflow design and cross-function process orchestration"
      head: workflow-designer
  roles:
    - bot: order-fulfillment
      role: lead
      reportsTo: null
      domain: fulfillment
    - bot: inventory-manager
      role: specialist
      reportsTo: order-fulfillment
      domain: inventory
    - bot: inventory-alert
      role: support
      reportsTo: inventory-manager
      domain: inventory
    - bot: shipping-tracker
      role: specialist
      reportsTo: order-fulfillment
      domain: fulfillment
    - bot: price-optimizer
      role: specialist
      reportsTo: order-fulfillment
      domain: pricing
    - bot: workflow-designer
      role: support
      reportsTo: order-fulfillment
      domain: fulfillment
  escalation:
    critical: order-fulfillment
    unhandled: order-fulfillment
    paths:
      - name: "Fulfillment SLA Breach"
        trigger: "fulfillment_sla_breach"
        chain: [order-fulfillment]
      - name: "Critical Stock Out"
        trigger: "stock_critical"
        chain: [inventory-alert, inventory-manager, order-fulfillment]
      - name: "Shipping Exception"
        trigger: "shipping_exception"
        chain: [shipping-tracker, order-fulfillment]
      - name: "Margin Erosion"
        trigger: "margin_critical"
        chain: [price-optimizer, order-fulfillment]
---
# Operations

Six bots covering the full operations lifecycle: order fulfillment coordination, inventory management, stock alerting, shipment tracking, price optimization, and workflow automation.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Order Fulfillment | Lead coordinator, SLA monitoring, dispatch oversight | @every 1h |
| Inventory Manager | Stock levels, replenishment, supplier coordination | @every 2h |
| Inventory Alert | Low-stock detection, critical threshold notifications | @every 30m |
| Shipping Tracker | Carrier monitoring, delivery status, exception handling | @every 1h |
| Price Optimizer | Dynamic pricing rules, margin analysis, competitive pricing | @daily |
| Workflow Designer | Cross-function process automation and orchestration | @on_demand |

## How They Work Together

Order Fulfillment acts as the central coordinator for all operational activity. Inventory Manager tracks stock levels and coordinates replenishment with suppliers, with Inventory Alert watching for threshold breaches in real time. Shipping Tracker monitors active shipments and surfaces delivery exceptions to Order Fulfillment for action. Price Optimizer analyzes margins and competitive signals daily, feeding pricing recommendations upstream. Workflow Designer automates recurring cross-function processes and can be invoked on demand for custom orchestration.

**Communication flow:**
- Inventory Alert detects low stock -> alert to Inventory Manager
- Inventory Alert detects critical stock out -> alert to Order Fulfillment
- Inventory Manager triggers reorder -> finding to Order Fulfillment
- Shipping Tracker detects exception -> alert to Order Fulfillment
- Price Optimizer identifies margin risk -> finding to Order Fulfillment
- Order Fulfillment coordinates fulfillment action -> request to Shipping Tracker
- Workflow Designer surfaces automation opportunities -> finding to Order Fulfillment

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `fulfillment_sla_hours`, `reorder_lead_time_days`, `low_stock_threshold_units`, `carrier_accounts`, `pricing_strategy`
3. Bots begin running on their default schedules automatically
4. Check Order Fulfillment's briefings for consolidated operations status
