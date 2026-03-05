---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: social-media-monitor
  displayName: "Social Media Monitor"
  version: "1.0.0"
  description: "Monitors brand mentions and sentiment across platforms."
  category: marketing
  tags: ["social-media", "sentiment", "brand"]
agent:
  capabilities: ["sentiment_analysis", "brand_monitoring"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 10000
  estimatedCostTier: "medium"
schedule:
  default: "@hourly"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant insight discovered" }
data:
  entityTypesRead: ["social_mentions", "brand_keywords"]
  entityTypesWrite: ["sentiment_reports", "mention_alerts"]
  memoryNamespaces: ["sentiment_baselines", "trending_topics"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["marketing"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Social Media Monitor

Monitors social media for brand mentions. Analyzes sentiment, detects trending conversations, and flags reputation risks.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
