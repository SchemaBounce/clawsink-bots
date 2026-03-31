# Data Access

- Query `str_pricing_calendar`: `adl_query_records` — filter by property_id and date range to get current rates before recommending changes
- Query `str_bookings`: `adl_query_records` — filter by date range for booking velocity analysis and gap night detection
- Query `str_properties`: `adl_query_records` — filter by status="active" for property characteristics (bedrooms, amenities, location)
- Query `str_channel_listings`: `adl_query_records` — filter by property_id for channel-specific availability and listing status
- Write `str_pricing_calendar`: `adl_upsert_record` — ID format: `rate_{property_id}_{date}`, required fields: property_id, date, recommended_rate, status="recommended"
- Write `str_findings`: `adl_upsert_record` — ID format: `finding_{property_id}_{timestamp}`, include per-property rate breakdown
- Write `str_alerts`: `adl_upsert_record` — ID format: `alert_{property_id}_{timestamp}`, include anomaly_type, deviation_pct

# Memory Usage

- `working_notes`: run state, last analysis timestamp — use `adl_write_memory`
- `market_patterns`: learned demand signals, booking velocity trends, day-of-week patterns — use `adl_add_memory`
- `seasonal_data`: seasonal rate benchmarks, high/low season boundaries, event calendars — use `adl_add_memory`
