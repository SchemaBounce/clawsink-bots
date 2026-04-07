---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: microsoft-teams
  displayName: "Microsoft Teams"
  version: "1.0.0"
  description: "Microsoft Teams — messages, channels, and meetings"
  tags: ["microsoft", "teams", "chat", "meetings", "enterprise"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "teams-mcp-server"]
env:
  - name: MICROSOFT_CLIENT_ID
    description: "Azure AD application client ID"
    required: true
  - name: MICROSOFT_CLIENT_SECRET
    description: "Azure AD application client secret"
    required: true
  - name: MICROSOFT_TENANT_ID
    description: "Azure AD tenant ID"
    required: true
tools:
  - name: send_message
    description: "Send a message to a Teams channel or chat"
    category: messages
  - name: list_channels
    description: "List channels in a team"
    category: channels
  - name: list_teams
    description: "List teams the app has access to"
    category: teams
  - name: create_channel
    description: "Create a new channel in a team"
    category: channels
  - name: list_messages
    description: "List messages in a channel"
    category: messages
  - name: schedule_meeting
    description: "Schedule a Teams meeting"
    category: meetings
  - name: list_members
    description: "List members of a team or channel"
    category: teams
---

# Microsoft Teams MCP Server

Provides Microsoft Teams tools for enterprise messaging, channel management, and meeting scheduling via the Microsoft Graph API.

## Which Bots Use This

- **executive-assistant** -- Schedules meetings, sends reminders, manages team communications
- **customer-support** -- Handles internal escalation channels and cross-team coordination
- **hr-assistant** -- Posts company announcements, manages onboarding channels
- **incident-commander** -- Creates war-room channels and coordinates incident response

## Setup

1. Register an application in [Azure Active Directory](https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
2. Grant Microsoft Graph API permissions: `ChannelMessage.Send`, `Channel.ReadBasic.All`, `Team.ReadBasic.All`, `OnlineMeetings.ReadWrite`
3. Add the credentials to your workspace secrets as `MICROSOFT_CLIENT_ID`, `MICROSOFT_CLIENT_SECRET`, and `MICROSOFT_TENANT_ID`
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Teams server instance across bots:

```yaml
mcpServers:
  - ref: "tools/microsoft-teams"
    reason: "Enterprise bots need Teams access for internal communication and meetings"
    config:
      default_team_id: "your-team-id"
```
