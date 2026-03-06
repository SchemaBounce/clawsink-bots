# Shared Resources

Cross-cutting resources used by multiple bots and teams. These files are reference data and protocol definitions, not manifest files.

## Files

### escalation-chains.json

Global default escalation routing for bots operating **outside** a team context (standalone deployment). When a bot is activated within a team, the team's `orgChart.escalation` takes precedence. See [teams/README.md](../teams/README.md) for team-level escalation.

This is the only file in `shared/` that is parsed by the platform at runtime.

### entity-schemas.md

Entity type naming conventions and common entity type definitions. Entity types use snake_case and are prefixed with a role abbreviation (e.g., `sre_findings`, `acct_invoices`).

### message-protocol.md

Inter-bot message format. Four message types:

| Type | Semantics | Response Expected |
|------|-----------|-------------------|
| `alert` | Urgent — recipient must act | Acknowledge + action |
| `request` | Ask for analysis/data | Response with findings |
| `finding` | Informational | Read and incorporate |
| `text` | General | Optional |

Messages use the compact Toon Card payload format (200-500 bytes).

### north-star-template.json

Template for Zone 1 North Star keys. Use as reference when creating `zone1-north-star.json` data seeds for new bots. See [bots/README.md](../bots/README.md) for the data seeds format.

### output-format.md

Standard output formatting rules for bot findings and reports.

### domain-schemas/

JSON schemas for common domain entity types (CRM, finance, inventory, operations, support). Use as reference when creating `zone2-entity-types.json` data seeds.

## Toon Card Format

Inter-bot messages use a compact "Toon Card" payload (200-500 bytes):

```json
{
  "toonCard": {
    "entityType": "string",
    "entityId": "string",
    "title": "string",
    "severity": "low | medium | high | critical",
    "summary": "string (<200 chars)",
    "metrics": {},
    "actionRequired": true | false
  }
}
```
