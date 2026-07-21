---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: gusto
  displayName: "Gusto"
  version: "1.0.0"
  description: "Gusto's official hosted MCP server. Read companies, employees, contractors, payrolls, and time sheets, and run or write payroll actions in your Gusto account."
  tags: ["gusto", "payroll", "hr", "people-ops"]
  category: "hr"
  author: "gusto"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# live-probed 2026-07-21 (popular-tools sweep). AS mcp.api.gusto.com, DCR
# verified. Scopes omitted: the client requests the AS's advertised default
# (read scopes across companies/employees/payrolls plus payrolls:write and
# payrolls:run for write-capable workspaces), which keeps token refresh
# intact.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.api.gusto.com/"

env: []
---

# Gusto MCP Server

Gusto's official hosted MCP server. Read companies, employees, contractors, departments, jobs, compensations, pay schedules, payrolls, and time sheets from your Gusto account. Write-capable workspaces can also run payroll actions.

## How authentication works

1. Click **Connect account** on the Gusto card.
2. A Gusto sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Tools are served by Gusto and discovered at session start.
- Payroll writes (`payrolls:write`, `payrolls:run`) follow the platform's
  approval rules for agent actions. HR and payroll data is sensitive; review
  the scopes granted during connect before approving.
