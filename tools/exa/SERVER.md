---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: exa
  displayName: "Exa Search"
  version: "1.0.0"
  description: "Semantic web search for AI agents — token-efficient, embedding-based search"
  tags: ["search", "web", "semantic", "research", "presence"]
  author: "exa"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "exa-mcp-server"]
env:
  - name: EXA_API_KEY
    description: "API key from exa.ai"
    required: true
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
2. Add `EXA_API_KEY` to your workspace secrets

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
