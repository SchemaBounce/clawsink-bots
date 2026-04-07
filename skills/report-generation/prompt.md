## Report Generation

Build structured reports from ADL records and store as queryable report entities.

### Steps

1. `adl_query_records(entity_type=<source_type>)` — fetch the dataset for the report period. Use date filters: `created_at >= <start>` and `created_at <= <end>`.
2. Group records by the configured dimensions (e.g., domain, status, priority). Compute per-group: count, sum, average, min, max.
3. `adl_query_records(entity_type="reports", filters={"report_type": "<type>"})` — fetch the prior report for delta comparison.
4. Calculate period-over-period changes: absolute delta and percentage change for each metric.
5. Generate an executive summary: top 3 findings, biggest improvement, biggest regression.
6. `adl_upsert_record(entity_type="reports")` — store with fields: `report_type`, `period_start`, `period_end`, `sections[]`, `summary`, `metrics`, `generated_at`.
7. `adl_send_message(type="finding")` to relevant domain agents with a compact DataPart containing the summary and report entity_id.

### Output Schema

- `entity_type`: `"reports"`
- Required fields: `report_type`, `period_start`, `period_end`, `sections`, `summary`, `metrics`, `generated_at`

### Anti-Patterns

- NEVER generate a report without a date range — unbounded queries produce inconsistent results.
- NEVER omit the prior-period comparison — a report without deltas has no actionable insight.
- NEVER embed full record data in the report — store summaries and reference source entity IDs.
