---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: brave-search
  displayName: "Brave Search"
  version: "1.0.0"
  description: "Brave Search API — web search, news, and local results"
  tags: ["brave", "search", "web", "news"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@modelcontextprotocol/server-brave-search@0.6.2"]
env:
  - name: BRAVE_API_KEY
    description: "Brave Search API key from brave.com/search/api/"
    required: true
tools:
  - name: brave_web_search
    description: "Search the web using Brave Search"
    category: search
  - name: brave_local_search
    description: "Search for local businesses and places"
    category: search
---

# Brave Search MCP Server

Provides Brave Search API tools for bots that need web search, news results, and local business lookups. An alternative to Exa for keyword-based search.

## Which Bots Use This

- **data-analyst** -- Performs web research to supplement data analysis with external context
- **content-strategist** -- Researches topics, trends, and competitor content for strategy planning

## Setup

1. Get a Brave Search API key from [brave.com/search/api/](https://brave.com/search/api/)
2. Add `BRAVE_API_KEY` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Brave Search server instance across bots:

```yaml
mcpServers:
  - ref: "tools/brave-search"
    reason: "Bots need web search access for research and external data gathering"
    config:
      default_count: 10
```
