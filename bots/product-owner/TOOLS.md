# Data Access

- Query `cs_findings`: `adl_query_records` — filter by date range or category for customer support insights
- Query `ba_findings`: `adl_query_records` — filter by theme or domain for business analyst insights
- Query `mktg_findings`: `adl_query_records` — filter by campaign or channel for marketing insights
- Query `tickets`: `adl_query_records` — filter by status, category, or feature_request tag
- Query `contacts`: `adl_query_records` — filter by segment or tier for customer context
- Query `campaigns`: `adl_query_records` — filter by status or type for marketing context
- Write `po_findings`: `adl_upsert_record` — ID format `po_{YYYYMMDD}_{seq}`, required fields: finding_type, theme, recommendation
- Write `po_alerts`: `adl_upsert_record` — ID format `po_alert_{YYYYMMDD}_{seq}`, required fields: severity, signal_type, impact
- Write `gh_issues`: `adl_upsert_record` — ID format `gh_{YYYYMMDD}_{seq}`, required fields: title, body, labels, priority, user_stories, acceptance_criteria, customer_signals, source_findings
- Write `feature_requests`: `adl_upsert_record` — ID format `feat_{YYYYMMDD}_{seq}`, required fields: title, description, signal_count, priority

# Memory Usage

- `working_notes`: Current analysis context and cross-run notes — use `adl_write_memory`
- `learned_patterns`: Detected feedback clustering patterns — use `adl_add_memory` to append new observations
- `customer_signals`: Feature request frequency and impact scores — use `adl_add_memory` to track growing demand
- `backlog_priorities`: Top 10 ranked features — use `adl_write_memory` to overwrite with current ranking

# MCP Server Tools

- Connected issue tracker: create prioritized feature requests or bug reports
- Connected issue tracker: check existing issues to avoid duplicates
- Connected issue tracker: search for related issues before creating new ones
- Any other connected issue tracker the workspace uses: create prioritized issues the same way
- Any other connected issue tracker the workspace uses: search existing issues to avoid duplicates

# Sub-Agent Orchestration

- `signal-collector`: Delegates customer feedback aggregation from support, marketing, and analyst sources
- `rice-scorer`: Delegates feature prioritization using RICE scoring (Reach, Impact, Confidence, Effort)
- `issue-drafter`: Delegates structured GitHub issue spec creation with user stories and acceptance criteria
