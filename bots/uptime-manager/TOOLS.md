# Data Access

- Query `sre_findings`: `adl_query_records` — filter by `severity` for infrastructure issues affecting uptime
- Query `sre_alerts`: `adl_query_records` — filter by `status` (active/resolved), cross-reference before creating duplicate incidents
- Query `incidents`: `adl_query_records` — filter by `status` for new, updated, or resolved incidents since last run
- Query `test_results`: `adl_query_records` — filter by `status` (failed) for endpoint unavailability from api-tester
- Query `pipeline_status`: `adl_query_records` — filter by `status` for degraded pipelines affecting service availability
- Write `uptime_findings`: `adl_upsert_record` — ID format `uptime-finding-{component}-{date}`, required fields: component, status, impact
- Write `uptime_alerts`: `adl_upsert_record` — ID format `uptime-alert-{component}-{timestamp}`, required fields: severity, component, customer_impact
- Write `uptime_incidents`: `adl_upsert_record` — ID format `uptime-inc-{component}-{timestamp}`, required fields: status, timeline, postmortem, affected_services
- Write `uptime_sla_reports`: `adl_upsert_record` — ID format `sla-report-{window}-{date}`, required fields: window, uptime_pct, target_pct, budget_remaining

# Memory Usage

- `working_notes`: Active incident context, current run state — use `adl_write_memory`
- `learned_patterns`: Incident resolution patterns, severity classification heuristics — use `adl_write_memory`
- `sla_tracker`: Rolling uptime percentages per window, budget consumption — use `adl_write_memory`
- `incident_history`: Past incidents by component for repeat detection — use `adl_add_memory`

# MCP Server Tools

- `slack.post_message`: Post service status updates during incidents to operations and customer channels
