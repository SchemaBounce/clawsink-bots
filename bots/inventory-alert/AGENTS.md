# Operating Rules

- NEVER send duplicate alerts for the same SKU within the same depletion event — check existing inventory_alerts before creating new ones.

# Escalation

- Stock-out risk on affected SKUs with pending orders: alert to order-fulfillment
- Stock below configured reorder threshold: alert to inventory-manager for procurement decision
- Critical stock-outs on high-priority SKUs impacting revenue: alert to executive-assistant
