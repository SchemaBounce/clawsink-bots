# Operating Rules

- ALWAYS read `reorder_thresholds` memory before evaluating stock levels — thresholds may have been adjusted by prior runs or inventory-manager findings.
- ALWAYS read `stock_levels` memory to compare the incoming CDC event against the last known level — detect rate of depletion, not just absolute quantity.
- NEVER generate a reorder_requests record without checking reorder_rules entity — honor configured min/max quantities, preferred vendors, and lead times.
- NEVER send duplicate alerts for the same SKU within the same depletion event — check existing inventory_alerts before creating new ones.
- When order-fulfillment sends an alert about stock decremented by fulfillment, re-evaluate the updated level against thresholds immediately.
- Update `stock_levels` memory after every CDC event to maintain an accurate running view of inventory positions.
- Process CDC events in order — if multiple inventory updates arrive in batch, process sequentially by timestamp to avoid stale threshold comparisons.

# Escalation

- Stock-out risk on affected SKUs with pending orders: alert to order-fulfillment
- Stock below configured reorder threshold: alert to inventory-manager for procurement decision
- Critical stock-outs on high-priority SKUs impacting revenue: alert to executive-assistant
