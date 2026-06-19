---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: dataforseo
  displayName: "DataForSEO"
  version: "1.0.0"
  description: "Keyword research, SERP analysis, backlinks, and on-page SEO via the DataForSEO API. Requires a paid DataForSEO account — all API calls are metered."
  tags: ["seo", "keywords", "serp", "backlinks", "onpage", "research", "dataforseo"]
  author: "dataforseo"
  license: "MIT"
# npm package: dataforseo-mcp-server (official DataForSEO package)
# GitHub: https://github.com/dataforseo/mcp-server-typescript
# npm registry: https://www.npmjs.com/package/dataforseo-mcp-server
# Latest version pinned: 2.9.8 (verified 2026-06-11 via npm registry)
#
# AUTH: HTTP Basic — DATAFORSEO_USERNAME (your API login email) and
# DATAFORSEO_PASSWORD (your API password). Both verified from:
#   - https://dataforseo.com/model-context-protocol (official setup docs)
#   - GitHub repo https://github.com/dataforseo/mcp-server-typescript
#
# COST NOTE: DataForSEO is a paid, metered API. Every tool call consumes API
# credits from the customer's own DataForSEO account. Credentials are issued
# at https://app.dataforseo.com/register. This is not a platform-provided
# credential — each workspace supplies its own DataForSEO login.
auth:
  type: "http_basic"
  username_env: "DATAFORSEO_USERNAME"
  password_env: "DATAFORSEO_PASSWORD"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "dataforseo-mcp-server@2.9.8"]
env:
  - name: DATAFORSEO_USERNAME
    description: "DataForSEO account login email. Get credentials at https://app.dataforseo.com/register. All API calls are metered against this account."
    required: true
    sensitive: false
  - name: DATAFORSEO_PASSWORD
    description: "DataForSEO account password. Stored encrypted; used together with DATAFORSEO_USERNAME for HTTP Basic auth to api.dataforseo.com."
    required: true
    sensitive: true

# Tools listed are verified top-level operations from the DataForSEO MCP server's
# SERP, KEYWORDS_DATA, DATAFORSEO_LABS, ONPAGE, and BACKLINKS modules.
# Tool names verified from https://github.com/dataforseo/mcp-server-typescript
# and https://dataforseo.com/model-context-protocol (2026-06-11).
# The full server has 10 modules; ENABLED_MODULES can restrict to a subset.
tools:
  - name: serp_google_organic_live
    description: "Real-time Google organic search results for a keyword: URL, title, description, position, and SERP features."
    category: serp
  - name: serp_google_organic_task_post
    description: "Schedule a Google organic SERP task for batch processing; use when requesting results for many keywords at once."
    category: serp
  - name: keywords_google_ads_search_volume
    description: "Monthly search volume, CPC, and competition level for a list of keywords via Google Ads data."
    category: keywords
  - name: keywords_google_ads_keywords_for_site
    description: "Keyword suggestions derived from a target domain or URL with volume and CPC data."
    category: keywords
  - name: keywords_google_trends_explore
    description: "Google Trends interest-over-time data for one or more keywords with geographic and category filters."
    category: keywords
  - name: labs_google_keyword_ideas
    description: "DataForSEO Labs keyword ideas: search volume, keyword difficulty, traffic potential, and SERP competition."
    category: labs
  - name: labs_google_domain_rank_overview
    description: "Organic traffic estimate, keyword count, authority score, and visibility trends for a domain."
    category: labs
  - name: labs_google_related_keywords
    description: "Semantically related keywords with SERP overlap data and difficulty scores."
    category: labs
  - name: onpage_task_post
    description: "Start an on-page crawl of a URL or domain to collect meta tags, headings, canonicals, schema, and load time."
    category: onpage
  - name: backlinks_summary
    description: "Backlink count, referring domain count, domain rating, and top anchor text distribution for a domain."
    category: backlinks
---

# DataForSEO MCP Server

Provides keyword research, real-time SERP data, backlink analysis, and on-page SEO metrics via the official DataForSEO MCP package.

**Package:** [`dataforseo-mcp-server@2.9.8`](https://github.com/dataforseo/mcp-server-typescript) — official package from DataForSEO.

> **Paid, metered API.** Every tool call consumes credits from your DataForSEO account. Pricing at [dataforseo.com/pricing](https://dataforseo.com/pricing). Register at [app.dataforseo.com/register](https://app.dataforseo.com/register). This is a customer-supplied account — SchemaBounce does not provide DataForSEO credits.

## Modules

The `dataforseo-mcp-server` supports ten modules. Set `ENABLED_MODULES` to a comma-separated subset to reduce exposed tools:

| Module | What it covers |
|---|---|
| `SERP` | Real-time and task-based Google/Bing/Yahoo search results |
| `KEYWORDS_DATA` | Search volume, CPC, trends via Google Ads and Google Trends |
| `DATAFORSEO_LABS` | Proprietary metrics: keyword difficulty, domain authority, related keywords |
| `ONPAGE` | Website crawl and on-page SEO audit |
| `BACKLINKS` | Backlink profile, referring domains, anchor text |
| `DOMAIN_ANALYTICS` | Traffic estimates, technologies, Whois data |
| `CONTENT_ANALYSIS` | Brand mention monitoring and sentiment data |
| `BUSINESS_DATA` | Business review and entity data |
| `AI_OPTIMIZATION` | Keyword data and LLM benchmark data for AEO |
| `MERCHANT` | Product data and competitor pricing |

## Which Bots Use This

- **seo-expert** — keyword research and SERP gap analysis. The auditor uses `labs_google_keyword_ideas` and `keywords_google_ads_search_volume` to validate almost-ranking opportunities from GSC; `backlinks_summary` to surface link-building context; `onpage_task_post` for a structured on-page crawl when `adl_proxy_call` is insufficient.

## Setup

1. Register at [app.dataforseo.com/register](https://app.dataforseo.com/register).
2. After registration, your API login and password appear in the API Access section.
3. Add `DATAFORSEO_USERNAME` (your login email) and `DATAFORSEO_PASSWORD` in the MCP connection setup.
4. Optionally set `ENABLED_MODULES` to a comma-separated list of module names to limit exposed tools.

## BYO-Remote Alternatives

Ahrefs and Semrush offer official hosted remote MCP endpoints that work as customer BYO-remote servers. They require the customer's own paid subscription:

- **Ahrefs MCP** — `https://api.ahrefs.com/mcp/mcp` (streamable-http; requires Ahrefs API token). Add as a custom BYO-remote connection in your workspace.
- **Semrush MCP** — `https://mcp.semrush.com/v1/mcp` (streamable-http; requires Semrush API key). Add as a custom BYO-remote connection in your workspace.

Neither is hosted as a managed manifest here because they are customer-supplied remote endpoints, not subprocess-hosted tools. Use the "Add custom MCP" flow in your workspace settings to configure them.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/dataforseo"
    required: false
    reason: "Keyword volume, SERP data, backlinks, and on-page audit for deeper SEO research"
    config:
      ENABLED_MODULES: "SERP,KEYWORDS_DATA,DATAFORSEO_LABS,ONPAGE,BACKLINKS"
```
