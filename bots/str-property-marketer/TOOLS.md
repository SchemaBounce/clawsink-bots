# Data Access

- Query `str_properties`: `adl_query_records` — filter by property_id for property details, amenities, unique features
- Query `str_reviews`: `adl_query_records` — filter by property_id for guest-loved features and recurring positive themes
- Query `str_channel_listings`: `adl_query_records` — filter by property_id for platform requirements (photo minimums, character limits)
- Query `str_bookings`: `adl_query_records` — filter by property_id and date range for booking pattern analysis (seasonal demand)
- Query `mkt_content`: `adl_query_records` — filter by property_id and status to check existing approved content before creating new
- Query `mkt_social_posts`: `adl_query_records` — filter by property_id for recent social media activity
- Write `mkt_content`: `adl_upsert_record` — ID format: `content_{property_id}_{platform}_{timestamp}`, required fields: property_id, platform, content_type, body, status="draft"
- Write `mkt_social_posts`: `adl_upsert_record` — ID format: `social_{property_id}_{platform}_{timestamp}`, required fields: property_id, platform, post_body
- Write `str_findings`: `adl_upsert_record` — ID format: `finding_{property_id}_{timestamp}`, include content summary and target channel
- Write `str_alerts`: `adl_upsert_record` — ID format: `alert_{timestamp}`, include alert_type

# Memory Usage

- `working_notes`: run state, content pipeline status — use `adl_write_memory`
- `content_calendar`: upcoming content schedule, seasonal promotion plans — use `adl_add_memory`
- `seo_insights`: keyword performance data, platform-specific SEO patterns — use `adl_add_memory`
