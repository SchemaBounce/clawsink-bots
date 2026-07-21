# Pinned-Client OAuth Registrations; Operator Runbook

## What this document is

Five catalog entries (`tools/gong`, `tools/chargebee`, `tools/box`,
`tools/front`, `tools/crunchbase`) use `auth.type: oauth2_mcp` with a
**pinned client** instead of dynamic client registration (DCR). Their
authorization servers were live-probed on 2026-07-21 and confirmed to
serve RFC 8414 metadata but no RFC 7591 DCR endpoint, so the platform
cannot register a client automatically at connect time. A human has to
register an OAuth app with each vendor once per environment, then set the
resulting client id (and secret, where the vendor issues one) as a
platform environment variable.

This is the same pattern already in production for `tools/github-remote`
(see that `SERVER.md` for the code-level contract). Nothing here runs in
our gateway; every one of these is a vendor-hosted remote MCP server; the
platform only brokers the OAuth handshake.

## The one redirect URI every registration needs

Every vendor app below must allow this **exact** redirect URI, once per
environment that serves the tile:

```
<api-base>/api/v1/oauth/mcp/callback
```

Where `<api-base>` is the environment's public API origin. In production
that is:

```
https://api.schemabounce.com/api/v1/oauth/mcp/callback
```

This is a single, workspace-agnostic callback (source:
`redirectURI()` in `core-api/schemabounce-api/internal/handlers/mcp_oauth_mcp_handler.go`,
resolved from the `MCP_OAUTH_REDIRECT_BASE` env var, falling back to
`GOOGLE_REDIRECT_BASE`). Register it once per vendor app; it does not need
to change per workspace or per connection.

## Where the credentials go

After registering, set the resulting values as environment variables on
the core-api pod (the same place `GH_CLIENT_ID` / `GH_CLIENT_SECRET`
already live for `tools/github-remote`). Follow RULE 8.2: environment-
specific values belong in ArgoCD application parameters
(`argocd/environments/{env}/`), not hardcoded in Helm values, and secrets
are never inlined in values files; put the secret values in the secrets
manager and reference them the way `GH_CLIENT_SECRET` is referenced today.

| Vendor     | Env var(s) to set                                               |
| ---------- | ----------------------------------------------------------------- |
| Gong       | `GONG_MCP_OAUTH_CLIENT_ID`, `GONG_MCP_OAUTH_CLIENT_SECRET`         |
| Chargebee  | `CHARGEBEE_MCP_OAUTH_CLIENT_ID` (no secret; public client)        |
| Box        | `BOX_MCP_OAUTH_CLIENT_ID`, `BOX_MCP_OAUTH_CLIENT_SECRET`           |
| Front      | `FRONT_MCP_OAUTH_CLIENT_ID`, `FRONT_MCP_OAUTH_CLIENT_SECRET`       |
| Crunchbase | `CRUNCHBASE_MCP_OAUTH_CLIENT_ID`, `CRUNCHBASE_MCP_OAUTH_CLIENT_SECRET` |

Until these are set, the tile stays in `needs_setup`; connect attempts
will fail at the authorize step because `ResolveClientID` returns empty.

---

## Gong

- **MCP endpoint:** `https://mcp.gong.io/mcp`
- **Authorization server:** `https://mcp.gong.io` (authorization endpoint
  `https://app.gong.io/oauth2/authorize`, token endpoint
  `https://app.gong.io/oauth2/generate-mcp-token`)
- **Scopes to request:** `mcp:ai-ask:read`, `mcp:ai-briefer:read`,
  `mcp:ai-assistant:read` (all three; each gates one of the three MCP
  tools; requesting fewer drops the matching tool from the session)

**Registration steps:**

1. Sign in to Gong as an admin and go to **Admin Center → Settings →
   Ecosystem → API**, then the **Integrations** tab.
2. Click **Create Integration**.
3. Fill in the integration form: name (e.g. "SchemaBounce"), description,
   small + large logo, the three scopes above, privacy policy URL, terms
   URL, a help article link, a contact email, and the organization's
   domain.
