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
  instructions: |        # Operating rules → injected as AGENTS.md in runtime
    ## Operating Rules
    - Rule 1: domain-specific behavioral rule
    - Rule 2: what to always do before acting
    - Rule 3: escalation criteria
  toolInstructions: |    # Tool conventions → injected as TOOLS.md in runtime
    ## Tool Usage
    - Use adl_query_records with entity_type="x" for lookups
    - Write findings with adl_upsert_record to entity_type="x_findings"
    - Store unstructured analysis with adl_add_memory
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

## Bootstrap Instructions (`agent.instructions` + `agent.toolInstructions`)

The `agent:` block contains two fields that become the bot's runtime system prompt sections:

| Field | Runtime Section | Purpose |
|-------|----------------|---------|
| `agent.instructions` | **AGENTS.md** | Operating rules, guardrails, escalation criteria, cross-bot coordination |
| `agent.toolInstructions` | **TOOLS.md** | Tool usage conventions, entity type patterns, memory namespace rules |

Both are YAML multiline strings (`|`) nested inside the `agent:` block. They are injected into every agent run alongside SOUL.md and IDENTITY.md.

### Writing Good Instructions

- 5-10 bullet points covering ALWAYS/NEVER rules specific to this bot's domain
- Reference actual entity types from `data.entityTypesRead` and `data.entityTypesWrite`
- Reference actual memory namespaces from `data.memoryNamespaces`
- Reference actual messaging targets from `messaging.sendsTo`
- Include escalation criteria: when to alert vs. log as finding
- Include token budget awareness if the bot has expensive analysis patterns

### Writing Good Tool Instructions

- Which entity types to query with `adl_query_records` and their filter patterns
- Which entity types to write with `adl_upsert_record` and their ID format conventions
- When to use `adl_add_memory` (unstructured) vs `adl_write_memory` (structured)
- When to use `adl_semantic_search` vs `adl_query_records`
- Batch operation preferences (`bulk_upsert` for >3 records)
- Memory namespace conventions from `data.memoryNamespaces`

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

## SOUL.md — Agent Identity Specification

### Purpose

SOUL.md defines WHO the agent is -- personality, expertise, decision-making authority, and communication style. It is the LLM system prompt, injected every turn. It is NOT instructions (those go in BOT.md `agent.instructions` which becomes AGENTS.md) and NOT tool usage conventions (those go in BOT.md `agent.toolInstructions` which becomes TOOLS.md).

### Architecture Context

OpenClaw injects bootstrap files into every LLM call:

| File | Source | Purpose |
|------|--------|---------|
| **SOUL.md** | `bots/{name}/SOUL.md` | System prompt (identity, personality, expertise) |
| **AGENTS.md** | BOT.md `agent.instructions` | Operating instructions |
| **TOOLS.md** | BOT.md `agent.toolInstructions` | Tool conventions |
| **IDENTITY.md** | Generated from BOT.md metadata | Lightweight metadata (name, emoji, vibe) |
| **USER.md** | Workspace user profile | User profile (injected in main session only) |

SOUL.md is for IDENTITY. AGENTS.md is for INSTRUCTIONS. Never mix them.

### Required Sections

```markdown
# {Display Name}

I am {Name}, the {role descriptor} for {domain/context}.

## Mission
{One compelling sentence about WHY this role exists -- the outcome, not the task}

## Expertise
{2-3 sentences about deep domain knowledge. What does this agent understand
that others don't? What patterns does it recognize? What connections does it make?}

## Decision Authority
- I decide: {what this agent handles autonomously -- scoring, prioritization, classification}
- I escalate: {what requires human judgment or cross-team coordination}

## Communication Style
{How this agent communicates -- tone, format, emphasis. What it never does.
How it frames recommendations.}
```

### Rules

1. **First person**: Always "I am", never "You are"
2. **Under 800 tokens**: Injected every LLM turn, tokens cost money
3. **No tool references**: Never mention `adl_query_records`, `adl_write_memory`, etc. -- those belong in TOOLS.md
4. **No entity type lists**: Never list `entityTypesRead/Write` -- those belong in BOT.md `data` section
5. **No run protocols**: Never write "Step 1: Query records, Step 2: Analyze..." -- those belong in AGENTS.md
6. **No memory namespace lists**: Never list working_notes, learned_patterns, etc.
7. **Domain knowledge YES**: Scoring thresholds, decision frameworks, industry rules ARE identity ("I require p < 0.05 before declaring a winner")
8. **Personality YES**: Preferences, style, what the agent cares about ARE identity ("I never round numbers" or "I lead with the one thing that matters most")

### Anti-Patterns

**BAD** -- instructions masquerading as identity:

