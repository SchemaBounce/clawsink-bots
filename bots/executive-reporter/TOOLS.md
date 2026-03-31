# Data Access

- Query `transactions`: `adl_query_records` — filter by `created_at`, `category` for financial overview
- Query `invoices`: `adl_query_records` — filter by `status`, `created_at` for accounts payable/receivable summary
- Query `acct_findings`: `adl_query_records` — filter by `severity` for finance domain highlights
- Query `tasks`: `adl_query_records` — filter by `status`, `sprint` for engineering velocity
- Query `stories`: `adl_query_records` — filter by `status`, `created_at` for product delivery tracking
- Query `bugs`: `adl_query_records` — filter by `severity`, `status` for quality metrics
- Query `velocity_metrics`: `adl_query_records` — filter by `period` for engineering throughput trends
- Query `experiments`: `adl_query_records` — filter by `status` for active experiment status
- Query `experiment_metrics`: `adl_query_records` — filter by `experiment_id` for experiment results
- Query `conversion_funnels`: `adl_query_records` — filter by `funnel_name`, `period` for conversion analytics
- Query `inventory_items`: `adl_query_records` — filter by `status`, `stock_level` for operations overview
- Query `support_tickets`: `adl_query_records` — filter by `severity`, `status` for support health
- Query `incidents`: `adl_query_records` — filter by `severity`, `status` for active incident impact
- Write `executive_summaries`: `adl_upsert_record` — ID format: `exec-summary-{period}-{date}`, required: period, tldr, key_metrics, changes, risks, recommended_actions
- Write `kpi_reports`: `adl_upsert_record` — ID format: `kpi-report-{period}-{date}`, required: period, kpis (array with value/baseline/change/status)

# Memory Usage

- `reporting_templates`: learned report structure preferences — use `adl_write_memory` for structured template data
- `kpi_baselines`: established KPI baseline values for trend comparison — use `adl_write_memory` for structured baseline data
- `stakeholder_preferences`: learned preferences for report detail level and format — use `adl_add_memory` for unstructured feedback notes

# Sub-Agent Orchestration

- `data-collector`: spawn to gather and normalize data across all domain entity types
- `kpi-monitor`: spawn for KPI baseline comparison and deviation detection
- `report-writer`: spawn to produce the formatted executive summary from collected data and KPI analysis
