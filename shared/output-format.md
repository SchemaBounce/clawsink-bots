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

## Run Report Schema

Every bot writes a `run_report` entity as its last action each run. This structured self-assessment enables goal tracking, setup issue reporting, and productivity measurement. The platform aggregates run reports into `bot_goal_health` entity records.

```json
{
  "entity_type": "run_report",
  "data": {
    "run_id": "string (matches agent_runs primary key)",
    "agent_id": "string",
    "timestamp": "ISO-8601",
    "duration_ms": 45000,
    "goals": [
      {
        "name": "string (matches goals[].name from BOT.md)",
        "status": "achieved | partial | missed | blocked | not_applicable",
        "value": "number (measured value, optional)",
        "target": "string (human-readable target, e.g. '>0')",
        "context": "string (<200 chars, what happened)",
        "reason": "string (<200 chars, why blocked/missed, optional)"
      }
    ],
    "setup_issues": [
      {
        "step_id": "string (matches setup.steps[].id from BOT.md)",
        "impact": "string (<200 chars, what this missing step prevented)"
      }
    ],
    "blockers": [
      {
        "type": "missing_data | dependency_down | config_error | permission_denied",
        "description": "string (<200 chars)"
      }
    ],
    "overall": "productive | limited | idle | blocked"
  }
}
```

### Overall Status Definitions

| Status | Meaning | Indicates |
|--------|---------|-----------|
| `productive` | Achieved at least one primary goal | Bot is working as intended |
| `limited` | Ran but couldn't achieve primary goals | Setup or data issues need attention |
| `idle` | No work to do (no new events/data since last run) | Normal, but track frequency |
| `blocked` | Couldn't run meaningfully | Action needed — check setup issues and blockers |

### Goal Status Values

| Status | Meaning |
|--------|---------|
| `achieved` | Goal target was met or exceeded |
| `partial` | Some progress toward goal but target not met |
| `missed` | Had the opportunity but didn't meet the target |
| `blocked` | Could not attempt due to missing setup or dependency |
| `not_applicable` | Goal doesn't apply this run (e.g., no feedback data yet for rate metrics) |

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
