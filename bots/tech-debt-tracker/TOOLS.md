# Data Access

- Query `review_findings`: `adl_query_records` — filter by `created_at` for new findings, by `severity` for prioritization
- Query `code_quality_metrics`: `adl_query_records` — filter by `module` for per-module analysis, by `metric_type` (coverage, complexity, duplication)
- Query `gh_issues`: `adl_query_records` — filter by `labels` for tech-debt tagged issues
- Write `tech_debt_items`: `adl_upsert_record` — ID format `tdi-{module}-{pattern}`, include severity, area, effort estimate, linked source findings
- Write `quality_trends`: `adl_upsert_record` — ID format `qt-{module}-{period}`, aggregate metrics per module and time period with trend direction

# Memory Usage

- `debt_patterns`: known systemic debt patterns with frequency counts — use `adl_read_memory` before classifying, `adl_add_memory` when 3+ findings match
- `working_notes`: in-progress analysis state for cross-run continuity — use `adl_write_memory` to save, `adl_read_memory` to resume

# MCP Server Tools

- `github.issues`: track technical debt issues across repositories, search for related open issues
