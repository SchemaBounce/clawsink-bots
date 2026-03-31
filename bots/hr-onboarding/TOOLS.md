# Data Access

- Query `employees`: `adl_query_records` — filter by `created_at > {last_run_timestamp}` for new hires, by `department` or `role` for template matching
- Query `onboarding_templates`: `adl_query_records` — look up template by role and department to generate checklists
- Write `onboarding_checklists`: `adl_upsert_record` — ID format `oc_{employee_id}_{date}`, required: employee_id, department, checklist_items, due_dates
- Write `hr_tasks`: `adl_upsert_record` — ID format `hrt_{employee_id}_{task}`, required: employee_id, task_name, responsible_party, due_date, status

# Memory Usage

- `onboarding_metrics`: per-process completion status and bottleneck tracking — use `adl_write_memory`
- `completion_rates`: aggregate trends across all onboarding processes — use `adl_write_memory`

# Sub-Agent Orchestration

- `checklist-generator`: creates role-specific onboarding checklists from templates
- `progress-tracker`: monitors checklist completion and flags stalled items
- `experience-analyzer`: evaluates onboarding experience quality and identifies improvement areas
