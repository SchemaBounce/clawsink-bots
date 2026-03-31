# Data Access

- Query `user_activity`: `adl_query_records` — filter by `account_id`, `created_at` for CDC-triggered events, `activity_type` for engagement signals
- Query `engagement_metrics`: `adl_query_records` — filter by `account_id`, `period` for baseline comparison, `metric_type` for specific signals (logins, feature_usage, session_duration)
- Write `churn_scores`: `adl_upsert_record` — ID format: `churn-{account_id}-{date}`, required: account_id, risk_score, time_window, corroborating_signals, confidence
- Write `retention_alerts`: `adl_upsert_record` — ID format: `retention-alert-{account_id}-{date}`, required: account_id, severity, risk_factors, recommended_action

# Memory Usage

- `activity_baselines`: per-account and cohort-level activity baselines — use `adl_write_memory` for structured baseline data
- `churn_indicators`: learned churn signal patterns and multi-signal combinations — use `adl_write_memory` for structured pattern data

# MCP Server Tools

- `stripe.list_subscriptions`: check subscription status and billing signals that correlate with churn
- `stripe.list_charges`: detect payment failures or downgrades as churn indicators

# Sub-Agent Orchestration

- `engagement-scorer`: spawn for individual account engagement scoring against baselines
- `risk-assessor`: spawn for multi-signal risk assessment combining activity, billing, and support data
- `cohort-analyzer`: spawn for cohort-level churn pattern analysis and trend detection
