---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mock-flaky
  displayName: "Mock (failure injection)"
  version: "1.0.0"
  description: "Local test MCP for failure paths: exposes mock_error (always errors) and mock_slow (latency/timeout). Use -behavior=crash via a variant to test failed-start traces."
  tags: ["mock", "test", "failure", "error"]
  category: "testing"
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "sb-mock-mcp"
  args: ["-name=mock-flaky"]
validation:
  tool:
    name: mock_ping
    args: {}
  timeout_ms: 5000
tools:
  - name: mock_ping
    description: "Returns server identity."
    category: "read"
  - name: mock_error
    description: "Always returns an MCP error result (exercises the error envelope path)."
    category: "read"
  - name: mock_slow
    description: "Sleeps then returns (latency/timeout testing)."
    category: "read"
---

`sb-mock-mcp` test fixture (failure injection: error + slow). See `tools/MOCK_FIXTURES.md`.

