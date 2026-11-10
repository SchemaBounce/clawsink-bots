# Data Access

- Query `gh_issues`: `adl_query_records` — filter by `assignee` or `labels` for issues assigned to this bot, by `created_at` for new requests
- Issues synced from a connected code host are `tasks` records, not `gh_issues`: `adl_query_records` on `tasks` filtered by `external_source`. The `tasks` schema says where the issue body is and how closing works; read the body before you judge an issue.
- Query `review_findings`: `adl_query_records` — filter by `severity` for high/critical findings requiring architectural response
- Query `architecture_decisions`: `adl_query_records` — filter by `module` to check prior decisions for consistency
- Write `implementation_plans`: `adl_upsert_record` — ID format `plan-{issue_id}`, include file changes, risk level, test strategy, architecture rationale
- Write `implementation_tickets`: `adl_upsert_record` — ID format `ticket-{plan_id}-{step}`, actionable developer instructions with file paths and test commands
- Write `architecture_decisions`: `adl_upsert_record` — ID format `adr-{date}-{topic}`, persist new patterns and design decisions

# Memory Usage

- `working_notes`: in-progress planning state for cross-run continuity — use `adl_write_memory` to save, `adl_read_memory` to resume
- `architecture_patterns`: prior architecture decisions for consistency checking — use `adl_add_memory` for new decisions, `adl_read_memory` before planning
- `codebase_map`: module dependencies and ownership for impact analysis — use `adl_read_memory` when scoping changes

# MCP Server Tools

- Connected code-hosting tool: read issue details, comments, and linked pull requests for context when creating implementation plans
- Connected code-hosting tool: search the codebase to understand module structure and find affected files
- Connected code-hosting tool: review recent pull requests to understand current development patterns

# Sub-Agent Orchestration

- `planner`: delegate deep issue analysis and structured implementation plan generation
