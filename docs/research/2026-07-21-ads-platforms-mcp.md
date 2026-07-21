# Paid-ads platforms: Google Ads, Meta Ads, LinkedIn Ads MCP access

Date: 2026-07-21
Status: research, no catalog entries authored
Author: investigation for the MCP catalog program

## Summary

None of the three platforms cleared the bar this catalog requires for an
`oauth2_mcp` (dynamic client registration) entry. One does not have an
official hosted MCP endpoint at all (Google Ads). One has an official hosted
endpoint but its advertised dynamic client registration rejects every caller
that Meta has not pre-approved, confirmed by a live probe against the real
endpoint (Meta Ads). One has no single official hosted endpoint and the
underlying API tier is partner-application-gated (LinkedIn Ads). All three are
documented below with the concrete registration path and an effort estimate.
No `tools/<name>/SERVER.md` was authored for any of them.

| Platform    | Official hosted MCP endpoint | Live DCR test           | Verdict                                    |
| ----------- | ----------------------------- | ------------------------ | ------------------------------------------- |
| Google Ads  | No (self-hosted only)         | N/A                      | Document only                               |
| Meta Ads    | Yes, `mcp.facebook.com/ads`   | **Fails**, 400           | Document only; pinned-client path exists    |
| LinkedIn Ads| No                             | N/A                      | Document only                               |

## Google Ads

**No Google-hosted remote endpoint exists.** Google shipped an official,
open-source Google Ads MCP server (`github.com/googleads/google-ads-mcp`,
maintained by the Google Ads API team) on 2026-04-28, but it is
**self-hosted only**; there is no `mcp.google.com`-style URL to point a
`streamable-http` transport at. A customer or SchemaBounce would have to run
the server itself (`pipx run --spec
git+https://github.com/googleads/google-ads-mcp.git google-ads-mcp`, or the
PyPI-style stdio invocation), which is the same shape as the `github` stdio
packageType this catalog already supports for other vendors.

**Scope of the official server is narrow.** It is strictly read-only: three
tools (`list_accessible_customers`, a GAQL `search` tool for reporting, and
`get_resource_metadata`). No campaign creation, no bid changes, no pausing.
Anything mutating stays on the raw Google Ads API, outside MCP.

**Auth is not a simple API key.** Google Ads API access requires:

1. A Google Ads **developer token**, applied for at
   `https://ads.google.com/aw/apicenter` against a Google Ads manager account.
   New tokens start at **Explorer** access (often auto-approved but capped and
   test-account-only). Production traffic needs **Basic access**, a manual
   Google review that the search results describe as taking days to weeks,
   longer during high-demand periods (Google's own forum flagged slower
   approvals in Feb 2026).
2. A standard Google OAuth client with the `https://www.googleapis.com/auth/adwords`
   scope. This platform already runs a native Google OAuth handler
   (`mcp_oauth_google_handler.go`) reused across `google-search-console`,
   `google-analytics`, `google-drive`, etc. (see `tools/google-search-console/SERVER.md`
   for the pattern); adding the `adwords` scope to that same client is
   mechanically cheap. The developer token is the actual gate, and it is
   **workspace-specific**: each SchemaBounce customer's own Google Ads manager
   account would need its own token, not something SchemaBounce can obtain
   once for all customers the way the platform-level Google OAuth client works
   today. That breaks the "one connect button" model every other native-Google
   entry uses.

