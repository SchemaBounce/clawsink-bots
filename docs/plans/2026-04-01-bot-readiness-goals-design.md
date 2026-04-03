# Bot Operational Readiness & Goal Accountability Design

## Context

Bots today are "enabled" but there's no guarantee they can actually do their jobs. A bot can be activated without the connections, credentials, or configuration it needs. There's no way to measure whether a bot is succeeding at its mission — only that it ran. This design adds per-bot setup validation, goal-based success metrics, self-reported accountability, and rollup from bot → team → workspace ROI. It connects to the whitepaper narrative: your AI workforce is measurable, accountable, and provably delivering value.

## Design Decisions (User-Confirmed)

- **Manifest-driven**: BOT.md declares setup steps and goals. Platform reads them dynamically.
- **Goal-based success**: Named goals with measurable criteria, self-reported each run.
- **Tiered readiness**: Steps have priorities (required/recommended/optional). Required = hard gate.
- **Structured run reports**: Bot writes `run_report` entity each run with goal status.
- **Full rollup**: Bot → Team → Workspace ROI dashboard.
- **User feedback loop**: Users react to findings (confirmed/false positive), feeding rate metrics.
- **ADL-native**: Setup status and goal data stored IN the ADL as records/memory, not just UI state. Bots can introspect their own readiness.
- **Platform-optimizer as advisor**: The existing platform-optimizer bot reads setup status + goal data across all bots and recommends fixes/improvements.

---

## 1. Setup Steps (`setup:` block in BOT.md)

### Schema

```yaml
setup:
  steps:
    - id: string              # Unique within bot (kebab-case)
      name: string            # Human-readable (<60 chars)
      description: string     # What this does and why (<200 chars)
      type: string            # mcp_connection | secret | config | data_presence | north_star | manual
      group: string           # connections | configuration | data | external
      priority: string        # required | recommended | optional
      reason: string          # Why the bot needs this (<200 chars)
      
      # Type-specific fields (only relevant ones per type)
      ref: string             # mcp_connection: tools/{name}
      secretName: string      # secret: workspace secret key name
      entityType: string      # data_presence: entity type to check
      minCount: int           # data_presence: minimum record count
      target:                 # config: where value is stored
        namespace: string     # Memory namespace
        key: string           # Memory key
      key: string             # north_star: zone1 key name
      
      # UI rendering hints (frontend contract)
      ui:
        icon: string          # Icon identifier (slack, stripe, database, etc.)
        inputType: string     # password | text | number | slider | select | toggle
        actionLabel: string   # Button/action text
        placeholder: string   # Input placeholder
        helpUrl: string       # Link to setup docs
        validationHint: string # Input format hint
        instructions: string  # Multi-line instructions (manual type)
        min: number           # Slider/number min
        max: number           # Slider/number max
        step: number          # Slider/number increment
        unit: string          # Display unit (%, min, etc.)
        default: any          # Default value
        options:              # Select type options
          - value: string
            label: string
        prefillFrom: string   # Auto-fill source (e.g., "workspace.industry")
        emptyState: string    # data_presence: message when no records
```

### Step Types & Platform Validation

| Type | Auto-validates? | How | Frontend component |
|------|----------------|-----|-------------------|
| `mcp_connection` | Yes | Ping MCP server, check tools accessible | Connect button + status badge |
| `secret` | Yes | Check workspace secrets for named key (non-empty) | Masked text input + save |
| `config` | Yes | Check memory namespace/key exists, type-validate | Varies by `ui.inputType` |
| `data_presence` | Yes | Query entity type, check count >= minCount | Count badge + import button |
| `north_star` | Yes | Check zone1 for key presence | Input (pre-filled from workspace) |
| `manual` | No | User attestation (checkbox) | Checkbox + instruction card |

### Readiness Levels

| Level | Condition | Bot behavior |
|-------|-----------|-------------|
| `blocked` | Any `required` step incomplete | Bot will NOT run. Schedule skipped. |
| `operational` | All `required` steps complete | Bot runs. May have reduced capability. |
| `fully_configured` | All `required` + `recommended` complete | Bot runs at full capability. |
| `optimized` | All steps complete | Bot has every possible advantage. |

