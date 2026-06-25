---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: tiktok
  displayName: "TikTok"
  version: "1.0.0"
  description: "TikTok Content Posting API via Composio. Publish videos from a URL, upload video files, post photos, list videos, check publish status, and read account stats through a connected TikTok Developer app."
  tags: ["tiktok", "social", "video", "marketing", "composio"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "TIKTOK"
  setupReason: "Authorized via Composio against your own TikTok Developer app. The agent calls execute_composio_tool with TIKTOK_* action names (e.g. TIKTOK_PUBLISH_VIDEO, TIKTOK_LIST_VIDEOS, TIKTOK_GET_USER_STATS)."
transport:
  # Remote streamable-HTTP. The scoped, per-connected-account Composio MCP URL is
  # resolved at connection time (ComposioOAuthClient.EnsureMcpInstanceURL) and stored
  # on the connection's transport_config, where the gateway reads it. There is no
  # local command: the former `npx @composio/mcp` recipe was a CLI that serves no MCP
  # tools and exits before the handshake (gateway child_exited / start 500).
  type: "streamable-http"
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio connection.
  # Leaving this blank uses the workspace's Composio integration for this
  # service; provide a value only to override the managed connection. Do not
  # mark this required:true, that makes the setup/reconnect modal demand a key
  # the Composio flow already covers.
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your TikTok Developer app is then connected inside Composio via OAuth 2.0."
    required: false
    sensitive: true

tools:
  - name: publish_video
    description: "Publish a video to TikTok by pulling it from a public URL (publish action, gate behind approval)"
    category: content
  - name: upload_video
    description: "Upload a single video file to TikTok via the Content Posting API (publish action, gate behind approval)"
    category: content
  - name: post_photo
    description: "Create a photo post of 1 to 35 images, published or saved as a draft (publish action, gate behind approval)"
    category: content
  - name: get_publish_status
    description: "Check the processing status of a video or photo post by its publish id"
    category: content
  - name: list_videos
    description: "List videos for the authenticated account"
    category: insights
  - name: get_user_stats
    description: "Read profile information and statistics for the authenticated account, including follower count and engagement metrics"
    category: insights
---

# TikTok MCP Server

Provides TikTok Content Posting API tools via Composio, backed by your own TikTok Developer app. Covers video publishing from a URL, video file uploads, photo posts, publish-status checks, video listing, and account stats.

## Auth Model: Composio (TIKTOK)

This server is backed by the Composio TIKTOK toolkit (10 tools, OAuth 2.0). Bots call `execute_composio_tool` with `TIKTOK_*` action names. The friendly tools above are a curated subset that map to real toolkit actions:

| Friendly tool | Composio action |
|---------------|-----------------|
| publish_video | TIKTOK_PUBLISH_VIDEO |
| upload_video | TIKTOK_UPLOAD_VIDEO |
| post_photo | TIKTOK_POST_PHOTO |
| get_publish_status | TIKTOK_FETCH_PUBLISH_STATUS |
| list_videos | TIKTOK_LIST_VIDEOS |
| get_user_stats | TIKTOK_GET_USER_STATS |

The toolkit also exposes ad and marketing actions (`TIKTOK_GET_ACTION_CATEGORIES`, `TIKTOK_GET_TERM`, `TIKTOK_LIST_GMV_MAX_OCCUPIED_CUSTOM_SHOP_ADS`) and a batch `TIKTOK_UPLOAD_VIDEOS`. Those are out of scope for this server's declared tools and are not granted here.

## Auth Caveat: You Supply Your Own TikTok Developer App

This is not zero-setup managed OAuth. Composio has no managed app for TikTok, so you must connect your own TikTok Developer app inside Composio. Register an app at developers.tiktok.com, add the Content Posting API and the Login Kit products, enable OAuth 2.0, and connect those credentials in Composio under the TikTok toolkit. Without your own app, the connection will not authorize.

## Caveat: Public Posting Requires an Audited App

TikTok's Content Posting API only allows direct public posting for audited apps. An unaudited app can only post privately or as a draft, and only to the developer's own account. Until TikTok audits your app, `publish_video`, `upload_video`, and `post_photo` will post as private or draft, not public. This is the TikTok equivalent of LinkedIn's company-page scope gating. Apply for the audit in the TikTok developer portal once your integration is ready.

## Posting Is Approval-Gated

`publish_video`, `upload_video`, and `post_photo` publish content. The `social-publishing` skill holds every post behind explicit human approval before it goes live. Status checks, video listing, and stat reads are not gated.

## External Requirements

- A **TikTok Developer account** with an app configured for the Content Posting API and Login Kit, using OAuth 2.0.
- Those OAuth 2.0 credentials connected in Composio under the TikTok toolkit.
- An approved Content Posting API audit if you want posts to publish publicly rather than as private or draft.

## Which Bots Use This

- **social-media-manager** -- Publishes approved videos and photos after human approval, checks publish status, lists videos, and reads account stats. Posting runs behind the approval gate.

## Setup

1. Register an app at [developers.tiktok.com](https://developers.tiktok.com) with the Content Posting API and Login Kit products and OAuth 2.0 enabled.
2. Sign up at [composio.dev](https://composio.dev) and get your API key.
3. In Composio, connect your TikTok app under the TikTok toolkit using your app's OAuth 2.0 credentials.
4. Apply for the Content Posting API audit if you need public posting. Until then, posts go out as private or draft.
5. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/tiktok"
    reason: "Social bots need TikTok access for approved short-form video and photo posting"
```
