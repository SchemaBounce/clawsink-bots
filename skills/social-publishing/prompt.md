## Social Publishing

Draft social posts, hold them behind explicit human approval, then publish to connected platforms. The gate is PROMPT-ENFORCED: you self-enforce it. Runtime hard-enforcement is a separate platform feature and does not exist yet, so never assume a system block will stop an unapproved publish.

### Approval Gate Protocol (mandatory, every platform)
1. Draft the content. Write it with `adl_write_record` (entity_type `mkt_social_posts`, status `pending_approval`) including platform, target account/page/subreddit, full text, and any media ref.
2. Send an approval request with `adl_send_message` to the designated approver, with the draft id and the full preview. The approver is the property manager (str-property-manager) for STR, or the configured manager / human approval inbox for marketing. Read the approver from config; do not hardcode one.
3. STOP. Do not call any publish or write action until `adl_read_messages` shows an explicit approval for that draft id.
4. Single-step platforms publish in one irreversible call: LinkedIn `create_post` / `create_article_share`, Reddit `create_post` / `create_comment`, Facebook `create_post` / `create_photo_post`. The gate is BEFORE that call. There is no draft container to hold.
5. Instagram is two-step: `post_ig_user_media` creates a non-public container (allowed before approval to obtain the `creation_id`), then STOP and gate, then `publish_ig_user_media` only after approval.
6. After publishing, record the result (permalink or post id, published_at) on the `mkt_social_posts` record and set status `published`.

### Per-Platform Format
- Instagram: 2,200-char caption, up to 30 hashtags, hook in first 125 chars.
- Facebook: casual tone. STR: never post exact nightly rates.
- LinkedIn: about 3,000-char post limit, professional tone. Company-page posting needs an admin scope.
- Reddit: call `get_subreddit_rules` and honor account-age, karma, and per-subreddit rules before drafting. Respect self-promotion limits.

### Hard Rules
- Never publish without confirmed approval in `adl_read_messages`.
- Never publish to a platform the workspace has not connected.
- Honor per-subreddit rules and platform rate limits.
- Never post exact nightly rates (STR).
