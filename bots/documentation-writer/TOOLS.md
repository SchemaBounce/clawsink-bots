# Data Access

- Query `implementation_plans`: `adl_query_records` — filter by status="complete" to find implementations needing doc coverage
- Query `gh_issues`: `adl_query_records` — filter by labels or milestone to identify doc-related issues
- Write `doc_updates`: `adl_upsert_record` — ID format `docupdate_{plan_id}`, required fields: affected_files, change_type, specification, triggered_by
- Write `doc_findings`: `adl_upsert_record` — ID format `docfinding_{date}_{slug}`, required fields: gap_type, description, severity

# Memory Usage

- `doc_standards`: documentation conventions, style rules, file organization patterns — use `adl_write_memory` to cache standards loaded from North Star
- `working_notes`: in-progress doc analysis state, pending reviews — use `adl_write_memory` to save between runs

# MCP Server Tools

- `github.get_file_contents`: read existing documentation files to understand current state and structure
- `github.search_code`: find documentation files affected by an implementation change
- `notion.get_page`: read documentation pages in Notion workspace for gap analysis
