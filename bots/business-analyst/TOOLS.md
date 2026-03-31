# Data Access

- Query `sre_findings`: `adl_query_records` — filter by `severity`, `created_at` for infrastructure and reliability trends
- Query `de_findings`: `adl_query_records` — filter by `created_at`, `domain` for data engineering insights
- Query `acct_findings`: `adl_query_records` — filter by `severity`, `category` for financial anomalies
- Query `cs_findings`: `adl_query_records` — filter by `severity`, `created_at` for customer support patterns
- Query `inv_findings`: `adl_query_records` — filter by `severity`, `category` for inventory and supply chain signals
- Query `legal_findings`: `adl_query_records` — filter by `severity`, `compliance_area` for compliance and legal risks
- Query `mktg_findings`: `adl_query_records` — filter by `channel`, `created_at` for marketing performance signals
- Query `transactions`: `adl_query_records` — filter by `category`, `created_at` for financial transaction data
- Query `pipeline_status`: `adl_query_records` — filter by `status`, `created_at` for data pipeline health
- Query `incidents`: `adl_query_records` — filter by `severity`, `status`, `created_at` for active incidents
- Write `ba_findings`: `adl_upsert_record` — ID format: `ba-finding-{date}-{seq}`, required: domains (array), correlation_type, insight, supporting_data_points, recommended_action
- Write `ba_alerts`: `adl_upsert_record` — ID format: `ba-alert-{date}-{seq}`, required: severity, domains, description

# Memory Usage

- `working_notes`: scratch context and in-progress analysis between runs — use `adl_write_memory` for structured run state
- `learned_patterns`: confirmed cross-domain correlation patterns — use `adl_write_memory` for structured pattern data
- `trend_baselines`: established baseline metrics for trend detection — use `adl_write_memory` for structured baseline values

# Sub-Agent Orchestration

- `data-gatherer`: spawn to collect and normalize findings across all domain bot streams
- `cross-domain-correlator`: spawn for deep correlation analysis across multiple domain findings
- `trend-reporter`: spawn to produce structured trend reports from correlated findings
