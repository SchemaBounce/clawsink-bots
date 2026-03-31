# Data Access

- Query `str_properties`: `adl_query_records` — filter by status for portfolio overview
- Query `str_bookings`: `adl_query_records` — filter by date range for occupancy pipeline
- Query `str_channel_listings`: `adl_query_records` — check listing health across channels
- Query `str_pricing_calendar`: `adl_query_records` — review current rate strategy
- Query `str_messages`: `adl_query_records` — monitor guest communication metrics
- Query `str_guests`: `adl_query_records` — guest satisfaction tracking
- Query `str_reviews`: `adl_query_records` — rating trend monitoring
- Query `str_turnovers`: `adl_query_records` — operational status
- Query `str_findings`: `adl_query_records` — filter by source_bot to read all specialist outputs
- Query `str_alerts`: `adl_query_records` — filter by status="unacknowledged" for pending alerts
- Query `crm_contacts`: `adl_query_records` — owner contact information
- Query `fin_transactions`: `adl_query_records` — revenue data for portfolio reporting
- Write `str_properties`: `adl_upsert_record` — ID format: `prop_{property_id}`, always include status field
- Write `str_findings`: `adl_upsert_record` — ID format: `briefing_{date}`, include portfolio metrics summary
- Write `str_alerts`: `adl_upsert_record` — ID format: `alert_{timestamp}`, include acknowledgment and action taken

# Memory Usage

- `working_notes`: run state, pending coordination tasks — use `adl_write_memory`
- `portfolio_health`: week-over-week KPI trends (occupancy, RevPAN, ratings) — use `adl_add_memory`
- `learned_patterns`: cross-domain correlations (e.g., pricing changes affecting review scores) — use `adl_add_memory`
