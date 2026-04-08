## Notification Dispatch

Route alerts through ADL messaging with severity-based escalation.

### Steps

1. `adl_list_agents` — discover active agents and their domains. Map recipient names to agent IDs.
2. `adl_query_records(entity_type="notification_rules")` — load channel preferences and escalation chains per recipient.
3. Classify alert severity: `critical` (page immediately), `high` (next cycle), `medium` (batch OK), `low` (daily digest).
4. `adl_send_message(type="alert")` for critical/high — one alert per recipient per run (platform limit: 5 messages/run, 1 alert/recipient/run).
5. `adl_send_message(type="finding")` for medium/low — batch into a single message per recipient with a DataPart summary.
6. On delivery failure: retry once, then `adl_request_escalation` with the original payload and failure reason.
7. `adl_upsert_record(entity_type="dispatch_log")` — log each dispatch with fields: `recipient`, `channel`, `severity`, `status` (delivered|failed|escalated), `timestamp`.

### Output Schema

- `entity_type`: `"dispatch_log"`
- Required fields: `alert_id`, `recipient`, `severity`, `channel`, `status`, `timestamp`, `retry_count`

### Anti-Patterns

- NEVER send more than 1 alert per recipient per run — batch lower-severity items into findings instead.
- NEVER skip the dispatch log — every notification must have an auditable record.
- NEVER guess agent IDs — call `adl_list_agents` first; names resolve automatically.
