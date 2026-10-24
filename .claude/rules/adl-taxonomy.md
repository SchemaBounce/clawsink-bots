# ADL Taxonomy — Single Source of Truth

> **Design doc:** See `frontend` repo: `docs/plans/2026-03-12-adl-taxonomy-design.md`
> **Always loaded** — this repo defines the marketplace blueprints.

## The 4 Entities

| Concept | Definition | This repo's role |
|---------|-----------|-----------------|
| **Skill** | Reusable prompt + tool requirements | `skills/{name}/SKILL.md` — defines the skill |
| **Bot** | Complete agent blueprint with baked-in skills | `bots/{name}/BOT.md` — defines the bot |
| **Agent** | Deployed, running instance of a bot | NOT in this repo — created in workspace when bot is deployed |
| **Domain template** | Bundle of bots with an org chart; using it creates domains and their agents | `templates/{name}/TEMPLATE.md` — defines the template (file layout keeps its old name for now) |

## Key Rules for Manifest Authors

1. **Bots are blueprints, not deployed agents.** BOT.md defines defaults (model, schedule, skills). Users customize after deployment. Write defaults that make sense as starting points.
2. **Skills are baked into bots.** A bot's `skills: [ref]` list is final. Users cannot add/remove skills post-deploy. Design bots with the right skill mix from the start.
3. **Domain templates are deploy bundles with org structure** (dec-185, accepted 2026-10-22). A TEMPLATE.md defines which bots deploy together, the domains they land in (`orgChart.domains`) and escalation paths. In the workspace the groupings are **Domains**; "team" no longer names a SchemaBounce concept. Exceptions that keep the word: the Team plan, Microsoft Teams, a provider's Team seat, Linear teams. Say "domain template" in new prose. Do NOT rename the `templates/` directory, the `TEMPLATE.md` file name, `kind: DomainTemplate` or any `metadata.name` (`engineering-team` and the rest are activation keys stored in customer workspaces); the platform accepts new names for those later and keeps the old ones working.
4. **"Seat" never names a SchemaBounce concept** (dec-121, accepted 2026-10-14, supersedes dec-031). Never call an agent, its capacity, workspace membership or a plan a seat in manifests, README files, or documentation. Bots deploy directly to become Agents. Single exception: a third-party provider's own license unit, in the provider's own term (for example a Claude Team seat), in the code, types and copy that handle those licenses (dec-077, dec-112, dec-113). Bot (marketplace blueprint) and Agent (deployed instance) are never interchanged. Agent slots are a visual capacity representation with no data model. `scripts/check-seat-copy.sh` (pre-commit) enforces this.

## Terminology in Manifests and Docs

| Context | Say | Don't say |
|---------|-----|-----------|
| This repo's listings | "Bot" | "Agent", "Seat" |
| What happens at deploy | "Creates an agent" | "Activates to a seat" |
| Bot capabilities | "Skills (baked in)" | "Attachable skills", "Seat skills" |
| Using a domain template | "Creates its domains and deploys its bots as agents" | "Fills seats", "Activates a team" |
| A group of agents in a workspace | "Domain" | "Team" |
| A TEMPLATE.md bundle | "Domain template" | "Team", "Team pack" |
| Capacity limits | "Agent slots" | "Seats" |

## Manifest Hierarchy

```
Skill (capability)
  └── referenced by Bot via skills: [ref]

Bot (blueprint)
  ├── skills: [ref to skills/]
  ├── SOUL.md (identity)
  ├── model defaults
  ├── schedule defaults
  └── referenced by a domain template via bots: [ref]

Domain template (bundle, TEMPLATE.md)
  ├── bots: [ref to bots/]
  ├── orgChart (roles, escalation)
  └── northStar (workspace context)
```

## README and Documentation

When writing README files or documentation in this repo:
- Describe bots as "blueprints" or "templates" — not as running agents
- Explain that skills are part of the bot definition, not standalone deployable units
- Clarify that a domain template creates its domains and multiple agents from its member bots
- Never use "seat" for an agent, capacity or a plan. Use "agent slots" for tier capacity if needed. Only a provider's own license unit may be called a seat, in the provider's term (dec-121)

## Three Concepts Sharing the Word 'Skill'

The ADL system uses the word "skill" in three distinct ways. Each operates independently with different storage, discovery, invocation, and ownership models. Always qualify which skill type you are discussing.

### Comparison Table

| Concept | Storage | Runtime Discovery | Runtime Invocation | Who Controls | UI Location |
|---------|---------|-------------------|-------------------|--------------|-------------|
| **Marketplace Skills** | `agent.skill_prompts` JSONB array | Embedded in SOUL.md at activation | `adl_invoke_skill` tool call | Marketplace authors (BOT.md) | Bot definition pages (Marketplace tab) |
| **Crystallized Skills** | `adl_skills` + `adl_crystallization_candidates` tables | `adl_discover_skills` tool call | `adl_execute_skill` tool call (Tier 0/1 only) | Workspace users via approval flow | Automations > Functions tab |
| **Tool Pack Tools** | Hardcoded Go functions in `tools_packs.go`, available to every agent | `adl_tool_search` tool call promotes a match into the provider tool list | `callPackTool` dispatch in provider tools | Platform team; no per-agent access control | Marketplace > Tool Packs tab |

### Critical Rules

- When writing code that references "skills," always qualify: *marketplace skills*, *crystallized skills*, or *tool pack tools*. Unqualified "skill" leads to ambiguity.
- The `adl_skills` table holds **only crystallized skills**. It is not related to `agent.skill_prompts`.
- The `agent.skill_prompts` JSONB column holds **only marketplace skill prompts**. It is not related to `adl_skills`.
- The frontend "Functions" page at `/context/functions` (Context Engine, beside Data Explorer) operates on crystallized skills only. It is NOT a tool pack browser and NOT a marketplace skill editor.
- `adl_invoke_skill` activates a marketplace skill by loading its prompt and restricting available tools to those declared in its requirements.
- `adl_execute_skill` runs a crystallized skill by calling its underlying PostgreSQL function or materialized view.
- `adl_discover_skills` lists all crystallized skills available to the agent.
- `adl_tool_search` discovers tool pack tools. All 133 pack tools are available to every agent; the ones not yet surfaced ship `SearchOnly` (discoverable, but absent from the provider tool list to save tokens). A search match promotes its tool into the tool list with its real schema starting at the next turn boundary.
- Marketplace skills are inherited from the bot at activation; they can be added/removed/reordered post-deploy on the Agent's Skills tab.
- Crystallized skills are auto-discovered patterns detected by the platform, never manually authored by users.
- Tool pack tools are hardcoded platform capabilities available to every agent, always. There is no per-agent allowlist and `toolPacks[]` on a bot manifest is catalog/display metadata, not an access-control decision. Delivery is just in time: a pack tool is `SearchOnly` until `adl_tool_search` surfaces it, then it is promoted into the model's tool list.
