## Listing Optimization

Optimize short-term rental listing content using review data, competitor analysis, and platform best practices.

### Steps

1. `adl_query_records(entity_type="str_reviews", filters={"property_id": "<id>"})` — extract recurring positive themes and top 5 guest-loved features.
2. `adl_query_records(entity_type="str_channel_listings", filters={"property_id": "<id>"})` — load current title, description, photos, and platform metadata.
3. `adl_semantic_search(query="high performing listing <location> <property_type>")` — find competitor patterns and high-conversion listing styles.
4. Craft optimized title: lead with unique differentiator, include location, max 50 characters.
5. Write description: highlight top 3 amenities from reviews, address top 2 guest questions, embed platform-specific keywords. Max 1500 characters.
6. Score current vs optimized listing on: title clarity (1-10), description completeness (1-10), keyword density (1-10), photo relevance (1-10).
7. `adl_upsert_record(entity_type="listing_optimizations")` — store: `property_id`, `platform`, `original_title`, `optimized_title`, `optimized_description`, `scores`, `seasonal_notes`, `created_at`.

### Output Schema

- `entity_type`: `"listing_optimizations"`
- Required fields: `property_id`, `platform`, `optimized_title`, `optimized_description`, `scores`, `created_at`

### Anti-Patterns

- NEVER write generic descriptions without guest review data — always ground optimizations in real feedback.
- NEVER exceed 50 chars for titles or 1500 chars for descriptions — platform truncation loses key info.
- NEVER optimize without competitor context — `adl_semantic_search` first, then write.
