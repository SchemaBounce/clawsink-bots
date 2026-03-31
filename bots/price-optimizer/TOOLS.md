# Data Access

- Query `market_prices`: `adl_query_records` — filter by `created_at` for CDC-triggered events, `product_category` for category-level trends, `sku_id` for individual items
- Query `pricing_rules`: `adl_query_records` — filter by `sku_id` or `category` to retrieve floor/ceiling constraints and margin targets
- Write `price_recommendations`: `adl_upsert_record` — ID format: `price-rec-{sku_id}-{date}`, required: sku_id, current_price, recommended_price, reason, expected_margin_impact, confidence
- Write `pricing_alerts`: `adl_upsert_record` — ID format: `price-alert-{date}-{seq}`, required: severity, affected_category, description, catalog_impact_pct

# Memory Usage

- `price_history`: historical price movements per SKU and category — use `adl_write_memory` for structured time-series data, update with every CDC event
- `elasticity_models`: demand elasticity estimates per product category — use `adl_write_memory` for structured model parameters

# Sub-Agent Orchestration

- `market-scanner`: spawn for broad market price trend analysis across categories
- `elasticity-modeler`: spawn for demand elasticity recalculation when sufficient new price_history data accumulates
- `pricing-writer`: spawn for generating batch price recommendation records
