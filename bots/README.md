# Bots

A Bot is a complete agent definition with identity, model, schedule, messaging, and composed skills. Bots are always top-level agents — they are the unit of deployment and execution.

**Relationship to Teams**: Bots are grouped into teams via `bots[].ref: "bots/{name}@{version}"` in TEAM.md. See [teams/README.md](../teams/README.md) for team composition.

**Relationship to Skills**: Bots compose skills via `skills[].ref: "skills/{name}@{version}"`. Each skill's `prompt.md` is appended to the bot's system prompt. See [skills/README.md](../skills/README.md) for the skill format.

**Relationship to Plugins**: Bots declare plugin dependencies via `plugins[].ref`. See [plugins/README.md](../plugins/README.md) for the plugin ecosystem.

**Relationship to MCP Servers**: Bots declare MCP server dependencies via `mcpServers[].ref`. See [tools/README.md](../tools/README.md) for the MCP server format.

## Directory Structure

```
bots/{bot-name}/
├── BOT.md            # Manifest (kind: Bot) — YAML frontmatter parsed by marketplace
├── SOUL.md           # Agent identity document (<800 tokens)
├── agents/           # Sub-agent definitions (optional, Claude Code format)
│   ├── researcher.md
│   ├── writer.md
│   └── editor.md
└── data-seeds/       # Bootstrap data for ADL zones
    ├── zone1-north-star.json
    ├── zone2-entity-types.json
    └── zone3-initial-memory.json
```

## BOT.md Format

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: string           # Kebab-case identifier, unique across all bots
  displayName: string    # Human-readable name
  version: string        # SemVer (e.g., "1.0.0")
  description: string    # One-line description (<120 chars)
  category: string       # One of: operations, engineering, finance, support, legal, marketing, management
  tags: [string]         # Searchable tags
agent:
  capabilities: [string] # OpenClaw capability identifiers
  hostingMode: string    # "openclaw" (managed) or "self-hosted"
  defaultDomain: string  # ADL domain this bot operates in
model:
  provider: string       # "anthropic" or "openai"
  preferred: string      # Model ID for normal runs
  fallback: string       # Model ID if preferred unavailable
  thinkLevel: null | string  # null, "low", "medium", "high"
cost:
  estimatedTokensPerRun: int    # Typical token consumption per run
  estimatedCostTier: string     # "low", "medium", or "high"
schedule:
  default: string        # Cron expression or @every interval
  recommendations:
    light: string
    standard: string
    intensive: string
messaging:
  listensTo:
    - type: string       # Message type: alert, request, finding, text
      from: [string]     # Bot names or ["*"] for all
  sendsTo:
    - type: string
      to: [string]
      when: string       # Human-readable trigger condition
data:
  entityTypesRead: [string]
  entityTypesWrite: [string]
  memoryNamespaces: [string]
zones:
  zone1Read: [string]    # North Star keys this bot reads
  zone2Domains: [string] # Shared domains this bot accesses
skills:                  # Skill composition
  - ref: string          # Reference to shared skill: "skills/{name}@{version}"
plugins:                 # OpenCLAW plugin dependencies (optional)
  - ref: string          # npm package + version: "{name}@{version}"
    slot: string         # Plugin slot if exclusive (e.g., "memory", "channel")
    required: boolean    # true (default) = bot won't start without it
    reason: string       # Why this bot needs this plugin
    config: object       # Bot-specific config (merged with workspace defaults)
mcpServers:              # Custom MCP servers this bot requires (optional)
  - ref: string          # Reference: "tools/{server-name}"
    required: boolean    # true (default) = bot won't start without it
    reason: string       # Why this bot needs this server
    config: object       # Bot-specific config overrides (no secrets)
egress:                  # External network access policy (optional)
  mode: string           # "open" | "llm-only" | "restricted" | "none" (default: llm-only)
  allowedDomains:        # Only used when mode is "restricted"
    - string             # Exact domain or wildcard: "api.stripe.com", "*.github.com"
requirements:
  minTier: string        # Minimum workspace tier
---

# {Display Name}

