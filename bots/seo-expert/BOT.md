---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: seo-expert
  displayName: "SEO Expert"
  version: "0.3.6"
  description: "Audits the workspace's connected site for SEO and GEO/AEO: Google Search Console and Bing Webmaster keyword data, Core Web Vitals, on-page meta, SERP rank tracking, AI citation share-of-voice (ChatGPT/Claude/Perplexity via CitationBench), llms.txt drafting, and GEO content recommendations. Surfaces topic opportunities for the blog writer and drafts simulated outreach for human review."
  category: content
  tags: ["seo", "audit", "content", "marketing", "research"]
agent:
  capabilities: ["seo", "research", "audit"]
  hostingMode: "openclaw"
  defaultDomain: "content"
  instructions: |
    ## Operating Rules
    - FOUNDATIONAL PHILOSOPHY: Foundational SEO is the base — original, expert, people-first content (E-E-A-T), technical soundness (crawlability, semantic HTML, Core Web Vitals, valid structured data), and real keyword performance. These are not optional. GEO (Generative Engine Optimization) / AEO (Answer Engine Optimization) is a FIRST-CLASS capability layered on top: the agent actively (a) measures AI citation share-of-voice across ChatGPT, Claude, and Perplexity for brand and category queries, and (b) applies GEO tactics — drafting llms.txt for human review, improving entity clarity, structuring content for answer-engine extraction (Q&A formatting, direct first-paragraph answers), and tracking citation share-of-voice run-over-run. GEO tactics amplify good foundational content; they do not substitute for it. Low citation share-of-voice is almost always a content quality signal, not a missing llms.txt.
    - ALLOWED GEO tactics: llms.txt/llms-full.txt (drafted for human review, never auto-published), entity clarity edits (name the product explicitly in context), Q&A section formatting, answer-engine-friendly page structure (direct answer before elaboration), citation share-of-voice measurement. These are legitimate and the agent should recommend them when warranted.
    - NOT recommended: AI-specific keyword phrasing (AI engines understand synonyms), inauthentic backlinks or artificial brand mentions, content fragmentation or chunking solely for LLM ingestion, claiming llms.txt alone will fix low citation scores without addressing the underlying content quality.
    - ALWAYS read brand_voice and product_catalog from Zone 1 before drafting any topic suggestion or outreach message.
    - The agent itself MUST NOT make raw HTTP calls. All external access goes through native MCP servers (e.g. google-search-console) which run as stdio subprocesses inside the workspace pod and enforce auth, scopes, and rate limits.
    - This bot is audit and dry-run only for outreach. Outreach is recorded in seo_outreach_log with status="would_send"; nothing leaves the cluster as a send.
    - On every run, emit at least one actionable seo_finding. "Everything looks fine" is not an acceptable finding.
    - Cover the full signal stack: crawlability and indexation status (Google AND Bing), semantic HTML and clear heading structure, page experience / Core Web Vitals (LCP, INP, CLS), Lighthouse SEO score, valid JSON-LD structured data (for rich-result eligibility), Open Graph + Twitter Card completeness, content quality and originality (thin/commodity content, missing first-hand expertise), real keyword performance from Google Search Console (impressions, CTR, position), Bing Webmaster search performance and crawl health (if connected), SERP rank tracking (DataForSEO position snapshots with run-over-run deltas), AND AI citation share-of-voice (ChatGPT, Claude, Perplexity) via the AI Citation Tracker MCP.
    - When proposing topics for blog-writer, prefer "almost-ranking" queries from GSC: impressions >= 100 AND position between 5 and 20 AND CTR below the run's median. Message blog-writer via adl_send_message AND write a seo_topic_suggestion record.
    - File a seo_finding for: pages blocked from crawling/indexing, non-semantic markup or missing/duplicate H1, missing or invalid og:* tags, missing twitter:* tags, missing or invalid JSON-LD, LCP > 2.5s on mobile, CLS > 0.1, missing meta description, weak title, thin or commodity content lacking first-hand expertise (<800 words or no original perspective), orphaned URLs, duplicate slugs, missing canonical. Also file an info-level seo_finding when AI citation share-of-voice drops more than 5 points run-over-run, with suggested_fix pointing to the underlying content quality gap (not to llms.txt or AI-specific hacks as a first response). File a separate seo_finding when llms.txt is missing or stale (last draft older than 90 days); suggested_fix = invoke geo-aeo skill to generate a new draft for human review.
    - Outreach simulation: for each plausible link-building target, write a seo_outreach_log row with channel in {email, twitter, linkedin}, a real draft message, and status="would_send". Never store contact PII for real people; use only public role-based addresses (e.g., editor@example.com).
  toolInstructions: |
    ## Tool Usage
    - Step 1: `adl_read_memory` namespace `bot:seo-expert:northstar` keys `brand_voice`, `product_catalog`, `competitive_anchors`
    - Step 2: `adl_read_memory` namespace `seo:audit:cache` key `sitemap_xml` (seeded by the bootstrap script before each run); list URLs.
    - Step 3: Spawn `auditor` sub-agent. Invoke the `seo-operations` skill and the `rank-tracking` skill. The auditor uses the Google Search Console MCP (`query_search_analytics`, `inspect_url`, `list_sitemaps`) for keyword data and indexation; `adl_proxy_call` for on-page meta audits (Open Graph, JSON-LD, canonical, H1; 10 calls/run, 32 KB cap); the pagespeed MCP (`analyze_page_speed`, `get_full_audit`, `crux_summary`) for Core Web Vitals and Lighthouse scores on the home page and top-3 URLs; the DataForSEO MCP (`serp_google_organic_live`) for keyword rank snapshots via the rank-tracking skill; and if the Bing Webmaster MCP is connected, `get_query_stats`, `get_keyword_data`, `get_crawl_issues`, and `get_url_info` for Bing/Copilot search performance and indexation health.
    - Step 4: Spawn `geo-auditor` sub-agent. Invoke the `geo-aeo` skill. The geo-auditor uses the AI Citation Tracker MCP (`research.ai_citation.check`, `research.ai_citation.share_of_voice`, `research.ai_citation.history`) to measure brand citation share-of-voice across ChatGPT, Claude, and Perplexity for the brand_queries from cache; uses the llms.txt Generator MCP (`generate-llms`) to produce a draft llms.txt for human review; and files GEO content recommendations (entity clarity, Q&A formatting) for almost-ranking pages. If either MCP is absent, the sub-agent emits an info-level finding and continues.
    - Step 5: For each finding, `adl_upsert_record` entity_type=`seo_findings` with severity, metric_name, metric_value, provider.
    - Step 6: For each almost-ranking GSC query, `adl_upsert_record` entity_type=`seo_keyword_opportunity`.
    - Step 7: Spawn `recommender` sub-agent; for each topic suggestion, `adl_upsert_record` entity_type=`seo_topic_suggestion` AND `adl_send_message` to `blog-writer` type=`finding`. Link to the seo_keyword_opportunity rows that justify it.
    - Step 8: Spawn `outreach-simulator` sub-agent; for each candidate, `adl_upsert_record` entity_type=`seo_outreach_log` with status="would_send".
    - Step 9: `adl_write_memory` namespace `seo:run:state` key `last_run` with timestamp + counts per metric_name.
