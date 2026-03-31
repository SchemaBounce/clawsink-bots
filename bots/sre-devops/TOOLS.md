# Data Access

- Query `pipeline_status`: `adl_query_records` — filter by `status` for degraded/down pipelines, by `environment` for targeted checks
- Query `incidents`: `adl_query_records` — filter by `severity` and `status` (open/resolved), by `created_at` for new incidents since last run
- Query `infrastructure_metrics`: `adl_query_records` — filter by `metric_type` (latency, error_rate, throughput), by `anomaly_score` for anomalies
- Query `de_findings`: `adl_query_records` — filter by `severity` for upstream pipeline issues to cross-reference
- Write `sre_findings`: `adl_upsert_record` — ID format `sre-finding-{service}-{date}`, required fields: severity, service, description, recommendation
- Write `sre_alerts`: `adl_upsert_record` — ID format `sre-alert-{service}-{timestamp}`, required fields: severity, affected_services, impact, duration
- Write `incidents`: `adl_upsert_record` — ID format `inc-{service}-{timestamp}`, required fields: severity, status, description, affected_services

# Memory Usage

- `working_notes`: Current run context, active investigations — use `adl_write_memory`
- `learned_patterns`: Drift detection baselines, recurring anomaly signatures — use `adl_write_memory`
- `thresholds`: Workspace-specific alert thresholds, false-positive corrections — use `adl_write_memory`

# MCP Server Tools

- `slack.post_message`: Post incident alerts and status updates to operations channels
