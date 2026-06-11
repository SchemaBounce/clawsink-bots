---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: twitter
  displayName: "Twitter / X"
  version: "1.0.0"
  description: "Twitter/X API, tweets, timelines, users, and search"
  tags: ["twitter", "x", "social", "tweets"]
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation (SchemaBounce #1614).
# Twitter/X uses standard Bearer auth on the v2 API.
auth:
  type: http_bearer
  token_env: TWITTER_BEARER_TOKEN

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "twitter-mcp@0.1.1"]
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio-managed OAuth
  # connection. Leaving these blank uses the workspace's Composio integration for
  # this service; provide values only to override the managed connection. Marked
  # required:true previously, which made the setup/reconnect modal demand
  # credentials the managed flow already covers.
  - name: TWITTER_BEARER_TOKEN
    description: "Twitter API v2 bearer token"
    required: false
    sensitive: true

# /2/users/me with a bearer token works for user-context tokens; app-
# only bearer tokens will get a 403 (correctly mapped). Tight rate
# limits on the Twitter free tier make this a 1-call-per-15-minute
# operation in production.
#
# NO healthProbe block — Twitter API v2 free tier is so tightly
# rate-limited (10-100 reads per 15min depending on the tier) that
# periodic 5-min probing would saturate the quota immediately.
validation:
  request:
    method: GET
    url: https://api.twitter.com/2/users/me
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Twitter rejected the bearer token (401). Regenerate the token in your X Developer Portal app settings and update TWITTER_BEARER_TOKEN." }
    "403": { state: needs_setup, message: "Bearer token type or app permissions insufficient (403). /2/users/me requires a user-context bearer; app-only bearers won't work here." }
    "429": { state: failed, message: "Twitter API rate limit hit (429). The free tier has very tight limits — wait 15min before retrying." }
    "default": { state: failed }
  timeout_ms: 5000

tools:
  - name: post_tweet
    description: "Post a new tweet"
    category: tweets
  - name: get_tweet
    description: "Get details of a specific tweet"
    category: tweets
  - name: search_tweets
    description: "Search recent tweets by query"
    category: search
  - name: get_user
    description: "Get a user's profile information"
    category: users
  - name: get_timeline
    description: "Get a user's recent timeline"
    category: tweets
  - name: like_tweet
    description: "Like a tweet"
    category: tweets
  - name: retweet
    description: "Retweet a tweet"
    category: tweets
  - name: list_followers
    description: "List followers of a user"
    category: users
---

# Twitter / X MCP Server

Provides Twitter/X API tools for posting tweets, searching conversations, and managing community engagement.

## Which Bots Use This

- **marketing-manager** -- Posts product updates, monitors brand mentions, and tracks engagement
- **devrel** -- Engages with the developer community, shares technical content, and monitors discussions

## Setup

1. Apply for a [Twitter Developer account](https://developer.twitter.com/) and create a project
2. Generate a Bearer Token with read and write permissions
3. Add `TWITTER_BEARER_TOKEN` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Twitter server instance across bots:

```yaml
mcpServers:
  - ref: "tools/twitter"
    reason: "Bots need Twitter/X access for social engagement and brand monitoring"
    config:
      default_tweet_fields: "created_at,public_metrics"
```
