---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: box
  displayName: "Box"
  version: "1.0.0"
  description: "Box's official hosted MCP server. Search, read, and act on files and folders in your Box account."
  tags: ["box", "files", "storage", "documents", "content"]
  category: "files-docs"
  author: "box"
  license: "Proprietary"

# MCP-spec OAuth 2.1 challenge + RFC 8414 discovery, live-probed 2026-07-21:
# AS https://api.box.com/ serves metadata (authorization_endpoint
# account.box.com/api/oauth2/authorize, token_endpoint
# api.box.com/oauth2/token) but offers NO RFC 7591 DCR, so this entry uses
# the pinned-client path (P2-2): client resolved from Box-issued Integration
# Credentials (BOX_MCP_OAUTH_CLIENT_ID / BOX_MCP_OAUTH_CLIENT_SECRET).
# PRECONDITION: an org admin generates these from the Box Admin Console
# (Integrations > Custom Box MCP Server > Configure > Additional
# Configuration > Add Integration Credentials), which auto-generates the
# client id/secret. Box gates access by application scopes (root_readwrite,
# ai.readwrite, docgen.readwrite per developer.box.com/guides/box-mcp/setup;
# Enterprise Advanced plan required). Enter our redirect
# URI there:
#   <api-base>/api/v1/oauth/mcp/callback
# for every environment that serves this tile. See
# clawsink-bots/docs/PINNED_CLIENT_REGISTRATIONS.md for the full runbook. No
# scopes are pinned: Box's AS advertises none via OAuth scope strings;
# access is governed by the application scopes granted on the Box app instead.
auth:
  type: oauth2_mcp
  client_id_env: BOX_MCP_OAUTH_CLIENT_ID
  client_secret_env: BOX_MCP_OAUTH_CLIENT_SECRET

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.box.com/mcp"

env: []
---

# Box MCP Server

Box's official hosted MCP server. Search, read, and act on files and folders in a connected Box account.

## How authentication works

1. Click **Connect account** on the Box card.
2. A Box sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents never see the token; it is injected at session start.

If the connection shows **Reconnect**, the grant expired or was revoked on Box's side; run the connect flow again.

## Notes

- Access requires the Box MCP server integration enabled by a Box admin with the ai.readwrite application scope (Enterprise Advanced plan); the connecting user cannot grant this.
- Tools are served by Box and discovered at session start.
