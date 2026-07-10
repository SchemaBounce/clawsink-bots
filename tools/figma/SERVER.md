---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: figma
  displayName: "Figma"
  version: "1.0.0"
  description: "Figma's official hosted MCP server. Connect with your Figma account to read files, frames, and components."
  tags: ["design", "ui", "prototyping", "collaboration"]
  category: "design"
  author: "figma"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. No pasted credential: the platform
# runs the consent flow against the vendor's own authorization server and keeps
# the access token fresh. The env spec is empty on purpose.
auth:
  type: oauth2_mcp
  scopes: ["mcp:connect"]

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.figma.com/mcp"

env: []
---

# Figma MCP Server

Figma's official hosted MCP server. Connect with your Figma account to read files, frames, and components.

## How authentication works

1. Click **Connect account** on the Figma card.
2. A Figma sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- Requested scopes are pinned to mcp:connect.
- Tools are served by the vendor and discovered at session start (files, frames, components, and comments).
