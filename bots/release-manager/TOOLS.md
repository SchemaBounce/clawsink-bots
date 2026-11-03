# Data Access

- Query `releases`: `adl_query_records` — filter by `status` for pending/completed releases, by `version` for specific release lookup
- Query `changelogs`: `adl_query_records` — filter by `version_range` for changes in a release window
- Query `pull_requests`: `adl_query_records` — filter by `merged_at` since last release for aggregation into release notes
- Query `review_findings`: `adl_query_records` — filter by `status` (unresolved) to verify all findings are resolved before release
- Write `release_notes`: `adl_upsert_record` — ID format `release-notes-{version}`, required fields: version, categories, breaking_changes, summary
- Write `release_plans`: `adl_upsert_record` — ID format `release-plan-{version}`, required fields: version, target_date, blockers, readiness_status

# Memory Usage

- `release_history`: Past release versions, dates, and outcomes — use `adl_add_memory`
- `versioning_decisions`: Version bump rationale for each release — use `adl_write_memory`

# MCP Server Tools

- Connected code-hosting tool: create releases with tags and release notes
- Connected code-hosting tool: list merged pull requests for changelog aggregation
- Connected code-hosting tool: create release branches for version preparation
- Connected chat tool: announce releases to engineering channels
