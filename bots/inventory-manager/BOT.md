---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: inventory-manager
  displayName: "Inventory & Acquisition Manager"
  version: "1.0.0"
  description: "Stock level monitoring, reorder calculations, vendor tracking, acquisition pipeline management."
  category: operations
  tags: ["inventory", "stock", "vendors", "reorder", "acquisition", "procurement"]
agent:
  capabilities: ["procurement", "operations"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
  maxTokenBudget: 50000
schedule:
  default: "@every 8h"
  recommendations:
    light: "@daily"
    standard: "@every 8h"
    intensive: "@every 4h"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "accountant"] }
    - { type: "finding", from: ["marketing-growth"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical stock-out or supply chain disruption" }
    - { type: "finding", to: ["business-analyst", "accountant"], when: "cost trend or reorder recommendation" }
data:
  entityTypesRead: ["transactions", "companies"]
  entityTypesWrite: ["inv_findings", "inv_alerts"]
  memoryNamespaces: ["working_notes", "learned_patterns", "stock_levels"]
zones:
  zone1Read: ["mission", "industry", "budget_constraints", "reorder_policy"]
  zone2Domains: ["operations"]
skills:
  - inline: "core-analysis"
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
