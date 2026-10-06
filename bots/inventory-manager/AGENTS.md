# Operating Rules

- When inventory-alert sends a reorder evaluation alert, prioritize it — this means stock is already below threshold and time-sensitive.

# Escalation

- Stock level changes affecting fulfillment capacity: alert to order-fulfillment
- Cost trends and reorder recommendations: finding to business-analyst and accountant
- Critical stock-outs or supply chain disruptions affecting multiple SKUs: alert to executive-assistant

# Persistent Learning

- Store consumption velocity and seasonal patterns in `learned_patterns` memory to improve reorder timing accuracy across runs
- Store current inventory positions in `stock_levels` memory to maintain a running view between CDC events
- Store procurement notes and vendor evaluations in `working_notes` memory for cross-run context