4. Set **Redirect URI** to the callback URL above.
5. Save. A new row appears in the integrations list with the **Client
   ID** shown directly, and a **Client Secret** behind "Show secret".
6. Copy both into `GONG_MCP_OAUTH_CLIENT_ID` / `GONG_MCP_OAUTH_CLIENT_SECRET`.

Source: [Create an OAuth app for Gong](https://help.gong.io/docs/create-an-app-for-gong),
[About Gong MCP server](https://help.gong.io/docs/about-gong-mcp-server).

---

## Chargebee

- **MCP endpoint:** `https://mcp.chargebee.com/mcp`
- **Authorization server:** `https://app.chargebee.com/mcp`
  (authorization endpoint `https://app.chargebee.com/oauth2/authorize`,
  token endpoint `https://app.chargebee.com/oauth2/token`)
- **Scopes to request:** none. Chargebee's authorization server advertises
  no `scopes_supported`; access is scoped by which Chargebee site the app
  is registered against, not an OAuth scope string.
- **Client type:** Chargebee's AS advertises
  `token_endpoint_auth_methods_supported: ["none"]` only; this is a
  **public client** (PKCE, no client secret). Do not expect or store a
  secret for Chargebee.

**Registration steps:**

1. Sign in to the target Chargebee site as an admin and go to the OAuth Apps section of your Chargebee site settings (navigation names vary by Chargebee version; search "OAuth Apps" in the settings search bar, or see chargebee.com docs).
2. Click **Create an OAuth App**.
3. Enter an app name and set the redirect URL to the callback URL above.
4. Save. Chargebee shows a **Client ID** (no secret, per the public-client
   note above).
5. Copy it into `CHARGEBEE_MCP_OAUTH_CLIENT_ID`.

Note: this OAuth app is created on a specific Chargebee site/subdomain. If
different workspaces need different Chargebee sites connected, each site
needs its own registered app and this catalog entry only carries one
pinned client; flag that scaling question before onboarding a second
Chargebee customer.

Source: [Chargebee MCP Servers](https://www.chargebee.com/docs/billing/2.0/developer-resources/mcp),
[Chargebee API documentation](https://apidocs.chargebee.com/).

---

## Box

- **MCP endpoint:** `https://mcp.box.com/mcp`
- **Authorization server:** `https://api.box.com/` (authorization endpoint
  `https://account.box.com/api/oauth2/authorize`, token endpoint
  `https://api.box.com/oauth2/token`)
- **Scopes to request:** none as an OAuth scope string. Box gates MCP
  access through Box application scopes (root_readwrite, ai.readwrite,
docgen.readwrite), not the
  OAuth `scope` parameter.

**Registration steps (this one is NOT the general Box Developer Console
custom-app flow; Box ships a purpose-built admin panel for its MCP
server):**

1. Sign in to the Box Admin Console as an admin and go to
   **Integrations**.
2. Find **Custom Box MCP Server**, hover it, and click **Configure**.
3. Under **Additional Configuration**, click **+ Add Integration
   Credentials**. Box auto-generates the Client ID and Client Secret;
   there is nothing to type in for those two fields.
4. Enter the callback URL above as the **Redirect URI**.
5. Under application scopes, grant **ai.readwrite** (plus root_readwrite /
   docgen.readwrite if the workspace needs file and doc generation tools).
   Box MCP requires the Enterprise Advanced plan; the admin tile is named
   "Box MCP server" (see developer.box.com/guides/box-mcp/setup).
6. Save, then copy the generated Client ID and Client Secret into
   `BOX_MCP_OAUTH_CLIENT_ID` / `BOX_MCP_OAUTH_CLIENT_SECRET`.

Source: [Box MCP server](https://developer.box.com/guides/box-mcp),
[Managing Box MCP Servers](https://support.box.com/hc/en-us/articles/43847256139923-Managing-Box-MCP-Servers).

---

## Front

- **MCP endpoint:** `https://mcp.frontapp.com/mcp`
- **Authorization server:** `https://app.frontapp.com` (authorization
  endpoint `https://app.frontapp.com/oauth/authorize`, token endpoint
  `https://app.frontapp.com/oauth/token`)
- **Scopes to request:** `feature:mcp` (the only scope Front's MCP
  authorization server advertises)

**Registration steps:**

1. Sign in to Front as an admin and open the developer app creation flow
   (Front app → Settings → Developers → "Create, manage, and publish
   apps").
2. Create a new app (e.g. "SchemaBounce MCP Connector").
3. Go to the **Features** tab → **Add feature** → configure an **OAuth**
   feature.
4. Under feature access, enable **only** "MCP Server". Front's own docs
   warn that enabling any other feature access on the same OAuth feature
   causes 403s when the MCP endpoint is called; leave everything else
   off.
5. Set the **Redirect URI** to the callback URL above.
6. Under resource permissions, select the narrowest scope set the
   workspace actually needs (`read`, plus `write` and/or `send` only if
   agents must create drafts or send messages). The AS-advertised scope
   this catalog entry pins is `feature:mcp`; the read/write/send split is
   configured on the Front side per app, not passed as an OAuth scope
   string.
7. Save. Front shows the **Client ID** and **Client secret** on the OAuth
   feature settings page.
8. Copy both into `FRONT_MCP_OAUTH_CLIENT_ID` / `FRONT_MCP_OAUTH_CLIENT_SECRET`.

Source: [Front MCP Server docs](https://dev.frontapp.com/docs/mcp-server),
[Front OAuth docs](https://dev.frontapp.com/docs/oauth).

---

## Crunchbase

- **MCP endpoint:** `https://mcp.crunchbase.com/mcp`
- **Authorization server:** `https://www.crunchbase.com` (authorization
  endpoint `https://www.crunchbase.com/oauth/authorize`, token endpoint
  `https://oauth.crunchbase.com/token`)
- **Scopes to request:** `offline_access`, `lists.read`

**This one is not self-service.** Unlike the other four vendors above,
Crunchbase does not publish a developer console where you can create an
OAuth app and get a client id back immediately. Crunchbase gates API (and
by extension MCP) access behind an Enterprise/Applications license, and
the OAuth client has to be issued by Crunchbase's own team.

**Registration steps:**

1. Contact Crunchbase, either through the workspace's existing Crunchbase
   account representative, or via the API sales form at
   [about.crunchbase.com/products/crunchbase-api](https://about.crunchbase.com/products/crunchbase-api).
2. Request an OAuth client for the hosted MCP server (`mcp.crunchbase.com`),
   explicitly naming the redirect URI above and the two scopes
   (`offline_access`, `lists.read`).
3. Crunchbase's AS metadata lists both `client_secret_post` and `none` as
   supported token-endpoint auth methods, so ask for a confidential client
   (with a secret) to match this catalog entry's `client_secret_env`
   field. If Crunchbase only issues a public client, drop
   `client_secret_env` from `tools/crunchbase/SERVER.md` before use.
4. Once issued, set the client id and secret into
   `CRUNCHBASE_MCP_OAUTH_CLIENT_ID` / `CRUNCHBASE_MCP_OAUTH_CLIENT_SECRET`.

Source: [Crunchbase API](https://about.crunchbase.com/products/crunchbase-api),
[Using the API](https://data.crunchbase.com/docs/using-the-api). No
official Crunchbase documentation for the hosted MCP server's OAuth setup
was found publicly as of 2026-07-21; confirm the current process with
Crunchbase directly before relying on the steps above.

---

## Verifying a registration worked

After setting the env vars and deploying, the standard MCP OAuth
diagnostic path applies: try **Connect account** on the tile from a
workspace, and if the authorize redirect 400s or the callback errors,
check core-api logs for the `mcp-generic-oauth` handler. A `resolveClientId`
returning empty means the env var name in `SERVER.md` doesn't match what
was actually set (see the field names in the auth block of each
`SERVER.md` above; they must match exactly, including case).
