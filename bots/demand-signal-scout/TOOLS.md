# Demand Signal Scout Tools

## Data Access

- Read north star and source configuration with `adl_read_memory`.
- Read dedupe, suppression, and prior action state with one `adl_query_records` pass across `prospect_signals`, `outreach_drafts`, `suppression_entries`, and `external_action`.
- Discover configured public intent with Exa search and connected Reddit or YouTube read actions.
- Read subreddit rules before drafting any Reddit response.
- Write `prospect_signals` with `adl_upsert_record` using deterministic entity id `signal_{platform}_{sourceIdOrCanonicalUrlHash}`.
- Write `outreach_drafts` with deterministic entity id `draft_{signalEntityId}`.
- Call the connected platform's effectful reply action with final text. The runtime returns a parked `act_...` id until a human approves it in Inbox > Actions.
- Write a PII-free `receipt` using `receipt_demand-signal-scout_{metric}_{YYYYMMDDHH}`.
- Update source cursors and cap state with `adl_write_memory`.

## Intent Score

Score from zero and record each matched component:

| Evidence | Points |
| --- | ---: |
| Explicit recommendation, replacement, implementation-help, or vendor request | +30 |
| Concrete active problem matching the configured offer | +25 |
| Company, stack, role, or operating context matches the ICP | +20 |
| Source item is no more than 72 hours old | +15 |
| Source permits a relevant commercial response or is an owned-content comment | +10 |
| Generic educational discussion with no active problem | -25 |
| Student, job-seeker, homework, or unrelated consumer context | -40 |
| Source rules prohibit the proposed engagement | -100 |
| Suppressed, previously handled, rejected, expired, or duplicate source item | -100 |

Clamp the final score to 0-100. The default queue threshold is 70. Never increase a score because an author appears influential or because personal profile data is available.

## Prospect Signal Contract

Required fields:

```json
{
  "platform": "reddit | youtube | web",
  "sourceId": "opaque immutable platform id or canonical URL hash",
  "sourceUrl": "canonical public URL",
  "observedAt": "ISO 8601",
  "publishedAt": "ISO 8601 when available",
  "intentScore": 85,
  "scoreEvidence": ["explicit_recommendation_request", "active_problem", "recent"],
  "problemCategory": "workspace-configured bounded label",
  "status": "qualified",
  "policyStatus": "clear",
  "conversionCampaign": "bounded campaign label",
  "expiresAt": "ISO 8601"
}
```

Do not store post text, comment text, author identity, profile attributes, or inferred personal data. The source URL is the evidence pointer for the human reviewer.

## Reply Contract

1. Answer the actual question in the source conversation.
2. Disclose the workspace's affiliation when mentioning its product or service.
3. Add the configured conversion URL only if relevant and permitted, using `utm_source`, `utm_medium=community`, `utm_campaign=demand-scout`, and an opaque `utm_content` signal id.
4. Do not claim outcomes not present in approved workspace proof.
5. Keep the reply concise and source-native.
6. Call the effectful reply tool once, save the parked action id, and stop until Inbox records a decision.

## Run Receipt

Receipt fields contain counts and opaque ids only:

```json
{
  "kind": "receipt",
  "metric": "demand_scout_run",
  "value": 3,
  "unit": "qualified_signals",
  "subject": "run_opaque_id",
  "occurredAt": "ISO 8601",
  "agentSlug": "demand-signal-scout",
  "candidatesSeen": 18,
  "draftsParked": 2,
  "dailyCapRemaining": 4
}
```

## Sub-Agent Orchestration

None. Discovery is bounded to three searches and 20 candidates per run so scoring, dedupe, and action creation remain in one auditable execution.
