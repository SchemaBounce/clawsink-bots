---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: facebook-pages
  displayName: "Facebook Pages"
  version: "1.0.0"
  description: "Facebook Pages via Composio managed-OAuth. Create posts, publish photos/videos, read Page insights, and manage conversations."
  tags: ["facebook", "social", "marketing", "pages", "composio"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "FACEBOOK"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent calls execute_composio_tool with FACEBOOK_* action names (e.g. FACEBOOK_CREATE_POST, FACEBOOK_GET_PAGE_INSIGHTS)."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@composio/mcp@1.0.9"]
env:
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Required to authenticate the Composio MCP gateway. Your Facebook Page is connected inside Composio via OAuth."
    required: true
    sensitive: true

tools:
  - name: list_managed_pages
    description: "List all Facebook Pages the authenticated user manages"
    category: pages
  - name: get_page_details
    description: "Retrieve comprehensive Page information including settings and metadata"
    category: pages
  - name: create_post
    description: "Generate a text or link-based post on a Facebook Page"
    category: posts
  - name: create_photo_post
    description: "Publish an image post with optional caption to a Page"
    category: posts
  - name: create_video_post
    description: "Upload and publish video content to a Page"
    category: posts
  - name: get_page_posts
    description: "Fetch posts from a Page timeline"
    category: posts
  - name: update_post
    description: "Edit existing post content"
    category: posts
  - name: delete_post
    description: "Permanently remove a post from a Page"
    category: posts
  - name: get_page_insights
    description: "Access Page-level analytics and performance metrics"
    category: insights
  - name: get_post_insights
    description: "Get analytics for an individual post (reach, impressions, reactions)"
    category: insights
  - name: get_post_reactions
    description: "Retrieve reaction data (likes, loves, etc.) for a post"
    category: insights
  - name: send_message
    description: "Send a message from a Page to a user via Messenger"
    category: messaging
---

# Facebook Pages MCP Server

Provides Facebook Pages API tools via Composio's managed-OAuth gateway. Supports Page post creation, photo/video publishing, analytics, and Messenger conversations.

## Auth Model: Composio

This server is backed by the Composio FACEBOOK toolkit (43 tools). Authentication is managed by Composio — the user connects their Facebook Page in Composio via OAuth once, then bots call `execute_composio_tool` with `FACEBOOK_*` action names.

## External Requirements

- A **Facebook Page** (not a personal profile) — STR properties should have a dedicated Page
- The Composio FACEBOOK toolkit connected under your Composio account
- For video publishing: video files must be accessible via URL or uploaded in advance

## Which Bots Use This

- **str-channel-manager** -- Publishes approved property posts to Facebook Pages after str-property-manager approval
- **str-property-marketer** -- Reads Page insights and post performance for content planning

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key
2. Add `COMPOSIO_API_KEY` to your workspace secrets
3. In Composio, connect your Facebook Page via OAuth under the Facebook toolkit
4. The server starts automatically when a bot that references it runs

## Composio Toolkit

Composio FACEBOOK toolkit: verified at https://docs.composio.dev/apps/facebook (43 tools).

## Team Usage

```yaml
mcpServers:
  - ref: "tools/facebook-pages"
    reason: "STR marketing bots need Facebook Page access for property promotion and audience engagement"
```
