# Bots

A Bot is a complete agent definition with identity, model, schedule, messaging, and composed skills. Bots are always top-level agents — they are the unit of deployment and execution.

**Relationship to Teams**: Bots are grouped into teams via `bots[].ref: "bots/{name}@{version}"` in TEAM.md. See [teams/README.md](../teams/README.md) for team composition.

**Relationship to Skills**: Bots compose skills via `skills[].ref: "skills/{name}@{version}"`. Each skill's `prompt.md` is appended to the bot's system prompt. See [skills/README.md](../skills/README.md) for the skill format.

**Relationship to Tool Packs**: Bots declare native deterministic tool dependencies via `toolPacks[].ref: "packs/{name}@{version}"`. See [packs/README.md](../packs/README.md) for the tool pack format.

**Relationship to Plugins**: Bots declare plugin dependencies via `plugins[].ref`. See [plugins/README.md](../plugins/README.md) for the plugin ecosystem.

**Relationship to MCP Servers**: Bots declare MCP server dependencies via `mcpServers[].ref`. See [tools/README.md](../tools/README.md) for the MCP server format.

## Directory Structure

```
bots/{bot-name}/
├── BOT.md            # Manifest (kind: Bot) — YAML frontmatter parsed by marketplace
├── SOUL.md           # Agent identity document (<800 tokens)
├── agents/           # Sub-agent definitions (optional, Claude Code format)
│   ├── researcher.md
│   ├── writer.md
│   └── editor.md
└── data-seeds/       # Bootstrap data for ADL zones
    ├── zone1-north-star.json
    ├── zone2-entity-types.json
    └── zone3-initial-memory.json
```

## BOT.md Format

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: string           # Kebab-case identifier, unique across all bots
  displayName: string    # Human-readable name
  version: string        # SemVer (e.g., "1.0.0")
  description: string    # One-line description (<120 chars)
  category: string       # One of: operations, engineering, finance, support, legal, marketing, management
  tags: [string]         # Searchable tags
agent:
  capabilities: [string] # OpenClaw capability identifiers
  hostingMode: string    # "openclaw" (managed) or "self-hosted"
  defaultDomain: string  # ADL domain this bot operates in
  instructions: |        # Operating rules → injected as AGENTS.md in runtime
    ## Operating Rules
    - Rule 1: domain-specific behavioral rule
    - Rule 2: what to always do before acting
    - Rule 3: escalation criteria
  toolInstructions: |    # Tool conventions → injected as TOOLS.md in runtime
    ## Tool Usage
    - Use adl_query_records with entity_type="x" for lookups
    - Write findings with adl_upsert_record to entity_type="x_findings"
    - Store unstructured analysis with adl_add_memory
model:
  provider: string       # "anthropic" or "openai"
  preferred: string      # Model ID for normal runs
  fallback: string       # Model ID if preferred unavailable
  thinkLevel: null | string  # null, "low", "medium", "high"
cost:
  estimatedTokensPerRun: int    # Typical token consumption per run
  estimatedCostTier: string     # "low", "medium", or "high"
schedule:
  default: string        # Cron expression or @every interval
  recommendations:
    light: string
    standard: string
    intensive: string
messaging:
  listensTo:
    - type: string       # Message type: alert, request, finding, text, approval, decision, info, directive
      from: [string]     # Bot names or ["*"] for all
  sendsTo:
    - type: string
      to: [string]
      when: string       # Human-readable trigger condition
data:
  entityTypesRead: [string]
  entityTypesWrite: [string]
  memoryNamespaces: [string]
zones:
  zone1Read: [string]    # North Star keys this bot reads
  zone2Domains: [string] # Shared domains this bot accesses
skills:                  # Skill composition
  - ref: string          # Reference to shared skill: "skills/{name}@{version}"
toolPacks:               # Native deterministic tools (optional)
  - ref: string          # Reference: "packs/{name}" or "packs/{name}@{version}"
    reason: string       # Why this bot needs this native tool pack
plugins:                 # OpenCLAW plugin dependencies (optional)
  - ref: string          # npm package + version: "{name}@{version}"
    slot: string         # Plugin slot if exclusive (e.g., "memory", "channel")
    required: boolean    # true (default) = bot won't start without it
    reason: string       # Why this bot needs this plugin
    config: object       # Bot-specific config (merged with workspace defaults)
mcpServers:              # Custom MCP servers this bot requires (optional)
  - ref: string          # Reference: "tools/{server-name}"
    required: boolean    # true (default) = bot won't start without it
    reason: string       # Why this bot needs this server
    config: object       # Bot-specific config overrides (no secrets)
