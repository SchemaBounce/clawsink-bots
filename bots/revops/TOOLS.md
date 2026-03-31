# Data Access

- Query `pipeline_reports`: `adl_query_records` — filter by `period`, `created_at` for pipeline health and coverage ratios
- Query `deal_insights`: `adl_query_records` — filter by `deal_stage`, `channel` for conversion funnel and attribution data
- Query `mktg_findings`: `adl_query_records` — filter by `channel`, `campaign_id` for marketing performance and spend data
- Query `campaigns`: `adl_query_records` — filter by `status`, `channel` for active campaign attribution
- Query `churn_scores`: `adl_query_records` — filter by `risk_score`, `created_at` for net revenue retention adjustments
- Query `revenue_data`: `adl_query_records` — filter by `period`, `segment` for revenue time-series and cohort analysis
- Query `ba_findings`: `adl_query_records` — filter by `domains`, `created_at` for cross-domain insights affecting revenue
- Write `revops_findings`: `adl_upsert_record` — ID format: `revops-finding-{date}-{seq}`, required: finding_type, source_domains, metrics, recommended_action
- Write `revops_alerts`: `adl_upsert_record` — ID format: `revops-alert-{date}-{seq}`, required: severity, metric, threshold_breached, current_value
- Write `revops_forecasts`: `adl_upsert_record` — ID format: `revops-forecast-{period}`, required: period, forecast_value, confidence_interval, assumptions
- Write `revops_metrics`: `adl_upsert_record` — ID format: `revops-metric-{metric_name}-{date}`, required: metric_name, value, trend_direction, baseline_comparison

# Memory Usage

- `working_notes`: scratch context and coordination state between runs — use `adl_write_memory` for structured run state
- `learned_patterns`: confirmed revenue patterns and seasonal trends — use `adl_write_memory` for structured pattern data
- `revenue_baselines`: established revenue baselines for trend comparison — use `adl_write_memory` for structured baseline values
- `attribution_models`: channel attribution model parameters and weights — use `adl_write_memory` for structured model state

# MCP Server Tools

- `stripe.list_charges`: pull payment data for revenue reconciliation and CAC calculation
- `stripe.list_subscriptions`: track MRR/ARR and subscription lifecycle for LTV computation

# Sub-Agent Orchestration

- `attribution-modeler`: spawn to map deals to originating channels and calculate per-channel CAC
- `forecast-builder`: spawn to build revenue forecasts from attribution + pipeline + churn data
