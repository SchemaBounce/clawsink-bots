# Data Access

- Query `str_reviews`: `adl_query_records` — filter by property_id for trend analysis (need 5+ reviews for patterns), or by status="new" for unprocessed reviews
- Query `str_bookings`: `adl_query_records` — filter by booking_id to link reviews to stay details and context
- Query `str_guests`: `adl_query_records` — filter by guest_id for guest history (use guest_id only, never PII in outputs)
- Query `str_properties`: `adl_query_records` — filter by property_id for property context when drafting responses
- Write `str_reviews`: `adl_upsert_record` — ID format: `review_{platform}_{review_id}`, update host_response field with draft
- Write `str_findings`: `adl_upsert_record` — ID format: `finding_{property_id}_{timestamp}`, include theme, review_count, severity
- Write `str_alerts`: `adl_upsert_record` — ID format: `alert_{property_id}_{timestamp}`, include review rating, platform, guest_id

# Memory Usage

- `working_notes`: run state, pending response drafts — use `adl_write_memory`
- `review_patterns`: cross-property feedback themes, recurring issues, trending topics — use `adl_add_memory`
- `response_templates`: effective response patterns by review type, platform, and sentiment — use `adl_add_memory`
