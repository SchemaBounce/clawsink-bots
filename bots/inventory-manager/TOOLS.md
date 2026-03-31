# Data Access

- Query `transactions`: `adl_query_records` — filter by date range for consumption rate calculation, group by SKU
- Query `companies`: `adl_query_records` — filter by vendor ID for supplier performance and lead time data
- Write `inv_findings`: `adl_upsert_record` — ID format `inv_{YYYYMMDD}_{seq}`, required fields: finding_type, sku, recommendation, cost_impact
- Write `inv_alerts`: `adl_upsert_record` — ID format `inv_alert_{YYYYMMDD}_{seq}`, required fields: severity, sku, current_level, reorder_point

# Memory Usage

- `stock_levels`: Current inventory positions per SKU — use `adl_write_memory` to overwrite with latest snapshot
- `learned_patterns`: Consumption velocity, seasonal trends, vendor lead times — use `adl_add_memory` to append new observations
- `working_notes`: Procurement context, vendor evaluations, pending PO status — use `adl_write_memory` for current state

# Sub-Agent Orchestration

- `stock-analyst`: Delegates consumption rate analysis and trend detection across SKUs
- `procurement-recommender`: Delegates EOQ calculations and vendor selection recommendations
- `vendor-tracker`: Delegates vendor performance monitoring and lead time tracking
