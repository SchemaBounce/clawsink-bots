# Teams

A Team is a coordinated group of bots that work together under a shared North Star context, org chart, and escalation routing. Teams are the top of the hierarchy — they represent a complete operational unit for a specific business or industry.

**Relationship to Bots**: Teams compose bots via `bots[].ref: "bots/{name}@{version}"`. See [bots/README.md](../bots/README.md) for the bot format.

**Relationship to Plugins**: Teams can declare shared plugins available to all member bots. See [plugins/README.md](../plugins/README.md) for the plugin ecosystem.

**Relationship to MCP Servers**: Teams can declare shared MCP server instances. See [tools/README.md](../tools/README.md) for the MCP server format.

**Relationship to Data Kits**: Teams bundle Data Kits via `dataKits[].ref: "data-kits/{name}@{version}"`. Activating a team auto-installs its referenced kits. See [data-kits/README.md](../data-kits/README.md) for the kit format.

## Directory Structure

```
teams/{team-name}/
└── TEAM.md           # Manifest (kind: Team) — YAML frontmatter parsed by marketplace
```

## TEAM.md Format

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: string           # Kebab-case identifier
  displayName: string    # Human-readable name
  version: string        # SemVer
  description: string    # One-line description
  category: string       # Industry or use-case category
  tags: [string]
  author: string
  license: string
  estimatedMonthlyCost: string  # Estimated cost at default schedules
bots:
  - ref: string          # Reference: "bots/{name}@{version}"
plugins:                 # Shared plugin dependencies for this team (optional)
  - ref: string          # npm package + version
    slot: string         # Plugin slot if exclusive
    reason: string       # Why this team needs this plugin
    config: object       # Team-wide defaults (bots can override)
mcpServers:              # Shared MCP servers for this team (optional)
  - ref: string          # Reference: "tools/{server-name}"
    reason: string       # Why this team needs this server
    config: object       # Team-wide defaults (bots can override)
dataKits:                # Domain data packages bundled with this team (optional)
  - ref: string          # Reference: "data-kits/{name}@{version}"
    required: boolean    # true = primary kit for this team; false = supplementary
    installSampleData: boolean  # Whether to seed sample data (default: false)
northStar:
  industry: string       # Target industry for this team
  context: string        # Description of the ideal user/scenario
  requiredKeys: [string] # North Star keys that must be filled for this team
orgChart:
  lead: string           # Bot that runs the team (top of chain, reports to human)
  roles:
    - bot: string        # Bot name (must match a bots[].ref entry)
      role: string       # "lead" | "specialist" | "support"
      reportsTo: string | null  # Bot this bot reports to (null = reports to human)
      domain: string     # Zone 2 shared domain this bot operates in
  escalation:
    critical: string     # Bot that receives all critical alerts (usually the lead)
    unhandled: string    # Fallback for anything without a matching path
    paths:
      - name: string     # Human-readable escalation path name
        trigger: string  # What triggers it (e.g., "stock_critical", "churn_high")
        chain: [string]  # Ordered bot chain, first to last (last = final escalation)
teamGoals:               # Team-level success metrics (optional)
  - name: string              # Unique within team (snake_case)
    description: string       # Human-readable (<120 chars)
    category: string          # primary | secondary | health
    composedFrom:
      - bot: string           # Bot name (must match bots[].ref)
        goal: string          # Goal name from that bot's goals[]
        weight: number        # 0-1 (optional, weights sum to 1)
    aggregation: string       # average | sum | min | max | worst (default: average)
    target:
      operator: string        # > | < | >= | <= | == | between
      value: number
      period: string          # daily | weekly | monthly
---

# {Display Name}

