# Data Access

- Query `inventory`: `adl_query_records` — filter by SKU or warehouse, compare quantity against thresholds
- Query `reorder_rules`: `adl_query_records` — filter by SKU to get min/max quantities, preferred vendors, lead times
- Write `inventory_alerts`: `adl_upsert_record` — ID format `inv_alert_{SKU}_{YYYYMMDD}`, required fields: sku, current_level, threshold, severity
- Write `reorder_requests`: `adl_upsert_record` — ID format `reorder_{SKU}_{YYYYMMDD}`, required fields: sku, recommended_qty, vendor, lead_time

# Memory Usage

- `stock_levels`: Running inventory positions per SKU — use `adl_write_memory` to overwrite after each CDC event
- `reorder_thresholds`: Configured reorder points per SKU — use `adl_write_memory` when thresholds are adjusted

# Sub-Agent Orchestration

- `threshold-evaluator`: Delegates stock level vs threshold comparison logic
- `reorder-calculator`: Delegates reorder quantity calculations based on rules and consumption
- `alert-dispatcher`: Delegates alert routing and deduplication checks