### Frontend Setup Modal Contract

- Steps grouped by `group` field (connections → configuration → data → external)
- Within groups, ordered by priority (required first)
- Each step renders as its type-specific component
- Progress bar: "3 of 5 required steps complete"
- "Activate Bot" button enabled when all `required` steps green
- Re-validation on revisit (connections may have broken)

---

## 2. Goals Framework (`goals:` block in BOT.md)

### Schema

```yaml
goals:
  - name: string              # Unique within bot (snake_case)
    description: string       # Human-readable (<120 chars)
    category: string          # primary | secondary | health
    metric:
      type: string            # count | rate | threshold | boolean
      # count: count entity records matching filter
      entity: string          # Entity type to count
      filter: object          # Field-value filter (optional)
      source: string          # "memory" if reading from memory instead of entities
      namespace: string       # Memory namespace (when source=memory)
      # rate: ratio of two counts
      numerator: { entity: string, filter: object }
      denominator: { entity: string, filter: object }
      # threshold: numeric value
      measurement: string     # What's being measured (self-reported key)
      # boolean: did/didn't happen
      check: string           # What to check for
    target:
      operator: string        # > | < | >= | <= | == | between
      value: number           # Target value (or [min, max] for between)
      period: string          # per_run | daily | weekly | monthly
      condition: string       # Human-readable qualifier (optional)
    feedback:                 # Optional: user feedback loop
      enabled: boolean
      entityType: string      # Which records get feedback buttons
      actions:
        - value: string       # Stored value (e.g., "confirmed", "false_positive")
          label: string       # Button text
```

### Goal Categories

| Category | Purpose | Dashboard placement |
|----------|---------|-------------------|
| `primary` | Core mission metrics — why this bot exists | Front and center, big numbers |
| `secondary` | Quality/efficiency metrics | Expandable detail section |
| `health` | Bot self-improvement and operational health | Status indicators |

### Metric Types

| Type | Measures | Example |
|------|---------|---------|
| `count` | Entity records matching criteria | "Flagged 12 transactions" |
| `rate` | Ratio of two entity counts | "8% false positive rate" |
| `threshold` | Numeric value against target | "Avg 3.2 min response time" |
| `boolean` | Did/didn't happen | "Published weekly report: yes" |

---

## 3. Run Reports (Self-Reported Accountability)

### Entity Schema: `run_report`

Every bot writes this as its last action each run. This is injected into agent instructions automatically.

```json
{
  "entity_type": "run_report",
  "data": {
    "run_id": "string",
    "agent_id": "string",
    "timestamp": "ISO-8601",
    "duration_ms": 45000,
    "goals": [
      {
        "name": "goal_name",
        "status": "achieved | partial | missed | blocked | not_applicable",
        "value": 12,
        "target": ">0",
        "context": "Human-readable explanation (<200 chars)"
      }
    ],
    "setup_issues": [
      {
        "step_id": "step_id",
        "impact": "What this missing step prevented (<200 chars)"
      }
    ],
    "blockers": [
      {
        "type": "missing_data | dependency_down | config_error | permission_denied",
        "description": "What went wrong (<200 chars)"
      }
    ],
    "overall": "productive | limited | idle | blocked"
  }
}
```

### `overall` Status Definitions

| Status | Meaning | Indicates |
|--------|---------|-----------|
| `productive` | Achieved at least one primary goal | Bot is working |
| `limited` | Ran but couldn't achieve primary goals | Setup or data issues |
| `idle` | No work to do (no new events/data) | Normal, but track frequency |
| `blocked` | Couldn't run meaningfully | Action needed |

---

## 4. ADL-Native Status (Self-Knowledge)

Setup status and goal health are stored IN the ADL so bots can introspect.

### Stored as ADL Records

