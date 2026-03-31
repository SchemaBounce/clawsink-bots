# Data Access

- Query `customers`: `adl_query_records` — filter by `created_at > {last_run_timestamp}` for new signups, or by customer ID from CDC trigger event
- Query `onboarding_templates`: `adl_query_records` — look up template matching the customer's plan tier or deal type
- Write `onboarding_tasks`: `adl_upsert_record` — ID format `ot_{customer_id}_{step}`, required: customer_id, step_name, due_date, status
- Write `welcome_messages`: `adl_upsert_record` — ID format `wm_{customer_id}_{sequence}`, required: customer_id, message_content, send_order

# Memory Usage

- `onboarding_progress`: per-customer state (current step, stall detection timestamps) — use `adl_write_memory`
- `completion_rates`: aggregate metrics (completion rate, avg time, stall points) — use `adl_write_memory`

# Sub-Agent Orchestration

- `checklist-generator`: creates the full onboarding task sequence from templates
- `milestone-tracker`: monitors per-customer progress and detects stalls
- `welcome-sequencer`: generates personalized welcome messages based on customer context
