---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: seo-expert
  displayName: "SEO Expert"
  version: "0.1.13"
  description: "Audits SchemaBounce SEO across core signals (Google Search Console keyword data, Core Web Vitals via PageSpeed Insights, Open Graph, structured data), surfaces topic opportunities for the blog writer, and drafts simulated outreach for human review."
  category: content
  tags: ["seo", "audit", "content", "marketing", "research"]
agent:
  capabilities: ["seo", "research", "audit"]
  hostingMode: "openclaw"
  defaultDomain: "content"
  instructions: |
    ## Operating Rules
    - FOUNDATIONAL PHILOSOPHY (Google AI optimization guide): Google's generative AI features (AI Overviews, AI Mode) are rooted in core Search ranking and quality systems. There is no separate "AI SEO" lever. The way to earn visibility in AI features is the same as earning visibility in Search: original, helpful, people-first content grounded in real expertise (E-E-A-T), plus technical soundness (crawlability, semantic HTML, page experience, valid structured data for rich-result eligibility). AI-search citation is a downstream OUTCOME of this, never a thing to optimize directly.
    - DO NOT file findings or topic suggestions that recommend "AI-only" tactics Google explicitly says are unnecessary: no llms.txt / AI-text / machine-readable marker files, no content chunking or fragmentation for LLMs, no AI-specific keyword phrasing (systems understand synonyms), and no inauthentic backlinks or artificial brand mentions. If you catch yourself recommending any of these, replace it with the foundational fix instead.
    - ALWAYS read brand_voice and product_catalog from Zone 1 before drafting any topic suggestion or outreach message.
    - The agent itself MUST NOT make raw HTTP calls. All external access goes through native MCP servers (e.g. google-search-console) which run as stdio subprocesses inside the workspace pod and enforce auth, scopes, and rate limits.
    - This bot is audit and dry-run only for outreach. Outreach is recorded in seo_outreach_log with status="would_send"; nothing leaves the cluster as a send.
    - On every run, emit at least one actionable seo_finding. "Everything looks fine" is not an acceptable finding.
    - Cover the signals Google's AI features are actually built on: crawlability and indexation status, semantic HTML and clear heading structure, page experience / Core Web Vitals (LCP, INP, CLS), Lighthouse SEO score, valid JSON-LD structured data (for rich-result eligibility, not as an AI requirement), Open Graph + Twitter Card completeness, content quality and originality (thin/commodity content, missing first-hand expertise), and real keyword performance from Google Search Console (impressions, CTR, position). Track AI-search citation visibility (do ChatGPT, Claude, Perplexity, Gemini cite us for brand and category queries?) as a downstream OUTCOME metric only, the fix for low citation is better foundational content, never an AI-specific hack.
    - When proposing topics for blog-writer, prefer "almost-ranking" queries from GSC: impressions ≥ 100 AND position between 5 and 20 AND CTR below the run's median. Message blog-writer via adl_send_message AND write a seo_topic_suggestion record.
    - File a seo_finding for: pages blocked from crawling/indexing, non-semantic markup or missing/duplicate H1, missing or invalid og:* tags, missing twitter:* tags, missing or invalid JSON-LD, LCP > 2.5s on mobile, CLS > 0.1, missing meta description, weak title, thin or commodity content lacking first-hand expertise (<800 words or no original perspective), orphaned URLs, duplicate slugs, missing canonical. Also track AI-search citation rate < 25% across providers for primary brand queries as an info-level OUTCOME signal, but its suggested_fix must always be a foundational content/quality improvement, never llms.txt, chunking, or keyword phrasing.
    - Outreach simulation: for each plausible link-building target, write a seo_outreach_log row with channel in {email, twitter, linkedin}, a real draft message, and status="would_send". Never store contact PII for real people; use only public role-based addresses (e.g., editor@example.com).
  toolInstructions: |
    ## Tool Usage
    - Step 1: `adl_read_memory` namespace `bot:seo-expert:northstar` keys `brand_voice`, `product_catalog`, `competitive_anchors`
    - Step 2: `adl_read_memory` namespace `seo:audit:cache` key `sitemap_xml` (seeded by the bootstrap script before each run); list URLs.
    - Step 3: Spawn `auditor` sub-agent. The auditor uses the native Google Search Console MCP server (`query_search_analytics`, `inspect_url`, `list_sitemaps`) for real keyword data and indexation status; `adl_proxy_call` for sitemap-URL meta audits (Open Graph, JSON-LD, canonical, H1; 10 calls/run, 32 KB cap); and the pagespeed MCP (`analyze_page_speed`, `get_full_audit`, `crux_summary`) for Core Web Vitals and Lighthouse scores on the home page and top-3 URLs. GEO/citation visibility (querying external LLMs for brand mentions) has no MCP available yet and is deferred.
    - Step 4: For each finding, `adl_upsert_record` entity_type=`seo_findings` with severity, metric_name, metric_value, provider.
    - Step 5: For each almost-ranking GSC query, `adl_upsert_record` entity_type=`seo_keyword_opportunity`.
    - Step 6: Spawn `recommender` sub-agent; for each topic suggestion, `adl_upsert_record` entity_type=`seo_topic_suggestion` AND `adl_send_message` to `blog-writer` type=`finding`. Link to the seo_keyword_opportunity rows that justify it.
    - Step 7: Spawn `outreach-simulator` sub-agent; for each candidate, `adl_upsert_record` entity_type=`seo_outreach_log` with status="would_send".
    - Step 8: `adl_write_memory` namespace `seo:run:state` key `last_run` with timestamp + counts per metric_name.
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
  - ref: "tools/google-search-console"
    required: true
    reason: "Real keyword data, impressions, CTR, and position trends. A native stdio MCP server hosted in the workspace pod, authorized once via Google OAuth from the deploy modal (no Composio). This is the auditor's data path for almost-ranking opportunities; without it the auditor still runs but only emits Open-Graph and structured-data findings."
    config:
      default_lookback_days: 28
  - ref: "tools/pagespeed"
    required: false
    reason: "Core Web Vitals and Lighthouse scores via Google PageSpeed Insights API. The auditor calls analyze_page_speed, get_full_audit, and crux_summary for the site's home page and top-3 URLs. Requires GOOGLE_API_KEY with PageSpeed Insights API enabled. Without it, the auditor skips performance metrics (LCP, CLS, INP, Lighthouse SEO score) and emits only on-page meta and GSC keyword findings."
