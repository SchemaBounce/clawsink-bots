# MCP Servers

MCP (Model Context Protocol) servers are standalone processes that expose tools to bots via the MCP protocol. This directory contains server definitions that bots and teams can reference to declare tool dependencies beyond the standard ADL toolset.

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

1. `SERVER.md` has valid YAML frontmatter with `kind: McpServer`
2. `metadata.name` matches the directory name under `tools/`
3. `transport.type` is one of: `stdio`, `sse`, `streamable-http`
4. `transport.command` is present when type is `stdio`
5. `transport.url` is present when type is `sse` or `streamable-http`
6. All `env[].name` are UPPERCASE_SNAKE_CASE
7. No `env` entries contain actual secret values
8. All `tools[].name` are unique within the server
9. All bot `mcpServers[].ref` point to valid `tools/` directories
10. All team `mcpServers[].ref` point to valid `tools/` directories

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
| [codex](codex/) | Sandboxed OpenAI Codex sessions for implementation and PRs (managed, credit-billed) | streamable-http |
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
