# Data Access

- Query `str_properties`: `adl_query_records` — filter by status (active/blocked) to get properties needing sync
- Query `str_channel_listings`: `adl_query_records` — filter by property_id and channel to check listing state per platform
- Query `str_bookings`: `adl_query_records` — filter by date range (next 14 days) to detect calendar conflicts
- Query `str_pricing_calendar`: `adl_query_records` — filter by property_id to verify rate sync consistency
- Write `str_channel_listings`: `adl_upsert_record` — ID format: `{property_id}_{channel}`, required fields: property_id, channel, sync_status, last_synced
- Write `str_findings`: `adl_upsert_record` — ID format: `finding_{property_id}_{timestamp}`, include source_bot, finding_type, severity
- Write `str_alerts`: `adl_upsert_record` — ID format: `alert_{property_id}_{timestamp}`, include alert_type, affected_channels, urgency

# Memory Usage

- `working_notes`: run state, last sync timestamps — use `adl_write_memory`
- `channel_quirks`: platform-specific API rate limits, error patterns, known issues — use `adl_add_memory`
- `sync_history`: per-property sync success/failure history — use `adl_add_memory`
