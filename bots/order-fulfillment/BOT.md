---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: order-fulfillment
  displayName: "Order Fulfillment"
  version: "1.0.5"
  description: "Orchestrates order processing workflows from receipt through delivery."
  category: ecommerce
  tags: ["orders", "fulfillment", "workflow", "cdc"]
agent:
  capabilities: ["order_management", "workflow"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
  instructions: |
    ## Operating Rules
    - ALWAYS read `workflow_state` memory before processing a new order — check for in-progress fulfillment workflows that may affect warehouse capacity or routing.
    - ALWAYS read `sla_targets` memory to determine the fulfillment SLA for the order's priority level and shipping method.
    - NEVER change an order status without writing a corresponding fulfillment_tasks record documenting the state transition and reason.
    - NEVER skip inventory validation — before confirming fulfillment, verify stock availability by cross-referencing with inventory-alert and inventory-manager data.
    - Send tracking requests to shipping-tracker (request) immediately after a shipment is dispatched — include tracking number and carrier.
    - Send stock decrement alerts to inventory-alert (alert) after fulfillment — this triggers reorder evaluation for consumed SKUs.
    - Escalate to executive-assistant (alert) only for systemic fulfillment failures (e.g., warehouse system down, carrier rejection affecting multiple orders).
    - When inventory-alert or inventory-manager sends stock-level alerts, evaluate impact on pending orders — hold or reroute orders for out-of-stock SKUs.
    - When shipping-tracker sends delivery status findings (delay, exception), update the corresponding order_status record and escalate if SLA is breached.
    - Use the n8n-workflow plugin to trigger external fulfillment workflows (warehouse routing, shipping labels, carrier dispatch) — do not attempt to replicate external system logic.
    - Process orders FIFO by default, but priority orders (expedited shipping, VIP accounts) jump the queue.
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
  entityType: "orders"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
    - { type: "alert", from: ["inventory-alert", "inventory-manager"] }
    - { type: "finding", from: ["shipping-tracker"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
    - { type: "request", to: ["shipping-tracker"], when: "order shipped — tracking number assigned, monitor delivery" }
    - { type: "alert", to: ["inventory-alert"], when: "order fulfilled — stock decremented for ordered SKUs" }
data:
  entityTypesRead: ["orders", "fulfillment_rules"]
  entityTypesWrite: ["fulfillment_tasks", "order_status"]
  memoryNamespaces: ["workflow_state", "sla_targets"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["operations"]
presence:
  email:
    required: true
    provider: agentmail
egress:
  mode: "none"
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send order confirmation emails, shipping notifications, and fulfillment updates to customers"
  - ref: "tools/composio"
    required: false
    reason: "Connect to shipping carriers, warehouse management, and e-commerce platforms for order processing"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/cdc-event-analysis@1.0.0"
plugins:
  - ref: "n8n-workflow@latest"
    required: true
    reason: "Triggers fulfillment workflows in external systems (warehouse routing, shipping labels, carrier dispatch)"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-ecommerce-platform
      name: "Connect e-commerce platform"
      description: "Links your store so the bot can receive and process incoming orders"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Primary data source for orders, inventory status, and fulfillment workflows"
      ui:
        icon: composio
        actionLabel: "Connect E-commerce Platform"
        helpUrl: "https://docs.schemabounce.com/integrations/ecommerce"
    - id: set-sla-targets
      name: "Define fulfillment SLA targets"
      description: "Set processing time targets by order priority and shipping method"
      type: config
      group: configuration
      target: { namespace: sla_targets, key: fulfillment_sla }
      priority: required
      reason: "Cannot monitor SLA compliance without defined fulfillment time targets"
      ui:
        inputType: form
        fields:
          - { name: standard_hours, label: "Standard shipping SLA (hours)", type: number, default: 48 }
          - { name: expedited_hours, label: "Expedited shipping SLA (hours)", type: number, default: 24 }
          - { name: priority_hours, label: "Priority/VIP SLA (hours)", type: number, default: 12 }
    - id: connect-agentmail
      name: "Connect email for notifications"
      description: "Enables sending order confirmations, shipping updates, and fulfillment alerts"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Customer-facing order status communication and internal fulfillment alerts"
      ui:
        icon: email
        actionLabel: "Connect Email"
    - id: set-mission
      name: "Set business mission"
      description: "Helps the bot understand order priority and fulfillment context"
      type: north_star
      key: mission
      group: configuration
      priority: recommended
      reason: "Mission context guides fulfillment prioritization and escalation decisions"
      ui:
        inputType: textarea
        placeholder: "e.g., Fast, reliable delivery for our e-commerce customers"
    - id: import-fulfillment-rules
      name: "Import fulfillment rules"
      description: "Routing rules determine which warehouse handles each order"
      type: data_presence
      entityType: fulfillment_rules
      minCount: 1
      group: data
      priority: recommended
      reason: "Without routing rules, orders cannot be assigned to warehouses automatically"
      ui:
        actionLabel: "Add Fulfillment Rules"
        emptyState: "No fulfillment rules found. Define warehouse routing, carrier preferences, and priority rules."
        helpUrl: "https://docs.schemabounce.com/bots/order-fulfillment/rules"
    - id: import-orders
      name: "Import existing orders"
      description: "Seed the bot with in-flight orders for immediate processing"
      type: data_presence
      entityType: orders
      minCount: 1
      group: data
      priority: optional
      reason: "Existing orders give the bot immediate work and establish processing patterns"
      ui:
        actionLabel: "Import Orders"
        emptyState: "No orders found. Connect your e-commerce platform or import via CSV."
goals:
  - name: fulfill_orders
    description: "Process incoming orders through the complete fulfillment lifecycle"
    category: primary
    metric:
      type: count
      entity: fulfillment_tasks
      filter: { status: "completed" }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when new orders exist"
  - name: sla_compliance
    description: "Fulfill orders within their designated SLA time windows"
    category: primary
    metric:
      type: rate
      numerator: { entity: fulfillment_tasks, filter: { sla_met: true } }
      denominator: { entity: fulfillment_tasks, filter: { status: "completed" } }
    target:
      operator: ">="
      value: 0.95
      period: weekly
  - name: order_processing_health
    description: "No orders stuck in processing without status updates"
    category: health
    metric:
      type: count
      entity: order_status
      filter: { status: "stuck", age_hours: { "$gt": 24 } }
    target:
      operator: "=="
      value: 0
      period: daily
  - name: inventory_sync
    description: "Stock decrements sent to inventory after every fulfillment"
    category: secondary
    metric:
      type: boolean
      check: inventory_alert_sent_after_fulfillment
    target:
      operator: "=="
      value: true
      period: per_run
---

# Order Fulfillment

Orchestrates the complete order fulfillment lifecycle. Routes orders to appropriate warehouses, tracks processing stages, and ensures SLA compliance.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
