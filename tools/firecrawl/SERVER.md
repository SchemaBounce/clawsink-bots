---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: firecrawl
  displayName: "Firecrawl"
  version: "1.0.0"
  description: "Web crawling and data extraction API for AI agents, no browser required"
  tags: ["crawling", "scraping", "web", "extraction", "research", "presence"]
  author: "firecrawl"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "firecrawl-mcp@3.11.0"]
env:
  - name: FIRECRAWL_API_KEY
    description: "API key from firecrawl.dev"
    required: true
tools:
  - name: firecrawl_scrape
    description: "Extract content from a single URL in JSON, markdown, or branded formats"
    category: scraping
  - name: firecrawl_batch_scrape
    description: "Process multiple URLs efficiently with parallel handling"
    category: scraping
  - name: firecrawl_interact
    description: "Browser automation, click, type, navigate on scraped pages"
    category: automation
  - name: firecrawl_map
    description: "Discover all URLs within a website for site mapping"
    category: discovery
  - name: firecrawl_crawl
    description: "Multi-page extraction with configurable depth and limits"
    category: crawling
  - name: firecrawl_search
    description: "Web search and scrape results in one step"
    category: search
  - name: firecrawl_agent
    description: "Complex multi-source research and data extraction with autonomous navigation"
    category: research
  - name: firecrawl_browser
    description: "Raw CDP browser sessions for advanced automation"
    category: automation
---

# Firecrawl MCP Server

Provides fast web crawling and data extraction for AI agents without spinning up full browsers. Returns LLM-ready markdown instead of raw HTML — 10x cheaper and faster than browser-based scraping for read-only data extraction.

## Which Bots Use This

- **blog-writer** — Crawls reference sites for content research
- **business-analyst** — Extracts structured data from industry reports
- **market-intelligence** — Crawls competitor websites for pricing and features
- **content-scheduler** — Scrapes social media and news for content ideas
- **data-engineer** — Extracts data from web sources for pipeline ingestion
- **knowledge-base-curator** — Crawls documentation sites for knowledge base updates

## Setup

1. Sign up at [firecrawl.dev](https://firecrawl.dev) and get your API key
2. Add `FIRECRAWL_API_KEY` to your workspace secrets

## When to Use Firecrawl vs Hyperbrowser

| Use Case | Firecrawl | Hyperbrowser |
|----------|-----------|--------------|
| Read-only data extraction | Best choice | Overkill |
| Form filling / login | Use `firecrawl_interact` | Better choice |
| Multi-page crawling | Best choice | Works but slower |
| Interactive web apps | Limited | Best choice |
| Cost | Lower (no browser) | Higher (full browser) |

## Team Usage

```yaml
mcpServers:
  - ref: "tools/firecrawl"
    reason: "Team bots need web crawling for data extraction and research"
    config: {}
```
