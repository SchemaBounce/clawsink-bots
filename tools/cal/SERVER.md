---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: cal
  displayName: "Cal.com"
  version: "1.0.0"
  description: "Cal.com scheduling — bookings, availability, and event types"
  tags: ["cal", "scheduling", "calendar", "bookings"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "cal-mcp@1.0.6"]
env:
  - name: CAL_API_KEY
    description: "Cal.com API key from cal.com/settings/developer"
    required: true
tools:
  - name: list_bookings
    description: "List upcoming and past bookings"
    category: bookings
  - name: create_booking
    description: "Create a new booking"
    category: bookings
  - name: cancel_booking
    description: "Cancel an existing booking"
    category: bookings
  - name: list_event_types
    description: "List available event types"
    category: events
  - name: get_availability
    description: "Get available time slots"
    category: availability
  - name: list_schedules
    description: "List configured schedules"
    category: availability
---

# Cal.com MCP Server

Provides Cal.com API tools for managing bookings, checking availability, and configuring event types.

## Which Bots Use This

- **executive-assistant** -- Books meetings, checks availability, and manages scheduling conflicts
- **sales-pipeline** -- Schedules product demos and follow-up calls with prospects

## Setup

1. Log in to [Cal.com](https://cal.com/) and navigate to Settings > Developer
2. Generate an API key
3. Add `CAL_API_KEY` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Cal.com server instance across bots:

```yaml
mcpServers:
  - ref: "tools/cal"
    reason: "Bots need Cal.com access for scheduling meetings and managing availability"
    config:
      default_event_type: "30min"
```
