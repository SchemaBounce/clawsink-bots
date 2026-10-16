---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: browserbase
  displayName: "Browserbase"
  version: "1.0.0"
  description: "Cloud browser that opens real web pages and takes screenshots, so an agent can see a site the way a visitor does."
  tags: ["browser", "screenshot", "web", "design", "qa", "automation", "presence"]
  category: "browser-scraping"
  author: "browserbase"
  license: "Apache-2.0"
# npm package: @browserbasehq/mcp-server-browserbase (https://www.npmjs.com/package/@browserbasehq/mcp-server-browserbase)
# Pinned to 2.4.3, latest on the npm registry 2026-10-16.
#
# This package has a screenshot tool that returns a PNG image (scaled to at
# most 1568 px on a side). Browserbase's hosted URL server offers navigation
# and page reading but no screenshot, so connect this one when an agent needs
# to see pages. The browser itself runs in Browserbase's cloud.
#
# MODEL: act, observe, extract and agent call a Gemini model and need
# GEMINI_API_KEY. The package's default model, gemini-2.0-flash, is retired,
# so the args name google/gemini-2.5-flash. Navigation, screenshots and the
# session tools need no model key.
#
# NO validation block: creating a session spends Browserbase browser minutes.
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@browserbasehq/mcp-server-browserbase@2.4.3", "--modelName", "google/gemini-2.5-flash", "--browserWidth", "1280", "--browserHeight", "800"]
env:
  - name: BROWSERBASE_API_KEY
    description: "API key from browserbase.com (Settings > API Keys)"
    required: true
    sensitive: true
  - name: BROWSERBASE_PROJECT_ID
    description: "Project ID from browserbase.com (Settings > Project)"
    required: true
  - name: GEMINI_API_KEY
    description: "Google Gemini API key. Only needed for act, observe, extract and agent; screenshots and navigation work without it."
    required: false
    sensitive: true
tools:
  - name: browserbase_session_create
    description: "Open a cloud browser session"
    category: session
  - name: browserbase_session_close
    description: "Close the browser session"
    category: session
  - name: browserbase_stagehand_navigate
    description: "Go to a URL"
    category: navigation
  - name: browserbase_screenshot
    description: "Full-page screenshot of the current page, returned as a PNG image"
    category: capture
  - name: browserbase_stagehand_get_url
    description: "Return the current page URL"
    category: navigation
  - name: browserbase_stagehand_act
    description: "Do one action on the page described in plain language (click, type, scroll)"
    category: interaction
  - name: browserbase_stagehand_observe
    description: "List the actionable elements on the page"
    category: interaction
  - name: browserbase_stagehand_extract
    description: "Extract structured content from the page"
    category: extraction
  - name: browserbase_stagehand_agent
    description: "Run a multi-step browsing task"
    category: automation
---

# Browserbase MCP Server

Opens real web pages in a Browserbase cloud browser and takes screenshots. A
designer or QA agent uses it to see a page the way a visitor sees it: colours,
images, what sits above the fold, whether text is readable on its background.

## How an agent sees a page

1. `browserbase_session_create`, then `browserbase_stagehand_navigate` to the URL.
2. `browserbase_screenshot`. SchemaBounce saves the image to Files under
   `/captures` and the result names its `file_id`.
3. `adl_view_image_file` with that `file_id` and a prompt saying what to check.
4. `browserbase_session_close` when done, so the session stops billing.

The browser is 1280 x 800. A 390 px phone view needs a second connection with
`--browserWidth 390 --browserHeight 844` in its arguments.

## Which Bots Use This

Any bot that has to see a page rather than read its code: a designer auditing
a live page before and after a redesign, a researcher looking at competitor
pages, a tester checking how a release renders.

## Setup

1. Sign up at [browserbase.com](https://www.browserbase.com).
2. Copy the API key and the project ID from Settings.
3. Optional: a Gemini API key for `act`, `observe` and `extract`.
