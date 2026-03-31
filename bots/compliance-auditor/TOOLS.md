# Data Access

- Query `financial_records`: `adl_query_records` — filter by `created_at` for new records since last run, CDC-triggered runs process the triggering record
- Query `compliance_rules`: `adl_query_records` — filter by `framework` for active regulatory rules to audit against
- Write `audit_findings`: `adl_upsert_record` — ID format `audit-{record_id}-{rule}`, required fields: record_id, rule_violated, framework, severity, explanation
- Write `compliance_reports`: `adl_upsert_record` — ID format `compliance-report-{date}`, required fields: records_audited, violations_found, frameworks_checked

# Memory Usage

- `regulatory_frameworks`: Active compliance rules and framework definitions — use `adl_write_memory`
- `audit_history`: Audit coverage tracking to ensure no records are missed across runs — use `adl_add_memory`
