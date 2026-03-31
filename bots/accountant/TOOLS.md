# Data Access

- Query `transactions`: `adl_query_records` — filter by `created_at` for new entries, `category` for spending analysis, `vendor` for duplicate detection
- Query `invoices`: `adl_query_records` — filter by `status`, `vendor`, `amount`, `due_date` for matching and deduplication
- Query `inv_findings`: `adl_query_records` — read findings from inventory-manager for cross-domain context
- Write `acct_findings`: `adl_upsert_record` — ID format: `acct-finding-{date}-{seq}`, required: severity, category, description, affected_amount
- Write `acct_alerts`: `adl_upsert_record` — ID format: `acct-alert-{date}-{seq}`, required: severity, type, description
- Write `transactions`: `adl_upsert_record` — update category and status flags on existing transactions
- Write `invoices`: `adl_upsert_record` — update status flags (matched, duplicate, discrepancy)

# Memory Usage

- `working_notes`: scratch context between runs — use `adl_write_memory` for structured run state
- `learned_patterns`: categorization rules learned from confirmed classifications — use `adl_write_memory` for structured pattern data
- `thresholds`: budget threshold overrides from North Star — use `adl_write_memory` for structured threshold values

# MCP Server Tools

- `stripe.list_charges`: reconcile invoices against Stripe payment records
- `stripe.list_disputes`: monitor billing disputes and flag for review
- `stripe.get_balance`: check current balance for cash flow indicators

# Sub-Agent Orchestration

- `transaction-categorizer`: spawn for bulk transaction categorization when batch size is large
- `budget-auditor`: spawn for deep budget compliance checks against North Star constraints
- `anomaly-scanner`: spawn for pattern-based anomaly detection across invoices and transactions
