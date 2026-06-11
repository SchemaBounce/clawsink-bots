---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: google-analytics
  displayName: "Google Analytics"
  version: "1.0.0"
  description: "Google Analytics 4 traffic, sessions, engagement, and conversion data via Composio's managed-OAuth gateway."
  tags: ["google", "analytics", "seo", "traffic", "conversions", "engagement", "composio"]
  author: "schemabounce"
  license: "MIT"
# Composio toolkit: GOOGLE_ANALYTICS — 67 tools in total.
# Composio toolkit page: https://composio.dev/toolkits/google_analytics
# Slug confirmed in core-api schemabounce-api/internal/adl/composio_imported_slugs.go:
#   {Slug: "google_analytics", DisplayName: "Google Analytics", ToolsCount: 67}
#
# Auth model: Composio managed-OAuth. The user connects their Google Analytics
# account inside Composio once via OAuth. At runtime, the agent calls
# execute_composio_tool with GOOGLEANALYTICS_* action names and the Composio
# MCP gateway routes the call through the stored OAuth tokens.
#
# ENV: COMPOSIO_API_KEY is required — it authenticates the @composio/mcp
# subprocess to Composio's backend. The GA4 OAuth tokens themselves live in
# Composio and are NOT a separate env var the workspace needs to supply.
auth:
  method: "composio"
  composioToolkit: "GOOGLE_ANALYTICS"
  setupReason: "Authorized via Composio's managed-OAuth gateway. Connect your Google Analytics account inside Composio; the agent calls execute_composio_tool with GOOGLEANALYTICS_* action names (e.g. GOOGLEANALYTICS_RUN_REPORT, GOOGLEANALYTICS_LIST_ACCOUNT_SUMMARIES)."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@composio/mcp@1.0.9"]
env:
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP subprocess. Your Google Analytics account is then connected inside Composio via OAuth."
    required: true
    sensitive: true

# Tools listed here are the SEO-relevant subset of the 67-tool GOOGLE_ANALYTICS
# toolkit. Verified from https://composio.dev/toolkits/google_analytics (2026-06-11).
# toolCount reflects only this listed subset; the full toolkit has 67 actions.
tools:
  - name: run_report
    description: "Custom GA4 report with any dimension/metric combination: sessions, users, traffic-by-channel, bounce rate, engagement rate, conversions, revenue."
    category: reporting
  - name: batch_run_reports
    description: "Run up to five GA4 reports in a single API call to reduce latency and quota consumption."
    category: reporting
  - name: run_pivot_report
    description: "Pivot-table report for multi-dimensional analysis such as traffic source versus landing page."
    category: reporting
  - name: run_realtime_report
    description: "Real-time data showing active users and event counts over the last 30 minutes."
    category: reporting
  - name: run_funnel_report
    description: "Conversion funnel report showing user drop-off at each step of a defined funnel."
    category: conversions
  - name: list_conversion_events
    description: "List all conversion events configured on a GA4 property, with event name and creation timestamp."
    category: conversions
  - name: list_account_summaries
    description: "List all GA4 accounts and properties the credential can access, with property IDs."
    category: discovery
  - name: create_audience_export
    description: "Create an export of a GA4 audience segment for offline analysis or custom reporting."
    category: audiences
---

# Google Analytics MCP Server

Provides GA4 reporting and audience tools via Composio's managed-OAuth gateway. The bot calls `execute_composio_tool` with `GOOGLEANALYTICS_*` action names; Composio routes the call through the workspace's connected Google Analytics OAuth token.

**Toolkit source:** [GOOGLE_ANALYTICS on Composio](https://composio.dev/toolkits/google_analytics) — 67 tools total.

## Auth Model: Composio

The user connects their Google Analytics account inside Composio once via OAuth. At runtime, the subprocess (`npx @composio/mcp@1.0.9`) authenticates to Composio's backend with `COMPOSIO_API_KEY`, which then routes GA4 API calls through the stored OAuth tokens. No separate Google credentials are needed in the workspace.

## SEO Use Cases

- **Traffic by channel** — use `run_report` with `sessionDefaultChannelGroup` dimension to break down organic vs. paid vs. referral sessions.
- **Landing page performance** — `run_report` with `landingPage` dimension + `sessions`, `engagementRate`, `bounceRate` metrics.
- **Conversion tracking** — `list_conversion_events` to audit configured goals; `run_report` with `conversions` and `ecommercePurchases` metrics.
- **Almost-ranking pages** — combine GSC position data (from google-search-console MCP) with GA4 session/engagement data for the same URLs.

## Which Bots Use This

- **seo-expert** — supplements Google Search Console keyword data with GA4 engagement and conversion metrics. The auditor uses `run_report` for sessions-by-channel and landing-page engagement; `list_conversion_events` to verify conversion tracking is intact.

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key.
2. Add `COMPOSIO_API_KEY` to your workspace secrets.
3. In Composio, connect your Google Analytics account via OAuth under the Google Analytics toolkit.
4. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/google-analytics"
    required: false
    reason: "GA4 traffic, engagement, and conversion data to supplement GSC keyword signals"
```
