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

## How Bots Report Progress

Bots do not write a separate end-of-run report record. Instead, a bot's last action each run should make sure its work products exist as the entity types its own goals count. If a goal's metric is `{ type: count, entity: blog_drafts }`, the bot's job each run is to produce `blog_drafts` records when there is work to do, not to separately narrate that it did.

The platform reads goal progress from those entity records directly. For a `count` metric with a `target.period` of `daily`, `weekly`, `monthly`, or `per_run`, the platform declares an outcome metric over the entity type and reads it on every run boundary and again every hour, storing the result as an `outcome_metric_snapshot`. `rate`, `threshold`, `boolean`, and `quarterly`-period goals are listed on the bot's marketplace page but are not tracked this way yet. See [bots/README.md](../bots/README.md) "How the Platform Tracks Goals" for the full picture.

Blockers and incomplete setup steps still need somewhere to land. Write them to the existing `bot_setup_status` entity (see [bots/README.md](../bots/README.md) "Setup Instructions") rather than to a dedicated report record. Monitoring bots such as `platform-optimizer` read `bot_setup_status` and `outcome_metric_snapshot` to find bots that are blocked or off track.

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

## Output Style Modes

The platform automatically selects an output mode based on how the agent was triggered:

| Mode | Trigger | Behavior |
|------|---------|----------|
| **terse** | Scheduled runs, CDC events | Records only, no prose. Text output only for critical alerts. No greetings or narration. |
| **conversational** | Chat, session resume | Natural language. Answer directly, suggest next steps. Keep under 300 words. |
| **detailed** | Report generation (explicit) | Headers, bullet points, tables. Include methodology. End with executive summary. |

Agents can override the default via the `outputMode` field in their config. When writing bot manifests, consider which mode best fits the bot's primary use case — most scheduled bots should default to `terse`.

### Mode-Specific Rules

**Terse mode agents should:**
- Write findings as structured records, not prose
- Only produce text output for critical alerts requiring human attention
- Exit silently (memory update only) when nothing changed

**Conversational mode agents should:**
- Explain what numbers mean, not just report them
- Offer follow-up actions proactively
- Use more tool calls per turn — each should advance the conversation

**Detailed mode agents should:**
- Use headers and tables to organize findings
- Include methodology notes (data sources, computation methods)
- Always end with an executive summary and prioritized action items

## Context Budget

The platform enforces per-section character limits on agent context to prevent large workspaces from overwhelming prompts:

| Context Section | Budget | ~Tokens |
|----------------|--------|---------|
| North Star | 4,000 chars | ~1,000 |
| Domain Summary | 2,000 chars | ~500 |
| Private Memory | 4,000 chars | ~1,000 |
| Unread Messages | 2,000 chars | ~500 |
| Previous Runs | 2,000 chars | ~500 |
| Pending Tasks | 2,000 chars | ~500 |
| **Total** | **20,000 chars** | **~5,000** |

When total context exceeds the budget, the largest sections are trimmed proportionally (minimum 25% preserved per section). Truncated sections include a marker: `...[truncated — N chars omitted]`.

### Implications for Bot Authors

- Keep North Star documents concise — they consume the largest context budget
- Agents that use many memory namespaces should consolidate keys (target 10-20 keys)
- The delta-run pattern (read memory → query only new records → exit early if nothing changed) minimizes context overhead
- Memory entries with `decay_class: ephemeral` auto-delete after 1 day, keeping the memory footprint lean
