# Skills

**clawsink-bots authors no skills** (dec-202). This directory holds this README and nothing else; the
validator `tests/skills/validate-format.sh` fails if a skill directory, `SKILL.md` or `prompt.md` appears here.

A skill is reusable know-how composed into a bot. A bot's `skills:` list has two kinds of entry:

1. **The SchemaBounce skill, always first.** SchemaBounce authors exactly one skill, `schemabounce`. It
   lives in [SchemaBounce/schemabounce-agent-kit](https://github.com/SchemaBounce/schemabounce-agent-kit)
   (`skills/schemabounce`) and is referenced here as `skills/schemabounce`, with no local directory. It
   covers how the platform works for an agent. Its `references/` files are `run-basics`, `agents-and-tasks`,
   `data-layer`, `files`, `workflows`, `pipelines`, `approvals-and-secrets`, `connections-and-tools`,
   `reporting`, `code-sessions`, `console-and-docs`, `billing-and-spend`, `hosted-mcp`, `workspace-admin`,
   `goals` and `decisions`.
2. **Public registry skills for domain know-how**, where a credible public skill exists (below). Where none
   exists, the bot's own `SOUL.md` / `AGENTS.md` carries the procedure.

```yaml
skills:
  - ref: "skills/schemabounce"
  - ref: "registry:coreyhaines31/marketingskills/seo-audit"
```

`docs/skills-to-public-registry.md` records which public skill replaced which old skill, with the checks
behind each choice (exists, partner audit, fit), and which old skills mapped to none.

A bot that needs a new capability does not add a skill here. Reference a public skill, or write the
instructions into the bot.

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

## Validation

`tests/skills/validate-format.sh` (run by `tests/validate-all.sh`) checks that:

1. `skills/` contains `README.md` only.
2. Every `ref: "skills/..."` in a bot, template, plugin, pack, data kit, rule or tool manifest is
   `skills/schemabounce` (optionally `@x.y.z`); any other `skills/<name>` fails.
3. Every `registry:` ref matches `registry:<owner>/<repo>/<skill>[@<40-hex commit>]`.
4. Every rule `appliesTo` entry that names a skill is `skills/schemabounce`.
5. Every bot lists `skills/schemabounce` first.
