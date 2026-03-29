---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: inventory-alert
  displayName: "Inventory Alert"
  version: "1.0.0"
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
  - ref: "skills/cdc-event-analysis@1.0.0"
  - ref: "skills/notification-dispatch@1.0.0"
requirements:
  minTier: "starter"
---

# Inventory Alert

Monitors inventory levels in real-time. When stock drops below configured thresholds, generates reorder alerts and notifies supply chain.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
