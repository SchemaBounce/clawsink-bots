# Paperclip MCP Server

Connects SchemaBounce agents to a Paperclip company through Paperclip's official MCP server.

## Setup

Create an agent API key in Paperclip, then add a Paperclip connection in the SchemaBounce workspace with:

- `PAPERCLIP_API_URL`: the reachable base URL of the Paperclip instance
- `PAPERCLIP_API_KEY`: the agent API key
- `PAPERCLIP_COMPANY_ID`: the company the worker belongs to
- `PAPERCLIP_AGENT_ID`: the Paperclip agent represented by the worker

The hosted worker supplies `PAPERCLIP_RUN_ID` for each dispatched heartbeat. Do not store a fixed run ID in connection settings.

The package is pinned to `@paperclipai/mcp-server@2026.831.1`.
