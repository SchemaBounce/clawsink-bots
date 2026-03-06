# ClawSink Bots Specification v2

This is the authoritative format specification for the composability model: **Skills**, **Bots** (with optional **Sub-Agents**), and **Teams**.

## Overview

The architecture uses three manifest kinds that compose hierarchically. ClawSink is an abstraction layer **above** agents — it defines what agents are, how they compose, and how they communicate. It does not sit between agents and the runtime.

| Kind | Directory | Purpose | Manifest File |
|------|-----------|---------|---------------|
| `Skill` | `skills/` | Reusable capability (single responsibility) | `SKILL.md` |
| `Bot` | `bots/` | Top-level agent definition (identity + skills + sub-agents) | `BOT.md` |
| `Team` | `teams/` | Coordinated bot group (shared North Star) | `TEAM.md` |

**Bots are always top-level agents.** Teams are groupings of bots. Sub-agents exist *within* a bot for internal workflow orchestration — they are never exposed outside the bot's scope.

```
Team (saas-growth)
 ├── Bot (executive-assistant)          ← top-level agent
 │    ├── Skill (daily-briefing)
 │    ├── Skill (cross-domain-synthesis)
 │    └── Skill (follow-up-tracking)
 ├── Bot (blog-writer)                  ← top-level agent
 │    ├── Skill (editorial-planning)    ← composed into SOUL.md
 │    ├── Sub-Agent (researcher)        ← isolated session, task string only
 │    ├── Sub-Agent (writer)            ← isolated session, task string only
 │    └── Sub-Agent (editor)            ← isolated session, task string only
 ├── Bot (accountant)                   ← top-level agent
 │    ├── Skill (invoice-categorization)
 │    ├── Skill (expense-tracking)
 │    └── Skill (budget-monitoring)
 └── ...
```

### Design Principles

1. **Bots own their sub-agents.** Sub-agents are internal implementation details — other bots and teams never interact with them directly. All inter-bot communication goes through the parent bot.
2. **Sub-agents have their own identity.** Each sub-agent is defined as a markdown file with YAML frontmatter and a system prompt body — the same format as Claude Code's `.claude/agents/`. They run in isolated sessions with their own context.
3. **Skills belong to the parent bot only.** Skills are composed into the parent bot's SOUL.md at runtime. Sub-agents get their identity from their own agent file, not from skills.
4. **Sub-agents validate each other's work.** The pattern enables quality gates within a single bot's workflow (e.g., a writer drafts, an editor reviews) without requiring cross-bot messaging.
5. **ClawSink sits above, not between.** The manifest layer defines agent identity, composition, and communication. The runtime (OpenCLAW) handles execution. ClawSink never intercepts agent-to-runtime calls.

---

## Skill Manifest (`SKILL.md`)

A Skill is a reusable capability that can be composed into multiple bots. Skills define WHAT to do, not WHO does it.

### Directory Structure

```
skills/{skill-name}/
├── SKILL.md          # Manifest with kind: Skill
└── prompt.md         # Skill-specific instructions (<200 tokens)
```

### SKILL.md Format

YAML frontmatter delimited by `---`, followed by markdown documentation.

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: string           # Kebab-case identifier, unique across all skills
  displayName: string    # Human-readable name
  version: string        # SemVer (e.g., "1.0.0")
  description: string    # One-line description (<120 chars)
  tags: [string]         # Searchable tags
  author: string         # Author or organization
  license: string        # License identifier
tools:
  required: [string]     # Subset of platform tools this skill needs
data:
  producesEntityTypes: [string]   # Entity types this skill writes
  consumesEntityTypes: [string]   # Entity types this skill reads
---
```

### prompt.md Format

A focused instruction block that gets appended to the bot's SOUL.md at runtime. Must be under 200 tokens. Starts with a `## {Skill Name}` heading and contains numbered steps.

```markdown
## Invoice Categorization

When processing invoices:
1. Query uncategorized invoices (entity_type="invoices", filter by missing category)
2. Classify each invoice: category, vendor, urgency
3. Flag duplicates by matching vendor + amount + date
4. Write categorization as acct_findings
```

### Field Rules

- `metadata.name` must match the directory name under `skills/`
- `tools.required` must be a subset of the platform's available tools
- `data.producesEntityTypes` must follow `{role_prefix}_findings` convention when writing findings
- Skills must NOT define identity, schedule, model, or messaging -- those belong to the Bot

---

## Bot Manifest (`BOT.md`)

A Bot is a complete agent definition with identity, model, schedule, messaging, and a composition of skills.

### Directory Structure

```
bots/{bot-name}/
├── BOT.md            # Manifest with kind: Bot
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

### BOT.md Format

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
  - inline: string       # Bot-specific skill (no shared definition)
plugins:                 # OpenCLAW plugin dependencies (optional)
  - ref: string          # npm package + version: "{name}@{version}"
    slot: string         # Plugin slot if exclusive (e.g., "memory", "channel")
    required: boolean    # true (default) = bot won't start without it
    reason: string       # Why this bot needs this plugin
    config: object       # Bot-specific config (merged with workspace defaults)
requirements:
  minTier: string        # Minimum workspace tier
---
```

