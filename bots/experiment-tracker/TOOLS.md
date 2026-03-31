# Data Access

- Query `experiments`: `adl_query_records` — filter by status (active, completed, killed) or start_date range
- Query `experiment_metrics`: `adl_query_records` — filter by experiment_id and date range for time-series metric data
- Query `conversion_funnels`: `adl_query_records` — filter by experiment_id and variant to compare funnel performance
- Write `experiment_results`: `adl_upsert_record` — ID format `result_{experiment_id}_{YYYYMMDD}`, required fields: experiment_id, variant_a_stats, variant_b_stats, p_value, confidence_interval, sample_size
- Write `experiment_recommendations`: `adl_upsert_record` — ID format `rec_{experiment_id}`, required fields: experiment_id, recommendation (ship/kill/continue), rationale, effect_size, confidence_interval

# Memory Usage

- `experiment_log`: Active experiment tracking with current sample sizes and last evaluation dates — use `adl_write_memory` to overwrite with current state
- `significance_thresholds`: Configured p-value thresholds and minimum sample sizes per experiment — use `adl_write_memory` when thresholds change
- `winning_patterns`: Historical lift decay data for novelty effect detection — use `adl_add_memory` to append completed experiment outcomes

# Sub-Agent Orchestration

- `stats-calculator`: Delegates statistical significance calculations (chi-squared, t-test, confidence intervals)
- `novelty-detector`: Delegates lift decay analysis over time to catch novelty effects
- `experiment-summarizer`: Delegates weekly experiment status summaries and recommendation reports
