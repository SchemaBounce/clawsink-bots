# Data Access

- Query `meeting_notes`: `adl_query_records` — filter by `created_at > {last_run_timestamp}` for new meetings to process
- Query `attendee_lists`: `adl_query_records` — cross-reference with action items to validate task ownership
- Write `meeting_summaries`: `adl_upsert_record` — ID format `ms_{meeting_id}_{date}`, required: meeting_title, attendees, decisions, summary
- Write `action_items`: `adl_upsert_record` — ID format `ai_{meeting_id}_{seq}`, required: owner, description, due_date, status, source_meeting

# Memory Usage

- `decision_log`: key decisions and their context for future reference — use `adl_add_memory`
- `recurring_themes`: topics that recur across meetings, stalled discussions — use `adl_write_memory`

# MCP Server Tools

- `notion.create_page` / `notion.update_page`: publish meeting summaries and action item lists to Notion

# Sub-Agent Orchestration

- `transcript-parser`: extracts raw content structure from meeting notes
- `summary-writer`: composes concise meeting summaries with decisions and key points
- `followup-tracker`: identifies and formats action items with owners and due dates
