---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: listing-optimization
  displayName: "Listing Optimization"
  version: "1.0.0"
  description: "Optimize property listing descriptions, titles, and content for maximum visibility."
  tags: ["listings", "seo", "copywriting", "property-marketing"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_memory", "adl_semantic_search"]
data:
  producesEntityTypes: []
  consumesEntityTypes: ["str_properties", "str_reviews", "str_channel_listings", "str_bookings"]
---
# Listing Optimization

Analyzes review themes, competitor positioning, and platform search algorithms to craft compelling property descriptions, titles, and highlight unique amenities for maximum conversion.
