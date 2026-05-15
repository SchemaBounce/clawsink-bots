---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: google-meet
  displayName: "Google Meet"
  version: "1.0.0"
  description: "Google Meet video conferencing, create meetings and manage participants"
  tags: ["google", "meet", "video", "conferencing"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "GOOGLEMEET"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like GOOGLEMEET_*."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@cocal/google-calendar-mcp@2.6.1"]
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
  - name: create_meeting
    description: "Create a Meet video conference"
    category: meetings
  - name: get_meeting_link
    description: "Get Meet link for an event"
    category: meetings
  - name: list_upcoming_meetings
    description: "List upcoming meetings with Meet links"
    category: conferencing
---

# Google Meet MCP Server

Provides Google Meet tools for bots that create and manage video conferences.

Google Meet links are created through Google Calendar events with `conferenceData`. This server uses the same underlying package as the google-calendar MCP server (`@cocal/google-calendar-mcp`), but is scoped to video conferencing operations.

## Which Bots Use This

- **churn-predictor** -- Schedules video calls with at-risk customers for retention conversations
- **sales-pipeline** -- Creates demo meeting links and sends them to prospects
- **executive-assistant** -- Sets up team meetings and all-hands with video conferencing

## Setup

1. Create a Google Cloud project and enable the Calendar API (Meet links are created via Calendar)
2. Create OAuth 2.0 credentials (client ID and secret)
3. Add `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and `GOOGLE_REDIRECT_URI` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Google Meet server instance across bots:

```yaml
mcpServers:
  - ref: "tools/google-meet"
    reason: "Bots need video conferencing for customer calls and team meetings"
```
