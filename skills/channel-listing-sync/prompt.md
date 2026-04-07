## Channel Listing Sync

Synchronize property availability and listing data across booking platforms, detecting conflicts and health issues.

### Steps

1. `adl_query_records(entity_type="str_properties")` — load all managed properties with their current configuration.
2. `adl_query_records(entity_type="str_bookings", filters={"status": "confirmed"})` — build current availability calendar per property.
3. `adl_query_records(entity_type="str_channel_listings")` — fetch listings across all platforms (Airbnb, VRBO, Lodgify, FB Marketplace).
4. Detect conflicts per property: (a) double-bookings (overlapping confirmed dates across channels), (b) stale availability (listing shows available for booked dates), (c) price mismatches (>5% variance across channels for same dates).
5. Assess listing health: flag missing photos (<5), incomplete descriptions (<200 chars), disabled/paused listings, missing amenity data.
6. `adl_upsert_record(entity_type="sync_results")` — one per property-channel pair: `property_id`, `channel`, `conflicts[]`, `health_issues[]`, `availability_match` (true|false), `synced_at`.
7. `adl_memory_write(namespace="channel_sync", key="last_checkpoint")` — store sync timestamp for incremental runs.
8. For double-bookings or stale availability: `adl_send_message(type="alert")` to the property-manager agent immediately.

### Output Schema

- `entity_type`: `"sync_results"`
- Required fields: `property_id`, `channel`, `conflicts`, `health_issues`, `availability_match`, `synced_at`

### Anti-Patterns

- NEVER skip the booking calendar build — syncing listings without current availability misses conflicts.
- NEVER treat a 5% or smaller price variance as a conflict — minor rounding differences across platforms are normal.
- NEVER sync without writing a checkpoint — incremental runs depend on knowing the last successful sync time.
