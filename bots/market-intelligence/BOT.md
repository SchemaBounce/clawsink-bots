---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: market-intelligence
  displayName: "Market Intelligence"
  version: "1.0.0"
  description: "Track industry landscape, product announcements, feature parity gaps, and positioning shifts."
  category: management
  tags: ["market-analysis", "industry", "landscape", "positioning", "feature-parity"]
agent:
  capabilities: ["analytics", "research"]
  hostingMode: "openclaw"
  defaultDomain: "growth"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "medium"
cost:
  estimatedTokensPerRun: 25000
  estimatedCostTier: "medium"
schedule:
  default: "@weekly"
  cronExpression: "0 8 * * 1"
  recommendations:
    light: "@every 14d"
    standard: "@weekly"
    intensive: "@every 3d"
messaging:
  listensTo:
    - { type: "finding", from: ["product-owner", "sales-pipeline", "blog-writer"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["product-owner"], when: "feature gap analysis or industry capability shift" }
    - { type: "finding", to: ["marketing-growth"], when: "positioning insight or messaging opportunity" }
    - { type: "finding", to: ["executive-assistant"], when: "weekly market briefing or significant industry event" }
data:
  entityTypesRead: ["po_findings", "pipeline_reports", "deal_insights", "blog_drafts"]
  entityTypesWrite: ["mi_findings", "mi_alerts", "mi_landscape_reports"]
  memoryNamespaces: ["working_notes", "learned_patterns", "landscape_baselines", "feature_gaps"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities", "product_catalog"]
  zone2Domains: ["growth", "product"]
skills:
  - ref: "skills/trend-analysis@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: false
    reason: "OAuth access to news aggregation and RSS feed APIs"
egress:
  mode: "restricted"
  allowedDomains: ["newsapi.org", "api.rss2json.com", "*.producthunt.com"]
requirements:
  minTier: "starter"
---

# Market Intelligence

Monitors the data integration and streaming industry to identify feature gaps, positioning shifts, and market opportunities that inform product and marketing strategy.

## What It Does

- Produces a weekly market landscape briefing covering product announcements, feature changes, and positioning shifts
- Maintains a running feature parity analysis comparing SchemaBounce capabilities against industry alternatives
- Correlates deal loss reasons from sales pipeline with industry feature advantages to prioritize product gaps
- Tracks emerging trends in the data integration space (new protocols, paradigm shifts, adoption patterns)
- Surfaces positioning insights and messaging opportunities for the marketing team

## Escalation Behavior

- Sends weekly market briefings and significant industry events to executive-assistant
- Sends feature gap analysis and capability shift findings to product-owner
- Sends positioning insights and messaging opportunities to marketing-growth
- Listens for product feedback from product-owner, deal context from sales-pipeline, and content signals from blog-writer

## Recommended Setup

- Run weekly (Monday 8 AM) for a steady cadence of market briefings
- Enable the composio plugin for automated RSS and news API access
- Pair with product-owner and sales-pipeline bots for full feedback loop on feature gaps and deal outcomes
