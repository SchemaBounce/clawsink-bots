# Mock MCP catalog fixtures (`mock-*`)

These `tools/mock-*` entries are **test fixtures**, not real integrations. They map
to the `sb-mock-mcp` binary (`schemabounce-mcp/go/cmd/sb-mock-mcp`) — a REAL,
conformant MCP server configured via flags — so the gateway boards/validates/hosts
them through the *actual* hosting path. They exist to test every TYPE of MCP locally:
transport × auth × network-scope × tool-shape × failure mode.

| Fixture | Transport | Auth | Notable | Tests |
|---|---|---|---|---|
| `mock-stdio-bearer` | stdio | http_bearer (`MOCK_TOKEN`) | mock_ping echoes injected cred NAME | board/validate/grant/use + **credential-injection proof** + mutating tools (approval gate) |
| `mock-stdio-noauth` | stdio | none (public) | `mock_any` (any-typed arg, schema-repaired) | no-auth path + the `any`→schema edge against strict clients |
| `mock-remote-apikey` | streamable-http | api_key_header (`X-Api-Key`) | `restricted` network + allowlist; URL from `${MOCK_REMOTE_URL}` | remote dial + header injection + domain allowlist |
| `mock-flaky` | stdio | none | `mock_error`, `mock_slow` | error-envelope + latency/timeout paths |

## How they're configured

The mock is configured by the transport `args` (flags) — `-name`, `-require-env`,
`-behavior`, `-expose-schema-bug`, `-transport`, `-tools`. The connection `env` block
carries the **injected credential** (the gateway puts it in the child env / a header);
`mock_ping` reports which credential NAMES it received (never the values), proving the
gateway injected them while the agent runtime never held them.

## Hosting locally

- **stdio fixtures:** `sb-mock-mcp` must be on the gateway's `ALLOWED_COMMANDS` and
  baked/mounted into the gateway image (see W5 / `dev-restart-all.sh`).
- **remote fixtures:** run `sb-mock-mcp -transport=streamable-http -http-addr=:8080`
  somewhere the gateway can reach, and set `MOCK_REMOTE_URL`.

The in-process Tier-A harness (`mcptest`) drives these against the real gateway
session manager without the full catalog; the catalog path is exercised by the
Tier-B K8s e2e.
