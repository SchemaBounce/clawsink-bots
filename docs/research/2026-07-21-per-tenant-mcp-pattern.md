# Per-tenant MCP servers: how SchemaBounce should support them

Date: 2026-07-21
Status: research + design proposal, not yet built
Author: investigation for the MCP catalog program

## The problem

The catalog format (`SERVER.md` → `mcp_server_catalog.url_template` → connection
transport) assumes one server has one URL that every customer connects to
(`https://mcp.plain.com/mcp`, `https://api.githubcopilot.com/mcp/`). That holds
for vendor-hosted, single-tenant-endpoint servers. It breaks for vendors whose
MCP endpoint is generated per customer:

- **Databricks**; the managed MCP servers (Genie, Unity Catalog Functions, AI
  Search, SQL) live at `https://<workspace-hostname>/api/2.0/mcp/<server-type>`.
  `<workspace-hostname>` is unique per Databricks account (e.g.
  `dbc-a1b2c3d4-e5f6.cloud.databricks.com`), and some server types also carry
  catalog/schema/space identifiers in the path.
- **dbt Cloud**; the remote MCP endpoint is
  `https://YOUR_DBT_HOST_URL/api/ai/v1/mcp/`. The host differs by cell/region
  (`cloud.getdbt.com` vs `ACCOUNT_PREFIX.us1.dbt.com` for multi-cell accounts).
- Same shape applies to **Tableau** (per-site server URL), **Metabase**, and any
  self-hosted **Grafana**.

A catalog row with one fixed `url` cannot represent these. Today the only way a
customer reaches one of these servers is the **custom/BYO flow**, which this
doc confirms works for the URL part today, and is missing multi-header auth
for the vendors that need it (dbt Cloud).

## Part 1; What the custom/BYO flow can do today (verified by reading code)

### Yes: a customer can already paste an arbitrary remote MCP URL

`CustomMcpServerModal.tsx` → Remote URL tab (`src/pages/workspaces/agent-data-layer/CustomMcpServerModal.tsx`)
lets a user type any `https://` URL plus one auth header name, and submits a
`TransportConfigSpec` (`packageType: "remote"`, `transportType:
"streamable-http" | "sse"`) to the create-connection endpoint. There is no
allowlist of hosts; any reachable HTTPS endpoint is accepted
(`normalizeRemoteUrl` in `customMcpTransport.ts` just enforces scheme + rejects
plain HTTP). So "enter your Databricks workspace URL" or "enter your dbt Cloud
host" already works as a **freeform paste**, per workspace, today. There is no
catalog entry for it (no logo, no guided setup, no health-state copy tuned to
the vendor); it is exactly as discoverable as any other BYO server, which is
to say: not discoverable at all unless a human walks the customer through it.

### Yes: BYO remote servers can be classified as OAuth automatically

`mcp_oauth_byo.go` (`detectOAuthMcpBYO`) runs on every credential-less
`custom/*` streamable-http/sse connection. It probes the pasted URL for the
MCP-spec 401 challenge (RFC 9728 `WWW-Authenticate` header naming a protected
resource metadata document). If the vendor's endpoint answers the challenge,
the connection is auto-classified `auth_method = oauth-mcp` and the UI shows
"Connect your account" instead of a dead-end credential form; no code change
needed per vendor.

### No: BYO OAuth can only use Dynamic Client Registration, never a pinned client

This is the load-bearing limitation. `mcp_oauth_mcp_handler.go`
→ `resolveRemoteURL()` (line ~460) is explicit:

```go
if strings.HasPrefix(serverRef, "custom/") {
    tc, ok := h.connections.LookupCustomTransport(ctx, workspaceID, serverRef)
    ...
    return tc.Url, nil, nil   // <-- pin is always nil for custom/*
}
```

The comment above it spells out why: *"the stored BYO transport for custom/\*
refs (never any pin; a pin names platform env vars and endpoints, so it must
only ever come from the verified catalog, not user input)"*. Then in
`ensureClientRegistration()`, no pin means the handler always falls through to
`h.oauth.RegisterClient(...)`; RFC 7591 Dynamic Client Registration against
the vendor's `registration_endpoint`.

