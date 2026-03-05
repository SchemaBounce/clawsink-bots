---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: shipping-tracker
  displayName: "Shipping Tracker"
  version: "1.0.0"
  description: "Monitors shipment status changes and detects delivery issues."
  category: ecommerce
  tags: ["shipping", "logistics", "tracking", "cdc"]
agent:
  capabilities: ["logistics", "tracking"]
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
  entityType: "shipments"
  eventType: "updated"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical issue detected" }
data:
  entityTypesRead: ["shipments", "delivery_slas"]
  entityTypesWrite: ["shipping_alerts", "delivery_predictions"]
  memoryNamespaces: ["carrier_performance", "route_patterns"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["operations"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Shipping Tracker

Tracks shipment status changes in real-time. Predicts delays, detects exceptions, and proactively notifies customers.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
