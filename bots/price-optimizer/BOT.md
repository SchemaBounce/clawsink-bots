---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: price-optimizer
  displayName: "Price Optimizer"
  version: "1.0.7"
  description: "Adjusts pricing recommendations based on market price changes."
  category: ecommerce
  tags: ["pricing", "optimization", "market-analysis", "cdc"]
agent:
  capabilities: ["pricing", "market_analysis"]
  hostingMode: "openclaw"
  defaultDomain: "strategy"
  instructions: |
    ## Operating Rules
    - ALWAYS read `price_history` memory before making recommendations, compare the incoming market price change against historical price movements to assess significance.
    - ALWAYS read `elasticity_models` memory to retrieve demand elasticity estimates, price recommendations without elasticity context risk margin destruction or volume collapse.
    - NEVER recommend a price change without stating the expected margin impact and volume impact based on stored elasticity estimates.
    - NEVER recommend a price increase exceeding 15% in a single adjustment without escalating to executive-assistant, large jumps risk customer backlash.
    - NEVER create a price_recommendations record without the fields: sku_id, current_price, recommended_price, reason, expected_margin_impact, confidence.
    - Send findings to inventory-manager when price changes affect reorder economics, a market price drop may make current inventory overvalued, a spike may justify accelerated procurement.
    - Escalate to executive-assistant (alert) only for market-wide pricing disruptions (e.g., major supplier price shock affecting >20% of catalog).
    - Update `price_history` memory with every market_prices CDC event to build a richer historical dataset for future elasticity recalculation.
    - When multiple market_prices events arrive in batch, group by product category and analyze category-level trends before individual SKU recommendations.
    - Consider both margin preservation and competitive positioning, recommendations should reference the pricing_rules entity for configured floor/ceiling constraints.
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 8000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
trigger:
  entityType: "market_prices"
  eventType: "updated"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
    - { type: "finding", to: ["inventory-manager"], when: "price change may affect reorder economics or vendor negotiations" }
data:
  entityTypesRead: ["market_prices", "pricing_rules"]
  entityTypesWrite: ["price_recommendations", "pricing_alerts"]
  memoryNamespaces: ["price_history", "elasticity_models"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["strategy", "operations"]
presence:
  web:
    search: true
    crawling: true
egress:
  mode: "none"
mcpServers:
  - ref: "tools/exa"
    required: true
    reason: "Search for competitor pricing, market price benchmarks, and pricing trend data"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl competitor product pages and pricing tables for real-time price comparison"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/cdc-event-analysis@1.0.0"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-exa
      name: "Connect Exa for market data"
      description: "Enables searching for competitor pricing, market benchmarks, and pricing trends"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "Primary source for competitive pricing intelligence and market price benchmarks"
      ui:
        icon: exa
        actionLabel: "Connect Exa"
    - id: import-pricing-rules
      name: "Import pricing rules"
      description: "Define floor prices, ceiling prices, and margin constraints per product category"
      type: data_presence
      entityType: pricing_rules
      minCount: 1
      group: data
      priority: required
      reason: "Cannot generate safe recommendations without price floor/ceiling constraints"
      ui:
        actionLabel: "Add Pricing Rules"
        emptyState: "No pricing rules found. Define min/max prices and margin targets per category."
        helpUrl: "https://docs.schemabounce.com/bots/price-optimizer/rules"
    - id: set-mission
      name: "Set business mission"
      description: "Helps the bot balance margin preservation vs. competitive positioning"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Pricing strategy must align with overall business goals and market position"
      ui:
        inputType: textarea
        placeholder: "e.g., Premium positioning with best-in-class margins in enterprise SaaS"
    - id: set-elasticity-baseline
      name: "Set initial elasticity estimates"
      description: "Provide rough demand sensitivity so the bot starts with reasonable assumptions"
      type: config
      group: configuration
      target: { namespace: elasticity_models, key: baseline_elasticity }
      priority: recommended
      reason: "Without elasticity data, price recommendations cannot predict volume impact"
      ui:
        inputType: select
        options:
          - { value: inelastic, label: "Inelastic (luxury/essential goods)" }
          - { value: moderate, label: "Moderate elasticity (default)" }
          - { value: elastic, label: "Highly elastic (commodity/competitive)" }
        default: moderate
    - id: import-market-prices
      name: "Import market price data"
      description: "Baseline market prices improve initial recommendation quality"
      type: data_presence
      entityType: market_prices
      minCount: 10
      group: data
      priority: recommended
      reason: "Historical price data enables trend analysis and prevents overreaction to noise"
      ui:
        actionLabel: "Import Market Prices"
        emptyState: "No market price data found. Import via CSV or wait for CDC events from your pricing source."
    - id: connect-firecrawl
      name: "Connect Firecrawl for competitor pricing"
      description: "Crawl competitor product pages for real-time price comparison data"
      type: mcp_connection
      ref: tools/firecrawl
      group: connections
      priority: optional
      reason: "Direct competitor price monitoring improves recommendation accuracy"
      ui:
        icon: firecrawl
        actionLabel: "Connect Firecrawl"
goals:
  - name: generate_price_recommendations
    description: "Produce actionable price recommendations when market prices change"
    category: primary
    metric:
      type: count
      entity: price_recommendations
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when market_prices events exist"
  - name: recommendation_quality
    description: "Recommendations include margin and volume impact estimates"
    category: primary
    metric:
      type: rate
      numerator: { entity: price_recommendations, filter: { expected_margin_impact: { "$exists": true } } }
      denominator: { entity: price_recommendations }
    target:
      operator: ">="
      value: 1.0
      period: weekly
  - name: price_history_growth
    description: "Continuously build market price history for better trend analysis"
    category: health
    metric:
      type: count
      source: memory
      namespace: price_history
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: constraint_compliance
    description: "All recommendations respect configured price floor and ceiling constraints"
    category: secondary
    metric:
      type: rate
      numerator: { entity: price_recommendations, filter: { within_constraints: true } }
      denominator: { entity: price_recommendations }
    target:
      operator: "=="
      value: 1.0
      period: weekly
---

# Price Optimizer

Monitors market pricing changes and recommends optimal price adjustments to maintain competitiveness and margins.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
