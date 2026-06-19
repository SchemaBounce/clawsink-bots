---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: bing-webmaster
  displayName: "Bing Webmaster Tools"
  version: "1.0.0"
  description: "Bing and Microsoft Copilot search performance, indexation status, crawl diagnostics, URL submission, keyword analytics, and sitemap management via the Bing Webmaster Tools API."
  tags: ["seo", "bing", "copilot", "indexing", "keywords", "webmaster", "search-performance"]
  author: "isiahw1"
  license: "MIT"
# npm package: @isiahw1/mcp-server-bing-webmaster
# GitHub: https://github.com/isiahw1/mcp-server-bing-webmaster
# npm registry: https://www.npmjs.com/package/@isiahw1/mcp-server-bing-webmaster
# Latest version pinned: 1.0.2 (released 2026-02-10; verified 2026-06-11 via npm registry
#   and https://github.com/isiahw1/mcp-server-bing-webmaster README)
#
# AUTH: Bing Webmaster Tools API key.
#   Get your key: https://www.bing.com/webmasters → Settings → API Access.
#   The package reads BING_WEBMASTER_API_KEY from the environment and passes it
#   to the Bing Webmaster API (ssl.bing.com). No additional auth block needed —
#   the subprocess handles key injection internally.
#
# WHY THIS MATTERS: Bing holds ~27% of desktop search share in the US and is
# the backend for Microsoft Copilot. A site visible in Google but blocked in
# Bing misses Copilot AI-answer eligibility entirely. This MCP provides the
# same operational surface for Bing that Google Search Console provides for
# Google: keyword click data, crawl health, and URL submission.
#
# STRATEGY NOTE: For rank tracking (keyword position over time) across both
# Google and Bing, use the `rank-tracking` skill with the DataForSEO MCP,
# which can query both Google and Bing SERP endpoints. This MCP focuses on
# the Bing-specific signals that have no DataForSEO equivalent: crawl errors,
# URL submission quotas, blocked-URL management, and Bing-side keyword CTR.
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@isiahw1/mcp-server-bing-webmaster@1.0.2"]

env:
  - name: BING_WEBMASTER_API_KEY
    description: "Bing Webmaster Tools API key. Get it at bing.com/webmasters → Settings → API Access. Required for all tool calls."
    required: true
    sensitive: true

validation:
  tool:
    name: get_sites

# Tools listed here are verified from the package README and GitHub repo
# (https://github.com/isiahw1/mcp-server-bing-webmaster) as of 2026-06-11.
# The package exposes ~40 tools total; this subset covers the SEO-relevant
# operations the seo-expert bot needs. Remaining tools (geographic settings,
# page preview blocks, deep link management, URL parameters) are available
# but not surfaced to the agent by default.
tools:
  - name: get_sites
    description: "List all sites verified in the Bing Webmaster Tools account."
    category: sites
  - name: add_site
    description: "Add a new site to Bing Webmaster Tools for ownership verification."
    category: sites
  - name: verify_site
    description: "Initiate site ownership verification for a newly added site."
    category: sites
  - name: get_query_stats
    description: "Bing search query performance for the site: impressions, clicks, CTR, and average position over a date range."
    category: traffic
  - name: get_page_stats
    description: "Page-level Bing traffic data: impressions, clicks, and average position for each page."
    category: traffic
  - name: get_rank_and_traffic_stats
    description: "Aggregate site-wide ranking and click data broken down by date, providing trend visibility."
    category: traffic
  - name: get_url_traffic_info
    description: "Traffic details for a specific URL: impressions, clicks, and position history from Bing."
    category: traffic
  - name: get_crawl_stats
    description: "Bing bot crawl activity metrics: pages crawled per day, bandwidth, and crawl frequency."
    category: crawl
  - name: get_crawl_issues
    description: "List URLs with Bing crawl errors (DNS, connection, robots, HTTP) and their recurrence counts."
    category: crawl
  - name: get_crawl_settings
    description: "Retrieve current Bing crawl rate settings for the site."
    category: crawl
  - name: update_crawl_settings
    description: "Adjust Bing bot crawl rate (e.g., reduce to avoid server load; increase to accelerate indexation)."
    category: crawl
  - name: get_url_info
    description: "Bing indexation status for a specific URL: whether it is indexed, the last crawl date, and any index-block reasons."
    category: indexing
  - name: submit_url
    description: "Submit a single URL for immediate Bing indexation. Uses the URL submission quota."
    category: submission
  - name: submit_url_batch
    description: "Submit multiple URLs for Bing indexation in a single batch call. More efficient than individual submit_url calls."
    category: submission
  - name: get_url_submission_quota
    description: "Check remaining daily URL submission quota for the site."
    category: submission
  - name: submit_sitemap
    description: "Submit a sitemap URL to Bing Webmaster Tools for crawling and indexation tracking."
    category: sitemaps
  - name: remove_sitemap
    description: "Remove a previously submitted sitemap from Bing Webmaster Tools."
    category: sitemaps
  - name: get_keyword_data
    description: "Bing keyword click metrics for a specific keyword on the site: clicks, impressions, CTR, and average position."
    category: keywords
  - name: get_related_keywords
    description: "Keyword suggestions and variations based on a seed term, with Bing-side search volume signals."
    category: keywords
  - name: get_keyword_stats
    description: "Historical keyword performance data for a term over time, useful for trend analysis."
    category: keywords
  - name: get_link_counts
    description: "Total inbound link count to the site as seen by Bing, broken down by page."
    category: links
  - name: get_url_links
    description: "Inbound links pointing to a specific URL as indexed by Bing."
    category: links
