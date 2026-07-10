---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: dropbox
  displayName: "Dropbox"
  version: "1.0.0"
  description: "Dropbox's official hosted MCP server. Connect with your Dropbox account to work with files and folders."
  tags: ["files", "storage", "cloud", "documents"]
  category: "storage"
  author: "dropbox"
  license: "Proprietary"

# This entry replaces the DROPBOX_ACCESS_TOKEN API-key entry: remote hosted OAuth is the default so we no
# longer pay for managed/API-key auth. The serverRef is unchanged; an existing
# connection shows Reconnect once, then uses OAuth.
# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. No pasted credential: the platform
# runs the consent flow against the vendor's own authorization server and keeps
# the access token fresh. The env spec is empty on purpose.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.dropbox.com/mcp"

env: []
---

# Dropbox MCP Server

Dropbox's official hosted MCP server. Connect with your Dropbox account to work with files and folders.

## How authentication works

1. Click **Connect account** on the Dropbox card.
2. A Dropbox sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- No scopes pin: the client requests the server's advertised default set (including the refresh-token scope), so token refresh keeps working.
- Tools are served by the vendor and discovered at session start (files, folders, sharing, and file requests).
- Replaces the DROPBOX_ACCESS_TOKEN API-key entry. An existing connection shows Reconnect once, then uses OAuth.
