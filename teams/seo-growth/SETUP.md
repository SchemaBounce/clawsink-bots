# SEO Growth Suite: Setup Guide

This guide walks through activating both bots, connecting the two things that matter most (Google Search Console and the blog drafts connector), and optionally adding the data sources that deepen the audit.

## What each bot does

| Bot | What it does |
|-----|--------------|
| SEO Expert | Audits the connected site weekly: crawl and indexation health in Google and Bing, semantic HTML, Core Web Vitals, structured data, real Google Search Console keyword data, SERP rank snapshots, and AI citation share-of-voice across ChatGPT, Claude, and Perplexity. Files a finding for every issue and a topic suggestion for every almost-ranking query. Drafts link-building outreach as dry-run only and never sends. |
| Blog Writer | Reads SEO Expert's topic suggestions, validates each against the product catalog and editorial calendar, and writes a technical blog draft in research, draft, and self-edit phases. Submits every draft for human review. Never auto-publishes. |

---

## Step 1: Activate the seo-growth team

In SchemaBounce, open your workspace and go to the Agents section. Find the SEO Growth team in the catalog and click Activate. This deploys both bots as agents with the org chart pre-wired: SEO Expert as lead, Blog Writer reporting to it.

After activation, fill in the North Star configuration keys when prompted. Both bots read these, so the audit framing and the content voice stay consistent:

- `brand_voice` - Tone and style for every topic suggestion, outreach draft, and blog post (e.g. `Technical but approachable, developer-focused, no marketing jargon`)
- `product_catalog` - Current product names, features, and positioning, so suggestions reference real features
- `competitive_anchors` - How your product compares to alternatives, used to frame comparison queries (e.g. `vs Fivetran: real-time vs batch`)
- `company_glossary` - Canonical terms and acronyms so content stays consistent (e.g. `CDC = Change Data Capture`)

SEO Expert also needs two config values, set during its setup steps:

- `site_url` - The Google Search Console property URL for the site this bot audits. It must match a verified GSC property exactly (e.g. `https://www.yoursite.com/`).
- `brand_queries` - A JSON array of 5 to 10 brand and category queries to track for AI citation share-of-voice (e.g. `["your brand name", "your brand vs competitor", "category keyword"]`).

---

## Step 2: Connect the two required sources

These two connections are the minimum for value. Everything in Step 3 is optional depth on top.

### Google Search Console (SEO Expert)

What you get: real keyword data (impressions, click-through, position) and indexation status. This is the data path for almost-ranking opportunities. Without it, the auditor still runs but only emits on-page meta and structured-data findings.

How to connect:

1. In SchemaBounce, open the SEO Expert agent, go to Connections, and click Connect Google Search Console.
2. A popup opens Google's consent screen using SchemaBounce's platform OAuth client. Approve the read-only Search Console scopes.
3. Google redirects back and the refresh token is stored encrypted on the connection. The token never leaves SchemaBounce infrastructure.

There is no API key to paste. Authorization is native Google OAuth. Make sure the Google account you authorize has access to the property you set in `site_url`.

### Blog drafts connector (Blog Writer)

What you get: Blog Writer creates and submits drafts through a dedicated connector rather than holding credentials itself.

How to connect:

1. In Workspace Settings, go to Service Accounts and create one with the `blog:write` scope.
2. Open the Blog Writer agent, go to Connections, and enter the service account `client_id`, `client_secret`, and `SCHEMABOUNCE_API_URL` in the blog connection step.
3. The runtime injects those credentials into the connector at execution time. Human approval of drafts is never agent-callable, so nothing publishes without a person.

Once both are connected, SEO Expert audits the site weekly, sends topic suggestions to Blog Writer, and Blog Writer turns them into drafts for your review.

---

## Step 3: Add optional data sources

Each connection below adds one signal. Connect the ones your data sources support. The team runs without any of them, on Google Search Console alone.

