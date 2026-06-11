---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: social-publishing
  displayName: "Social Publishing"
  version: "1.0.0"
  description: "Draft and (after human approval) publish property social posts to Instagram and Facebook Pages with correct format limits and a mandatory approval gate."
  tags: ["instagram", "facebook", "social-media", "marketing", "str", "publishing"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_messages", "adl_send_message", "adl_read_memory", "adl_write_memory"]
data:
  producesEntityTypes: ["mkt_social_posts"]
  consumesEntityTypes: ["str_properties", "str_reviews", "mkt_content"]
---
# Social Publishing

Draft property social posts per platform, send for str-property-manager approval, then publish only after approval is confirmed.