presence:                # External identity requirements (optional)
  email:
    required: boolean    # true = provision on activation; false = optional setup later
    provider: string     # "agentmail" (only supported provider for v1)
    displayName: string  # Template: "{bot-name}@{workspace}.agents.schemabounce.com"
  web:
    browsing: boolean    # Needs hyperbrowser for interactive web automation
    search: boolean      # Needs exa for semantic web search
    crawling: boolean    # Needs firecrawl for fast data extraction
  voice:
    required: boolean    # Requires admin approval (recurring cost)
    provider: string     # "elevenlabs"
    voiceProfile: string # Voice style hint: "professional", "friendly", "authoritative"
  phone:
    required: boolean    # Requires admin approval (real phone number + cost)
    provider: string     # "agentphone"
egress:                  # External network access policy (optional)
  mode: string           # "open" | "llm-only" | "restricted" | "none" (default: llm-only)
  allowedDomains:        # Only used when mode is "restricted"
    - string             # Exact domain or wildcard: "api.stripe.com", "*.github.com"
requirements:
  minTier: string        # Minimum workspace tier
setup:                   # Per-bot setup steps (optional)
  steps:
    - id: string              # Unique within bot (kebab-case)
      name: string            # Human-readable (<60 chars)
      description: string     # What this does and why (<200 chars)
      type: string            # mcp_connection | secret | config | data_presence | north_star | manual
      group: string           # connections | configuration | data | external
      priority: string        # required | recommended | optional
      reason: string          # Why the bot needs this (<200 chars)
      ref: string             # mcp_connection: "tools/{name}"
      secretName: string      # secret: workspace secret key name
      entityType: string      # data_presence: entity type to check
      minCount: int           # data_presence: minimum record count
      target:                 # config: where value is stored
        namespace: string
        key: string
      key: string             # north_star: zone1 key name
      ui:                     # Frontend rendering hints
        icon: string
        inputType: string     # password | text | number | slider | select | toggle
        actionLabel: string
        placeholder: string
        helpUrl: string
        validationHint: string
        instructions: string  # Multi-line (manual type)
        min: number
        max: number
        step: number
        unit: string
        default: any
        options:
          - value: string
            label: string
        prefillFrom: string   # Auto-fill source (e.g., "workspace.industry")
        emptyState: string    # data_presence: empty message
goals:                   # Success metrics (optional)
  - name: string              # Unique within bot (snake_case)
    description: string       # Human-readable (<120 chars)
    category: string          # primary | secondary | health
    metric:
      type: string            # count | rate | threshold | boolean
      entity: string          # Entity type to measure
      filter: object          # Field-value filter (optional)
      source: string          # "memory" for memory-based metrics
      namespace: string       # Memory namespace (when source=memory)
      numerator: { entity: string, filter: object }   # rate type
      denominator: { entity: string, filter: object }  # rate type
      measurement: string     # threshold type: what's measured
      check: string           # boolean type: what to check
    target:
      operator: string        # > | < | >= | <= | == | between
      value: number           # Target value
      period: string          # per_run | daily | weekly | monthly
      condition: string       # Human-readable qualifier (optional)
    feedback:                 # User feedback loop (optional)
      enabled: boolean
      entityType: string      # Which records get feedback buttons
      actions:
        - value: string
          label: string
---

# {Display Name}

Extended documentation here. Renders as the bot's marketplace page.
```

## Bootstrap Instructions (`agent.instructions` + `agent.toolInstructions`)

The `agent:` block contains two fields that become the bot's runtime system prompt sections:

| Field | Runtime Section | Purpose |
|-------|----------------|---------|
| `agent.instructions` | **AGENTS.md** | Operating rules, guardrails, escalation criteria, cross-bot coordination |
| `agent.toolInstructions` | **TOOLS.md** | Tool usage conventions, entity type patterns, memory namespace rules |

Both are YAML multiline strings (`|`) nested inside the `agent:` block. They are injected into every agent run alongside SOUL.md and IDENTITY.md.

### Writing Good Instructions

- 5-10 bullet points covering ALWAYS/NEVER rules specific to this bot's domain
- Reference actual entity types from `data.entityTypesRead` and `data.entityTypesWrite`
- Reference actual memory namespaces from `data.memoryNamespaces`
- Reference actual messaging targets from `messaging.sendsTo`
- Include escalation criteria: when to alert vs. log as finding
- Include token budget awareness if the bot has expensive analysis patterns

### Writing Good Tool Instructions

- Which entity types to query with `adl_query_records` and their filter patterns
- Which entity types to write with `adl_upsert_record` and their ID format conventions
- When to use `adl_add_memory` (unstructured) vs `adl_write_memory` (structured)
- When to use `adl_semantic_search` vs `adl_query_records`
- Batch operation preferences (`bulk_upsert` for >3 records)
- Memory namespace conventions from `data.memoryNamespaces`

## Skills Section

The `skills:` section lists capabilities this bot uses:

- `ref: "skills/{skill-name}@{version}"` — references a shared skill from the `skills/` directory. The skill's `prompt.md` is appended to the bot's SOUL.md at runtime.

Skills are composed in the order listed. SOUL.md always comes first in the final system prompt.

## Tool Packs Section

The `toolPacks:` section declares native deterministic function bundles that run inside the ADL runtime. Use tool packs when the bot needs structured computation, parsing, formatting, or domain-specific helpers without making external network calls.

- `ref` must point to a valid `packs/` directory containing a `PACK.md`
- Version suffix is optional; if present, it must be SemVer (`@1.0.0`)
- `reason` is required and non-empty — explain why the bot needs the pack
- Tool packs are native platform functions, not external integrations

### Example

```yaml
toolPacks:
  - ref: "packs/data-transform@1.0.0"
    reason: "Normalize CSV uploads and reshape structured records before writing findings"
  - ref: "packs/document-gen@1.0.0"
    reason: "Generate deterministic reports and summaries from structured data"
