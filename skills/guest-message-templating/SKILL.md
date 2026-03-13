---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: guest-message-templating
  displayName: "Guest Message Templating"
  version: "1.0.0"
  description: "Auto-respond to guest inquiries with personalized, context-aware messages."
  tags: ["guest-communication", "auto-response", "templates", "hospitality"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_semantic_search"]
data:
  producesEntityTypes: ["str_messages"]
  consumesEntityTypes: ["str_messages", "str_bookings", "str_guests", "str_properties"]
---
# Guest Message Templating

Drafts personalized guest messages across the booking lifecycle: pre-booking inquiries, check-in instructions, during-stay support, and post-stay follow-up. Maintains Superhost response time targets.
