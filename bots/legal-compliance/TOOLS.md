# Data Access

- Query `contracts`: `adl_query_records` — filter by `expiry_date` for contracts within 30 days, by `status` for pending reviews
- Query `companies`: `adl_query_records` — filter by `compliance_status` for entities with outstanding compliance requirements
- Write `legal_findings`: `adl_upsert_record` — ID format `legal-finding-{framework}-{date}`, required fields: framework, finding_type, severity, recommendation, requires_human_review
- Write `legal_alerts`: `adl_upsert_record` — ID format `legal-alert-{type}-{timestamp}`, required fields: alert_type, deadline, severity, affected_entity
- Write `contracts`: `adl_upsert_record` — ID format `contract-{entity}-{date}`, required fields: status, review_notes (never store full contract text)

# Memory Usage

- `working_notes`: Current compliance posture summary and active investigations — use `adl_write_memory`
- `learned_patterns`: Regulatory change patterns for anticipating future requirements — use `adl_write_memory`
- `compliance_calendar`: Deadlines for contract renewals, certification expirations, filing dates — use `adl_write_memory`
