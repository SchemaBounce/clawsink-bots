# Data Access

- Query `infra_metrics`: `adl_query_records` — filter by `metric_type` and `created_at` for recent metrics, sample representative windows if data volume is large
- Query `service_status`: `adl_query_records` — filter by `status` for degraded services, always query alongside `infra_metrics` for complete reports
- Write `health_reports`: `adl_upsert_record` — ID format `health-report-{date}`, required fields: summary, trends, capacity_risks, recommendations
- Write `infra_alerts`: `adl_upsert_record` — ID format `infra-alert-{component}-{timestamp}`, required fields: severity, component, trend_direction, risk_assessment

# Memory Usage

- `performance_baselines`: Historical metric norms for trend comparison — use `adl_write_memory`
- `capacity_trends`: Resource utilization trends for threshold breach forecasting — use `adl_write_memory`
