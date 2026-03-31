# Data Access

- Query `social_metrics`: `adl_query_records` — filter by platform and date range for engagement analysis
- Query `engagement_data`: `adl_query_records` — filter by content_type or theme to compare format performance
- Query `industry_posts`: `adl_query_records` — filter by recency to monitor trending topics and peer strategies
- Write `social_strategy`: `adl_upsert_record` — ID format `strategy_{platform}_{week}`, required fields: platform, content_mix, posting_cadence, theme_priorities
- Write `content_calendar_items`: `adl_upsert_record` — ID format `social_{platform}_{date}`, required fields: platform, scheduled_date, scheduled_time, content_type, theme, hook, status="planned"

# Memory Usage

- `platform_performance`: per-platform engagement baselines, reach, impressions, follower growth — use `adl_write_memory` to update after analysis
- `content_themes`: theme names with performance scores, lifecycle status (active/retired) — use `adl_write_memory` to track theme effectiveness
- `posting_cadence`: optimal posting times and frequency per platform — use `adl_write_memory` to update quarterly

# Sub-Agent Orchestration

1. **engagement-analyzer** (haiku) — analyze post performance and update engagement benchmarks per platform and content type
2. **content-planner** (sonnet) — update the content calendar with new items based on strategy adjustments and incoming blog content
3. **industry-watcher** (haiku) — analyze industry peer social activity and identify content strategy opportunities
