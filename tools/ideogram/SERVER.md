---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: ideogram
  displayName: "Ideogram"
  version: "1.0.0"
  description: "Ideogram's official hosted MCP server. Generate images with strong text rendering from prompts with your Ideogram account."
  tags: ["ideogram", "image-generation", "ai-art", "text-to-image"]
  category: "ai"
  author: "ideogram"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-16 (social content sweep). AS mcp.ideogram.ai, DCR at /register.
# Scopes omitted: the client requests the AS's advertised default, which
# keeps offline_access intact for token refresh where the vendor offers it.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.ideogram.ai/mcp"

env: []
---

# Ideogram MCP Server

Ideogram's official hosted MCP server. Generate images with strong text rendering from prompts.

## How authentication works

1. Click **Connect account** on the Ideogram card.
2. A Ideogram sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Publishing tools post to connected social accounts; the platform's publish-class approval rules apply to those agent actions.
- Tools are served by the vendor and discovered at session start.
