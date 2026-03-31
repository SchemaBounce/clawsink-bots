# Data Access

- Query `*` (all entity types): `adl_query_records` — this bot validates any incoming record type; filter by `created_at` for new records
- Write `dq_findings`: `adl_upsert_record` — ID format `dqf-{entity_type}-{record_id}`, include rule violated, severity, field details
- Write `dq_scores`: `adl_upsert_record` — ID format `dqs-{entity_type}-{batch_date}`, quality scorecard with completeness, format, consistency, and referential integrity scores

# Memory Usage

- `quality_rules`: learned validation rules and configured thresholds per entity type — use `adl_read_memory` before every validation run
- `baseline_stats`: field-level distribution statistics for anomaly detection — use `adl_add_memory` after each batch to improve baselines over time

# Sub-Agent Orchestration

- `rule-validator`: delegate rule-based validation checks (completeness, format compliance, consistency)
- `pattern-learner`: delegate statistical analysis to detect anomalies and learn new validation patterns from data distributions