---

# Bing Webmaster Tools MCP Server

Provides access to Bing and Microsoft Copilot search performance data, crawl health, URL submission, and keyword analytics via the Bing Webmaster Tools API.

**Package:** [`@isiahw1/mcp-server-bing-webmaster@1.0.2`](https://github.com/isiahw1/mcp-server-bing-webmaster) — verified on npm registry 2026-06-11.

> **Why Bing matters for SEO in 2026:** Bing is the backend for Microsoft Copilot, Bing Chat, and Windows 11 integrated search. AI-answer eligibility on Copilot depends on Bing indexation — a site missing from Bing's index cannot appear in Copilot answers regardless of its Google ranking. Bing holds ~27% of US desktop search market share.

## What It Covers

| Surface | Tools |
|---|---|
| Search performance | `get_query_stats`, `get_page_stats`, `get_rank_and_traffic_stats`, `get_url_traffic_info` |
| Crawl health | `get_crawl_stats`, `get_crawl_issues`, `get_crawl_settings` |
| Indexation | `get_url_info`, `submit_url`, `submit_url_batch`, `get_url_submission_quota` |
| Sitemaps | `submit_sitemap`, `remove_sitemap` |
| Keywords | `get_keyword_data`, `get_related_keywords`, `get_keyword_stats` |
| Links | `get_link_counts`, `get_url_links` |

## Which Bots Use This

- **seo-expert** — audits the site's Bing/Copilot search performance alongside Google Search Console data. The auditor uses `get_query_stats` and `get_keyword_data` for Bing-side keyword signals; `get_crawl_issues` and `get_url_info` for Bing indexation health; `submit_url_batch` when new content needs immediate Bing indexation. Files `seo_findings` for pages indexed in Google but blocked in Bing (crawl errors, robots disallow, HTTP 4xx/5xx from Bing's perspective).

## Setup

1. Sign in at [bing.com/webmasters](https://www.bing.com/webmasters) and verify your site.
2. Go to **Settings → API Access** and generate an API key.
3. Add `BING_WEBMASTER_API_KEY` in the MCP connection setup.

## Relationship to DataForSEO and Rank Tracking

For SERP position snapshots over time (rank tracking), use the `rank-tracking` skill with the DataForSEO MCP — DataForSEO can query Bing organic results the same way it queries Google. This MCP focuses on the Bing-native signals that DataForSEO does not expose: crawl error details, Bing-side URL submission, blocked-URL management, and Bing keyword CTR from the verified site's own account.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/bing-webmaster"
    required: false
    reason: "Bing/Copilot search performance, crawl health, and URL submission for sites targeting Bing or Copilot AI answers"
    config: {}
```
