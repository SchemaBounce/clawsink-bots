---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: review-response-generation
  displayName: "Review Response Generation"
  version: "1.0.0"
  description: "Draft personalized host responses to guest reviews matching rating and feedback tone."
  tags: ["reviews", "responses", "guest-relations", "reputation"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_semantic_search", "adl_tool_search"]
data:
  producesEntityTypes: ["str_reviews"]
  consumesEntityTypes: ["str_reviews", "str_bookings", "str_guests", "str_properties"]
---
# Review Response Generation

Drafts thoughtful, personalized host responses to guest reviews. Adapts tone to rating: warm gratitude for positive reviews, empathetic and solution-focused for negative feedback.
