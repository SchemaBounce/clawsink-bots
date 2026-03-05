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

Each bot is a persistent agent that:
1. Wakes on a configurable cron schedule
2. Reads data via structured tool calls -- not prompt stuffing
3. Analyzes, acts, and writes structured findings back
4. Messages other bots when escalation is needed
5. Persists learnings in private memory across runs

## Available Bots

| Bot | Purpose |
|-----|---------|
| [SRE / DevOps](bots/sre-devops/) | Pipeline health, incidents, SLA tracking |
| [Data Engineer](bots/data-engineer/) | Schema drift, CDC health, DLQ monitoring |
| [Customer Support](bots/customer-support/) | Ticket triage, onboarding, churn detection |
| [Inventory Manager](bots/inventory-manager/) | Stock levels, reorder points, vendor tracking |
| [Marketing & Growth](bots/marketing-growth/) | Content calendar, campaigns, SEO tracking |
| [Accountant](bots/accountant/) | Expense tracking, reconciliation, budget monitoring |
| [Business Analyst](bots/business-analyst/) | Cross-domain analysis, trend detection |
| [Legal & Compliance](bots/legal-compliance/) | Contract review, regulatory tracking |
| [Executive Assistant](bots/executive-assistant/) | Synthesizes all bot outputs, daily briefings |
| [Security Agent](bots/security-agent/) | Vulnerability scanning, policy audits, CVE monitoring |
| [Product Owner](bots/product-owner/) | Customer feedback, feature prioritization, GH issue specs |
| [Mentor / Coach](bots/mentor-coach/) | Bot team health, coaching, process improvement |
| [Blog Writer](bots/blog-writer/) | Blog post drafting and content creation |

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

| Team | Bots | Purpose |
|------|------|---------|
| [Small Business Starter](teams/small-business-starter/) | 5 bots | Essential AI team for any small business |

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

Bots, skills, and teams are activated via the onboarding wizard or API. The activation flow registers agents, seeds data, assigns domains, and the scheduler automatically picks them up.

## Inter-Bot Communication

Bots communicate via messaging with 4 message types: `alert`, `request`, `finding`, `text`. Data exchange uses compact structured payloads to minimize token cost.

See [shared/message-protocol.md](shared/message-protocol.md) for the full protocol.

## License

Apache License 2.0 -- see [LICENSE](LICENSE).
