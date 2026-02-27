# Entity Type Naming Conventions

## Per-Bot Entity Types

Each bot writes to entity types prefixed with its role abbreviation:

| Bot | Prefix | Findings Type | Alerts Type |
|-----|--------|--------------|-------------|
| SRE / DevOps | `sre_` | `sre_findings` | `sre_alerts` |
| Data Engineer | `de_` | `de_findings` | `de_alerts` |
| Business Analyst | `ba_` | `ba_findings` | `ba_alerts` |
| Accountant | `acct_` | `acct_findings` | `acct_alerts` |
| Customer Support | `cs_` | `cs_findings` | `cs_alerts` |
| Inventory Manager | `inv_` | `inv_findings` | `inv_alerts` |
| Legal & Compliance | `legal_` | `legal_findings` | `legal_alerts` |
| Marketing & Growth | `mktg_` | `mktg_findings` | `mktg_alerts` |
| Executive Assistant | `ea_` | `ea_findings` | `ea_alerts` |
| Security Agent | `sec_` | `sec_findings` | `sec_alerts` |
| Product Owner | `po_` | `po_findings` | `po_alerts` |
| Mentor / Coach | `mentor_` | `mentor_findings` | `mentor_alerts` |

## Shared Entity Types

These entity types are shared across bots and may be created by any bot or by the user:

| Entity Type | Description | Typical Writers |
|------------|-------------|-----------------|
| `contacts` | People (customers, vendors, partners) | customer-support, marketing-growth |
| `companies` | Organizations | customer-support, inventory-manager |
| `transactions` | Financial transactions | accountant |
| `tickets` | Support tickets | customer-support |
| `tasks` | Action items and to-dos | executive-assistant |
| `contracts` | Legal contracts and agreements | legal-compliance |
| `invoices` | Invoices (sent and received) | accountant |
| `campaigns` | Marketing campaigns | marketing-growth |
| `incidents` | Infrastructure incidents | sre-devops |
| `infrastructure_metrics` | Infrastructure metrics (CPU, memory, latency, error rates) | user/external, sre-devops |
| `pipeline_status` | Pipeline health snapshots | data-engineer, sre-devops |
| `vulnerability_scans` | Security scan results and posture snapshots | security-agent |
| `gh_issues` | Structured GitHub issue specs for human review | product-owner |
| `feature_requests` | Individual customer feature requests | product-owner |
| `team_health_reports` | Weekly bot team performance reports | mentor-coach |

## Entity ID Format

Entity IDs follow the pattern: `{prefix}_{date}_{sequence}`

Examples:
- `sre_20260224_001` — First SRE finding on Feb 24, 2026
- `acct_20260224_003` — Third accountant finding on Feb 24, 2026

For shared entity types, use the bot prefix: `cs_ticket_20260224_001`

## Standard Fields

All `_findings` entity types should include these fields:

| Field | Type | Description |
|-------|------|-------------|
| `severity` | string | `low`, `medium`, `high`, `critical` |
| `category` | string | Bot-specific category |
| `description` | string | Human-readable finding description |
| `recommendation` | string | Suggested action |
| `metrics` | object | Relevant numeric values (optional) |
| `related_entities` | array | IDs of related entities (optional) |

All `_alerts` entity types should include:

| Field | Type | Description |
|-------|------|-------------|
| `severity` | string | `high` or `critical` |
| `title` | string | Alert title (<80 chars) |
| `description` | string | What happened |
| `action_required` | string | What needs to be done |
| `acknowledged` | boolean | Whether the alert has been handled |
