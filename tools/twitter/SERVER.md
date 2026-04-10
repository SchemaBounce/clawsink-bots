---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: twitter
  displayName: "Twitter / X"
  version: "1.0.0"
  description: "Twitter/X API — tweets, timelines, users, and search"
  tags: ["twitter", "x", "social", "tweets"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "twitter-mcp@0.1.1"]
env:
  - name: TWITTER_BEARER_TOKEN
    description: "Twitter API v2 bearer token"
    required: true
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
