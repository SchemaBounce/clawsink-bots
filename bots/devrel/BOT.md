---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: devrel
  displayName: "Developer Relations"
  version: "1.0.4"
  description: "Monitors developer community health, GitHub activity, friction points, and developer advocacy."
  category: marketing
  tags: ["developer-relations", "community", "github", "open-source", "advocacy"]
agent:
  capabilities: ["content_marketing", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 keys (mission, product_catalog, community_goals) before analyzing community signals — align all findings with company mission and current product capabilities.
    - ALWAYS compare current community metrics against community_baselines memory before reporting trends. Only escalate when a metric deviates more than 15% from baseline.
    - NEVER interact directly with community members, post responses, or open GitHub issues. Your role is analysis and insight routing — humans handle public-facing community engagement.
    - NEVER include individual usernames, email addresses, or personal information in findings. Aggregate patterns only.
    - Escalate to executive-assistant only for critical sentiment drops or community backlash events. Route product friction points to product-owner and growth metrics to marketing-growth.
    - Correlate cs_findings from customer-support with community signals before creating devrel_findings — confirm patterns exist in both channels before escalating.
    - When a recurring friction point affects 3+ developers or appears in 3+ separate threads, classify it as "high" severity and send to product-owner with specific issue links.
    - Update community_baselines memory at the end of each run with current metric values (stars, issue response time, active contributors, discussion volume).
    - Track friction points in friction_tracker memory with a count — only graduate to a finding when the count reaches the threshold.
    - Review blog_drafts and doc_updates from blog-writer and documentation-writer each run to identify content that could address active friction points.
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
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
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
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: true
    browsing: false
    crawling: true
mcpServers:
  - ref: "tools/github"
    required: true
    reason: "Monitors repo stars, issues, contributions, and community activity"
  - ref: "tools/agentmail"
    required: false
    reason: "Send community updates, contributor recognition, and developer newsletter content"
  - ref: "tools/exa"
    required: true
    reason: "Search developer forums, Stack Overflow, and tech blogs for community sentiment and friction points"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl developer community sites and forums for feedback aggregation"
  - ref: "tools/composio"
    required: false
    reason: "Connect to Discord, community management, and developer analytics platforms"
egress:
  mode: "restricted"
  allowedDomains: ["*.github.com", "api.github.com", "discord.com", "api.stackexchange.com"]
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-community-goals
      name: "Define community goals"
      description: "Growth targets, engagement benchmarks, and response time SLAs"
      type: north_star
      key: community_goals
      group: configuration
      priority: required
      reason: "Cannot measure community health without defined engagement targets"
      ui:
        inputType: text
        placeholder: '{"star_growth_monthly": 50, "issue_response_hours": 24, "active_contributors": 20}'
    - id: set-product-catalog
      name: "Define product catalog"
      description: "Current features and roadmap context for community questions"
      type: north_star
      key: product_catalog
      group: configuration
      priority: required
      reason: "Cannot correlate friction points with product capabilities without product context"
      ui:
        inputType: text
        placeholder: "e.g., CDC pipelines, Kolumn CLI, SaaS connectors, workflow engine"
    - id: connect-github
      name: "Connect GitHub for community monitoring"
      description: "Tracks repo stars, issues, PRs, discussions, and contributor activity"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: required
      reason: "Primary data source for developer community health metrics"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
    - id: connect-exa
      name: "Connect Exa for sentiment scanning"
      description: "Search developer forums, Stack Overflow, and tech blogs for community sentiment"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "Required for scanning developer forums and detecting friction points beyond GitHub"
      ui:
        icon: search
        actionLabel: "Connect Exa"
    - id: set-friction-threshold
      name: "Configure friction point threshold"
      description: "Number of occurrences before a friction point escalates to a finding"
      type: config
      group: configuration
      target: { namespace: friction_tracker, key: escalation_threshold }
      priority: recommended
      reason: "Controls signal-to-noise ratio for developer friction reporting"
      ui:
        inputType: text
        placeholder: '{"min_occurrences": 3, "min_affected_developers": 3}'
        default: '{"min_occurrences": 3, "min_affected_developers": 3}'
    - id: connect-firecrawl
      name: "Connect Firecrawl for forum crawling"
      description: "Crawl developer community sites and forums for feedback aggregation"
      type: mcp_connection
      ref: tools/firecrawl
      group: connections
      priority: optional
      reason: "Expands community coverage beyond GitHub and search-indexed forums"
      ui:
        icon: globe
        actionLabel: "Connect Firecrawl"
goals:
  - name: friction_point_detection
    description: "Identify recurring developer friction points before they become churn risks"
    category: primary
    metric:
      type: count
      entity: devrel_findings
      filter: { finding_type: "friction_point", severity: "high" }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when friction signals exist in community channels"
  - name: community_health_tracking
    description: "Track community metrics against baselines every run"
    category: primary
    metric:
      type: boolean
      check: "baselines_compared_and_updated"
    target:
      operator: "=="
      value: 1
      period: per_run
  - name: sentiment_accuracy
    description: "Improve sentiment analysis accuracy through correlation with support data"
    category: secondary
    metric:
      type: rate
      numerator: { entity: devrel_findings, filter: { corroborated_by_support: true } }
      denominator: { entity: devrel_findings, filter: { sentiment: "negative" } }
    target:
      operator: ">"
      value: 0.7
      period: monthly
    feedback:
      enabled: true
      entityType: devrel_findings
      actions:
        - { value: confirmed, label: "Real issue" }
        - { value: false_positive, label: "Not a concern" }
  - name: baseline_freshness
    description: "Keep community baselines current for accurate trend detection"
    category: health
    metric:
      type: boolean
      check: "community_baselines_updated_this_run"
    target:
      operator: "=="
      value: 1
      period: per_run
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
