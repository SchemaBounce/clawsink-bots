# Data Access

- Query `pull_requests`: `adl_query_records` — filter by `created_at` for new PRs, by `status` for open reviews
- Query `code_diffs`: `adl_query_records` — filter by `pull_request_id` to get diffs for a specific PR
- Write `review_findings`: `adl_upsert_record` — ID format `rf-{pr_id}-{finding_index}`, include severity, file path, line number, fix suggestion
- Write `code_quality_metrics`: `adl_upsert_record` — ID format `cqm-{pr_id}`, aggregate quality scores per PR

# Memory Usage

- `review_patterns`: previously discussed and accepted patterns to avoid re-flagging — use `adl_read_memory` before each review
- `recurring_issues`: patterns appearing in 3+ PRs signaling systemic problems — use `adl_add_memory` when threshold is reached

# MCP Server Tools

- Connected code-hosting tool: fetch pull request metadata, diff content, and review comments
- Connected code-hosting tool: search for related issues when a code review finding maps to a known bug
- Connected code-hosting tool: search the codebase for pattern prevalence when evaluating severity

# Sub-Agent Orchestration

- `security-scanner`: delegate OWASP vulnerability and auth bypass checks
- `quality-checker`: delegate code complexity, naming, and test coverage analysis
- `pattern-tracker`: delegate recurring issue detection and cross-PR pattern matching
