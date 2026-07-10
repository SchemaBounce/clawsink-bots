---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: stripe-remote
  displayName: "Stripe"
  version: "1.0.0"
  description: "Stripe's official hosted MCP server. Connect with your Stripe account to let agents work with customers, invoices, and payments."
  tags: ["payments", "billing", "subscriptions", "finance"]
  category: "finance"
  author: "stripe"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and notion-remote. There is NO pasted
# credential: the platform runs the consent flow against the vendor's own
# authorization server and keeps the access token fresh. The env spec is empty
# on purpose; a declared var would render a credential form no one can fill.
auth:
  type: oauth2_mcp

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.stripe.com"

env: []
---

# Stripe MCP Server

Stripe's official hosted MCP server. Connect with your Stripe account to let agents work with customers, invoices, and payments.

## How authentication works

1. Click **Connect account** on the Stripe card.
2. A Stripe sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## Notes

- No scopes pin: the authorization server advertises none, so the scope parameter is omitted.
- Tools are served by the vendor and discovered at session start (customers, invoices, subscriptions, and payments).
- This grants an agent access to a live Stripe account. Stripe's authorization server lives on a separate host (access.stripe.com); the platform follows the issuer automatically. Effectful calls still route through the Inbox Actions queue. Separate from the API-token tools/stripe entry.
