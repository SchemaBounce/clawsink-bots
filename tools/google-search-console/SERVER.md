---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: google-search-console
  displayName: "Google Search Console"
  version: "1.0.0"
  description: "Google Search Console real keyword data, indexation status, sitemap health, and search analytics — reached through the Composio MCP gateway."
  tags: ["google", "seo", "search-console", "gsc", "analytics"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "GOOGLE_SEARCH_CONSOLE"
  setupReason: "Real keyword data, impressions, CTR, position trends. Without this the SEO auditor falls back to internal-only checks and cannot identify almost-ranking opportunities."
# This is a virtual MCP server — agents reach Google Search Console through the
# Composio gateway, not a separate process. The runtime calls
# `composio.execute_composio_tool` with action names that Composio resolves to
# the GSC API. The transport block below documents this for the marketplace UI;
# OpenCLAW does not start a separate process for this server.
transport:
  type: "composio-virtual"
env:
  - name: GOOGLE_SEARCH_CONSOLE_REFRESH_TOKEN
    description: "Managed by Composio after OAuth consent. Not exposed to bots; resolved server-side per tool call."
    required: false
    sensitive: true
tools:
  - name: GOOGLE_SEARCH_CONSOLE_QUERY_SEARCH_ANALYTICS
    description: "Query Search Analytics over a date range. Dimensions: query, page, country, device, searchAppearance. Returns clicks, impressions, CTR, position."
    category: analytics
  - name: GOOGLE_SEARCH_CONSOLE_INSPECT_URL
    description: "Inspect a single URL: indexation status, last crawl, canonical, mobile usability, rich results."
    category: indexation
  - name: GOOGLE_SEARCH_CONSOLE_LIST_SITEMAPS
    description: "List submitted sitemaps and their crawl errors / warnings."
    category: indexation
  - name: GOOGLE_SEARCH_CONSOLE_LIST_SITES
    description: "List GSC verified properties (sites) the credential has access to."
    category: discovery
---

# Google Search Console MCP

Provides Google Search Console (GSC) Search Analytics, URL inspection, and sitemap-health tools through the **Composio managed-OAuth gateway**. SEO bots discover the available actions at runtime via `composio.search_composio_tools({ toolkits: ["GOOGLE_SEARCH_CONSOLE"] })` and execute them via `composio.execute_composio_tool({ action, arguments })`.

This is a **virtual MCP server**: it represents the GSC capability set, but the actual MCP transport is Composio. There is no separate process to start.

## Which Bots Use This

- **seo-expert** — primary consumer. The auditor pulls Search Analytics for the workspace's site over a rolling 28-day window and identifies almost-ranking opportunities (impressions ≥ 100, position 5-20, CTR below median). The recommender turns those into topic suggestions for the blog-writer.

## Connection Flow

1. The user clicks **Deploy** on the SEO Expert bot in the marketplace.
2. The deploy modal shows two MCP dependencies:
   - **Composio** (required) — the workspace must have a Composio API key. If missing, the modal links to Workspace Settings → Connections.
   - **Google Search Console** (optional) — the deploy modal renders a "Connect" button that opens Composio's OAuth popup for the GSC toolkit. On success, the connection is recorded in `mcp_connections` keyed by `tools/google-search-console`.
3. The user approves Google's OAuth consent for the `webmasters.readonly` scope.
4. Composio stores the long-lived refresh token; we never see it directly.
5. The agent activates and the auditor can immediately call GSC tools through Composio.

## Why Composio (not a separate MCP server binary)

- The OAuth dance is non-trivial and adds a credential-management surface. Composio is already in our runtime registry and already handles OAuth for 500+ services. Using it for GSC is one entry in `mcpServerMeta.ts`, zero new Go code, zero new credential storage.
- A future iteration may swap in a dedicated GSC MCP server binary (e.g., a community Node package) once the OAuth handler in core-api supports direct Google OAuth. Until then, Composio is the path.

## Verification

Once deployed, the auditor's first GSC tool call should be:

```
composio.search_composio_tools({
  toolkits: ["GOOGLE_SEARCH_CONSOLE"],
  use_case: "fetch real keyword performance over the last 28 days"
})
```

If Composio returns `TOOLKIT_NOT_CONNECTED`, the user has Composio configured but has not authorized the GSC toolkit. The auditor handles this gracefully by emitting a single `seo_findings` row asking the user to connect.
