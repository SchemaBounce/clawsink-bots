---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: google-calendar
  displayName: "Google Calendar"
  version: "1.0.0"
  description: "Google Calendar events, scheduling, and meeting management"
  tags: ["google", "calendar", "scheduling", "meetings"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@cocal/google-calendar-mcp"]
env:
  - name: GOOGLE_CLIENT_ID
    description: "Google OAuth client ID"
    required: true
  - name: GOOGLE_CLIENT_SECRET
    description: "Google OAuth client secret"
    required: true
  - name: GOOGLE_REDIRECT_URI
    description: "Google OAuth redirect URI"
    required: true
tools:
  - name: list_calendars
    description: "List calendars"
    category: calendars
  - name: list_events
    description: "List events in a calendar"
    category: events
  - name: create_event
    description: "Create a calendar event"
    category: events
  - name: update_event
    description: "Update an existing event"
    category: events
  - name: delete_event
    description: "Delete an event"
    category: events
  - name: find_free_time
    description: "Find free/busy times"
    category: scheduling
  - name: quick_add
    description: "Quick-add event from text"
    category: events
  - name: move_event
    description: "Move event to another calendar"
    category: events
---

# Google Calendar MCP Server

Provides Google Calendar API tools for bots that manage events, scheduling, and meeting coordination.

## Which Bots Use This

- **churn-predictor** -- Schedules check-in calls with at-risk customers
- **executive-assistant** -- Manages calendars, books meetings, and resolves scheduling conflicts
- **sales-pipeline** -- Schedules demos and follow-up meetings with prospects

## Setup

1. Create a Google Cloud project and enable the Calendar API
2. Create OAuth 2.0 credentials (client ID and secret)
3. Add `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and `GOOGLE_REDIRECT_URI` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Google Calendar server instance across bots:

```yaml
mcpServers:
  - ref: "tools/google-calendar"
    reason: "Bots need calendar access for scheduling meetings and check-ins"
    config:
      default_calendar: "primary"
```
