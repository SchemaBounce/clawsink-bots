---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: social-media-monitor
  displayName: "Social Media Monitor"
  version: "1.0.5"
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
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
  - ref: "skills/sentiment-analysis@1.0.0"
mcpServers:
  - ref: "tools/exa"
    required: true
    reason: "Search social media and news for brand mentions, trending topics, and sentiment signals"
  - ref: "tools/hyperbrowser"
    required: true
    reason: "Browse social media platforms and news sites to analyze brand mention context"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl review sites and forums for comprehensive brand sentiment data"
presence:
  web:
    browsing: true
    search: true
    crawling: true
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: true
    reason: "OAuth access to social platform APIs (Twitter/X, LinkedIn, Instagram) for pulling brand mentions and sentiment data"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-social-platforms
      name: "Connect social media platforms"
      description: "Links your social accounts (Twitter/X, LinkedIn, Instagram) for brand mention monitoring"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Primary data source — cannot monitor brand mentions without social platform access"
      ui:
        icon: composio
        actionLabel: "Connect Social Accounts"
        helpUrl: "https://docs.schemabounce.com/integrations/social"
    - id: set-brand-keywords
      name: "Define brand keywords"
      description: "Keywords and phrases to monitor across all platforms"
      type: config
      group: configuration
      target: { namespace: sentiment_baselines, key: brand_keywords }
      priority: required
      reason: "Mention monitoring requires knowing what to track — company name, product names, key personnel"
      ui:
        inputType: text
        placeholder: "e.g., YourBrand, @yourbrand, #yourbrand, CEO name"
    - id: set-mission
      name: "Set brand context"
      description: "Describe your brand so the bot can distinguish relevant mentions from noise"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Brand context filters noise — a fintech company named 'Mercury' needs context to avoid astronomy mentions"
      ui:
        inputType: text
        placeholder: "e.g., B2B SaaS platform for data engineering teams"
    - id: set-crisis-threshold
      name: "Set crisis alert threshold"
      description: "Number of negative engagements that trigger a reputation crisis alert"
      type: config
      group: configuration
      target: { namespace: sentiment_baselines, key: crisis_engagement_threshold }
      priority: recommended
      reason: "Tuning the crisis threshold avoids alert fatigue from normal negative mentions"
      ui:
        inputType: slider
        min: 10
        max: 200
        step: 10
        default: 50
    - id: connect-web-search
      name: "Connect web search for mentions"
      description: "Searches beyond social platforms for brand mentions in blogs, forums, and news"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: recommended
      reason: "Brand mentions on blogs, forums, and news sites supplement social platform data"
      ui:
        icon: search
        actionLabel: "Connect Web Search"
    - id: import-mentions
      name: "Import historical mentions"
      description: "Past mention data establishes sentiment baselines and normal mention volume"
      type: data_presence
      entityType: social_mentions
      minCount: 100
      group: data
      priority: recommended
      reason: "Sentiment baselines require historical data — without it, all activity looks anomalous"
      ui:
        actionLabel: "Import Mentions"
        emptyState: "No mention history found. Connect social platforms first to start collecting data."
        helpUrl: "https://docs.schemabounce.com/data/import"
goals:
  - name: mention_coverage
    description: "Capture and analyze brand mentions across all connected platforms"
    category: primary
    metric:
      type: count
      entity: sentiment_reports
    target:
      operator: ">="
      value: 1
      period: daily
  - name: crisis_detection_speed
    description: "Reputation crises flagged within one hourly run of onset"
    category: primary
    metric:
      type: boolean
      check: crisis_alert_sent
    target:
      operator: "=="
      value: true
      period: per_run
      condition: "when crisis threshold exceeded"
  - name: sentiment_trend_accuracy
    description: "Sentiment shifts correctly identified against rolling baselines"
    category: secondary
    metric:
      type: rate
      numerator: { entity: mention_alerts, filter: { alert_validated: true } }
      denominator: { entity: mention_alerts, filter: { alert_validated: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.80
      period: monthly
    feedback:
      enabled: true
      entityType: mention_alerts
      actions:
        - { value: true, label: "Accurate alert" }
        - { value: false, label: "False alarm" }
  - name: baseline_freshness
    description: "Sentiment baselines updated every run to keep comparisons current"
    category: health
    metric:
      type: count
      source: memory
      namespace: sentiment_baselines
    target:
      operator: ">"
      value: 0
      period: daily
      condition: "updated each run"
---

# Social Media Monitor

Monitors social media for brand mentions. Analyzes sentiment, detects trending conversations, and flags reputation risks.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
