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
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 key (mission) before analyzing mentions — filter out noise by aligning sentiment analysis with brand-relevant context.
    - ALWAYS compare current sentiment scores against sentiment_baselines memory before escalating. Only flag shifts that exceed a 10% deviation from the rolling baseline.
    - NEVER respond to, engage with, or interact with social media posts. Your role is monitoring and alerting only — humans handle public-facing responses.
    - NEVER include individual user handles or personal information in mention_alerts or sentiment_reports. Report aggregate patterns and anonymized examples only.
    - Escalate to executive-assistant immediately for reputation crises: viral negative mentions (50+ engagements with negative sentiment) or coordinated criticism patterns.
    - Send sentiment trends and engagement pattern findings to social-media-strategist so strategy can be adjusted based on real-time data.
    - Send brand awareness trends and viral mention opportunities to marketing-growth for campaign amplification decisions.
    - Update sentiment_baselines memory at the end of every run with current platform-level sentiment averages and mention volumes.
    - Track emerging topics in trending_topics memory — promote to a finding only when a topic appears across 2+ platforms or persists for 3+ consecutive runs.
    - Given hourly scheduling, keep each run focused and efficient — process only new mentions since the last run timestamp.
  toolInstructions: |
    ## Tool Usage
    - Query `social_mentions` entities to pull recent brand mentions across platforms. Filter by timestamp > last_run_time to process only new data.
    - Query `brand_keywords` entities to get the current list of monitored keywords, brand names, and product terms. Use these as search filters.
    - Write `sentiment_reports` entities for periodic summaries. Required fields: report_date, platform, mention_count, avg_sentiment_score, sentiment_distribution (positive|neutral|negative counts), top_themes[], notable_mentions[].
    - Write `mention_alerts` entities only for escalation events (reputation crisis, viral negative content). Required fields: severity (critical|high), platform, trigger_description, mention_volume, sentiment_score, recommended_response_urgency.
    - Use `sentiment_baselines` memory namespace to store rolling averages per platform: avg_sentiment_score, avg_mention_volume, baseline_date. Update every run.
    - Use `trending_topics` memory namespace to track emerging themes. Key format: `trend-{platform}-{topic-slug}`. Store: first_seen, run_count, platforms_seen[], growing (boolean).
    - When searching social_mentions, use the brand_keywords entity list as the filter set rather than hardcoding search terms — this allows the keyword list to evolve without changing agent behavior.
    - For sentiment scoring, use the sentiment-analysis skill. Classify each mention as positive (>0.6), neutral (0.3-0.6), or negative (<0.3).
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 6000
  estimatedCostTier: "medium"
schedule:
  default: "@hourly"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "reputation crisis or critical brand mention" }
    - { type: "finding", to: ["social-media-strategist"], when: "sentiment trend or engagement pattern requiring strategy adjustment" }
    - { type: "finding", to: ["marketing-growth"], when: "brand awareness trend or viral mention opportunity" }
data:
  entityTypesRead: ["social_mentions", "brand_keywords"]
  entityTypesWrite: ["sentiment_reports", "mention_alerts"]
  memoryNamespaces: ["sentiment_baselines", "trending_topics"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["marketing"]
egress:
  mode: "restricted"
  allowedDomains: ["api.twitter.com", "api.x.com", "api.linkedin.com", "graph.facebook.com"]
skills:
  - ref: "skills/scheduled-report@1.0.0"
  - ref: "skills/sentiment-analysis@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: true
    reason: "OAuth access to social platform APIs (Twitter/X, LinkedIn, Instagram) for pulling brand mentions and sentiment data"
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
