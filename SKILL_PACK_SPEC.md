# ClawSink Bots Specification v2

This is the authoritative format specification for the three-tier composability model: **Skills**, **Bots**, and **Teams**.

## Overview

The architecture uses three manifest kinds that compose hierarchically:

| Kind | Directory | Purpose | Manifest File |
|------|-----------|---------|---------------|
| `Skill` | `skills/` | Reusable capability (single responsibility) | `SKILL.md` |
| `Bot` | `bots/` | Complete agent definition (identity + skills) | `BOT.md` |
| `Team` | `teams/` | Coordinated bot group (shared North Star) | `TEAM.md` |

```
Team
 ├── Bot (executive-assistant)
 │    ├── Skill (daily-briefing)
 │    ├── Skill (cross-domain-synthesis)
 │    └── Skill (follow-up-tracking)
 ├── Bot (accountant)
 │    ├── Skill (invoice-categorization)
 │    ├── Skill (expense-tracking)
 │    └── Skill (budget-monitoring)
 └── ...
```

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
skills:                  # NEW: Skill composition
  - ref: string          # Reference to shared skill: "skills/{name}@{version}"
  - inline: string       # Bot-specific skill (no shared definition)
requirements:
  minTier: string        # Minimum workspace tier
---
```

### Skills Section

The `skills:` section lists capabilities this bot uses. Two formats:

- `ref: "skills/{skill-name}@{version}"` -- references a shared skill from the `skills/` directory. The skill's `prompt.md` is appended to the bot's SOUL.md at runtime.
- `inline: "{skill-name}"` -- a bot-specific capability that doesn't have a shared skill definition. Documented directly in the bot's SOUL.md.

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

### Team validation
1. `TEAM.md` has valid YAML frontmatter with `kind: Team`
2. All `bots[].ref` reference existing bot directories with matching versions
3. `northStar.requiredKeys` is the union of all `zones.zone1Read` keys from member bots
4. `estimatedMonthlyCost` matches calculated cost from model/schedule combinations
