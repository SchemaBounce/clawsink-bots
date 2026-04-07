---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: zoom
  displayName: "Zoom"
  version: "1.0.0"
  description: "Zoom video conferencing — meetings, webinars, and recordings"
  tags: ["zoom", "video", "conferencing", "meetings", "webinars"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "zoom-mcp-server"]
env:
  - name: ZOOM_ACCOUNT_ID
    description: "Zoom Server-to-Server OAuth account ID"
    required: true
  - name: ZOOM_CLIENT_ID
    description: "Zoom Server-to-Server OAuth client ID"
    required: true
  - name: ZOOM_CLIENT_SECRET
    description: "Zoom Server-to-Server OAuth client secret"
    required: true
tools:
  - name: create_meeting
    description: "Create a new Zoom meeting"
    category: meetings
  - name: list_meetings
    description: "List scheduled meetings"
    category: meetings
  - name: get_meeting
    description: "Get details of a specific meeting"
    category: meetings
  - name: update_meeting
    description: "Update an existing meeting"
    category: meetings
  - name: delete_meeting
    description: "Delete a scheduled meeting"
    category: meetings
  - name: list_recordings
    description: "List cloud recordings"
    category: recordings
  - name: list_participants
    description: "List participants of a meeting"
    category: participants
---

# Zoom MCP Server

Provides Zoom tools for meeting management, recording access, and participant tracking via the Zoom Server-to-Server OAuth API.

## Which Bots Use This

- **sales-pipeline** -- Schedules and tracks demo calls with prospects
- **executive-assistant** -- Creates and manages meeting schedules
- **customer-success** -- Schedules onboarding and check-in calls
- **hr-assistant** -- Coordinates interview scheduling

## Setup

1. Create a Server-to-Server OAuth app in the [Zoom App Marketplace](https://marketplace.zoom.us/)
2. Copy the Account ID, Client ID, and Client Secret
3. Add them to your workspace secrets as `ZOOM_ACCOUNT_ID`, `ZOOM_CLIENT_ID`, and `ZOOM_CLIENT_SECRET`
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Zoom server instance across bots:

```yaml
mcpServers:
  - ref: "tools/zoom"
    reason: "Bots need Zoom access for scheduling and managing video meetings"
    config:
      default_timezone: "America/New_York"
```
