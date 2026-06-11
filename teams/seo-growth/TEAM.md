---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: seo-growth
  displayName: "SEO Growth"
  version: "1.0.0"
  description: "Search and answer-engine growth loop covering technical SEO and GEO/AEO audits, real keyword and rank data, AI citation share-of-voice, and content production from the opportunities the audit finds"
  domain: marketing
  category: marketing
  tags: ["seo", "geo", "aeo", "content", "marketing", "keyword-research", "rank-tracking", "ai-citation", "core-web-vitals"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/seo-expert@0.3.6"
  - ref: "bots/blog-writer@1.0.15"
northStar:
  industry: "SEO and Content Marketing"
  context: "Team running search and answer-engine growth for a site: technical and on-page SEO audits, keyword and rank tracking, AI citation measurement, and the content production that fills the gaps the audit finds"
  requiredKeys:
    - brand_voice
    - product_catalog
    - competitive_anchors
    - company_glossary
orgChart:
  lead: seo-expert
  domains:
    - name: "SEO and GEO Audit"
      description: "Technical and on-page audits, Google Search Console and Bing keyword data, Core Web Vitals, SERP rank tracking, and AI citation share-of-voice"
      head: seo-expert
    - name: "Content Production"
      description: "Turns almost-ranking keyword opportunities into drafted blog posts, routed to human review before publishing"
      head: blog-writer
  roles:
    - bot: seo-expert
      role: lead
      reportsTo: null
      domain: seo-geo-audit
    - bot: blog-writer
      role: specialist
      reportsTo: seo-expert
      domain: content-production
  escalation:
    critical: seo-expert
    unhandled: seo-expert
    paths:
      - name: "Critical SEO Finding"
        trigger: "critical_seo_finding"
        chain: [seo-expert]
      - name: "Rank Drop Alert"
        trigger: "rank_drop_detected"
        chain: [seo-expert]
---
# SEO Growth

Two bots forming a search-growth loop. SEO Expert audits the connected site and finds the keyword and content opportunities. Blog Writer turns those opportunities into drafted posts for human review. The audit is real and produces real artifacts. Publishing and outreach stay human-gated.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| SEO Expert | Lead. Technical and on-page audit, GSC and Bing keyword data, Core Web Vitals, SERP rank tracking, AI citation share-of-voice, topic suggestions, dry-run outreach | @weekly |
| Blog Writer | Specialist. Writes technical blog drafts from the topic suggestions the audit produces, routed to human review before publishing | @weekly |

## How They Work Together

SEO Expert is the lead. Each week it audits the workspace's connected site across the full signal stack: crawlability and indexation in Google and Bing, semantic HTML and heading structure, Core Web Vitals and Lighthouse SEO score, structured data and Open Graph completeness, real keyword performance from Google Search Console, SERP rank snapshots from DataForSEO, and AI citation share-of-voice across ChatGPT, Claude, and Perplexity. It writes a finding for every issue and a keyword opportunity for every almost-ranking query.

When SEO Expert finds an almost-ranking query (impressions at or above 100, position between 5 and 20, click-through below the run median), it sends a topic suggestion to Blog Writer and records a durable `seo_topic_suggestion` linked to the keyword opportunity rows that justify it. Blog Writer reads those suggestions at the start of its run, validates the topic against the product catalog and editorial calendar, drafts the post in research, draft, and self-edit phases, and submits it as a draft for human review. Nothing publishes without a person approving it.

Both bots read the same North Star configuration so the audit framing and the content voice stay consistent. SEO Expert escalates critical findings and large rank drops for human attention. Blog Writer routes every draft to the platform's human review queue and never auto-publishes.

**Communication flow:**
- SEO Expert almost-ranking query -> topic suggestion to Blog Writer + `seo_topic_suggestion` record
- SEO Expert critical finding or 10-plus position rank swing -> human escalation
- Blog Writer completed draft -> human review queue (status draft, then submit for review)
- Blog Writer missing context -> request for human input rather than a thin post

## Required and Optional Connections

The team works with one required connection per bot and adds depth as you connect more data sources.

**Required to get value:**
- **Google Search Console** (SEO Expert). Real keyword data, impressions, click-through, position, and indexation. Without it the auditor still runs but only emits on-page meta and structured-data findings.
- **Blog drafts connector** (Blog Writer). A workspace service account with the `blog:write` scope. The bot holds no credentials directly; the runtime injects the service account at execution time.

**Optional, each adds a signal:**
- **PageSpeed Insights** (SEO Expert). Core Web Vitals (LCP, INP, CLS) and Lighthouse SEO score for the home page and top URLs. Needs a Google API key.
- **Google Analytics** (SEO Expert). GA4 sessions, engagement, and conversion verification through Composio managed OAuth.
- **DataForSEO** (SEO Expert). Keyword difficulty, SERP gap analysis, backlink context, and the SERP rank snapshots that drive rank tracking. Needs a paid DataForSEO account.
- **Bing Webmaster Tools** (SEO Expert). Bing and Microsoft Copilot search performance, crawl health, and indexation. Bing indexation is the eligibility gate for Copilot answers.
- **AI Citation Tracker** (SEO Expert). Brand citation share-of-voice across ChatGPT, Claude, and Perplexity through the CitationBench hosted MCP.
- **llms.txt Generator** (SEO Expert). Drafts `llms.txt` and `llms-full.txt` for human review. Needs an OpenAI API key.

## Getting Started

1. Activate the team via the ADL onboarding wizard. This deploys both bots with the org chart pre-wired: SEO Expert as lead, Blog Writer reporting to it.
2. Fill in the North Star keys: `brand_voice`, `product_catalog`, `competitive_anchors`, `company_glossary`.
3. Set SEO Expert's two config values when prompted: `site_url` (your verified Google Search Console property) and `brand_queries` (5 to 10 brand and category queries for AI citation tracking).
4. Connect Google Search Console and the blog drafts connector. These are the minimum for value.
5. Add the optional connections you want (PageSpeed, DataForSEO, Bing, Google Analytics, AI Citation Tracker, llms.txt Generator) as your data sources allow.
6. Bots begin running on their weekly schedules. Check SEO Expert's findings and Blog Writer's drafts in your workspace.

See `SETUP.md` for step-by-step credential setup for each connection.
