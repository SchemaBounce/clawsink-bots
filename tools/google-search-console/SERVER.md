---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: google-search-console
  displayName: "Google Search Console"
  version: "1.0.0"
  description: "Google Search Console real keyword performance, indexation, and sitemap health. Native Google OAuth — no Composio in the data path."
  tags: ["google", "seo", "search-console", "gsc", "analytics"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "native-oauth"
  provider: "google"
  scopes:
    - "https://www.googleapis.com/auth/webmasters.readonly"
    - "openid"
    - "email"
  setupReason: "Real keyword data, impressions, CTR, position trends. Without this the SEO auditor falls back to internal-only checks and cannot identify almost-ranking opportunities."
# Transport: a stdio MCP server we host inside the workspace OpenCLAW pod.
# The npm package below is illustrative — replace with the actual package
# we vendor or publish. The runtime resolves GOOGLE_REFRESH_TOKEN from
# mcp_connections at pod-start and the MCP server uses it to mint short-lived
# access tokens for every Google Search Console API call. No customer data
# leaves the pod except to googleapis.com.
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "google-search-console-mcp@latest"]
  # NOTE: at the time of writing the canonical npm package is still being
  # vetted. Until it is, the SERVER.md is committed as a target spec; the
  # OAuth handler in core-api (mcp_oauth_google_handler.go) lands the
  # refresh token regardless, so when the package is finalised the runtime
  # path lights up with no further frontend / handler changes.
env:
  - name: GOOGLE_REFRESH_TOKEN
    description: "Workspace's Google OAuth refresh token. Issued by core-api after the user completes the consent flow opened from the deploy modal. Stored encrypted in mcp_connections; resolved server-side at pod start."
    required: true
    sensitive: true
  - name: GOOGLE_OAUTH_CLIENT_ID
    description: "Platform-level Google OAuth client ID (same one that issued the refresh token). Sourced from the SchemaBounce-owned Google Cloud project, not per-customer."
    required: true
    sensitive: false
  - name: GOOGLE_OAUTH_CLIENT_SECRET
    description: "Platform-level Google OAuth client secret. Used by the MCP server to mint access tokens from the stored refresh token. Sourced from the SchemaBounce-owned Google Cloud project."
    required: true
    sensitive: true
tools:
  - name: query_search_analytics
    description: "Query Search Analytics over a date range. Dimensions: query, page, country, device, searchAppearance. Returns clicks, impressions, CTR, position."
    category: analytics
  - name: inspect_url
    description: "Inspect a single URL: indexation status, last crawl, canonical, mobile usability, rich results."
    category: indexation
  - name: list_sitemaps
    description: "List submitted sitemaps and their crawl errors / warnings."
    category: indexation
  - name: list_sites
    description: "List GSC verified properties (sites) the credential has access to."
    category: discovery
---

# Google Search Console MCP

A direct GSC MCP server, no third-party gateway. Ships in the workspace OpenCLAW pod as a stdio subprocess; reaches Google Search Console via the official API.

## Auth flow (one-time per workspace)

1. User clicks **Deploy** on the SEO Expert in the marketplace.
2. The deploy modal lists `tools/google-search-console` as an optional MCP dependency and renders a **Connect** button.
3. Clicking Connect calls `POST /api/v1/workspaces/{ws}/mcp/connections/oauth/google/initiate` with this server's scopes.
4. Backend opens a popup pointed at Google's consent screen using SchemaBounce's platform-level OAuth client.
5. User picks their Google account and consents to read-only Search Console access.
6. Google redirects to `GET /api/v1/oauth/google/callback?code=...&state=...`.
7. Backend exchanges the code for a refresh token + access token, stores them encrypted in `mcp_connections` keyed by `tools/google-search-console`, and the popup closes.
8. The deploy modal refetches connections, the gate clears, the user clicks **Deploy**.

The refresh token never leaves our infrastructure. The data path at runtime is **agent → workspace OpenCLAW pod → GSC MCP subprocess → googleapis.com → back**. No Composio, no third-party broker.

## Which Bots Use This

- **seo-expert** — primary consumer. The auditor pulls Search Analytics for the workspace's verified site over a rolling 28-day window and identifies almost-ranking opportunities (impressions ≥ 100, position 5-20, CTR below median).

## Why native (vs Composio)

We previously routed this through Composio's GSC toolkit. That works, but every API call passed through Composio's hosted backend — they saw the request and response payloads, and at scale the per-action billing eats real margin. The native path costs us a one-time Google OAuth handler in core-api (`mcp_oauth_google_handler.go`) and a stdio MCP server vendored in the workspace pod. After that, every Google service we add (GA4, Drive, Sheets, Gmail, Calendar) reuses the exact same OAuth client and handler — only the scopes change in `mcpServerMeta.ts`.

## Platform configuration (one-time per environment)

- Create a Google Cloud project, enable the **Google Search Console API**.
- Create an OAuth 2.0 **Web application** client.
- Authorised redirect URIs: `https://api.schemabounce.com/api/v1/oauth/google/callback` (and `http://localhost:8080/api/v1/oauth/google/callback` for local dev).
- Set core-api env: `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_OAUTH_REDIRECT_BASE`.
- Same client ID + secret serves every Google service the platform supports — one consent screen, many `webmasters.*`, `analytics.*`, `drive.*`, `gmail.*` scopes available depending on which bots a workspace deploys.
