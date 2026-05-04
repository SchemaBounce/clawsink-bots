---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: logistics-company
  displayName: "Logistics Company"
  version: "1.0.0"
  description: "AI operations team for logistics, warehousing, and 3PL. Manages shipment tracking, inventory across locations, order fulfillment SLAs, and cost-per-order optimization."
  category: logistics
  tags: ["logistics", "shipping", "warehousing", "fulfillment", "supply-chain", "starter"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
requirements:
  minTier: "starter"
bots:
  - ref: "bots/executive-reporter@1.0.0"
  - ref: "bots/accountant@1.0.0"
  - ref: "bots/inventory-manager@1.0.0"
  - ref: "bots/shipping-tracker@1.0.0"
  - ref: "bots/order-fulfillment@1.0.0"
  - ref: "bots/inventory-alert@1.0.0"
dataKits:
  - ref: "data-kits/logistics@1.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/financial-ops@1.0.0"
    required: false
    installSampleData: false
northStar:
  industry: "Logistics / Warehousing / 3PL"
  context: "Logistics companies, warehouses, or 3PL providers managing inbound/outbound shipments, inventory across locations, and order fulfillment SLAs"
  requiredKeys:
    - warehouse_locations
    - carrier_accounts
    - fulfillment_sla
    - inventory_categories
    - peak_seasons
orgChart:
  lead: executive-reporter
  domains:
    - name: "Warehouse"
      description: "Floor-level ops and daily operating reports"
      head: executive-reporter
      children:
        - name: "Inventory"
          description: "Stock levels, cycle counts, slot optimization"
          head: inventory-manager
          children:
            - name: "Alerts"
              description: "Low-stock / expiry / misplacement notifications"
              head: inventory-alert
    - name: "Shipping"
      description: "Carrier tracking, inbound + outbound trips"
      head: shipping-tracker
    - name: "Fulfillment"
      description: "Order picks, pack stations, dispatch"
      head: order-fulfillment
    - name: "Finance"
      description: "Freight cost, dwell time, margin per shipment"
      head: accountant
  roles:
    - bot: executive-reporter
      role: lead
      reportsTo: null
      domain: warehouse-ops
    - bot: accountant
      role: specialist
      reportsTo: executive-reporter
      domain: finance
    - bot: inventory-manager
      role: specialist
      reportsTo: executive-reporter
      domain: warehouse-ops
    - bot: shipping-tracker
      role: specialist
      reportsTo: executive-reporter
      domain: shipping
    - bot: order-fulfillment
      role: specialist
      reportsTo: executive-reporter
      domain: fulfillment
    - bot: inventory-alert
      role: support
      reportsTo: inventory-manager
      domain: warehouse-ops
  escalation:
    critical: executive-reporter
    unhandled: executive-reporter
    paths:
      - name: "Stock critical or discrepancy"
        trigger: "inventory_critical"
        chain: [inventory-alert, inventory-manager, executive-reporter]
      - name: "Shipment SLA breach"
        trigger: "shipping_exception"
        chain: [shipping-tracker, executive-reporter]
---
# Logistics Company

An AI operations team for the logistics floor. Whether you run a single warehouse, a multi-location 3PL, or a fulfillment operation, the daily reality is the same: orders come in faster than you can pick them, carriers miss pickups, inventory counts drift from system records, and one late shipment can cost you a client contract. This team gives you visibility across every moving part, literally.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Reporter | Daily ops dashboard, fulfillment rate, shipping exceptions, inventory turns, cost per order | @daily |
| Accountant | Carrier invoice reconciliation, shipping cost tracking, and margin per shipment | @daily |
| Inventory Manager | Stock levels across locations, reorder point management, and cycle count coordination | @every 4h |
| Shipping Tracker | Monitors all in-transit shipments, predicts delays, and flags carrier exceptions | @every 2h |
| Order Fulfillment | Validates incoming orders, routes to optimal warehouse, and tracks pick-pack-ship progress | @cdc |
| Inventory Alert | Fires on low stock, overstock, slow-moving SKUs, and inventory discrepancies | @cdc |

## How They Work Together

Logistics operations are a continuous cycle: orders arrive, inventory gets allocated, items get picked and packed, shipments go out, and the whole thing needs to happen within your SLA window. Every bot in this team handles a link in that chain.

Order Fulfillment is the trigger point. When a new order comes in, it validates the order details, checks stock availability across warehouse locations via Inventory Manager, and routes the order to the optimal fulfillment location based on proximity to the delivery address and current stock. If an item is available in two warehouses, it picks the one that meets the SLA with the lowest shipping cost. If stock is insufficient, it immediately notifies Inventory Alert.

Inventory Manager maintains the system of record for stock across all locations. It tracks inbound receipts, outbound allocations, transfers between locations, and manages reorder points based on velocity. In a multi-location operation, knowing where your stock actually is, not just that you have it somewhere, is the difference between same-day fulfillment and a three-day delay. It coordinates cycle counts to catch discrepancies before they cause fulfillment failures.

Inventory Alert acts on exceptions. Low stock against reorder points, overstock tying up warehouse space, slow-moving SKUs that should be liquidated or redistributed, and inventory count discrepancies that suggest shrinkage or receiving errors. Each alert includes the specific SKU, location, current quantity, and recommended action.

Shipping Tracker monitors every package from label creation to delivery confirmation. It pulls tracking data from carrier accounts, identifies shipments that are falling behind their estimated delivery window, and flags exceptions, address corrections needed, customs holds, failed delivery attempts, carrier facility delays. Predicted late deliveries get surfaced before they actually miss the SLA, giving your team time to proactively contact the customer or escalate with the carrier.

Accountant handles the financial side of moving goods. Carrier invoices get reconciled against expected rates, surcharges, dimensional weight adjustments, and accessorial fees are compared to contracted rates. It calculates true cost per shipment and margin per order, identifying which carrier lanes are profitable and which are bleeding money.

Executive Reporter compiles the daily operations dashboard from all bots: fulfillment rate against SLA, number of shipping exceptions, inventory turn rate, cost per order trend, and any critical alerts. This is the single view that tells a logistics operator whether today was a good day or a fire drill.

**Communication flow:**
- Order Fulfillment receives new order -> stock check to Inventory Manager, routing decision based on location and SLA
- Order Fulfillment detects insufficient stock -> alert to Inventory Alert and Executive Reporter
- Inventory Manager identifies reorder point breach -> alert to Inventory Alert
- Inventory Alert fires on low stock, overstock, or discrepancy -> alert to Executive Reporter
- Shipping Tracker predicts late delivery or detects carrier exception -> alert to Executive Reporter
- Accountant identifies carrier invoice discrepancy or margin issue -> finding to Executive Reporter
- Executive Reporter compiles daily ops dashboard from all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `warehouse_locations`, `carrier_accounts`, `fulfillment_sla`, `inventory_categories`, `peak_seasons`
3. Bots begin running on their default schedules automatically
4. Check Executive Reporter's daily dashboards for a consolidated operations view
