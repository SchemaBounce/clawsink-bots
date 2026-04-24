---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: mcp-awareness
  displayName: "External Connections Awareness"
  version: "1.0.0"
  description: "Discover and use workspace MCP connections to interact with external services like GitHub, Slack, Stripe, and Google Workspace."
  tags: ["mcp", "connections", "integrations", "external-services"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_tool_search"]
data:
  producesEntityTypes: []
  consumesEntityTypes: []
---
# External Connections Awareness

Teaches agents that their workspace can have external service connections (MCP servers) and how to discover and use them. Connected services provide tools the agent can call directly, GitHub issues, Slack messages, Stripe charges, Google Sheets, and more.

## When to Use

- User asks the agent to interact with an external service
- Agent needs to send notifications, create documents, or read external data
- Business processes require actions outside the data layer (email, chat, payments)

## What You Get

- **Discovery**: Check what services are connected to this workspace
- **Direct tool access**: Connected services expose tools callable by the agent
- **Graceful fallback**: If a service isn't connected, guide the user to add it
- **Security**: Credentials are managed by the platform, never exposed to agents
