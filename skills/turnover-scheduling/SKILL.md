---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: turnover-scheduling
  displayName: "Turnover Scheduling"
  version: "1.0.0"
  description: "Coordinate cleaning and maintenance between guest stays for guest-ready properties."
  tags: ["cleaning", "maintenance", "scheduling", "turnover"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_send_message"]
data:
  producesEntityTypes: ["str_turnovers"]
  consumesEntityTypes: ["str_turnovers", "str_bookings", "str_properties"]
---
# Turnover Scheduling

Identifies upcoming turnovers from the booking calendar, schedules cleaning crews, tracks completion status, and flags tight turnaround windows or maintenance issues.
