---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: inventory-manager
  displayName: "Inventory & Acquisition Manager"
  version: "1.0.7"
  description: "Stock level monitoring, reorder calculations, vendor tracking, acquisition pipeline management."
  category: operations
  tags: ["inventory", "stock", "vendors", "reorder", "acquisition", "procurement"]
agent:
  capabilities: ["procurement", "operations"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
  instructions: |
    ## Operating Rules
    - ALWAYS read `stock_levels` memory and `learned_patterns` memory before analysis, reorder decisions must factor in consumption velocity and seasonal patterns from prior runs.
    - ALWAYS check North Star keys (budget_constraints, reorder_policy) before generating reorder recommendations, procurement must respect configured policies.
    - NEVER issue a reorder recommendation without calculating the economic order quantity (EOQ) or justifying the quantity based on consumption rate and lead time.
    - NEVER approve a vendor switch or price increase acceptance without writing an inv_findings record documenting the cost impact analysis.
    - When inventory-alert sends a reorder evaluation alert, prioritize it. This means stock is already below threshold and time-sensitive.
    - Send stock level changes affecting fulfillment capacity to order-fulfillment (alert) so pending orders can be managed proactively.
    - Send cost trends and reorder recommendations to business-analyst and accountant (finding) for financial planning visibility.
    - Escalate to executive-assistant (alert) only for critical stock-outs or supply chain disruptions affecting multiple SKUs.
    - When price-optimizer sends findings about price changes, evaluate impact on reorder economics, adjust reorder quantities or vendor selection if margins shift.
    - When marketing-growth sends demand forecast findings, factor projected demand into reorder timing calculations.
    - Use automation-first principle: deterministic reorder triggers (stock below threshold + no pending PO) should become `adl_create_trigger` automations.
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
schedule:
  default: "@every 8h"
  recommendations:
    light: "@daily"
    standard: "@every 8h"
    intensive: "@every 4h"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "accountant"] }
    - { type: "finding", from: ["marketing-growth", "price-optimizer"] }
    - { type: "alert", from: ["inventory-alert"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical stock-out or supply chain disruption" }
    - { type: "finding", to: ["business-analyst", "accountant"], when: "cost trend or reorder recommendation" }
    - { type: "alert", to: ["order-fulfillment"], when: "stock level changes that affect fulfillment capacity" }
data:
  entityTypesRead: ["transactions", "companies"]
  entityTypesWrite: ["inv_findings", "inv_alerts"]
  memoryNamespaces: ["working_notes", "learned_patterns", "stock_levels"]
zones:
  zone1Read: ["mission", "industry", "budget_constraints", "reorder_policy"]
  zone2Domains: ["operations", "strategy"]
presence:
  email:
    required: true
    provider: agentmail
  web:
    search: true
    browsing: true
egress:
  mode: "none"
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send reorder alerts, stock reports, and vendor communications to procurement teams"
  - ref: "tools/exa"
    required: true
    reason: "Search for supplier pricing, lead time data, and supply chain disruption news"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse vendor portals and supplier catalogs to verify pricing and availability"
  - ref: "tools/composio"
    required: false
    reason: "Connect to ERP, procurement, and supply chain SaaS platforms for order management"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/data-ops@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
toolPacks:
  - ref: "packs/ecommerce-toolkit@1.0.0"
    reason: "Inventory calculations, reorder points, and safety stock analysis"
  - ref: "packs/data-transform@1.0.0"
    reason: "Parse and merge inventory feeds from multiple sources"
  - ref: "packs/datetime-toolkit@1.0.0"
    reason: "Lead time calculations and delivery date estimation"
automations:
  triggers:
    - name: "Update stock levels on new order"
      entityType: "orders"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "A new order was placed. Update stock levels for all items in this order and flag any that drop below reorder thresholds."
    - name: "Evaluate reorder on low stock"
      entityType: "stock"
      eventType: "updated"
      targetAgent: "self"
      condition: '{"quantity": {"$lt": 10}}'
      promptTemplate: "Stock level dropped below threshold. Evaluate whether a reorder is needed based on consumption rate and lead time."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-reorder-policy
      name: "Define reorder policy"
      description: "Reorder thresholds, lead times, and EOQ parameters for procurement"
      type: north_star
      key: reorder_policy
      group: configuration
      priority: required
      reason: "Cannot generate reorder recommendations without defined thresholds and lead times"
      ui:
        inputType: text
        placeholder: '{"default_lead_days": 7, "safety_stock_multiplier": 1.5, "reorder_method": "eoq"}'
        helpUrl: "https://docs.schemabounce.com/bots/inventory-manager/reorder-policy"
    - id: set-budget-constraints
      name: "Set procurement budget"
      description: "Budget limits for procurement spending by category or period"
      type: north_star
      key: budget_constraints
      group: configuration
      priority: required
      reason: "Reorder recommendations must respect procurement budget limits"
      ui:
        inputType: text
        placeholder: '{"monthly_procurement_limit": 50000, "per_order_max": 10000}'
    - id: connect-agentmail
      name: "Verify email identity"
      description: "Bot sends reorder alerts, stock reports, and vendor communications"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: required
      reason: "Email alerts are critical for time-sensitive reorder notifications"
      ui:
        icon: email
        actionLabel: "Verify Email"
    - id: connect-exa
      name: "Connect web search"
      description: "Search for supplier pricing, lead time data, and supply chain news"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "Supply chain research and vendor pricing lookups require web search"
      ui:
        icon: search
        actionLabel: "Connect Exa Search"
    - id: import-transactions
      name: "Import inventory transactions"
      description: "Historical purchase and consumption data for demand forecasting"
      type: data_presence
      entityType: transactions
      minCount: 10
      group: data
      priority: recommended
      reason: "Historical data improves consumption velocity calculations and reorder timing"
      ui:
        actionLabel: "Import Transactions"
        emptyState: "No transactions found. Import from your ERP or inventory system."
    - id: connect-composio
      name: "Connect ERP / procurement platform"
      description: "Links your ERP or procurement system for order management"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: recommended
      reason: "Automated sync with ERP enables real-time stock level tracking"
      ui:
        icon: composio
        actionLabel: "Connect ERP"
    - id: set-industry
      name: "Set business industry"
      description: "Industry context determines seasonal patterns and vendor benchmarks"
      type: north_star
      key: industry
      group: configuration
      priority: recommended
      reason: "Seasonal demand patterns and vendor expectations vary by industry"
      ui:
        inputType: select
        options:
          - { value: ecommerce, label: "E-commerce / Retail" }
          - { value: manufacturing, label: "Manufacturing" }
          - { value: food_beverage, label: "Food & Beverage" }
          - { value: healthcare, label: "Healthcare / Pharma" }
          - { value: wholesale, label: "Wholesale / Distribution" }
        prefillFrom: "workspace.industry"
goals:
  - name: prevent_stockouts
    description: "No critical stock-outs. All SKUs stay above safety stock thresholds"
    category: primary
    metric:
      type: count
      entity: inv_alerts
      filter: { severity: "critical", type: "stockout" }
    target:
      operator: "=="
      value: 0
      period: weekly
      condition: "zero critical stock-out alerts"
  - name: reorder_recommendations
    description: "Generate timely reorder recommendations before stock hits threshold"
    category: primary
    metric:
      type: count
      entity: inv_findings
      filter: { type: "reorder_recommendation" }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when stock approaches reorder point"
  - name: vendor_cost_tracking
    description: "Track vendor pricing trends and flag cost increases"
    category: secondary
    metric:
      type: count
      entity: inv_findings
      filter: { type: "cost_analysis" }
    target:
      operator: ">"
      value: 0
      period: monthly
  - name: stock_level_memory
    description: "Stock levels and consumption patterns tracked across runs"
    category: health
    metric:
      type: count
      source: memory
      namespace: stock_levels
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "cumulative growth"
---

# Inventory & Acquisition Manager

Monitors stock levels, calculates reorder points, tracks vendor performance, and manages the acquisition pipeline. Keeps procurement proactive rather than reactive.

## What It Does

- Monitors stock levels against minimum thresholds
- Calculates reorder points based on consumption rates and lead times
- Tracks vendor performance: delivery times, quality, pricing trends
- Manages acquisition pipeline and purchase order status
- Identifies cost-saving opportunities in procurement

## Escalation Behavior

- **Critical**: Stock-out imminent, supply chain disruption → alerts executive-assistant
- **High**: Vendor price increase, quality degradation → finding to accountant
- **Medium**: Reorder recommendation, stock trend → logged as inv_findings
- **Low**: Minor level adjustments → memory update only
