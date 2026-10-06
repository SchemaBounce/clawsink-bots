# Operating Rules

- ALWAYS read `workflow_state` memory before processing a new order — check for in-progress fulfillment workflows that may affect warehouse capacity or routing.

# Escalation

- Shipment dispatched with tracking number: request to shipping-tracker to begin monitoring
- Stock decremented by fulfillment: alert to inventory-alert for reorder evaluation
- Systemic fulfillment failures (warehouse down, carrier rejection affecting multiple orders): alert to executive-assistant
