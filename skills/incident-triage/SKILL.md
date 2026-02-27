---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: incident-triage
  displayName: "Incident Triage"
  version: "1.0.0"
  description: "Detects and correlates infrastructure incidents across services."
  tags: ["operations", "incidents", "triage", "correlation"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_send_message"]
data:
  producesEntityTypes: ["sre_findings", "sre_alerts", "incidents"]
  consumesEntityTypes: ["incidents", "infrastructure_metrics"]
---
# Incident Triage

Queries recent incidents and infrastructure metrics, correlates anomalies across services, assigns severity, and escalates critical incidents.
