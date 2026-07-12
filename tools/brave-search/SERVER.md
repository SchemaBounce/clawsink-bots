---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: brave-search
  displayName: "Brave Search"
  version: "1.0.0"
  description: "Brave Search API, web search, news, and local results"
  tags: ["brave", "search", "web", "news"]
  category: "browser-scraping"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation (SchemaBounce #1614).
# Brave Search uses the X-Subscription-Token header.
auth:
  type: api_key_header
  token_env: BRAVE_API_KEY
  header_name: X-Subscription-Token

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@modelcontextprotocol/server-brave-search@0.6.2"]
env:
  - name: BRAVE_API_KEY
    description: "Brave Search API key from brave.com/search/api/"
    required: true
    sensitive: true

# Validation calls /web/search with a tiny query. Brave's free tier
# allows 1 query/second; manual revalidate is well within limits.
# Each call consumes 1 request from the subscription's monthly
# allowance — bounded by user clicks.
#
# NO healthProbe block: 5min cadence would burn ~288 requests/day
# per workspace per connection, which is half the free tier's daily
# allowance for one user. Manual validate via the UI is the only
# path that costs requests.
validation:
  request:
    method: GET
    url: "https://api.search.brave.com/res/v1/web/search?q=connectivity+check&count=1"
    headers:
      Accept: application/json
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Brave Search rejected the API key (401). Check the key at https://api-dashboard.search.brave.com/app/keys and update BRAVE_API_KEY." }
    "403": { state: needs_setup, message: "API key lacks required permissions (403) or subscription expired." }
    "422": { state: failed, message: "Brave Search rejected the request shape (422)." }
    "429": { state: failed, message: "Brave Search rate limit hit (429). Retry in a minute." }
    "default": { state: failed }
  timeout_ms: 5000

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
2. Add `BRAVE_API_KEY` in the MCP connection setup
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
