## Anomaly Detection

Detect statistical anomalies in numeric ADL record fields using z-score and IQR methods.

### Steps

1. `adl_query_records(entity_type=<target_type>)` — fetch records with the numeric field to analyze. Minimum 30 records required for statistical validity.
2. Compute descriptive stats: mean, standard deviation, Q1, Q3, IQR (Q3 - Q1).
3. Z-score detection: flag records where `|value - mean| / stddev > 3.0`.
4. IQR detection: flag records where `value < Q1 - 1.5 * IQR` or `value > Q3 + 1.5 * IQR`.
5. Merge flagged records from both methods. Classify severity: `critical` (|z| > 5), `high` (|z| > 4), `medium` (|z| > 3), `low` (IQR-only outlier).
6. `adl_upsert_record(entity_type="anomaly_findings")` — one record per anomaly: `source_entity_id`, `source_entity_type`, `field_name`, `value`, `z_score`, `method`, `severity`, `detected_at`.
7. For critical/high anomalies: `adl_send_message(type="alert")` to the domain owner with a DataPart containing `entity_id` + `severity` + `value`.

### Output Schema

- `entity_type`: `"anomaly_findings"`
- Required fields: `source_entity_id`, `source_entity_type`, `field_name`, `value`, `z_score`, `method`, `severity`, `detected_at`

### Anti-Patterns

- NEVER run anomaly detection on fewer than 30 data points — insufficient sample produces meaningless z-scores.
- NEVER report an anomaly without both the raw value and z-score — severity context requires both.
- NEVER alert on low/medium severity — only `critical` and `high` warrant agent alerts; log the rest silently.
