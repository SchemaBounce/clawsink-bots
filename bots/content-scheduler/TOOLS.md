# Data Access

- Query `content_calendar`: `adl_query_records` — filter by date range or channel to check upcoming schedule
- Query `channel_configs`: `adl_query_records` — filter by channel name to load frequency limits and publishing windows
- Write `scheduled_posts`: `adl_upsert_record` — ID format `sched_{channel}_{date}_{time}`, required fields: channel, scheduled_date, scheduled_time, content_type, status
- Write `content_plans`: `adl_upsert_record` — ID format `plan_{week}_{channel}`, required fields: week_start, channel, planned_items

# Memory Usage

- `editorial_calendar`: scheduled items, slot allocations, deadline tracking — use `adl_write_memory` to update after each scheduling pass
- `performance_data`: publishing outcomes, on-time rates, missed deadlines — use `adl_write_memory` to update at end of each run

# Sub-Agent Orchestration

1. **timing-optimizer** (haiku) — determine optimal publish times based on historical engagement and audience timezone patterns
2. **calendar-planner** (sonnet) — review calendar for gaps, over-scheduling, cadence violations, and upcoming deadlines
3. **engagement-tracker** (haiku) — track post-publish engagement metrics and update performance baselines
