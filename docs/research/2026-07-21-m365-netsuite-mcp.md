# Enterprise gap research: Microsoft 365 and NetSuite MCP access

Date: 2026-07-21
Status: research, no SERVER.md entries authored (neither vendor clears the bar — see verdicts below)
Related: `docs/research/2026-07-21-per-tenant-mcp-pattern.md` (the per-tenant URL-template
gap this doc's build plans depend on)

## Verdict up front

| Vendor | Official hosted MCP endpoint exists? | Covers the target data (mail/calendar/SharePoint/OneDrive, or AR/invoices)? | SERVER.md authored today? |
| --- | --- | --- | --- |
| Microsoft 365 / Graph | Yes, two of them | One does (Agent 365 Work IQ), one doesn't (Enterprise Graph MCP is identity-only) | No |
| NetSuite | Yes | Yes (AR, invoices, customers, saved searches, SuiteQL via the standard tools SuiteApp) | No |

Neither gets a catalog entry in this pass. Both fail the same architectural
precondition: their MCP URL is **per-tenant/per-account**
(`https://agent365.svc.cloud.microsoft/agents/tenants/{tenantId}/servers/...`,
`https://<accountid>.suitetalk.api.netsuite.com/services/mcp/v1/...`), and
today's `oauth2_mcp` catalog resolver copies `entry.URLTemplate` verbatim into
the launch URL with zero substitution
(`config_publisher.go` `resolveCatalogToolDefaults()` — confirmed by reading
the code, see the linked per-tenant-MCP-pattern doc, Part 1). A single fixed
`transport.url` cannot represent "one server, unique host per customer." That
gap has to close first (Part 2 of the linked doc: one `url_placeholders` JSONB
column + a setup-modal input + reuse of the already-tested `{TOKEN}`
substitution helper) before either vendor can become a first-class catalog
tile. Both CAN be reached today via the existing custom/BYO Remote URL flow
(`mcp-byo.md`) — see the build plans below for what that requires per vendor.

---

## Part 1 — Microsoft 365 / Microsoft Graph

Microsoft ships **two separate official hosted MCP surfaces**, both remote
(`streamable-http`), neither of which is a stdio server you'd run yourself.
They are not interchangeable — this is the detail that matters for the task's
question ("Outlook mail, calendar, SharePoint/OneDrive").

### 1.1 Microsoft MCP Server for Enterprise — identity only, NOT mail/calendar/SharePoint

- Endpoint: `https://mcp.svc.cloud.microsoft/enterprise` (single global URL,
  no per-tenant path — this one WOULD fit our catalog format as-is).
- **Live-probed 2026-07-21** with the project's probe script:
  `microsoft-enterprise-graph|OK|https://login.microsoftonline.com/organizations/v2.0|dcr=NO|scopes=openid profile email offline_access`.
  Confirms: real 401 challenge, real RFC 8414 AS metadata, **no RFC 7591 DCR**
  (`login.microsoftonline.com` never advertises a `registration_endpoint`).
  A pinned-client entry (the `github-remote` pattern) is the only viable
  `oauth2_mcp` shape here, not a DCR entry.
- Scope: **Microsoft Entra identity and directory data only** — users, groups,
  applications, devices, audit logs, conditional access policies,
  administrative reporting. Read-only. Three tools:
  `microsoft_graph_suggest_queries`, `microsoft_graph_get`,
  `microsoft_graph_list_properties`. **Zero mail, calendar, SharePoint, or
  OneDrive coverage** — this surface answers "how many users do we have" and
  "is MFA enabled for all admins," not "summarize my inbox."
  ([Overview](https://learn.microsoft.com/en-us/graph/mcp-server/overview))
- Status: **public preview** (doc dated 2025-11-18, still preview as of the
  2026-07-04 content refresh). Delegated permissions only, no app-only/service
  auth. 100 calls/min/user rate limit. No extra license required beyond
  whatever Graph data license the caller already needs (e.g. Entra ID P2 for
  PIM content).
- Setup: tenant admin runs a one-time PowerShell provisioning
  (`Grant-EntraBetaMCPServerPermission -ApplicationName VisualStudioCode`),
  then a **custom MCP client** registers its own Entra app (Application
  Administrator or Cloud Application Administrator role), adds delegated
  scopes named `MCP.{GraphScope}` (e.g. `MCP.User.Read.All`), and gets admin
  consent. ([Get started](https://learn.microsoft.com/en-us/graph/mcp-server/get-started))

**Why this doesn't answer the task's question**: it's the wrong server. It's
useful for an "IT ops / directory insights" agent, not an inbox/calendar/file
agent. Do not build toward this one for the executive-assistant / customer-
support / hr-assistant use cases already listed in
`tools/microsoft-teams/SERVER.md`.

### 1.2 Agent 365 Work IQ MCP servers — THIS is the mail/calendar/SharePoint/OneDrive surface

- Catalog of first-party remote MCP servers under **Microsoft Agent 365**
  (separate product from the Enterprise Graph MCP above):
  Work IQ Mail (`mcp_MailTools`), Work IQ Calendar (`mcp_CalendarTools`), Work
  IQ SharePoint, Work IQ OneDrive (`mcp_OneDriveRemoteServer`), Work IQ Teams,
  Work IQ User, Work IQ Word, plus Dataverse/Dynamics 365 and a
  "Microsoft MCP Management Server" for building custom tenant tools.
  ([Work IQ MCP overview](https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview))
- **Endpoint is per-tenant**, confirmed from Microsoft's own worked example
  (Claude Code / GitHub Copilot CLI / VS Code setup samples all use the same
  shape):
  `https://agent365.svc.cloud.microsoft/agents/tenants/{tenantId}/servers/mcp_MailTools`
  — swap `mcp_MailTools` for `mcp_CalendarTools`, `mcp_OneDriveRemoteServer`,
  etc. This is the exact "per-tenant path segment" case the sibling research
  doc's `url_placeholders` proposal targets.
  ([OneDrive reference](https://learn.microsoft.com/en-us/microsoft-copilot-studio/mcp-onedrive-work-iq))
- OneDrive server specifics (representative of the family's shape/limits):
  17 tools (get drive info, list/find/read/create/rename/delete/copy/move
  files and folders, share, set sensitivity label), every file operation
  capped at **5 MB**, folder listing capped at 20 items per call. This is a
  narrow, governance-first tool surface, not a general Graph passthrough.
- **Auth is a hard architecture mismatch with our current pinned-client
  pattern, not just a per-tenant URL problem**:
  - Public-client OAuth, redirect URIs restricted to native-app patterns:
    `http://localhost:8080/callback`, `http://127.0.0.1`,
    `https://localhost`, `ms-appx-web://Microsoft.AAD.BrokerPlugin/{client-id}`,
    `http://vscode.dev/redirect`. Our platform's redirect is a fixed HTTPS
    server callback (`redirectURI()` in
    `mcp_oauth_mcp_handler.go` returns `<MCP_OAUTH_REDIRECT_BASE>/api/v1/oauth/mcp/callback`
    — production value should resolve to
    `https://api.schemabounce.com/api/v1/oauth/mcp/callback`, confirm the
    actual `MCP_OAUTH_REDIRECT_BASE` ArgoCD parameter before building). None
    of Microsoft's four documented redirect patterns is an arbitrary HTTPS
    URL a platform can register — this needs live testing against a trial
    tenant to find out whether Entra will accept our HTTPS callback on a
    "Web" platform registration (plausible, undocumented) or whether the
    Work IQ permission model strictly requires the public-client/native flow
    shown in every Microsoft example.
  - **Per-tenant admin app registration is mandatory** — there's no
    multi-tenant "consent once, connect everywhere" app Microsoft ships for
    third parties the way GitHub's App model works (`github-remote`'s
    pinned-client precedent). Every customer tenant's admin has to register
    an Entra app, add the `WorkIQ-{Server}` permission, consent, and hand us
    a client ID. That's a **pinned-client-per-customer-workspace** model, not
    a **pinned-client-per-platform** model — architecturally closer to "every
    customer brings their own OAuth app" than to `github-remote`.
    ([Custom client app registration](https://learn.microsoft.com/en-us/microsoft-agent-365/developer/custom-client-app-registration))
  - **Requires a Microsoft 365 Copilot license** — a $30/user/month add-on on
    top of M365 licensing. This alone rules out most SMB/mid-market
    customers who don't already have Copilot seats; it's an enterprise-tier
    gate, not a universal M365 tenant capability.
    ([Work IQ overview, "Important" box](https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview))
  - **Preview status with an explicit no-stability promise**: "Microsoft
    might change preview MCP tool names and parameters. Avoid hard-coded
    dependencies." Building a pinned tool-name integration against this today
    risks silent breakage on a Microsoft-side rename.
  - A parallel **"BYO MCP" registration flow** exists for customers who want
    to register their OWN remote MCP server (not ours) into their Agent 365
    tooling gateway — irrelevant to us as a vendor, but confirms the platform
    is admin-gated end to end: "developers register a remote MCP server via
    the Agent 365 CLI... IT admin reviews... approves or rejects."

### 1.3 Build plan for Microsoft 365 (mail/calendar/SharePoint/OneDrive)

Given the license gate + per-tenant admin app registration + native-redirect
constraint + preview instability, **do not build a catalog `oauth2_mcp` entry
against Agent 365 Work IQ now.** Recommended path, in order:

1. **(0.5 day, no build)** Update `tools/microsoft-teams/SERVER.md`'s
   Composio-backed entry description to note it does NOT cover Outlook
   mail/calendar/SharePoint/OneDrive (it's Teams-only), so nobody assumes
   Composio's `MICROSOFT_TEAMS` toolkit is a stand-in for the broader M365
   surface. Quick doc-accuracy fix, zero risk.
2. **(1-2 days) Check Composio/other managed-OAuth aggregators first** — the
   existing `microsoft-teams` entry already proves the platform has a
   Composio-backed path for Microsoft services that sidesteps the per-tenant
   Entra app registration problem entirely (Composio holds the OAuth app,
   customers connect through Composio's managed flow, same as every other
   `auth.method: composio` entry in the catalog). Check whether Composio (or
   another integration aggregator already wired into the platform) offers
   `OUTLOOK`, `MICROSOFT_ONEDRIVE`, `SHAREPOINT`, or `MICROSOFT_OUTLOOK`
   toolkits. If yes, this is the fastest real path to "M365 mail/calendar in
   the catalog" — no per-tenant Entra work, no license-gate exposure beyond
   what the customer's own M365 plan requires, follows the exact pattern
   already shipped for Teams. **This should be the first thing tried before
   any direct-Graph build.**
3. **(3-5 days, gated on #2 coming back negative) Direct Graph app, scoped to
   what doesn't need Work IQ / Copilot licensing** — Microsoft Graph itself
   (not Agent 365) supports plain delegated-permission OAuth against
   `Mail.Read`, `Calendars.ReadWrite`, `Sites.Read.All`, `Files.ReadWrite`
   scopes with NO Copilot license requirement, using a standard multi-tenant
   Entra app SchemaBounce registers once (same shape as the existing
   `github-remote` GitHub App pin — pre-registered client, no DCR, since
   Microsoft identity platform has never supported RFC 7591). This is NOT
   the Work IQ/Agent 365 product; it's the same mechanism community servers
   like `Softeria/ms-365-mcp-server` and `MartinM85/mcp-server-graph-api`
   already use. Two implementation choices:
   - **(a) First-party stdio bridge** (like the `microsoft-teams` npm
     package pattern, but running an in-gateway Graph MCP binary/npm package
     instead of Composio) — SchemaBounce registers one multi-tenant Entra
     app, ships `client_id`/`client_secret` as platform env vars, each
     workspace does an OAuth consent that grants access to their own
     mailbox/calendar/SharePoint under our app's identity. This is a genuine
     build: pick or fork a maintained Graph MCP stdio server (`Softeria/ms-
     365-mcp-server` is the most starred community option, MIT-licensed,
     confirm license terms before vendoring), wire it into the gateway's
     npm-hostable path (`mcp-registry-npm-hostable` pattern already used
     elsewhere), write the SERVER.md with `auth.type: oauth2_mcp` and a
     pinned client the same shape as `github-remote`.
   - **(b) Wait for a remote-hosted equivalent** — Microsoft may eventually
     un-gate Work IQ from the Copilot license or ship a general-availability
     Graph MCP without the Agent 365 wrapper; re-check
     `learn.microsoft.com/en-us/graph/mcp-server/overview` quarterly (it is
     actively being extended — the Enterprise identity server itself
     shipped as recently as 2025-11).
   Effort: 3-5 engineering days for (a) once #2 is ruled out (mostly the npm-
   hostable stdio integration + multi-tenant Entra app registration +
   SERVER.md authoring + validation probe), assuming the vendored server's
   OAuth flow is compatible with our gateway's credential injection model.
4. **Do not attempt Work IQ integration until** Microsoft either (i) drops
   the Copilot license requirement, or (ii) the per-tenant `url_placeholders`
   gap (linked doc) ships AND we've live-tested whether Entra accepts a
   platform HTTPS redirect URI on a Web-platform app registration (untested
   here — no live tenant available in this research pass).

---

## Part 2 — NetSuite

### 2.1 What exists: NetSuite AI Connector Service (Oracle-shipped, GA, per-account)

- **Real, Oracle-official, remote MCP endpoint** — not a community project.
  URL pattern (confirmed from `docs.oracle.com` NetSuite Applications Suite
  help center, "Connect to the NetSuite AI Connector Service"):
  ```
  https://<accountid>.suitetalk.api.netsuite.com/services/mcp/v1/suiteapp/com.netsuite.mcpstandardtools
  ```
  (`<accountid>` is the customer's NetSuite account ID, e.g. `TD12345678` —
  another per-account URL, the same architectural shape as Agent 365's
  per-tenant path.) A second path,
  `.../services/mcp/v1/all`, additionally exposes the customer's own
  SuiteScript-authored custom tools.
  ([Get started with the NetSuite AI Connector Service](https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/article_3200541651.html),
  [Connect to the NetSuite AI Connector Service](https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/section_0714082142.html))
- **Standard OAuth 2.0 Authorization Code + PKCE**, "AI clients must support
  OAuth 2.0 Authorization Code Grant flow with Proof Key for Code Exchange."
  On first connection from a recognized client (Claude, ChatGPT), NetSuite
  **auto-creates an Integration Record** (`Public Client: checked`,
  `Authorization Code Grant: checked`, `Redirect URI: auto-populated`) under
  Setup → Integration → Manage Integrations. This auto-provisioning behavior
  is documented only for Claude/ChatGPT/Codex by name — **whether it also
  triggers for an arbitrary third-party client identifying itself over MCP
  (i.e., SchemaBounce) is the single biggest unknown and needs a live trial-
  account test**, not something resolvable from docs alone. If NetSuite's
  auto-provisioning is tied to a per-client allowlist (plausible, given it
  names specific vendors) rather than a generic RFC 7591 DCR endpoint, our
  BYO flow's DCR-only path (see the linked per-tenant-MCP-pattern doc, Part 1
  "No: BYO OAuth can only use Dynamic Client Registration") will not work
  out of the box, and a manually-created Integration Record (with a
  NetSuite-issued client id/secret pasted in) would be required — which our
  BYO custom/* flow currently has no field for (pins are catalog-only).
- **Status: GA**, not preview — corroborated by ChatGPT Business/Enterprise
  shipping a direct workspace-connector integration "added early 2026" and
  by Oracle's March 2026 SuiteConnect London announcement of the "AI
  Connector Service Companion" extension on top of an already-shipped base
  service.
  ([NetSuite AI Connector Companion: MCP & Apps](https://www.houseblend.io/articles/netsuite-ai-connector-companion-mcp-apps),
  [Techzine: NetSuite expands AI Connector Service with MCP Apps](https://www.techzine.eu/news/applications/140095/netsuite-expands-ai-connector-service-with-mcp-apps/))
- **Free**: the AI Connector Service and the MCP Standard Tools SuiteApp are
  both free NetSuite features (no incremental NetSuite license). The
  customer's AI client subscription is the only external cost (Claude Pro/
  Max/Team — the free tier explicitly does not support custom connectors).
- **Setup burden lives on the customer's NetSuite admin**, every time, per
  account:
  1. Setup → Company → Enable Features → SuiteCloud: enable **Server
     SuiteScript**, **REST Web Services**, **OAuth 2.0** (under Manage
     Authentication).
  2. Install the **MCP Standard Tools SuiteApp** from the SuiteApp
     Marketplace.
  3. **Create a dedicated custom role** for MCP access — NetSuite explicitly
     **blocks the Administrator role from being used with MCP** — with
     `MCP Server Connection` (Full), `OAuth 2.0 Access Tokens` (Full),
     `REST Web Services` (Full), plus whatever record-level permissions the
     AR-chasing use case needs (Transactions → Invoice, Find Transaction,
     Customer, etc.). Oracle also ships prebuilt **"MCP-ready roles"**
     (CFO, Controller, AR Analyst) as of the March 2026 Companion release —
     check whether one of those covers AR chasing before hand-rolling
     permissions.
  4. Sign in to the AI client with the custom role (not Administrator) and
     complete OAuth consent.
- **Data exposed**: full REST-Web-Services-permitted record CRUD, saved
  search execution, reports, and natural-language-to-SuiteQL query
  generation — this covers the AR-chasing use case directly (overdue
  invoice lists, customer balances, payment status) without any custom
  SuiteScript, gated only by whatever the custom MCP role's record
  permissions allow.

### 2.2 Community/SuiteTalk options (context, not the recommendation)

Several unofficial SuiteTalk-based MCP servers exist on GitHub
(`dsvantien/netsuite-mcp-server`, `manateeit/netsuite-mcp-v3`,
`glints-dev/mcp-netsuite`, `CDataSoftware/netsuite-mcp-server-by-cdata` —
read-only via CData JDBC). These predate or duplicate what Oracle's own
service now does natively (SuiteQL access, record reads, OAuth). Building or
adopting one of these would mean maintaining SuiteTalk/TBA auth code and
duplicating a surface Oracle now ships for free and GA. Not recommended given
2.1 exists.

### 2.3 Recommendation for the AR-chasing use case: connect the existing Oracle GA endpoint via BYO, do not build a stdio server

This is a **"leverage the vendor's own official server," not build, not
wait, not partner** case — the strongest of the three options in this
research pass, because unlike M365 there is no license-tier gate blocking
mid-market customers and the service is already GA and free.

1. **(0.5-1 day) Live-verify the OAuth path on a NetSuite trial/sandbox
   account** — this is the one thing this research pass could not do without
   a real account. Specifically: does pointing our platform's fixed
   `redirect_uri` (`https://api.schemabounce.com/api/v1/oauth/mcp/callback`)
   at a fresh NetSuite account's Integration Record auto-provisioning flow
   work, or does NetSuite reject an unrecognized client and require a
   manually-created Integration Record with a NetSuite-issued client
   id/secret pasted into our side? This single test determines whether
   NetSuite can be onboarded as a **DCR-style BYO connection today with zero
   backend changes**, or needs the **BYO-pinned-client extension** (a real
   gap: today's `custom/*` OAuth path has no field for a user-supplied
   client id/secret, only catalog-pin or DCR — see the linked per-tenant doc,
   Part 1 "No: BYO OAuth can only use Dynamic Client Registration").
2. **(1-2 days, only if step 1 finds DCR doesn't work) Add a "bring your own
   OAuth client" field to the custom/BYO MCP form** — a small, generically
   useful extension (not NetSuite-specific): let a user paste a client_id/
   client_secret pair NetSuite (or any other pre-registration-only vendor)
   issued them, store it the same way `github-remote`'s platform-level pin
   is stored but scoped to the one workspace connection instead of the whole
   catalog. This unblocks NetSuite AND any other enterprise vendor requiring
   manual app registration without DCR (a pattern this research and the
   linked per-tenant doc both hit independently).
3. **(0.5 day, no build) Write the customer-facing NetSuite setup guide** —
   mirrors the Databricks/dbt Cloud guides in the linked per-tenant-MCP-
   pattern doc's Part 3: account-specific URL (with the account ID
   placeholder explained), the four NetSuite-admin prerequisite steps from
   2.1 above, and a note steering AR-chasing customers toward Oracle's
   prebuilt "AR Analyst" MCP-ready role if available on their account, to
   avoid the customer hand-rolling permissions.
4. **(future, once the per-tenant `url_placeholders` catalog gap ships) Promote
   to a first-class catalog tile** — `auth.type: oauth2_mcp`,
   `transport.url: "https://{NETSUITE_ACCOUNT_ID}.suitetalk.api.netsuite.com/services/mcp/v1/suiteapp/com.netsuite.mcpstandardtools"`,
   `urlPlaceholders: [{name: NETSUITE_ACCOUNT_ID, ...}]`, using whichever
   auth shape step 1 determined (DCR entry — no `client_id_env` needed — or
   pinned entry with `client_id_env`/`client_secret_env` if NetSuite requires
   a manual Integration Record per account even for a known client).

Total estimated effort to a working BYO connection guide: **1-3 days**
(mostly the live sandbox test in step 1 and, conditionally, the pinned-client
BYO field in step 2). This is materially cheaper than building or adopting a
SuiteTalk stdio server, because Oracle's own GA service already does
everything the AR-chasing use case needs.

---

## Summary table

| Vendor / surface | Hosting | Auth | Status | License gate | Recommendation |
| --- | --- | --- | --- | --- | --- |
| Microsoft Enterprise Graph MCP (`mcp.svc.cloud.microsoft/enterprise`) | Remote, single global URL | Pinned client (no DCR, probe-verified) | Public preview | None extra | Not useful for mail/calendar/SharePoint — identity/directory only, skip |
| Agent 365 Work IQ (Mail/Calendar/SharePoint/OneDrive) | Remote, per-tenant URL | Per-tenant Entra app, native-redirect public client | Preview, tool names may change | Requires Microsoft 365 Copilot license | Check Composio Outlook/OneDrive toolkits first; else build a direct-Graph stdio bridge (3-5 days); do not touch Work IQ itself yet |
| NetSuite AI Connector Service | Remote, per-account URL | OAuth 2.0 + PKCE, auto-provisioned Integration Record (DCR-like, unverified for 3rd-party clients) | **GA**, free | None (customer needs a paid Claude/ChatGPT plan) | Live-test OAuth on a trial account, then ship a BYO setup guide now (1-3 days); promote to a catalog tile once URL-placeholder support ships |

## Sources

- [Overview of Microsoft MCP Server for Enterprise](https://learn.microsoft.com/en-us/graph/mcp-server/overview)
- [Get Started With the Microsoft MCP Server for Enterprise](https://learn.microsoft.com/en-us/graph/mcp-server/get-started)
- [Work IQ MCP overview (preview)](https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview)
- [Work IQ OneDrive reference (preview)](https://learn.microsoft.com/en-us/microsoft-copilot-studio/mcp-onedrive-work-iq)
- [Custom client app registration for Agent 365 CLI](https://learn.microsoft.com/en-us/microsoft-agent-365/developer/custom-client-app-registration)
- [microsoft/mcp — catalog of official Microsoft MCP servers](https://github.com/microsoft/mcp)
- [Softeria/ms-365-mcp-server (community Graph MCP, MIT)](https://github.com/softeria/ms-365-mcp-server)
- [NetSuite: Get Started with the NetSuite AI Connector Service](https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/article_3200541651.html)
- [NetSuite: Connect to the NetSuite AI Connector Service](https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/section_0714082142.html)
- [NetSuite: MCP Standard Tools SuiteApp](https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/article_143403258.html)
- [NetSuite AI Connector Service FAQ](https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/article_4160616848.html)
- [What is the NetSuite AI Connector Service? (netsuite.com)](https://www.netsuite.com/portal/products/artificial-intelligence-ai/mcp-server.shtml)
- [Techzine: NetSuite Expands AI Connector Service with MCP Apps](https://www.techzine.eu/news/applications/140095/netsuite-expands-ai-connector-service-with-mcp-apps/)
- [Houseblend: NetSuite AI Connector Companion: MCP & Apps](https://www.houseblend.io/articles/netsuite-ai-connector-companion-mcp-apps)
- [Numeric: NetSuite MCP Setup Guide for Controllers (2026)](https://www.numeric.io/blog/netsuite-mcp)
- Live probe (this research pass, 2026-07-21):
  `microsoft-enterprise-graph|OK|https://login.microsoftonline.com/organizations/v2.0|dcr=NO|scopes=openid profile email offline_access`
- `/mnt/c/git/core-api/schemabounce-api/internal/adl/config_publisher.go` (`McpOAuthCatalogPin`, `resolveCatalogToolDefaults`)
- `/mnt/c/git/core-api/schemabounce-api/internal/handlers/mcp_oauth_mcp_handler.go` (`redirectURI()`, `resolveRemoteURL()`)
- `/mnt/c/git/clawsink-bots/tools/microsoft-teams/SERVER.md`, `tools/github-remote/SERVER.md`, `tools/plain/SERVER.md`, `tools/unsora/SERVER.md`, `tools/zendesk/SERVER.md` (read for format/precedent)
