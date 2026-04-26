---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: seo-expert
  displayName: "SEO Expert"
  version: "0.1.3"
  description: "Audits SchemaBounce SEO across modern signals (Google Search Console keyword data, Core Web Vitals, Open Graph, structured data, AI-search citation visibility), suggests blog topics, and drafts simulated outreach for human review."
  category: content
  tags: ["seo", "audit", "content", "marketing", "research"]
agent:
  capabilities: ["seo", "research", "audit"]
  hostingMode: "openclaw"
  defaultDomain: "content"
  instructions: |
    ## Operating Rules
    - ALWAYS read brand_voice and product_catalog from Zone 1 before drafting any topic suggestion or outreach message.
    - The agent itself MUST NOT make raw HTTP calls. All external access goes through guarded built-in tools (adl_seo_*) that enforce SSRF guards, allowlists, and timeouts server-side.
    - This bot is audit and dry-run only for outreach. Outreach is recorded in seo_outreach_log with status="would_send"; nothing leaves the cluster as a send.
    - On every run, emit at least one actionable seo_finding. "Everything looks fine" is not an acceptable finding.
    - Cover modern SEO signals: Open Graph + Twitter Card completeness, JSON-LD/structured data validity, Core Web Vitals (LCP, INP, CLS), Lighthouse SEO score, indexation status, real keyword performance from Google Search Console (impressions, CTR, position), and AI-search citation visibility (do ChatGPT, Claude, Perplexity, Gemini cite us for our brand and category queries?).
    - When proposing topics for blog-writer, prefer "almost-ranking" queries from GSC: impressions ≥ 100 AND position between 5 and 20 AND CTR below the run's median. Message blog-writer via adl_send_message AND write a seo_topic_suggestion record.
    - File a seo_finding for: missing or invalid og:* tags, missing twitter:* tags, missing or invalid JSON-LD, LCP > 2.5s on mobile, CLS > 0.1, missing meta description, weak title, thin content (<800 words), orphaned URLs, duplicate slugs, missing canonical, AI-search citation rate < 25% across providers for primary brand queries.
    - Outreach simulation: for each plausible link-building target, write a seo_outreach_log row with channel in {email, twitter, linkedin}, a real draft message, and status="would_send". Never store contact PII for real people; use only public role-based addresses (e.g., editor@example.com).
  toolInstructions: |
    ## Tool Usage
    - Step 1: `adl_read_memory` namespace `bot:seo-expert:northstar` keys `brand_voice`, `product_catalog`, `competitive_anchors`
    - Step 2: `adl_read_memory` namespace `seo:audit:cache` key `sitemap_xml` (seeded by the bootstrap script before each run); list URLs.
    - Step 3: Spawn `auditor` sub-agent. The auditor uses Composio MCP tools (`composio.search_composio_tools` then `composio.execute_composio_tool`) to reach Google Search Console for real keyword data, and `adl_proxy_call` for sitemap-URL meta audits (Open Graph, JSON-LD, canonical). PageSpeed and GEO/LLMO checks are deferred to dedicated MCP servers in the next iteration.
    - Step 4: For each finding, `adl_upsert_record` entity_type=`seo_findings` with severity, metric_name, metric_value, provider.
    - Step 5: For each almost-ranking GSC query, `adl_upsert_record` entity_type=`seo_keyword_opportunity`.
    - Step 6: Spawn `recommender` sub-agent; for each topic suggestion, `adl_upsert_record` entity_type=`seo_topic_suggestion` AND `adl_send_message` to `blog-writer` type=`finding`. Link to the seo_keyword_opportunity rows that justify it.
    - Step 7: Spawn `outreach-simulator` sub-agent; for each candidate, `adl_upsert_record` entity_type=`seo_outreach_log` with status="would_send".
    - Step 8: `adl_write_memory` namespace `seo:run:state` key `last_run` with timestamp + counts per metric_name.
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 12000
cost:
  estimatedTokensPerRun: 9000
  estimatedCostTier: "low"
schedule:
  default: "@weekly"
  recommendations:
    light: "@monthly"
    standard: "@weekly"
    intensive: "@every 3d"
  cronExpression: "0 7 * * 1"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "marketing-growth"] }
    - { type: "finding", from: ["blog-writer"] }
  sendsTo:
    - { type: "finding", to: ["blog-writer"], when: "topic suggestion ready" }
    - { type: "finding", to: ["executive-assistant"], when: "critical seo finding requires action" }
data:
  entityTypesRead: ["blog_drafts", "seo_findings", "seo_outreach_log", "seo_topic_suggestion", "seo_keyword_opportunity"]
  entityTypesWrite: ["seo_findings", "seo_outreach_log", "seo_topic_suggestion", "seo_keyword_opportunity"]
  memoryNamespaces: ["seo:audit:cache", "seo:run:state"]
zones:
  zone1Read: ["brand_voice", "product_catalog", "competitive_anchors", "company_glossary"]
  zone2Domains: ["content"]
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: true
    browsing: true
    crawling: true
egress:
  mode: "allowlist"
  allowlist:
    - "googleapis.com"
    - "www.googleapis.com"
    - "searchconsole.googleapis.com"
    - "pagespeedonline.googleapis.com"
    - "api.anthropic.com"
    - "api.openai.com"
    - "api.perplexity.ai"
    - "schemabounce.com"
    - "api.schemabounce.com"
