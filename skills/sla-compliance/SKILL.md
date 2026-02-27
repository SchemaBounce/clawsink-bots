---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: sla-compliance
  displayName: "SLA Compliance"
  version: "1.0.0"
  description: "Tracks SLA targets and alerts when compliance thresholds are breached."
  tags: ["operations", "sla", "compliance", "uptime"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_send_message"]
data:
  producesEntityTypes: ["sre_findings", "sre_alerts"]
  consumesEntityTypes: ["pipeline_status", "incidents"]
---
# SLA Compliance

Reads SLA targets from North Star, calculates current compliance levels from pipeline and incident data, and escalates breaches.
