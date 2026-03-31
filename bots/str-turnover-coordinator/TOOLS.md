# Data Access

- Query `str_turnovers`: `adl_query_records` — filter by status (pending/scheduled/active) and date for upcoming turnover tracking
- Query `str_bookings`: `adl_query_records` — filter by checkout/checkin date within next 48 hours to generate cleaning assignments
- Query `str_properties`: `adl_query_records` — filter by property_id for property size and turnover requirements
- Write `str_turnovers`: `adl_upsert_record` — ID format: `turnover_{property_id}_{date}`, required fields: property_id, checkout_time, checkin_time, cleaner_id, status, priority
- Write `str_findings`: `adl_upsert_record` — ID format: `finding_{property_id}_{timestamp}`, include issue_type, severity
- Write `str_alerts`: `adl_upsert_record` — ID format: `alert_{property_id}_{timestamp}`, include alert_type (late_cleaning/maintenance/missed_turnover)

# Memory Usage

- `working_notes`: run state, active turnover queue — use `adl_write_memory`
- `cleaner_roster`: cleaner performance metrics (on-time rate, quality scores, availability) — use `adl_add_memory`
- `maintenance_log`: recurring property maintenance issues and patterns — use `adl_add_memory`
