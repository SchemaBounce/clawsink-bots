# Demand Signal Scout Tools

## Data Access

- Read `northstar:icp_definition` key `icp_definition`, `northstar:conversion_url` key `conversion_url`, source configuration, and run state first. Do not read the obsolete bot-scoped North Star namespace.
- Read dedupe and queue state in one bounded query across `prospect_signals`, `company_buying_signals`, `content_opportunities`, `acquisition_queue`, `outreach_drafts`, `suppression_entries`, and `external_action`.
- Discover configured public intent with Exa and connected Reddit or YouTube read actions. Read subreddit rules before drafting a Reddit response.
- Read connected CRM and first-party form records once per pass. CRM access is read-only. Use opaque record ids and bounded evidence labels outside the source system.
- Write deterministic entity ids with `adl_upsert_record`:
  - `signal_{platform}_{sourceIdOrCanonicalUrlHash}`
  - `company_signal_{sourceSystem}_{companyRecordId}_{signalType}_{YYYYMMDD}`
  - `content_opportunity_{themeHash}_{YYYYMMDD}`
  - `queue_{YYYYMMDD}_{candidateType}_{candidateId}`
  - `draft_{signalEntityId}`
- Call an effectful public reply action only with final approved-review text. The runtime returns a parked `act_...` id until a human decides in Inbox > Actions.
- Write one PII-free `receipt` per run and update source cursors, feedback windows, learned weights, and daily cap state.

## Public Intent Score

Score public candidates from zero and record each matched component:

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

Clamp the score to 0-100. The default threshold is 70. Never increase a score because an author appears influential or because personal profile data is available.

## Acquisition Priority Score

Rank every eligible public signal, company signal, attributed hand raise, and content opportunity with the same 0-100 model:

| Component | Maximum | Evidence |
| --- | ---: | --- |
| Intent | 35 | Explicit active problem, recommendation request, form request, deal activity, or repeated owned-channel question |
| ICP fit | 25 | Match to configured company, stack, role, and problem criteria |
| Recency | 15 | Strongest inside 24 hours, decaying to zero at the configured retention boundary |
| Relationship | 15 | First-party form, existing CRM account, owned-channel engagement, or public-only signal in descending order |
| Measured engagement | 10 | Explicit reply, click, form, meeting, deal, or bounded public engagement delta |

Record each component and evidence labels. Never infer a meeting, relationship, identity, or buying stage. Queue items below `minimum_priority_score` are omitted. Tie-break by observed time, then deterministic candidate id.

## Prospect Signal Contract

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
  "feedbackStatus": "not_due | due | partial | complete | unavailable",
  "nextFeedbackAt": "ISO 8601",
  "engagementDelta": { "replies": 2, "score": 5 },
  "attributedLeadId": "opaque first-party lead id, only after voluntary form submission",
  "expiresAt": "ISO 8601"
}
```

Do not store post text, comment text, author identity, profile attributes, or inferred personal data. The public URL is the evidence pointer for a human reviewer.

## Company Buying Signal Contract

Use only explicit connected CRM, form, news, deal, and engagement evidence:

```json
{
  "sourceSystem": "hubspot | first_party_form | public_news",
  "companyRef": "opaque CRM company id or canonical domain hash",
  "signalType": "form_submission | sales_engagement | marketing_engagement | deal_activity | company_news",
  "evidenceLabels": ["demo_request", "open_deal", "recent_sales_reply"],
  "observedAt": "ISO 8601",
  "intentScore": 90,
  "expiresAt": "ISO 8601"
}
```

Do not copy contact fields into this entity. A public signal may link to an opaque lead id only when the lead submitted a first-party form containing that signal's `utm_content` value. Never write back to the CRM.

## Content Opportunity Contract

Create an opportunity after the configured minimum number of related, recent questions:

```json
{
  "theme": "bounded workspace taxonomy label",
  "sourceSignalIds": ["signal_opaque_1", "signal_opaque_2", "signal_opaque_3"],
  "recommendedFormat": "community_post | short_qa | video_reply | long_form",
  "audienceNeed": "bounded problem label",
  "draftBrief": "reviewable brief without copied source text or author identity",
  "status": "proposed",
  "observedAt": "ISO 8601"
}
```

These are planning records. The YouTube connector can read comments and post comment replies; it does not publish Community posts, Shorts, or videos.

## Daily Acquisition Queue Contract

```json
{
  "queueDate": "YYYY-MM-DD",
  "rank": 1,
  "candidateType": "public_signal | company_signal | attributed_lead | content_opportunity",
  "candidateId": "opaque ADL entity id",
  "priorityScore": 92,
  "scoreComponents": { "intent": 35, "fit": 25, "recency": 15, "relationship": 12, "engagement": 5 },
  "evidenceLabels": ["demo_request", "icp_match", "observed_today"],
  "recommendedAction": "review_reply | contact_known_lead | review_content_brief | investigate_account",
  "ownerRole": "sales | marketing | revops",
  "status": "open"
}
```

Upsert one queue per UTC day, cap it at `daily_queue_limit`, and rerank deterministically after reconciliation. An item recommends work; it never bypasses CRM ownership rules or Inbox approval.

## Feedback And Attribution

1. Reconcile action status before creating another draft.
2. For published Reddit and YouTube replies, read supported counters at 24 and 72 hours and store only count deltas plus outcome labels.
3. Update source, query, and community weights from aggregate outcomes. Keep weights bounded from 0.5 to 1.5 so one result cannot dominate discovery.
4. Attribute a public signal to a first-party hand raise only through its opaque `utm_content` signal id.
5. Record meetings, opportunities, and revenue only from explicit CRM or interaction records. Never infer them from clicks, comments, or views.

## Reply Contract

1. Answer the actual question in the source conversation.
2. Disclose the workspace's affiliation when mentioning its product or service.
3. Add the configured conversion URL only when relevant and permitted, using `utm_source`, `utm_medium=community`, `utm_campaign=demand-scout`, and an opaque `utm_content` signal id.
4. Do not claim outcomes not present in approved workspace proof.
5. Keep the reply concise and source-native.
6. Call the effectful reply tool once, save the parked action id, and stop until Inbox records a decision.

## Run Receipt

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
  "feedbackReconciled": 4,
  "contentOpportunities": 1,
  "queueSize": 12,
  "draftsParked": 2,
  "dailyCapRemaining": 3
}
```

## Sub-Agent Orchestration

None. One bounded agent owns reconciliation, discovery, scoring, ranking, and receipt creation so the acquisition queue has one deterministic contract and one audit trail.
