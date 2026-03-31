# Data Access

- Query `*_findings` (sre, de, ba, acct, cs, inv, legal, mktg, ea, sec, po): `adl_query_records` — filter by `created_at > {last_run_timestamp}` to review all new bot outputs across 11 streams
- Write `mentor_findings`: `adl_upsert_record` — ID format `mf_{bot_name}_{date}`, required: bot_name, score, evidence, coaching_recommendation
- Write `mentor_alerts`: `adl_upsert_record` — ID format `ma_{issue}_{date}`, required: severity, affected_bots, issue_description
- Write `team_health_reports`: `adl_upsert_record` — ID format `thr_{period_end}`, required: period, overall_score, bot_scores, highlights, coaching

# Memory Usage

- `working_notes`: current run state and analysis context — use `adl_write_memory`
- `learned_patterns`: detected team-level performance patterns — use `adl_add_memory`
- `team_baselines`: per-bot performance baseline scores for regression detection — use `adl_write_memory`
- `improvement_log`: coaching recommendation follow-through tracking — use `adl_add_memory`

# Sub-Agent Orchestration

- `findings-aggregator`: collects and normalizes findings from all 11 bot streams
- `quality-scorer`: evaluates individual bot performance across scoring dimensions
- `health-report-writer`: composes the structured team health report with scores and coaching
