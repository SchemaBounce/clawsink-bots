---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: fireflies
  displayName: "Fireflies"
  version: "1.0.0"
  description: "Fireflies' official hosted MCP server. Search meeting transcripts, summaries, and action items with your Fireflies account."
  tags: ["fireflies", "meetings", "transcription", "notes", "productivity"]
  category: "productivity"
  author: "fireflies"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR). Fireflies was on
# the no-DCR exclusion list; re-probed 2026-07-16 and the vendor now exposes
# DCR (AS api.fireflies.ai, /register). Scopes omitted: the AS advertises
# profile + email; the client requests the advertised default.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://api.fireflies.ai/mcp"

env: []
---

# Fireflies MCP Server

Fireflies' official hosted MCP server. Agents can search meeting transcripts, pull summaries, and extract action items from recorded meetings.

## How authentication works

1. Click **Connect account** on the Fireflies card.
2. A Fireflies sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by the vendor and discovered at session start.
