# Data Access

- Query `user_feedback`: `adl_query_records` — filter by `created_at > {last_run_timestamp}` for new feedback, by `theme` for cluster analysis
- Query `usage_analytics`: `adl_query_records` — filter by page/feature for drop-off detection and usage patterns
- Query `support_tickets`: `adl_query_records` — filter by category for recurring usability complaints
- Write `ux_findings`: `adl_upsert_record` — ID format `uxf_{theme}_{date}`, required: severity, theme, pain_point, evidence_count, recommendation, affected_personas
- Write `usability_reports`: `adl_upsert_record` — ID format `ur_{period}`, required: period, themes, top_pain_points, trend_summary

# Memory Usage

- `user_patterns`: user behavior patterns and journey-stage insights — use `adl_add_memory`
- `pain_points`: active pain point themes with severity scores and signal counts — use `adl_write_memory`
- `research_backlog`: emerging patterns needing more evidence before becoming findings — use `adl_write_memory`

# Sub-Agent Orchestration

- `feedback-clusterer`: groups raw feedback items into thematic clusters
- `pattern-scanner`: scans usage analytics and tickets for recurring usability patterns
- `insight-synthesizer`: composes ux_findings from clustered evidence with recommendations
