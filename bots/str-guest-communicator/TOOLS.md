# Data Access

- Query `str_messages`: `adl_query_records` — filter by guest_id for conversation history, or by status="unanswered" and sort by created_at ascending (oldest first)
- Query `str_bookings`: `adl_query_records` — filter by guest_id to verify booking status before sharing sensitive info (door codes, wifi)
- Query `str_guests`: `adl_query_records` — filter by guest_id for guest preferences and history
- Query `str_properties`: `adl_query_records` — filter by property_id for property-specific details (amenities, directions, house rules)
- Write `str_messages`: `adl_upsert_record` — ID format: `msg_{booking_id}_{timestamp}`, required fields: guest_id, property_id, channel, direction (outbound), content
- Write `str_findings`: `adl_upsert_record` — ID format: `finding_{topic}_{timestamp}`, include source_bot, finding_type
- Write `str_alerts`: `adl_upsert_record` — ID format: `alert_{guest_id}_{timestamp}`, include alert_type, urgency

# Memory Usage

- `working_notes`: run state, pending message queue — use `adl_write_memory`
- `guest_context`: per-guest preferences, ongoing issues, communication history — use `adl_add_memory`
- `response_templates`: reusable response patterns by message type and platform — use `adl_add_memory`
