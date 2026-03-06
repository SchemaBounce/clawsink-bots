# Skills

Skills are reusable capabilities composed into bots. A skill defines WHAT to do, not WHO does it — it has no identity, schedule, model, or messaging of its own.

**Relationship to Bots**: Skills are referenced by bots via `skills[].ref: "skills/{name}@{version}"` in BOT.md. At activation, each skill's `prompt.md` is appended to the bot's system prompt after SOUL.md. See [bots/README.md](../bots/README.md) for how bots compose skills.

## Directory Structure

```
skills/{skill-name}/
├── SKILL.md          # Manifest (kind: Skill) — YAML frontmatter parsed by marketplace
└── prompt.md         # Skill instructions (<200 tokens) — appended to bot's system prompt
```

## SKILL.md Format

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

# {Display Name}

Extended documentation here. Renders as the skill's marketplace page.
```

## prompt.md Format

A focused instruction block appended to the bot's SOUL.md at runtime. Must be under 200 tokens. Starts with a `## {Skill Name}` heading and contains numbered steps.

```markdown
## Invoice Categorization

When processing invoices:
1. Query uncategorized invoices (entity_type="invoices", filter by missing category)
2. Classify each invoice: category, vendor, urgency
3. Flag duplicates by matching vendor + amount + date
4. Write categorization as acct_findings
```

## Field Rules

- `metadata.name` must match the directory name under `skills/`
- `tools.required` must be a subset of the platform's available tools
- `data.producesEntityTypes` must follow `{role_prefix}_findings` convention when writing findings
- Skills must NOT define identity, schedule, model, or messaging — those belong to the Bot

## Validation

1. `SKILL.md` has valid YAML frontmatter with `kind: Skill`
2. `prompt.md` exists and is under 200 tokens
3. `tools.required` only contains valid ADL tool names
4. `metadata.name` matches the directory name

## What the Platform Does

| You Provide | The Platform Will |
|-------------|-------------------|
| `SKILL.md` frontmatter | Display on the skill's marketplace page |
| `prompt.md` | Append to the parent bot's system prompt at activation |
| `tools.required` | Show as "Uses tools" badges on the marketplace page |
| `data.producesEntityTypes` | Show in the "Produces" section |
| `data.consumesEntityTypes` | Show in the "Consumes" section |

## Canonical Example

See [`daily-briefing/`](daily-briefing/) for a complete skill with SKILL.md and prompt.md.
