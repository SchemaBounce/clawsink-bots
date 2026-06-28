---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: twitter
  displayName: "Twitter / X"
  version: "2.0.0"
  description: "Twitter/X API via Composio. Post and delete tweets, reply, look up a tweet, search recent and full-archive conversations, and read user profiles through a connected Twitter/X Developer app."
  tags: ["twitter", "x", "social", "marketing", "composio"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "TWITTER"
  setupReason: "Authorized via Composio against your own Twitter/X Developer app. The agent calls execute_composio_tool with TWITTER_* action names (e.g. TWITTER_CREATION_OF_A_POST, TWITTER_RECENT_SEARCH, TWITTER_GET_USER_BY_ID)."
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
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your Twitter/X Developer app is then connected inside Composio via OAuth 2.0."
    required: false
    sensitive: true

tools:
  - name: create_post
    description: "Post a new tweet (publish action, gate behind approval)"
    category: tweets
  - name: reply
    description: "Reply to an existing tweet by setting the in-reply-to tweet id on a new post (publish action, gate behind approval)"
    category: tweets
  - name: delete_post
    description: "Delete a tweet by its post id"
    category: tweets
  - name: get_post
    description: "Look up a single tweet by its post id"
    category: tweets
  - name: search_recent
    description: "Search tweets from the last 7 days using X search syntax"
    category: search
  - name: search_full_archive
    description: "Search the full public tweet archive from March 2006 onward"
    category: search
  - name: get_user
    description: "Read a user's public profile by user id"
    category: users
---

# Twitter / X MCP Server

Provides Twitter/X tools via Composio, backed by your own Twitter/X Developer app. Covers posting, replies, deletes, single-tweet lookup, recent and full-archive search, and user reads.

## Auth Model: Composio (TWITTER)

This server is backed by the Composio TWITTER toolkit (79 tools). Bots call `execute_composio_tool` with `TWITTER_*` action names. The friendly tools above are a curated subset that map to real toolkit actions:

| Friendly tool | Composio action |
|---------------|-----------------|
| create_post | TWITTER_CREATION_OF_A_POST |
| reply | TWITTER_CREATION_OF_A_POST (with the in-reply-to tweet id parameter) |
| delete_post | TWITTER_POST_DELETE_BY_POST_ID |
| get_post | TWITTER_POST_LOOKUP_BY_POST_ID |
| search_recent | TWITTER_RECENT_SEARCH |
| search_full_archive | TWITTER_FULL_ARCHIVE_SEARCH |
| get_user | TWITTER_GET_USER_BY_ID |

## Auth Caveat: You Supply Your Own Twitter/X Developer App

This is not zero-setup managed OAuth. As of February 2026, Composio removed managed credentials for Twitter. You must connect your own Twitter/X Developer app inside Composio. Create an app in the X Developer Portal, enable OAuth 2.0 with user-context permissions (read and write), and connect those credentials in Composio under the Twitter toolkit. Without your own app, the connection will not authorize.

## Posting Is Approval-Gated

`create_post` and `reply` publish publicly. The `social-publishing` skill holds every post behind explicit human approval before it goes live. Deletes, lookups, search, and user reads are not gated.

## External Requirements

- A **Twitter/X Developer account** with an app configured for OAuth 2.0 user-context (read and write).
- Those OAuth 2.0 credentials connected in Composio under the Twitter toolkit.
- The X free tier has tight rate limits. Plan posting and search volume accordingly.

## Which Bots Use This

- **social-media-manager** -- Publishes approved tweets and replies after human approval, deletes when needed, and searches for context. Posting runs behind the approval gate.
- **social-media-monitor** -- Searches recent tweets for brand mentions and sentiment. Monitoring only, no posting.

## Setup

1. Apply for a [Twitter Developer account](https://developer.x.com/en/portal/dashboard) and create an app with OAuth 2.0 user-context permissions (read and write).
2. Sign up at [composio.dev](https://composio.dev) and get your API key.
3. In Composio, connect your Twitter/X app under the Twitter toolkit using your app's OAuth 2.0 credentials.
4. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/twitter"
    reason: "Social bots need Twitter/X access for approved posting and brand monitoring"
```
