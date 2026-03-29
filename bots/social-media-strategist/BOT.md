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
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 keys (mission, industry, stage, priorities) before creating content strategies or calendar items — all social content must align with current business priorities and brand positioning.
    - ALWAYS check platform_performance memory for recent engagement baselines before recommending content types or posting times — decisions must be data-driven, not assumed.
    - NEVER post or publish content directly to social platforms. Your role is strategy and planning — write content_calendar_items entities that humans or automation tools execute.
    - NEVER copy or closely paraphrase competitor social content. Identify engagement patterns and themes, then create original angles aligned with brand voice.
    - When receiving a finding from blog-writer about new blog content, create corresponding social distribution items (LinkedIn post, Twitter thread, etc.) in content_calendar_items within the same run.
    - When receiving campaign adjustment requests from marketing-growth, update content_themes memory and adjust upcoming content_calendar_items accordingly.
    - Send content_calendar_items to content-scheduler via request message with the items ready for scheduling — include platform, date, time, and content type.
    - When a social topic consistently outperforms (2x+ engagement rate vs baseline), send a finding to blog-writer suggesting long-form coverage of that theme.
    - Track content themes in content_themes memory with performance scores. Retire themes that underperform for 3+ consecutive posts and amplify high-performers.
    - Monitor the social_metrics automation trigger — when engagement data updates, flag significant changes (>25% deviation from posting_cadence baseline) immediately.
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
    - { type: "request", to: ["content-scheduler"], when: "content calendar items ready for scheduling" }
    - { type: "finding", to: ["blog-writer"], when: "high-performing social topic suitable for long-form blog content" }
data:
  entityTypesRead: ["social_metrics", "engagement_data", "industry_posts"]
  entityTypesWrite: ["social_strategy", "content_calendar_items"]
  memoryNamespaces: ["platform_performance", "content_themes", "posting_cadence"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities"]
  zone2Domains: ["marketing"]
egress:
  mode: "restricted"
  allowedDomains: ["api.twitter.com", "api.x.com", "api.linkedin.com", "graph.facebook.com"]
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
