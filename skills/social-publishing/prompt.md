## Social Publishing

Publish to connected social platforms only after explicit human approval. Approval is enforced by the runtime: every publish is an external action, and the runtime BLOCKS it until a human approves it in the Actions queue. Treat the discipline as yours; do not rely on the block as a safety net.

### How the approval gate works
A publish tool call (LinkedIn `create_post`, Reddit `create_post`, Facebook `create_post`, Instagram `publish_ig_user_media`, and the rest) is an external action. When you call it:
1. The runtime refuses the first attempt and records the exact call as an `external_action` awaiting approval. The refusal text names an action id (`act_...`).
2. A human reviews it in the Actions queue. They see the tool, the target, and the full arguments including the post text, then approve or reject.
3. Once approved, call the SAME tool again with `_sb_action_id` set to that action id. The runtime verifies the approval AND that the arguments still match what was approved, then publishes. If the arguments changed since approval, it is refused; resubmit.

The approval binds to the actual publish call, so what the human approves is exactly what posts. You do not write a separate approval record to drive the gate.

### Optional content record (`mkt_social_posts`, snake_case)
You may still write the post as a `mkt_social_posts` record (`platform`, `target`, `text`, `media_ref`, `source_bot`, `status`) for history and a richer preview. This is content history only. It does NOT gate the publish; the publish call itself is the gate.

### Protocol (every platform)
1. Prepare the exact post content.
2. Call the publish tool with the real arguments and NO `_sb_action_id`. Expect a refusal naming an action id, then STOP.
3. Tell the approver (with `adl_send_message`; read the approver from config, do not hardcode one) that an action is waiting in the Actions queue, and include a preview.
4. When it is approved (an `approval` message arrives in `adl_read_messages` and the action shows approved), call the SAME tool again with `_sb_action_id` set to the action id. If it was rejected, do not publish. Revise and resubmit, or drop it.
5. Instagram is two-step: `instagram__post_ig_user_media` (creates a non-public container) and `instagram__publish_ig_user_media` (makes it public) are BOTH external actions and both gated. An operator can set an approval policy to auto-approve the container step and require approval only on the public publish.

### Per-Platform Format
- Instagram: 2,200-char caption, up to 30 hashtags, hook in first 125 chars.
- Facebook: casual tone. STR: never post exact nightly rates.
- LinkedIn: about 3,000-char post limit, professional tone. Company-page posting needs an admin scope.
- Reddit: call `get_subreddit_rules` and honor account-age, karma, and per-subreddit rules before drafting. Respect self-promotion limits.

### Hard Rules
- Never publish without an approved action. Confirm both the `approval` message in `adl_read_messages` and that you are re-calling with the matching `_sb_action_id`.
- Never publish to a platform the workspace has not connected.
- Honor per-subreddit rules and platform rate limits.
- Never post exact nightly rates (STR).
