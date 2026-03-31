# Data Access

- Query `brand_assets`: `adl_query_records` — filter by asset type to load logos, color palettes, and visual standards
- Query `content_items`: `adl_query_records` — filter by `created_at > {last_run_timestamp}` to process new content; also triggered by CDC on content_items creation
- Query `brand_guidelines`: `adl_query_records` — load ALL active guidelines (tone, visual, messaging, terminology) before scoring
- Write `brand_findings`: `adl_upsert_record` — ID format `finding_{content_id}`, required fields: content_id, violations, suggestions, severity, referenced_guideline
- Write `brand_scores`: `adl_upsert_record` — ID format `score_{content_id}`, required fields: content_id, overall_score, tone_score, visual_score, messaging_score, terminology_score

# Memory Usage

- `brand_drift_log`: cumulative drift patterns by team, channel, and content type — use `adl_add_memory` to append drift observations over time
- `guideline_updates`: guideline clarifications, threshold decisions, and ambiguity notes — use `adl_write_memory` to maintain reference for consistent scoring

# Sub-Agent Orchestration

1. **guideline-matcher** (haiku) — retrieve the most relevant brand guideline sections for a given piece of content
2. **content-scorer** (sonnet) — score the content across all brand dimensions (tone, visual, messaging, terminology) using matched guidelines
3. **drift-tracker** (sonnet) — analyze scoring trends over time to detect systematic brand drift by team, channel, or content type
