## Review Response Generation

Generate personalized, tone-appropriate responses to guest reviews with human-in-the-loop for negatives.

### Steps

1. `adl_query_records(entity_type="str_reviews", filters={"response_status": "pending"})` — fetch unresponded reviews.
2. Enrich each: `adl_get_record(entity_type="str_bookings")` + `adl_get_record(entity_type="str_guests")` for stay dates, property, guest name.
3. Route by rating: **4-5 stars** warm/grateful, reference stay details, max 150 words. **3 stars** acknowledge + highlight improvements, max 200 words. **1-2 stars** empathetic/solution-focused, address each complaint, max 250 words.
4. `adl_semantic_search(query="review response <property_id> <star_rating>")` — find similar past responses for tone consistency.
5. Personalize: guest first name, check-in/check-out dates, property-specific details. Never generic.
6. `adl_upsert_record(entity_type="str_review_responses")` — store: `review_id`, `property_id`, `star_rating`, `response_text`, `tone`, `status`, `created_at`.
7. For 1-2 stars: set `status: "requires_approval"` + `adl_send_message(type="request")` to property-manager. For 3-5 stars: `status: "draft"`.

### Output Schema

- `entity_type`: `"str_review_responses"`
- Required fields: `review_id`, `property_id`, `star_rating`, `response_text`, `tone`, `status`, `created_at`

### Anti-Patterns

- NEVER auto-publish responses to 1-2 star reviews — always require human approval via `requires_approval` status.
- NEVER write generic responses without guest/booking context — "Thank you for your stay" without personalization damages brand trust.
- NEVER exceed word limits (150/200/250 by tier) — concise responses perform better on all platforms.
