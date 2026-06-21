---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mock-remote-apikey
  displayName: "Mock (remote, API key)"
  version: "1.0.0"
  description: "Local test MCP: remote streamable-http transport, api_key_header auth. The gateway dials the URL and injects the key header; mock_ping reports receivedHeaders."
  tags: ["mock", "test", "remote", "streamable-http", "api-key"]
  category: "testing"
  author: "schemabounce"
  license: "MIT"
# Remote transport: the gateway connects to the URL (no child process). The URL is
# templated from an env var so local dev can point it at a running
# `sb-mock-mcp -transport=streamable-http` instance.
transport:
  type: "streamable-http"
  url: "${MOCK_REMOTE_URL}/mcp"
env:
  - name: MOCK_API_KEY
    description: "API key sent as the X-Api-Key header. Presence-only check by the mock."
    required: true
    sensitive: true
  - name: MOCK_REMOTE_URL
    description: "Base URL of the running sb-mock-mcp http instance (e.g. http://mock-remote:8080)."
    required: true
    sensitive: false
auth:
  type: api_key_header
  token_env: MOCK_API_KEY
  header_name: X-Api-Key
validation:
  tool:
    name: mock_ping
    args: {}
  timeout_ms: 5000
network:
  scope: restricted
  allowedDomains:
    - "mock-remote:8080"
    - "localhost:18765"
tools:
  - name: mock_ping
    description: "Returns server identity + which auth headers it received."
    category: "read"
  - name: mock_echo
    description: "Echoes the message argument."
    category: "read"
---

`sb-mock-mcp` test fixture (remote streamable-http, api_key_header). See `tools/MOCK_FIXTURES.md`.

