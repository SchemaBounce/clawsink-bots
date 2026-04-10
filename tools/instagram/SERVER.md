---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: instagram
  displayName: "Instagram"
  version: "1.0.0"
  description: "Instagram Graph API — posts, stories, comments, and insights"
  tags: ["instagram", "social", "media", "marketing"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "instagram-mcp@1.1.7"]
env:
  - name: INSTAGRAM_ACCESS_TOKEN
    description: "Instagram Graph API access token"
    required: true
tools:
  - name: get_profile
    description: "Get the authenticated user's profile"
    category: posts
  - name: list_media
    description: "List recent media posts"
    category: posts
  - name: create_post
    description: "Create a new image or carousel post"
    category: posts
  - name: get_comments
    description: "Get comments on a media post"
    category: comments
  - name: reply_to_comment
    description: "Reply to a comment on a post"
    category: comments
  - name: get_insights
    description: "Get account or post performance insights"
    category: insights
  - name: list_stories
    description: "List active stories"
    category: posts
---

# Instagram MCP Server

Provides Instagram Graph API tools for managing posts, responding to comments, and tracking engagement insights.

## Which Bots Use This

- **marketing-manager** -- Publishes posts, monitors engagement, and tracks social media performance
- **content-strategist** -- Analyzes post insights and plans content calendars

## Setup

1. Create a Meta app with Instagram Graph API permissions in the [Meta Developer Portal](https://developers.facebook.com/)
2. Generate a long-lived access token with `instagram_basic`, `instagram_content_publish`, and `instagram_manage_comments` permissions
3. Add `INSTAGRAM_ACCESS_TOKEN` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Instagram server instance across bots:

```yaml
mcpServers:
  - ref: "tools/instagram"
    reason: "Bots need Instagram access for social media management and analytics"
    config:
      default_media_type: "IMAGE"
```
