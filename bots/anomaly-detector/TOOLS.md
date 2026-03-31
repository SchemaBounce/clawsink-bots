# Data Access

- Query `metrics`: `adl_query_records` — filter by created_at for new incoming metrics events, triggered via CDC
- Query `alert_rules`: `adl_query_records` — check for user-configured thresholds that override default statistical detection
- Write `anomaly_findings`: `adl_upsert_record` — ID format: `anomaly_{metric_name}_{timestamp}`, required fields: metric_name, deviation, severity (critical/high/medium/low), baseline_value, observed_value
- Write `anomaly_alerts`: `adl_upsert_record` — ID format: `alert_{metric_name}_{timestamp}`, required fields: metric_name, severity, description

# Memory Usage

- `metric_baselines`: established normal ranges per metric — read before every evaluation, use `adl_write_memory`
- `detection_models`: refined baseline parameters, learned thresholds — update after each run with `adl_write_memory`

# Sub-Agent Orchestration

- `statistical-analyzer`: performs statistical deviation calculations against baselines
- `pattern-learner`: refines detection models from historical patterns
- `alert-correlator`: groups related anomalies to reduce alert noise