**Recommended path if pursued:** host the server as a `github` packageType
stdio recipe (checksum-pinned release, same hosting shape as `github-remote`'s
sibling stdio entries), reuse the existing native-Google-OAuth client for the
`adwords` scope, and require each customer to paste their own Google Ads
developer token as a `required: true` env var (it cannot be a platform-level
secret the way `GOOGLE_OAUTH_CLIENT_ID` is, because the token is tied to the
customer's own Ads manager account and Basic-access approval).

**Effort estimate:** Medium engineering (stdio github-source hosting + one new
OAuth scope on an existing client, roughly a day), but the token approval is
**per-customer and outside our control** (days to weeks, sometimes rejected).
Given the server is read-only with three tools, the value bar for a customer
to go get their own developer token is worth restating clearly in the catalog
description before committing engineering time.

## Meta Ads

**An official hosted endpoint exists: `https://mcp.facebook.com/ads`.**
Meta shipped it 2026-04-29 as "Meta Ads AI Connectors," authenticated through
Meta Business OAuth. It advertises 29 tools (reporting, campaign management,
catalog management, signal diagnostics).

### Probe results

```
meta-ads|OK|https://mcp.facebook.com/ads|dcr=yes|scopes=ads_management ads_read catalog_management business_management pages_show_list instagram_basic
```

The 401 challenge, protected-resource metadata, and authorization-server
metadata all resolve cleanly:

- AS issuer: `https://www.facebook.com`
- `authorization_endpoint`: `https://www.facebook.com/v25.0/dialog/oauth`
- `token_endpoint`: `https://graph.facebook.com/v25.0/oauth/access_token`
- `registration_endpoint`: `https://mcp.facebook.com/.well-known/register/ads`
- `token_endpoint_auth_methods_supported`: `["none"]` (public client only)

On metadata alone this reads as `dcr=yes` and would qualify for an
`oauth2_mcp` entry per the catalog's normal bar.

### It does not actually work; verified live

The probe script only checks whether `registration_endpoint` is present in
the metadata; it does not attempt a real registration. A real RFC 7591 POST
to that endpoint, using the exact request shape core-api's `RegisterClient`
sends (public client, our production redirect URI
`https://api.schemabounce.com/api/v1/oauth/mcp/callback`, the AS's advertised
scopes), was rejected:

```
$ curl -X POST https://mcp.facebook.com/.well-known/register/ads \
    -d '{"redirect_uris":["https://api.schemabounce.com/api/v1/oauth/mcp/callback"], ...}'

{"error":"invalid_client_metadata","error_description":"Dynamic registration is not available for this client."}
HTTP 400
```

This matches public reports from other MCP clients hitting the same wall:
`anthropics/claude-code#55002`, `#58054`, `#57191`, and `openai/codex#24103`
all describe the identical failure; Meta advertises a `registration_endpoint`
per RFC 8414 but the endpoint rejects unrecognized callers with
`invalid_client_metadata` / "redirect_uris are not registered for this
client." Meta appears to allow-list specific partner redirect URIs
(ChatGPT, Claude.ai) rather than accepting open dynamic registration, despite
the metadata implying otherwise.

**Per this catalog's bar ("An OK+dcr=yes result is required before authoring
an oauth2_mcp (DCR) entry"), Meta Ads does not qualify**; the metadata claims
DCR support, the live registration call proves it is not actually available
to us. No `tools/meta-ads/SERVER.md` was authored.

### The pinned-client path is unusually well-positioned here

Unlike a cold-start pinned-client integration, this platform already has most
of the pieces in place:

1. **A Facebook/Meta OAuth app already exists**: `FACEBOOK_CLIENT_ID` /
   `FACEBOOK_CLIENT_SECRET`, shared between the ETL `facebook-ads` connector
   (`internal/connectors/definitions/facebook-ads.json`) and a **native Facebook
   OAuth handler already built for this exact purpose**
   (`mcp_oauth_facebook_handler.go`). Its own header comment says: *"facebook-ads
   stays native (Meta Marketing API, which shares the OAuth app with ETL
   ingestion)."* The scopes it already validates
   (`ads_read`, `ads_management`, `business_management`, plus
   `pages_show_list` / `instagram_basic`) are exactly the scope set
   `mcp.facebook.com/ads` advertises.
2. **The scopes are not a cold App Review ask.** The ETL `facebook-ads`
   connector already ships as a `"stable"` status connector requesting
   `ads_read` / `ads_management` / `business_management` against the same
   Meta App. Whatever App Review tier that app already cleared for ETL
   ingestion very likely already covers the MCP use case's scope needs; this
   should be confirmed with Meta's App Dashboard directly, not assumed, but it
   is a materially smaller ask than starting from zero.
3. **The generic pinned oauth2_mcp path already exists in code**
   (`McpOAuthCatalogPin` with `client_id_env` / `client_secret_env` /
   `authorization_endpoint` / `token_endpoint`, exactly the shape
   `tools/github-remote/SERVER.md` uses today). A `meta-ads` entry would be a
   near-copy of `github-remote`'s `auth:` block, pointed at Meta's endpoints
   instead of GitHub's.

**What is NOT yet confirmed, and blocks shipping this today:**

- **Feature flag.** The generic pinned-client OAuth flow is currently gated
  behind `MCP_OAUTH_CLIENT_ENABLED`, which is off (per the MCP OAuth client
  program status). It needs to be on before this path is reachable at all.
- **Redirect URI registration.** The Meta App's "Valid OAuth Redirect URIs"
  list would need `https://api.schemabounce.com/api/v1/oauth/mcp/callback`
  added. It is not the same URI the native `facebook-ads` handler uses
  (`/api/v1/oauth/facebook/callback`), so this is an additive Meta App
  Dashboard change, not a reuse of an existing registration.
- **Token audience binding, unverified.** MCP's OAuth profile (RFC 8707
  resource indicators) expects an access token to be bound to the specific
  resource (`mcp.facebook.com/ads`). Standard Facebook Graph OAuth, which is
  what a pinned-client flow through `www.facebook.com/v25.0/dialog/oauth`
  produces, has no resource-indicator concept. Whether Meta's ads MCP endpoint
  will accept a token minted this way (versus one minted through its own,
  currently allow-list-only, registration flow) is **unverified** and can only
  be confirmed by completing a real OAuth round trip against a Meta Business
  account with ads access. This is the single open risk that determines
  whether the pinned-client path is viable at all, or whether Meta's ads MCP
  is fully closed to non-partner integrators regardless of pinning.

