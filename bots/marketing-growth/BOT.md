---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: marketing-growth
  displayName: "Marketing & Growth"
  version: "1.0.5"
  description: "Content calendar management, SEO tracking, campaign metric analysis, social scheduling."
  category: marketing
  tags: ["marketing", "growth", "seo", "campaigns", "content", "social"]
agent:
  capabilities: ["content_marketing", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 keys (mission, industry, stage, priorities, growth_targets) before generating any campaign analysis or content recommendation — ground all output in business context.
    - ALWAYS check the content_calendar memory namespace before requesting new content from blog-writer or social-media-strategist to avoid duplicate assignments.
    - NEVER publish or auto-send content — your role is coordination and analysis. Content creation belongs to blog-writer; social execution belongs to social-media-strategist.
    - NEVER fabricate metric values. If campaign data is unavailable or stale, log a finding and request updated data rather than estimating.
    - Escalate to executive-assistant ONLY when a campaign fails or a metric drops more than 20% week-over-week. Do not escalate routine fluctuations.
    - When sending requests to blog-writer, always include the target topic, intended audience, and suggested publish window from the content_calendar namespace.
    - When sending findings to growth-hacker, include channel name, metric values, and the time window so experiments can be designed with proper baselines.
    - Coordinate with social-media-strategist before adjusting campaign strategy — send a request with the proposed change and wait for engagement data before finalizing.
    - Log all pattern observations in learned_patterns memory before sending findings externally — this prevents repeat analysis of the same trend.
    - Review cs_findings from customer-support at the start of every run to surface content topics driven by real user pain points.
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
    - { type: "request", to: ["blog-writer"], when: "content topic request or content calendar assignment" }
    - { type: "request", to: ["social-media-strategist"], when: "campaign needs social amplification or strategy adjustment" }
    - { type: "request", to: ["content-scheduler"], when: "content publishing schedule update" }
    - { type: "finding", to: ["growth-hacker"], when: "channel performance data or experiment opportunity" }
data:
  entityTypesRead: ["campaigns", "contacts", "cs_findings"]
  entityTypesWrite: ["mktg_findings", "mktg_alerts", "campaigns"]
  memoryNamespaces: ["working_notes", "learned_patterns", "content_calendar"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities", "growth_targets"]
  zone2Domains: ["marketing", "growth"]
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: true
    crawling: true
egress:
  mode: "restricted"
  allowedDomains: ["www.googleapis.com", "analyticsdata.googleapis.com"]
mcpServers:
  - ref: "tools/exa"
    required: true
    reason: "Search for SEO trends, content marketing benchmarks, and campaign performance data"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl competitor content and landing pages to identify content gaps and SEO opportunities"
  - ref: "tools/agentmail"
    required: false
    reason: "Send campaign performance reports and content calendar updates to stakeholders"
  - ref: "tools/composio"
    required: false
    reason: "Connect to Google Analytics, Mailchimp, and social media platforms for campaign metrics"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    required: true
    reason: "OAuth access to marketing platforms (Google Ads, Meta Ads, Mailchimp) for pulling campaign metrics and SEO data"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-marketing-platform
      name: "Connect marketing platform"
      description: "Links your marketing tools so the bot can pull campaign metrics and SEO data"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Primary data source for campaign metrics, SEO rankings, and channel performance"
      ui:
        icon: composio
        actionLabel: "Connect Marketing Platform"
        helpUrl: "https://docs.schemabounce.com/integrations/marketing"
    - id: set-growth-targets
      name: "Define growth targets"
      description: "Set your quarterly growth KPIs so the bot can benchmark campaign performance"
      type: north_star
      key: growth_targets
      group: configuration
      priority: required
      reason: "Cannot evaluate campaign success without defined growth targets"
      ui:
        inputType: textarea
        placeholder: "e.g., 20% MQL increase, 15% organic traffic growth, $50 target CAC"
    - id: set-industry
      name: "Set business industry"
      description: "Marketing benchmarks and channel strategies vary by industry"
      type: north_star
      key: industry
      group: configuration
      priority: required
      reason: "Industry context shapes content strategy and channel prioritization"
      ui:
        inputType: select
        options:
          - { value: fintech, label: "FinTech / Payments" }
          - { value: ecommerce, label: "E-commerce / Retail" }
          - { value: saas, label: "SaaS / Software" }
          - { value: healthcare, label: "Healthcare" }
          - { value: other, label: "Other" }
        prefillFrom: "workspace.industry"
    - id: connect-exa
      name: "Connect Exa for SEO research"
      description: "Enables search for SEO trends, content benchmarks, and marketing intelligence"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "SEO tracking and content gap analysis require web search capabilities"
      ui:
        icon: exa
        actionLabel: "Connect Exa"
    - id: import-campaigns
      name: "Import existing campaigns"
      description: "Historical campaign data establishes performance baselines for trend analysis"
      type: data_presence
      entityType: campaigns
      minCount: 5
      group: data
      priority: recommended
      reason: "Performance baselines prevent false-positive trend alerts on initial runs"
      ui:
        actionLabel: "Import Campaigns"
        emptyState: "No campaign data found. Import via CSV or connect your marketing platform first."
        helpUrl: "https://docs.schemabounce.com/data/import"
    - id: connect-firecrawl
      name: "Connect Firecrawl for content analysis"
      description: "Crawl competitor content and landing pages to identify content gaps"
      type: mcp_connection
      ref: tools/firecrawl
      group: connections
      priority: optional
      reason: "Competitor content analysis improves SEO recommendations and content calendar"
      ui:
        icon: firecrawl
        actionLabel: "Connect Firecrawl"
goals:
  - name: identify_growth_opportunities
    description: "Surface actionable growth insights from campaign and channel data"
    category: primary
    metric:
      type: count
      entity: mktg_findings
      filter: { finding_type: ["growth_opportunity", "channel_insight"] }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when campaign data exists"
  - name: content_calendar_coverage
    description: "Maintain a populated content calendar with upcoming scheduled content"
    category: primary
    metric:
      type: count
      source: memory
      namespace: content_calendar
    target:
      operator: ">"
      value: 3
      period: weekly
      condition: "rolling content pipeline"
  - name: campaign_monitoring_health
    description: "Regularly process campaign data without gaps or stale runs"
    category: health
    metric:
      type: boolean
      check: last_run_completed_successfully
    target:
      operator: "=="
      value: true
      period: per_schedule
  - name: seo_trend_detection
    description: "Detect meaningful SEO ranking changes and organic traffic shifts"
    category: secondary
    metric:
      type: count
      entity: mktg_findings
      filter: { finding_type: "seo_change" }
    target:
      operator: ">"
      value: 0
      period: monthly
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
