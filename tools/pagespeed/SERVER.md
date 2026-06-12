---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: pagespeed
  displayName: "PageSpeed Insights"
  version: "1.0.0"
  description: "Google PageSpeed Insights and Chrome UX Report analysis for Core Web Vitals, Lighthouse scores, and real-world field data."
  tags: ["seo", "performance", "core-web-vitals", "lighthouse", "pagespeed"]
  author: "ruslanlap"
  license: "MIT"
# npm package: pagespeed-insights-mcp (https://www.npmjs.com/package/pagespeed-insights-mcp)
# Pinned to 1.2.3 — latest verified on npm registry 2026-06-11.
# Makes HTTPS calls to the Google PageSpeed Insights API v5 and the Chrome UX Report
# API; no local Chrome binary required. All data paths are outbound-only to
# pagespeedonline.googleapis.com and chromeuxreport.googleapis.com.
#
# AUTH: GOOGLE_API_KEY env var passed to the npx subprocess. The PSI API accepts
# keyless requests but at a very low daily quota (~25 req/day per IP); a key with
# the PageSpeed Insights API enabled is required for production use.
# Create at: https://console.cloud.google.com/apis/credentials
# Enable API: https://console.cloud.google.com/apis/library/pagespeedonline.googleapis.com
#
# NO validation block: a real PSI call triggers a full Lighthouse run (5-15 s, 1 quota
# unit). We do not burn quota on automated health probes. User-initiated "Test
# Connection" is the correct gate; between checks, the agent-runtime callback supplies
# connection status through the AgentStatus side channel.
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "pagespeed-insights-mcp@1.2.3"]

env:
  - name: GOOGLE_API_KEY
    description: "Google API key with PageSpeed Insights API enabled. Required for production; keyless operation is capped at ~25 requests/day per IP. Create at console.cloud.google.com/apis/credentials."
    required: true
    sensitive: true

tools:
  - name: analyze_page_speed
    description: "Comprehensive Google PageSpeed Insights analysis with full Lighthouse metrics for a URL."
    category: performance
  - name: get_performance_summary
    description: "Simplified report of key performance metrics and top improvement opportunities."
    category: performance
  - name: full_report
    description: "Combined lab-based Lighthouse data with real-world Chrome User Experience (CrUX) field measurements."
    category: performance
  - name: get_full_audit
    description: "Complete audit across all Lighthouse categories: Performance, Accessibility, Best Practices, SEO, and PWA."
    category: audit
  - name: get_visual_analysis
    description: "Screenshots and frame-by-frame filmstrips showing page load progression."
    category: audit
  - name: get_element_analysis
    description: "Identifies specific DOM elements causing performance issues."
    category: audit
  - name: get_network_analysis
    description: "Detailed waterfall of network requests during page load."
    category: audit
  - name: get_javascript_analysis
    description: "Analysis of JavaScript execution time and its impact on page performance."
    category: audit
  - name: get_image_optimization_details
    description: "Identifies image-related performance opportunities (oversized or unoptimized images)."
    category: audit
  - name: get_render_blocking_details
    description: "Identifies resources that block the first paint of a page."
    category: audit
  - name: get_third_party_impact
    description: "Analyzes the impact of third-party scripts (ads, analytics, trackers)."
    category: audit
  - name: compare_pages
    description: "Compares performance metrics between two URLs side-by-side."
    category: comparison
  - name: batch_analyze
    description: "Analyzes multiple URLs in sequence and returns aggregated results."
    category: comparison
  - name: get_recommendations
    description: "Prioritized improvement suggestions with actionable fixes based on audit results."
    category: recommendations
  - name: crux_summary
    description: "Chrome User Experience Report (CrUX) real-world field data for LCP, CLS, INP, and FCP."
    category: analytics
  - name: clear_cache
    description: "Clears the internal response cache to force fresh API requests on the next call."
    category: utility
---

# PageSpeed Insights MCP Server

Runs Google PageSpeed Insights analyses and retrieves Chrome UX Report field data for any URL. No local browser required; all data comes from Google's hosted Lighthouse runner and the CrUX dataset.

## Which Bots Use This

- **seo-expert** — audits the site's home page and top URLs for Core Web Vitals violations (LCP > 2.5 s, CLS > 0.1, INP > 200 ms) and Lighthouse SEO score < 90. Files `seo_findings` for each violation.

## Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials) and create an API key.
2. Enable the [PageSpeed Insights API](https://console.cloud.google.com/apis/library/pagespeedonline.googleapis.com) on that key.
3. Add `GOOGLE_API_KEY` to your workspace secrets when deploying an agent that uses this MCP.

## Key Features

- **Lab data** — Lighthouse performance, accessibility, best-practices, SEO, and PWA scores.
- **Field data** — CrUX real-user LCP, CLS, INP, and FCP percentiles from Chrome telemetry.
- **Actionable detail** — element-level, network, JS, image, and render-blocking diagnostics.
- **Batch and compare** — analyze multiple URLs or diff two pages in one call.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/pagespeed"
    required: false
    reason: "Core Web Vitals and Lighthouse scores for SEO performance audits"
    config: {}
```
