---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: chrome-devtools
  displayName: "Chrome DevTools (remote browser)"
  version: "1.0.0"
  description: "Drives a hosted Chrome over the DevTools protocol: open pages, take screenshots, emulate a phone, read styles, run Lighthouse and performance traces. The browser runs at your browser provider; SchemaBounce runs only the small controller."
  tags: ["browser", "screenshot", "devtools", "chrome", "design", "qa", "lighthouse", "performance", "presence"]
  category: "browser-scraping"
  author: "google"
  license: "Apache-2.0"
# npm package: chrome-devtools-mcp (https://www.npmjs.com/package/chrome-devtools-mcp)
# Pinned to 1.10.1 (published 2026-09-23). 1.11.0 (2026-10-15) was a day old
# when this entry was written; move the pin once a release has been out two
# weeks.
#
# The server never starts a browser here: --wsEndpoint makes it connect to a
# Chrome you already have at a hosted browser provider (or your own Chrome with
# remote debugging on). It connects on the first browser call, so starting the
# connection and listing its tools needs no browser.
#
# The endpoint carries its own token, so it is a credential: it reaches the
# server as a command-line argument on a workspace's own gateway. The shared
# free-plan gateway refuses a credential on the command line, so this server
# runs on paid plans.
#
# A screenshot comes back as an image, which SchemaBounce saves to the
# workspace Files under /captures. A screenshot of 2 MB or more stays on the
# server instead: take the viewport rather than the full page, or use JPEG.
#
# --no-usage-statistics: no usage telemetry from our gateway to Google.
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "chrome-devtools-mcp@1.10.1", "--wsEndpoint", "${BROWSER_WS_ENDPOINT}", "--no-usage-statistics"]
env:
  - name: BROWSER_WS_ENDPOINT
    description: "WebSocket URL of a hosted Chrome, starting wss:// and including its access token (from your browser provider's dashboard, for example a Browserless token URL)"
    required: true
    sensitive: true
tools:
  - name: navigate_page
    description: "Open a URL, or go back, forward or reload"
    category: navigation
  - name: new_page
    description: "Open a new tab"
    category: navigation
  - name: take_screenshot
    description: "Screenshot of the viewport, the full page or one element, returned as an image"
    category: capture
  - name: take_snapshot
    description: "Text snapshot of the page's accessibility tree, with element ids for clicks"
    category: capture
  - name: emulate
    description: "Emulate a device viewport (390x844 phone), dark mode, network or CPU throttling"
    category: emulation
  - name: resize_page
    description: "Resize the page"
    category: emulation
  - name: get_css_styles
    description: "Computed CSS styles of an element"
    category: inspection
  - name: click
    description: "Click an element"
    category: interaction
  - name: fill
    description: "Type into an input"
    category: interaction
  - name: evaluate_script
    description: "Run JavaScript in the page"
    category: interaction
  - name: lighthouse_audit
    description: "Lighthouse audit for accessibility, SEO and best practices"
    category: audit
  - name: performance_start_trace
    description: "Start a performance trace (Core Web Vitals)"
    category: performance
  - name: performance_stop_trace
    description: "Stop the trace and report insights"
    category: performance
  - name: list_network_requests
    description: "Network requests the page made"
    category: inspection
  - name: list_pages
    description: "Open tabs"
    category: navigation
---

# Chrome DevTools (remote browser)

Lets an agent see and inspect a web page the way a visitor's Chrome does:
screenshots at desktop and phone sizes, computed styles, Lighthouse, and
performance traces. The browser itself runs at a hosted browser provider, so
no browser runs inside SchemaBounce.

## How an agent sees a page

1. Open the page.
2. Take a screenshot. SchemaBounce saves it to Files under `/captures` and the
   result names its `file_id`.
3. Look at it with `adl_view_image_file`, naming what to check.
4. Emulate a 390 x 844 phone and take another screenshot for the phone view.

## Setup

1. Get a hosted Chrome from a browser provider that gives you a WebSocket URL
   with your token in it (`wss://...`). Your own Chrome started with
   `--remote-debugging-port` behind a secure tunnel also works.
2. Paste that URL as `BROWSER_WS_ENDPOINT`.

The URL is a credential: anyone holding it can drive the browser and spend
your provider's minutes. Rotate it at the provider if it leaks.

## Which Bots Use This

Any bot that has to see a page rather than read its code: a designer
auditing a live page before and after a redesign, a researcher looking at
competitor pages, a tester checking how a release renders.