**Effort estimate:** Low-to-Medium if the token-audience risk resolves
favorably (flip the feature flag, register one redirect URI, write a
`github-remote`-shaped `SERVER.md`, confirm the existing scopes clear App
Review). Not viable at all if Meta's endpoint hard-rejects non-partner-minted
tokens regardless of scope; that can only be known by testing with real
credentials, which this research pass did not have.

## LinkedIn Ads

**No single official hosted MCP endpoint was found.** Search results turned
up community and third-party servers (a "LinkedIn Campaign Manager MCP
Server" on PulseMCP, various self-hosted GitHub repos using LinkedIn's
official Community Management / Marketing APIs), but no `mcp.linkedin.com`
or equivalent LinkedIn-hosted, LinkedIn-maintained endpoint akin to Meta's
`mcp.facebook.com/ads` or Plain's `mcp.plain.com`. Nothing was probed with
the DCR script because there is no candidate URL to probe.

### The API tier itself is the real gate, not MCP

LinkedIn's developer platform splits access into five tiers. The tier ads
tooling needs; the **Marketing Developer Platform** (campaign, analytics,
ad-account APIs); is **partner-application-gated**: a manual LinkedIn review
that public write-ups put at "4 weeks best case, 4 months average," with
rejections common and reasons rarely disclosed. This is a LinkedIn-side,
per-applicant gate; it exists independent of whether the integration is MCP,
REST, or anything else.

### The realistic near-term path is the existing Composio pattern

This catalog already has a `tools/linkedin/SERVER.md` entry (Composio
`LINKEDIN` toolkit, member/company posting + page analytics, 22 tools) and
sibling `facebook-pages` / `instagram` entries on the identical pattern.
Composio separately lists a dedicated **`linkedin_ads`** toolkit
(`composio.dev/toolkits/linkedin_ads`) covering campaign, creative, and
analytics actions against LinkedIn's Marketing API. Composio's own
documentation is explicit that this toolkit **requires the customer to
configure their own OAuth credentials**; Composio does not grant blanket
Marketing Developer Platform access on a customer's behalf the way it does
for, say, Facebook Pages. That means the LinkedIn-side partner approval above
is not something Composio, or SchemaBounce, can shortcut; it is the
customer's own LinkedIn Marketing Developer Platform application.

