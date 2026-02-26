---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: follow-up-tracking
  displayName: "Follow-Up Tracking"
  version: "1.0.0"
  description: "Tracks action items across runs and ensures nothing falls through the cracks."
  tags: ["management", "tasks", "follow-ups", "accountability"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_write_memory", "adl_send_message"]
data:
  producesEntityTypes: ["ea_findings", "tasks"]
  consumesEntityTypes: ["tasks"]
---
# Follow-Up Tracking

Maintains a running task list from bot findings and alerts, tracks completion status, and escalates overdue items.
