# Data Access

- Query `gh_issues`: `adl_query_records`, filter by `assignee` or `labels` for issues assigned to this bot, by `created_at` for new work
- Query `implementation_plans`: `adl_query_records`, read plans handed down by software-architect before writing a new one
- Write `code_sessions`: `adl_upsert_record`, ID format `session-{plan_id}`, include status, files changed, test output, retry count
- Write `pull_requests`: `adl_upsert_record`, ID format `pr-{plan_id}`, include PR URL, linked issues, plan reference, review status

# Memory Usage

- `working_notes`: active session ID and progress for cross-run continuity, `adl_write_memory` to save, `adl_read_memory` to resume
- `codebase_map`: module layout and ownership for scoping, `adl_read_memory` before planning, update after each session

# MCP Server Tools

## code-sandbox (the session loop)

1. `code_session_create`: pass `repo`, `base_branch`, `prompt` (the plan), and optionally `engine` (default `claude-code`), `model`, `max_budget_usd`
2. `code_session_status`: poll until the session leaves `running`. States: pending, provisioning, cloning, running, awaiting_approval, awaiting_resume, completed, failed, cancelled
3. `code_session_execute`: send a follow-up prompt when the session is `awaiting_resume` (test failures, clarification)
4. `code_session_diff`: review the full diff before requesting a push, confirm it matches the plan scope
5. `code_session_push`: request the push to a feature branch. Agent-initiated pushes escalate to the Inbox; wait for approval, do not retry the push
6. `code_session_result`: collect summary, files changed, and test output for the `code_sessions` record
7. `code_session_cancel`: tear down a session after 2 failed retries or when scope is invalidated

## github

- `github.issues`: read issue details and comments for context when planning
- `github.pull_requests`: confirm the PR opened after an approved push, add labels and link issues
