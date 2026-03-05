---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: price-optimizer
  displayName: "Price Optimizer"
  version: "1.0.0"
  description: "Adjusts pricing recommendations based on market price changes."
  category: ecommerce
  tags: ["pricing", "optimization", "market-analysis", "cdc"]
agent:
  capabilities: ["pricing", "market_analysis"]
  hostingMode: "openclaw"
  defaultDomain: "strategy"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 6000
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
data:
  entityTypesRead: ["market_prices", "pricing_rules"]
  entityTypesWrite: ["price_recommendations", "pricing_alerts"]
  memoryNamespaces: ["price_history", "elasticity_models"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["strategy"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Price Optimizer

Monitors market pricing changes and recommends optimal price adjustments to maintain competitiveness and margins.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
