---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: semgrep
  displayName: "Semgrep"
  version: "1.0.0"
  description: "Semgrep's official hosted MCP server. Static analysis, security scanning, and AppSec findings with your Semgrep account."
  tags: ["semgrep", "security", "sast", "static-analysis", "appsec"]
  category: "developer-tools"
  author: "semgrep"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR). Semgrep was on
# the no-DCR exclusion list; re-probed 2026-07-16 and the vendor now exposes
# DCR (AS login.semgrep.dev, /oauth2/register). Scopes omitted: the AS
# advertises identity scopes + offline_access; the client requests the
# advertised default.
auth:
  type: oauth2_mcp

transport:
  type: "streamable-http"
  url: "https://mcp.semgrep.ai/mcp"

env: []
---

# Semgrep MCP Server

Semgrep's official hosted MCP server. Agents can run static analysis, review security findings, and work with Semgrep rules and AppSec results.

## How authentication works

1. Click **Connect account** on the Semgrep card.
2. A Semgrep sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Pairs with the Aikido entry as the catalog's security-scanner options.
- Tools are served by the vendor and discovered at session start.
