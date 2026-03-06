# Contributing to ClawSink Bots

## Adding a Bot

1. Create `bots/{bot-name}/` directory (kebab-case)
2. Create `BOT.md` with YAML frontmatter -- see [bots/README.md](bots/README.md) for the full format
3. Create `SOUL.md` -- agent identity, under 800 tokens
4. Create `data-seeds/` with `zone1-north-star.json`, `zone2-entity-types.json`, `zone3-initial-memory.json`
5. Optionally create `agents/` directory with sub-agent `.md` files

**Canonical example**: `bots/blog-writer/` (has sub-agents, plugins, full SOUL.md)

## Adding a Team

1. Create `teams/{team-name}/` directory (kebab-case)
2. Create `TEAM.md` with YAML frontmatter including `orgChart` -- see [teams/README.md](teams/README.md) for the full format
3. All bots referenced in `bots[].ref` must exist in the `bots/` directory
4. Every bot must appear in `orgChart.roles` with a role, reportsTo, and domain
5. Exactly one bot must have `role: lead` with `reportsTo: null`

**Canonical example**: `teams/restaurant-group/` (has orgChart, escalation paths, industry-specific domains)

## Adding a Skill

1. Create `skills/{skill-name}/` directory (kebab-case)
2. Create `SKILL.md` with YAML frontmatter -- see [skills/README.md](skills/README.md) for the full format
3. Create `prompt.md` -- skill instructions, under 200 tokens

## Adding an MCP Server

1. Create `tools/{server-name}/` directory (kebab-case)
2. Create `SERVER.md` with YAML frontmatter -- see [tools/README.md](tools/README.md) for the full format
3. Define `transport` (stdio, sse, or streamable-http)
4. List required `env` variables (names only -- never include actual values)
5. List all `tools` the server provides with descriptions and categories
6. Reference from bots via `mcpServers[].ref: "tools/{server-name}"`
7. For team-wide servers, add to TEAM.md `mcpServers` section

**Canonical example**: `tools/github/SERVER.md` (stdio transport, 25 tools across 3 categories)

**MCP Servers vs Plugins**: MCP servers provide external tool endpoints via the Model Context Protocol. Plugins are npm-based OpenCLAW runtime extensions (OAuth, memory, channels). Use MCP servers for external API access; use plugins for runtime capabilities.

## Validation Checklist

Before submitting a PR:

- [ ] `metadata.name` matches directory name in every manifest
- [ ] BOT.md has all required YAML fields (see spec)
- [ ] SOUL.md exists and is under 800 tokens
- [ ] data-seeds/ has all 3 JSON files with valid content
- [ ] TEAM.md orgChart has exactly 1 lead with `reportsTo: null`
- [ ] Every bot in team appears exactly once in orgChart.roles
- [ ] Escalation paths only reference bots in the team
- [ ] No secrets, credentials, or API keys in any file
- [ ] No competitor names (Fivetran, Hevo, Airbyte, etc.)
- [ ] No dollar amounts -- use `estimatedCostTier` and `estimatedTokensPerRun`
- [ ] All `mcpServers[].ref` point to existing `tools/` directories
- [ ] SERVER.md has valid YAML with `kind: McpServer`
- [ ] No secrets in MCP server `env` -- names only, no values
- [ ] Markdown body after `---` provides marketplace documentation

## Manifest Parsing

All manifest files are parsed programmatically to populate the SchemaBounce marketplace. The YAML frontmatter is extracted and mapped directly to UI elements. See the "How the Marketplace Parser Works" section in [README.md](README.md) for the exact field-to-UI mapping.

Breaking the YAML format will break the marketplace. Validate before committing.

## File Format Rules

- YAML frontmatter must be delimited by `---` on its own line
- Markdown body follows after the closing `---`
- All YAML strings with special characters must be quoted
- Use kebab-case for names, snake_case for entity types, camelCase for YAML fields
- Maximum line length: none enforced, but keep YAML readable
