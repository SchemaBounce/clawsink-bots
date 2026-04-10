## Sentiment Analysis

Classify text sentiment and store structured findings as ADL records.

### Steps

1. `adl_query_records(entity_type=<source_type>)` — fetch unanalyzed records (e.g., `reviews`, `tickets`, `feedback`). Filter: `sentiment_score IS NULL`.
2. Use `adl_tool_search` with keywords "classify text" or "extract entities" to find deterministic text analysis tools. Prefer built-in tools for entity extraction and structured classification.
3. For each record, classify sentiment: `positive` (score 0.6-1.0), `neutral` (0.4-0.6), `negative` (0.0-0.4). Assign a numeric confidence score 0.0-1.0.
4. Extract top 3 driving phrases — the specific words/phrases that most influenced the classification.
5. If text has 2+ distinct segments (e.g., "Room was great but staff was rude"), provide per-segment breakdown.
6. `adl_upsert_record(entity_type="sentiment_findings")` — store: `source_entity_type`, `source_entity_id`, `overall_sentiment`, `score`, `confidence`, `driving_phrases[]`, `segments[]`.
7. For records scoring below 0.3 with confidence above 0.8: `adl_send_message(type="alert")` to the domain owner agent.

### Output Schema

- `entity_type`: `"sentiment_findings"`
- Required fields: `source_entity_type`, `source_entity_id`, `overall_sentiment`, `score`, `confidence`, `driving_phrases`, `analyzed_at`

### Anti-Patterns

- NEVER classify without a numeric score — "positive/negative" alone is unusable for trending.
- NEVER analyze the same record twice — check for existing `sentiment_findings` with matching `source_entity_id` before processing.
- NEVER send alerts for low-confidence negatives (confidence < 0.8) — flag for human review instead.
