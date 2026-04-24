---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: playwright
  displayName: "Playwright"
  version: "1.0.0"
  description: "Playwright browser automation, testing, scraping, and web interaction"
  tags: ["playwright", "browser", "testing", "automation", "e2e"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@playwright/mcp@0.0.70"]
env: []
tools:
  - name: browser_navigate
    description: "Navigate to a URL"
    category: navigation
  - name: browser_click
    description: "Click an element on the page"
    category: interaction
  - name: browser_type
    description: "Type text into an input field"
    category: interaction
  - name: browser_screenshot
    description: "Take a screenshot of the page"
    category: capture
  - name: browser_snapshot
    description: "Capture an accessibility snapshot of the page"
    category: capture
  - name: browser_wait
    description: "Wait for an element or condition"
    category: navigation
  - name: browser_select_option
    description: "Select an option from a dropdown"
    category: interaction
  - name: browser_hover
    description: "Hover over an element"
    category: interaction
  - name: browser_execute_javascript
    description: "Execute JavaScript in the browser context"
    category: interaction
  - name: browser_pdf_save
    description: "Save the current page as a PDF"
    category: capture
---

# Playwright MCP Server

Provides Playwright browser automation tools for end-to-end testing, web scraping, and interactive web workflows. Requires Chromium, which is automatically downloaded on first run.

## Which Bots Use This

- **qa-tester** -- Runs automated end-to-end tests against web applications
- **web-scraper** -- Extracts structured data from websites
- **competitive-analyst** -- Monitors competitor websites for changes
- **seo-analyst** -- Audits page structure, meta tags, and performance

## Setup

1. No environment variables are required -- the server works out of the box
2. Chromium is automatically downloaded on first run via `npx @playwright/mcp@latest`
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Playwright server instance across bots:

```yaml
mcpServers:
  - ref: "tools/playwright"
    reason: "Bots need browser automation for testing and web interaction"
    config:
      headless: true
```
