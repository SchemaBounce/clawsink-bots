---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: brand-audit
  displayName: "Brand Audit"
  version: "1.0.0"
  description: "Audits content and assets for brand consistency, tone, and guideline compliance."
  tags: ["design", "brand", "content", "quality"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_send_message"]
data:
  producesEntityTypes: ["brand_findings", "brand_scores"]
  consumesEntityTypes: ["brand_assets", "content_items", "brand_guidelines"]
---
# Brand Audit

Reviews content and assets against brand guidelines for consistency in tone, visual identity, and messaging.
