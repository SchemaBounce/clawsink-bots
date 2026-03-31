# Data Access

- Query `po_findings`: `adl_query_records` — check for feature requests the product team has already acknowledged or planned
- Query `pipeline_reports`: `adl_query_records` — sales pipeline context for deal correlation
- Query `deal_insights`: `adl_query_records` — filter by outcome="lost" to correlate loss reasons with feature gaps
- Query `blog_drafts`: `adl_query_records` — content signals for market positioning alignment
- Write `mi_findings`: `adl_upsert_record` — ID format: `mi_finding_{topic}_{timestamp}`, required fields: finding_type, domain, summary
- Write `mi_alerts`: `adl_upsert_record` — ID format: `mi_alert_{timestamp}`, required fields: alert_type, urgency
- Write `mi_landscape_reports`: `adl_upsert_record` — ID format: `landscape_{week_date}`, required fields: product_announcements, feature_parity_changes, positioning_shifts, emerging_trends

# Memory Usage

- `working_notes`: run state, pending analysis tasks — use `adl_write_memory`
- `learned_patterns`: industry trend patterns, recurring themes — use `adl_add_memory`
- `landscape_baselines`: established industry state for genuine shift detection — use `adl_write_memory`
- `feature_gaps`: tracked gaps with status (open/closed), deal citation count — use `adl_write_memory`
