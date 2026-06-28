---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mock-stdio-noauth
  displayName: "Mock (stdio, no auth)"
  version: "1.0.0"
  description: "Local test MCP: stdio transport, no credentials (public). Validates the no-auth board/validate/use path."
  tags: ["mock", "test", "stdio", "public"]
  category: "testing"
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "sb-mock-mcp"
  args: ["-name=mock-stdio-noauth"]
# No env, no auth block: public server.
validation:
  tool:
    name: mock_ping
    args: {}
  timeout_ms: 5000
tools:
  - name: mock_ping
    description: "Returns server identity."
    category: "read"
  - name: mock_echo
    description: "Echoes the message argument."
    category: "read"
  - name: mock_any
    description: "Accepts an arbitrary JSON value (any-typed arg, schema-repaired)."
    category: "read"
---

`sb-mock-mcp` test fixture (stdio, public). See `tools/MOCK_FIXTURES.md`.

