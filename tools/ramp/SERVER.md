---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: ramp
  displayName: "Ramp"
  version: "1.0.0"
  description: "Ramp's official hosted MCP server. Read corporate card transactions, bills, reimbursements, and spend data with your Ramp account."
  tags: ["ramp", "finance", "spend", "corporate-cards", "expenses"]
  category: "finance"
  author: "ramp"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 + RFC 8414 + RFC 7591 DCR), live-probed
# 2026-07-16: AS mcp.ramp.com, DCR at /register.
#
# SCOPES ARE DELIBERATELY PINNED READ-ONLY (apollo-precedent curation). The AS
# advertises 38 scopes including funds:write, bank_accounts:write,
# banking_drawdown_requests:write, transactions:write, x402:write and
# limits:write, which move real money or change card controls. This is a live
# corporate finance account; the curated grant is the read set below.
# offline_access is not in the advertised list, so pinning cannot break token
# refresh. A workspace that needs a write scope can connect a BYO custom
# remote to the same URL with its own consent.
auth:
  type: oauth2_mcp
  scopes:
    [
      "transactions:read",
      "cards:read",
      "bills:read",
      "reimbursements:read",
      "users:read",
      "departments:read",
      "vendors:read",
      "limits:read",
      "spend_requests:read",
      "accounting:read",
    ]

transport:
  type: "streamable-http"
  url: "https://mcp.ramp.com/mcp"

env: []
---

# Ramp MCP Server

Ramp's official hosted MCP server. Agents can read card transactions, bills, reimbursements, spend requests, and accounting data for reporting and reconciliation work.

## How authentication works

1. Click **Connect account** on the Ramp card.
2. A Ramp sign-in window opens. Approve access.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on the
vendor's side; run the connect flow again.

## Notes

- Requested scopes are pinned to a read-only set: transactions, cards, bills, reimbursements, users, departments, vendors, limits, spend requests, and accounting.
- Write scopes that move money or change card controls (funds:write, bank_accounts:write, transactions:write, limits:write, x402:write) are deliberately excluded from the curated grant.
- Tools are served by the vendor and discovered at session start.
