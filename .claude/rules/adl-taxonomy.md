# ADL Taxonomy — Single Source of Truth

> **Design doc:** See `frontend` repo: `docs/plans/2026-03-12-adl-taxonomy-design.md`
> **Always loaded** — this repo defines the marketplace blueprints.

## The 4 Entities

| Concept | Definition | This repo's role |
|---------|-----------|-----------------|
| **Skill** | Reusable prompt + tool requirements | `skills/{name}/SKILL.md` — defines the skill |
| **Bot** | Complete agent blueprint with baked-in skills | `bots/{name}/BOT.md` — defines the bot |
| **Agent** | Deployed, running instance of a bot | NOT in this repo — created in workspace when bot is deployed |
| **Team** | Group of bots with org chart | `teams/{name}/TEAM.md` — defines the team blueprint |

## Key Rules for Manifest Authors

1. **Bots are blueprints, not deployed agents.** BOT.md defines defaults (model, schedule, skills). Users customize after deployment. Write defaults that make sense as starting points.
2. **Skills are baked into bots.** A bot's `skills: [ref]` list is final. Users cannot add/remove skills post-deploy. Design bots with the right skill mix from the start.
3. **Teams are deploy bundles with org structure.** TEAM.md defines which bots deploy together, their org chart, and escalation paths. These persist as visual groupings in the workspace.
4. **"Seat" does not exist.** Never reference seats in manifests, README files, or documentation. Bots deploy directly to become Agents.

## Terminology in Manifests and Docs

| Context | Say | Don't say |
|---------|-----|-----------|
| This repo's listings | "Bot" | "Agent", "Seat" |
| What happens at deploy | "Creates an agent" | "Activates to a seat" |
| Bot capabilities | "Skills (baked in)" | "Attachable skills", "Seat skills" |
| Team activation | "Deploys member bots as agents" | "Fills seats" |
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
  └── referenced by Team via bots: [ref]

Team (bundle)
  ├── bots: [ref to bots/]
  ├── orgChart (roles, escalation)
  └── northStar (workspace context)
```

## README and Documentation

When writing README files or documentation in this repo:
- Describe bots as "blueprints" or "templates" — not as running agents
- Explain that skills are part of the bot definition, not standalone deployable units
- Clarify that teams create multiple agents from their member bots
- Never mention "seats" — use "agent slots" for tier capacity if needed

## Three Concepts Sharing the Word 'Skill'

The ADL system uses the word "skill" in three distinct ways. Each operates independently with different storage, discovery, invocation, and ownership models. Always qualify which skill type you are discussing.

### Comparison Table

| Concept | Storage | Runtime Discovery | Runtime Invocation | Who Controls | UI Location |
|---------|---------|-------------------|-------------------|--------------|-------------|
| **Marketplace Skills** | `agent.skill_prompts` JSONB array | Embedded in SOUL.md at activation | `adl_invoke_skill` tool call | Marketplace authors (BOT.md) | Bot definition pages (Marketplace tab) |
| **Crystallized Skills** | `adl_skills` + `adl_crystallization_candidates` tables | `adl_discover_skills` tool call | `adl_execute_skill` tool call (Tier 0/1 only) | Workspace users via approval flow | Automations > Functions tab |
| **Tool Pack Tools** | Hardcoded Go functions in `tools_packs.go` + allowlist per agent | `adl_tool_search` tool call | `callPackTool` dispatch in provider tools | Platform team; per-agent allowlist | Marketplace > Tool Packs tab |

### Critical Rules

- When writing code that references "skills," always qualify: *marketplace skills*, *crystallized skills*, or *tool pack tools*. Unqualified "skill" leads to ambiguity.
- The `adl_skills` table holds **only crystallized skills**. It is not related to `agent.skill_prompts`.
- The `agent.skill_prompts` JSONB column holds **only marketplace skill prompts**. It is not related to `adl_skills`.
- The frontend "Functions" tab at `/agent-data-layer/automations?tab=functions` operates on crystallized skills only. It is NOT a tool pack browser and NOT a marketplace skill editor.
- `adl_invoke_skill` activates a marketplace skill by loading its prompt and restricting available tools to those declared in its requirements.
- `adl_execute_skill` runs a crystallized skill by calling its underlying PostgreSQL function or materialized view.
- `adl_discover_skills` lists all crystallized skills available to the agent.
- `adl_tool_search` discovers tool pack tools available to the agent via its hardcoded allowlist.
- Marketplace skills are inherited from the bot at activation; they can be added/removed/reordered post-deploy on the Agent's Skills tab.
- Crystallized skills are auto-discovered patterns detected by the platform, never manually authored by users.
- Tool pack tools are hardcoded platform capabilities, configured per-agent via an allowlist maintained by the workspace admin.
