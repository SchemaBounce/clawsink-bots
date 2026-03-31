# Data Access

- Query `deals`: `adl_query_records` — filter by stage, status (open/won/lost), close_date range, or segment for pipeline analysis
- Query `pipeline_stages`: `adl_query_records` — filter by pipeline ID to get stage definitions and ordering
- Write `pipeline_reports`: `adl_upsert_record` — ID format `pipeline_{YYYYMMDD}`, required fields: period, conversion_rates, stage_velocity, coverage_ratio, forecast
- Write `deal_insights`: `adl_upsert_record` — ID format `insight_{deal_id}`, required fields: deal_id, insight_type, recommendation, severity

# Memory Usage

- `conversion_rates`: Stage-to-stage conversion percentages as rolling baselines — use `adl_write_memory` to overwrite with latest snapshot
- `stage_durations`: Average days per stage for velocity tracking — use `adl_write_memory` to overwrite with updated averages

# MCP Server Tools

- `stripe.stripe_list_invoices`: Verify payment status for closed deals to confirm revenue recognition
- `stripe.stripe_list_customers`: Cross-reference deal customers with payment records

# Sub-Agent Orchestration

- `deal-scorer`: Delegates deal health scoring and win probability calculation
- `bottleneck-detector`: Delegates stage velocity analysis and conversion drop identification
- `at-risk-alerter`: Delegates stalled deal detection and SLA breach flagging
