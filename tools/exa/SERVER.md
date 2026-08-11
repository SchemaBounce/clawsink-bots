---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: exa
  displayName: "Exa Search"
  version: "1.0.0"
  description: "Semantic web search for AI agents, token-efficient, embedding-based search"
  tags: ["search", "web", "semantic", "research", "presence"]
  category: "browser-scraping"
  author: "exa"
  license: "MIT"
# Declarative auth + validation.
# Exa's HTTP API uses an x-api-key header, applied automatically before
# the validation request. Test Connection and the connection card always
# show the same verdict.
auth:
  type: api_key_header
  token_env: EXA_API_KEY
  header_name: x-api-key

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "exa-mcp-server@3.2.0"]
env:
  - name: EXA_API_KEY
    description: "API key from exa.ai"
    required: true
    sensitive: true

# Validation calls Exa's /search endpoint with a minimal probe query.
# A successful call consumes ~1 Exa credit, which is the cost of
# the user clicking Test Connection — bounded by user action.
#
# NO healthProbe block is intentional: periodic probing would burn Exa
# credits on every workspace connection, and Exa has no free "ping"
# endpoint. Health status between manual checks may lag; clicking Test
# Connection always gives the current, verified state.
validation:
  request:
    method: POST
    url: https://api.exa.ai/search
    headers:
      Content-Type: application/json
    body: '{"query":"connectivity check","numResults":1}'
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Exa rejected the API key (401). Check or regenerate the key at https://dashboard.exa.ai/api-keys." }
    "402": { state: needs_setup, message: "Exa account out of credits (402). Top up at https://dashboard.exa.ai." }
    "403": { state: needs_setup, message: "Exa API key lacks required permissions (403)." }
    "429": { state: failed, message: "Exa rate limit hit (429). Retry in a minute." }
    "default": { state: failed }
  timeout_ms: 5000

tools:
  - name: web_search_exa
    description: "Search the web for any topic and get clean, ready-to-use content"
    category: search
  - name: get_code_context_exa
    description: "Find code examples, documentation, and programming solutions from GitHub, Stack Overflow, and docs"
    category: code
  - name: crawling_exa
    description: "Get the full content of a specific webpage from a known URL"
    category: crawling
  - name: web_search_advanced_exa
    description: "Advanced web search with full control over filters, domains, dates, and content options"
    category: search
---

# Exa Search MCP Server

Provides semantic web search optimized for AI agents. Unlike traditional search engines, Exa uses embedding-based retrieval and condenses webpages to only relevant tokens — saving 10x on LLM costs.

## Which Bots Use This

- **business-analyst** — Researches market trends and competitive intelligence
- **blog-writer** — Finds sources and references for content creation
- **market-intelligence** — Monitors industry news and competitor activity
- **compliance-auditor** — Searches for regulatory updates and legal changes
- **sre-devops** — Finds documentation and troubleshooting guides
- **product-owner** — Researches user needs and feature requests

## Setup

1. Sign up at [exa.ai](https://exa.ai) and get your API key
2. Add `EXA_API_KEY` in the MCP connection setup

## Key Features

- **Token-efficient** — condenses webpages to only relevant content, reducing LLM costs
- **Semantic search** — understands intent, not just keywords
- **Code context** — specialized search for programming docs and examples
- **Advanced filters** — domain, date range, content type filtering

## Team Usage

```yaml
mcpServers:
  - ref: "tools/exa"
    reason: "Team bots need web search for research and monitoring"
    config: {}
```
