# Data Access

- Query `tickets`: `adl_query_records` — filter by `created_at > {last_run_timestamp}` for new tickets, by `status` for open/pending SLA checks
- Query `contacts`: `adl_query_records` — look up customer context when triaging tickets
- Query `companies`: `adl_query_records` — check account-level health and tier for prioritization
- Query `sre_findings`: `adl_query_records` — correlate infra issues with open ticket clusters
- Write `cs_findings`: `adl_upsert_record` — ID format `csf_{topic}_{date}`, required: severity, category, evidence
- Write `cs_alerts`: `adl_upsert_record` — ID format `csa_{account}_{date}`, required: severity, affected_customer, reason
- Write `tickets`: `adl_upsert_record` — update status, category, resolution on existing tickets

# Memory Usage

- `working_notes`: current run state, last run timestamp — use `adl_write_memory`
- `learned_patterns`: known ticket patterns and resolution templates — use `adl_add_memory`
- `customer_health`: per-account health context and trend data — use `adl_write_memory`

# MCP Server Tools

- `slack.list_channels` / `slack.post_message`: monitor support channels for customer issues and post escalation notifications

# Sub-Agent Orchestration

- `ticket-triager`: categorizes incoming tickets by severity and type
- `sentiment-analyzer`: evaluates customer sentiment from ticket content
- `response-drafter`: drafts initial responses for known ticket patterns
