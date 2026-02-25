# Custom Tool Declarations

This directory will contain custom MCP tool declarations for Skill Pack bots.

Currently, all bots use the standard ADL tool set:
- `adl_query_records` — Query records by entity type
- `adl_write_record` — Write/update a record
- `adl_read_memory` — Read from private memory
- `adl_write_memory` — Write to private memory
- `adl_read_messages` — Read incoming messages
- `adl_send_message` — Send message to another bot
- `adl_search` — Semantic search across records

Future custom tools may include:
- External API integrations (Stripe, GitHub, Slack)
- Specialized data transformations
- Domain-specific calculations
