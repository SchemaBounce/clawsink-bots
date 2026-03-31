# Data Access

- Query `social_mentions`: `adl_query_records` — filter by `created_at > {last_run_timestamp}` to process only new mentions since last run
- Query `brand_keywords`: `adl_query_records` — load active brand keywords and monitored terms for mention filtering
- Write `sentiment_reports`: `adl_upsert_record` — ID format `sentiment_{platform}_{date}`, required fields: platform, sentiment_score, mention_volume, deviation_from_baseline
- Write `mention_alerts`: `adl_upsert_record` — ID format `alert_{platform}_{date}_{hash}`, required fields: platform, alert_type, severity, aggregate_summary (no personal info)

# Memory Usage

- `sentiment_baselines`: rolling platform-level sentiment averages and mention volumes — use `adl_write_memory` to update at end of every run
- `trending_topics`: emerging topic names with platform counts and consecutive run appearances — use `adl_write_memory` to track, promote to finding at threshold

# Sub-Agent Orchestration

1. **sentiment-scorer** (haiku) — classify sentiment on new mentions and detect reputation threats in real time
2. **trend-aggregator** (sonnet) — aggregate mention data into trend reports showing sentiment shifts and topic patterns
3. **viral-detector** (haiku) — trigger when engagement velocity exceeds thresholds, indicating potential viral content (positive or negative)
