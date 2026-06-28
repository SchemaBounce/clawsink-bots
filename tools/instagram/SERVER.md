---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: instagram
  displayName: "Instagram"
  version: "1.1.0"
  description: "Instagram Graph API via Composio managed-OAuth. Create posts, publish media, read insights, and manage comments."
  tags: ["instagram", "social", "media", "marketing", "composio"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "INSTAGRAM"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent calls execute_composio_tool with INSTAGRAM_* action names (e.g. INSTAGRAM_GET_USER_INFO, INSTAGRAM_POST_IG_USER_MEDIA)."
transport:
  # Remote streamable-HTTP. The scoped, per-connected-account Composio MCP URL is
  # resolved at connection time (ComposioOAuthClient.EnsureMcpInstanceURL) and stored
  # on the connection's transport_config, where the gateway reads it. There is no
  # local command: the former `npx @composio/mcp` recipe was a CLI that serves no MCP
  # tools and exits before the handshake (gateway child_exited / start 500).
  type: "streamable-http"
env:
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Required to authenticate the Composio MCP gateway. Your Instagram account is then connected inside Composio via OAuth."
    required: true
    sensitive: true

# No MCP read-only canary here: @composio/mcp is a stdio<->HTTP proxy CLI that
# exposes no per-action MCP tools, so a tools/call canary can never match the
# live tool list. Composio connections are verified by their Composio account
# status (ACTIVE), not an MCP tool call — see core-api RecordComposioVerdict.

tools:
  - name: get_user_info
    description: "Get Instagram business account profile details"
    category: profile
  - name: get_user_media
    description: "List published media from the account"
    category: media
  - name: post_ig_user_media
    description: "Create a media container for an image, video, or reel (first step of the two-step publish flow)"
    category: media
  - name: publish_ig_user_media
    description: "Publish a prepared media container to Instagram (second step; requires manager approval before calling)"
    category: media
  - name: create_carousel_container
    description: "Draft a carousel post with 2-10 media items before publishing"
    category: media
  - name: get_ig_user_stories
    description: "Fetch active 24-hour stories on the account"
    category: media
  - name: get_ig_media_insights
    description: "Get performance data for a post (views, reach, engagement, impressions)"
    category: insights
  - name: get_user_insights
    description: "Get account-level analytics and statistics"
    category: insights
  - name: get_ig_user_content_publishing_limit
    description: "Check the account's remaining daily content publishing quota"
    category: limits
  - name: get_ig_media_comments
    description: "Retrieve comments on a specific Instagram post"
    category: comments
  - name: post_ig_media_comments
    description: "Post a comment on an Instagram media item"
    category: comments
  - name: post_ig_comment_replies
    description: "Reply to a specific comment on a post"
    category: comments
---

# Instagram MCP Server

Provides Instagram Graph API tools via Composio's managed-OAuth gateway. Handles the two-step container-then-publish flow required by the Graph API, post performance insights, and comment management.

## Auth Model: Composio

This server is backed by the Composio INSTAGRAM toolkit (36 tools). Authentication is managed by Composio — the user connects their Instagram Business Account in Composio via OAuth once, then bots call `execute_composio_tool` with `INSTAGRAM_*` action names.

**Why Composio and not a standalone npm package:** The only available standalone npm package for Instagram MCP (`instagram-mcp`) uses RapidAPI (a third-party scraper), not the official Instagram Graph API. Composio's INSTAGRAM toolkit uses the Graph API directly and supports content publishing, which the RapidAPI route does not.

## External Requirements

- A **Meta Business Account** connected to an Instagram Business or Creator account
- **App Review** approval from Meta for the `instagram_content_publish` permission if publishing programmatically from your own Meta App
- If using Composio's managed OAuth, Composio handles the App Review surface on your behalf

## Which Bots Use This

- **str-channel-manager** -- Publishes approved property social posts after str-property-manager approval
- **str-property-marketer** -- Reads post insights and checks publishing limits for content planning

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key
2. Add `COMPOSIO_API_KEY` in the MCP connection setup
3. In Composio, connect your Instagram Business Account via OAuth under the Instagram toolkit
4. The server starts automatically when a bot that references it runs

## Two-Step Publish Flow

Instagram's Graph API requires two calls to publish a post:
1. `post_ig_user_media` — create a media container (returns a `creation_id`)
2. `publish_ig_user_media` — publish the container using the `creation_id`

The `social-publishing` skill enforces a **human-approval gate** between steps. Bots must send the draft container ID to str-property-manager and wait for approval before calling `publish_ig_user_media`.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/instagram"
    reason: "Social media bots need Instagram access for property promotion and engagement monitoring"
```
