---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: airbnb
  displayName: "Airbnb (search)"
  version: "0.1.4"
  description: "Search public Airbnb listings and fetch listing details. Read-only market research, no host account"
  tags: ["short-term-rental", "vacation-rental", "market-research", "search", "comps"]
  author: "openbnb-org (community)"
  license: "MIT"
  category: web
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@openbnb/mcp-server-airbnb@0.1.4"]
env: []
tools:
  - name: airbnb_search
    description: "Search Airbnb listings by location, dates, guests, price, and property type"
    category: search
  - name: airbnb_listing_details
    description: "Get details for a specific listing ID"
    category: search
---

# Airbnb Search MCP Server

Read-only search of public Airbnb listings: competitive pricing, amenities, and availability lookups. This server is not affiliated with Airbnb and has no access to your own host account. Manage your own Airbnb inventory via the Lodgify channel. It needs no credentials and respects `robots.txt` by default (we do not pass `--ignore-robots-txt`).

## Which Bots Use This

- **str-property-manager** -- Competitive pricing research and market comps
- **str-pricing-optimizer** -- Benchmarks portfolio rates against comparable public listings

## Setup

No credentials are required. The server starts automatically when a bot that references it runs.