```json
// Entity type: bot_setup_status (written by platform, read by bots)
{
  "entity_type": "bot_setup_status",
  "data": {
    "agent_id": "agt_fraud_detector",
    "bot_name": "fraud-detector",
    "readiness_level": "operational",
    "steps": [
      { "id": "connect_slack", "status": "complete", "completed_at": "..." },
      { "id": "stripe_key", "status": "complete", "completed_at": "..." },
      { "id": "enable_webhooks", "status": "incomplete", "priority": "recommended" }
    ],
    "required_complete": 4,
    "required_total": 4,
    "recommended_complete": 2,
    "recommended_total": 3,
    "last_validated": "2026-04-01T10:00:00Z"
  }
}

// Entity type: bot_goal_health (computed by platform from run_reports)
{
  "entity_type": "bot_goal_health",
  "data": {
    "agent_id": "agt_fraud_detector",
    "bot_name": "fraud-detector",
    "period": "weekly",
    "period_start": "2026-03-25",
    "goals": [
      {
        "name": "flag_suspicious_transactions",
        "achievement_rate": 0.92,
        "trend": "stable",
        "last_value": 12,
        "feedback_score": 0.88
      }
    ],
    "overall_health": "healthy",
    "productive_runs": 6,
    "limited_runs": 1,
    "idle_runs": 0,
    "blocked_runs": 0
  }
}
```

### Bot Self-Correction

Because status is in the ADL, bots can read it on each run:

1. Bot reads its own `bot_setup_status` → knows what's missing
2. Bot reads its own `bot_goal_health` → knows its trends
3. Bot adjusts behavior: skips actions that require missing connections, focuses on achievable goals
4. Bot reports `setup_issues` in run report → platform-optimizer picks up the signal

### Platform-Optimizer Integration

The platform-optimizer bot already reads `agent_runs` and writes `opt_recommendations`. With this design it also:

- Reads `bot_setup_status` across all bots → identifies systematic setup gaps
- Reads `bot_goal_health` across all bots → identifies underperformers
- Reads `run_report` records → identifies bots reporting `blocked` or `limited`
- Writes `opt_recommendations` with specific actions: "fraud-detector would improve 23% if Stripe webhooks enabled (step: enable_webhooks)"
- Reports to `executive-assistant` with workspace-level summary

**New data access for platform-optimizer BOT.md:**
```yaml
data:
  entityTypesRead:
    # ... existing ...
    - bot_setup_status
    - bot_goal_health
    - run_report
```

---

## 5. Team Rollup (`teamGoals:` in TEAM.md)

### Schema

```yaml
teamGoals:
  - name: string              # Unique within team (snake_case)
    description: string       # Human-readable (<120 chars)
    category: string          # primary | secondary | health
    composedFrom:
      - bot: string           # Bot name
        goal: string          # Goal name from that bot
        weight: number        # 0-1, weights sum to 1 (optional)
    aggregation: string       # average | sum | min | max | worst (default: average)
    target:
      operator: string
      value: number
      period: string
```

### Team Health Derivation

```
Team Health = weighted composite of:
  40% — Member bot readiness (avg setup completion %)
  40% — Member bot goal achievement (avg primary goal achievement rate)
  20% — Inter-bot communication health (messages flowing as declared)
```

---

## 6. Workspace ROI Dashboard

Platform computes from all active bots/teams:

| Metric | Source | Display |
|--------|--------|---------|
| Workforce Readiness | `bot_setup_status` records | "32/38 bots fully configured" |
| Goal Achievement Rate | `bot_goal_health` records | "78% primary goals achieved this week" |
| Productivity Distribution | `run_report` overall status | Pie chart: productive/limited/idle/blocked |
| User Feedback Score | Feedback actions on findings | "89% of findings confirmed useful" |
| Automation Coverage | Productive runs / total runs | "93% autonomous this month" |
| Token Efficiency | Tokens per achieved primary goal | "Avg 4,200 tokens per productive run" |

---

## 7. Concrete Examples

