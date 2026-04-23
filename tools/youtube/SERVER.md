---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: youtube
  displayName: "YouTube"
  version: "1.0.0"
  description: "YouTube Data API, videos, channels, playlists, and analytics"
  tags: ["youtube", "video", "google", "content"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "youtube-mcp@0.1.2"]
env:
  - name: YOUTUBE_API_KEY
    description: "YouTube Data API v3 key"
    required: true
tools:
  - name: search_videos
    description: "Search for videos by query"
    category: videos
  - name: get_video
    description: "Get details of a specific video"
    category: videos
  - name: list_playlists
    description: "List playlists for a channel"
    category: channels
  - name: get_channel
    description: "Get channel information and statistics"
    category: channels
  - name: list_comments
    description: "List comments on a video"
    category: videos
  - name: get_analytics
    description: "Get video or channel analytics data"
    category: analytics
  - name: list_subscriptions
    description: "List channel subscriptions"
    category: channels
---

# YouTube MCP Server

Provides YouTube Data API tools for searching videos, managing playlists, and retrieving channel analytics.

## Which Bots Use This

- **content-strategist** -- Analyzes video performance and plans content calendars
- **marketing-manager** -- Tracks channel growth and engagement metrics
- **data-analyst** -- Pulls video analytics for reporting dashboards

## Setup

1. Enable the YouTube Data API v3 in your [Google Cloud Console](https://console.cloud.google.com/)
2. Create an API key (or OAuth credentials for write operations)
3. Add `YOUTUBE_API_KEY` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single YouTube server instance across bots:

```yaml
mcpServers:
  - ref: "tools/youtube"
    reason: "Bots need YouTube access for video analytics and content management"
    config:
      default_max_results: 25
```
