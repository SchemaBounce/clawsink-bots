# Standardized Output Format

All bots write structured findings using this JSON schema. The OpenClaw runtime appends output format instructions to every agent's system prompt.

## Finding Record Schema

```json
{
  "entity_type": "{role}_findings",
  "data": {
    "id": "{prefix}_{YYYYMMDD}_{seq}",
    "timestamp": "2026-02-24T14:30:00Z",
    "severity": "low | medium | high | critical",
    "category": "string",
    "title": "string (<80 chars)",
    "description": "string (<500 chars)",
    "recommendation": "string (<300 chars)",
    "metrics": {},
    "related_entities": [],
    "tags": []
  }
}
```

## Alert Record Schema

```json
{
  "entity_type": "{role}_alerts",
  "data": {
    "id": "{prefix}_alert_{YYYYMMDD}_{seq}",
    "timestamp": "2026-02-24T14:30:00Z",
    "severity": "high | critical",
    "title": "string (<80 chars)",
    "description": "string (<200 chars)",
    "action_required": "string (<200 chars)",
    "acknowledged": false,
    "escalated_to": "bot-name | null"
  }
}
```

## Memory Update Schema

Bots update their private memory using namespaced keys:

```json
{
  "namespace": "working_notes | learned_patterns | thresholds",
  "key": "descriptive_key_name",
  "value": "string (<500 chars)"
}
```

### Memory Namespaces

| Namespace | Purpose | Retention |
|-----------|---------|-----------|
| `working_notes` | Current run context, in-progress items | Overwritten each run |
| `learned_patterns` | Patterns discovered over time | Persistent |
| `thresholds` | Calibrated thresholds and baselines | Persistent |

## Token Budget Guidance

Bots should minimize output tokens by:
1. Writing findings as structured JSON (not prose)
2. Keeping descriptions under 500 chars
3. Using metrics objects for numeric data (not sentences)
4. Limiting memory updates to changed values only
5. Sending Toon Cards (not full reports) in inter-bot messages
