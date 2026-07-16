---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: speakai
  displayName: "Speak AI"
  version: "1.0.0"
  description: "Speak AI's official hosted MCP server. Transcribe and analyze audio, video, and text with Speak AI with your Speak AI account."
  tags: ["speak-ai", "transcription", "analysis", "nlp"]
  category: "productivity"
  author: "speakai"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-16 (social content sweep). AS api.speakai.co, DCR at /register; single mcp scope.
# Scopes omitted: the client requests the AS's advertised default, which
# keeps offline_access intact for token refresh where the vendor offers it.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://api.speakai.co/v1/mcp"

env: []
---

# Speak AI MCP Server

Speak AI's official hosted MCP server. Transcribe and analyze audio, video, and text with Speak AI.

## How authentication works

1. Click **Connect account** on the Speak AI card.
2. A Speak AI sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Publishing tools post to connected social accounts; the platform's publish-class approval rules apply to those agent actions.
- Tools are served by the vendor and discovered at session start.