plugins: []
mcpServers:
  - ref: "tools/composio"
    required: true
    reason: "Composio is the managed-OAuth gateway that provides Google Search Console (and future GA4, etc.) without writing custom OAuth handlers. Without it the auditor cannot reach GSC at all."
  - ref: "tools/google-search-console"
    required: false
    reason: "Real keyword data, impressions, CTR, position trends. Authorized via Composio OAuth at activation time. Without this the auditor still runs but only emits Open-Graph and structured-data findings — no almost-ranking opportunities."
    config:
      default_lookback_days: 28
requirements:
  minTier: "starter"
goals:
  - name: findings_per_run
    description: "Each run produces at least one actionable seo_finding"
    category: primary
    metric:
      type: count
      entity: seo_findings
    target:
      operator: ">="
      value: 1
      period: per_run
  - name: topic_suggestions_per_month
    description: "Feed blog-writer at least four high-quality topic suggestions per month"
    category: primary
    metric:
      type: count
      entity: seo_topic_suggestion
    target:
      operator: ">="
      value: 4
      period: monthly
  - name: outreach_dry_run_only
    description: "Outreach is simulated only; zero outbound sends"
    category: health
    metric:
      type: boolean
      check: "no_outbound_egress"
    target:
      operator: "=="
      value: 1
      period: per_run
---

# SEO Expert

Audits SchemaBounce's published content footprint, generates topic suggestions for the blog-writer, and drafts simulated outreach for review. **Audit and dry-run only.** Real sends require credentials and a Phase 2 plan; this bot does not perform any external send.

## What It Does

- **Modern on-page audit:** for every URL in the sitemap, validates Open Graph + Twitter Card completeness, JSON-LD/structured-data presence and validity, canonical and hreflang, meta description, H1 count, image alt-coverage. (Replaces orcascan.com's open-graph-validator concept in-process.)
- **Core Web Vitals + Lighthouse:** runs PageSpeed Insights for the home page and top URLs. Files findings on LCP > 2.5s, CLS > 0.1, INP > 200ms, Lighthouse SEO score < 90.
- **Real keyword data:** pulls Google Search Console Search Analytics over the last 28 days. Identifies "almost-ranking" queries (impressions ≥ 100, position 5-20, CTR below run-median) and writes them as `seo_keyword_opportunity` records.
- **AI-search citation visibility (GEO/LLMO):** for 5-10 brand-relevant queries, asks Anthropic Claude, OpenAI ChatGPT, and Perplexity whether SchemaBounce is cited. Files a finding when citation rate is below 25% across providers. (umoren.ai concept implemented in-process.)
- **Topic suggestions:** turns almost-ranking queries into concrete topics for blog-writer; messages them via `adl_send_message` and writes durable `seo_topic_suggestion` records.
- **Outreach simulation:** drafts plausible link-building outreach (guest post pitches, broken-link replacements) and records in `seo_outreach_log` with `status="would_send"`. Never sends.

## Sub-Agents

| Agent | Model | Responsibility |
|-------|-------|----------------|
| **auditor** | Haiku | Runs `adl_seo_meta_audit`, `adl_seo_pagespeed_audit`, `adl_seo_fetch_gsc_keywords`, `adl_seo_geo_visibility_check`. Files `seo_findings` and `seo_keyword_opportunity`. |
| **recommender** | Sonnet | Synthesizes findings + opportunities into topic suggestions and outreach candidates. Prefers almost-ranking queries. |
| **outreach-simulator** | Haiku | Drafts each outreach message and records to seo_outreach_log. Never sends. |

## Why Dry-Run For Outreach Only

The audit, GSC pulls, PageSpeed, and AI-search citation checks are real and produce real artifacts. **Outreach is dry-run only** — real send requires credential management (Mailgun/SES/Twitter) and a careful spam-prevention plan. Until that is built, the value is in the audit and the suggestion pipeline. Pretending to send is dishonest; we are honest about what we do and do not do.

## External APIs This Agent Reaches

The agent itself never makes raw HTTP calls. The four built-in OpenCLAW tools (`adl_seo_*`) are server-side, with SSRF guards, allowlists, and timeouts. They reach:

- `searchconsole.googleapis.com` (Google Search Console Search Analytics, URL Inspection, Sitemaps API)
- `pagespeedonline.googleapis.com` (PageSpeed Insights / Lighthouse)
- `api.anthropic.com`, `api.openai.com`, `api.perplexity.ai` via the existing ClawShell virtual-key proxy (citation visibility check; the agent never sees a real API key)
- The audited domain itself (one-shot HTML fetch for `adl_seo_meta_audit`, capped at 2 MB body, 10 s timeout, http(s) only, private-IP denied)

## Required North Star Keys

Set in your workspace's North Star zone:

- `brand_voice` — same as blog-writer; outreach drafts must match
- `product_catalog` — what we actually offer
- `competitive_anchors` — how we describe ourselves vs alternatives
- `company_glossary` — canonical terms

## Data the Bootstrap Script Stages

Before each run, the bootstrap script writes:

- `seo:audit:cache/sitemap_xml` — raw `public/sitemap.xml` content
- `seo:audit:cache/published_posts_json` — JSON list returned by `GET /api/v1/blog/posts`
- `seo:audit:cache/brand_queries` — JSON array of 5-10 queries the GEO check uses (e.g., "real-time CDC platform", "schemabounce vs fivetran"). Owned by the workspace operator.
- `seo:audit:cache/site_url` — the GSC property URL for the workspace (e.g., `https://schemabounce.com/`)

These are read by the auditor sub-agent. The agent itself does no outbound HTTP — every external call is brokered by an `adl_seo_*` built-in.
