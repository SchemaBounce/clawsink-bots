---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: order-fulfillment
  displayName: "Order Fulfillment"
  version: "1.0.0"
  description: "Orchestrates order processing workflows from receipt through delivery."
  category: ecommerce
  tags: ["orders", "fulfillment", "workflow", "cdc"]
agent:
  capabilities: ["order_management", "workflow"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 10000
  estimatedCostTier: "low"
trigger:
  entityType: "orders"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
data:
  entityTypesRead: ["orders", "fulfillment_rules"]
  entityTypesWrite: ["fulfillment_tasks", "order_status"]
  memoryNamespaces: ["workflow_state", "sla_targets"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["operations"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Order Fulfillment

Orchestrates the complete order fulfillment lifecycle. Routes orders to appropriate warehouses, tracks processing stages, and ensures SLA compliance.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