So: **BYO OAuth only works against an authorization server that supports DCR.**
`plain` and `unsora` (read as canonical examples) both work today specifically
*because* their AS supports DCR; the SERVER.md comments say so explicitly
("DCR verified", "DCR at /oauth/register"). `github-remote` is the counter-case:
GitHub's AS has no DCR, so it needed a **pinned client** (`client_id_env` /
`client_secret_env` naming a platform env var); and pins are catalog-only,
gated to `tier: verified`, never available to a `custom/*` BYO row.

**Databricks and dbt Cloud OAuth is enterprise-grade OAuth 2.1**; Databricks
requires an OAuth app registered in the account console (client id issued by
Databricks admin, not self-registered by an anonymous client); dbt Cloud's
OAuth support is in beta and its public docs do not spell out whether a
manual client-registration path exists for clients without dynamic
registration support (verify against a live dbt Cloud account before relying
on it). Neither vendor's docs claim RFC 7591 DCR support. **Assume BYO OAuth will not auto-classify these connections**;
if it silently doesn't 401-challenge in a DCR-discoverable way, `detectOAuthMcpBYO`
returns `(nil, false)` and the connection falls through to normal (static
credential) validation, which is the outcome we want for the PAT-based guides
below.

### Gap found: BYO remote transport supports exactly ONE static auth header

`TransportConfigSpec.AuthHeaderName` (`internal/models/mcp_connection.go:261`)
is a single string. It flows unchanged through `config_publisher.go` (line
~2970) and `mcp_connection_service.go` (line ~650) onto the `McpTransportSpec`
the gateway launches with. There is no `Headers map[string]string`; never was
one added for the runtime path (a `spec.AuthHeaders` map exists but only for
the validation-probe task, `mcp_connection_handler.go:1948`, and even there
`buildValidationRemoteAuthHeaders` returns early with a single key when
`authHeaderName` is set).

This matters because **dbt Cloud's token auth needs two to four headers**
simultaneously (`Authorization`, `x-dbt-prod-environment-id`, and for
`execute_sql` also `x-dbt-dev-environment-id` + `x-dbt-user-id`; see Part 3).
Databricks needs only one (`Authorization: Bearer <PAT>`), so it fits the
existing single-header model cleanly. dbt Cloud does not, fully, today.

### Yes: there is already a working "{PLACEHOLDER}" substitution mechanism; but only for validation probes, not for the connection URL

`mcp_validation_engine.go` → `runUpstreamProbe` substitutes `{ENV_VAR}` tokens
in a `McpServerValidationDef.Request.URL` (and body) against the connection's
stored credentials before firing the health-check probe
(`mcp_validation_engine_extensions_test.go`,
`TestRunUpstreamProbe_UrlTemplateSubstitutes` / `_UrlTemplateMissing`). This is
a **SERVER.md-authored `validation.request.url` field**, used today for things
like Jira's `{JIRA_URL}/rest/api/3/myself`. It proves the substitution
mechanism (parse `{TOKEN}`, look up in a credentials map, replace, and fail
cleanly with a named-variable error when missing) already exists in the
codebase and is tested; it is simply not wired to the **connection's actual
launch URL** (`url_template` → `McpTransportSpec.Url`), only to the probe.
`resolveCatalogToolDefaults()` (`config_publisher.go:2795`) copies
`entry.URLTemplate` straight into `transport.Url` with zero substitution.

Note: a second, narrower substitution site exists at core-api schemabounce-api/internal/handlers/mcp_connection_handler.go (buildAndEnqueueValidate, ~lines 1936-1948), which resolves ${ENV}-style tokens in tc.Url for the validate-job path. It is distinct from the {TOKEN} grammar discussed here and any placeholder design must account for both sites.


## Part 2; Design proposal: catalog URL template with a user-supplied placeholder

The smallest change that lets a catalog entry represent "one server, one URL
shape, unique host per customer":

### 2.1 SERVER.md: a `transport.url` with a documented placeholder token

```yaml
transport:
  type: "streamable-http"
  url: "https://{DATABRICKS_WORKSPACE_HOST}/api/2.0/mcp/sql"
  urlPlaceholders:
    - name: DATABRICKS_WORKSPACE_HOST
      label: "Databricks workspace hostname"
      description: "Your workspace URL without the https:// prefix, e.g. dbc-a1b2c3d4-e5f6.cloud.databricks.com"
      example: "dbc-a1b2c3d4-e5f6.cloud.databricks.com"
```

