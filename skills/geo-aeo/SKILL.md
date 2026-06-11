---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: geo-aeo
  displayName: "GEO / AEO"
  version: "1.0.0"
  description: "Generative Engine Optimization and Answer Engine Optimization workflow: measures AI citation share-of-voice across ChatGPT, Claude, and Perplexity; drafts llms.txt for human review; and applies GEO content tactics (entity clarity, Q&A formatting, answer-engine-friendly structure)."
  tags: ["geo", "aeo", "llms-txt", "ai-citation", "share-of-voice", "answer-engine"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_upsert_record", "adl_read_memory", "adl_write_memory", "adl_send_message"]
data:
  producesEntityTypes: ["seo_findings", "seo_geo_citation", "seo_llms_txt_draft"]
  consumesEntityTypes: ["seo_keyword_opportunity", "seo_geo_citation"]
---
# GEO / AEO

Measures AI citation visibility and applies GEO tactics: llms.txt drafting, entity clarity, and answer-engine-friendly content recommendations.
