## Scheduled Report

1. Read the triggering message for report scope and audience.
2. Use `adl_tool_search` with keywords "report", "table", or "chart" to find deterministic formatting and aggregation tools. Prefer built-in tools for data summarization.
3. Load cursor state from memory to determine where the last run ended.
4. Query domain_records created or updated since the cursor timestamp.
5. Analyze trends, notable changes, and emerging patterns in the new data.
6. Write a periodic_findings record summarizing key insights and metrics.
7. Write a periodic_reports record with the full structured report.
8. Update the cursor in memory to the current timestamp.
9. Send a summary message to relevant downstream bots using adl_send_message.
10. Never re-analyze records from previous runs; always work incrementally.

Anti-patterns:
- NEVER generate a report without loading the cursor from memory first — missing the cursor causes full re-analysis of historical data.
- NEVER send the full report body as a message to downstream bots — send a DataPart summary with the report entity_id for on-demand lookup.
- NEVER skip updating the cursor after a successful run — stale cursors cause duplicate analysis on the next cycle.
