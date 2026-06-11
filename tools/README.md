# MCP Servers

MCP (Model Context Protocol) servers are standalone processes that expose tools to bots via the MCP protocol. This directory contains server **definitions** (declarations) that bots and teams reference to declare tool dependencies beyond the standard ADL toolset.

> ## ⚠️ Definitions only — and moving to `server.json`
>
> A file here is a **declaration** of an MCP server (transport + source + auth +
> env + tools), NOT the server itself. **The mcp-gateway is the only execution
> surface:** a `stdio` server runs as a child process INSIDE the gateway pod
> (source = `npm` via `npx`, `pypi` via `uvx`, or `github` = a pinned,
> checksum-verified release binary pulled into the gateway's source cache); a
> `remote` server runs elsewhere and the gateway connects to its `url` (e.g.
> exa). No per-session containers, nothing baked into the gateway image.
>
> The manifest format is migrating from `SERVER.md` (markdown frontmatter) to
> **`server.json`** (machine-parseable, same `McpServerDef` schema). That same
> JSON is what a customer submits to host their own MCP. **New servers: write
> `server.json`, not `SERVER.md`.** Authoritative rule:
> `core-api/.claude/rules/mcp-server-hosting.md`.

**Relationship to Bots**: Bots declare MCP server dependencies via `mcpServers[].ref: "tools/{name}"` in BOT.md. See [bots/README.md](../bots/README.md) for the bot manifest format.

**Relationship to Teams**: Teams declare shared MCP server instances via `mcpServers[]` in TEAM.md. See [teams/README.md](../teams/README.md) for team-level sharing.

## MCP Servers vs Plugins

MCP servers and plugins serve different purposes:

| | MCP Servers | Plugins |
|---|---|---|
| **What** | Standalone processes providing tools via MCP protocol | npm-based TypeScript modules extending the OpenCLAW runtime |
| **How they run** | Separate process (stdio, SSE, or streamable HTTP transport) | Loaded into the OpenCLAW runtime process |
| **What they provide** | Tools (callable functions with schemas) | Channels, memory backends, OAuth, workflows |
| **Where defined** | `tools/{server-name}/SERVER.md` | Declared in `plugins:` section of BOT.md or TEAM.md |
| **Lifecycle** | Started on demand when a bot that references it runs | Installed via `openclaw plugins install` |
| **Examples** | GitHub API, Slack API, Stripe API | composio (OAuth), memory-lancedb (vector recall), microsoft-teams (channel) |

In short: plugins extend the runtime itself (new memory backends, new communication channels), while MCP servers provide external API tools that bots call during execution.

## Standard ADL Tools

Every bot automatically has access to the standard ADL tool set. These do NOT require an MCP server declaration:

- `adl_query_records` -- Query records by entity type
- `adl_write_record` -- Write or update a record
- `adl_read_memory` -- Read from private memory
- `adl_write_memory` -- Write to private memory
- `adl_read_messages` -- Read incoming messages
- `adl_send_message` -- Send message to another bot
- `adl_search` -- Semantic search across records

MCP servers supplement these with domain-specific tools (GitHub issues, Slack messages, Stripe payments, etc.).

## How Bots Reference MCP Servers

Bots declare MCP server dependencies in their `BOT.md` manifest under `mcpServers:`:

```yaml
mcpServers:
  - ref: "tools/github"
    required: true
    reason: "Creates GitHub issues from bug triage findings"
    config:
      default_org: "acme-corp"
```

- `ref` points to a directory under `tools/` containing a `SERVER.md`
- `required` defaults to `true` -- the bot will not start without this server
- `reason` explains why the bot needs this server (required, non-empty)
- `config` provides bot-specific configuration overrides (never secrets)

## How Teams Share MCP Servers

Teams declare shared MCP server instances in their `TEAM.md` under `mcpServers:`:

```yaml
mcpServers:
  - ref: "tools/github"
    reason: "Engineering bots need GitHub access for code review, issue tracking, and releases"
    config:
      default_org: "acme-corp"
```

A team-level declaration creates a **single shared instance** of the MCP server for all bots in the team. This avoids spinning up duplicate processes. Individual bots can override `config` in their own `mcpServers:` section -- bot config is merged on top of team config.

## SERVER.md Format

Each MCP server is defined in `tools/{server-name}/SERVER.md` with YAML frontmatter (`kind: McpServer`) followed by a markdown documentation body.

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: string           # Kebab-case, matches directory name
  displayName: string    # Human-readable name
  version: string        # SemVer
  description: string    # One-line description (<120 chars)
  tags: [string]
  author: string
  license: string
transport:
  type: string           # "stdio" | "sse" | "streamable-http"
  command: string        # For stdio: command to run (e.g., "npx")
  args: [string]         # For stdio: command arguments
  url: string            # For sse/http: server URL template
env:                     # Required environment variables (names only, NEVER values)
  - name: string         # UPPERCASE_SNAKE_CASE variable name
    description: string  # What this variable is for
    required: boolean
tools:                   # Tools this server provides (declarative listing)
  - name: string         # Tool name as exposed via MCP
    description: string  # What this tool does
    category: string     # Grouping for UI display
---

Documentation body renders as the server's marketplace page.
```

### Transport Types

- **stdio**: The runtime starts the MCP server as a child process and communicates over stdin/stdout. Most common for npm-packaged servers. Requires `command` and `args`.
- **sse**: The runtime connects to a running server via Server-Sent Events. Requires `url`.
- **streamable-http**: The runtime connects via HTTP with streaming support. Requires `url`.

### Environment Variables

The `env` section declares what secrets the server needs but NEVER contains actual values. Users add the actual secrets to their workspace secrets store. The runtime injects them at startup.

### Tools Listing

The `tools` section is a declarative listing for marketplace display and dependency validation. The actual tool schemas (parameters, return types) come from the MCP server itself at runtime via the `tools/list` protocol method.

## Adding a New MCP Server

1. Create a directory under `tools/` with a kebab-case name:
   ```
   tools/my-server/
   └── SERVER.md
   ```

2. Write `SERVER.md` with valid YAML frontmatter (`kind: McpServer`) and a documentation body. See `tools/github/SERVER.md` for a complete example.

3. Ensure `metadata.name` matches the directory name.

4. List all required environment variables in `env` with descriptions. Never include actual secret values.

5. List the tools the server provides in `tools` with names, descriptions, and categories.

6. Reference the server from bot or team manifests:
   ```yaml
   mcpServers:
     - ref: "tools/my-server"
       reason: "Why this bot needs these tools"
   ```

7. Validate:
   - `kind: McpServer` is present in frontmatter
   - `transport.type` is one of: `stdio`, `sse`, `streamable-http`
   - `transport.command` exists when type is `stdio`; `transport.url` exists when type is `sse` or `streamable-http`
   - All `env[].name` are UPPERCASE_SNAKE_CASE with no actual values
   - All `tools[].name` are unique within the server
   - All bot/team `mcpServers[].ref` values point to valid `tools/` directories

## Validation

`tests/tools/validate-manifest.sh` enforces the full `McpServerDef` structural
contract on every manifest. Both `server.json` and `SERVER.md` are validated
when present; a malformed `server.json` fails CI even if a `SERVER.md` also exists.

1. `SERVER.md` has valid YAML frontmatter with `kind: McpServer`, OR `server.json` parses as valid JSON
2. `metadata.name` matches the directory name under `tools/`
3. `transport.type` is one of: `stdio`, `sse`, `streamable-http`
4. `transport.command` is present when type is `stdio`
5. `transport.url` is present when type is `sse` or `streamable-http`
6. All `env[].name` are UPPERCASE_SNAKE_CASE
7. No `env` entries contain actual secret values
8. All `tools[].name` are unique within the server
9. All bot `mcpServers[].ref` point to valid `tools/` directories
10. All team `mcpServers[].ref` point to valid `tools/` directories

**Cross-repo guard note:** This validator enforces structure only. First-party
manifest-to-binary parity (e.g. tool names declared in `tools/schemabounce/`
matching the tools the `schemabounce-mcp` binary actually exposes) cannot be
enforced here because the binary lives in a separate repo. That contract is
enforced by `TestToolsList_MatchesManifest` in the `schemabounce-mcp` repo's
CI. Do not add external binary invocations to this script.

## What the Platform Does

| You Provide | The Platform Will |
|-------------|-------------------|
| `transport.type` + `command`/`url` | Start the server using the declared transport method |
| `env[].name` | Resolve each variable from the workspace's secrets store (activation fails if required secrets are missing) |
| `tools[]` | Register the server's tools so bots can call them by name |

Never put secrets in SERVER.md — only declare variable names. Users configure actual values in their workspace settings.

## Available Servers (66 total)

### Engineering & DevOps

| Server | Description | Transport |
|--------|-------------|-----------|
| [github](github/) | GitHub API — issues, PRs, repos, and actions | stdio |
| [gitlab](gitlab/) | GitLab — projects, merge requests, issues, CI/CD | stdio |
| [sentry](sentry/) | Sentry error tracking — issues, events, releases | stdio |
| [playwright](playwright/) | Playwright browser automation and testing | stdio |
| [vercel](vercel/) | Vercel deployments, projects, and domains | stdio |
| [docker](docker/) | Docker container, image, and volume management | stdio |
| [terraform](terraform/) | Terraform IaC — plan, apply, state, workspaces | stdio |
| [kubernetes](kubernetes/) | Kubernetes cluster — pods, deployments, services | stdio |
| [codex](codex/) | **[Preview]** Sandboxed OpenAI Codex sessions — backend not yet deployed | streamable-http |
| [argocd](argocd/) | Argo CD GitOps — applications, sync, resources, logs | stdio |

### Platform (SchemaBounce + Kolumn)

| Server | Description | Transport |
|--------|-------------|-----------|
| [schemabounce](schemabounce/) | SchemaBounce platform — workspaces, pipelines, schemas, ADL | streamable-http |
| [kolumn](kolumn/) | Kolumn IaC — schema patterns, HCL generation, validation | streamable-http |

### Communications

| Server | Description | Transport |
|--------|-------------|-----------|
| [slack](slack/) | Slack workspace messaging and channels | stdio |
| [gmail](gmail/) | Gmail — send, read, search, organize messages | stdio |
| [twilio](twilio/) | Twilio SMS, voice calls, and messaging | stdio |
| [discord](discord/) | Discord bot — messages, channels, guilds | stdio |
| [microsoft-teams](microsoft-teams/) | Microsoft Teams — messages, channels, meetings | stdio |
| [google-meet](google-meet/) | Google Meet video conferencing | stdio |
| [zoom](zoom/) | Zoom meetings, webinars, and recordings | stdio |

### Finance & Accounting

| Server | Description | Transport |
|--------|-------------|-----------|
| [stripe](stripe/) | Stripe payments, billing, subscriptions | stdio |
| [quickbooks](quickbooks/) | QuickBooks Online — invoices, payments, expenses | stdio |
| [xero](xero/) | Xero accounting — invoices, contacts, reports | stdio |

### E-commerce

| Server | Description | Transport |
|--------|-------------|-----------|
| [shopify](shopify/) | Shopify — products, orders, inventory, customers | stdio |

### Project Management

| Server | Description | Transport |
|--------|-------------|-----------|
| [jira](jira/) | Jira project management and issue tracking | stdio |
| [linear](linear/) | Linear issue tracking and project management | stdio |
| [asana](asana/) | Asana — tasks, projects, teams, portfolios | sse |
| [todoist](todoist/) | Todoist — tasks, projects, labels | stdio (uvx) |

### Productivity & Docs

| Server | Description | Transport |
|--------|-------------|-----------|
| [notion](notion/) | Notion pages, databases, and wikis | stdio |
| [google-calendar](google-calendar/) | Google Calendar events and scheduling | stdio |
| [google-sheets](google-sheets/) | Google Sheets reading and writing | stdio |
| [google-docs](google-docs/) | Google Docs creation and editing | stdio |
| [confluence](confluence/) | Confluence wiki — pages, spaces, search | stdio |
| [airtable](airtable/) | Airtable — records, tables, bases | stdio |

### CRM & Sales

| Server | Description | Transport |
|--------|-------------|-----------|
| [salesforce](salesforce/) | Salesforce CRM — accounts, contacts, opportunities | sse |
| [hubspot](hubspot/) | HubSpot CRM — contacts, deals, companies | sse |
| [pipedrive](pipedrive/) | Pipedrive CRM — deals, contacts, activities | stdio |

### Customer Support

| Server | Description | Transport |
|--------|-------------|-----------|
| [zendesk](zendesk/) | Zendesk — tickets, users, knowledge base | stdio |
| [intercom](intercom/) | Intercom — conversations, contacts, articles | sse |
| [freshdesk](freshdesk/) | Freshdesk — tickets, contacts, agents | stdio |

### Monitoring & Observability

| Server | Description | Transport |
|--------|-------------|-----------|
| [firebase](firebase/) | Firebase — logs, analytics, Firestore, Auth | stdio |
| [datadog](datadog/) | Datadog — metrics, logs, traces, monitors | sse |
| [grafana](grafana/) | Grafana — dashboards, Prometheus queries, alerting | stdio |
| [pagerduty](pagerduty/) | PagerDuty — incidents, on-call, escalation | stdio |
| [prometheus](prometheus/) | Prometheus — PromQL queries, targets, alerts | stdio |

### Cloud Infrastructure

| Server | Description | Transport |
|--------|-------------|-----------|
| [aws](aws/) | AWS — EC2, S3, Lambda, RDS, 1000+ resources | stdio (uvx) |
| [aws-cloudwatch](aws-cloudwatch/) | AWS CloudWatch — logs, metrics, alarms | stdio (uvx) |
| [gcp](gcp/) | Google Cloud — Compute, Storage, BigQuery, GKE | stdio |
| [azure](azure/) | Microsoft Azure — VMs, storage, databases | stdio |

### Data & Databases

| Server | Description | Transport |
|--------|-------------|-----------|
| [postgres](postgres/) | PostgreSQL queries and schema inspection | stdio |
| [mysql](mysql/) | MySQL queries and schema inspection | stdio |
| [mongodb](mongodb/) | MongoDB queries, collections, aggregation | stdio |
| [redis](redis/) | Redis keys, hashes, lists, sets | stdio |
| [elasticsearch](elasticsearch/) | Elasticsearch search, indices, aggregations | stdio |
| [bigquery](bigquery/) | Google BigQuery SQL queries and datasets | sse |
| [snowflake](snowflake/) | Snowflake SQL queries and warehouses | stdio |

### Marketing

| Server | Description | Transport |
|--------|-------------|-----------|
| [mixpanel](mixpanel/) | Mixpanel — events, funnels, retention | stdio |
| [mailchimp](mailchimp/) | Mailchimp — campaigns, audiences, templates | stdio |

### Storage

| Server | Description | Transport |
|--------|-------------|-----------|
| [google-drive](google-drive/) | Google Drive files and folders | stdio |
| [dropbox](dropbox/) | Dropbox files, folders, sharing | sse |

### Agent Presence Servers

These servers give agents their own internet identity and presence. They work with the `presence:` section in BOT.md to automatically provision external identities on activation.

| Server | Description | Transport | Presence Type |
|--------|-------------|-----------|---------------|
| [agentmail](agentmail/) | Email identity — send, receive, manage email | stdio | `presence.email` |
| [hyperbrowser](hyperbrowser/) | Cloud browser — browse, scrape, automate the web | stdio | `presence.web.browsing` |
| [exa](exa/) | Semantic web search — embedding-based | stdio | `presence.web.search` |
| [firecrawl](firecrawl/) | Web crawling — fast data extraction | stdio | `presence.web.crawling` |
| [elevenlabs](elevenlabs/) | Voice and audio — TTS, STT, voice cloning, calls | stdio (uvx) | `presence.voice` |
| [composio](composio/) | SaaS gateway — 500+ integrations with managed OAuth | stdio | N/A |
| [agentphone](agentphone/) | Phone and SMS — provision numbers, texts, calls | stdio | `presence.phone` |

### Presence vs MCP Servers

The `presence:` section in BOT.md and the `mcpServers:` section serve complementary purposes:

| Concern | `presence:` | `mcpServers:` |
|---------|-------------|---------------|
| **What it does** | Declares identity to **provision** (email address, phone number) | Declares tools to **connect** (send_email, make_call) |
| **When it runs** | On bot activation — creates external accounts | On bot execution — starts MCP server process |
| **What it creates** | `agent_external_identities` record with lifecycle | `agent_mcp_grants` record with tool access |
| **Example** | "This bot needs an email address" | "This bot needs the send_email tool" |

A bot that needs email typically declares BOTH:

```yaml
presence:
  email:
    required: true
    provider: agentmail
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send and receive email for client communication"
```

### Auto-Provisioning Rules

| Capability | Auto-provision? | Admin approval? | Why |
|-----------|----------------|-----------------|-----|
| Email | Yes | No | Low cost, high value |
| Web browsing/search/crawling | Yes (no provisioning needed) | No | Just tool access |
| Voice | No | Yes | Recurring cost |
| Phone | No | Yes | Real phone number + cost |

### Note on ElevenLabs

ElevenLabs is the only **Python-based** MCP server. It requires `uvx` (from the `uv` package manager) instead of `npx`. The transport config uses `command: "uvx"` with `args: ["elevenlabs-mcp"]`.

---

# Credential Validation Specs (SchemaBounce #1614)

Each `SERVER.md` may optionally declare three additional YAML blocks that let SchemaBounce's generic validation engine in `core-api` verify the user's credentials against the upstream service and probe the upstream's reachability — without per-server Go code.

These blocks are **declarative**: an author specifies _what_ to call, _how to authenticate_, and _how to interpret the response_. The engine handles the HTTP mechanics, retries, timeouts, audit logging, and credential redaction.

## When to add a spec

| Server type | Add a spec? | Engine behavior without one |
|---|---|---|
| HTTPS SaaS API with a testable endpoint (GitHub, Notion, Stripe, …) | **Yes** | Connection sits at `health_state = 'unverified'` — orange badge "Saved — not yet verified". |
| Per-tenant HTTPS SaaS (Jira, Salesforce, Confluence) | **Yes** with URL template | same |
| Stdio-only MCP with no HTTPS API (Postgres, MongoDB, Filesystem, Playwright) | **No** | `'unverified'` — correct; upstream health verifies via the MCP gateway probe instead. |
| OAuth-managed service (Gmail, Google Calendar, Spotify) where token rotation lives elsewhere | **Not yet** | `'unverified'` — pending OAuth-refresh engine extension. |

## The three blocks

### `auth:` — how credentials reach the wire

Four shapes are supported. Choose the simplest one that matches the upstream's auth scheme.

**`http_bearer`** — single env var becomes the `Authorization: Bearer <token>` header. Most common shape.

```yaml
auth:
  type: http_bearer
  token_env: GITHUB_PERSONAL_ACCESS_TOKEN
```

**`api_key_header`** — single env var becomes the value of a named header. Custom header name (defaults to `X-API-Key`).

```yaml
auth:
  type: api_key_header
  token_env: EXA_API_KEY
  header_name: x-api-key
```

**`http_basic`** — two shapes:

```yaml
# Single-credential (key as username, blank password — Stripe pattern):
auth:
  type: http_basic
  token_env: STRIPE_API_KEY

# Two-credential (Jira / Confluence / Zendesk pattern):
auth:
  type: http_basic
  username_env: JIRA_EMAIL
  password_env: JIRA_API_TOKEN
```

**`injection`** — explicit header template for upstreams whose auth doesn't fit a shortcut (Linear uses a raw token in `Authorization` with no `Bearer` prefix). The `{ENV_NAME}` token is substituted with the credential value at request time. Credentials never appear in logs.

```yaml
auth:
  injection:
    header_name: Authorization
    header_template: "{LINEAR_API_KEY}"
```

Use `type: none` to declare "upstream has no auth" explicitly (rare).

### `validation:` — synchronous "are these credentials good?" check

Runs on connection-create and on Test Connection clicks. Bounded by `timeout_ms` (defaults to 10s).

```yaml
validation:
  request:
    method: GET
    url: https://api.github.com/user
    headers:
      Accept: application/vnd.github+json
  expect:
    status: 200
    extract:
      authenticated_as_field: login
  on_status:
    "401": { state: needs_setup, message: "GitHub rejected the token (401). Check the PAT value." }
    "403": { state: needs_setup, message: "Token lacks required scopes." }
    "default": { state: failed }
  timeout_ms: 5000
```

**Field rules:**

| Field | Required? | Notes |
|---|---|---|
| `request.method` | Yes | One of GET, POST, PUT, DELETE, PATCH, HEAD. |
| `request.url` | Yes | Absolute `https://` URL, OR a `{ENV_VAR}/path` template for per-tenant hosts. Resolved URL must still be https at runtime — engine refuses plain http. |
| `request.headers` | No | Map of header name → value. Values may contain `{ENV_VAR}` placeholders. |
| `request.body` | No | Verbatim request body. May contain `{ENV_VAR}` placeholders (useful for GraphQL queries with embedded fields). |
| `expect.status` | No (default 200) | The happy-path HTTP status code → engine returns `health_state = 'connected'`. |
| `expect.extract.authenticated_as_field` | No | Top-level JSON field whose value populates the audit log's "authenticated as" hint (e.g. GitHub's `login`, Jira's `displayName`). |
| `on_status` | No | Per-code outcome overrides. Keys are HTTP status code strings; the special key `"default"` matches anything else. State must be one of: `connected`, `needs_setup`, `failed`, `unverified`. |
| `timeout_ms` | No (default 10000) | Per-attempt timeout. Keep small; the engine is in the request path. |

**State semantics:**

- `connected` — green badge. Credentials work; upstream is reachable.
- `needs_setup` — orange badge. Engine can talk to the upstream but the credential was rejected (401/403). The user needs to fix their credential.
- `failed` — red badge. Network failure, 5xx, or an unmapped status code. Not the user's credential — usually a transient upstream issue or a real outage.
- `unverified` — orange "Saved — not yet verified" badge. Engine has no opinion. Only used when no `validation` block is declared OR no `on_status` entry matches AND there's no `default`.

### `healthProbe:` — periodic background health check

Identical shape to `validation` plus an `interval_seconds` field. Runs on the engine's scheduler, separate from user-triggered Test Connection clicks. Use this when:

- The upstream has a cheap idempotent endpoint that detects revoked tokens between user sessions.
- You want the connection card to update without a user click.

**Do NOT add `healthProbe` when:**

- The upstream's only viable validation endpoint consumes metered resources (Exa search burns ~1 credit per call → 288 credits/day at 5min cadence per workspace per connection).
- The upstream is rate-limited tightly (most public Twitter/X endpoints).

```yaml
healthProbe:
  request:
    method: GET
    url: https://api.github.com/rate_limit
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300            # 5min; minimum 30s, default 300s
```

## URL templating — per-tenant hosts

For services where the API host is per-tenant (Jira's customer Jira instance, Salesforce's instance URL, Mailchimp's server prefix), use `{ENV_VAR}` substitution in `request.url`:

```yaml
env:
  - { name: JIRA_URL, required: true }
  - { name: JIRA_EMAIL, required: true }
  - { name: JIRA_API_TOKEN, required: true, sensitive: true }

auth:
  type: http_basic
  username_env: JIRA_EMAIL
  password_env: JIRA_API_TOKEN

validation:
  request:
    method: GET
    url: "{JIRA_URL}/rest/api/3/myself"
    headers:
      Accept: application/json
  expect:
    status: 200
    extract:
      authenticated_as_field: displayName
  on_status:
    "401": { state: needs_setup, message: "Jira rejected the email/token combination (401)." }
    "403": { state: needs_setup, message: "Account lacks permission to read /myself (403)." }
    "default": { state: failed }
  timeout_ms: 5000
```

Same `{ENV_VAR}` syntax works in `request.headers` values and `request.body`.

## What the engine does NOT do (yet)

- **Body-level success checks.** APIs that return HTTP 200 with `{ok: false}` (Slack `auth.test`) or `{errors: [...]}` (Linear GraphQL) require body inspection. Engine extension pending.
- **AWS SigV4 / GCP service-account signing.** Cryptographic request signing isn't expressible declaratively yet. AWS/GCP MCP servers stay unverified for now.
- **OAuth refresh flows.** Tokens that expire and require refresh-token grants are handled by the existing OAuth subsystem, not this engine.
- **Nested JSON extraction.** `extract.authenticated_as_field` reads top-level fields only. Linear's `data.viewer.name` falls back to no hint.
- **Composite identity strings.** Slack's "bot: foo (team: bar)" pattern needs `extract.authenticated_as_template` (engine extension).
- **MCP-protocol probes.** Direct DB connections (Postgres, MongoDB) require MCP-side probes that run via the agent runtime, not this engine. Those probes live in `core-api/internal/handlers/mcp_probes.go` and remain authoritative for those servers.

## Security invariants

1. **No plain http.** Parse-time check requires `https://` or a `{template}` URL. Runtime check enforces `https://` after substitution. The only exception is loopback (`http://127.0.0.1` and `http://localhost`) for httptest fixtures.
2. **Credentials never appear in audit rows.** The engine's `sanitizeErr` bounds error message length and the audit log columns are typed (state enum + structured detail) — no free-form credential capture.
3. **Probe-interval floor.** Parse-time check requires `interval_seconds >= 30`. Sub-30s polling risks DoSing upstreams.
4. **Mark secrets `sensitive: true`.** The `env:` block's `sensitive` flag drives audit-log redaction. Always set it on API keys, tokens, and passwords.

## Testing your spec

Every spec is automatically exercised by the round-trip test framework at `core-api/schemabounce-api/internal/adl/mcp_validation_engine_roundtrip_test.go`. For each `tools/{name}/SERVER.md` that declares a `validation` block, the test:

1. **Happy path** — stubs the upstream returning `expect.status`; asserts engine returns `connected` and extracts the identity hint.
2. **Each `on_status` code** — stubs the upstream returning each declared status code; asserts engine returns the mapped state with the spec's message.
3. **Network failure** — points the engine at port 1 (refused); asserts engine returns `failed`.
4. **Missing credential** — supplies empty creds; asserts engine returns `needs_setup`.

Run it locally with:

```bash
cd /path/to/core-api/schemabounce-api
CLAWSINK_BOTS_PATH=/path/to/clawsink-bots \
  CGO_ENABLED=0 go test -count=1 -run='TestRoundTrip' -v ./internal/adl/...
```

CI runs this on every PR.

## Adding a spec — checklist

Before opening a PR with a new SERVER.md spec block:

- [ ] Read the upstream's API docs to confirm the validation endpoint's status-code semantics. `401` is the common "bad credential" code; some services use `403` (token lacks scope) or `200 + ok:false` (Slack — not yet supported).
- [ ] Confirm the endpoint is idempotent + cheap. No mutations, no metered resources unless explicitly opt-in.
- [ ] Set `sensitive: true` on every credential env var.
- [ ] Author `on_status` entries for at least `401`, `403`, and `"default"`. Concrete user-facing messages for each (e.g. "Check the PAT value", "Lacks required scopes").
- [ ] Decide whether to include `healthProbe`. Yes for free idempotent endpoints; no for metered/expensive ones.
- [ ] Make the URL https or `{TEMPLATE}`-prefixed. Parse-time enforcement will reject http.
- [ ] Run the round-trip test locally — it MUST pass for your new spec.

## Worked examples

See these merged SERVER.md files for canonical patterns:

| Pattern | Example | Why it's the canonical reference |
|---|---|---|
| Bearer + custom header | `tools/notion/SERVER.md` | Bearer auth with the upstream's required `Notion-Version` header carried in `request.headers`. |
| API-key custom header | `tools/exa/SERVER.md` | `api_key_header` with non-default `header_name: x-api-key`. Validation only — no healthProbe to avoid burning credits. |
| Bearer + extracted identity | `tools/github/SERVER.md` | Bearer + `extract.authenticated_as_field: login` for audit visibility. |

(Stripe, Jira, Confluence, Zendesk patterns land in the next batch using `http_basic`.)
