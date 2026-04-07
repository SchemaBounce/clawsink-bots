---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: redis
  displayName: "Redis"
  version: "1.0.0"
  description: "Redis key-value store — keys, hashes, lists, sets, and pub/sub"
  tags: ["redis", "cache", "key-value", "database"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "redis-mcp"]
env:
  - name: REDIS_URL
    description: "Redis connection URL e.g. redis://localhost:6379"
    required: true
tools:
  - name: get
    description: "Get key value"
    category: keys
  - name: set
    description: "Set key value"
    category: keys
  - name: del
    description: "Delete key"
    category: keys
  - name: keys
    description: "List keys matching pattern"
    category: keys
  - name: hget
    description: "Hash get"
    category: hashes
  - name: hset
    description: "Hash set"
    category: hashes
  - name: lrange
    description: "List range"
    category: lists
  - name: smembers
    description: "Set members"
    category: sets
  - name: info
    description: "Server info"
    category: server
---

# Redis MCP Server

Provides Redis key-value store tools for bots that need to inspect caches, manage data structures, and monitor server health.

## Which Bots Use This

- **sre-devops** — Cache inspection, key analysis, and server health monitoring
- **data-analyst** — Cache analytics and data structure exploration

## Setup

1. Prepare a Redis connection URL
2. Add `REDIS_URL` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Redis server instance across bots:

```yaml
mcpServers:
  - ref: "tools/redis"
    reason: "Bots need Redis access for cache inspection and analytics"
    config:
      read_only: true
```
