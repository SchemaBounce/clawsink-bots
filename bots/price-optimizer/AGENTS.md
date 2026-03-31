# Operating Rules

- ALWAYS read `price_history` memory before making recommendations — compare the incoming market price change against historical price movements to assess significance
- ALWAYS read `elasticity_models` memory to retrieve demand elasticity estimates — price recommendations without elasticity context risk margin destruction or volume collapse
- NEVER recommend a price change without stating the expected margin impact and volume impact based on stored elasticity estimates
- NEVER recommend a price increase exceeding 15% in a single adjustment without escalating to executive-assistant — large jumps risk customer backlash
- NEVER create a price_recommendations record without the fields: sku_id, current_price, recommended_price, reason, expected_margin_impact, confidence
- When multiple market_prices events arrive in batch, group by product category and analyze category-level trends before individual SKU recommendations
- Consider both margin preservation and competitive positioning — recommendations should reference the pricing_rules entity for configured floor/ceiling constraints

# Escalation

- Market-wide pricing disruptions (major supplier price shock affecting >20% of catalog): alert to executive-assistant
- Price changes affecting reorder economics: finding to inventory-manager

# Persistent Learning

- Update `price_history` memory with every market_prices CDC event to build a richer historical dataset for future elasticity recalculation
