# ClawSink Bots

Pre-built, persistent AI bot packs for SchemaBounce workspaces. Each bot is a complete OpenCLAW agent that autonomously operates a specific business role. Teams compose bots into domain-specific functions (Customer Service, Marketing, Engineering, and so on) — a business activates the domain teams it needs.

This repository is **parsed programmatically** to populate the marketplace, agent pages, and org chart views in the SchemaBounce console. Every manifest file is a contract -- the format must be followed exactly.

## Spec

**[ARCHITECTURE.md](ARCHITECTURE.md)** provides the architectural overview and cross-cutting conventions. Each directory has its own README with the complete manifest specification for that level:

| Level | Spec |
|-------|------|
| Skills | [skills/README.md](skills/README.md) |
| Bots | [bots/README.md](bots/README.md) |
| Teams | [teams/README.md](teams/README.md) |
| Data Kits | [data-kits/README.md](data-kits/README.md) |
| Built-in Tools | [packs/README.md](packs/README.md) |
| MCP Servers | [tools/README.md](tools/README.md) |
| Plugins | [plugins/README.md](plugins/README.md) |

## Repository Structure

```
clawsink-bots/
├── ARCHITECTURE.md              # Authoritative format specification
├── README.md                       # This file
├── LICENSE                         # Apache 2.0
│
├── skills/                         # 42 reusable skill definitions
│   └── {skill-name}/
│       ├── SKILL.md                # Manifest (kind: Skill)
│       └── prompt.md               # Skill instructions (<200 tokens)
│
├── bots/                           # 60 complete agent definitions
│   └── {bot-name}/
│       ├── BOT.md                  # Manifest (kind: Bot) -- PARSED FOR MARKETPLACE
│       ├── SOUL.md                 # Agent identity (<800 tokens)
│       ├── agents/                 # Sub-agent definitions (optional)
│       │   └── {agent-name}.md     # YAML frontmatter + system prompt
│       └── data-seeds/             # Bootstrap data for ADL zones
│           ├── zone1-north-star.json
│           ├── zone2-entity-types.json
│           └── zone3-initial-memory.json
│
├── teams/                          # 11 domain-specific bot teams (one per business function)
│   └── {team-name}/
│       └── TEAM.md                 # Manifest (kind: Team) -- PARSED FOR MARKETPLACE
│
├── data-kits/                      # 11 domain data packages (one per domain team)
│   └── {kit-name}/
│       ├── KIT.md                  # Manifest (kind: DataKit) -- PARSED FOR MARKETPLACE
│       ├── entity-schemas.json     # Entity type definitions with typed fields
│       ├── graph-templates.json    # AGE graph edge type templates
│       ├── vector-config.json      # pgvector collection configurations
│       ├── memory-bootstrap.json   # Industry KPIs, thresholds, domain knowledge
│       └── sample-data.json        # Example records for optional seeding
│
├── shared/                         # Cross-cutting infrastructure
│   ├── message-protocol.md         # Inter-bot message format (alert/request/finding/text)
│   ├── escalation-chains.json      # Global default escalation routing
│   ├── entity-schemas.md           # Common entity type definitions
│   ├── north-star-template.json    # North Star key template
│   └── output-format.md           # Standard output formatting
│
├── packs/                          # Native deterministic built-in tool manifests
│   ├── README.md                   # Tool pack documentation
│   └── {pack-name}/
│       └── PACK.md                 # Manifest (kind: ToolPack) -- PARSED FOR MARKETPLACE
│
├── tools/                          # MCP server definitions
│   ├── README.md                   # MCP server documentation
│   └── {server-name}/
│       └── SERVER.md               # Manifest (kind: McpServer) -- PARSED FOR MARKETPLACE
│
└── plugins/                        # Plugin ecosystem documentation
    └── README.md                   # Installation guide, slot system
```

## How the Marketplace Parser Works

The marketplace reads manifest files (`BOT.md`, `TEAM.md`, `SKILL.md`, `PACK.md`, `SERVER.md`, and `KIT.md`) and extracts YAML frontmatter to populate UI. Every field in the frontmatter has a specific rendering target.

### Bot Page (`/marketplace/bots/{name}`)

