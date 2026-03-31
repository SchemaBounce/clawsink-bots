# Data Access

- Query `transactions`: `adl_query_records` — filter by `created_at` for CDC-triggered new entries, `amount` for threshold checks, `merchant_category` for pattern matching
- Query `fraud_rules`: `adl_query_records` — read configured fraud detection rules and thresholds
- Write `fraud_scores`: `adl_upsert_record` — ID format: `fraud-score-{txn_id}`, required: transaction_id, risk_score (0-100), signals, confidence
- Write `fraud_alerts`: `adl_upsert_record` — ID format: `fraud-alert-{date}-{seq}`, required: transaction_id, risk_score, reason, recommended_action

# Memory Usage

- `fraud_patterns`: known fraud signatures and behavioral indicators — use `adl_write_memory` for structured pattern data (anonymized signals only, never raw amounts or account numbers)
- `risk_thresholds`: current risk score thresholds from North Star risk_policy — use `adl_write_memory` for structured threshold values

# MCP Server Tools

- `stripe.list_charges`: cross-reference transaction details for suspicious charge patterns
- `stripe.list_disputes`: identify disputed charges that may correlate with fraud signals

# Sub-Agent Orchestration

- `transaction-scorer`: spawn for individual transaction risk scoring when processing batch events
- `pattern-analyzer`: spawn for deep pattern analysis across historical fraud signals
- `false-positive-reviewer`: spawn to review borderline scores and reduce false positive rate
