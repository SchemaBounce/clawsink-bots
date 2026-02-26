# ClawSink Bots

Pre-built, persistent AI bot modules for SchemaBounce. Each bot is a complete OpenClaw Skill Pack that autonomously operates a specific business role — from SRE to Accountant to Executive Assistant.

Designed for **solopreneurs and small businesses** to fill organizational gaps and reduce mental load.

## How It Works

Each bot is a persistent OpenClaw agent that:
1. Wakes on a cron schedule (configurable per role)
2. Reads data from the ADL (Agent Data Layer) via tool calls — not prompt stuffing
3. Analyzes, acts, and writes structured findings back to the ADL
4. Messages other bots when escalation is needed
5. Persists learnings in private memory across runs

**ADL-first design** keeps token costs minimal. The full 12-bot team runs for ~$16/month.

## Available Bots

| Bot | Model | Default Schedule | ~$/month | Purpose |
|-----|-------|-----------------|----------|---------|
| [SRE / DevOps](packs/sre-devops/) | Haiku | @every 4h | $0.72 | Pipeline health, incidents, SLA tracking |
| [Data Engineer](packs/data-engineer/) | Haiku | @every 6h | $0.36 | Schema drift, CDC health, DLQ monitoring |
| [Customer Support](packs/customer-support/) | Haiku | @every 2h | $1.44 | Ticket triage, onboarding, churn detection |
| [Inventory Manager](packs/inventory-manager/) | Haiku | @every 8h | $0.27 | Stock levels, reorder points, vendor tracking |
| [Marketing & Growth](packs/marketing-growth/) | Haiku | @daily | $0.12 | Content calendar, campaigns, SEO tracking |
| [Accountant](packs/accountant/) | Haiku | @daily | $0.09 | Expense tracking, reconciliation, budget monitoring |
| [Business Analyst](packs/business-analyst/) | Sonnet | @every 12h | $2.70 | Cross-domain analysis, trend detection |
| [Legal & Compliance](packs/legal-compliance/) | Sonnet | @weekly | $0.15 | Contract review, regulatory tracking |
| [Executive Assistant](packs/executive-assistant/) | Sonnet | @every 4h | $5.40 | Synthesizes all bot outputs, daily briefings |
| [Security Agent](packs/security-agent/) | Sonnet | @daily | $1.14 | Vulnerability scanning, policy audits, CVE monitoring |
| [Product Owner](packs/product-owner/) | Sonnet | @every 12h | $2.28 | Customer feedback, feature prioritization, GH issue specs |
| [Mentor / Coach](packs/mentor-coach/) | Sonnet | @weekly | $0.16 | Bot team health, coaching, process improvement |

## Directory Structure

```
clawsink-bots/
├── SKILL_PACK_SPEC.md          # Authoritative format specification
├── shared/                     # Common infrastructure
│   ├── north-star-template.json    # Zone 1 keys all bots expect
│   ├── message-protocol.md         # Inter-bot message types
│   ├── entity-schemas.md           # Entity type naming conventions
│   ├── escalation-chains.json      # Machine-readable routing
│   └── output-format.md            # Standardized JSON output
├── packs/                      # Bot definitions
│   ├── sre-devops/
│   │   ├── SKILL.md                # Manifest (model, schedule, deps)
│   │   ├── SOUL.md                 # Identity document (<800 tokens)
│   │   └── data-seeds/             # Zone 1/2/3 bootstrap data
│   ├── data-engineer/
│   ├── business-analyst/
│   ├── accountant/
│   ├── customer-support/
│   ├── inventory-manager/
│   ├── legal-compliance/
│   ├── marketing-growth/
│   ├── executive-assistant/
│   ├── security-agent/
│   ├── product-owner/
│   └── mentor-coach/
└── tools/                      # Future: custom tool declarations
```

## Skill Pack Format

Each pack contains three components:

- **SKILL.md** — YAML frontmatter manifest (model, schedule, messaging, data deps) + markdown docs
- **SOUL.md** — Agent identity document loaded as system prompt (<800 tokens)
- **data-seeds/** — Bootstrap data for ADL zones (North Star, entity types, initial memory)

See [SKILL_PACK_SPEC.md](SKILL_PACK_SPEC.md) for the full specification.

## Activation

Packs are activated via the SchemaBounce ADL onboarding wizard or API:

```bash
POST /api/v1/workspaces/:workspace_id/agent-data-layer/skill-packs/activate
{
  "packs": ["sre-devops", "accountant", "executive-assistant"],
  "northStarOverrides": {
    "mission": "Help solopreneurs manage their e-commerce business",
    "industry": "e-commerce"
  }
}
```

The activation flow registers agents, seeds data, assigns domains, and the OpenClaw runtime scheduler automatically picks them up.

## Inter-Bot Communication

Bots communicate via ADL messaging with 4 message types: `alert`, `request`, `finding`, `text`. Data exchange uses compact **Toon Cards** (200-500 bytes) to minimize token cost.

See [shared/message-protocol.md](shared/message-protocol.md) for the full protocol.

## Token Optimization

- SOUL.md documents are under 800 tokens each
- Bots read data via ADL tool calls, not prompt context stuffing
- Haiku-default for 6 of 12 bots (12x cheaper than Sonnet)
- Structured JSON output (not prose) minimizes output tokens
- Toon Cards for inter-bot data exchange (not full reports)

## License

Apache License 2.0 — see [LICENSE](LICENSE).
