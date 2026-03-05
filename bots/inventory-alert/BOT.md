---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: inventory-alert
  displayName: "Inventory Alert"
  version: "1.0.0"
  description: "Detects low stock levels and triggers reorder alerts when inventory falls below thresholds."
  category: ecommerce
  tags: ["inventory", "stock", "alerts", "cdc"]
agent:
  capabilities: ["stock_management", "supply_chain"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 5000
  estimatedCostTier: "low"
trigger:
  entityType: "inventory"
  eventType: "updated"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
data:
  entityTypesRead: ["inventory", "reorder_rules"]
  entityTypesWrite: ["inventory_alerts", "reorder_requests"]
  memoryNamespaces: ["stock_levels", "reorder_thresholds"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["operations"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Inventory Alert

Monitors inventory levels in real-time. When stock drops below configured thresholds, generates reorder alerts and notifies supply chain.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