Extended documentation here. Renders as the bot's marketplace page.
```

## Skills Section

The `skills:` section lists capabilities this bot uses:

- `ref: "skills/{skill-name}@{version}"` — references a shared skill from the `skills/` directory. The skill's `prompt.md` is appended to the bot's SOUL.md at runtime.

Skills are composed in the order listed. SOUL.md always comes first in the final system prompt.

## Plugins Section

The `plugins:` section declares OpenCLAW plugin dependencies — npm-based TypeScript modules that extend the runtime with channels, memory backends, OAuth managers, tools, and background services.

### Plugin Categories

| Category | Slot | Examples | What It Adds |
|----------|------|----------|-------------|
| **Channel** | `channel` | `microsoft-teams`, `voice-call`, `wacli` | Messaging channels (Teams, phone, WhatsApp) |
| **Memory** | `memory` | `memory-lancedb`, `memos-cloud` | Vector recall, cross-agent memory |
| **OAuth** | `oauth` | `composio` | Managed OAuth for 860+ apps |
| **Workflow** | — | `n8n-workflow` | External workflow orchestration |
| **Workspace** | — | `gog` | Google Workspace (Gmail, Calendar, Drive, Docs) |

Plugins with a `slot` are exclusive — only one plugin per slot loads at a time.

### Plugin Field Rules

- `plugins[].ref` must be a valid npm package spec (name + semver range)
- `plugins[].reason` is required and non-empty — explain why, not just what
- `plugins[].config` must NEVER contain secrets (API keys, tokens, passwords) — those go in workspace secrets
- `plugins[].slot` should match OpenCLAW's slot taxonomy when the plugin is exclusive
- `plugins[].required` defaults to `true` — set to `false` for nice-to-have plugins

### Example

```yaml
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    reason: "Managed OAuth for blog API — handles token refresh and scoping"
    config:
      apps: ["blog"]
      scopes: ["blog:write"]
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    reason: "Vector recall for editorial history and topic research across runs"
```

## MCP Servers Section

The `mcpServers:` section declares MCP server dependencies. See [tools/README.md](../tools/README.md) for the full SERVER.md format and transport types.

- `ref` must point to a valid `tools/` directory containing a `SERVER.md`
- `required` defaults to `true` — the bot won't start without this server
- `config` is merged with team-level config (bot overrides team)
- `config` must NEVER contain secrets

## Egress Section

The `egress:` section declares which external HTTPS endpoints the bot needs to reach via the proxy token system (`request_proxy_token` → `execute_proxy_call`). When a bot is deployed to a seat, the `egress` section auto-populates the seat's `manifest.egressPolicy`. The admin can override it per-seat.

- `mode` defaults to `llm-only` (no proxy calls allowed, LLM calls via ClawShell still work)
- `open` allows the agent to reach any public HTTPS endpoint
- `restricted` limits the agent to only the domains listed in `allowedDomains`
- `none` blocks all external access (both proxy calls and direct HTTP)
- Wildcard domains: `*.stripe.com` matches `sub.stripe.com` but NOT `stripe.com.evil.tld`

```yaml
egress:
  mode: restricted
  allowedDomains:
    - "api.stripe.com"
    - "*.github.com"
    - "hooks.slack.com"
```

## SOUL.md Format

The agent's identity document. Injected as system context on every run. Keep under 800 tokens.

### Required Sections

```markdown
# {Display Name}

You are {Display Name}, a persistent AI team member for this business.

