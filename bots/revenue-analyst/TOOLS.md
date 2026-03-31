# Data Access

- Query `revenue_data`: `adl_query_records` — filter by `period`, `created_at` for time-series analysis, `segment` for cohort breakdowns
- Query `sales_metrics`: `adl_query_records` — filter by `deal_stage`, `created_at` for pipeline velocity and conversion data
- Write `revenue_reports`: `adl_upsert_record` — ID format: `rev-report-{period}-{date}`, required: period, metrics, trend_direction, baseline_comparison
- Write `trend_findings`: `adl_upsert_record` — ID format: `rev-trend-{date}-{seq}`, required: trend_type, magnitude, confidence, data_freshness_timestamp

# Memory Usage

- `revenue_baselines`: computed baselines for WoW/MoM comparison — use `adl_write_memory` for structured baseline data, update every run
- `forecast_models`: prior forecast parameters and accuracy tracking — use `adl_write_memory` for structured model state

# MCP Server Tools

- `stripe.list_charges`: pull MRR/ARR data and subscription metrics for revenue trend analysis
- `stripe.list_subscriptions`: track subscription changes affecting recurring revenue

# Sub-Agent Orchestration

- `trend-detector`: spawn for deep time-series analysis across multiple revenue segments
- `forecast-builder`: spawn for building and calibrating revenue forecast models
- `segment-analyzer`: spawn for cohort-level revenue breakdown and segment performance
