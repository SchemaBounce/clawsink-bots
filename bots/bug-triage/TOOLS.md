# Data Access

- Query `bug_reports`: `adl_query_records` — filter by `created_at` for new reports, by `status` for open bugs, by `category` for domain filtering
- Query `team_capacity`: `adl_query_records` — check current team workload before routing assignments
- Write `triage_decisions`: `adl_upsert_record` — ID format `td-{bug_id}`, include severity (P0-P4), category, routing target, justification
- Write `severity_scores`: `adl_upsert_record` — ID format `ss-{bug_id}`, include score, factors, and confidence level

# Memory Usage

- `bug_patterns`: known bug patterns and prior triage decisions for duplicate detection — use `adl_read_memory` before triage, `adl_add_memory` after resolution
- `resolution_times`: historical fix timelines per severity/category — use `adl_add_memory` to track, `adl_read_memory` to estimate ETAs

# MCP Server Tools

- `github.issues`: create bug issues, search for duplicates, apply labels and assign owners
- `jira.issues`: create and track bugs in Jira projects when workspace uses Jira
- `linear.issues`: create and track bugs in Linear when workspace uses Linear

# Sub-Agent Orchestration

- `severity-scorer`: delegate severity assessment using impact analysis and affected user estimation
- `duplicate-detector`: delegate cross-referencing new reports against existing open bugs
- `pattern-analyzer`: delegate pattern matching against historical bug data for root cause hints
