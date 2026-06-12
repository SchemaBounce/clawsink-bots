---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: social-media-manager
  displayName: "Social Media Manager"
  version: "1.0.6"
  description: "Publishes approved marketing content to connected social platforms (LinkedIn, Reddit, Instagram, Facebook, YouTube) and handles engagement, never publishing anything without explicit human approval."
  category: marketing
  tags: ["social-media", "publishing", "linkedin", "reddit", "instagram", "facebook", "youtube", "twitter", "telegram", "tiktok", "marketing", "approval-gate", "composio"]
agent:
  capabilities: ["content", "operations"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
  instructions: |
    ## Operating Rules
    - NEVER publish or post anything to any platform without an explicit approval message for that draft id in adl_read_messages. This is the prime directive. The approval gate is prompt-enforced, so you must self-enforce it on every run.
    - When you receive a draft or content_calendar_item from social-media-strategist or content-scheduler, run the social-publishing gate: write a mkt_social_posts record with status pending_approval, send the full preview to the configured approver, then STOP until approval arrives.
    - If no approver is configured, escalate to marketing-growth and do not publish. A missing approver is a blocker, not a reason to skip the gate.
    - NEVER publish to a platform the workspace has not connected. Check the connection before drafting, and skip platforms that are not connected.
    - Apply the SAME approval discipline to any outbound public action, including comment replies and direct messages. Engagement that posts in public is a publish and needs approval.
    - For Reddit, call get_subreddit_rules and honor account-age, karma, and per-subreddit rules before drafting. Respect self-promotion limits.
    - NEVER fabricate engagement metrics. Report only numbers returned by the platform insights tools, and say so when data is unavailable.
    - For Instagram, create the media container first (post_ig_user_media) to obtain the creation_id, then gate, then publish_ig_user_media only after approval. The container is not public, so creating it before approval is allowed.
    - After a successful publish, record the permalink or post id and published_at on the mkt_social_posts record and set status published. Send a status finding back to social-media-strategist.
    - Store per-platform quirks and rate limits in the platform_quirks memory namespace so future runs avoid repeating failed patterns.
    - NEVER expose API credentials or auth tokens in findings, drafts, or messages.
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for drafts to publish and approvals on pending posts
    - Step 3: `adl_query_records` for mkt_social_posts with status `pending_approval` and any new content_calendar_items
    - Step 4: If nothing to draft and no approvals waiting → `adl_write_memory` updated timestamp → STOP
    - Step 5: Draft, gate, or (on approval) publish → update mkt_social_posts → write findings → update memory
model:
  provider: "anthropic"
  preferred: "sonnet_latest"
  fallback: "sonnet_latest"
  thinkLevel: "medium"
  maxTokenBudget: 15000
cost:
  estimatedTokensPerRun: 15000
  estimatedCostTier: "medium"
schedule:
  default: "@every 1h"
  recommendations:
    light: "@every 4h"
    standard: "@every 1h"
    intensive: "@every 15m"
messaging:
  listensTo:
    - { type: "request", from: ["social-media-strategist", "content-scheduler"] }
    - { type: "finding", from: ["social-media-strategist"] }
  sendsTo:
    - { type: "request", to: ["marketing-growth"], when: "a drafted post needs human approval before publishing" }
    - { type: "finding", to: ["social-media-strategist"], when: "a post is published or its publishing status changes" }
data:
  entityTypesRead: ["content_calendar_items", "mkt_content", "mkt_social_posts"]
  entityTypesWrite: ["mkt_social_posts", "mkt_findings"]
  memoryNamespaces: ["working_notes", "platform_quirks"]
zones:
  zone1Read: ["mission", "industry", "priorities"]
  zone2Domains: ["marketing"]
egress:
  mode: "restricted"
  allowedDomains: ["api.linkedin.com", "oauth.reddit.com", "www.reddit.com", "graph.facebook.com", "graph.instagram.com", "api.instagram.com", "open.tiktokapis.com", "backend.composio.dev"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/social-publishing@2.0.0"
mcpServers:
  - ref: "tools/linkedin"
    required: false
    reason: "Publish approved B2B posts and article shares to LinkedIn after human approval; reply to comments and read page analytics"
  - ref: "tools/reddit"
    required: false
    reason: "Publish approved community posts and comments after human approval; read subreddit rules to stay compliant before drafting"
  - ref: "tools/instagram"
    required: false
    reason: "Publish approved Instagram posts after human approval via the two-step container flow; read post insights"
  - ref: "tools/facebook-pages"
    required: false
    reason: "Publish approved Facebook Page posts after human approval; reply to comments and read Page analytics"
  - ref: "tools/youtube"
    required: false
    reason: "Read video and channel statistics, list playlists and captions, and reply to comments after human approval via Composio managed OAuth"
  - ref: "tools/discord"
    required: false
    reason: "Post approved community updates, replies, and reactions to Discord channels via the Composio DISCORDBOT toolkit, and read channel activity. Posting runs behind the human-approval gate"
  - ref: "tools/twitter"
    required: false
    reason: "Publish approved tweets and replies after human approval via the Composio TWITTER toolkit, delete when needed, and search recent and full-archive conversations for context. Posting runs behind the approval gate"
  - ref: "tools/telegram"
    required: false
    reason: "Broadcast approved posts to Telegram channels after human approval via the Composio TELEGRAM toolkit, and read channel history. Posting runs behind the approval gate"
  - ref: "tools/tiktok"
    required: false
    reason: "Publish approved short-form videos and photos to TikTok after human approval via the Composio TIKTOK toolkit, read the video list and user stats. Posting runs behind the approval gate"
  - ref: "tools/agentmail"
    required: false
    reason: "Notify the configured manager when a draft is waiting for approval and send publishing status summaries"
  - ref: "tools/composio"
    required: false
    reason: "Composio managed-OAuth broker backing the LinkedIn, Reddit, Instagram, and Facebook connections"
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: true
    browsing: false
requirements:
  minTier: "team"
setup:
  steps:
    - id: connect-linkedin
      name: "Connect LinkedIn"
      description: "Enables publishing approved posts and article shares to LinkedIn and reading page analytics"
      type: mcp_connection
      ref: tools/linkedin
      group: connections
      priority: recommended
      reason: "B2B publishing and engagement run through the LinkedIn connection (via Composio managed OAuth)"
      ui:
        icon: social
        actionLabel: "Connect LinkedIn"
        helpUrl: "https://docs.schemabounce.com/integrations/linkedin"
    - id: connect-reddit
      name: "Connect Reddit"
      description: "Enables publishing approved posts and comments to Reddit and reading subreddit rules"
      type: mcp_connection
      ref: tools/reddit
      group: connections
      priority: recommended
      reason: "Community publishing requires the Reddit connection and rule checks before posting"
      ui:
        icon: social
        actionLabel: "Connect Reddit"
        helpUrl: "https://docs.schemabounce.com/integrations/reddit"
    - id: connect-instagram
      name: "Connect Instagram"
      description: "Enables the two-step Instagram publish flow for approved posts and reading post insights"
      type: mcp_connection
      ref: tools/instagram
      group: connections
      priority: recommended
      reason: "Instagram publishing uses the container-then-publish flow with the approval gate between steps"
      ui:
        icon: social
        actionLabel: "Connect Instagram"
        helpUrl: "https://docs.schemabounce.com/integrations/instagram"
    - id: connect-facebook
      name: "Connect Facebook Pages"
      description: "Enables publishing approved posts to Facebook Pages and reading Page analytics"
      type: mcp_connection
      ref: tools/facebook-pages
      group: connections
      priority: recommended
      reason: "Facebook Page publishing and engagement run through the Facebook connection"
      ui:
        icon: social
        actionLabel: "Connect Facebook"
        helpUrl: "https://docs.schemabounce.com/integrations/facebook"
    - id: set-require-approval
      name: "Require publish approval"
      description: "Controls whether every post must be approved by a human before publishing. Keep this on."
      type: north_star
      key: require_publish_approval
      group: configuration
      priority: required
      reason: "Publishing to live social accounts is irreversible and public, so a human must approve every post"
      ui:
        inputType: select
        options:
          - { value: "true", label: "On (recommended)" }
          - { value: "false", label: "Off" }
    - id: set-approver
      name: "Set the approver"
      description: "Who reviews and approves drafts before they publish"
      type: north_star
      key: publish_approver
      group: configuration
      priority: required
      reason: "The bot sends every draft to this approver and waits for an explicit approval message before publishing"
      ui:
        inputType: text
        placeholder: "marketing-growth or a manager's inbox"
        helpUrl: "https://docs.schemabounce.com/bots/social-media-manager/approval"
    - id: setup-email
      name: "Verify email identity"
      description: "Bot emails the manager when a draft is waiting for approval and sends publishing summaries"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: recommended
      reason: "Approval prompts and publishing summaries are delivered by email"
      ui:
        icon: email
        actionLabel: "Verify Email"
goals:
  - name: approved_posts_published
    description: "Publish content to connected platforms after it is approved"
    category: primary
    metric:
      type: count
      entity: mkt_social_posts
      filter: { status: "published" }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when approved drafts are available"
    feedback:
      enabled: true
      entityType: mkt_social_posts
      actions:
        - { value: on_brand, label: "On brand" }
        - { value: off_brand, label: "Off brand" }
        - { value: wrong_platform, label: "Wrong platform" }
  - name: zero_unapproved_publishes
    description: "Never publish a post that was not explicitly approved by a human"
    category: primary
    metric:
      type: count
      entity: mkt_social_posts
      filter: { status: "published", approved: false }
    target:
      operator: "=="
      value: 0
      period: weekly
      condition: "any unapproved publish is a compliance failure"
  - name: engagement_handled
    description: "Reply to comments and messages within the approval discipline"
    category: secondary
    metric:
      type: count
      entity: mkt_findings
      filter: { category: "engagement" }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when engagement activity occurs"
  - name: platform_knowledge
    description: "Build knowledge of per-platform rules, quirks, and rate limits"
    category: health
    metric:
      type: count
      source: memory
      namespace: platform_quirks
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Social Media Manager

Publishes approved marketing content to connected social platforms and handles engagement. It receives drafts from the Social Media Strategist (or drafts its own from `content_calendar_items` and `mkt_content`), runs the approval gate, and publishes only after a human approves.

## Prime Directive: Approval Before Publishing

Publishing to a live social account is irreversible and public. This bot never publishes anything without explicit human approval. The flow on every post is the same:

1. Draft the content and write it as a `mkt_social_posts` record with status `pending_approval`.
2. Send the full preview to the configured approver and stop.
3. Publish only after an approval for that draft id shows up in `adl_read_messages`.
4. Record the permalink and set status `published`.

The gate is **prompt-enforced**. The bot self-enforces it on every run. Runtime hard-enforcement is a separate platform feature and is not in place yet, so the discipline lives in the bot's instructions and the `social-publishing` skill. The same discipline applies to engagement: a public comment reply or direct message is a publish and needs approval.

## Connected Platforms

| Platform | What it does |
|----------|--------------|
| LinkedIn | Posts, article shares, comment replies, page analytics |
| Reddit | Posts and comments, with subreddit rule checks before drafting |
| Instagram | Two-step container-then-publish flow, post insights |
| Facebook Pages | Page posts, photo posts, comment replies, Page analytics |
| YouTube | Video and channel statistics, comment reads, comment replies after approval, captions and playlists |
| Discord | Channel posts and replies, reactions, channel and member reads, channel management. Posting is approval-gated |
| Twitter / X | Posts, replies, deletes, single-tweet lookup, recent and full-archive search. Posting is approval-gated |
| Telegram | Channel and chat broadcast posts, update polling, chat history and chat info reads. Posting is approval-gated |
| TikTok | Video and photo posts, publish-status checks, video list, account stats. Posting is approval-gated. Needs your own TikTok Developer app, and public posting needs an audited app |

All of these run through Composio, so the workspace connects each account once in Composio. Discord connects a bot through the Composio DISCORDBOT toolkit. Telegram connects a @BotFather bot token through the Composio TELEGRAM toolkit.

Twitter and TikTok are the connections that are not zero-setup. As of February 2026 Composio removed managed credentials for Twitter, so the workspace must connect its own Twitter/X Developer app (OAuth 2.0 user-context) in Composio under the Twitter toolkit. TikTok has no managed Composio app either, so the workspace connects its own TikTok Developer app (Content Posting API and Login Kit, OAuth 2.0). TikTok public posting also needs an audited app. Until TikTok audits the app, posts go out as private or draft to the developer's own account.

## Platforms Pending De-Fiction

WhatsApp is not wired here on purpose. Its MCP manifest currently describes tools that do not exist in the package that would run, so granting it would be dishonest. It is coming once its integration is de-fictioned against a real package.

## How It Works With the Team

- Social Media Strategist plans the calendar and hands drafts to this bot for publishing review. The strategist still never publishes directly.
- Content Scheduler hands scheduled items that are due for publishing.
- This bot sends approval requests to the configured manager and status findings back to the strategist after publishing.
