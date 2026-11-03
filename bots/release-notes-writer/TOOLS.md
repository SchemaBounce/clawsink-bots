# Data Access

- Query `commits`: `adl_query_records` — filter by `created_at` for version range, consolidate multi-commit features into single line items
- Query `tickets`: `adl_query_records` — filter by `linked_commit` or `version` to correlate commits with ticket descriptions
- Write `release_notes`: `adl_upsert_record` — ID format `release-notes-{version}`, required fields: version, sections (breaking_changes, features, fixes, performance, internal)
- Write `changelogs`: `adl_upsert_record` — ID format `changelog-{version}`, required fields: version, entries, date

# Memory Usage

- `release_history`: Completed release notes for cross-release formatting consistency — use `adl_add_memory`
- `feature_categories`: Categorization conventions for consistent grouping across releases — use `adl_write_memory`

# MCP Server Tools

- Connected code-hosting tool: list commits in a version range for release note generation
- Connected code-hosting tool: list merged pull requests to correlate with changelog entries
