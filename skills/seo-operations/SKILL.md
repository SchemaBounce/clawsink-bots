---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: seo-operations
  displayName: "SEO Operations"
  version: "1.0.0"
  description: "Classic technical SEO audit and keyword-opportunity workflow: reads Google Search Console performance data, interprets Core Web Vitals thresholds, audits on-page meta via adl_proxy_call, and surfaces almost-ranking opportunities for content action."
  tags: ["seo", "audit", "core-web-vitals", "keyword-research", "on-page"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_upsert_record", "adl_read_memory", "adl_write_memory", "adl_proxy_call", "adl_send_message"]
data:
  producesEntityTypes: ["seo_findings", "seo_keyword_opportunity"]
  consumesEntityTypes: ["seo_keyword_opportunity"]
---
# SEO Operations

Foundational technical SEO audit workflow: keyword performance from Google Search Console, Core Web Vitals from PageSpeed Insights, and on-page meta checks via adl_proxy_call.