**Recommended path if pursued:** author `tools/linkedin-ads/SERVER.md`
mirroring `tools/linkedin/SERVER.md`'s Composio pattern (`composioToolkit:
"LINKEDIN_ADS"`), with the setup docs stating plainly that the customer must
already hold LinkedIn Marketing Developer Platform access and bring their own
OAuth client into Composio before the connection will work. This is
`SERVER.md`-authoring work only (low effort, an afternoon), but it should not
ship framed as "click Connect and go" the way `facebook-pages` is; the
gate is real and outside anyone's control but LinkedIn's.

**Effort estimate:** Low engineering effort to write the entry once someone
decides it is worth shipping a connector whose real precondition is a
LinkedIn-side approval measured in months. The bottleneck is 100% LinkedIn's
review queue, not anything buildable here.

## How this relates to the existing facebook-pages / instagram entries

`tools/facebook-pages/SERVER.md` and `tools/instagram/SERVER.md` are **not**
on the native Facebook OAuth path; they are explicitly routed through
Composio's managed OAuth (`auth.method: "composio"`), and
`mcp_oauth_facebook_handler.go` enforces this at the API layer: it hard-rejects
`tools/facebook-pages` and `tools/instagram` from the native-OAuth initiate
endpoint and tells the caller to use Composio instead
(`composioManagedFacebookServers` allowlist).

The **native** Facebook OAuth handler exists for exactly one designed purpose
today: a future `tools/facebook-ads` entry using the platform's own
`FACEBOOK_CLIENT_ID` / `FACEBOOK_CLIENT_SECRET` (the same app ETL's
`facebook-ads` connector uses), producing a long-lived Graph API token stored
per-connection. That native flow authenticates against the *Marketing Graph
API* directly (no MCP server in the loop) and is a separate, already-buildable
feature from the `mcp.facebook.com/ads` hosted-MCP integration this doc
evaluated. The hosted-MCP integration (this doc's "pinned-client path" above)
would reuse the *same* Meta App and scopes as that native handler, but talks
to Meta's own MCP server over `streamable-http` instead of calling the Graph
API directly from a stdio recipe. Both are legitimate, non-competing ways to
get Facebook/Meta Ads data into an agent; which one to build depends on
whether Meta's hosted MCP endpoint turns out to accept pinned-client tokens
(open question above) versus building a straightforward native Graph API
stdio server, which has no such open question because it is entirely within
SchemaBounce's own infrastructure.

## Sources

- [GitHub - googleads/google-ads-mcp](https://github.com/googleads/google-ads-mcp)
- [Google Ads MCP server: Developer integration guide](https://developers.google.com/google-ads/api/docs/developer-toolkit/mcp-server)
- [Developer Token | Google Ads API](https://developers.google.com/google-ads/api/docs/api-policy/developer-token)
- [Access Levels and Permissible Use | Google Ads API](https://developers.google.com/google-ads/api/docs/api-policy/access-levels)
- [High Demand Slows Google Ads API Access Approvals](https://ppcnewsfeed.com/ppc-news/2026-02/high-demand-slows-google-ads-api-access-approvals/)
- [GitHub - pipeboard-co/meta-ads-mcp](https://github.com/pipeboard-co/meta-ads-mcp)
- [mcp.facebook.com/ads: Set Up the Official Meta MCP (2026)](https://adadvisor.ai/blog/mcp-facebook-com-ads-official-meta-setup)
- [Meta Ads MCP: Meta's Official Server, 29 Tools](https://www.usecarly.com/blog/meta-ads-mcp/)
- [Official Meta Ads MCP fails OAuth login with invalid_client_metadata · openai/codex#24103](https://github.com/openai/codex/issues/24103)
- [[BUG] Official Meta Ads MCP (mcp.facebook.com/ads) fails OAuth with "redirect_uris are not registered for this client" · anthropics/claude-code#55002](https://github.com/anthropics/claude-code/issues/55002)
- [MCP HTTP OAuth fails with Meta MCP (mcp.facebook.com/ads): redirect_uris not registered · anthropics/claude-code#58054](https://github.com/anthropics/claude-code/issues/58054)
- [Meta Ads MCP at mcp.facebook.com/ads rejects Claude Code CLI OAuth · anthropics/claude-code#57191](https://github.com/anthropics/claude-code/issues/57191)
- [LinkedIn Campaign Manager MCP Server by ZLeventer | PulseMCP](https://www.pulsemcp.com/servers/zleventer-linkedin-campaign-manager)
- [LinkedIn MCP Servers: Pages, Posts, Ads, and Sales Navigator with AI | MCPBundles Docs](https://www.mcpbundles.com/blog/linkedin-mcp-server)
- [LinkedIn API Access in 2026: Tiers, Approval & Alternatives](https://www.getphyllo.com/post/linkedin-api-access-in-2026-partner-program-approval-timeline-alternatives)
- [LinkedIn API Approval Process: What It Takes to Get Access (2026 Guide)](https://socialmeai.com/blog/linkedin-api-approval-process)
- [Advertising API Application Review and Developer Support | LinkedIn Help](https://www.linkedin.com/help/linkedin/answer/a527289)
- [Linkedin Ads MCP Integration for AI Agents | Composio](https://composio.dev/toolkits/linkedin_ads)
- [Metaads MCP Integration for AI Agents | Composio](https://composio.dev/toolkits/metaads)
- [Google Ads MCP Integration for AI Agents | Composio](https://composio.dev/toolkits/googleads)
