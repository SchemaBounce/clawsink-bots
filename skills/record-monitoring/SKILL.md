---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: record-monitoring
  displayName: "Record Monitoring"
  version: "1.0.0"
  description: "Continuously monitors entity records for compliance violations, quality issues, or policy breaches."
  tags: ["monitoring", "compliance", "quality", "records"]
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_write_memory", "adl_tool_search"]
data:
  consumesEntityTypes: ["monitored_records"]
  producesEntityTypes: ["monitoring_findings", "compliance_alerts"]
---
# Record Monitoring

Monitors entity records for compliance violations, data quality issues, or policy breaches. Loads monitoring rules from memory, systematically checks records against those rules, and writes findings for any violations detected.

## When to Use

Use this skill in bots responsible for ongoing compliance checks, data quality enforcement, or policy adherence across a domain's records.

## Typical Bots

Compliance bots, data quality watchers, security audit bots, and governance enforcement agents.