model:
  provider: "anthropic"
  preferred: "sonnet_latest"
  fallback: "haiku_latest"
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
  entityTypesRead: ["blog_drafts", "seo_findings", "seo_outreach_log", "seo_topic_suggestion", "seo_keyword_opportunity", "seo_geo_citation", "seo_llms_txt_draft", "seo_rank_snapshot"]
  entityTypesWrite: ["seo_findings", "seo_outreach_log", "seo_topic_suggestion", "seo_keyword_opportunity", "seo_geo_citation", "seo_llms_txt_draft", "seo_rank_snapshot"]
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
  mode: "restricted"
  # Page fetches (sitemap, robots.txt, per-URL meta audit) go through adl_proxy_call,
  # which uses the ADL's own SSRF-guarded proxy — NOT the egress allowedDomains list.
  # The workspace's audited domain therefore does NOT need to appear here.
  # If future direct-proxy use is added, the admin can extend allowedDomains per-seat.
  allowedDomains:
    - "googleapis.com"
    - "www.googleapis.com"
    - "searchconsole.googleapis.com"
    - "pagespeedonline.googleapis.com"
    - "api.anthropic.com"
    - "api.openai.com"
    - "api.perplexity.ai"
    - "mcp.citationbench.com"
    - "api.citationbench.com"
    - "api.dataforseo.com"
    - "ssl.bing.com"
    - "backend.composio.dev"