| YAML Field | Renders As |
|---|---|
| `metadata.displayName` | Page title, card heading |
| `metadata.description` | Card subtitle, search snippet |
| `metadata.category` | Category filter pill |
| `metadata.tags` | Search index, tag chips |
| `model.preferred` | "Powered by" badge |
| `cost.estimatedCostTier` | Cost indicator (low/medium/high) |
| `cost.estimatedTokensPerRun` | Estimated usage display |
| `schedule.default` | "Runs every..." label |
| `schedule.recommendations` | Schedule picker options |
| `messaging.sendsTo` | Communication diagram edges |
| `messaging.listensTo` | Communication diagram edges |
| `skills[].ref` | "Capabilities" section |
| `toolPacks[].ref` | "Native functions" section |
| `plugins[].ref` | "Required plugins" section |
| `agents/*.md` (directory listing) | "Sub-agents" section |
| Markdown body after `---` | Long description / documentation tab |

### Team Page (`/marketplace/teams/{name}`)

| YAML Field | Renders As |
|---|---|
| `metadata.displayName` | Page title, card heading |
| `metadata.description` | Card subtitle, search snippet |
| `metadata.domain` | Domain filter pill, domain badge |
| `metadata.tags` | Search index, tag chips |
| `bots[].ref` | Bot cards grid, bot count badge |
| `northStar.industry` | "Built for" label |
| `northStar.context` | Target audience description |
| `northStar.requiredKeys` | "Setup required" checklist |
| `orgChart.lead` | Org chart root node |
| `orgChart.roles` | Org chart tree visualization |
| `orgChart.roles[].domain` | Domain grouping in org chart |
| `orgChart.escalation.paths` | Escalation flow arrows in org chart |
| `plugins[].ref` | "Team plugins" section |
| `toolPacks[].ref` | "Shared native functions" section |
| Markdown body after `---` | Long description / documentation tab |

### Org Chart Page (`/workspaces/{id}/agent-data-layer/org-chart`)

The org chart view renders the team's `orgChart` as an interactive tree:

- **Nodes**: Each bot is a node, colored by role (lead = primary, specialist = secondary, support = muted)
- **Edges**: `reportsTo` defines parent-child edges in the tree
- **Grouping**: Bots are visually grouped by `domain`
- **Escalation overlays**: `escalation.paths` render as highlighted flow arrows when selected
- **Bot detail**: Clicking a node shows the bot's `metadata.description`, `schedule.default`, and `messaging` connections

### MCP Server Page (`/marketplace/tools/{name}`)

| YAML Field | Renders As |
|---|---|
| `metadata.displayName` | Page title, card heading |
| `metadata.description` | Card subtitle, search snippet |
| `metadata.tags` | Search index, tag chips |
| `transport.type` | Transport badge (stdio/sse/streamable-http) |
| `env[].name` | "Required configuration" checklist |
| `env[].description` | Configuration help text |
| `tools[].name` | "Available tools" list |
| `tools[].description` | Tool description |
| `tools[].category` | Tool grouping headers |
| Markdown body after `---` | Long description / documentation tab |

### Built-in Tools Page (`/marketplace/packs/{name}`)

| YAML Field | Renders As |
|---|---|
| `metadata.displayName` | Page title, card heading |
| `metadata.description` | Card subtitle, search snippet |
| `metadata.category` | Category filter pill |
| `metadata.tags` | Search index, tag chips |
| `tools[].name` | "Native functions" list |
| `tools[].description` | Function description |
| `tools[].category` | Function grouping headers |
| Markdown body after `---` | Long description / documentation tab |

### Data Kit Page (`/marketplace/data-kits/{name}`)

| YAML Field | Renders As |
|---|---|
| `metadata.displayName` | Page title, card heading |
| `metadata.description` | Card subtitle, search snippet |
| `metadata.domain` | Domain filter pill, domain badge |
| `metadata.tags` | Search index, tag chips |
| `entityPrefix` | Prefix badge |
| `entityCount` | Entity count badge |
| `graphEdgeTypes` | "Relationships" section |
| `vectorCollections` | "Search Collections" section |
| `compatibility.teams` | "Works with" team badges |
| `compatibility.composableWith` | "Composes with" kit badges |
| Markdown body after `---` | Long description / documentation tab |