### PageSpeed Insights (SEO Expert)

What you get: Core Web Vitals (LCP, INP, CLS) and the Lighthouse SEO score for your home page and top URLs. Without it, the auditor skips performance metrics.

Where to get the credential: create a Google API key in a Google Cloud project with the PageSpeed Insights API enabled. In the SEO Expert agent, open Connections, click Connect PageSpeed, and add it as `GOOGLE_API_KEY`.

### Google Analytics (SEO Expert)

What you get: GA4 sessions, engagement, and conversion verification per channel, which supplements the GSC keyword view. Without it, the auditor skips GA4 engagement and conversion metrics.

Where to get the credential: this uses Composio managed OAuth. In SchemaBounce, connect Composio, then link your Google Analytics 4 account inside Composio once via OAuth. The platform supplies the Composio broker key; your GA4 OAuth tokens live in Composio, not as a separate value you paste. Click Connect Google Analytics in the SEO Expert agent.

### DataForSEO (SEO Expert)

What you get: keyword difficulty and volume, SERP gap analysis, backlink context for outreach simulation, and the SERP rank snapshots that drive rank tracking. Without it, opportunity scoring relies on GSC signals alone and rank tracking is skipped.

Where to get the credential: sign up for a paid DataForSEO account. This is metered and customer-supplied. In the SEO Expert agent, open Connections, click Connect DataForSEO, and enter `DATAFORSEO_USERNAME` and `DATAFORSEO_PASSWORD` (HTTP basic auth).

### Bing Webmaster Tools (SEO Expert)

What you get: Bing and Microsoft Copilot search performance, crawl diagnostics, keyword analytics, and indexation health. Bing indexation is the eligibility gate for Copilot answers, so this matters for sites targeting Copilot. Without it, the auditor skips Bing and Copilot signals.

Where to get the credential: go to bing.com/webmasters, then Settings, then API Access, and copy your API key. In the SEO Expert agent, click Connect Bing Webmaster and add it as `BING_WEBMASTER_API_KEY`.

### AI Citation Tracker (SEO Expert)

What you get: brand citation share-of-voice across ChatGPT, Claude, and Perplexity for your `brand_queries`, tracked run over run. Without a key, the server returns shape-complete demo data, so the GEO workflow runs but the numbers are synthetic.

Where to get the credential: get a CitationBench API key from your CitationBench account. In the SEO Expert agent, click Connect Citation Tracker and add it as `CITATIONBENCH_API_KEY`.

### llms.txt Generator (SEO Expert)

What you get: drafts of `llms.txt` and `llms-full.txt` for your site, stored for human review and never auto-published. Without it, the geo-auditor skips the draft step.

Where to get the credential: get an OpenAI API key from platform.openai.com. In the SEO Expert agent, click Connect llms.txt Generator and add it as `OPENAI_API_KEY`.

---

## What each bot can do (post-connection)

| Bot | With required connections | With optional connections |
|-----|---------------------------|---------------------------|
| SEO Expert | Pull GSC keyword and indexation data, audit on-page meta and structured data via the ADL proxy, find almost-ranking queries, file findings, send topic suggestions | Add Core Web Vitals and Lighthouse (PageSpeed), GA4 engagement and conversions (Google Analytics), keyword difficulty and rank snapshots (DataForSEO), Bing and Copilot signals (Bing Webmaster), AI citation share-of-voice (Citation Tracker), and llms.txt drafts (llms.txt Generator) |
| Blog Writer | Read topic suggestions from SEO Expert, write drafts in research, draft, and self-edit phases, submit each for human review through the blog connector | |

## A note on what stays human-gated

The audit, GSC pulls, PageSpeed checks, rank snapshots, and AI citation checks are real and produce real artifacts. Two things never happen without a person: SEO Expert's outreach is dry-run only and is recorded with status `would_send`, and Blog Writer's drafts always go to human review before anything publishes.
