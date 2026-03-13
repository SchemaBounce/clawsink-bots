## Channel Listing Sync

When synchronizing listings:
1. Query str_properties and str_bookings to build current availability per property
2. Compare against str_channel_listings for each platform (Airbnb, VRBO, Lodgify, FB Marketplace)
3. Detect calendar conflicts: double-bookings, stale availability, price mismatches
4. Flag listing health issues: missing photos, incomplete descriptions, disabled listings
5. Write updated str_channel_listings with sync timestamps and conflict status
6. Store last sync checkpoint in memory for incremental runs
