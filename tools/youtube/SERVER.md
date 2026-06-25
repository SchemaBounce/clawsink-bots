---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: youtube
  displayName: "YouTube"
  version: "2.0.0"
  description: "YouTube Data API via Composio managed-OAuth. Search videos, read video and channel statistics, read and reply to comments, list playlists and captions, and find trending videos."
  tags: ["youtube", "video", "social", "marketing", "composio"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "YOUTUBE"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent calls execute_composio_tool with YOUTUBE_* action names (e.g. YOUTUBE_SEARCH_YOU_TUBE, YOUTUBE_LIST_COMMENT_THREADS, YOUTUBE_GET_CHANNEL_STATISTICS)."
transport:
  # Remote streamable-HTTP. The scoped, per-connected-account Composio MCP URL is
  # resolved at connection time (ComposioOAuthClient.EnsureMcpInstanceURL) and stored
  # on the connection's transport_config, where the gateway reads it. There is no
  # local command: the former `npx @composio/mcp` recipe was a CLI that serves no MCP
  # tools and exits before the handshake (gateway child_exited / start 500).
  type: "streamable-http"
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio-managed OAuth
  # connection. Leaving this blank uses the workspace's Composio integration for
  # this service; provide a value only to override the managed connection. Do not
  # mark this required:true, that makes the setup/reconnect modal demand a key the
  # managed OAuth flow already covers.
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your YouTube account is then connected inside Composio via OAuth."
    required: false
    sensitive: true

tools:
  - name: search_videos
    description: "Search YouTube for videos, channels, or playlists by query"
    category: discovery
  - name: list_most_popular
    description: "List trending and most-popular videos for a region"
    category: discovery
  - name: get_video_details
    description: "Get details and statistics (views, likes, comment counts) for one or more videos"
    category: videos
  - name: get_channel_statistics
    description: "Get channel statistics including subscriber, view, and video counts"
    category: channels
  - name: get_channel_id_by_handle
    description: "Resolve a channel handle or URL to its channel id"
    category: channels
  - name: list_channel_videos
    description: "List the videos published by a channel"
    category: channels
  - name: list_comment_threads
    description: "List top-level comment threads on a video, with optional replies"
    category: engagement
  - name: list_comments
    description: "List individual comments on a video"
    category: engagement
  - name: post_comment
    description: "Post a top-level comment on a video"
    category: engagement
  - name: reply_to_comment
    description: "Reply to an existing comment"
    category: engagement
  - name: list_playlists
    description: "List the authenticated user's playlists"
    category: playlists
  - name: list_playlist_items
    description: "List the videos in a playlist"
    category: playlists
  - name: list_captions
    description: "List the caption tracks available for a video"
    category: captions
---

# YouTube MCP Server

Provides YouTube Data API tools via Composio's managed-OAuth gateway. Covers video and channel search, video and channel statistics, comment reading and replies, playlist listing, caption listing, and trending discovery.

## Auth Model: Composio

This server is backed by the Composio YOUTUBE toolkit (47 tools). Authentication is managed by Composio. The user connects their Google or YouTube account in Composio via OAuth once, then bots call `execute_composio_tool` with `YOUTUBE_*` action names. The friendly tools above map to real toolkit actions such as `YOUTUBE_SEARCH_YOU_TUBE`, `YOUTUBE_GET_VIDEO_DETAILS_BATCH`, `YOUTUBE_GET_CHANNEL_STATISTICS`, `YOUTUBE_LIST_COMMENT_THREADS`, and `YOUTUBE_POST_COMMENT`.

No manual API key is required. The workspace's Composio-managed OAuth connection covers authentication, so the `COMPOSIO_API_KEY` env field is optional and acts only as an override.

## External Requirements

- A **Google or YouTube account** connected in Composio via OAuth.
- Read actions (search, statistics, comment reads, captions, playlists) work with read scopes.
- Write actions (`post_comment`, `reply_to_comment`) require channel ownership plus the matching YouTube OAuth scopes. Composio requests these during the OAuth grant.
- Channel statistics cover subscriber, view, and video counts. Watch-time and audience demographics come from the separate YouTube Analytics API and are out of scope for this server's declared tools.

## Which Bots Use This

- **social-media-manager** -- Reads video and channel statistics for reporting, replies to comments after human approval, and reads captions and playlists. Comment replies follow the same approval gate as any public post.

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key.
2. Add `COMPOSIO_API_KEY` in the MCP connection setup if you want to override the managed connection. Otherwise leave it blank.
3. In Composio, connect your Google or YouTube account via OAuth under the YouTube toolkit.
4. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/youtube"
    reason: "Marketing bots need YouTube access for video statistics, comment engagement, and content research"
```
