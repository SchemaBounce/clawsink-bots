---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: marketing-growth
  displayName: "Marketing & Growth"
  version: "1.0.0"
  description: "Content calendar management, SEO tracking, campaign metric analysis, social scheduling."
  category: marketing
  tags: ["marketing", "growth", "seo", "campaigns", "content", "social"]
agent:
  capabilities: ["content_marketing", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "@daily"
  recommendations:
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 12h"
messaging:
  listensTo:
    - { type: "finding", from: ["customer-support"] }
    - { type: "request", from: ["executive-assistant", "business-analyst"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "campaign failure or significant metric drop" }
    - { type: "finding", to: ["business-analyst", "inventory-manager"], when: "growth trend or channel performance insight" }
data:
  entityTypesRead: ["campaigns", "contacts", "cs_findings"]
  entityTypesWrite: ["mktg_findings", "mktg_alerts", "campaigns"]
  memoryNamespaces: ["working_notes", "learned_patterns", "content_calendar"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities", "growth_targets"]
  zone2Domains: ["marketing"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Marketing & Growth

Manages the marketing pipeline: content calendar, SEO tracking, campaign metrics, and social media scheduling. Identifies growth opportunities and channel performance trends.

## What It Does

- Maintains content calendar and flags upcoming deadlines
- Tracks campaign performance metrics (conversion, engagement, spend)
- Monitors SEO rankings and organic traffic trends
- Identifies top-performing channels and content types
- Suggests content topics based on customer support trends

## Escalation Behavior

- **Critical**: Campaign failure, major metric drop → alerts executive-assistant
- **High**: Significant trend change, channel underperformance → finding to business-analyst
- **Medium**: Content calendar updates, SEO observations → logged as mktg_findings
- **Low**: Routine metric tracking → memory update only
