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

### prompt.md Quality Requirements

Every skill prompt MUST include:

1. **Numbered steps** with specific ADL tool names (e.g., `adl_query_records`, `adl_upsert_record`)
2. **Output schema** specifying the entity_type and required fields for records written
3. **2-3 anti-patterns** using "NEVER X — do Y instead" format
4. **Numeric anchors** where applicable (thresholds, limits, character counts)

Keep prompts under 25 lines for token efficiency.

#### Good prompt.md (A grade)

```
1. Read messages (adl_read_messages) — check for requests
2. Query uncategorized invoices (adl_query_records entity_type: invoices, filter: status=uncategorized)
3. For each invoice: classify category, normalize vendor name, assess payment urgency
4. Check for duplicates (same vendor + amount + date within 7-day window)
5. Write categorization (adl_upsert_record entity_type: acct_findings)
6. Flag duplicates as high severity (adl_send_message type: alert)

Output: adl_upsert_record entity_type=acct_findings
Required fields: invoice_id, category, vendor_normalized, urgency, duplicate_flag

Anti-patterns:
- NEVER categorize uncertain transactions — flag for human review instead
- NEVER batch invoices older than 90 days with current — process separately
- NEVER skip duplicate detection — duplicates cause double payments
```

#### Bad prompt.md (C grade)

```
1. Get the data
2. Analyze it
3. Write results
4. Send alerts if needed
```

Problems: no tool names, no entity types, no anti-patterns, no output schema, not actionable.

#### Interaction with SOUL.md

Skills are injected into the agent's prompt alongside SOUL.md. The skill provides the HOW (procedure), while SOUL.md provides the WHO (identity, expertise, constraints). Skills should NOT:

- Redefine the agent's identity or communication style
- Duplicate constraints that are in SOUL.md or the platform prompt layer
- Reference specific agents by name (use roles like "domain lead" instead for portability)

## Public registry skills

A bot or team may reference a skill published in the open Agent Skills
ecosystem (the agentskills.io `SKILL.md` format, indexed by skills.sh) instead
of a skill in this repository:

```yaml
skills:
  - ref: "registry:anthropics/knowledge-work-plugins/invoice-chase"          # resolves to the publisher's current commit at deploy
  - ref: "registry:anthropics/knowledge-work-plugins/invoice-chase@3f2a9c1e0b7d4f5a6c8e9d0b1a2c3d4e5f6a7b8c"  # pinned
```

Grammar: `registry:<owner>/<repo>/<skill>[@<40-hex commit>]`. `<owner>/<repo>`
is the public GitHub repository; `<skill>` is the `SKILL.md` `name`, which must
equal its directory name.

What the platform does with a registry ref:

1. Finds the skill directory the way the skills CLI does: repository root,
   `skills/`, agent skill folders such as `.claude/skills/`, `.claude-plugin`
   plugin entries, up to three levels deep.
2. Keeps `SKILL.md` plus text files under `references/` and `assets/`
   (32 KiB body, 256 KiB total, 50 files). `scripts/` are recorded by path and
   never run in a hosted agent.
3. Pins the resolved commit and a content hash on the deployed agent. The agent
   keeps that commit until a person updates it in the console; a new upstream
   commit is offered, never applied by itself.
4. Refuses the skill when its skills.sh partner audit (Socket, Snyk, Gen Agent
   Trust Hub and others) reports `fail` or `CRITICAL`, and says which partner.
5. Uses the `SKILL.md` body as the skill prompt. A registry skill has no
   `prompt.md`; the frontmatter `description` is what the agent sees in its
   skills list before it loads the body.

A Claude Code plugin repository's `skills/` are registry skills through the
same grammar. Its MCP servers, hooks and commands are not; use the plugin
import tooling for those.

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
