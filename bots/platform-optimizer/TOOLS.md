# Data Access

- Query `agent_runs`: `adl_query_records` — filter by `agent_id` for per-agent analysis, by `status` for failed runs, by `created_at` for recent activity
- Query `dq_findings`: `adl_query_records` — cross-reference with entity type growth rates to identify schema drift
- Query `dq_scores`: `adl_query_records` — filter by `entity_type` for per-type quality trends
- Query `pipeline_status`: `adl_query_records` — filter by `pipeline_id` for pipeline optimization candidates
- Query `health_reports`: `adl_query_records` — aggregate health data for platform-wide analysis
- Query `infra_metrics`: `adl_query_records` — storage utilization, resource consumption trends
- Query `team_health_reports`: `adl_query_records` — cross-team performance comparisons
- Query `mentor_findings`: `adl_query_records` — coaching insights that affect optimization priorities
- Write `opt_findings`: `adl_upsert_record` — ID format `of-{dimension}-{date}`, include optimization type, evidence, expected impact
- Write `opt_alerts`: `adl_upsert_record` — ID format `oa-{issue_type}-{timestamp}`, critical platform health alerts
- Write `opt_recommendations`: `adl_upsert_record` — ID format `or-{target}-{action}`, actionable recommendations with ROI estimate
- Write `platform_health_reports`: `adl_upsert_record` — ID format `phr-{date}`, comprehensive daily health report

# Memory Usage

- `performance_baselines`: per-agent historical metrics for efficiency comparison — use `adl_read_memory` before flagging inefficiency
- `crystallization_tracker`: proposed patterns and their lifecycle status — use `adl_read_memory` to avoid re-proposals, `adl_add_memory` for new proposals
- `cost_metrics`: token consumption and cost trends across agents — use `adl_write_memory` to update aggregates
- `improvement_log`: adopted recommendations and their measured impact — use `adl_add_memory` to track outcomes

# Sub-Agent Orchestration

- `crystallization-analyst`: delegate pattern scanning, crystallization proposals, and token savings estimates
- `cost-analyzer`: delegate per-agent cost metrics, model downgrade modeling, and ROI estimates
