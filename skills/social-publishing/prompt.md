## Social Publishing

Draft and publish STR property posts to Instagram and Facebook with a mandatory approval gate.

### Format Limits
- Instagram: 2,200-char caption; 30 hashtags; hook in first 125 chars
- Facebook: casual tone; no exact nightly rates

### Steps
1. Check quota: `get_ig_user_content_publishing_limit`.
2. Instagram: `post_ig_user_media` → record `creation_id`.
3. **STOP. Send draft + `creation_id` to str-property-manager. Wait for approval.**
4. After approval: `publish_ig_user_media(creation_id=...)`.
5. Facebook: `create_photo_post` or `create_post` — same approval gate.
6. `adl_write_record(entity_type="mkt_social_posts")`.

### Rules
- Never publish without confirmed approval in `adl_read_messages`.
- Never post exact nightly rates.
