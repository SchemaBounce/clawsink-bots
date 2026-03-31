# Data Access

- Query `campaigns`: `adl_query_records` — filter by status or date range for active campaign metrics (conversion, engagement, spend)
- Query `contacts`: `adl_query_records` — filter by segment or acquisition channel for audience analysis
- Query `cs_findings`: `adl_query_records` — filter by recency to surface content topics from customer support pain points
- Write `mktg_findings`: `adl_upsert_record` — ID format `mktg_{topic}_{date}`, required fields: finding_type, channel, metrics, recommendation
- Write `mktg_alerts`: `adl_upsert_record` — ID format `alert_{campaign}_{date}`, required fields: campaign_id, alert_type, severity, metric_values
- Write `campaigns`: `adl_upsert_record` — update campaign records with analysis notes or status changes

# Memory Usage

- `working_notes`: in-progress analysis, pending items, cross-run context — use `adl_write_memory` to save state
- `learned_patterns`: pattern observations with timestamps to prevent re-analysis — use `adl_add_memory` to append new patterns
- `content_calendar`: content assignments, deadlines, gap tracking — use `adl_write_memory` to update after each coordination pass

# Sub-Agent Orchestration

1. **campaign-analyzer** (sonnet) — analyze active campaign metrics including conversion rates, engagement, and spend efficiency
2. **channel-comparator** (haiku) — compare performance across marketing channels and identify growth opportunities or budget reallocation needs
3. **growth-signal-writer** (haiku) — persist findings, update campaigns, and route signals to other bots after analysis completes