```

## Plugins Section

The `plugins:` section declares OpenCLAW plugin dependencies — npm-based TypeScript modules that extend the runtime with channels, memory backends, OAuth managers, tools, and background services.

### Plugin Categories

| Category | Slot | Examples | What It Adds |
|----------|------|----------|-------------|
| **Channel** | `channel` | `microsoft-teams`, `voice-call`, `wacli` | Messaging channels (Teams, phone, WhatsApp) |
| **Memory** | `memory` | `memory-lancedb`, `memos-cloud` | Vector recall, cross-agent memory |
| **OAuth** | `oauth` | `composio` | Managed OAuth for 860+ apps |
| **Workflow** | — | `n8n-workflow` | External workflow orchestration |
| **Workspace** | — | `gog` | Google Workspace (Gmail, Calendar, Drive, Docs) |

Plugins with a `slot` are exclusive — only one plugin per slot loads at a time.

### Plugin Field Rules

- `plugins[].ref` must be a valid npm package spec (name + semver range)
- `plugins[].reason` is required and non-empty — explain why, not just what
- `plugins[].config` must NEVER contain secrets (API keys, tokens, passwords) — those go in workspace secrets
- `plugins[].slot` should match OpenCLAW's slot taxonomy when the plugin is exclusive
- `plugins[].required` defaults to `true` — set to `false` for nice-to-have plugins

### Example

```yaml
plugins:
  - ref: "composio@latest"
    slot: "oauth"
    reason: "Managed OAuth for blog API — handles token refresh and scoping"
    config:
      apps: ["blog"]
      scopes: ["blog:write"]
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    reason: "Vector recall for editorial history and topic research across runs"
```

## MCP Servers Section

The `mcpServers:` section declares MCP server dependencies. See [tools/README.md](../tools/README.md) for the full SERVER.md format and transport types.

- `ref` must point to a valid `tools/` directory containing a `SERVER.md`
- `required` defaults to `true` — the bot won't start without this server
- `config` is merged with team-level config (bot overrides team)
- `config` must NEVER contain secrets

## Presence Section

The `presence:` section declares what external identity capabilities a bot needs. Unlike `mcpServers:` (which connects tools) or `plugins:` (which extends the runtime), `presence:` triggers **identity provisioning** — creating email addresses, phone numbers, or voice identities when the bot is deployed as an agent.

### Sub-Sections

| Sub-section | What it provisions | Provider | Admin approval? |
|-------------|-------------------|----------|-----------------|
| `email` | Email inbox (send/receive) | `agentmail` | No |
| `web.browsing` | Browser access (interactive) | `hyperbrowser` | No |
| `web.search` | Semantic web search | `exa` | No |
| `web.crawling` | Fast data extraction | `firecrawl` | No |
| `voice` | Voice identity (TTS/STT/calls) | `elevenlabs` | Yes |
| `phone` | Phone number (SMS/calls) | `agentphone` | Yes |

### How Presence Works with MCP Servers

Every `presence:` provider has a corresponding MCP server in `tools/`. The bot should declare BOTH:

1. `presence:` — tells the platform to **provision** the identity on activation
2. `mcpServers:` — gives the bot **tool access** to use the provisioned identity

```yaml
# Example: bot with email presence
presence:
  email:
    required: true
    provider: agentmail
mcpServers:
  - ref: "tools/agentmail"
    required: true
    reason: "Send weekly reports and respond to client emails"
```

Web capabilities (`web.browsing`, `web.search`, `web.crawling`) don't provision external accounts — they only need tool access. You can declare them in `presence:` for documentation and set `true/false`, but the actual capability comes from the matching `mcpServers:` entry.

### Field Rules

- `presence.email.required: true` means activation FAILS if email can't be provisioned
- `presence.voice` and `presence.phone` always require admin approval regardless of `required` value
- `presence.email.displayName` supports templates: `{bot-name}`, `{workspace}` are substituted at runtime
- If a bot declares `presence.email` without a matching `mcpServers` entry for `tools/agentmail`, validation fails
- Omit `presence:` entirely for internal-only bots that don't need external identity

## Egress Section

The `egress:` section declares which external HTTPS endpoints the bot needs to reach via the proxy token system (`request_proxy_token` → `execute_proxy_call`). When a bot is deployed to a seat, the `egress` section auto-populates the seat's `manifest.egressPolicy`. The admin can override it per-seat.

- `mode` defaults to `llm-only` (no proxy calls allowed, LLM calls via ClawShell still work)
- `open` allows the agent to reach any public HTTPS endpoint
- `restricted` limits the agent to only the domains listed in `allowedDomains`
- `none` blocks all external access (both proxy calls and direct HTTP)
- Wildcard domains: `*.stripe.com` matches `sub.stripe.com` but NOT `stripe.com.evil.tld`

```yaml
egress:
  mode: restricted
  allowedDomains:
    - "api.stripe.com"
    - "*.github.com"
    - "hooks.slack.com"