### Skill Page (`/marketplace/skills/{name}`)

| YAML Field | Renders As |
|---|---|
| `metadata.displayName` | Page title |
| `metadata.description` | Card subtitle |
| `tools.required` | "Uses tools" badges |
| `data.producesEntityTypes` | "Produces" section |
| `data.consumesEntityTypes` | "Consumes" section |
| `prompt.md` content | Skill instructions display |

## What Happens When You Activate

Every field in a manifest maps to a platform action. When a bot is activated, the platform uses the manifest to compose its identity, install its plugins, make native built-in tools available, connect MCP servers, seed its data, register its schedule, and wire its messaging. For teams, the platform also creates the org chart, sets up escalation routing, and deploys shared resources across all member bots.

See **"What the Platform Does With This Spec"** in [ARCHITECTURE.md](ARCHITECTURE.md) for details on what each field triggers.

## Composability Hierarchy

```
Team (engineering-team)                      ← domain-specific bot team [domain: engineering]
 ├── Data Kit (engineering)                  ← the team's domain data package
 │    ├── Entity Schemas (eng_incidents, eng_deployments, ...)
 │    ├── Graph Templates (AFFECTS, DEPLOYED_TO)
 │    ├── Vector Collections (eng_runbooks)
 │    └── Memory Bootstraps (MTTR KPIs, deployment thresholds)
 ├── Bot (software-architect)                ← top-level agent [lead]
 │    ├── Skill (code-review)                ← reusable capability
 │    ├── Sub-Agent (request-router)         ← internal workflow step
 │    └── Sub-Agent (followup-tracker)
 ├── Bot (code-reviewer)                     ← top-level agent [specialist]
 │    ├── Skill (code-review)
 │    └── Built-in Tools (data-transform)        ← native deterministic functions
 ├── Bot (sre-devops)                        ← top-level agent [specialist]
 │    └── Sub-Agent (incident-analyst)
 ├── Bot (api-tester)                        ← top-level agent [support → code-reviewer]
 ├── Bot (release-manager)                   ← top-level agent [specialist]
 └── Bot (bug-triage)                        ← top-level agent [specialist]
```

**Data Kits** are full-stack domain data packages (entity schemas + graph + vectors + memory + sample data). **Skills** are reusable instructions composed into bots. **Built-in Tools** are native deterministic platform functions that bots can declare when they need domain-specific computation. **Bots** are complete agents with identity, schedule, and messaging. **Sub-agents** are internal to a bot (isolated sessions for workflow steps). **Teams** compose bots into a coordinated group with an org chart, escalation paths, and bundled Data Kits. **MCP Servers** provide external tool endpoints that bots call via the Model Context Protocol. **Plugins** are npm-based runtime extensions for OAuth, memory, channels, and automation.

## Creating Your Own Bot Pack

Any team can create a bot pack repository that the marketplace parser will index. Follow these steps:

### 1. Create a new repository

```
your-org-bots/
├── ARCHITECTURE.md    # Copy from this repo (or reference it)
├── bots/
│   └── your-bot/
│       ├── BOT.md
│       ├── SOUL.md
│       ├── agents/       # Optional
│       └── data-seeds/
│           ├── zone1-north-star.json
│           ├── zone2-entity-types.json
│           └── zone3-initial-memory.json
├── teams/
│   └── your-team/
│       └── TEAM.md
├── skills/               # Optional
│   └── your-skill/
│       ├── SKILL.md
│       └── prompt.md
├── packs/                # Optional -- native deterministic built-in tools
│   └── your-pack/
│       └── PACK.md
└── tools/                # Optional -- MCP server definitions
    └── your-server/
        └── SERVER.md
```

### 2. Write your BOT.md

Every field in the YAML frontmatter is required unless marked optional in the spec. The parser will reject manifests with missing required fields.

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: your-bot              # Must match directory name
  displayName: "Your Bot"     # Shows in marketplace
  version: "1.0.0"
  description: "What this bot does in one line"  # <120 chars
  category: operations        # See category taxonomy below
  tags: ["tag1", "tag2"]
