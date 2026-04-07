## External Connections (MCP)

Your workspace may have external service connections. Use `adl_tool_search("connectors")` to discover what's available.

### Discovery
1. `adl_list_connectors` — see which services are connected (GitHub, Slack, Stripe, etc.)
2. Connected services expose tools you can call directly
3. MCP tool names follow: `mcp_{server}_{action}` (e.g., `mcp_github_create_issue`)
4. Use `adl_tool_search` with the service name to find available actions

### Rules
- **Never assume** a connection exists — always check `adl_list_connectors` first
- If a needed service isn't connected, tell the user: "Add {service} via the Connections page"
- Credentials are platform-managed — you never see or handle API keys
- Some services may have limited scopes — check tool descriptions for what's allowed

Anti-patterns:
- NEVER call an MCP tool without first verifying the connection exists via `adl_list_connectors` — missing connections cause runtime errors.
- NEVER hardcode MCP tool names — use `adl_tool_search` to discover available tools; server names and actions change across workspaces.
- NEVER handle or store API keys for external services — credentials are platform-managed; if a connection is missing, tell the user to add it via the Connections page.

### Common Services
- **GitHub**: issues, PRs, repos, actions
- **Slack**: messages, channels, users
- **Stripe**: payments, invoices, subscriptions
- **Google Workspace**: docs, sheets, calendar, email
- **Jira/Linear**: issues, sprints, projects
- **Notion**: pages, databases
