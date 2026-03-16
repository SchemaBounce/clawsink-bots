---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: devrel
  displayName: "Developer Relations"
  version: "1.0.0"
  description: "Monitors developer community health, GitHub activity, friction points, and developer advocacy."
  category: marketing
  tags: ["developer-relations", "community", "github", "open-source", "advocacy"]
agent:
  capabilities: ["content_marketing", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 20000
  estimatedCostTier: "medium"
schedule:
  default: "@daily"
  recommendations:
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 12h"
messaging:
  listensTo:
    - { type: "finding", from: ["product-owner", "blog-writer", "documentation-writer"] }
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["customer-support"] }
  sendsTo:
    - { type: "finding", to: ["product-owner"], when: "developer feedback pattern or friction point requiring product action" }
    - { type: "finding", to: ["marketing-growth"], when: "community growth metrics or engagement trend" }
    - { type: "finding", to: ["executive-assistant"], when: "community health summary or critical sentiment shift" }
data:
  entityTypesRead: ["po_findings", "blog_drafts", "cs_findings", "doc_updates"]
  entityTypesWrite: ["devrel_findings", "devrel_alerts", "devrel_community_metrics"]
  memoryNamespaces: ["working_notes", "learned_patterns", "community_baselines", "friction_tracker"]
zones:
  zone1Read: ["mission", "product_catalog", "community_goals"]
  zone2Domains: ["marketing", "engineering"]
skills:
  - ref: "skills/sentiment-analysis@1.0.0"
  - ref: "skills/trend-analysis@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: true
    reason: "Managed OAuth for GitHub, Discord, and Stack Overflow APIs"
    config:
      apps: ["github", "discord"]
      scopes: ["repo:read", "issues:read"]
mcpServers:
  - ref: "tools/github"
    required: true
    reason: "Monitors repo stars, issues, contributions, and community activity"
egress:
  mode: "restricted"
  allowedDomains: ["*.github.com", "api.github.com", "discord.com", "api.stackexchange.com"]
requirements:
  minTier: "starter"
---

# Developer Relations

Monitors developer community health across GitHub, forums, and support channels. Detects friction points, tracks community growth, and feeds actionable insights to product and marketing teams.

## What It Does

- Scans GitHub activity every run — stars, issues, contributions, discussions, response times
- Identifies developer friction points and recurring pain patterns from issue themes
- Tracks community health metrics and flags significant trend changes against baselines
- Analyzes sentiment across community channels to detect shifts early
- Correlates customer support findings with developer community signals

## Escalation Behavior

- **Critical**: Sudden sentiment drop, community backlash, or viral negative feedback → finding to executive-assistant
- **High**: Recurring friction point affecting multiple developers → finding to product-owner
- **Medium**: Community growth trend or engagement shift → finding to marketing-growth
- **Low**: Minor metric fluctuation within baselines → memory update only

## Recommended Setup

Set these North Star keys for best results:
- `community_goals` — Growth targets, engagement benchmarks, response time SLAs
- `product_catalog` — Current features and roadmap context for community questions
- `mission` — Company mission to align developer advocacy messaging