```

## Setup Section

The `setup:` section declares per-bot prerequisite steps that must be completed before the bot can do its job. Each step is typed so the platform can validate it automatically and the frontend can render a setup modal.

### Step Types

| Type | Auto-validates? | How | Frontend Component |
|------|----------------|-----|-------------------|
| `mcp_connection` | Yes | Ping MCP server, check tools accessible | Connect button + status badge |
| `secret` | Yes | Check workspace secrets for named key (non-empty) | Masked text input + save |
| `config` | Yes | Check memory namespace/key exists, type-validate | Varies by `ui.inputType` |
| `data_presence` | Yes | Query entity type, check count >= minCount | Count badge + import button |
| `north_star` | Yes | Check zone1 for key presence | Input (pre-filled from workspace) |
| `manual` | No | User attestation (checkbox) | Checkbox + instruction card |

### Step Groups

Steps are grouped for UI rendering:

| Group | Contains | Modal section |
|-------|---------|--------------|
| `connections` | MCP server connections, OAuth flows | "Connect Your Services" |
| `configuration` | Thresholds, preferences, North Star values | "Configure Settings" |
| `data` | Required entity records, imports | "Prepare Your Data" |
| `external` | Manual steps done outside the platform | "External Setup" |

### Readiness Levels

The platform derives a readiness level from step completion:

| Level | Condition | Bot Behavior |
|-------|-----------|-------------|
| `blocked` | Any `required` step incomplete | Bot will NOT run. Schedule skipped. |
| `operational` | All `required` steps complete | Bot runs. May have reduced capability. |
| `fully_configured` | All `required` + `recommended` complete | Bot runs at full capability. |
| `optimized` | All steps complete | Bot has every possible advantage. |

### ADL Integration

Setup status is stored as a `bot_setup_status` entity in the ADL. Bots can read their own setup status on each run to adjust behavior (skip actions that require missing connections, report setup issues in their run report). The platform-optimizer bot reads setup status across all bots to identify systematic gaps and recommend fixes.

### UI Contract

The frontend renders setup steps as a modal:
- Steps grouped by `group` (connections -> configuration -> data -> external)
- Within groups, ordered by priority (required first)
- Each step renders as its type-specific component using `ui:` hints
- Progress bar: "N of M required steps complete"
- "Activate Bot" button enabled when all `required` steps are green
- Re-validation on revisit (connections may have broken)

### Example

```yaml
setup:
  steps:
    - id: connect_stripe
      name: "Connect Stripe"
      description: "Reads transaction data for fraud pattern analysis"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Primary data source for transaction monitoring"
      ui:
        icon: stripe
        actionLabel: "Connect Stripe"
    - id: fraud_threshold
      name: "Set fraud score threshold"
      description: "Transactions above this score are flagged for review"
      type: config
      group: configuration
      target: { namespace: thresholds, key: fraud_score_cutoff }
      priority: required
      reason: "Cannot flag transactions without a detection threshold"
      ui:
        inputType: slider
        min: 0.5
        max: 0.99
        step: 0.01
        default: 0.8
    - id: enable_webhooks
      name: "Enable payment webhooks"
      description: "Set up your payment processor to send real-time events"
      type: manual
      group: external
      priority: recommended
      reason: "Real-time transaction feed for immediate detection"
      ui:
        actionLabel: "I've enabled webhooks"
        instructions: |
          1. Go to Stripe Dashboard -> Developers -> Webhooks
          2. Add your SchemaBounce webhook endpoint
          3. Select events: charge.succeeded, charge.failed, charge.disputed
