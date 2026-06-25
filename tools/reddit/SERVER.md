---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: reddit
  displayName: "Reddit"
  version: "1.0.0"
  description: "Reddit API via Composio managed-OAuth. Create posts, read and search subreddit content, comment, and pull subreddit rules and user info."
  tags: ["reddit", "social", "community", "marketing", "composio"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "REDDIT"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent calls execute_composio_tool with REDDIT_* action names (e.g. REDDIT_CREATE_REDDIT_POST, REDDIT_POST_REDDIT_COMMENT, REDDIT_DELETE_REDDIT_POST)."
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
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your Reddit account is then connected inside Composio via OAuth."
    required: false
    sensitive: true

# No MCP read-only canary here: @composio/mcp is a stdio<->HTTP proxy CLI that
# exposes no per-action MCP tools, so a tools/call canary can never match the
# live tool list. Composio connections are verified by their Composio account
# status (ACTIVE), not an MCP tool call — see core-api RecordComposioVerdict.

tools:
  - name: get_user_info
    description: "Get account data for a Reddit user, including karma scores"
    category: profile
  - name: get_subreddit_posts
    description: "Retrieve posts from a publicly accessible subreddit"
    category: community
  - name: get_top_posts
    description: "Retrieve top-rated posts from a subreddit with a time filter"
    category: community
  - name: search_posts
    description: "Search across subreddits for posts and comments by query"
    category: community
  - name: search_subreddits
    description: "Search subreddits by title and description"
    category: community
  - name: get_subreddit_rules
    description: "Fetch a subreddit's posting rules to check compliance before posting"
    category: community
  - name: create_post
    description: "Create a text or link post in a subreddit, with optional flair"
    category: content
  - name: delete_post
    description: "Delete a Reddit post by its ID"
    category: content
  - name: create_comment
    description: "Post a comment in reply to a submission or another comment"
    category: engagement
  - name: get_post_comments
    description: "Retrieve the comments on a Reddit post"
    category: engagement
---

# Reddit MCP Server

Provides Reddit API tools via Composio's managed-OAuth gateway. Covers posting, subreddit reading and search, comment management, and subreddit rule lookups for compliance.

## Auth Model: Composio

This server is backed by the Composio REDDIT toolkit (22 tools). Authentication is managed by Composio. The user connects their Reddit account in Composio via OAuth once, then bots call `execute_composio_tool` with `REDDIT_*` action names. The friendly tools above map to real toolkit actions such as `REDDIT_CREATE_REDDIT_POST`, `REDDIT_POST_REDDIT_COMMENT`, `REDDIT_DELETE_REDDIT_POST`, and the subreddit read and search actions.

No manual API key is required. The workspace's Composio-managed OAuth connection covers authentication, so the `COMPOSIO_API_KEY` env field is optional and acts only as an override.

## External Requirements

- A **Reddit account** connected in Composio via OAuth.
- Reddit **app credentials** (client ID and secret) for the OAuth grant. Composio handles these for the managed connection.
- Posting is subject to per-subreddit rules and Reddit's account-age and karma thresholds. Use `get_subreddit_rules` before posting.

## Which Bots Use This

- **social-media-strategist** -- Researches subreddit conversations and drafts community content. It does not publish directly.
- **social-media-monitor** -- Reads and searches subreddits for brand mentions and sentiment. Monitoring only, no posting.

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key.
2. Add `COMPOSIO_API_KEY` in the MCP connection setup if you want to override the managed connection. Otherwise leave it blank.
3. In Composio, connect your Reddit account via OAuth under the Reddit toolkit.
4. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/reddit"
    reason: "Community bots need Reddit access for listening and content research"
```
