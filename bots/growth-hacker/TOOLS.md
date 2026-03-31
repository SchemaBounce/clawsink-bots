# Data Access

- Query `acquisition_metrics`: `adl_query_records` — filter by channel and date range for CAC, conversion rate, and volume analysis
- Query `campaign_results`: `adl_query_records` — filter by `created_at > {last_run_timestamp}` to catch new results from automation trigger
- Query `conversion_funnels`: `adl_query_records` — filter by funnel stage to identify drop-off points
- Write `growth_experiments`: `adl_upsert_record` — ID format `exp_{channel}_{name}_{version}`, required fields: name, hypothesis, channel, status, metric, baseline, target, kill_criteria
- Write `growth_findings`: `adl_upsert_record` — ID format `finding_{experiment}_{date}`, required fields: experiment_name, result, roi, recommendation (scale/pivot/kill)

# Memory Usage

- `experiment_log`: running experiments with status, start dates, and kill criteria — use `adl_write_memory` to enforce max 3 concurrent per channel
- `channel_performance`: per-channel CAC, conversion_rate, volume, trend — use `adl_write_memory` to update each run for cross-channel comparison
- `viral_coefficients`: k-factor measurements for referral and viral loop experiments — use `adl_write_memory` to track; below 0.5 triggers escalation, above 1.0 triggers scale recommendation

# Sub-Agent Orchestration

1. **funnel-analyzer** (sonnet) — analyze the full acquisition funnel (awareness to referral) and identify highest-leverage drop-off points
2. **channel-ranker** (haiku) — rank acquisition channels by efficiency (CAC, conversion rate, LTV) and recommend budget reallocation
3. **experiment-designer** (sonnet) — design new experiments with hypothesis, variants, success criteria, and kill criteria