```

## Goals Section

The `goals:` section declares what success looks like for this bot. Goals are named, measurable, and the bot self-reports progress against them in a structured `run_report` each execution.

### Goal Categories

| Category | Purpose | Dashboard Placement |
|----------|---------|-------------------|
| `primary` | Core mission metrics -- why this bot exists | Front and center, big numbers |
| `secondary` | Quality/efficiency metrics | Expandable detail section |
| `health` | Bot self-improvement and operational health | Status indicators (green/yellow/red) |

### Metric Types

| Type | Measures | Example |
|------|---------|---------|
| `count` | Entity records matching criteria | "Flagged 12 transactions" |
| `rate` | Ratio of two entity counts | "85% detection accuracy" |
| `threshold` | Numeric value against a target | "Avg 3.2 min response time" |
| `boolean` | Did/didn't happen | "Published weekly report: yes" |

### User Feedback Loop

Goals with `feedback.enabled: true` render action buttons on entity records in the UI. Users can confirm or reject bot output (e.g., "Confirmed fraud" / "Not fraud"). Feedback is stored on the entity record and read by the bot on subsequent runs to improve `rate`-type metrics.

### Run Reports

Every bot writes a `run_report` entity as its last action each run. The run report includes goal status, setup issues, blockers, and an overall productivity assessment. See [shared/output-format.md](../shared/output-format.md) for the full schema.

### ADL Integration

Goal health is aggregated by the platform into `bot_goal_health` entity records. Bots can read their own goal trends. The platform-optimizer bot reads goal health across all bots and recommends improvements.

### Example

```yaml
goals:
  - name: flag_suspicious_transactions
    description: "Identify and flag potentially fraudulent transactions"
    category: primary
    metric:
      type: count
      entity: fraud_findings
      filter: { severity: ["high", "critical"] }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when new transactions exist"
  - name: detection_accuracy
    description: "Minimize false positives in fraud flagging"
    category: primary
    metric:
      type: rate
      numerator: { entity: fraud_findings, filter: { feedback: "confirmed" } }
      denominator: { entity: fraud_findings, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.85
      period: weekly
    feedback:
      enabled: true
      entityType: fraud_findings
      actions:
        - { value: confirmed, label: "Confirmed fraud" }
        - { value: false_positive, label: "Not fraud" }
  - name: pattern_learning
    description: "Continuously improve by learning new fraud patterns"
    category: health
    metric:
      type: count
      source: memory
      namespace: learned_patterns
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
```

## SOUL.md — Agent Identity Specification

### Purpose

SOUL.md defines WHO the agent is -- personality, expertise, decision-making authority, communication style, domain constraints, and execution protocol. It is the LLM system prompt, injected every turn. It is NOT operating instructions (those go in BOT.md `agent.instructions` which becomes AGENTS.md) and NOT tool usage conventions (those go in BOT.md `agent.toolInstructions` which becomes TOOLS.md).

### Architecture Context

OpenClaw injects bootstrap files into every LLM call:

| File | Source | Purpose |
|------|--------|---------|
| **Platform Prompt** | OpenCLAW runtime (automatic) | 7-section invisible prompt layer (identity, discipline, safety, tools, output, memory, comms) |
| **SOUL.md** | `bots/{name}/SOUL.md` | System prompt (identity, personality, expertise, constraints, run protocol) |
| **AGENTS.md** | BOT.md `agent.instructions` | Operating instructions |
| **TOOLS.md** | BOT.md `agent.toolInstructions` | Tool conventions |
| **IDENTITY.md** | Generated from BOT.md metadata | Lightweight metadata (name, emoji, vibe) |
| **USER.md** | Workspace user profile | User profile (injected in main session only) |

SOUL.md is for IDENTITY + CONSTRAINTS + RUN PROTOCOL. AGENTS.md is for OPERATING INSTRUCTIONS. Never mix them.

### Platform Prompt Layer (Automatic)

The OpenCLAW runtime automatically injects a platform-level prompt before every agent's SOUL.md. Bot authors do NOT need to include these rules -- they are applied invisibly:

1. **Platform Identity** -- positions the agent as a platform worker with cost awareness
2. **Execution Discipline** -- anti-slop, anti-hallucination, numeric output anchors
3. **Operational Safety** -- blast radius awareness, tiered action permissions
4. **Tool Discipline** -- tool selection guidance, call budgets (target 3-5, max 8)
5. **Output Quality** -- false claims mitigation, severity calibration, entity ID discipline
6. **Memory Discipline** -- decay classes, zone rules, tool selection, anti-patterns
7. **Inter-Agent Communication** -- message rate limits, delegation limits, escalation rules

**Output Style Modes** are also automatic based on task type:
- `terse` for scheduled/CDC runs -- records only, no prose
- `conversational` for chat -- natural language, suggest next steps
- `detailed` for reports -- headers, methodology, exec summary

Do NOT duplicate these rules in SOUL.md. Focus SOUL.md on domain-specific identity, expertise, constraints, and run protocol.

### Required Sections

```markdown
# {Display Name}

I am {Name}, the {role descriptor} for {domain/context}.

## Mission
{One compelling sentence about WHY this role exists -- the outcome, not the task}

## Expertise
{2-3 sentences about deep domain knowledge. What does this agent understand
that others don't? What patterns does it recognize? What connections does it make?}

## Decision Authority
- I decide: {what this agent handles autonomously -- scoring, prioritization, classification}
- I escalate: {what requires human judgment or cross-team coordination}

## Communication Style
{How this agent communicates -- tone, format, emphasis. What it never does.
How it frames recommendations.}

## Constraints
{3-5 domain-specific NEVER rules -- see "Constraints Section" below}

## Run Protocol
{8-10 numbered steps -- see "Run Protocol Section" below}
```

### Rules

1. **First person**: Always "I am", never "You are"
2. **Under 800 tokens**: Injected every LLM turn, tokens cost money
3. **No entity type lists**: Never list `entityTypesRead/Write` -- those belong in BOT.md `data` section
4. **No memory namespace lists**: Never list working_notes, learned_patterns, etc.
5. **Domain knowledge YES**: Scoring thresholds, decision frameworks, industry rules ARE identity ("I require p < 0.05 before declaring a winner")
6. **Personality YES**: Preferences, style, what the agent cares about ARE identity ("I never round numbers" or "I lead with the one thing that matters most")
7. **Constraints YES**: Domain-specific NEVER rules belong in SOUL.md (generic platform rules do NOT)
8. **Run protocol YES**: The 8-10 step execution sequence with ADL tool names belongs in SOUL.md

### Anti-Patterns

**BAD** -- instructions masquerading as identity, missing constraints and run protocol:

```markdown
You are Accountant, a persistent AI team member responsible for financial tracking.

## Mandates
1. Always categorize transactions
2. Check for duplicates
3. Run budget comparison

## Entity Types
- Read: transactions, invoices, budgets
- Write: acct_findings
```

Problems: "You are" instead of "I am". Mandates are instructions (belong in AGENTS.md). Entity Types are data declarations (belong in BOT.md). Missing required sections: Constraints and Run Protocol.

**GOOD** -- identity-focused with constraints and run protocol:

```markdown
# Accountant

I am the Accountant, the financial guardian of this business.

## Mission
Provide financial clarity that enables good decisions -- every transaction tells a story, every anomaly is a clue.

## Expertise
I categorize with precision, budget with discipline, and flag fraud with urgency. I understand that a duplicate invoice is not just a clerical error -- it is a control failure. I know the difference between a seasonal spending pattern and a budget breach.

## Decision Authority
- I decide: categorization, budget threshold alerts, anomaly flagging with deviation percentages
- I escalate: payment failures, billing system errors, suspected fraud patterns

## Communication Style
Precise, factual, and structured. I report in percentages and deviations, not adjectives. I never round, never guess, and never let an uncategorized transaction sit overnight.

## Constraints
- NEVER categorize a transaction you're uncertain about -- flag for human review instead
- NEVER auto-approve expenses above the configured threshold -- route to executive-assistant
- NEVER treat a duplicate invoice as a data entry error by default -- investigate as potential fraud
- NEVER report budget figures without comparison to the prior period

## Run Protocol
1. Read messages (adl_read_messages) -- check for requests from other agents
2. Read memory (adl_read_memory key: last_run_state) -- get last run timestamp
3. Delta query (adl_query_records filter: created_at > {last_run_timestamp} entity_type: transactions) -- only new transactions
4. If nothing new and no messages: update last_run_state (adl_write_memory). STOP.
5. Categorize each transaction using chart of accounts rules; flag uncertain ones
6. Run budget comparison -- deviation percentages against current period targets
7. Write findings (adl_upsert_record entity_type: acct_findings)
8. Alert if critical (adl_send_message type: alert to: executive-assistant) -- fraud, payment failures, budget breaches >20%
9. Route non-critical findings to relevant agent (adl_send_message type: finding)
10. Update memory (adl_write_memory key: last_run_state with timestamp + summary)
```

### Constraints Section (Required)

Every SOUL.md MUST include a `## Constraints` section with 3-5 domain-specific NEVER rules. These are guardrails that prevent the agent from making domain-specific mistakes.

**Format:** Each constraint uses "NEVER X -- Y instead" pattern.

**Rules:**
- Constraints must be specific to the bot's domain, NOT generic platform rules
- Generic rules (don't hallucinate, don't exceed tool budget) are handled by the platform prompt layer -- do not duplicate them
- 3-5 constraints per bot (enough to cover key failure modes, not so many they dilute impact)

**Good constraints (domain-specific):**

```markdown
## Constraints
- NEVER auto-publish content -- always submit as draft for human review
- NEVER categorize a transaction you're uncertain about -- flag for human review instead
- NEVER assign P0 to more than one issue simultaneously -- escalate to executive-assistant
```

**Bad constraints (too generic -- already in platform layer):**

```markdown
## Constraints
- NEVER hallucinate data  <-- platform layer handles this
- NEVER exceed 8 tool calls  <-- platform layer handles this
- NEVER send more than 5 messages  <-- platform layer handles this
```

### Run Protocol Section (Required)

Every SOUL.md MUST include a `## Run Protocol` section with 8-10 numbered steps defining the agent's execution sequence. Use specific ADL tool names.

**Standard template:**

```markdown
## Run Protocol
1. Read messages (adl_read_messages) -- check for requests from other agents
2. Read memory (adl_read_memory key: last_run_state) -- get last run timestamp
3. Delta query (adl_query_records filter: created_at > {last_run_timestamp}) -- only new items
4. If nothing new and no messages: update last_run_state (adl_write_memory). STOP.
5. [Domain-specific analysis step]
6. [Domain-specific processing step]
7. Write findings (adl_upsert_record entity_type: {role}_findings)
8. Alert if critical (adl_send_message type: alert to: executive-assistant)
9. Route non-critical to relevant agent (adl_send_message type: finding)
10. Update memory (adl_write_memory key: last_run_state with timestamp + summary)
```

**Rules:**
- Steps 1-4 (read messages, read memory, delta query, early exit) are standard -- always include them
- Steps 5-6 are domain-specific -- customize for the bot's expertise
- Steps 7-10 (write findings, alert, route, update memory) are standard -- always include them
- The delta-run pattern (step 4) saves tokens by exiting early when nothing changed
- Use specific tool names (`adl_read_messages`, `adl_query_records`, etc.) -- not vague "check for updates"

### Relationship to Scheduled Tasks

SOUL.md defines WHO the agent is (identity, expertise, constraints) and HOW it executes (run protocol). Scheduled tasks (BOT.md `schedule.tasks[]`) define WHAT triggers the agent and WHEN. The SOUL provides the consistent identity across all tasks -- a Guest Communicator checking Airbnb uses the same warm hospitality tone as when checking Facebook.

## Sub-Agents (`agents/` directory)

Bots can define sub-agents as markdown files in an `agents/` directory. Sub-agents are internal to the bot -- other bots and teams never interact with them directly. The parent bot orchestrates them via `sessions_spawn`.

### Agent File Format

```markdown
---
name: string            # Kebab-case identifier, unique within this bot
description: string     # When the parent bot should spawn this sub-agent
model: string           # "haiku", "sonnet", "opus", or "inherit" (default: inherit)
tools: [string]         # ADL tools this sub-agent can use (default: all except session tools)
---

{System prompt in markdown -- this is the sub-agent's identity and instructions}
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (kebab-case, matches filename without `.md`) |
| `description` | Yes | When the parent bot should delegate to this sub-agent |
| `model` | No | Model override: `haiku`, `sonnet`, `opus`, or `inherit` (default: `inherit`) |
| `tools` | No | Tool allowlist. Inherits all ADL tools except session tools if omitted |

### When to Use Sub-Agents vs Skills

| Use Case | Use a Skill | Use a Sub-Agent |
|----------|-------------|-----------------|
| Simple, sequential step | Yes | No |
| Needs its own isolated session | No | Yes |
| Validates another agent's output | No | Yes |
| Reusable across many bots | Yes | No |
| Requires different model/think level | No | Yes |
| Workflow with quality gates | No | Yes |

## Data Seeds Format

### zone1-north-star.json

Role-specific North Star key supplements. Merged non-destructively with the workspace's existing North Star data.

```json
{
  "seeds": [
    {
      "key": "string",
      "value": "string",
      "description": "string (optional)"
    }
  ]
}
```

### zone2-entity-types.json

Entity type definitions this bot creates and depends on.

```json
{
  "entityTypes": [
    {
      "name": "string",
      "description": "string",
      "sampleFields": ["string"]
    }
  ]
}
```

### zone3-initial-memory.json

Bootstrap private memory entries.

```json
{
  "memories": [
    {
      "namespace": "string",
      "key": "string",
      "value": "string"
    }
  ]
}
```

## Field Rules

- `metadata.name` must match the directory name under `bots/`
- `model.preferred` should use lighter models for routine tasks, more capable models for analytical tasks
- `cost.estimatedCostTier` is derived from model choice + schedule frequency
- `cost.estimatedTokensPerRun` is the typical token consumption per invocation (not a hard limit)
- `schedule.default` must be a valid cron expression or `@every` / `@daily` / `@weekly` interval
- `messaging.listensTo[].from` uses bot `metadata.name` values or `["*"]`
- `data.entityTypesWrite` must include `{abbrev}_findings` as a convention
- `agent.capabilities` should use values from the standard taxonomy: `operations`, `dev_devops`, `finance`, `analytics`, `customer_support`, `content_marketing`, `legal_compliance`, `management`, `research`, `data_engineering`, `procurement`, `security`

## Validation

1. `BOT.md` has valid YAML frontmatter with `kind: Bot` and all required fields
2. `SOUL.md` exists and is under 800 tokens (~600 words)
3. `SOUL.md` contains required sections: Mission, Expertise, Decision Authority, Communication Style, Constraints, Run Protocol
4. `SOUL.md` uses first person ("I am") not second person ("You are")
5. `SOUL.md` contains no entity type lists or memory namespace lists (those belong in BOT.md)
6. `SOUL.md` `## Constraints` section has 3-5 domain-specific NEVER rules (not generic platform rules)
7. `SOUL.md` `## Run Protocol` section has 8-10 numbered steps with specific ADL tool names
8. `data-seeds/` contains all three zone files with valid JSON
9. `data-seeds/zone3-initial-memory.json` uses plain namespaces (NOT `northstar:` or `domain:` prefixed)
10. `metadata.name` matches the directory name under `bots/`
11. All `skills[].ref` reference existing skill directories with matching versions
12. All `messaging.sendsTo[].to` reference valid bot names or system targets
13. `data.entityTypesWrite` includes a `{abbrev}_findings` entry
14. `agent.instructions` is present and contains domain-specific operating rules (not generic boilerplate)
15. `agent.toolInstructions` is present and references actual entity types from `data.entityTypesRead` / `data.entityTypesWrite`
16. `egress` block is present with an explicit `mode` value
17. All files in `agents/` have valid YAML frontmatter with `name` and `description`
18. Agent `name` matches the filename (e.g., `researcher.md` -> `name: researcher`)
19. Agent `tools` only references valid ADL tool names
20. All `plugins[].ref` are valid npm package specs (name + semver range)
21. All `plugins[].reason` are non-empty strings
22. No `plugins[].config` values contain secrets (no fields named `password`, `secret`, `token`, `apiKey`)
23. All `toolPacks[].ref` reference valid `packs/` directories containing `PACK.md`
24. All `toolPacks[].reason` are non-empty strings
25. No duplicate `toolPacks[].ref` entries appear within a bot
26. All `mcpServers[].ref` reference valid `tools/` directories containing `SERVER.md`
27. All `mcpServers[].reason` are non-empty strings
28. No `mcpServers[].config` values contain secrets
29. Every `presence:` provider has a matching `mcpServers[].ref` entry (e.g., `presence.email.provider: agentmail` requires `mcpServers: [{ref: "tools/agentmail"}]`)
30. `presence.email.displayName` only uses supported template variables (`{bot-name}`, `{workspace}`)
31. `presence:` sub-sections only reference supported providers (`agentmail`, `elevenlabs`, `agentphone`, `hyperbrowser`, `exa`, `firecrawl`)
32. `setup.steps[].id` is unique within the bot and kebab-case
33. `setup.steps[].type` is one of: `mcp_connection`, `secret`, `config`, `data_presence`, `north_star`, `manual`
34. `setup.steps[].group` is one of: `connections`, `configuration`, `data`, `external`
35. `setup.steps[].priority` is one of: `required`, `recommended`, `optional`
36. `setup.steps[]` with `type: mcp_connection` must have `ref` pointing to a valid `tools/` directory
37. `setup.steps[]` with `type: secret` must have `secretName` as a non-empty string
38. `setup.steps[]` with `type: config` must have `target.namespace` and `target.key`
39. `setup.steps[]` with `type: data_presence` must have `entityType` referencing a type in `data.entityTypesRead` or `data.entityTypesWrite`
40. `goals[].name` is unique within the bot and snake_case
41. `goals[].category` is one of: `primary`, `secondary`, `health`
42. `goals[].metric.type` is one of: `count`, `rate`, `threshold`, `boolean`
43. `goals[]` with `metric.type: rate` must have both `numerator` and `denominator`
44. `goals[].target.period` is one of: `per_run`, `daily`, `weekly`, `monthly`
45. `goals[]` with `feedback.enabled: true` must have at least 2 `feedback.actions`
46. At least one `goals[]` entry with `category: primary` is required if `goals:` is present

## What the Platform Does

| You Provide | The Platform Will |
|-------------|-------------------|
| `SOUL.md` | Use it as the bot's identity (system prompt section `# SOUL.md`) on every run |
| `agent.instructions` | Inject as `# AGENTS.md` section -- operating rules and guardrails |
| `agent.toolInstructions` | Inject as `# TOOLS.md` section -- tool usage conventions |
| `skills[].ref` | Append each skill's `prompt.md` to the bot's instructions |
| `toolPacks[].ref` | Make the declared native deterministic functions available to the bot |
| `data-seeds/` (3 zone files) | Bootstrap the bot's data -- North Star keys, entity schemas, and initial memory |
| `plugins[].ref` | Install and configure each plugin in the bot's runtime environment |
| `mcpServers[].ref` | Make the declared MCP server tools available to the bot |
| `presence` | Provision external identities (email, phone, voice) and auto-add provider domains to egress |
| `egress` | Configure the bot's external network access policy (proxy token allowlist) |
| `schedule.default` | Run the bot on the declared schedule (user can adjust) |
| `trigger` | Run the bot in response to data change events on the declared entity type |
| `messaging` | Connect the bot to the message system so it can communicate with other bots |
| `agents/*.md` | Make sub-agents available for the bot to spawn during its runs |
| `model.preferred` / `fallback` | Select the LLM the bot uses |
| `setup.steps` | Render a setup modal with typed validation; derive readiness level; write `bot_setup_status` to ADL |
| `goals` | Track goal achievement from run reports; compute `bot_goal_health`; render success dashboard |

Every field you declare gets acted on. Don't declare plugins or MCP servers the bot doesn't actually use. Data seeds are merged non-destructively. Skills are composed in the order listed.

## Canonical Example

See [`blog-writer/`](blog-writer/) for a complete bot with sub-agents, plugins, full SOUL.md, and data seeds.
