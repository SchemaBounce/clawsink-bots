# Data Access

- Query `leads`: `adl_query_records` entity_type=`leads` — sort oldest first, filter to records with no matching `receipt` (metric="first_touch_drafted") for that lead's entityId yet.
- Write `receipt`: `adl_upsert_record` entity_type=`receipt` — entityId format `receipt_{agentSlug}_{metric}_{subject}` for lead-scoped receipts (deterministic per lead and metric, so an upsert can never overwrite a different receipt), or `receipt_{agentSlug}_{metric}_{occurredAt}` for run-scoped receipts with no lead (for example `no_leads_synced`). Fields `{ kind: "receipt", metric, value, unit, subject, occurredAt, agentSlug }`. `subject` is always the lead record's entityId, never its email or name.
- Read `external_action`: `adl_query_records` entity_type=`external_action` — filter `id` = an action id captured from a prior gated send call, to check `pending_approval` / `approved` / `executed` / `rejected` status before deciding to escalate or confirm latency.

# Memory Usage

- `bot:lead-responder:run:state`: last processed lead id/timestamp and consecutive-empty-run count — `adl_write_memory` each run, `adl_read_memory` at the start of every run.
- `bot:lead-responder:northstar`: `response_sla_hours` (response-time target) and `demo_booking_url` (optional scheduling link to offer in the draft) — read only, seeded by `data-seeds/zone1-north-star.json`, editable by the workspace owner via the bot's setup steps.

# Connected Tools

The first-touch email is sent with a connected email tool. Find the right tool with the server's tool list or `adl_tool_search`, read its description, then call it. Never assume a tool name ahead of discovery.

Send a short personal email to the new sales inquiry, addressed to the email from the leads record, with a subject and body.

This is a mutating action, so the runtime intercepts it: instead of sending, it creates a pending `external_action` record and returns its id (`act_...`) with a refusal message. That refusal is the intended checkpoint, not an error. Capture the `act_...` id and write the `first_touch_drafted` receipt with that id inside `fields.actionId`. A human approves or rejects in Inbox > Actions; the runtime re-executes automatically on approval. Never re-call with a fabricated `_sb_action_id` and never ask for approval any other way.

# Run Order

1. `adl_read_memory` namespace `bot:lead-responder:run:state` key `last_run_state`.
2. `adl_read_memory` namespace `bot:lead-responder:northstar` keys `response_sla_hours`, `demo_booking_url`.
3. `adl_read_messages`, pick up any ad hoc `request` from executive-assistant.
4. `adl_query_records` entity_type=`leads`, oldest first. If the entity type is empty or errors, write one receipt (`metric="no_leads_synced"`, `value=1`, `unit="count"`) and stop for this run.
5. For each lead with no `first_touch_drafted` receipt: compose a specific, short first-touch (or reschedule, if `data.demoStatus == "no_show"`) that references what the lead actually said, then send it with the connected email tool. Capture the parked `act_...` id. Write a `first_touch_drafted` receipt (`value` = seconds between the lead's `createdAt` and now, `unit="seconds"`) with that id in `fields.actionId`.
6. For prior receipts whose `actionId` is still `pending_approval` past `response_sla_hours`: `adl_send_message` type=`alert` to `executive-assistant` with the action id and hours waited.
7. For prior receipts whose `actionId` now shows `status="executed"` in `external_action`: write a `first_touch_latency_seconds` receipt (`value` = seconds between the lead's `createdAt` and the action's `executed_at`, `unit="seconds"`).
8. `adl_write_memory` namespace `bot:lead-responder:run:state` key `last_run_state` with `{ run_at, leads_seen, drafts_submitted, escalations_sent, consecutive_empty_runs }`.

# Sub-Agent Orchestration

None. This bot's per-run workload is small (a handful of leads, a handful of tool calls); it does not spawn sub-agents.
