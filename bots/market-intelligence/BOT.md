---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: market-intelligence
  displayName: "Market Intelligence"
  version: "1.0.1"
  description: "Track industry landscape, product announcements, feature parity gaps, and positioning shifts."
  category: management
  tags: ["market-analysis", "industry", "landscape", "positioning", "feature-parity"]
agent:
  capabilities: ["analytics", "research"]
  hostingMode: "openclaw"
  defaultDomain: "growth"
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 keys (mission, industry, stage, priorities, product_catalog) before producing any landscape analysis — ground all assessments in the company's current position and product capabilities.
    - ALWAYS check landscape_baselines memory before reporting industry shifts. Only flag changes that represent genuine movement, not noise from a single announcement.
    - NEVER name specific competitors in findings or alerts. Use generic categories (e.g., "a major batch-first vendor" or "an open-source alternative") to keep analysis positioning-neutral.
    - NEVER speculate on competitor pricing or revenue. Focus on publicly observable capabilities, feature announcements, and positioning language.
    - Produce a weekly mi_landscape_reports entity every run summarizing: new product announcements, feature parity changes, positioning shifts, and emerging trends.
    - Correlate deal_insights from sales-pipeline with feature_gaps memory — when a feature gap is cited in 3+ lost deals, escalate to product-owner as a priority gap.
    - Send positioning insights to marketing-growth with specific messaging angle suggestions, not raw data dumps.
    - Update feature_gaps memory with each run: add new gaps discovered, mark gaps as "closed" when product_catalog shows the capability now exists.
    - When executive-assistant sends an ad-hoc request, prioritize it in the current run and deliver findings within the same execution cycle.
    - Review po_findings each run to avoid reporting feature gaps the product team has already acknowledged or planned.
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
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: true
    browsing: true
    crawling: true
mcpServers:
  - ref: "tools/exa"
    required: true
    reason: "Search for industry news, product announcements, and competitive positioning shifts"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse competitor websites and product pages to track feature changes and pricing updates"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl industry blogs, press releases, and analyst reports for landscape analysis"
  - ref: "tools/agentmail"
    required: false
    reason: "Send market intelligence briefings and competitive alerts to stakeholders"
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
