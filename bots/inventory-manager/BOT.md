---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: inventory-manager
  displayName: "Inventory & Acquisition Manager"
  version: "1.0.1"
  description: "Stock level monitoring, reorder calculations, vendor tracking, acquisition pipeline management."
  category: operations
  tags: ["inventory", "stock", "vendors", "reorder", "acquisition", "procurement"]
agent:
  capabilities: ["procurement", "operations"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
  instructions: |
    ## Operating Rules
    - ALWAYS read `stock_levels` memory and `learned_patterns` memory before analysis — reorder decisions must factor in consumption velocity and seasonal patterns from prior runs.
    - ALWAYS check North Star keys (budget_constraints, reorder_policy) before generating reorder recommendations — procurement must respect configured policies.
    - NEVER issue a reorder recommendation without calculating the economic order quantity (EOQ) or justifying the quantity based on consumption rate and lead time.
    - NEVER approve a vendor switch or price increase acceptance without writing an inv_findings record documenting the cost impact analysis.
    - When inventory-alert sends a reorder evaluation alert, prioritize it — this means stock is already below threshold and time-sensitive.
    - Send stock level changes affecting fulfillment capacity to order-fulfillment (alert) so pending orders can be managed proactively.
    - Send cost trends and reorder recommendations to business-analyst and accountant (finding) for financial planning visibility.
    - Escalate to executive-assistant (alert) only for critical stock-outs or supply chain disruptions affecting multiple SKUs.
    - When price-optimizer sends findings about price changes, evaluate impact on reorder economics — adjust reorder quantities or vendor selection if margins shift.
    - When marketing-growth sends demand forecast findings, factor projected demand into reorder timing calculations.
    - Use automation-first principle: deterministic reorder triggers (stock below threshold + no pending PO) should become `adl_create_trigger` automations.
  toolInstructions: |
    ## Tool Usage — Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state` — get last run timestamp
    - Step 2: `adl_read_messages` — check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}` — ONE query for all new records
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
  - ref: "skills/record-monitoring@1.0.0"
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
