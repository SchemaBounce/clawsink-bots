## Daily Briefing

Generate a prioritized cross-domain briefing from findings, alerts, and metrics since last run.

### Steps

1. `adl_query_records(entity_type="briefing_checkpoints", filters={"type": "daily"})` — get last briefing timestamp. Default to 24h ago if none exists.
2. `adl_query_records` across finding/alert entity types (`*_findings`, `*_alerts`) with `created_at > <last_timestamp>`. Collect all new items.
3. `adl_query_records(entity_type="north_star")` — load quarterly priorities from Zone 1 for relevance ranking.
4. Rank items: critical alerts first, then by alignment to quarterly priorities, then by recency.
5. Group into domains: operations, finance, support, growth, compliance. Max 5 items per domain.
6. `adl_upsert_record(entity_type="briefings")` — store: `briefing_date`, `period_start`, `period_end`, `critical_items[]`, `domain_sections[]`, `action_items[]`, `metrics_snapshot`, `generated_at`.
7. `adl_upsert_record(entity_type="briefing_checkpoints")` — update checkpoint with current timestamp.
8. `adl_send_message(type="finding")` to all active agents (via `adl_list_agents`) with a compact DataPart: critical count, action item count, briefing entity_id.

### Output Schema

- `entity_type`: `"briefings"`
- Required fields: `briefing_date`, `period_start`, `period_end`, `critical_items`, `domain_sections`, `action_items`, `generated_at`

### Anti-Patterns

- NEVER generate a briefing without checking the checkpoint — duplicate briefings waste agent cycles.
- NEVER include more than 5 items per domain — brevity is the point; link to full findings for detail.
- NEVER send the full briefing body as a message — send a DataPart summary with the briefing entity_id for on-demand lookup.
