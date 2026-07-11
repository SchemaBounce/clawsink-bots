---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: apollo
  displayName: "Apollo.io"
  version: "1.0.0"
  description: "Apollo.io's official hosted MCP server for prospecting, enrichment, and CRM. Connect with your Apollo account."
  tags: ["sales", "prospecting", "enrichment", "contacts", "outbound"]
  category: "crm"
  author: "apollo"
  license: "Proprietary"

# MCP-spec OAuth 2.1 (RFC 9728 challenge + RFC 8414 discovery + RFC 7591 DCR),
# the same generic flow as freee and Notion. The env spec is empty on purpose.
#
# SCOPES ARE DELIBERATELY CURATED. Apollo advertises 61 granular scopes as its
# default request; granting them all would let an agent send email as the user
# (emailer_messages_send_now, campaign approve), spend money
# (email_account_purchase_create, domain_purchase_create), and bulk-mutate the
# CRM. This pin covers prospecting search, enrichment, contact CRUD, pipeline
# visibility, and follow-up tasks; nothing that sends or purchases. Apollo
# advertises no offline_access scope, so pinning cannot break token refresh.
auth:
  type: oauth2_mcp
  scopes:
    [
      "read_user_profile",
      "mixed_people_api_search",
      "mixed_companies_search",
      "people_match",
      "organizations_enrich",
      "contacts_search",
      "contact_read",
      "contact_write",
      "contact_update",
      "opportunities_list",
      "opportunity_read",
      "tasks_create",
      "tasks_list",
      "users_list",
      "tags_list",
    ]

transport:
  # Official hosted remote MCP endpoint. Nothing runs in our gateway;
  # sessions connect by URL with the platform-managed bearer token.
  type: "streamable-http"
  url: "https://mcp.apollo.io/mcp"

env: []
---

# Apollo.io MCP Server

Apollo.io's official hosted MCP server for prospecting, enrichment, and CRM. Connect with your Apollo account.

## How authentication works

1. Click **Connect account** on the Apollo.io card.
2. An Apollo sign-in window opens. Approve access for the workspace.
3. The platform stores the OAuth grant and keeps the access token fresh. Agents
   never see the token; it is injected at session start.

No API key exists for this server. If the connection shows **Reconnect**, the
grant expired or was revoked on the vendor's side; run the connect flow again.

## What agents can do with this grant

- Search people and companies, match and enrich records
- Read, create, and update contacts
- List opportunities and read deal details
- Create and list follow-up tasks
- Read workspace users and tags for building queries

## What this grant deliberately excludes

- Sending or approving email campaigns (every `emailer_*` scope)
- Purchasing email accounts or domains
- Bulk account/contact creation and custom-object writes
- Website visitor tracker installation

If a workflow needs one of those, connect Apollo yourself and review the scope
list before approving; the pinned set is the safe default for agent use.
