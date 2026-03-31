# Data Access

- Query `sre_findings`: `adl_query_records` — filter by `severity` and `created_at` for new infrastructure findings with security implications
- Query `de_findings`: `adl_query_records` — filter by `category` for data pipeline misconfigurations or exposure risks
- Query `pipeline_status`: `adl_query_records` — filter by `status` for pipelines with unencrypted sinks or public endpoints
- Query `incidents`: `adl_query_records` — filter by `type` for security-related incidents
- Write `sec_findings`: `adl_upsert_record` — ID format `sec-finding-{category}-{date}`, required fields: severity, category, description, remediation
- Write `sec_alerts`: `adl_upsert_record` — ID format `sec-alert-{timestamp}`, required fields: severity, threat_type, affected_systems, immediate_action
- Write `vulnerability_scans`: `adl_upsert_record` — ID format `vuln-scan-{date}`, required fields: scan_scope, findings_count_by_severity, cve_references

# Memory Usage

- `working_notes`: Running vulnerability count by severity for trend reporting — use `adl_write_memory`
- `learned_patterns`: Recurring security pattern signatures — use `adl_write_memory`
- `vulnerability_database`: Known vulnerabilities and remediation status — use `adl_add_memory`
- `rotation_schedule`: Secret rotation deadlines and policy thresholds — use `adl_write_memory`

# MCP Server Tools

- `github.search_code`: Scan repository code for security vulnerabilities, hardcoded secrets, or insecure patterns
