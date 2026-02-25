# Skill Pack Specification v1

This is the authoritative format specification for OpenClaw Skill Packs.

## Overview

A Skill Pack is a directory containing three components:

| File | Purpose | Required |
|------|---------|----------|
| `SKILL.md` | Machine-parseable manifest (YAML frontmatter) + human docs | Yes |
| `SOUL.md` | Agent identity document loaded as system prompt | Yes |
| `data-seeds/` | Bootstrap data for ADL zones | Yes |

## SKILL.md Format

YAML frontmatter delimited by `---`, followed by markdown documentation.

### Required Fields

```yaml
---
apiVersion: openclaw.schemabounce.com/v1
kind: SkillPack
metadata:
  name: string           # Kebab-case identifier, unique across all packs
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
  maxTokenBudget: int    # Max tokens per run (input + output)
schedule:
  default: string        # Cron expression or @every interval
  recommendations:
    light: string        # Low-frequency option
    standard: string     # Default recommendation
    intensive: string    # High-frequency option
messaging:
  listensTo:
    - type: string       # Message type: alert, request, finding, text
      from: [string]     # Bot names or ["*"] for all
  sendsTo:
    - type: string
      to: [string]
      when: string       # Human-readable trigger condition
data:
  entityTypesRead: [string]   # Entity types this bot reads
  entityTypesWrite: [string]  # Entity types this bot creates
  memoryNamespaces: [string]  # Private memory namespaces used
zones:
  zone1Read: [string]    # North Star keys this bot reads
  zone2Domains: [string] # Shared domains this bot accesses
requirements:
  minTier: string        # Minimum workspace tier: starter, team, scale, enterprise
---
```

### Field Rules

- `metadata.name` must match the directory name under `packs/`
- `model.preferred` should use Haiku for routine tasks, Sonnet for analytical tasks
- `model.maxTokenBudget` should be 50,000 for Haiku bots, 100,000 for Sonnet bots
- `schedule.default` must be a valid cron expression or `@every` / `@daily` / `@weekly` interval
- `messaging.listensTo[].from` uses bot `metadata.name` values or `["*"]`
- `data.entityTypesWrite` must include `{name}_findings` as a convention

## SOUL.md Format

Plain markdown. Target: **<800 tokens (~1.5KB)**. The runtime appends ~600 tokens of output format rules and zone context, keeping total system prompt under 3KB.

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

## Escalation
- Critical: message executive-assistant type=alert
- Cross-domain: message {relevant-bot} type=finding
```

### Token Budget Guidelines

| Section | Max Tokens |
|---------|-----------|
| Title + intro | ~50 |
| Mission | ~30 |
| Mandates | ~120 |
| Run Protocol | ~200 |
| Entity Types | ~50 |
| Escalation | ~80 |
| **Total** | **~530** |

Leave ~270 token headroom for variations. Never exceed 800 tokens.

## Data Seeds Format

### zone1-north-star.json

Role-specific North Star key supplements. These are merged with the workspace's existing North Star data.

```json
{
  "seeds": [
    {
      "key": "string",
      "value": "string",
      "description": "string (optional, for documentation)"
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

- Pack directory: kebab-case matching `metadata.name`
- Entity types: snake_case, prefixed with role abbreviation (e.g., `sre_findings`)
- Memory namespaces: snake_case (e.g., `working_notes`, `learned_patterns`)
- Message types: lowercase (alert, request, finding, text)

## Validation

A valid pack must satisfy:
1. `SKILL.md` has valid YAML frontmatter with all required fields
2. `SOUL.md` exists and is under 800 tokens
3. `data-seeds/zone1-north-star.json` is valid JSON matching schema
4. `data-seeds/zone2-entity-types.json` is valid JSON matching schema
5. `data-seeds/zone3-initial-memory.json` is valid JSON matching schema
6. `metadata.name` matches the directory name
7. All `messaging.sendsTo[].to` values reference valid pack names or system targets
8. All `data.entityTypesWrite` include a `{name}_findings` entry
