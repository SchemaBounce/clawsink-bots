# Data Access

- Query `*_findings` (sre, de, ba, acct, cs, inv, legal, mktg, sec, po, mentor, opt, ea): `adl_query_records` — filter by `created_at > {last_run_timestamp}` to get all new findings across domains in a single sweep
- Query `*_alerts` (sre, de, acct, cs, inv, legal, mktg, sec, po, mentor, opt): `adl_query_records` — every alert must be triaged, never skipped
- Query `tasks`: `adl_query_records` — filter by `status` for open/pending action items
- Query `platform_health_reports`: `adl_query_records` — infrastructure health context for briefings
- Query `team_health_reports`: `adl_query_records` — bot team performance from mentor-coach
- Write `ea_findings`: `adl_upsert_record` — ID format `eaf_{topic}_{date}`, required: priority, source_bots, summary, recommendation
- Write `ea_alerts`: `adl_upsert_record` — ID format `eaa_{topic}_{date}`, required: severity, action_required, source
- Write `tasks`: `adl_upsert_record` — ID format `task_{assignee}_{date}_{seq}`, required: assignee, description, due_date, status

# Memory Usage

- `working_notes`: current run state and last run timestamp — use `adl_write_memory`
- `learned_patterns`: recurring cross-domain patterns and briefing templates — use `adl_add_memory`
- `follow_ups`: tracked action items and their completion status — use `adl_write_memory`

# MCP Server Tools

- `slack.post_message`: post daily briefings and critical alerts to leadership channels

# Sub-Agent Orchestration

- `cross-domain-synthesizer`: merges findings from all domains into prioritized briefing items
- `followup-tracker`: monitors action items across runs and flags overdue tasks
- `request-router`: routes cross-domain requests to the appropriate specialist bot
