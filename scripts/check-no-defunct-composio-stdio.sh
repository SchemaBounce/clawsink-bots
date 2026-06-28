#!/usr/bin/env bash
# Guard: no tools/*/SERVER.md may declare the defunct `npx @composio/mcp` stdio
# recipe as its transport command.
#
# Why: @composio/mcp is the Composio CLI, not an MCP server. Declaring it as a
# stdio transport made the mcp-gateway spawn a child that printed usage and
# exited before the MCP handshake (gateway child_exited / start 500 —
# SchemaBounce #1929, e.g. facebook publishing). Composio-managed servers are
# reached over a remote streamable-http transport whose per-connected-account
# URL is resolved at connect time (ComposioOAuthClient.EnsureMcpInstanceURL) and
# stored on the connection's transport_config. The manifest must declare
# `transport.type: "streamable-http"` and must NOT point the gateway at a local
# CLI.
#
# Usage: ./scripts/check-no-defunct-composio-stdio.sh   (exit 1 on any hit)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOOLS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/tools"

# Match a transport command line that runs @composio/mcp. A bare reference in a
# prose comment explaining why the recipe is gone is allowed; only an actual
# command/args recipe (npx ... @composio/mcp) is rejected.
hits=()
while IFS= read -r f; do
  if grep -qE '^[[:space:]]*(command:[[:space:]]*"?npx"?|args:.*@composio/mcp)' "$f"; then
    hits+=("$f")
  fi
done < <(grep -rl '@composio/mcp' "$TOOLS_DIR" 2>/dev/null || true)

if [ "${#hits[@]}" -gt 0 ]; then
  echo "ERROR: defunct '@composio/mcp' stdio transport recipe found in:" >&2
  for f in "${hits[@]}"; do echo "  - $f" >&2; done
  echo "" >&2
  echo "Composio-managed servers use transport.type: \"streamable-http\" (remote," >&2
  echo "per-account URL injected at connect time). Remove the stdio command/args." >&2
  exit 1
fi

echo "OK: no defunct @composio/mcp stdio recipe in tools/*/SERVER.md"
