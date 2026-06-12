---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: airbnb
  displayName: "Airbnb"
  version: "1.0.0"
  description: "Public Airbnb listing search and property details. Read-only. No host account management — use tools/lodgify for that."
  tags: ["airbnb", "str", "vacation-rental", "search", "hospitality"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@openbnb/mcp-server-airbnb@0.1.4"]
env: []

tools:
  - name: airbnb_search
    description: "Search Airbnb listings by location, dates, guest count, price range, and property type (public, read-only)"
    category: search
  - name: airbnb_listing_details
    description: "Retrieve detailed property information including amenities, house rules, location, and highlights (public, read-only)"
    category: search
---

# Airbnb MCP Server

Provides public Airbnb listing search and property detail retrieval. **Read-only, no authentication required.** Does not support host account management, calendar editing, pricing, bookings, or any write operations — those are covered by Lodgify.

## Scope

This server is limited to two tools: `airbnb_search` and `airbnb_listing_details`. Both use Airbnb's public listing data (equivalent to what an anonymous visitor sees). Respects robots.txt by default.

## Why Not Airbnb Account Management?

Airbnb does not expose a public API for host account management (no official SDK for reading/writing host listings, availability, or bookings). STR hosts who need multi-channel management should use `tools/lodgify`, which syncs to Airbnb, VRBO, and Booking.com through Lodgify's channel manager.

## Which Bots Use This

- **str-pricing-optimizer** -- Searches competitor listings near managed properties for market rate benchmarking
- **str-property-marketer** -- Researches competitor descriptions and amenity positioning

## Package

`@openbnb/mcp-server-airbnb@0.1.4` (npm, no auth) -- MCP server for Airbnb public search.
Verified: https://www.npmjs.com/package/@openbnb/mcp-server-airbnb

## Team Usage

```yaml
mcpServers:
  - ref: "tools/airbnb"
    reason: "Competitive intelligence — search nearby listings for pricing and content benchmarking"
```
