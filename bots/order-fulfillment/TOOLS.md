# Data Access

- Query `orders`: `adl_query_records` — filter by status (pending, processing), priority, shipping method
- Query `fulfillment_rules`: `adl_query_records` — filter by warehouse or shipping method for routing logic
- Write `fulfillment_tasks`: `adl_upsert_record` — ID format `task_{order_id}_{stage}`, required fields: order_id, status, stage, reason
- Write `order_status`: `adl_upsert_record` — ID format `status_{order_id}`, required fields: order_id, status, updated_reason

# Memory Usage

- `workflow_state`: Active fulfillment workflows and warehouse capacity — use `adl_write_memory` to track in-progress state
- `sla_targets`: SLA definitions per priority level and shipping method — use `adl_write_memory` when targets change

# Sub-Agent Orchestration

- `order-validator`: Delegates order validation, inventory checks, and eligibility verification
- `fulfillment-router`: Delegates warehouse selection and shipping method routing
- `fulfillment-recorder`: Delegates state transition recording and audit trail creation
