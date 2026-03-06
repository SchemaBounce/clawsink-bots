# ClawSink Bots Specification v2

This is the architectural overview for the composability model: **Skills**, **Bots** (with optional **Sub-Agents**), **Teams**, and **MCP Servers**. Each manifest kind has its own detailed specification in its directory's README.

## Overview

The architecture uses four manifest kinds that compose hierarchically. ClawSink is an abstraction layer **above** agents — it defines what agents are, how they compose, and how they communicate. It does not sit between agents and the runtime.

| Kind | Directory | Purpose | Manifest File |
|------|-----------|---------|---------------|
| `Skill` | `skills/` | Reusable capability (single responsibility) | `SKILL.md` |
| `Bot` | `bots/` | Top-level agent definition (identity + skills + sub-agents) | `BOT.md` |
| `Team` | `teams/` | Coordinated bot group (shared North Star) | `TEAM.md` |
| `McpServer` | `tools/` | Custom MCP tool server (shared across bots) | `SERVER.md` |

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

## Per-Level Specifications

Each directory contains its own README.md with the complete manifest format, field reference, validation rules, and canonical examples for that object type:

| Level | Spec Location | What It Covers |
|-------|---------------|----------------|
| Skills | [skills/README.md](skills/README.md) | `SKILL.md` manifest + `prompt.md` format |
| Bots | [bots/README.md](bots/README.md) | `BOT.md` manifest + `SOUL.md` + sub-agents + data seeds + plugins + MCP refs |
| Teams | [teams/README.md](teams/README.md) | `TEAM.md` manifest + org chart + escalation + shared plugins/MCP |
| MCP Servers | [tools/README.md](tools/README.md) | `SERVER.md` manifest + transport + env + tools listing |
| Plugins | [plugins/README.md](plugins/README.md) | Plugin ecosystem + slot system + installation |
| Shared Resources | [shared/README.md](shared/README.md) | Escalation chains, message protocol, entity schemas, Toon Card format |

---

## What the Platform Does With This Spec

This section explains what bot pack authors should expect when their manifests are activated. The goal is to help authors understand **why each field matters** — not to document platform internals.

### Bot Activation

When a user activates a bot from the marketplace, the platform uses the manifest to set up everything the bot needs:

| You Provide | The Platform Will |
|-------------|-------------------|
| `SOUL.md` | Use it as the bot's identity on every run |
| `skills[].ref` | Append each skill's `prompt.md` to the bot's instructions |
| `data-seeds/` (3 zone files) | Bootstrap the bot's data — North Star keys, entity schemas, and initial memory |
| `plugins[].ref` | Install and configure each plugin in the bot's runtime environment |
| `mcpServers[].ref` | Make the declared MCP server tools available to the bot |
| `schedule.default` | Run the bot on the declared schedule (user can adjust) |
| `trigger` | Run the bot in response to data change events on the declared entity type |
| `messaging.listensTo` / `sendsTo` | Connect the bot to the message system so it can communicate with other bots |
| `agents/*.md` | Make sub-agents available for the bot to spawn during its runs |
| `model.preferred` / `fallback` | Select the LLM the bot uses |

**What this means for authors:**
- Every field you declare gets acted on. Don't declare plugins or MCP servers the bot doesn't actually use.
- Data seeds are merged non-destructively — they won't overwrite existing workspace data.
- Skills are composed in the order listed. SOUL.md always comes first.
- MCP server `env` variables are resolved from workspace secrets — the manifest only declares the names, never the values.

### Team Activation

When a user activates a team, the platform sets up all member bots as a coordinated group:

| You Provide | The Platform Will |
|-------------|-------------------|
| `bots[].ref` | Activate each bot (full bot activation above) |
| `plugins[]` (team-level) | Install shared plugins available to all bots in the team |
| `mcpServers[]` (team-level) | Make shared MCP server tools available to all bots in the team |
| `northStar.requiredKeys` | Prompt the user to fill in required business context before bots run |
| `orgChart.roles` | Create the team's reporting hierarchy, visible in the org chart view |
| `orgChart.roles[].domain` | Group bots by domain — bots in the same domain share working data |
| `orgChart.escalation` | Set up escalation routing that overrides the global defaults |

**What this means for authors:**
- Team-level plugins and MCP servers are shared — you don't need to redeclare them on every bot.
- Bot-level `config` overrides team-level `config` for the same plugin or MCP server.
- The org chart appears in the workspace console. Users can view reporting lines and escalation paths visually.
- `northStar.requiredKeys` creates a setup checklist — the user must provide business context (mission, industry, etc.) before the team starts operating.
- Escalation paths defined here replace the global defaults in `shared/escalation-chains.json` for all bots in the team.

### MCP Server Deployment

When a bot or team references an MCP server:

| You Provide | The Platform Will |
|-------------|-------------------|
| `transport.type` + `command`/`url` | Start the server using the declared transport method |
| `env[].name` | Resolve each variable from the workspace's secrets store (activation fails if required secrets are missing) |
| `tools[]` | Register the server's tools so bots can call them by name |

**What this means for authors:**
- Never put secrets in SERVER.md — only declare variable names. Users configure actual values in their workspace settings.
- List every tool the server provides in the `tools[]` array. This is what appears on the marketplace page and what bots can call.
- `stdio` servers are managed by the platform. `sse` and `streamable-http` servers must be hosted externally by the user.

### Deactivation

Deactivation is non-destructive. The bot stops running but its working data, memory, and findings remain in the workspace. Reactivation picks up where the bot left off.

---

## Cross-Cutting Conventions

### Naming

- Skill directories: kebab-case matching `metadata.name`
- Bot directories: kebab-case matching `metadata.name`
- Team directories: kebab-case matching `metadata.name`
- MCP server directories: kebab-case matching `metadata.name`
- Entity types: snake_case, prefixed with role abbreviation (e.g., `sre_findings`)
- Memory namespaces: snake_case (e.g., `working_notes`, `learned_patterns`)
- Message types: lowercase (alert, request, finding, text)

### YAML Frontmatter

All manifest files use the same pattern:
- YAML frontmatter delimited by `---` on its own line
- Markdown body follows after the closing `---`
- All YAML strings with special characters must be quoted
- The parser extracts YAML frontmatter only; the markdown body is for documentation

### Inter-Bot Messages (Toon Card)

Inter-bot messages use a compact "Toon Card" payload (200-500 bytes). See [shared/README.md](shared/README.md) for the full format.
