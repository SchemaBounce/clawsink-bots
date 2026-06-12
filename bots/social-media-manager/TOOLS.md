# Data Access

- Query `content_calendar_items`: `adl_query_records` — filter by status and scheduled_date to find items due for publishing
- Query `mkt_content`: `adl_query_records` — filter by recency to pull approved content ready to adapt per platform
- Query `mkt_social_posts`: `adl_query_records` — filter by status (pending_approval/approved/published) to track the gate
- Write `mkt_social_posts`: `adl_write_record` — ID format `post_{platform}_{date}`, required fields: platform, target, text, status, and after publishing permalink + published_at
- Write `mkt_findings`: `adl_write_record` — ID format `finding_{platform}_{timestamp}`, include source_bot, finding_type, category

# Memory Usage

- `working_notes`: run state, last_run_state timestamp, posts awaiting approval — use `adl_write_memory`
- `platform_quirks`: per-platform format limits, subreddit rules, rate limits, and known posting errors — use `adl_write_memory` to avoid repeating failed patterns

# Publishing Tools (per platform)

- LinkedIn: `create_post`, `create_article_share`, `create_comment`, `get_org_page_stats` — single-call publish, gate before the call
- Reddit: `get_subreddit_rules` (always before drafting), `create_post`, `create_comment` — honor account-age, karma, and self-promotion limits
- Instagram: `post_ig_user_media` (container, allowed before approval), then `publish_ig_user_media` (only after approval), `get_ig_media_insights`
- Facebook Pages: `create_post`, `create_photo_post`, `get_post_insights` — single-call publish, gate before the call
