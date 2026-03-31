# Data Access

- Query `pipeline_status`: `adl_query_records` — filter by `pipeline_id` for specific pipelines, by `error_rate` for unhealthy ones, by `freshness_timestamp` for stale data
- Query `sre_findings`: `adl_query_records` — filter by `created_at` for new infrastructure findings affecting pipelines
- Write `de_findings`: `adl_upsert_record` — ID format `def-{pipeline_id}-{date}`, include finding type (drift, DLQ, latency), severity, evidence
- Write `de_alerts`: `adl_upsert_record` — ID format `dea-{pipeline_id}-{timestamp}`, critical alerts with impact assessment
- Write `pipeline_status`: `adl_upsert_record` — ID format `ps-{pipeline_id}`, must include pipeline_id, throughput, error_rate, freshness_timestamp

# Memory Usage

- `working_notes`: in-progress analysis and cross-run pipeline health context — use `adl_write_memory` / `adl_read_memory`
- `learned_patterns`: recurring failure patterns for faster root cause identification — use `adl_add_memory` when patterns repeat
- `thresholds`: freshness and error rate limits per pipeline — use `adl_read_memory` before every health evaluation

# Sub-Agent Orchestration

- `pipeline-health-checker`: delegate throughput, DLQ depth, and error rate checks across all active pipelines
- `schema-drift-detector`: delegate comparison of source schemas against sink configurations
- `freshness-auditor`: delegate data freshness validation against configured thresholds
