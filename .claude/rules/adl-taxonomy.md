# ADL Taxonomy — Single Source of Truth

> **Design doc:** `/mnt/c/git/frontend/docs/plans/2026-03-12-adl-taxonomy-design.md`
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
