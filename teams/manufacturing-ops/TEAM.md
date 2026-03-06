---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: manufacturing-ops
  displayName: "Manufacturing Ops"
  version: "1.0.0"
  description: "Production line operations: inventory, quality, fulfillment, logistics, and system reliability for manufacturers."
  category: manufacturing
  tags: ["manufacturing", "production", "quality", "supply-chain", "ops", "scale"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-reporter@1.0.0"
  - ref: "bots/inventory-manager@1.0.0"
  - ref: "bots/inventory-alert@1.0.0"
  - ref: "bots/order-fulfillment@1.0.0"
  - ref: "bots/shipping-tracker@1.0.0"
  - ref: "bots/data-quality-monitor@1.0.0"
  - ref: "bots/sre-devops@1.0.0"
requirements:
  minTier: "scale"
northStar:
  industry: "Manufacturing / Production"
  context: "Manufacturers managing production lines, raw material inventory, quality control, and outbound logistics"
  requiredKeys:
    - product_lines
    - raw_materials
    - production_capacity
    - quality_standards
    - supplier_base
    - shipping_regions
orgChart:
  lead: executive-reporter
  roles:
    - bot: executive-reporter
      role: lead
      reportsTo: null
      domain: production
    - bot: inventory-manager
      role: specialist
      reportsTo: executive-reporter
      domain: production
    - bot: inventory-alert
      role: support
      reportsTo: inventory-manager
      domain: production
    - bot: order-fulfillment
      role: specialist
      reportsTo: executive-reporter
      domain: logistics
    - bot: shipping-tracker
      role: specialist
      reportsTo: executive-reporter
      domain: logistics
    - bot: data-quality-monitor
      role: support
      reportsTo: sre-devops
      domain: quality
    - bot: sre-devops
      role: specialist
      reportsTo: executive-reporter
      domain: systems
  escalation:
    critical: executive-reporter
    unhandled: executive-reporter
    paths:
      - name: "Raw material shortage"
        trigger: "material_stockout_risk"
        chain: [inventory-alert, inventory-manager, executive-reporter]
      - name: "Production data integrity"
        trigger: "sensor_drift_detected"
        chain: [data-quality-monitor, sre-devops, executive-reporter]
      - name: "Shipment delay"
        trigger: "inbound_delivery_late"
        chain: [shipping-tracker, inventory-manager, executive-reporter]
---
# Manufacturing Ops

A production-focused operations team for manufacturers. Seven bots monitor the full production chain from raw material intake through finished goods shipment. Built for operations where a stockout halts the line, bad sensor data means bad product, and late shipments mean lost contracts.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Reporter | Daily production dashboard: output, quality, materials, shipments | @daily |
| Inventory Manager | Raw materials and finished goods tracking across production stages | @every 4h |
| Inventory Alert | Raw material shortage detection -- the most critical alert in manufacturing | @every 1h |
| Order Fulfillment | Customer orders against production schedules and available stock | @every 4h |
| Shipping Tracker | Outbound logistics and inbound raw material deliveries | @every 2h |
| Data Quality Monitor | Production data integrity: sensor readings, batch records, yield calculations | @every 4h |
| SRE & DevOps | Production line systems, SCADA/IoT infrastructure, MES uptime | @every 1h |

## How They Work Together

Manufacturing is unforgiving. When the line stops, everything stops -- and every minute of downtime has a direct cost. These bots mirror the operational reality of a production floor where raw materials, equipment, data, and logistics all have to work in sync.

Inventory Manager tracks raw materials and finished goods across every production stage -- receiving, work-in-progress, and finished goods ready to ship. Inventory Alert is the fire alarm. It monitors raw material levels against production schedules and fires the moment a shortage could halt a production line. In manufacturing, this is not a nice-to-have alert -- it is the difference between a running line and an idle workforce. When a material runs low, the alert goes to the Executive Reporter and triggers Shipping Tracker to check inbound delivery status from suppliers.

Order Fulfillment manages the demand side -- matching customer orders against production schedules and available finished goods. It knows what is promised, what is in production, and what is ready to ship. Shipping Tracker handles both directions: inbound raw material deliveries from suppliers and outbound finished goods to customers. Late inbound shipments get escalated because they directly threaten production schedules.

Data Quality Monitor validates the production data that everything else depends on. Sensor readings, batch records, yield calculations, quality measurements -- if any of this data is wrong, production decisions based on it are wrong too. A drift in a temperature sensor does not just mean bad data; it means bad product. SRE & DevOps monitors the technology infrastructure that runs the floor: SCADA systems, IoT sensor networks, MES platforms, and the connectivity that ties them together. When these systems go down, operators are flying blind.

Executive Reporter compiles the daily production dashboard that plant managers actually need: output versus target, quality yields, material availability, equipment uptime, and shipment status. No fluff -- just the numbers that determine whether the plant made money today.

**Communication flow:**
- Inventory Alert detects raw material shortage -> urgent alert to Executive Reporter, check to Shipping Tracker for inbound ETA
- Shipping Tracker sees delayed inbound delivery -> alert to Inventory Manager to recalculate buffer stock
- Data Quality Monitor detects sensor drift -> alert to SRE & DevOps for investigation, flag to Executive Reporter
- SRE & DevOps detects MES downtime -> alert to Executive Reporter, impact assessment to Order Fulfillment
- Order Fulfillment sees order exceeding available stock -> finding to Inventory Manager for production scheduling
- Inventory Manager updates finished goods count -> available stock to Order Fulfillment and Shipping Tracker
- Executive Reporter compiles daily production dashboard from all bot signals

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `product_lines`, `raw_materials`, `production_capacity`, `quality_standards`, `supplier_base`, `shipping_regions`
3. Bots begin running on their default schedules automatically
4. Check the Executive Reporter's daily production dashboard for output, quality, materials, and shipment status