### Skills Section

The `skills:` section lists capabilities this bot uses. Two formats:

- `ref: "skills/{skill-name}@{version}"` -- references a shared skill from the `skills/` directory. The skill's `prompt.md` is appended to the bot's SOUL.md at runtime.
- `inline: "{skill-name}"` -- a bot-specific capability that doesn't have a shared skill definition. Documented directly in the bot's SOUL.md.

### Plugins Section

The `plugins:` section declares OpenCLAW plugin dependencies — npm-based TypeScript modules that extend the runtime with channels, memory backends, OAuth managers, tools, and background services. Plugins are runtime code; skills are declarative instructions. Both are composable, but plugins require installation via `openclaw plugins install`.

This section replaces the legacy `externalApis:` field.

#### Plugin Categories

| Category | Slot | Examples | What It Adds |
|----------|------|----------|-------------|
| **Channel** | `channel` | `microsoft-teams`, `voice-call`, `wacli` | Messaging channels (Teams, phone, WhatsApp) |
| **Memory** | `memory` | `memory-lancedb`, `memos-cloud` | Vector recall, cross-agent memory |
| **OAuth** | `oauth` | `composio` | Managed OAuth for 860+ apps |
| **Workflow** | — | `n8n-workflow` | External workflow orchestration |
| **Workspace** | — | `gog` | Google Workspace (Gmail, Calendar, Drive, Docs) |

