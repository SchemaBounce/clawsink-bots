---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: inventory-alert
  displayName: "Inventory Alert"
  version: "1.0.4"
  description: "Detects low stock levels and triggers reorder alerts when inventory falls below thresholds."
  category: ecommerce
  tags: ["inventory", "stock", "alerts", "cdc"]
agent:
  capabilities: ["stock_management", "supply_chain"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
  instructions: |
    ## Operating Rules
    - ALWAYS read `reorder_thresholds` memory before evaluating stock levels — thresholds may have been adjusted by prior runs or inventory-manager findings.
    - ALWAYS read `stock_levels` memory to compare the incoming CDC event against the last known level — detect rate of depletion, not just absolute quantity.
    - NEVER generate a reorder_requests record without checking reorder_rules entity — honor configured min/max quantities, preferred vendors, and lead times.
    - NEVER send duplicate alerts for the same SKU within the same depletion event — check existing inventory_alerts before creating new ones.
    - Send stock-out risk alerts to order-fulfillment (alert) immediately — pending orders for affected SKUs may need to be held or rerouted.
    - Send reorder evaluation alerts to inventory-manager (alert) when stock drops below configured reorder threshold — inventory-manager handles the actual procurement decision.
    - Escalate to executive-assistant (alert) only for critical stock-outs on high-priority SKUs that will directly impact revenue or customer commitments.
    - When order-fulfillment sends an alert about stock decremented by fulfillment, re-evaluate the updated level against thresholds immediately.
    - Update `stock_levels` memory after every CDC event to maintain an accurate running view of inventory positions.
    - Process CDC events in order — if multiple inventory updates arrive in batch, process sequentially by timestamp to avoid stale threshold comparisons.
  toolInstructions: |
    ## Tool Usage — Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state` — get last run timestamp
    - Step 2: `adl_read_messages` — check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}` — ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 8000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
trigger:
  entityType: "inventory"
  eventType: "updated"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
    - { type: "alert", from: ["order-fulfillment"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
    - { type: "alert", to: ["order-fulfillment"], when: "stock-out risk — affected SKUs may delay pending orders" }
    - { type: "alert", to: ["inventory-manager"], when: "stock below reorder threshold — reorder evaluation needed" }
data:
  entityTypesRead: ["inventory", "reorder_rules"]
  entityTypesWrite: ["inventory_alerts", "reorder_requests"]
  memoryNamespaces: ["stock_levels", "reorder_thresholds"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["operations"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/cdc-event-analysis@1.0.0"
  - ref: "skills/notification-dispatch@1.0.0"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: seed-inventory-records
      name: "Feed inventory records"
      description: "Ensure inventory records are flowing into ADL from your inventory management system via CDC or API sync."
      type: data_presence
      group: data
      priority: required
      reason: "The bot is CDC-triggered on entityType=inventory updated events. Without inventory records, it has nothing to monitor."
      ui:
        entityType: "inventory"
        minCount: 5
    - id: seed-reorder-rules
      name: "Configure reorder rules"
      description: "Create reorder_rules records with min/max quantities, preferred vendors, and lead times per SKU or category."
      type: data_presence
      group: data
      priority: required
      reason: "The bot checks reorder_rules before generating reorder_requests. Without rules, it cannot determine correct reorder quantities or vendors."
      ui:
        entityType: "reorder_rules"
        minCount: 1
    - id: configure-reorder-thresholds
      name: "Set reorder thresholds"
      description: "Seed the reorder_thresholds memory with stock level thresholds per SKU or category that trigger alerts."
      type: config
      group: configuration
      priority: required
      reason: "The bot reads reorder_thresholds memory before evaluating stock levels. Without thresholds, it cannot determine when stock is low."
      ui:
        target:
          namespace: "reorder_thresholds"
          key: "thresholds"
    - id: set-north-star-mission
      name: "Define North Star mission"
      description: "Set the workspace mission so the bot understands which product lines or SKUs are highest priority."
      type: north_star
      group: configuration
      priority: recommended
      reason: "Mission context drives which stock-outs escalate to executive-assistant as critical vs routine alerts to inventory-manager."
      ui:
        key: "mission"
    - id: verify-order-fulfillment-active
      name: "Ensure Order Fulfillment bot is active"
      description: "Stock-out risk alerts are sent to order-fulfillment so pending orders can be held or rerouted."
      type: manual
      group: external
      priority: recommended
      reason: "The bot sends stock-out risk alerts to order-fulfillment. Without it, affected pending orders may ship with unavailable inventory."
      ui:
        instructions: "Deploy the order-fulfillment bot from the marketplace, or confirm it is already active in your workspace."
    - id: verify-inventory-manager-active
      name: "Ensure Inventory Manager bot is active"
      description: "Reorder evaluation alerts route to inventory-manager for procurement decisions."
      type: manual
      group: external
      priority: recommended
      reason: "The bot alerts inventory-manager when stock drops below reorder thresholds. Without it, reorder alerts go unprocessed."
      ui:
        instructions: "Deploy the inventory-manager bot from the marketplace, or confirm it is already active in your workspace."
goals:
  - id: alerts-generated
    name: "Alerts generated"
    description: "Total inventory alerts produced when stock drops below configured thresholds."
    metricType: count
    target: "> 0 per week"
    category: primary
    feedback:
      question: "Are the low-stock alerts timely and for the right SKUs?"
      options: ["yes", "mostly", "too many false alerts", "missing real stock-outs"]
  - id: duplicate-alert-rate
    name: "Duplicate alert prevention"
    description: "Percentage of alerts that are unique (no duplicate alerts for the same SKU in the same depletion event)."
    metricType: rate
    target: "> 95%"
    category: health
  - id: reorder-request-accuracy
    name: "Reorder request accuracy"
    description: "Percentage of reorder_requests that matched correct quantities and vendors from reorder_rules."
    metricType: rate
    target: "> 90%"
    category: primary
    feedback:
      question: "Are reorder quantities and vendor selections correct?"
      options: ["yes", "quantities right but wrong vendor", "quantities off", "both wrong"]
  - id: stock-levels-freshness
    name: "Stock levels freshness"
    description: "The stock_levels memory namespace reflects the latest inventory CDC events."
    metricType: boolean
    target: "updated within last 1h"
    category: health
---

# Inventory Alert

Monitors inventory levels in real-time. When stock drops below configured thresholds, generates reorder alerts and notifies supply chain.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