Extended documentation here. Renders as the team's marketplace page.
```

## Field Rules

- `metadata.name` must match the directory name under `teams/`
- `bots[].ref` must reference valid bot directories
- `northStar.requiredKeys` should list all zone1 keys needed by any bot in the team
- `estimatedMonthlyCost` is calculated from model costs at default schedules
- Teams do NOT override individual bot schedules or models — those are bot-level concerns
- Team-level `plugins` provide shared defaults; individual bot `plugins` can override `config`

## Org Chart

The `orgChart` defines the team's reporting hierarchy and escalation paths. It is a Zone 1 (North Star) data structure — seeded at team activation so all bots can query the org chart. The org chart is rendered visually in the workspace console.

### Roles

Every bot in a team has exactly one role:

| Role | Description | reportsTo | Count |
|------|-------------|-----------|-------|
| `lead` | Top of the team hierarchy. Receives consolidated findings, coordinates all bots. Reports to the human operator. | `null` | Exactly 1 per team |
| `specialist` | Domain expert. Does the core work for its domain. Reports findings to the lead or another specialist. | Another bot in the team | 1 or more |
| `support` | Auxiliary bot that feeds data to a specialist. Reports to its owning specialist. | A specialist bot | 0 or more |

The hierarchy creates a tree: human -> lead -> specialists -> support bots.

### Domains

Each bot is assigned to a Zone 2 shared domain via `roles[].domain`. Bots in the same domain share read/write access to domain-scoped entity records. Domains are team-specific and industry-appropriate:

- Restaurant: `kitchen-ops`, `front-of-house`, `finance`, `marketing`
- Software team: `engineering`, `quality`, `devops`, `project-management`
- Healthcare: `patient-care`, `compliance`, `administration`, `billing`
- Generic fallback: `operations`, `finance`, `management`, `customer-relations`

Multiple bots can share a domain. This enables coordination through shared state — bots in the same domain read each other's entity records without explicit message passing.

### Escalation

The `escalation` block defines how alerts propagate through the team:

- `critical`: Bot that receives ALL critical-severity alerts regardless of domain. Usually the lead.
- `unhandled`: Fallback for alerts that don't match any defined path. Usually the lead.
- `paths[]`: Named escalation chains for specific scenarios. Each path has:
  - `name`: Human-readable description (shown in the org chart UI)
  - `trigger`: Machine-readable trigger identifier (used by the runtime to route alerts)
  - `chain`: Ordered list of bots from first responder to final escalation

### Relationship to Global Escalation Chains

The `shared/escalation-chains.json` file defines global default routing for bots operating outside a team context. When a bot is activated within a team, the team's `orgChart.escalation` takes precedence. Both can coexist — the runtime resolves team-level first, then falls back to global.

### Org Chart Field Constraints

- `orgChart.lead` must match one bot in `bots[].ref`
- Every bot in `bots[].ref` must appear exactly once in `orgChart.roles`
- Exactly one role has `role: "lead"` — this bot has `reportsTo: null`
- `role` must be one of: `lead`, `specialist`, `support`
- `reportsTo` must reference another bot in the team's roles, or `null` for the lead
- `domain` is kebab-case, max 30 characters
- `escalation.critical` and `escalation.unhandled` must reference bots in the team
- `escalation.paths[].chain` must only contain bots in the team
- At least one escalation path is required per team

## Team-Level Plugins

Team-level `plugins[]` install shared plugins available to all bots in the team. Bot-level `plugins[]` layer on top. Slot conflicts between team-level and bot-level declarations are rejected at validation time.

## Team-Level MCP Servers

Team-level `mcpServers[]` creates a single shared server instance for all bots in the team. Individual bots can override `config` in their own `mcpServers[]` section — bot config is merged on top of team config.

## Team-Level Data Kits

Team-level `dataKits[]` bundles domain data packages that auto-install when the team is activated. Each kit provides entity schemas, graph relationship templates, vector search configurations, and memory bootstraps that the team's bots are designed to use.

- **`required: true`**: Primary kit for this team — installed automatically, cannot be skipped
- **`required: false`**: Supplementary kit — installed by default but user can opt out
- **`installSampleData: false`**: Default; set to `true` to seed example records during installation

Installation is idempotent — if a kit is already installed (e.g., from another team), it is skipped. Kits use entity prefixes to avoid name collisions when multiple kits coexist.

See [data-kits/README.md](../data-kits/README.md) for the full kit manifest specification.

## Team Goals Section

The `teamGoals:` section declares team-level success metrics that compose from individual bot goals. This enables rollup: bot goals → team health → workspace ROI.

### How Team Goals Compose

Each team goal references one or more bot goals via `composedFrom`. The platform reads the individual bot `bot_goal_health` records and aggregates them using the specified `aggregation` method and optional `weight` values.

| Aggregation | Behavior |
|-------------|----------|
| `average` | Weighted average of member bot goal values (default) |
| `sum` | Sum of all member bot goal values |
| `min` | Minimum value across member bots (best case) |
| `max` | Maximum value across member bots (worst case) |
| `worst` | Lowest achievement rate across member bots (bottleneck identifier) |

### Team Health Derivation

The platform computes team health as a weighted composite:
- **40%** — Member bot readiness (average setup completion across all bots)
- **40%** — Member bot goal achievement (average primary goal achievement rate)
- **20%** — Inter-bot communication health (messages flowing as declared in messaging)

### Example

```yaml
teamGoals:
  - name: issue_resolution_rate
    description: "Customer issues resolved without human intervention"
    category: primary
    composedFrom:
      - bot: customer-support
        goal: resolve_tickets
        weight: 0.7
      - bot: knowledge-base-curator
        goal: answer_coverage
        weight: 0.3
    target:
      operator: ">"
      value: 0.7
      period: weekly
  - name: team_responsiveness
    description: "Average time from issue to first bot action"
    category: secondary
    composedFrom:
      - bot: customer-support
        goal: first_response_time
      - bot: social-media-monitor
        goal: mention_response_time
    aggregation: average
    target:
      operator: "<"
      value: 15
      period: daily
