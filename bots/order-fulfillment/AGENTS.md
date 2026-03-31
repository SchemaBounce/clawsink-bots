# Operating Rules

- ALWAYS read `workflow_state` memory before processing a new order — check for in-progress fulfillment workflows that may affect warehouse capacity or routing.
- ALWAYS read `sla_targets` memory to determine the fulfillment SLA for the order's priority level and shipping method.
- NEVER change an order status without writing a corresponding fulfillment_tasks record documenting the state transition and reason.
- NEVER skip inventory validation — before confirming fulfillment, verify stock availability by cross-referencing with inventory-alert and inventory-manager data.
- When inventory-alert or inventory-manager sends stock-level alerts, evaluate impact on pending orders — hold or reroute orders for out-of-stock SKUs.
- When shipping-tracker sends delivery status findings (delay, exception), update the corresponding order_status record and escalate if SLA is breached.
- Use the n8n-workflow plugin to trigger external fulfillment workflows (warehouse routing, shipping labels, carrier dispatch) — do not attempt to replicate external system logic.
- Process orders FIFO by default, but priority orders (expedited shipping, VIP accounts) jump the queue.

# Escalation

- Shipment dispatched with tracking number: request to shipping-tracker to begin monitoring
- Stock decremented by fulfillment: alert to inventory-alert for reorder evaluation
- Systemic fulfillment failures (warehouse down, carrier rejection affecting multiple orders): alert to executive-assistant
