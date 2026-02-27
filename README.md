# ClawSink Bots

Pre-built, persistent AI bot modules for SchemaBounce. Each bot is a complete OpenClaw agent that autonomously operates a specific business role -- from SRE to Accountant to Executive Assistant.

Designed for **solopreneurs and small businesses** to fill organizational gaps and reduce mental load.

## Three-Tier Composability Model

ClawSink Bots uses a hierarchical composition model:

| Tier | What | Example |
|------|------|---------|
| **Skill** | Reusable capability (single responsibility) | `invoice-categorization`, `incident-triage` |
| **Bot** | Complete agent (identity + skills) | `accountant`, `sre-devops` |
| **Team** | Coordinated bot group (shared North Star) | `small-business-starter` |

Skills are composed into Bots. Bots are composed into Teams. Skills can be shared across multiple bots.

## How It Works

Each bot is a persistent OpenClaw agent that:
1. Wakes on a cron schedule (configurable per role)
2. Reads data from the ADL (Agent Data Layer) via tool calls -- not prompt stuffing
3. Analyzes, acts, and writes structured findings back to the ADL
4. Messages other bots when escalation is needed
5. Persists learnings in private memory across runs

**ADL-first design** keeps token costs minimal. The full 12-bot team runs for ~$16/month.

## Available Bots

| Bot | Model | Default Schedule | ~$/month | Purpose |
|-----|-------|-----------------|----------|---------|
| [SRE / DevOps](bots/sre-devops/) | Haiku | @every 4h | $0.72 | Pipeline health, incidents, SLA tracking |
| [Data Engineer](bots/data-engineer/) | Haiku | @every 6h | $0.36 | Schema drift, CDC health, DLQ monitoring |
| [Customer Support](bots/customer-support/) | Haiku | @every 2h | $1.44 | Ticket triage, onboarding, churn detection |
| [Inventory Manager](bots/inventory-manager/) | Haiku | @every 8h | $0.27 | Stock levels, reorder points, vendor tracking |
| [Marketing & Growth](bots/marketing-growth/) | Haiku | @daily | $0.12 | Content calendar, campaigns, SEO tracking |
| [Accountant](bots/accountant/) | Haiku | @daily | $0.09 | Expense tracking, reconciliation, budget monitoring |
| [Business Analyst](bots/business-analyst/) | Sonnet | @every 12h | $2.70 | Cross-domain analysis, trend detection |
| [Legal & Compliance](bots/legal-compliance/) | Sonnet | @weekly | $0.15 | Contract review, regulatory tracking |
| [Executive Assistant](bots/executive-assistant/) | Sonnet | @every 4h | $5.40 | Synthesizes all bot outputs, daily briefings |
| [Security Agent](bots/security-agent/) | Sonnet | @daily | $1.14 | Vulnerability scanning, policy audits, CVE monitoring |
| [Product Owner](bots/product-owner/) | Sonnet | @every 12h | $2.28 | Customer feedback, feature prioritization, GH issue specs |
| [Mentor / Coach](bots/mentor-coach/) | Sonnet | @weekly | $0.16 | Bot team health, coaching, process improvement |
| [Blog Writer](bots/blog-writer/) | Sonnet | @weekly | -- | Blog post drafting and content creation |

## Available Skills

Reusable capabilities extracted from bots and composable across multiple agents:

| Skill | Used By | Purpose |
|-------|---------|---------|
| [invoice-categorization](skills/invoice-categorization/) | accountant | Classify invoices by type, vendor, urgency |
| [expense-tracking](skills/expense-tracking/) | accountant | Track spending patterns, detect anomalies |
| [budget-monitoring](skills/budget-monitoring/) | accountant | Compare spend against budget limits |
| [incident-triage](skills/incident-triage/) | sre-devops | Detect and correlate infrastructure incidents |
| [pipeline-monitoring](skills/pipeline-monitoring/) | sre-devops | Monitor CDC pipeline health metrics |
| [sla-compliance](skills/sla-compliance/) | sre-devops | Track SLA targets and alert on breaches |
| [daily-briefing](skills/daily-briefing/) | executive-assistant | Generate prioritized daily briefings |
| [cross-domain-synthesis](skills/cross-domain-synthesis/) | executive-assistant | Identify patterns across business domains |
| [follow-up-tracking](skills/follow-up-tracking/) | executive-assistant | Track action items and ensure completion |

## Available Teams

Pre-configured bot groups for common use cases:

| Team | Bots | ~$/month | Purpose |
|------|------|----------|---------|
| [Small Business Starter](teams/small-business-starter/) | 5 bots | $8.00 | Essential AI team for any small business |

## Directory Structure

```
clawsink-bots/
├── SKILL_PACK_SPEC.md          # Authoritative format specification (v2)
├── skills/                     # Reusable skill definitions
│   ├── invoice-categorization/
│   │   ├── SKILL.md
│   │   └── prompt.md
│   ├── expense-tracking/
│   ├── budget-monitoring/
│   ├── incident-triage/
│   ├── pipeline-monitoring/
│   ├── sla-compliance/
│   ├── daily-briefing/
│   ├── cross-domain-synthesis/
│   └── follow-up-tracking/
├── bots/                       # Complete agent definitions
│   ├── sre-devops/
│   │   ├── BOT.md
│   │   ├── SOUL.md
│   │   └── data-seeds/
│   ├── accountant/
│   ├── executive-assistant/
│   └── ... (13 bots total)
├── teams/                      # Coordinated bot groups
│   └── small-business-starter/
│       └── TEAM.md
├── shared/                     # Common infrastructure
│   ├── north-star-template.json
│   ├── message-protocol.md
│   ├── entity-schemas.md
│   ├── escalation-chains.json
│   └── output-format.md
└── tools/                      # Future: custom tool declarations
```

## Activation

Bots, skills, and teams are activated via the SchemaBounce ADL onboarding wizard or API:

```bash
# Activate individual bots
POST /api/v1/workspaces/:workspace_id/agent-data-layer/skill-packs/activate
{
  "packs": ["sre-devops", "accountant", "executive-assistant"],
  "northStarOverrides": {
    "mission": "Help solopreneurs manage their e-commerce business",
    "industry": "e-commerce"
  }
}

# Activate a team (activates all member bots)
POST /api/v1/workspaces/:workspace_id/agent-data-layer/teams/activate
{
  "team": "small-business-starter",
  "northStarOverrides": {
    "mission": "Automate my freelance consulting business",
    "industry": "consulting"
  }
}
```

The activation flow registers agents, seeds data, assigns domains, and the OpenClaw runtime scheduler automatically picks them up.

## Inter-Bot Communication

Bots communicate via ADL messaging with 4 message types: `alert`, `request`, `finding`, `text`. Data exchange uses compact **Toon Cards** (200-500 bytes) to minimize token cost.

See [shared/message-protocol.md](shared/message-protocol.md) for the full protocol.

## Token Optimization

- SOUL.md documents are under 800 tokens each
- Skill prompt.md files are under 200 tokens each
- Bots read data via ADL tool calls, not prompt context stuffing
- Haiku-default for 6 of 13 bots (12x cheaper than Sonnet)
- Structured JSON output (not prose) minimizes output tokens
- Toon Cards for inter-bot data exchange (not full reports)

## License

Apache License 2.0 -- see [LICENSE](LICENSE).
