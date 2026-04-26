---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: google-search-console
  displayName: "Google Search Console"
  version: "1.0.0"
  description: "Google Search Console real keyword data, indexation status, sitemap health, and search analytics"
  tags: ["google", "seo", "search-console", "gsc", "analytics"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "google-search-console-mcp@latest"]
auth:
  method: "oauth2"
  redirectUri: "https://{tenant}/api/v1/oauth/google/callback"
  scope: "https://www.googleapis.com/auth/webmasters.readonly"
  setupReason: "Real keyword data, impressions, CTR, position trends. Without this the SEO auditor falls back to internal-only checks and cannot identify almost-ranking opportunities."
env:
  - name: GOOGLE_CLIENT_ID
    description: "Google OAuth client ID"
    required: true
    sensitive: true
  - name: GOOGLE_CLIENT_SECRET
    description: "Google OAuth client secret"
    required: true
    sensitive: true
  - name: GOOGLE_REDIRECT_URI
    description: "Google OAuth redirect URI for the workspace tenant"
    required: true
  - name: GOOGLE_REFRESH_TOKEN
    description: "Long-lived refresh token issued after first OAuth consent (stored encrypted)"
    required: true
    sensitive: true
tools:
  - name: gsc_list_sites
    description: "List GSC verified properties (sites) the credential has access to"
    category: discovery
  - name: gsc_search_analytics_query
    description: "Query Search Analytics over a date range. Dimensions: query, page, country, device, searchAppearance. Returns clicks, impressions, CTR, position."
    category: analytics
  - name: gsc_url_inspect
    description: "Inspect a single URL: indexation status, last crawl, canonical, mobile usability, rich results"
    category: indexation
  - name: gsc_sitemap_list
    description: "List submitted sitemaps and their crawl errors / warnings"
    category: indexation
---

# Google Search Console MCP Server

Provides Google Search Console (GSC) Search Console API access for SEO bots that need real keyword data, indexation status, and crawl health.

## Which Bots Use This

- **seo-expert** — primary consumer. The auditor pulls Search Analytics for the workspace's site over a rolling 28-day window and identifies "almost-ranking" opportunities (impressions ≥ 100, position 5-20, CTR below median). The recommender turns those into topic suggestions for the blog-writer.

## Setup

1. Create a Google Cloud project and enable the **Google Search Console API**.
2. Create OAuth 2.0 credentials (client ID and secret) with the `webmasters.readonly` scope.
3. Add `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and `GOOGLE_REDIRECT_URI` to your workspace's MCP connections (Workspace Settings → Connections → Google Search Console).
4. Complete the OAuth consent flow once. The refresh token is stored encrypted in `mcp_connections` and used to mint short-lived access tokens for every tool call.
5. The server starts automatically when a bot that references it runs. The first `gsc_list_sites` call confirms connectivity.

## What This Replaces

Before this server was wired, the SEO Expert could only audit our own sitemap and our own published-blog-list endpoint. It had **zero visibility into actual search traffic** — no keyword data, no CTR, no impressions, no position. It was structurally incapable of moving the SEO needle. This server is the first concrete step in closing that gap. See `docs/AGENT_MCP_TOOLING_HANDOFF.md` for the broader audit.

## Local-Test Note

While the actual public/community MCP server image is being finalized, the SEO Expert calls four built-in OpenCLAW tools (`adl_seo_fetch_gsc_keywords`, `adl_seo_pagespeed_audit`, `adl_seo_meta_audit`, `adl_seo_geo_visibility_check`) that resolve credentials from the same `mcp_connections` row this server uses. The MCP transport is the long-term path; the built-ins are the immediate path so the agent ships value today.

## Team Usage

Add to your TEAM.md to share a single GSC server instance across bots:

```yaml
mcpServers:
  - ref: "tools/google-search-console"
    required: false
    reason: "Real search performance data for SEO + content teams"
    config:
      default_site_url: "https://your-domain.com/"
```
