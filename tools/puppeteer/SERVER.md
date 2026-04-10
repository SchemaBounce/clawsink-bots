---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: puppeteer
  displayName: "Puppeteer"
  version: "1.0.0"
  description: "Puppeteer browser automation — navigation, screenshots, and scraping"
  tags: ["puppeteer", "browser", "automation", "scraping"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@modelcontextprotocol/server-puppeteer@2025.5.12"]
env: []
tools:
  - name: puppeteer_navigate
    description: "Navigate to a URL"
    category: navigation
  - name: puppeteer_screenshot
    description: "Take a screenshot of the current page"
    category: capture
  - name: puppeteer_click
    description: "Click an element on the page"
    category: interaction
  - name: puppeteer_fill
    description: "Fill in a form field"
    category: interaction
  - name: puppeteer_select
    description: "Select an option from a dropdown"
    category: interaction
  - name: puppeteer_hover
    description: "Hover over an element"
    category: interaction
  - name: puppeteer_evaluate
    description: "Execute JavaScript in the browser context"
    category: interaction
---

# Puppeteer MCP Server

Provides Puppeteer browser automation tools for bots that need to navigate websites, take screenshots, fill forms, and scrape data. An alternative to Playwright.

## Which Bots Use This

- **qa-tester** -- Automates browser-based UI testing, captures screenshots, and validates page content
- **data-analyst** -- Scrapes web pages for data collection and competitive analysis

## Setup

1. No environment variables are required -- Puppeteer downloads Chromium automatically on first run
2. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Puppeteer server instance across bots:

```yaml
mcpServers:
  - ref: "tools/puppeteer"
    reason: "Bots need browser automation for testing and web data extraction"
    config:
      headless: true
```