Plugins with a `slot` are exclusive — only one plugin per slot loads at a time (e.g., you can't run both `memory-lancedb` and `memos-cloud`).

#### Example

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

#### Field Rules

- `plugins[].ref` must be a valid npm package spec (name + semver range)
- `plugins[].reason` is required and non-empty — explain why, not just what
- `plugins[].config` must NEVER contain secrets (API keys, tokens, passwords) — those go in workspace secrets
- `plugins[].slot` should match OpenCLAW's slot taxonomy when the plugin is exclusive
- `plugins[].required` defaults to `true` — set to `false` for nice-to-have plugins where the bot can function without them

### Sub-Agents (`agents/` directory)

Bots can define sub-agents as markdown files in an `agents/` directory, following the same format as Claude Code's `.claude/agents/`. Each sub-agent file is a standalone agent definition with YAML frontmatter and a system prompt body.

Sub-agents are internal to the bot — other bots and teams never interact with them directly. The parent bot orchestrates them via `sessions_spawn`.

#### Agent File Format

```markdown
---
name: string            # Kebab-case identifier, unique within this bot
description: string     # When the parent bot should spawn this sub-agent
model: string           # "haiku", "sonnet", "opus", or "inherit" (default: inherit)
tools: [string]         # ADL tools this sub-agent can use (default: all except session tools)
---

{System prompt in markdown — this is the sub-agent's identity and instructions}
```

#### Supported Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (kebab-case, matches filename without `.md`) |
| `description` | Yes | When the parent bot should delegate to this sub-agent |
| `model` | No | Model override: `haiku`, `sonnet`, `opus`, or `inherit` (default: `inherit`) |
| `tools` | No | Tool allowlist. Inherits all ADL tools except session tools if omitted |

The markdown body after the frontmatter becomes the sub-agent's system prompt. This is the sub-agent's entire identity — write it as a focused, self-contained instruction set.

#### How Sub-Agents Work at Runtime

1. Parent bot calls `sessions_spawn` with the sub-agent's system prompt and model
2. Sub-agent runs in an isolated session with its own context
3. Sub-agent completes the task and announces results back to the parent
4. Parent bot reads the result and continues orchestrating

Sub-agents receive their system prompt + standard tool access. They do NOT receive the parent's SOUL.md, memory, or messages.

> **OpenCLAW compatibility note**: OpenCLAW's `sessions_spawn` currently accepts a `task` string but not a full custom system prompt. Until custom prompt injection is supported ([#18136](https://github.com/openclaw/openclaw/issues/18136)), the runtime will pass the agent file's markdown body as the task string. The format is designed to work today as task instructions and to upgrade seamlessly when full prompt injection lands.

#### When to Use Sub-Agents vs Skills

| Use Case | Use a Skill | Use a Sub-Agent |
|----------|-------------|-----------------|
| Simple, sequential step | Yes | No |
| Needs its own isolated session | No | Yes |
| Validates another agent's output | No | Yes |
| Reusable across many bots | Yes | No |
| Requires different model/think level | No | Yes |
| Workflow with quality gates | No | Yes |

#### Example: Blog Writer agents/

```
bots/blog-writer/
├── BOT.md
├── SOUL.md
├── agents/
│   ├── researcher.md    # Fast research on haiku
│   ├── writer.md        # Drafts post (inherits model)
│   └── editor.md        # Quality gate on sonnet
└── data-seeds/
```

See `bots/blog-writer/agents/` for the canonical example of sub-agent definitions.

### Field Rules

- `metadata.name` must match the directory name under `bots/`
- `model.preferred` should use lighter models for routine tasks, more capable models for analytical tasks
- `cost.estimatedCostTier` is derived from model choice + schedule frequency: low (light model, infrequent), medium (light model + frequent OR capable model + infrequent), high (capable model + frequent)
- `cost.estimatedTokensPerRun` is the typical token consumption per invocation (not a hard limit)
- `schedule.default` must be a valid cron expression or `@every` / `@daily` / `@weekly` interval
- `messaging.listensTo[].from` uses bot `metadata.name` values or `["*"]`
- `data.entityTypesWrite` must include `{abbrev}_findings` as a convention
- `agent.capabilities` should use values from the standard taxonomy: `operations`, `dev_devops`, `finance`, `analytics`, `customer_support`, `content_marketing`, `legal_compliance`, `management`, `research`, `data_engineering`, `procurement`, `security`

### SOUL.md Format

Plain markdown. Keep concise to minimize token usage per run.

#### Required Sections

```markdown
# {Display Name}

You are {Display Name}, a persistent AI team member for this business.

## Mission
{One sentence defining the bot's core purpose}

## Mandates
1. {First mandatory behavior -- executed every run}
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

---

## Team Manifest (`TEAM.md`)

A Team is a coordinated group of bots that work together under a shared North Star context.

### Directory Structure

```
teams/{team-name}/
└── TEAM.md           # Manifest with kind: Team
```

### TEAM.md Format

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: string           # Kebab-case identifier
  displayName: string    # Human-readable name
  version: string        # SemVer
  description: string    # One-line description
  category: string       # Industry or use-case category
  tags: [string]
  author: string
  license: string
  estimatedMonthlyCost: string  # Estimated cost at default schedules
bots:
  - ref: string          # Reference: "bots/{name}@{version}"
plugins:                 # Shared plugin dependencies for this team (optional)
  - ref: string          # npm package + version
    slot: string         # Plugin slot if exclusive
    reason: string       # Why this team needs this plugin
    config: object       # Team-wide defaults (bots can override)
northStar:
  industry: string       # Target industry for this team
  context: string        # Description of the ideal user/scenario
  requiredKeys: [string] # North Star keys that must be filled for this team
---
```

### Field Rules

- `metadata.name` must match the directory name under `teams/`
- `bots[].ref` must reference valid bot directories
- `northStar.requiredKeys` should list all zone1 keys needed by any bot in the team
- `estimatedMonthlyCost` is calculated from model costs at default schedules
- Teams do NOT override individual bot schedules or models -- those are bot-level concerns
- Team-level `plugins` provide shared defaults; individual bot `plugins` can override `config`

---

## Data Seeds Format

### zone1-north-star.json

Role-specific North Star key supplements. Merged with the workspace's existing North Star data.

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

## Toon Card Format

Inter-bot messages use a compact "Toon Card" payload (200-500 bytes):

```json
{
  "toonCard": {
    "entityType": "string",
    "entityId": "string",
    "title": "string",
    "severity": "low | medium | high | critical",
    "summary": "string (<200 chars)",
    "metrics": {},
    "actionRequired": true | false
  }
}
```

## Naming Conventions

- Skill directories: kebab-case matching `metadata.name`
- Bot directories: kebab-case matching `metadata.name`
- Team directories: kebab-case matching `metadata.name`
- Entity types: snake_case, prefixed with role abbreviation (e.g., `sre_findings`)
- Memory namespaces: snake_case (e.g., `working_notes`, `learned_patterns`)
- Message types: lowercase (alert, request, finding, text)

## Validation

### Skill validation
1. `SKILL.md` has valid YAML frontmatter with `kind: Skill`
2. `prompt.md` exists and is under 200 tokens
3. `tools.required` only contains valid ADL tool names
4. `metadata.name` matches the directory name

### Bot validation
1. `BOT.md` has valid YAML frontmatter with `kind: Bot` and all required fields
2. `SOUL.md` exists and is under 800 tokens
3. `data-seeds/` contains all three zone files with valid JSON
4. `metadata.name` matches the directory name
5. All `skills[].ref` reference existing skill directories with matching versions
6. All `messaging.sendsTo[].to` reference valid bot names or system targets
7. `data.entityTypesWrite` includes a `{abbrev}_findings` entry
8. All files in `agents/` have valid YAML frontmatter with `name` and `description`
9. Agent `name` matches the filename (e.g., `researcher.md` → `name: researcher`)
10. Agent `tools` only references valid ADL tool names
11. All `plugins[].ref` are valid npm package specs (name + semver range)
12. All `plugins[].reason` are non-empty strings
13. No `plugins[].config` values contain secrets (no fields named `password`, `secret`, `token`, `apiKey`)

### Team validation
1. `TEAM.md` has valid YAML frontmatter with `kind: Team`
2. All `bots[].ref` reference existing bot directories with matching versions
3. `northStar.requiredKeys` is the union of all `zones.zone1Read` keys from member bots
4. `estimatedMonthlyCost` matches calculated cost from model/schedule combinations
5. All `plugins[].ref` are valid npm package specs
6. No conflicting plugin slots between team-level and bot-level declarations
