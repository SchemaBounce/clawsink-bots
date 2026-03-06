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

## Available Servers

| Server | Description | Transport | Key Tools |
|--------|-------------|-----------|-----------|
| [github](github/) | GitHub API for issues, PRs, repos, and actions | stdio | `create_issue`, `create_pull_request`, `search_code` |
| [slack](slack/) | Slack workspace messaging and channels | stdio | `slack_post_message`, `slack_search_messages`, `slack_list_channels` |
| [stripe](stripe/) | Stripe payments, billing, and subscriptions | stdio | `stripe_list_customers`, `stripe_list_invoices`, `stripe_create_refund` |
