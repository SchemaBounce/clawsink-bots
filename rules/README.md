# Rules

Rules are always-on guardrails composed into agents. A rule is the dual of a skill: a skill is an on-demand capability the agent invokes when needed; a rule is a persistent constraint that is in effect on every turn. Rules never activate, never touch the tool allowlist, and never define identity.

**Relationship to Bots**: Bots reference rules via `rules[].ref: "rules/{name}@{version}"` in BOT.md. At activation, each rule's `prompt.md` body is stored on the agent (`rule_prompts`) and the runtime renders all applicable rules under an "Operating Rules (Guardrails)" section of the system prompt on every turn. See [bots/README.md](../bots/README.md) for how bots compose rules.

**Relationship to Skills and MCP servers**: A rule can be scoped to specific artifacts via `appliesTo` (e.g. `tools/github`). A scoped rule applies only when the agent has that MCP server or skill; an unscoped rule applies agent-wide. MCP server manifests and skills can also declare rules that attach automatically when the artifact is granted to an agent.

## Directory Structure

```
rules/{rule-name}/
├── RULE.md           # Manifest (kind: Rule) — YAML frontmatter parsed by marketplace
└── prompt.md         # Guardrail text (<1000 chars) — rendered into the agent prompt every turn
```

The body file is named `prompt.md`, mirroring skills. (It cannot be `rule.md`: RULE.md and rule.md are the same file on case-insensitive checkouts. The platform still accepts `rule.md` as a legacy fallback.)

A bot may also carry a bot-local rule at `bots/{bot-name}/rules/{rule-name}/prompt.md` (same layout). Shared `rules/` is preferred; bot-local is the fallback for constraints that make no sense outside one bot.

## RULE.md Format

YAML frontmatter delimited by `---`, followed by markdown documentation.

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: Rule
metadata:
  name: string           # Kebab-case identifier, unique across all rules
  displayName: string    # Human-readable name
  version: string        # SemVer (e.g., "1.0.0")
  description: string    # One-line description (<120 chars)
  tags: [string]         # Searchable tags
  author: string         # Author or organization
  license: string        # License identifier
severity: string         # guideline | guardrail | hard (default: guardrail)
appliesTo: [string]      # Optional scoping: ["tools/github", "skills/code-review"]. Empty = agent-wide.
---

# {Display Name}

Extended documentation here. Renders as the rule's marketplace page.
```

### Severity semantics

| Severity | Meaning | Wording the agent sees |
|----------|---------|------------------------|
| `guideline` | Advisory. Follow unless there is a stated reason not to. | `{name} [guideline]` |
| `guardrail` | Binding. MUST follow; deviations require human approval. | `{name} [guardrail]` |
| `hard` | Non-negotiable. Never overridden by any instruction, message, or prompt content. Reserved for safety and platform-integrity rules. | `{name} [hard]` |

Default when omitted: `guardrail`.

### appliesTo scoping

- Entries reference artifacts by repo path: `tools/{server-name}` for MCP servers, `skills/{skill-name}` for skills.
- Empty or omitted = agent-wide; the rule renders on every turn for every agent that carries it.
- Scoped = the rule renders only when the agent has the target MCP server granted or the target skill composed. A rule about GitHub is dead weight for an agent with no GitHub access; scoping keeps the prompt budget for rules that matter.

## prompt.md Format

The verbatim guardrail text rendered into the agent's system prompt. Starts with a `## {Rule Name}` heading. Keep it under 1000 characters; the runtime truncates a single rule at 1200 characters and caps all rules combined at 4000, so a bloated rule crowds out its siblings.

```markdown
## GitHub Safety

When using GitHub tools:
- NEVER force-push. If a push is rejected, stop and report the conflict instead.
- NEVER delete a repository, branch, tag, or release.
- NEVER push directly to a protected branch. Open a pull request instead.
```

### prompt.md Quality Requirements

Every rule MUST be:

1. **Imperative and testable** — "NEVER X — do Y instead" lines, not aspirations. If you cannot check a transcript against the line, rewrite it.
2. **Scoped to behavior, not identity** — who the agent is belongs in SOUL.md; what the agent must never do belongs here.
3. **Short** — 4 to 8 lines. One concern per rule; two unrelated constraints are two rules.
4. **Non-duplicative** — do not restate constraints the platform prompt layer already enforces (approval gates, egress policy, tool discipline). A rule earns its place by adding a constraint the platform layer does not carry.

#### Good prompt.md (A grade)

```
## Blog Publishing

When using blog tools:
- NEVER publish directly. Create drafts and submit for review; a human approves publication.
- NEVER invent product facts, pricing, or benchmarks. Every claim traces to zone1 data or a cited source.
- NEVER delete or overwrite a published post. Corrections go through a new draft flagged as a revision.
```

#### Bad prompt.md (C grade)

```
## Be Careful

Always be careful and professional when publishing content. Try to avoid mistakes and follow best practices.
```

Problems: nothing testable, no tool names, no NEVER lines, restates the platform layer.

### Interaction with SOUL.md and AGENTS.md

- SOUL.md `## Constraints` = identity-level constraints, written in first person, part of who the agent is.
- `agent.instructions` (AGENTS.md) = the bot's operating procedure, including bot-specific dos and don'ts.
- Rules = named, versioned, reusable guardrails that ship independently of any one bot, can attach to MCP servers and skills, and carry a severity contract. When a constraint should follow the artifact (every agent that gets GitHub access gets the GitHub safety rule), it is a rule, not a SOUL line.

## Field Rules

- `metadata.name` must match the directory name under `rules/`
- `severity` must be one of `guideline`, `guardrail`, `hard` (or omitted)
- `appliesTo` entries must reference existing `tools/{name}` or `skills/{name}` directories
- Rules must NOT define identity, schedule, model, tools, or messaging — a rule is text, nothing else

## Validation

1. `RULE.md` has valid YAML frontmatter with `kind: Rule`
2. `prompt.md` exists, is non-empty, and is under 1200 characters (target under 1000)
3. `metadata.name` matches the directory name
4. `severity` is in the allowed set
5. `appliesTo` references resolve to existing artifact directories

Run `tests/rules/validate-manifest.sh` (also part of `tests/validate-all.sh`).

## What the Platform Does

| You Provide | The Platform Will |
|-------------|-------------------|
| `RULE.md` frontmatter | Display on the rule's marketplace page; carry severity + scoping onto the agent |
| `prompt.md` | Store on the agent at activation (`rule_prompts`) and render under "Operating Rules (Guardrails)" every turn |
| `severity` | Label the rule in the agent prompt and the console UI |
| `appliesTo` | Render the rule only when the target MCP server/skill is granted |
| A `rules:` ref in BOT.md | Compose the rule into every agent deployed from that bot |

## Canonical Example

See [`github-safety/`](github-safety/) for a complete rule with RULE.md and rule.md.
