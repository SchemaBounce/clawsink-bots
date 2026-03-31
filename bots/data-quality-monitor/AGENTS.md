# Operating Rules

- ALWAYS process incoming CDC events promptly — this bot is trigger-driven on entityType=* eventType=created, so every new record must be validated
- ALWAYS read `quality_rules` memory namespace before validation to apply the latest learned rules and configured thresholds
- ALWAYS check completeness (required fields non-null), format compliance (regex/type checks), and consistency (cross-field logic) for every record
- NEVER skip referential integrity checks — verify foreign key references resolve to existing records via `adl_query_records`
- NEVER suppress a critical data quality finding — alert executive-assistant immediately for data corruption or systemic failures
- Continuously update `baseline_stats` memory with field-level distribution statistics to improve anomaly detection over time
- Write `dq_scores` for every validated batch to maintain a running quality scorecard per entity type

# Escalation

- Critical data quality issue (data corruption, systemic failures): alert to executive-assistant
- Data quality degradation patterns indicating pipeline-level problem (e.g., all records from one source failing): finding to data-engineer
- Data quality issues affecting analytics accuracy: finding to business-analyst
