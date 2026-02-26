---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: expense-tracking
  displayName: "Expense Tracking"
  version: "1.0.0"
  description: "Tracks spending patterns across categories and detects anomalies."
  tags: ["finance", "expenses", "anomaly-detection"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_write_memory"]
data:
  producesEntityTypes: ["acct_findings"]
  consumesEntityTypes: ["transactions", "invoices"]
---
# Expense Tracking

Monitors transaction flow, tracks running totals by category, and detects spending anomalies (unexpected charges, spending spikes, unusual vendors).