## Mission
{One sentence defining the bot's core purpose}

## Mandates
1. {First mandatory behavior — executed every run}
2. {Second mandatory behavior}
3. {Third mandatory behavior}

## Run Protocol
1. Read messages (adl_read_messages)
2. Read memory (adl_read_memory, namespace="working_notes")
3. Query data (adl_query_records, entity_type="{relevant_types}")
4. Analyze and act
5. Write findings (adl_write_record, entity_type="{role}_findings")
6. Update memory (adl_write_memory)
7. Message relevant bots (adl_send_message) if escalation needed

## Entity Types
- Read: {comma-separated list}
- Write: {role}_findings, {role}_alerts

## Sub-Agent Workflow (if applicable)
{Describe the orchestration flow between sub-agents.
Each sub-agent is defined in agents/*.md with its own system prompt.
The parent bot spawns them via sessions_spawn and orchestrates the pipeline.}

## Escalation
- Critical: message executive-assistant type=alert
- Cross-domain: message {relevant-bot} type=finding
```

## Sub-Agents (`agents/` directory)

Bots can define sub-agents as markdown files in an `agents/` directory. Sub-agents are internal to the bot — other bots and teams never interact with them directly. The parent bot orchestrates them via `sessions_spawn`.

### Agent File Format

```markdown
---
name: string            # Kebab-case identifier, unique within this bot
description: string     # When the parent bot should spawn this sub-agent
model: string           # "haiku", "sonnet", "opus", or "inherit" (default: inherit)
tools: [string]         # ADL tools this sub-agent can use (default: all except session tools)
---

{System prompt in markdown — this is the sub-agent's identity and instructions}
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (kebab-case, matches filename without `.md`) |
| `description` | Yes | When the parent bot should delegate to this sub-agent |
| `model` | No | Model override: `haiku`, `sonnet`, `opus`, or `inherit` (default: `inherit`) |
| `tools` | No | Tool allowlist. Inherits all ADL tools except session tools if omitted |

### When to Use Sub-Agents vs Skills

| Use Case | Use a Skill | Use a Sub-Agent |
|----------|-------------|-----------------|
| Simple, sequential step | Yes | No |
| Needs its own isolated session | No | Yes |
| Validates another agent's output | No | Yes |
| Reusable across many bots | Yes | No |
| Requires different model/think level | No | Yes |
| Workflow with quality gates | No | Yes |

## Data Seeds Format

### zone1-north-star.json

Role-specific North Star key supplements. Merged non-destructively with the workspace's existing North Star data.

```json
{
  "seeds": [
    {
      "key": "string",
      "value": "string",
      "description": "string (optional)"
    }
  ]
}
```

### zone2-entity-types.json

Entity type definitions this bot creates and depends on.

```json
{
  "entityTypes": [
    {
      "name": "string",
      "description": "string",
      "sampleFields": ["string"]
    }
  ]
}
```

### zone3-initial-memory.json

Bootstrap private memory entries.

```json
{
  "memories": [
    {
      "namespace": "string",
      "key": "string",
      "value": "string"
    }
  ]
}
```

## Field Rules

- `metadata.name` must match the directory name under `bots/`
- `model.preferred` should use lighter models for routine tasks, more capable models for analytical tasks
- `cost.estimatedCostTier` is derived from model choice + schedule frequency
- `cost.estimatedTokensPerRun` is the typical token consumption per invocation (not a hard limit)
- `schedule.default` must be a valid cron expression or `@every` / `@daily` / `@weekly` interval
- `messaging.listensTo[].from` uses bot `metadata.name` values or `["*"]`
- `data.entityTypesWrite` must include `{abbrev}_findings` as a convention
- `agent.capabilities` should use values from the standard taxonomy: `operations`, `dev_devops`, `finance`, `analytics`, `customer_support`, `content_marketing`, `legal_compliance`, `management`, `research`, `data_engineering`, `procurement`, `security`

## Validation

1. `BOT.md` has valid YAML frontmatter with `kind: Bot` and all required fields
2. `SOUL.md` exists and is under 800 tokens
3. `data-seeds/` contains all three zone files with valid JSON
4. `metadata.name` matches the directory name
5. All `skills[].ref` reference existing skill directories with matching versions
6. All `messaging.sendsTo[].to` reference valid bot names or system targets
7. `data.entityTypesWrite` includes a `{abbrev}_findings` entry
8. All files in `agents/` have valid YAML frontmatter with `name` and `description`
9. Agent `name` matches the filename (e.g., `researcher.md` -> `name: researcher`)
10. Agent `tools` only references valid ADL tool names
11. All `plugins[].ref` are valid npm package specs (name + semver range)
12. All `plugins[].reason` are non-empty strings
13. No `plugins[].config` values contain secrets (no fields named `password`, `secret`, `token`, `apiKey`)
14. All `mcpServers[].ref` reference valid `tools/` directories containing `SERVER.md`
15. All `mcpServers[].reason` are non-empty strings
16. No `mcpServers[].config` values contain secrets

## What the Platform Does

| You Provide | The Platform Will |
|-------------|-------------------|
| `SOUL.md` | Use it as the bot's identity on every run |
| `skills[].ref` | Append each skill's `prompt.md` to the bot's instructions |
| `data-seeds/` (3 zone files) | Bootstrap the bot's data — North Star keys, entity schemas, and initial memory |
| `plugins[].ref` | Install and configure each plugin in the bot's runtime environment |
| `mcpServers[].ref` | Make the declared MCP server tools available to the bot |
| `schedule.default` | Run the bot on the declared schedule (user can adjust) |
| `trigger` | Run the bot in response to data change events on the declared entity type |
| `messaging` | Connect the bot to the message system so it can communicate with other bots |
| `agents/*.md` | Make sub-agents available for the bot to spawn during its runs |
| `model.preferred` / `fallback` | Select the LLM the bot uses |

Every field you declare gets acted on. Don't declare plugins or MCP servers the bot doesn't actually use. Data seeds are merged non-destructively. Skills are composed in the order listed.

## Canonical Example

See [`blog-writer/`](blog-writer/) for a complete bot with sub-agents, plugins, full SOUL.md, and data seeds.
