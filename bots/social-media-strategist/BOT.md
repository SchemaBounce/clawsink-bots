---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: social-media-strategist
  displayName: "Social Media Strategist"
  version: "1.0.0"
  description: "Cross-platform social media strategy, content planning, and engagement analysis."
  category: marketing
  tags: ["social-media", "content", "engagement", "strategy", "scheduling", "analytics"]
agent:
  capabilities: ["analytics", "content"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 10000
  estimatedCostTier: "low"
schedule:
  default: "@daily"
  recommendations:
    light: "@every 3d"
    standard: "@daily"
    intensive: "@every 6h"
messaging:
  listensTo:
    - { type: "finding", from: ["marketing-growth"] }
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["blog-writer"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "viral content opportunity or reputation risk detected" }
    - { type: "finding", to: ["marketing-growth"], when: "engagement trend requiring campaign adjustment" }
data:
  entityTypesRead: ["social_metrics", "engagement_data", "industry_posts"]
  entityTypesWrite: ["social_strategy", "content_calendar_items"]
  memoryNamespaces: ["platform_performance", "content_themes", "posting_cadence"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities"]
  zone2Domains: ["marketing"]
skills:
  - ref: "skills/trend-analysis@1.0.0"
  - ref: "skills/sentiment-analysis@1.0.0"
automations:
  triggers:
    - entityType: "social_metrics"
      event: "updated"
      prompt: "Flag significant engagement changes."
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: true
    reason: "OAuth access to social platform APIs (Twitter/X, LinkedIn, Instagram) for reading engagement metrics and posting content"
requirements:
  minTier: "starter"
---

# Social Media Strategist

Optimizes cross-platform social media presence through data-driven content planning, engagement analysis, and industry monitoring. Creates content calendars aligned with brand voice and business goals.

## What It Does

- Analyzes social metrics across platforms (engagement rates, reach, impressions, follower growth)
- Monitors industry posts for trending topics and content strategies
- Plans content calendars with optimal posting times and content mix
- Tracks which content themes and formats drive the most engagement
- Flags significant engagement changes (positive viral moments or negative drops)
- Aligns social content with broader marketing campaigns and brand guidelines

## Content Calendar Item Format

Items are written as `content_calendar_items` entity type records:
```json
{
  "platform": "linkedin",
  "scheduled_date": "2026-03-05",
  "scheduled_time": "09:00",
  "content_type": "carousel",
  "theme": "product_update",
  "topic": "New pipeline monitoring dashboard walkthrough",
  "hook": "Your CDC pipeline just told you something important...",
  "hashtags": ["#DataEngineering", "#CDC", "#RealTimeData"],
  "target_engagement_rate": 0.045,
  "status": "planned"
}
```

## Escalation Behavior

- **Critical**: Negative viral moment or reputation risk detected -> finding to executive-assistant
- **High**: Content going viral organically, needs amplification -> finding to marketing-growth
- **Medium**: Weekly engagement trend analysis -> social_strategy record
- **Low**: Platform performance update -> platform_performance memory
