# Data Access

- Query `gh_issues`: `adl_query_records`, filter by `assignee` or `labels` for issues assigned to this bot, by `created_at` for new work
- Query `implementation_plans`: `adl_query_records`, read plans handed down by software-architect before writing a new one
- Write `code_sessions`: `adl_upsert_record`, ID format `session-{plan_id}`, include status, files changed, test output, retry count
- Write `pull_requests`: `adl_upsert_record`, ID format `pr-{plan_id}`, include PR URL, linked issues, plan reference, review status

# Memory Usage

- `working_notes`: active session ID and progress for cross-run continuity, `adl_write_memory` to save, `adl_read_memory` to resume
- `codebase_map`: module layout and ownership for scoping, `adl_read_memory` before planning, update after each session

# MCP Server Tools

## Code sessions (built into SchemaBounce, no connection needed)

1. `adl_start_code_session`: pass `task_id` and a prompt that stands alone (the plan). The platform writes the session's status, pull request link and any failure back onto the task
2. `adl_code_session_status`: follow the session until its work and checks are done
3. `adl_continue_code_session`: continue a failed, cancelled or expired session from its last checkpoint, for test failures or clarification
4. `adl_push_code_session`: with `open_pr`, while the session is still open. Agent pushes wait for a person in the Inbox unless the workspace turned that off; wait for approval, do not retry the push

## SchemaBounce Code Sessions connection (optional)

With this grant the `code_session_*` tools drive the same session step by step: `code_session_execute` sends a follow-up prompt, `code_session_diff` shows the full diff before a push, and `code_session_cancel` ends a session after 2 failed retries or when scope is invalidated.

## github

- Connected code-hosting tool: read issue details and comments for context when planning
- Connected code-hosting tool: confirm the pull request opened after an approved push, add labels and link issues
