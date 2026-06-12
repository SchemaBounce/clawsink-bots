---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: ai-citation-tracker
  displayName: "AI Citation Tracker"
  version: "1.0.0"
  description: "Measures brand citation share-of-voice across ChatGPT, Claude, and Perplexity via the CitationBench hosted MCP. Tracks whether and how often SchemaBounce is cited for target queries."
  tags: ["geo", "aeo", "citation", "share-of-voice", "seo", "analytics"]
  author: "citationbench"
  license: "commercial"
# Hosted MCP server by CitationBench (https://citationbench.com).
# Verified real and active 2026-06-11: endpoint responds, docs at
# citationbench.com/uses/ai-citation-tracking-api, MCP quickstart
# documents "claude mcp add citationbench https://mcp.citationbench.com/mcp".
#
# Transport: streamable-http (hosted, no self-hosting required).
# Auth: http_bearer with a CitationBench API key (sk_test_* or sk_live_*).
#       The endpoint also returns shape-complete demo data without auth,
#       so agent runs succeed before a key is provisioned — but citation
#       data will be demo-only until a real key is set.
#
# This manifest documents the three AI-citation tools from the ~35-tool
# CitationBench MCP suite that the seo-expert GEO workflow uses. The
# remaining tools (rank tracking, content production, link-building) are
# available once the connection is established but are outside seo-expert's
# current scope.
#
# Engines tracked: ChatGPT, Claude, Perplexity (confirmed). Gemini support
# is listed on the marketing page but not confirmed in API docs as of 2026-06-11.
auth:
  type: http_bearer
  token_env: CITATIONBENCH_API_KEY

transport:
  type: "streamable-http"
  url: "https://mcp.citationbench.com/mcp"

env:
  - name: CITATIONBENCH_API_KEY
    description: "CitationBench API key (sk_test_* for sandbox, sk_live_* for production). Sign up at citationbench.com to obtain a key. Without a key the server returns shape-complete demo data — no real citation measurements."
    required: false
    sensitive: true

tools:
  - name: research.ai_citation.check
    description: "Check whether a domain is cited for a specific query across ChatGPT, Claude, and Perplexity. Returns cited/mentioned/absent per engine plus a share-of-voice score."
    category: citation
  - name: research.ai_citation.share_of_voice
    description: "Compute share-of-voice for a domain across a set of queries and AI engines. Aggregates citation presence into a percentage score relative to tracked competitors."
    category: citation
  - name: research.ai_citation.history
    description: "Return the citation trajectory for a domain and query set over time. Used to track whether GEO improvements are moving the share-of-voice needle."
    category: citation
---

# AI Citation Tracker MCP Server

Hosted MCP by [CitationBench](https://citationbench.com). Measures how often and in what context SchemaBounce is cited by AI answer engines (ChatGPT, Claude, Perplexity) for brand and category queries.

## What It Measures

For each tracked query (e.g., "real-time CDC platform", "schemabounce vs fivetran"):

- **cited** — the domain appears as a source link in the AI's answer
- **mentioned** — the domain is named in the answer text but not linked
- **absent** — the domain does not appear

Aggregated across queries, this gives a **share-of-voice** score — the fraction of AI answers that include SchemaBounce for the target query set.

## How the seo-expert Bot Uses This

The GEO sub-agent:
1. Reads `brand_queries` from `seo:audit:cache` (seeded by the bootstrap script).
2. Calls `research.ai_citation.check` for each query × engine.
3. Calls `research.ai_citation.share_of_voice` for an aggregate score.
4. Calls `research.ai_citation.history` to compare to the previous run.
5. Writes `entity_type=seo_geo_citation` records with metric_name, engine, query, value, delta.
6. Files a `seo_finding` (severity=info) when share-of-voice drops more than 5 points run-over-run.

**Low share-of-voice is a signal, not a root cause.** The bot's suggested_fix always points to a foundational content action (thin content, missing entity clarity, low E-E-A-T) — never to an AI-specific hack.

## Auth + Demo Mode

Without `CITATIONBENCH_API_KEY`, the server returns shape-complete demo data. Useful for development, but the numbers are synthetic. Set `required: false` intentionally so the agent runs and the GEO workflow is exercised even before a paid key is provisioned.

## Setup

1. Sign up at [citationbench.com](https://citationbench.com).
2. Add your `CITATIONBENCH_API_KEY` to workspace secrets.
3. Connect this MCP server from the SEO Expert deploy modal.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/ai-citation-tracker"
    required: false
    reason: "GEO measurement: track AI citation share-of-voice for brand queries"
```