agent:
  capabilities: ["operations"]
  hostingMode: "openclaw"
  defaultDomain: "your-domain"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 10000
  estimatedCostTier: "medium"
schedule:
  default: "@daily"
  recommendations:
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 4h"
messaging:
  listensTo:
    - { type: "alert", from: ["*"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "analysis complete" }
data:
  entityTypesRead: ["relevant_entity_types"]
  entityTypesWrite: ["yb_findings"]
  memoryNamespaces: ["working_notes"]
zones:
  zone1Read: ["mission", "industry"]
  zone2Domains: ["your-domain"]
skills:
  - ref: "skills/your-skill@1.0.0"
toolPacks:                          # Optional -- native deterministic functions
  - ref: "packs/data-transform@1.0.0"
    reason: "Parses uploaded CSV files and normalizes inbound records"
mcpServers:                          # Optional -- MCP servers this bot requires
  - ref: "tools/github"
    required: true
    reason: "Needs GitHub access for issue management"
---

# Your Bot

Extended documentation goes here. This renders as the "About" tab on the marketplace page.
```

### 3. Write your SOUL.md

The agent's identity document. Injected as system context on every run. Keep under 800 tokens.

```markdown
# Your Bot

You are Your Bot, a persistent AI team member for this business.

## Mission
{One sentence core purpose}

## Mandates
1. {First mandatory behavior}
2. {Second mandatory behavior}

## Run Protocol
1. Read messages (adl_read_messages)
2. Read memory (adl_read_memory)
3. Query data (adl_query_records)
4. Analyze and act
5. Write findings (adl_write_record)
6. Update memory (adl_write_memory)
7. Escalate if needed (adl_send_message)

## Escalation
- Critical: message executive-assistant type=alert
```

### 4. Write your TEAM.md

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: your-team
  displayName: "Your Team"
  version: "1.0.0"
  description: "What this team does"
  domain: engineering              # One of the 11 canonical domain slugs
  category: engineering            # Set equal to domain
  tags: ["tag1"]
  author: "your-org"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/bot-a@1.0.0"
  - ref: "bots/bot-b@1.0.0"
  - ref: "bots/bot-c@1.0.0"
toolPacks:                          # Optional -- shared native functions for all team bots
  - ref: "packs/data-transform@1.0.0"
    reason: "Normalize shared CSV and JSON payloads before routing work"
northStar:
  industry: "Software Engineering"  # The team's function, not a business vertical
  context: "Who this team is for"
  requiredKeys:
    - mission
    - tech_stack
orgChart:
  lead: bot-a
  roles:
    - bot: bot-a
      role: lead
      reportsTo: null
      domain: operations
    - bot: bot-b
      role: specialist
      reportsTo: bot-a
      domain: finance
    - bot: bot-c
      role: support
      reportsTo: bot-b
      domain: finance
  escalation:
    critical: bot-a
    unhandled: bot-a
    paths:
      - name: "Budget anomaly"
        trigger: "budget_breach"
        chain: [bot-c, bot-b, bot-a]
mcpServers:                          # Optional -- shared MCP servers for all team bots
  - ref: "tools/github"
    reason: "Shared GitHub access for the whole team"
---

# Your Team

Extended documentation here.
```

### 5. Validate before submitting

Run these checks before submitting your bot pack:

```
Checklist:
[ ] Every BOT.md has valid YAML frontmatter with kind: Bot
[ ] Every SOUL.md is under 800 tokens
[ ] Every bot has data-seeds/ with all 3 zone files (valid JSON)
[ ] metadata.name matches directory name for every manifest
[ ] All skills[].ref point to existing skill directories
[ ] All toolPacks[].ref point to existing packs/ directories
[ ] Every referenced pack has a PACK.md with kind: ToolPack
[ ] All messaging.sendsTo[].to reference valid bot names
[ ] Every TEAM.md has orgChart with exactly one lead
[ ] Every bot in the team appears exactly once in orgChart.roles
[ ] Every escalation path only references bots in the team
[ ] No secrets, API keys, or credentials in any file
[ ] No competitor names or internal pricing
[ ] All mcpServers[].ref point to existing tools/ directories
[ ] MCP server SERVER.md has valid YAML with kind: McpServer
[ ] Markdown body exists after --- for marketplace documentation
```

## Category Taxonomy

Standard categories for `metadata.category` on bots:

| Category | Examples |
|---|---|
| `operations` | executive-assistant, order-fulfillment |
| `engineering` | sre-devops, data-engineer, code-reviewer |
| `finance` | accountant, revenue-analyst |
| `support` | customer-support, customer-onboarding |
| `legal` | legal-compliance, compliance-auditor |
| `marketing` | marketing-growth, social-media-strategist |
| `management` | executive-reporter, mentor-coach |
| `security` | security-agent, fraud-detector |
| `product` | product-owner, ux-researcher |
| `data` | data-quality-monitor, anomaly-detector |
| `logistics` | inventory-manager, shipping-tracker |
| `content` | blog-writer, content-scheduler |

Domain taxonomy for `metadata.domain` on teams and data kits. Teams are domain-specific functions, not whole companies. `metadata.category` is set equal to `metadata.domain` on teams, and to the literal `domain` on data kits.

| Domain | Team | Data Kit |
|---|---|---|
| `customer-service` | customer-service-team | customer-service |
| `marketing` | marketing-team | marketing |
| `sales` | sales-team | sales |
| `engineering` | engineering-team | engineering |
| `finance` | finance-team | finance |
| `operations` | operations-team | operations |
| `product` | product-team | product |
| `data` | data-team | data |
| `hr` | hr-team | hr |
| `legal-compliance` | legal-compliance-team | legal-compliance |
| `leadership` | leadership-team | leadership |

## Inter-Bot Communication

Bots communicate via 4 message types through the ADL message system:

| Type | Semantics | Response Expected |
|------|-----------|-------------------|
| `alert` | Urgent -- recipient must act | Acknowledge + action |
| `request` | Ask for analysis/data | Response with findings |
| `finding` | Informational | Read and incorporate |
| `text` | General | Optional |

See [shared/message-protocol.md](shared/message-protocol.md) for the full protocol including Toon Card format and rate limiting.

## Data Architecture

Bots operate within a three-zone data model:

- **Zone 1 (North Star)**: Company-level data all bots read. Humans write. Contains mission, org chart, industry context, compliance rules.
- **Zone 2 (Shared Domains)**: Domain-scoped working data. Bots in the same domain read/write freely. Cross-domain requires human grant.
- **Zone 3 (Private)**: Per-bot scratch space. Cursors, drafts, session state. Invisible to other bots.

Data seed files (`data-seeds/`) bootstrap these zones at bot activation.

## Disclaimers

**AI-Generated Output.** Bots in this repository are autonomous AI agents. All output they produce -- reports, recommendations, alerts, drafted content, triaged tickets, and any other artifacts -- is AI-generated and may contain errors, omissions, or hallucinations. Human review is required before acting on any bot output.

**No Professional Advice.** Nothing produced by these bots constitutes financial, legal, medical, tax, compliance, or other professional advice. Bots such as `accountant`, `legal-compliance`, and `hr-onboarding` are operational assistants, not licensed professionals. Always consult qualified professionals for decisions in these domains.

**Platform Dependency.** These bot definitions are specifications only. They require an active SchemaBounce workspace with the OpenCLAW runtime to execute. This repository contains no executable code, no API keys, and no credentials. Bot behavior depends on the platform version, model provider availability, and workspace configuration at the time of activation.

**Data Handling.** Bots read and write data within your workspace's scoped zones. You are responsible for the data you provide (North Star configuration, entity records, secrets) and for ensuring it complies with your organization's data governance and privacy policies. SchemaBounce does not access your workspace data except as described in the platform's privacy policy and terms of service.

**No Warranty.** This repository is provided "AS IS" without warranty of any kind. See the [LICENSE](LICENSE) for the full Apache 2.0 terms.

**Trademarks.** SchemaBounce, ClawSink, OpenCLAW, and Kolumn are trademarks of SchemaBounce, Inc. All other trademarks are the property of their respective owners.

## License

Copyright 2024-2026 SchemaBounce, Inc.

Apache License 2.0 -- see [LICENSE](LICENSE) and [NOTICE](NOTICE).
