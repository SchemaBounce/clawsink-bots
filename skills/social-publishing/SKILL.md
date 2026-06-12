---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: social-publishing
  displayName: "Social Publishing"
  version: "2.0.0"
  description: "Draft social posts and publish them to connected platforms (Instagram, Facebook, LinkedIn, Reddit) only after explicit human approval. Platform-agnostic format limits and a mandatory, prompt-enforced approval gate."
  tags: ["instagram", "facebook", "linkedin", "reddit", "social-media", "marketing", "str", "publishing"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_read_messages", "adl_send_message", "adl_read_memory", "adl_write_memory"]
data:
  producesEntityTypes: ["mkt_social_posts"]
  consumesEntityTypes: ["str_properties", "str_reviews", "mkt_content", "content_calendar_items"]
---
# Social Publishing

Draft social posts per platform, send them to the designated approver, and publish only after approval is confirmed in `adl_read_messages`. Works for STR property posts (Instagram, Facebook) and marketing posts (LinkedIn, Reddit, Instagram, Facebook).

The approval gate is **prompt-enforced**. The agent self-enforces it. Runtime hard-enforcement is a separate platform feature and is not in place yet, so the agent must never assume a system block will stop an unapproved publish.
