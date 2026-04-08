---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: hyperbrowser
  displayName: "Hyperbrowser"
  version: "1.0.0"
  description: "Cloud browser infrastructure for AI agents — browse, scrape, and automate the web"
  tags: ["browser", "web", "scraping", "automation", "presence"]
  author: "hyperbrowser"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "hyperbrowser-mcp@1.0.25"]
env:
  - name: HYPERBROWSER_API_KEY
    description: "API key from hyperbrowser.ai"
    required: true
tools:
  - name: scrape_webpage
    description: "Extract formatted content (markdown, screenshot) from any webpage"
    category: scraping
  - name: crawl_webpages
    description: "Navigate through multiple linked pages and extract LLM-friendly content"
    category: crawling
  - name: extract_structured_data
    description: "Convert messy HTML into structured JSON using a schema"
    category: extraction
  - name: search_with_bing
    description: "Query the web and get results via Bing search"
    category: search
  - name: browser_use_agent
    description: "Fast, lightweight browser automation with natural language commands"
    category: automation
  - name: openai_computer_use_agent
    description: "General-purpose automation using OpenAI's computer use model"
    category: automation
  - name: claude_computer_use_agent
    description: "Complex browser tasks using Claude computer use"
    category: automation
  - name: create_profile
    description: "Create a new persistent browser profile for stateful sessions"
    category: profiles
  - name: delete_profile
    description: "Delete an existing persistent browser profile"
    category: profiles
  - name: list_profiles
    description: "List all existing persistent browser profiles"
    category: profiles
---

# Hyperbrowser MCP Server

Provides cloud browser infrastructure for AI agents. Agents can browse websites, fill forms, extract data, and automate web interactions — all without managing browser instances.

## Which Bots Use This

- **customer-support** — Looks up help documentation and knowledge base articles
- **sre-devops** — Browses dashboards and monitoring UIs during incidents
- **ux-researcher** — Navigates competitor websites for UX analysis
- **market-intelligence** — Browses industry news sites and competitor pages
- **social-media-monitor** — Monitors social media platforms for brand mentions
- **devrel** — Browses community forums and documentation sites

## Setup

1. Sign up at [hyperbrowser.ai](https://hyperbrowser.ai) and get your API key
2. Add `HYPERBROWSER_API_KEY` to your workspace secrets

## Key Features

- **Sub-second browser startup** — 100s of concurrent sessions
- **Built-in CAPTCHA solving** and anti-bot evasion
- **Persistent profiles** — maintain logged-in state across sessions
- **AI-native automation** — natural language commands via `browser_use_agent`

## Team Usage

```yaml
mcpServers:
  - ref: "tools/hyperbrowser"
    reason: "Team bots need web browsing for research and monitoring"
    config: {}
```
