# Data Access

- Query `tasks`: `adl_query_records` — filter by `sprint_id` for current sprint items, by `status` for backlog/blocked, by `dependencies` for risk analysis
- Query `stories`: `adl_query_records` — filter by `priority` for backlog ordering, by `rice_score` for prioritization
- Query `bugs`: `adl_query_records` — filter by `severity` for P0/P1 bugs requiring sprint inclusion
- Query `velocity_metrics`: `adl_query_records` — filter by `sprint_id` for per-sprint velocity, aggregate for trailing averages
- Write `sprint_plans`: `adl_upsert_record` — ID format `sp-{sprint_id}`, include planned items, total story points, capacity percentage, dependency map
- Write `priority_recommendations`: `adl_upsert_record` — ID format `pr-{item_id}`, include RICE score breakdown and priority justification

# Memory Usage

- `sprint_history`: past sprint outcomes for retrospective analysis — use `adl_add_memory` after each sprint completion
- `velocity_trends`: trailing velocity data for capacity planning — use `adl_read_memory` before planning, `adl_write_memory` to update
- `team_capacity`: current team workload and availability — use `adl_read_memory` before assigning work

# MCP Server Tools

- `jira.sprints`: manage sprints, create and assign issues, track velocity in Jira
- `linear.cycles`: manage cycles, create and assign issues in Linear

# Sub-Agent Orchestration

- `rice-scorer`: delegate RICE score computation for backlog items
- `velocity-tracker`: delegate velocity trend analysis and capacity calculation
- `dependency-checker`: delegate cross-task dependency analysis and risk flagging
