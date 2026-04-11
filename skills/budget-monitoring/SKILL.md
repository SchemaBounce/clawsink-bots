---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: budget-monitoring
  displayName: "Budget Monitoring"
  version: "1.0.0"
  description: "Compares spending against budget constraints and flags overspend."
  tags: ["finance", "budget", "alerts"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_send_message", "adl_tool_search"]
data:
  producesEntityTypes: ["acct_findings", "acct_alerts"]
  consumesEntityTypes: ["transactions"]
---
# Budget Monitoring

Reads budget constraints from North Star (zone1), compares current spend totals against limits, and escalates when thresholds are breached.
