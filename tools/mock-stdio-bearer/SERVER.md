---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mock-stdio-bearer
  displayName: "Mock (stdio, bearer)"
  version: "1.0.0"
  description: "Local test MCP: stdio transport, http_bearer auth. sb-mock-mcp reports the injected credential via mock_ping (credential-injection proof)."
  tags: ["mock", "test", "stdio", "bearer"]
  category: "testing"
  author: "schemabounce"
  license: "MIT"
# Curated stdio entry: the gateway runs command/args as-is (command must be on the
# gateway's ALLOWED_COMMANDS allowlist; sb-mock-mcp is baked into the gateway image
# for local testing). The mock is configured via flags; the env block below carries
# the injected credential, which the gateway places in the child env and mock_ping
# confirms it received.
transport:
  type: "stdio"
  command: "sb-mock-mcp"
  args: ["-name=mock-stdio-bearer", "-require-env=MOCK_TOKEN"]
env:
  - name: MOCK_TOKEN
    description: "Any non-empty token. The mock only checks presence; mock_ping echoes the NAME it received, never the value."
    required: true
    sensitive: true
auth:
  type: http_bearer
  token_env: MOCK_TOKEN
# Tool-form validation: the engine starts the server and calls a read-only tool.
validation:
  tool:
    name: mock_ping
    args: {}
    expect:
      contains_text: "mock-stdio-bearer"
  timeout_ms: 5000
tools:
  - name: mock_ping
    description: "Returns server identity + which injected credentials it received."
    category: "read"
  - name: mock_echo
    description: "Echoes the message argument."
    category: "read"
  - name: create_thing
    description: "Creates a thing (mutating)."
    category: "write"
  - name: delete_thing
    description: "Deletes a thing (mutating)."
    category: "write"
---

`sb-mock-mcp` test fixture (stdio, http_bearer). See `tools/MOCK_FIXTURES.md`.

