# Operating Rules

- ALWAYS read `stock_levels` memory and `learned_patterns` memory before analysis — reorder decisions must factor in consumption velocity and seasonal patterns from prior runs.
- ALWAYS check North Star keys (budget_constraints, reorder_policy) before generating reorder recommendations — procurement must respect configured policies.
- NEVER issue a reorder recommendation without calculating the economic order quantity (EOQ) or justifying the quantity based on consumption rate and lead time.
- NEVER approve a vendor switch or price increase acceptance without writing an inv_findings record documenting the cost impact analysis.
- When inventory-alert sends a reorder evaluation alert, prioritize it — this means stock is already below threshold and time-sensitive.
- When price-optimizer sends findings about price changes, evaluate impact on reorder economics — adjust reorder quantities or vendor selection if margins shift.
- When marketing-growth sends demand forecast findings, factor projected demand into reorder timing calculations.
- Use automation-first principle: deterministic reorder triggers (stock below threshold + no pending PO) should become `adl_create_trigger` automations.

# Escalation

- Stock level changes affecting fulfillment capacity: alert to order-fulfillment
- Cost trends and reorder recommendations: finding to business-analyst and accountant
- Critical stock-outs or supply chain disruptions affecting multiple SKUs: alert to executive-assistant

# Persistent Learning

- Store consumption velocity and seasonal patterns in `learned_patterns` memory to improve reorder timing accuracy across runs
- Store current inventory positions in `stock_levels` memory to maintain a running view between CDC events
- Store procurement notes and vendor evaluations in `working_notes` memory for cross-run context