plugins: []
mcpServers:
  - ref: "tools/google-search-console"
    required: true
    reason: "Real keyword data, impressions, CTR, and position trends. A native stdio MCP server hosted in the workspace pod, authorized once via Google OAuth from the deploy modal (no Composio). This is the auditor's data path for almost-ranking opportunities; without it the auditor still runs but only emits Open-Graph and structured-data findings."
    config:
      default_lookback_days: 28
  - ref: "tools/pagespeed"
    required: false
    reason: "Core Web Vitals and Lighthouse scores via Google PageSpeed Insights API. The auditor calls analyze_page_speed, get_full_audit, and crux_summary for the site's home page and top-3 URLs. Requires GOOGLE_API_KEY with PageSpeed Insights API enabled. Without it, the auditor skips performance metrics (LCP, CLS, INP, Lighthouse SEO score) and emits only on-page meta and GSC keyword findings."
  - ref: "tools/ai-citation-tracker"
    required: false
    reason: "GEO measurement: tracks AI citation share-of-voice for brand and category queries across ChatGPT, Claude, and Perplexity via the CitationBench hosted MCP. Requires CITATIONBENCH_API_KEY. Without it, the geo-auditor emits an info-level finding noting measurement is unavailable and skips Part A of the geo-aeo skill; Parts B and C (llms.txt drafting and content recommendations) still run."
  - ref: "tools/llms-txt-generator"
    required: false
    reason: "GEO tactic: generates llms.txt and llms-full.txt drafts for the connected site for human review before publishing. Requires OPENAI_API_KEY. Without it, the geo-auditor emits an info-level finding and skips the llms.txt draft step."
  - ref: "tools/google-analytics"
    required: false
    reason: "GA4 traffic, engagement, and conversion data via Composio managed-OAuth. Supplements GSC keyword data with per-channel sessions, landing-page engagement rate, and conversion event verification. Requires COMPOSIO_API_KEY with a Google Analytics account connected in Composio. Without it, the auditor skips GA4-side engagement and conversion metrics; GSC and PageSpeed findings still run."
  - ref: "tools/dataforseo"
    required: false
    reason: "Keyword difficulty, SERP gap analysis, backlink profile, and on-page crawl via the official DataForSEO MCP. Adds depth to almost-ranking opportunity scoring (keyword difficulty + volume from Labs), backlink context for outreach simulation, and structured on-page crawl data beyond adl_proxy_call. Also the engine for the rank-tracking skill: serp_google_organic_live provides the SERP position snapshots. Requires DATAFORSEO_USERNAME and DATAFORSEO_PASSWORD from a paid DataForSEO account (metered, customer-supplied). Without it, the auditor relies on GSC signals alone for opportunity scoring, and rank tracking is skipped."
  - ref: "tools/bing-webmaster"
    required: false
    reason: "Bing and Microsoft Copilot search performance, crawl health, keyword analytics, and URL submission via the Bing Webmaster Tools API. The auditor uses get_query_stats and get_keyword_data for Bing-side keyword CTR signals that GSC does not cover; get_crawl_issues and get_url_info for Bing-specific indexation health; submit_url_batch when new content needs immediate Bing indexation. Critical for sites targeting Copilot AI answers — Bing indexation is required for Copilot eligibility. Requires BING_WEBMASTER_API_KEY from bing.com/webmasters. Without it, the auditor skips Bing/Copilot signals; Google SEO findings still run."
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/seo-operations@1.0.0"
  - ref: "skills/geo-aeo@1.0.0"
  - ref: "skills/rank-tracking@1.0.0"
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
setup:
  steps:
    - id: set-brand-voice
      name: "Define brand voice"
      description: "Tone, style guidelines, and terminology preferences for all content"
      type: north_star
      key: brand_voice
      group: configuration
      priority: required
      reason: "Every topic suggestion and outreach draft must match the established brand tone"
      ui:
        inputType: text
        placeholder: "e.g., Technical but approachable, developer-focused, no marketing jargon"
    - id: set-product-catalog
      name: "Define product catalog"
      description: "Current features, product names, and positioning for accurate topic suggestions"
      type: north_star
      key: product_catalog
      group: configuration
      priority: required
      reason: "Prevents topic suggestions that reference outdated features or incorrect product names"
      ui:
        inputType: text
        placeholder: "Product names, feature list, positioning summary"
    - id: set-competitive-anchors
      name: "Define competitive anchors"
      description: "How the workspace's product compares to alternatives; used for almost-ranking query framing"
      type: north_star
      key: competitive_anchors
      group: configuration
      priority: required
      reason: "Almost-ranking queries often include comparison terms; accurate framing prevents misleading suggestions"
      ui:
        inputType: text
        placeholder: "e.g., vs Fivetran: real-time vs batch; vs Airbyte: hosted vs self-managed"
    - id: set-site-url
      name: "Set the site URL to audit"
      description: "The Google Search Console property URL for the site this bot audits (must match your verified GSC property exactly)"
      type: config
      group: configuration
      target:
        namespace: seo:audit:cache
        key: site_url
      priority: required
      reason: "The auditor passes this URL to Google Search Console and uses it as the sitemap base. It must match a verified GSC property."
      ui:
        inputType: text
        placeholder: "https://www.yoursite.com/"
    - id: set-brand-queries
      name: "Set brand and category queries"
      description: "JSON array of 5-10 queries to track for AI citation share-of-voice (brand + category)"
      type: config
      group: configuration
      target:
        namespace: seo:audit:cache
        key: brand_queries
      priority: required
      reason: "The geo-auditor uses these queries to measure brand citation across ChatGPT, Claude, and Perplexity run-over-run"
      ui:
        inputType: json
        placeholder: '["your brand name", "your brand vs competitor", "category keyword you want to rank for"]'
    - id: connect-google-search-console
      name: "Connect Google Search Console"
      description: "Authorize the Google Search Console MCP server with your Google account to pull keyword and indexation data"
      type: mcp_connection
      ref: tools/google-search-console
      group: connections
      priority: required
      reason: "Real keyword data (impressions, CTR, position) and indexation status require a verified GSC connection; without it the auditor falls back to on-page meta findings only"
      ui:
        icon: google
        actionLabel: "Connect Google Search Console"
    - id: connect-pagespeed
      name: "Connect PageSpeed Insights"
      description: "Google PageSpeed Insights API for Core Web Vitals and Lighthouse SEO scores"
      type: mcp_connection
      ref: tools/pagespeed
      group: connections
      priority: optional
      reason: "Without it the auditor skips LCP, CLS, INP, and Lighthouse SEO score measurements; on-page meta and GSC findings still run"
      ui:
        icon: gauge
        actionLabel: "Connect PageSpeed"
    - id: connect-ai-citation-tracker
      name: "Connect AI Citation Tracker"
      description: "CitationBench MCP for measuring brand citation share-of-voice across ChatGPT, Claude, and Perplexity"
      type: mcp_connection
      ref: tools/ai-citation-tracker
      group: connections
      priority: optional
      reason: "Without CITATIONBENCH_API_KEY the geo-auditor skips AI citation measurement and emits an info-level finding; the audit and topic suggestions still run"
      ui:
        icon: chart
        actionLabel: "Connect Citation Tracker"
    - id: connect-llms-txt-generator
      name: "Connect llms.txt Generator"
      description: "Generates llms.txt and llms-full.txt drafts for human review"
      type: mcp_connection
      ref: tools/llms-txt-generator
      group: connections
      priority: optional
      reason: "Without OPENAI_API_KEY the geo-auditor skips the llms.txt draft step and emits an info-level finding"
      ui:
        icon: file
        actionLabel: "Connect llms.txt Generator"
    - id: set-company-glossary
      name: "Define company glossary"
      description: "Technical terms, acronyms, and product-specific terminology"
      type: north_star
      key: company_glossary
      group: configuration
      priority: recommended
      reason: "Ensures topic suggestions and outreach drafts use consistent internal terminology"
      ui:
        inputType: text
        placeholder: "e.g., CDC = Change Data Capture"
    - id: connect-google-analytics
      name: "Connect Google Analytics"
      description: "GA4 traffic, engagement, and conversion data via Composio managed-OAuth. Supplements GSC keyword signals with per-channel sessions and conversion verification."
      type: mcp_connection
      ref: tools/google-analytics
      group: connections
      priority: optional
      reason: "Without it the auditor skips GA4 engagement and conversion metrics; GSC and PageSpeed findings still run. Requires COMPOSIO_API_KEY with a Google Analytics account connected in Composio."
      ui:
        icon: chart
        actionLabel: "Connect Google Analytics"
    - id: connect-dataforseo
      name: "Connect DataForSEO"
      description: "Keyword difficulty, SERP analysis, backlinks, on-page crawl, and SERP rank snapshots via the DataForSEO API. Requires a paid DataForSEO account (metered, customer-supplied)."
      type: mcp_connection
      ref: tools/dataforseo
      group: connections
      priority: optional
      reason: "Without it the auditor relies on GSC signals alone for opportunity scoring, and rank tracking is skipped entirely. With it: keyword difficulty + volume from DataForSEO Labs, backlink context for outreach simulation, structured on-page crawl data, and daily SERP rank snapshots via serp_google_organic_live. Requires DATAFORSEO_USERNAME and DATAFORSEO_PASSWORD."
      ui:
        icon: search
        actionLabel: "Connect DataForSEO"
    - id: connect-bing-webmaster
      name: "Connect Bing Webmaster Tools"
      description: "Bing and Microsoft Copilot search performance, crawl diagnostics, keyword analytics, and URL submission via the Bing Webmaster Tools API."
      type: mcp_connection
      ref: tools/bing-webmaster
      group: connections
      priority: optional
      reason: "Without it the auditor skips Bing/Copilot-specific keyword CTR, crawl health, and indexation data. Required for sites targeting Copilot AI answers — Bing indexation is the eligibility gate for Copilot responses. Requires BING_WEBMASTER_API_KEY from bing.com/webmasters → Settings → API Access."
      ui:
        icon: search
        actionLabel: "Connect Bing Webmaster"