`urlPlaceholders` is new. It reuses the existing `env[]` block's shape
(name/label/description) rather than inventing a second vocabulary; a
placeholder is really just a non-secret `Variable` (see
`models.WorkspaceCredentials.Variables`, already a
`map[string]string` of plaintext non-secret values like base URL / org id,
returned and editable on reload) that happens to be substituted into the URL
instead of sent as an env var or header.

### 2.2 Registry sync: carry the placeholder list, don't resolve it

`registry_sync.go` writes `url_template` as-is (it already does; a `{TOKEN}`
in the string is opaque to the sync). Add one column,
`mcp_server_catalog.url_placeholders JSONB`, populated from the SERVER.md
block. No resolution happens at sync or catalog-read time; the placeholder
survives into `McpCatalogEntry.URLTemplate` and a new
`McpCatalogEntry.URLPlaceholders []URLPlaceholder` field untouched.

### 2.3 Connect flow: the setup modal collects the placeholder value like any other Variable

When a catalog entry declares `urlPlaceholders`, the catalog server's setup
modal (the one used for `tools/*` catalog refs; NOT `CustomMcpServerModal`,
which is the BYO path) renders one text input per placeholder, pre-filled with
the `example` as placeholder text, alongside the existing credential inputs.
The submitted value goes into the *same* `variables` map connections already
carry (`WorkspaceCredentials.Variables`) under the placeholder's `name`; no
new storage primitive, no new secret path (it is NOT a secret; workspace
hostnames are visible in the browser's OAuth redirect anyway).

### 2.4 Resolution: substitute at the exact place `url_template` becomes `transport.Url`

Add one function, reusing the *existing, tested* substitution logic from
`runUpstreamProbe` (extract it to a shared helper, e.g.
`substituteURLPlaceholders(template string, vars map[string]string) (string, error)`
in `mcp_validation_engine.go`, or lift it to a small shared file both
`mcp_validation_engine.go` and `config_publisher.go` import) and call it in
`resolveCatalogToolDefaults()`:

```go
resolvedURL, err := substituteURLPlaceholders(entry.URLTemplate, connVariables)
if err != nil {
    // same shape as the existing probe's "needs_setup" + named-variable error
    return nil, nil, ""  // and surface health=needs_setup, details="Missing DATABRICKS_WORKSPACE_HOST"
}
transport.Url = resolvedURL
```

This is a small, additive change: no new tables beyond one JSONB column, no
new auth model, reuses the tested `{TOKEN}` substitution grammar the probe
path already proved out, and reuses the existing plaintext-Variables storage
for the value. It does NOT touch OAuth; a per-tenant catalog entry with
`auth.type: oauth2_mcp` still needs either DCR (works out of the box, same as
`plain`/`unsora`) or a pinned client (works the same as `github-remote`, and a
pin's `authorization_endpoint`/`token_endpoint` can ALSO carry the placeholder
token, substituted the same way, for vendors whose OAuth endpoints are
per-tenant too; Databricks OAuth app registrations are per-workspace).

### 2.5 Secondary recommendation: multi-header static auth for BYO remote

Not required for the URL-template proposal above, but required to fully
support dbt Cloud (Part 3) via BYO today. Extend `TransportConfigSpec` with an
optional `authHeaders map[string]string` (plural), alongside the existing
singular `authHeaderName`, and carry it through the same three call sites
identified in Part 1 (`config_publisher.go`, `mcp_connection_service.go`,
`mcp_connection_handler.go`). Each key names a stored credential/variable; each
value is sent as that literal HTTP header. `CustomMcpServerModal`'s remote tab
gets a repeatable header-name/credential-name row instead of one fixed input.
This is a materially bigger change than the URL template (new field across 3+
call sites plus a UI list-editor); flag it as a separate follow-up, not a
blocker for shipping Databricks (which needs only one header).

## Part 3; Customer guides for connecting today, via the existing BYO flow

Both guides below work with **zero code changes**; they use the Remote URL
tab in "Add custom MCP server" as it exists today. Neither vendor's OAuth is
attempted (BYO OAuth needs DCR; assume it's absent for both; see Part 1), so
both use static token/header auth, which is fully supported for Databricks and
partially supported for dbt Cloud (see the note under step 4).

### 3.1 Connect Databricks (managed MCP: Genie, SQL, Unity Catalog Functions, AI Search)

1. In Databricks, generate a **personal access token**: workspace → Settings →
   Developer → Access tokens → Generate new token. Copy it immediately; it is
   shown once. (Or use a Databricks service principal token for a
   non-personal, longer-lived credential.)
2. In SchemaBounce, go to **Agent Data Layer → Connections → Add custom MCP
   server**.
3. **Display name**: something identifying the server, e.g. `Databricks SQL`.
4. **Remote URL tab**, Server URL: enter your workspace's MCP endpoint for the
   server type you want:
   - SQL: `https://<your-workspace-host>/api/2.0/mcp/sql`
   - Unity Catalog Functions: `https://<your-workspace-host>/api/2.0/mcp/functions/<catalog>/<schema>/<function>`
   - Genie: `https://<your-workspace-host>/api/2.0/mcp/genie/<genie_space_id>`
   - AI Search: `https://<your-workspace-host>/api/2.0/mcp/ai-search/<catalog>/<schema>/<index>`
     (`<your-workspace-host>` is the hostname shown in your browser when you're
     logged into Databricks, e.g. `dbc-a1b2c3d4-e5f6.cloud.databricks.com`;
     no `https://` prefix, no trailing slash.)
5. **Auth header credential**: type `Authorization`.
6. In the **Credentials** section below, add a row: key `Authorization`, value
   `Bearer <your PAT>` (include the literal word `Bearer` and a space before
   the token; Databricks expects the standard bearer format).
7. Save. SchemaBounce fires a validation probe; a green "Reachable" result
   confirms the token and URL are both correct. If it fails, double check the
   workspace hostname has no `https://` and no trailing slash, and that the
   PAT hasn't expired.
8. Grant the new connection's tools to an agent from the agent's MCP servers
   tab.

One SchemaBounce connection = one Databricks MCP server type. To use both
SQL and Genie, add two custom connections (different Server URLs), each with
its own PAT credential row (a Databricks PAT can be reused across both if
scoped broadly enough, or issue separate tokens for tighter blast radius).

### 3.2 Connect dbt Cloud (remote MCP)

**Known limitation first:** dbt Cloud's token auth needs the `Authorization`
header plus a numeric `x-dbt-prod-environment-id` header at minimum, and two
more headers (`x-dbt-dev-environment-id`, `x-dbt-user-id`) for the
`execute_sql` tool. Today's custom-MCP form sends exactly one static header
(see Part 1, "Gap found"). Until the multi-header extension in 2.5 ships, this
guide connects dbt Cloud with **the discovery/semantic-layer tools only**;
`execute_sql` and any tool requiring `x-dbt-*` headers beyond `Authorization`
will 401 or reject the call, because those headers never reach the request.

1. In dbt Cloud: **Account settings → API tokens → Personal tokens** → create
   a Personal Access Token. Copy it.
2. Note your **production environment ID** (visible in the environment's URL
   or settings page; a plain integer) and your dbt Cloud host (default
   `cloud.getdbt.com`; multi-cell accounts use
   `ACCOUNT_PREFIX.us1.dbt.com`; check **Account settings → Access URLs**).
3. In SchemaBounce, **Agent Data Layer → Connections → Add custom MCP
   server**.
4. **Display name**: `dbt Cloud`.
5. **Remote URL tab**, Server URL:
   `https://<your-dbt-host>/api/ai/v1/mcp/` (keep the trailing slash).
6. **Auth header credential**: type `Authorization`.
7. **Credentials**: add a row, key `Authorization`, value `Token <your PAT>`
   (dbt accepts either `Token <PAT>` or `Bearer <PAT>`; `Token` is the format
   in their own docs).
8. Save and validate. Expect the connection to come up healthy and serve
   discovery/metadata tools (`get_all_models`, `text_to_sql`, semantic-layer
   queries). SQL execution tools will fail until the multi-header extension
   (Part 2.5) ships, because `x-dbt-prod-environment-id` cannot be sent.
9. If you need `execute_sql` today, the only workaround is a
   vendor-side proxy: stand up a small HTTP reverse proxy you control that
   injects the three extra `x-dbt-*` headers server-side and forwards to the
   real dbt Cloud MCP endpoint, then point SchemaBounce's Server URL at your
   proxy instead of dbt Cloud directly. This is out of scope to build as part
   of this research; flag it in the follow-up if a customer needs it before
   2.5 ships.

## Appendix: the platform's OAuth callback URL, and a manual-registration gap it exposes

`MCPGenericOAuthHandler.redirectURI()` (`mcp_oauth_mcp_handler.go:450`) returns
`redirectBase + "/api/v1/oauth/mcp/callback"`. `redirectBase` resolves from
`MCP_OAUTH_REDIRECT_BASE`, falling back to `GOOGLE_REDIRECT_BASE`, falling back
to `http://localhost:8080` (`mcp_oauth_mcp_handler.go:83-89`). Neither env var
is overridden per environment in `argocd/`; the Helm overlay
(`core-api/deploy/helm/schemabounce/overlays/prod/values.yaml:275`) sets
`oauth.googleRedirectBase: "https://api.schemabounce.com"`, which is the only
value that reaches `GOOGLE_REDIRECT_BASE` in production. So in production
today the callback URL every MCP OAuth flow (catalog and BYO alike) presents
to a vendor's authorization server is:

```
https://api.schemabounce.com/api/v1/oauth/mcp/callback
```

This is the exact URL a customer would need to register if they used dbt
Cloud's "Manual Registration" path (Account settings → Integrations → App
integrations, PKCE, for clients whose AS doesn't do DCR) or Databricks'
account-console OAuth app registration. **Neither is wired today**: nothing in
`CreateMcpConnectionRequest` or `CustomMcpServerModal` accepts a
customer-supplied `client_id`/`client_secret` for a `custom/*` row:
`ensureClientRegistration()` only ever DCRs or uses a catalog `OAuthPin`
(Part 1). A workspace that manually registers an app with dbt Cloud or
Databricks and gets back a client id has nowhere to put it. If DCR turns out
not to work against either vendor (verify live; Part 1's "No" finding),
closing this gap means either (a) letting a `custom/*` connection carry its
own `clientId`/`clientSecretEnv` the way a catalog `OAuthPin` does today, or
(b) treating the redirect URI as documentation and asking the customer to use
the vendor's PAT/token auth instead (the guides in Part 3 already do this).

## Summary

| Question | Answer |
| --- | --- |
| Can a customer paste an arbitrary remote MCP URL today? | Yes, via BYO custom/* Remote URL tab. No allowlist. |
| Does BYO auto-detect OAuth? | Yes, via RFC 9728 challenge probing, but only completes the flow if the vendor's AS supports RFC 7591 DCR. |
| Can BYO use a pinned (non-DCR) OAuth client? | No; pins are catalog-only (`tier: verified`), never available to `custom/*`. |
| Can BYO send more than one static auth header? | No; `TransportConfigSpec.AuthHeaderName` is a single string end to end. |
| Is there a working `{PLACEHOLDER}` substitution mechanism in the codebase already? | Yes, for the validation-probe URL (`runUpstreamProbe`); proven and tested, but not wired to the connection's actual launch URL. |
| What's the smallest change for a first-class per-tenant catalog entry? | One JSONB column (`url_placeholders`) + one setup-modal input per placeholder + reuse the existing plaintext Variables storage + reuse the existing `{TOKEN}` substitution helper at the one place `url_template` becomes `transport.Url`. |
| Can Databricks be connected via BYO today, fully? | Yes; single PAT header covers it. |
| Can dbt Cloud be connected via BYO today, fully? | Partially; discovery/semantic-layer tools yes; `execute_sql` no, blocked on the multi-header gap. |

## Sources

- [Databricks managed MCP servers (AWS docs)](https://docs.databricks.com/aws/en/generative-ai/mcp/managed-mcp)
- [dbt Developer Hub; Set up remote MCP](https://docs.getdbt.com/docs/dbt-ai/setup-remote-mcp)
- [dbt Developer Hub; Connect dbt MCP server to dbt platform (OAuth)](https://docs.getdbt.com/docs/dbt-ai/mcp-quickstart-oauth)
