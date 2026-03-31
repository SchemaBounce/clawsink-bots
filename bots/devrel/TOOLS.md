# Data Access

- Query `po_findings`: `adl_query_records` — filter by recency to check product-owner findings that may affect community messaging
- Query `blog_drafts`: `adl_query_records` — filter by status to identify content that could address active friction points
- Query `cs_findings`: `adl_query_records` — filter by recency to correlate customer support patterns with community signals
- Query `doc_updates`: `adl_query_records` — filter by status to identify documentation improvements addressing community pain points
- Write `devrel_findings`: `adl_upsert_record` — ID format `devrel_{topic}_{date}`, required fields: finding_type, severity, pattern_description, affected_count
- Write `devrel_alerts`: `adl_upsert_record` — ID format `alert_{type}_{date}`, required fields: alert_type, severity, metric_deviation, baseline_value
- Write `devrel_community_metrics`: `adl_upsert_record` — ID format `metrics_{date}`, required fields: stars, issue_response_time, active_contributors, discussion_volume

# Memory Usage

- `working_notes`: in-progress analysis state, pending items — use `adl_write_memory` to save between runs
- `learned_patterns`: pattern observations with timestamps to prevent duplicate escalation — use `adl_add_memory` to append
- `community_baselines`: current metric values (stars, issue response time, active contributors, discussion volume) — use `adl_write_memory` to update at end of each run
- `friction_tracker`: friction point names with occurrence counts — use `adl_write_memory` to increment; graduate to finding at threshold

# MCP Server Tools

- `github.list_issues`: monitor open issues for friction patterns, response times, and recurring themes
- `github.get_repo`: pull repo-level metrics (stars, forks, watchers) for community health tracking
- `github.list_pull_requests`: track contributor activity and community engagement velocity

# Sub-Agent Orchestration

1. **community-scanner** (haiku) — collect raw GitHub community metrics: stars, issues, contributors, response times
2. **friction-analyzer** (sonnet) — analyze issue themes, sentiment, and developer pain points from scanner output
