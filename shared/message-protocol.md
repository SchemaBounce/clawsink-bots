# Inter-Bot Message Protocol

## Message Types

| Type | Semantics | Response Expected | Urgency |
|------|-----------|-------------------|---------|
| `alert` | Urgent — recipient must act on next run | Acknowledge + action | Critical/High |
| `request` | Ask another bot for analysis or data | Response with findings | Medium |
| `finding` | Informational — "this is relevant to you" | Read and incorporate | Low |
| `text` | General communication | Optional | None |
| `approval` | Request approval for a proposed action | Approve or reject | Medium |
| `decision` | Request a decision from a supervisor | Decision response | High |
| `info` | Purely informational — no action expected | None | None |
| `directive` | Command from a supervisor bot | Execute and confirm | High |
| `command` | System-level command (internal use) | Execute | High |
| `event` | System event notification (internal use) | Process | Varies |
| `broadcast` | Message to all bots in a domain | Read | Low |

### Core Types (Use These)

Most bots should use `alert`, `finding`, `request`, and `text`. The extended types (`approval`, `decision`, `directive`, `info`) are for specialized coordination patterns like org chart escalation chains and supervisor workflows.

## Message Envelope

All inter-bot messages use `adl_send_message` with this structure:

```json
{
  "to": "bot-name",
  "type": "alert | request | finding | text | approval | decision | info | directive",
  "subject": "Short subject line (<80 chars)",
  "body": "<Toon Card JSON or plain text>"
}
```

## Toon Card Format

Structured findings use the Toon Card format (200-500 bytes, token-efficient):

```json
{
  "toonCard": {
    "entityType": "sre_findings",
    "entityId": "sre_20260224_001",
    "title": "Pipeline latency spike",
    "severity": "high",
    "summary": "P99 latency 4.2s (threshold 3s). Correlated with webhook timeout increase.",
    "metrics": {"p99_ms": 4200, "error_rate": 0.03},
    "actionRequired": true
  }
}
```

### Toon Card Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `entityType` | string | Yes | Source entity type of the finding |
| `entityId` | string | Yes | Unique ID: `{role}_{YYYYMMDD}_{seq}` |
| `title` | string | Yes | One-line summary (<80 chars) |
| `severity` | string | Yes | `low`, `medium`, `high`, `critical` |
| `summary` | string | Yes | Details (<200 chars) |
| `metrics` | object | No | Key numeric values |
| `actionRequired` | boolean | Yes | Whether recipient must act |

## Escalation Rules

### When to Escalate

- **alert**: Use when the finding is urgent and the recipient's domain is directly affected
- **request**: Use when you need data or analysis from another bot's domain
- **finding**: Use when the information may be useful but doesn't require immediate action

### Who to Escalate To

Each bot has defined `messaging.sendsTo` in its SKILL.md. Follow these rules:

1. **Critical operational issues** go to `executive-assistant` as `alert`
2. **Cross-domain findings** go to `business-analyst` as `finding`
3. **Domain-specific findings** go to the domain owner bot as `finding`
4. **Data requests** go to the data owner bot as `request`

### Response Protocol

When a bot receives a message:

1. **alert**: Must acknowledge in next run. Write a response message and take action.
2. **request**: Must respond within 2 runs. Write findings and send back.
3. **finding**: Read and incorporate into working memory. No response required.
4. **text**: Optional read. No response required.

## Rate Limiting

- Max 5 messages per bot per run (prevents message storms)
- Max 1 `alert` message per bot per run to the same recipient
- Duplicate alerts (same title + severity within 24h) should be suppressed
