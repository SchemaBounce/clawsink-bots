---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: dynamic-pricing
  displayName: "Dynamic Pricing"
  version: "1.0.0"
  description: "Optimize nightly rates based on demand, seasonality, and occupancy patterns."
  tags: ["pricing", "revenue-management", "str", "optimization"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_write_memory"]
data:
  producesEntityTypes: ["str_pricing_calendar"]
  consumesEntityTypes: ["str_pricing_calendar", "str_bookings", "str_properties"]
---
# Dynamic Pricing

Analyzes booking patterns, seasonal demand, and occupancy to recommend optimal nightly rates. Maximizes RevPAN while maintaining occupancy targets within host-defined guardrails.