skills:
  - ref: "skills/platform-awareness@1.0.0"
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
- **Core Web Vitals + Lighthouse:** uses the pagespeed MCP to run Google PageSpeed Insights for the home page and top-3 URLs. Files findings on LCP > 2.5s, CLS > 0.1, INP > 200ms, Lighthouse SEO score < 90. Requires the `tools/pagespeed` MCP connection with a valid `GOOGLE_API_KEY`.
- **Real keyword data:** pulls Google Search Console Search Analytics over the last 28 days. Identifies "almost-ranking" queries (impressions ≥ 100, position 5-20, CTR below run-median) and writes them as `seo_keyword_opportunity` records.
- **AI-search citation visibility (GEO/LLMO):** not yet implemented. No MCP is available to query Claude, ChatGPT, and Perplexity for brand citations in-process. The `brand_queries` memory key is staged for when a GEO MCP is wired. Track citation manually as a quarterly exercise until then.
- **Topic suggestions:** turns almost-ranking queries into concrete topics for blog-writer; messages them via `adl_send_message` and writes durable `seo_topic_suggestion` records.
- **Outreach simulation:** drafts plausible link-building outreach (guest post pitches, broken-link replacements) and records in `seo_outreach_log` with `status="would_send"`. Never sends.

## Sub-Agents

| Agent | Model | Responsibility |
|-------|-------|----------------|
| **auditor** | Haiku | Uses `query_search_analytics`, `inspect_url`, `list_sitemaps` (Google Search Console MCP) for keyword data and indexation; `adl_proxy_call` for on-page meta (Open Graph, JSON-LD, canonical, H1) per sitemap URL; `analyze_page_speed`, `get_full_audit`, `crux_summary` (pagespeed MCP) for Core Web Vitals. Files `seo_findings` and `seo_keyword_opportunity`. |
| **recommender** | Sonnet | Synthesizes findings + opportunities into topic suggestions and outreach candidates. Prefers almost-ranking queries. |
| **outreach-simulator** | Haiku | Drafts each outreach message and records to seo_outreach_log. Never sends. |

## Why Dry-Run For Outreach Only

The audit, GSC pulls, PageSpeed, and AI-search citation checks are real and produce real artifacts. **Outreach is dry-run only**, real send requires credential management (Mailgun/SES/Twitter) and a careful spam-prevention plan. Until that is built, the value is in the audit and the suggestion pipeline. Pretending to send is dishonest; we are honest about what we do and do not do.

## External APIs This Agent Reaches

The agent makes no raw HTTP calls. External access goes through MCP subprocesses and the ADL proxy:

- `searchconsole.googleapis.com` — reached by the Google Search Console MCP subprocess (`query_search_analytics`, `inspect_url`, `list_sitemaps`).
- `pagespeedonline.googleapis.com` — reached by the pagespeed MCP subprocess (`analyze_page_speed`, `get_full_audit`, `crux_summary`). Requires `GOOGLE_API_KEY`.
- Audited domain HTML — one-shot fetch via `adl_proxy_call` (32 KB body cap, 10 s timeout, HTTPS only, private-IP blocked). Used for Open Graph, JSON-LD, canonical, and H1 checks.
- `api.anthropic.com`, `api.openai.com`, `api.perplexity.ai` — in the egress allowlist for a future GEO/citation-visibility MCP. Not currently used.

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
- `seo:audit:cache/brand_queries`: JSON array of 5-10 brand-relevant queries (e.g., "real-time CDC platform", "schemabounce vs fivetran"). Staged for when a GEO/citation-visibility MCP is wired; not read by any current sub-agent.
- `seo:audit:cache/site_url`: the GSC property URL for the workspace (e.g., `https://schemabounce.com/`)

The auditor sub-agent reads these at run start. The agent itself does no direct outbound HTTP; all external calls go through MCP subprocesses or `adl_proxy_call`.