```

## Validation

1. `TEAM.md` has valid YAML frontmatter with `kind: Team`
2. All `bots[].ref` reference existing bot directories with matching versions
3. `northStar.requiredKeys` is the union of all `zones.zone1Read` keys from member bots
4. `estimatedMonthlyCost` matches calculated cost from model/schedule combinations
5. All `plugins[].ref` are valid npm package specs
6. No conflicting plugin slots between team-level and bot-level declarations
7. `orgChart.lead` references a bot in `bots[].ref`
8. Every bot in `bots[].ref` appears exactly once in `orgChart.roles`
9. Exactly one role has `role: "lead"` with `reportsTo: null`
10. All `orgChart.roles[].reportsTo` reference valid bots in the team (or null for lead)
11. `escalation.critical` and `escalation.unhandled` reference bots in the team
12. All bots in `escalation.paths[].chain` are members of the team
13. All `mcpServers[].ref` reference valid `tools/` directories containing `SERVER.md`
14. No conflicting MCP server configs between team-level and bot-level declarations
15. All `dataKits[].ref` reference valid `data-kits/` directories containing `KIT.md`
16. No duplicate kit references within a single team
17. `teamGoals[].name` is unique within the team and snake_case
18. `teamGoals[].category` is one of: `primary`, `secondary`, `health`
19. `teamGoals[].composedFrom[].bot` must reference a bot in `bots[].ref`
20. `teamGoals[].composedFrom[].goal` must reference a valid goal name from the referenced bot's `goals[]`
21. `teamGoals[].composedFrom[].weight` values must sum to 1.0 when weights are specified
22. `teamGoals[].aggregation` is one of: `average`, `sum`, `min`, `max`, `worst`
23. `teamGoals[].target.period` is one of: `daily`, `weekly`, `monthly`

## What the Platform Does

| You Provide | The Platform Will |
|-------------|-------------------|
| `bots[].ref` | Activate each bot (full bot activation) |
| `plugins[]` (team-level) | Install shared plugins available to all bots in the team |
| `mcpServers[]` (team-level) | Make shared MCP server tools available to all bots in the team |
| `northStar.requiredKeys` | Prompt the user to fill in required business context before bots run |
| `orgChart.roles` | Create the team's reporting hierarchy, visible in the org chart view |
| `orgChart.roles[].domain` | Group bots by domain — bots in the same domain share working data |
| `orgChart.escalation` | Set up escalation routing that overrides the global defaults |
| `dataKits[].ref` | Auto-install referenced Data Kits (entity schemas, graph templates, vector collections, memory bootstraps) |
| `dataKits[].installSampleData` | Optionally seed sample data from the kit |
| `teamGoals` | Aggregate member bot goal health into team-level metrics; render team health dashboard |

Team-level plugins and MCP servers are shared — you don't need to redeclare them on every bot. Bot-level `config` overrides team-level `config` for the same plugin or MCP server.

## Canonical Example

See [`restaurant-group/`](restaurant-group/) for a complete team with orgChart, escalation paths, and industry-specific domains.