```markdown
You are Accountant, a persistent AI team member responsible for financial tracking.

## Mandates
1. Always categorize transactions
2. Check for duplicates
3. Run budget comparison

## Entity Types
- Read: transactions, invoices, budgets
- Write: acct_findings

## Run Protocol
1. adl_read_memory key "last_run"
2. adl_query_records entity_type="transactions"
3. Process and categorize
4. adl_write_memory updated timestamp
```

Problems: "You are" instead of "I am". Mandates are instructions (belong in AGENTS.md). Entity Types are data declarations (belong in BOT.md). Run Protocol is a step-by-step procedure with tool names (belongs in AGENTS.md/TOOLS.md).

**GOOD** -- identity-focused:

```markdown
# Accountant

I am the Accountant, the financial guardian of this business.

## Mission
Provide financial clarity that enables good decisions -- every transaction tells a story, every anomaly is a clue.

## Expertise
I categorize with precision, budget with discipline, and flag fraud with urgency. I understand that a duplicate invoice is not just a clerical error -- it is a control failure. I know the difference between a seasonal spending pattern and a budget breach.

## Decision Authority
- I decide: categorization, budget threshold alerts, anomaly flagging with deviation percentages
- I escalate: payment failures, billing system errors, suspected fraud patterns

## Communication Style
Precise, factual, and structured. I report in percentages and deviations, not adjectives. I never round, never guess, and never let an uncategorized transaction sit overnight.
```

### Relationship to Scheduled Tasks

SOUL.md defines HOW the agent works (personality, expertise). Scheduled tasks (BOT.md `schedule.tasks[]`) define WHAT the agent does and WHEN. The SOUL provides the consistent identity across all tasks -- a Guest Communicator checking Airbnb uses the same warm hospitality tone as when checking Facebook.

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
2. `SOUL.md` exists and is under 800 tokens (~600 words)
3. `SOUL.md` contains required sections: Mission, Expertise, Decision Authority, Communication Style
4. `SOUL.md` uses first person ("I am") not second person ("You are")
5. `SOUL.md` contains no tool references, entity type lists, run protocols, or memory namespace lists (those belong in AGENTS.md/TOOLS.md/BOT.md)
6. `data-seeds/` contains all three zone files with valid JSON
7. `data-seeds/zone3-initial-memory.json` uses plain namespaces (NOT `northstar:` or `domain:` prefixed)
8. `metadata.name` matches the directory name under `bots/`
9. All `skills[].ref` reference existing skill directories with matching versions
10. All `messaging.sendsTo[].to` reference valid bot names or system targets
11. `data.entityTypesWrite` includes a `{abbrev}_findings` entry
12. `agent.instructions` is present and contains domain-specific operating rules (not generic boilerplate)
13. `agent.toolInstructions` is present and references actual entity types from `data.entityTypesRead` / `data.entityTypesWrite`
14. `egress` block is present with an explicit `mode` value
15. All files in `agents/` have valid YAML frontmatter with `name` and `description`
16. Agent `name` matches the filename (e.g., `researcher.md` -> `name: researcher`)
17. Agent `tools` only references valid ADL tool names
18. All `plugins[].ref` are valid npm package specs (name + semver range)
19. All `plugins[].reason` are non-empty strings
20. No `plugins[].config` values contain secrets (no fields named `password`, `secret`, `token`, `apiKey`)
21. All `mcpServers[].ref` reference valid `tools/` directories containing `SERVER.md`
22. All `mcpServers[].reason` are non-empty strings
23. No `mcpServers[].config` values contain secrets

## What the Platform Does

| You Provide | The Platform Will |
|-------------|-------------------|
| `SOUL.md` | Use it as the bot's identity (system prompt section `# SOUL.md`) on every run |
| `agent.instructions` | Inject as `# AGENTS.md` section — operating rules and guardrails |
| `agent.toolInstructions` | Inject as `# TOOLS.md` section — tool usage conventions |
| `skills[].ref` | Append each skill's `prompt.md` to the bot's instructions |
| `data-seeds/` (3 zone files) | Bootstrap the bot's data — North Star keys, entity schemas, and initial memory |
| `plugins[].ref` | Install and configure each plugin in the bot's runtime environment |
| `mcpServers[].ref` | Make the declared MCP server tools available to the bot |
| `egress` | Configure the bot's external network access policy (proxy token allowlist) |
| `schedule.default` | Run the bot on the declared schedule (user can adjust) |
| `trigger` | Run the bot in response to data change events on the declared entity type |
| `messaging` | Connect the bot to the message system so it can communicate with other bots |
| `agents/*.md` | Make sub-agents available for the bot to spawn during its runs |
| `model.preferred` / `fallback` | Select the LLM the bot uses |

Every field you declare gets acted on. Don't declare plugins or MCP servers the bot doesn't actually use. Data seeds are merged non-destructively. Skills are composed in the order listed.

## Canonical Example

See [`blog-writer/`](blog-writer/) for a complete bot with sub-agents, plugins, full SOUL.md, and data seeds.
