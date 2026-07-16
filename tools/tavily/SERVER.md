---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: tavily
  displayName: "Tavily"
  version: "1.0.0"
  description: "Tavily's official hosted MCP server. Web search, content extraction, and crawling built for AI agents."
  tags: ["tavily", "search", "web", "crawling", "research"]
  category: "browser-scraping"
  author: "tavily"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR). Tavily was on the
# no-DCR exclusion list; re-probed 2026-07-16 and the vendor now exposes DCR
# (AS mcp.tavily.com, /register). Scopes omitted: the AS advertises
# openid + offline_access; the client requests the advertised default.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://mcp.tavily.com/mcp"

env: []
---

# Tavily MCP Server

Tavily's official hosted MCP server. Agents get web search, page content extraction, and site crawling tuned for research workflows.

## How authentication works

1. Click **Connect account** on the Tavily card.
2. A Tavily sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Search volume is metered against your Tavily plan.
- Tools are served by the vendor and discovered at session start.