### fraud-detector/BOT.md (new sections)

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
        helpUrl: "https://docs.schemabounce.com/integrations/stripe"
    
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

    - id: set_industry
      name: "Set business industry"
      description: "Fraud patterns differ significantly across industries"
      type: north_star
      key: industry
      group: configuration
      priority: required
      reason: "Industry-specific fraud detection models"
      ui:
        inputType: select
        options:
          - { value: fintech, label: "FinTech / Payments" }
          - { value: ecommerce, label: "E-commerce / Retail" }
          - { value: saas, label: "SaaS / Software" }
        prefillFrom: "workspace.industry"

    - id: connect_slack
      name: "Connect Slack for alerts"
      description: "Posts critical fraud alerts to your team channel"
      type: mcp_connection
      ref: tools/slack
      group: connections
      priority: recommended
      reason: "Real-time team alerting for high-severity fraud"
      ui:
        icon: slack
        actionLabel: "Connect Slack"

    - id: historical_data
      name: "Import historical transactions"
      description: "Baseline data improves initial detection accuracy"
      type: data_presence
      entityType: transactions
      minCount: 100
      group: data
      priority: recommended
      reason: "Pattern baseline for anomaly detection"
      ui:
        actionLabel: "Import Transactions"
        emptyState: "No transaction history found"

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
        - { value: needs_review, label: "Needs review" }

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

### customer-support team (TEAM.md new section)

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

  - name: customer_satisfaction
    description: "Positive feedback on bot-handled interactions"
    category: primary
    composedFrom:
      - bot: customer-support
        goal: resolution_quality
    aggregation: average
    target:
      operator: ">"
      value: 0.85
      period: monthly
```

---

## 8. Implementation Plan (High Level)

### Phase 1: Manifest Spec (this repo — clawsink-bots)
1. Update `bots/README.md` with `setup:` and `goals:` spec
2. Add `setup:` and `goals:` to 3-5 pilot bots (fraud-detector, customer-support, blog-writer, sre-devops, accountant)
3. Update `shared/output-format.md` with `run_report` entity schema
4. Update `teams/README.md` with `teamGoals:` spec
5. Update platform-optimizer BOT.md with new data access

### Phase 2: Platform Backend (core-api)
6. Add `bot_setup_status` and `bot_goal_health` entity types to ADL
7. Add setup validation API (POST `/agents/{id}/validate-setup`)
8. Add run report aggregation (background job: run_reports → bot_goal_health)
9. Extend activation handler to create `bot_setup_status` records
10. Extend OpenCLAW agent instructions template with run report requirement

### Phase 3: Frontend
11. Setup modal component (reads `setup.steps`, renders by type/group)
12. Bot detail page: readiness section + goal dashboard
13. Team health view: aggregated member bot health
14. Workspace ROI dashboard
15. Feedback buttons on finding cards

### Phase 4: Rollout
16. Add `setup:` + `goals:` to all 47 bots
17. Add `teamGoals:` to all 22 teams
18. Platform-optimizer reads new entity types and generates recommendations

---

## Files to Modify

### clawsink-bots (this repo)
- `bots/README.md` — Add `setup:` and `goals:` spec sections
- `shared/output-format.md` — Add `run_report` entity schema
- `teams/README.md` — Add `teamGoals:` spec section
- `bots/fraud-detector/BOT.md` — Pilot: add setup + goals
- `bots/customer-support/BOT.md` — Pilot: add setup + goals
- `bots/blog-writer/BOT.md` — Pilot: add setup + goals
- `bots/sre-devops/BOT.md` — Pilot: add setup + goals
- `bots/accountant/BOT.md` — Pilot: add setup + goals
- `bots/platform-optimizer/BOT.md` — Add new entity types to data access
- `teams/customer-support/TEAM.md` — Pilot: add teamGoals

### core-api (future — not in this plan's scope)
- Activation handler, agent dashboard, OpenCLAW executor, aggregation job

### frontend (future — not in this plan's scope)
- Setup modal, goal dashboard, team health, workspace ROI

---

## Verification

1. **Spec validation**: Updated README passes all existing validation rules + new fields parse correctly
2. **Pilot completeness**: 5 pilot bots have meaningful, domain-specific setup steps and goals
3. **Run report schema**: Matches output-format.md conventions, uses standard entity type patterns
4. **Platform-optimizer**: Reads new entity types, can generate meaningful recommendations
5. **Team rollup**: At least 1 team has teamGoals that compose from member bot goals