---

# SEO Expert

Audits the workspace's connected site footprint, generates topic suggestions for the blog-writer, and drafts simulated outreach for review. **Audit and dry-run only.** Real sends require credentials and a Phase 2 plan; this bot does not perform any external send.

## What It Does

- **Modern on-page audit:** for every URL in the sitemap, validates Open Graph + Twitter Card completeness, JSON-LD/structured-data presence and validity, canonical and hreflang, meta description, H1 count, image alt-coverage. (Replaces orcascan.com's open-graph-validator concept in-process.)
- **Core Web Vitals + Lighthouse:** uses the pagespeed MCP to run Google PageSpeed Insights for the home page and top-3 URLs. Files findings on LCP > 2.5s, CLS > 0.1, INP > 200ms, Lighthouse SEO score < 90. Requires the `tools/pagespeed` MCP connection with a valid `GOOGLE_API_KEY`.
- **Real keyword data:** pulls Google Search Console Search Analytics over the last 28 days. Identifies "almost-ranking" queries (impressions ≥ 100, position 5-20, CTR below run-median) and writes them as `seo_keyword_opportunity` records.
- **Bing/Copilot search signals:** if the Bing Webmaster MCP is connected, pulls `get_query_stats` and `get_keyword_data` for Bing-side CTR, and `get_crawl_issues` + `get_url_info` for Bing indexation health. Files `seo_findings` for pages indexed in Google but blocked in Bing. Requires `BING_WEBMASTER_API_KEY`.
- **SERP rank tracking:** uses the `rank-tracking` skill to snapshot SERP positions for the workspace's target keywords via `serp_google_organic_live` (DataForSEO MCP). Persists positions as `seo_rank_snapshot` records, computes run-over-run deltas, and files `seo_findings` on movements of 3+ positions. Alerts the executive-assistant on 10+ position swings. Requires DataForSEO MCP connection.
- **AI citation share-of-voice (GEO measurement):** uses the `tools/ai-citation-tracker` MCP (CitationBench hosted MCP at `mcp.citationbench.com/mcp`) to check whether the workspace's brand is cited, mentioned, or absent for brand and category queries across ChatGPT, Claude, and Perplexity. Requires `CITATIONBENCH_API_KEY`. Without a key the server returns demo data; the workflow still runs. Results are written as `seo_geo_citation` records and compared run-over-run via `research.ai_citation.history`.
- **llms.txt drafting (GEO tactic):** uses the `tools/llms-txt-generator` MCP (npm `llms-txt-generator@0.0.3`, `generate-llms` tool) to draft `llms.txt` and `llms-full.txt` for the connected site. Requires `OPENAI_API_KEY`. The draft is stored as `seo_llms_txt_draft` with `requires_human_review=true` and never auto-published. The executive-assistant is messaged when a new draft is ready.
- **GEO content recommendations:** for almost-ranking pages identified by the auditor, the geo-auditor checks entity clarity, Q&A formatting, and answer-engine-friendly structure. Files `seo_findings` (severity=low) with specific content edit suggestions.
- **Topic suggestions:** turns almost-ranking queries into concrete topics for blog-writer; messages them via `adl_send_message` and writes durable `seo_topic_suggestion` records.
- **Outreach simulation:** drafts plausible link-building outreach (guest post pitches, broken-link replacements) and records in `seo_outreach_log` with `status="would_send"`. Never sends.

## Sub-Agents

| Agent | Model | Responsibility |
|-------|-------|----------------|
| **auditor** | Haiku | Invokes `seo-operations` and `rank-tracking` skills. Uses Google Search Console MCP for keyword data and indexation; `adl_proxy_call` for on-page meta; pagespeed MCP for Core Web Vitals; DataForSEO MCP for rank snapshots; Bing Webmaster MCP (if connected) for Bing/Copilot signals. Files `seo_findings`, `seo_keyword_opportunity`, and `seo_rank_snapshot`. |
| **geo-auditor** | Haiku | Invokes `geo-aeo` skill. Uses AI Citation Tracker MCP for citation share-of-voice measurement; llms.txt Generator MCP for draft generation; files GEO content recommendations on almost-ranking pages. |
| **recommender** | Sonnet | Synthesizes findings + opportunities into topic suggestions and outreach candidates. Prefers almost-ranking queries. |
| **outreach-simulator** | Haiku | Drafts each outreach message and records to seo_outreach_log. Never sends. |

## Why Dry-Run For Outreach Only

The audit, GSC pulls, PageSpeed, and AI-search citation checks are real and produce real artifacts. **Outreach is dry-run only**, real send requires credential management (Mailgun/SES/Twitter) and a careful spam-prevention plan. Until that is built, the value is in the audit and the suggestion pipeline. Pretending to send is dishonest; we are honest about what we do and do not do.

## External APIs This Agent Reaches

The agent makes no raw HTTP calls. External access goes through MCP subprocesses and the ADL proxy:

- `searchconsole.googleapis.com` — reached by the Google Search Console MCP subprocess (`query_search_analytics`, `inspect_url`, `list_sitemaps`).
- `pagespeedonline.googleapis.com` — reached by the pagespeed MCP subprocess (`analyze_page_speed`, `get_full_audit`, `crux_summary`). Requires `GOOGLE_API_KEY`.
- Audited domain HTML — one-shot fetch via `adl_proxy_call` (32 KB body cap, 10 s timeout, HTTPS only, private-IP blocked). Used for Open Graph, JSON-LD, canonical, and H1 checks.
- `mcp.citationbench.com` — reached by the AI Citation Tracker MCP (streamable-http transport). Requires `CITATIONBENCH_API_KEY`. Used by the geo-auditor for `research.ai_citation.check`, `research.ai_citation.share_of_voice`, and `research.ai_citation.history`.
- `api.openai.com` — reached by the llms-txt-generator MCP subprocess (`generate-llms`). Requires `OPENAI_API_KEY`. Used by the geo-auditor to draft llms.txt.
- `api.dataforseo.com` — reached by the DataForSEO MCP subprocess. Also the engine for rank tracking via `serp_google_organic_live` (rank-tracking skill). Requires `DATAFORSEO_USERNAME` + `DATAFORSEO_PASSWORD`.
- `ssl.bing.com` — reached by the Bing Webmaster Tools MCP subprocess (`get_query_stats`, `get_keyword_data`, `get_crawl_issues`, `get_url_info`). Requires `BING_WEBMASTER_API_KEY`. Optional.
- `api.anthropic.com`, `api.perplexity.ai` — in the egress allowlist for any future direct AI-engine probing needs.

## Required North Star Keys

Set in your workspace's North Star zone:

- `brand_voice`: same as blog-writer; outreach drafts must match
- `product_catalog`: what we actually offer
- `competitive_anchors`: how we describe ourselves vs alternatives
- `company_glossary`: canonical terms

## Data the Bootstrap Script Stages

Before each run, the bootstrap script writes:

- `seo:audit:cache/sitemap_xml`: raw `public/sitemap.xml` content
- `seo:audit:cache/published_posts_json`: JSON list returned by `GET /api/v1/blog/posts`
- `seo:audit:cache/brand_queries`: JSON array of 5-10 brand-relevant queries set via the `set-brand-queries` setup step. Read by the geo-auditor sub-agent for AI citation share-of-voice checks via the AI Citation Tracker MCP.
- `seo:audit:cache/site_url`: the GSC property URL set via the `set-site-url` setup step (e.g., `https://www.yoursite.com/`). Must match a verified GSC property exactly.

The auditor sub-agent reads these at run start. The agent itself does no direct outbound HTTP; all external calls go through MCP subprocesses or `adl_proxy_call`.
