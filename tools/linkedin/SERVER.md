---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: linkedin
  displayName: "LinkedIn"
  version: "1.0.0"
  description: "LinkedIn API via Composio managed-OAuth. Create posts and article shares, read profile and company info, manage comments, and pull organization page analytics."
  tags: ["linkedin", "social", "b2b", "marketing", "composio"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "LINKEDIN"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent calls execute_composio_tool with LINKEDIN_* action names (e.g. LINKEDIN_CREATE_LINKED_IN_POST, LINKEDIN_GET_MY_INFO, LINKEDIN_GET_COMPANY_INFO)."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@composio/mcp@1.0.9"]
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio-managed OAuth
  # connection. Leaving this blank uses the workspace's Composio integration for
  # this service; provide a value only to override the managed connection. Do not
  # mark this required:true, that makes the setup/reconnect modal demand a key the
  # managed OAuth flow already covers.
  - name: COMPOSIO_API_KEY
    description: "Composio API key from composio.dev/settings. Authenticates the Composio MCP gateway. Your LinkedIn account is then connected inside Composio via OAuth."
    required: false
    sensitive: true

tools:
  - name: get_my_info
    description: "Get the authenticated LinkedIn member's profile information"
    category: profile
  - name: get_person_profile
    description: "Retrieve another LinkedIn member's profile by person ID"
    category: profile
  - name: get_company_info
    description: "List organizations where the authenticated user has a role, used to find company pages they can post to"
    category: profile
  - name: create_post
    description: "Create a post on LinkedIn for the member or a company page they manage"
    category: content
  - name: create_article_share
    description: "Share an article or external URL as a LinkedIn post"
    category: content
  - name: delete_post
    description: "Delete a LinkedIn post by its share ID"
    category: content
  - name: create_comment
    description: "Comment on a LinkedIn post or reply to an existing comment"
    category: engagement
  - name: get_org_page_stats
    description: "Get page statistics for a LinkedIn organization page"
    category: insights
  - name: get_share_stats
    description: "Get share statistics for a LinkedIn organization's posts"
    category: insights
---

# LinkedIn MCP Server

Provides LinkedIn API tools via Composio's managed-OAuth gateway. Covers member and company posting, article shares, comment management, and organization page analytics.

## Auth Model: Composio

This server is backed by the Composio LINKEDIN toolkit (22 tools). Authentication is managed by Composio. The user connects their LinkedIn account in Composio via OAuth once, then bots call `execute_composio_tool` with `LINKEDIN_*` action names. The friendly tools above map to real toolkit actions such as `LINKEDIN_CREATE_LINKED_IN_POST`, `LINKEDIN_GET_MY_INFO`, `LINKEDIN_GET_COMPANY_INFO`, and `LINKEDIN_DELETE_LINKED_IN_POST`.

No manual API key is required. The workspace's Composio-managed OAuth connection covers authentication, so the `COMPOSIO_API_KEY` env field is optional and acts only as an override.

## External Requirements

- A **LinkedIn account** connected in Composio via OAuth.
- **Company page posting** requires an admin role on the page plus the matching LinkedIn OAuth scopes (for example `w_organization_social` for organization posts and `r_organization_social` for organization read). Composio requests these during the OAuth grant. Member posting uses `w_member_social`.
- Marketing API access for ad-targeting actions is a separate LinkedIn approval and is out of scope for this server's declared tools.

## Which Bots Use This

- **social-media-strategist** -- Researches and drafts B2B content for LinkedIn and plans the content calendar. It does not publish directly.

## Setup

1. Sign up at [composio.dev](https://composio.dev) and get your API key.
2. Add `COMPOSIO_API_KEY` in the MCP connection setup if you want to override the managed connection. Otherwise leave it blank.
3. In Composio, connect your LinkedIn account via OAuth under the LinkedIn toolkit.
4. The server starts automatically when a bot that references it runs.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/linkedin"
    reason: "B2B social bots need LinkedIn access for content planning and page analytics"
```
