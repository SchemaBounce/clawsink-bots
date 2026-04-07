## Brand Audit

Evaluate content against brand guidelines and track compliance scores over time.

### Steps

1. `adl_query_records(entity_type="brand_guidelines")` — load tone, colors, typography, and messaging pillars from the North Star zone.
2. `adl_query_records(entity_type="content_items", filters={"created_at_gte": "<30_days_ago>"})` — fetch recent content and brand assets for audit.
3. Score each item 1-10 on four dimensions: tone alignment, visual consistency, terminology usage, messaging clarity. Compute average as `compliance_score`.
4. Flag items scoring below 6 on any dimension — these require corrective action.
5. `adl_upsert_record(entity_type="brand_findings")` — one per audited item: `content_id`, `content_type`, `scores`, `compliance_score`, `deviations[]`, `corrections[]`, `audited_at`.
6. `adl_query_records(entity_type="brand_findings", filters={"audited_at_gte": "<90_days_ago>"})` — compute 90-day trend. Track rolling average compliance score.
7. If rolling average drops below 7.0: `adl_send_message(type="alert")` to the executive-assistant agent with trend data and top 3 systemic deviations.

### Output Schema

- `entity_type`: `"brand_findings"`
- Required fields: `content_id`, `content_type`, `scores`, `compliance_score`, `deviations`, `corrections`, `audited_at`

### Anti-Patterns

- NEVER audit without loading current brand_guidelines first — stale guidelines produce false flags.
- NEVER report a deviation without a specific correction — "off-brand" alone is not actionable.
- NEVER alert on single low-scoring items — only escalate when the rolling average drops below 7.0.
