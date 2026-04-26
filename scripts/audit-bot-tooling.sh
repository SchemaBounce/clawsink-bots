#!/usr/bin/env bash
# Bot MCP Tooling Audit
# Walks bots/*/BOT.md and prints a markdown table scoring each bot's
# real-world tooling depth. Used by docs/AGENT_MCP_TOOLING_HANDOFF.md to
# track progress on closing the "surface-level agent" gap.
#
# Usage:
#   ./scripts/audit-bot-tooling.sh                # markdown table to stdout
#   ./scripts/audit-bot-tooling.sh --counts-only  # just the depth counts
#
# Depth scoring:
#   none       -- mcpServers: [] AND egress.mode: "none" (no path to anything external)
#   shallow    -- declares servers OR allows egress, but the servers are not in the
#                 core-api embeddedEnvSpecs registry, so activation will silently no-op
#   connected  -- declares >=1 server that exists in the runtime registry

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BOTS_DIR="$REPO_ROOT/bots"
TOOLS_DIR="$REPO_ROOT/tools"

# Runtime-known servers — must mirror core-api/.../adl/mcp_connection_service.go
# embeddedEnvSpecs map. If you add a SERVER.md here without a matching entry
# there, activation silently no-ops (auto-grant succeeds, tool never wires).
# Keep this list in sync with that file (line 25-71 as of 2026-04-25).
RUNTIME_KNOWN="github slack stripe jira linear notion firecrawl agentmail hyperbrowser exa elevenlabs composio agentphone claude-code google-search-console google-analytics-4 google-pagespeed-insights"

# A server has a SERVER.md (manifest known)
manifest_known() {
  [ -d "$TOOLS_DIR/$1" ]
}

# A server is wired in the core-api runtime registry
runtime_known() {
  local name="$1"
  for known in $RUNTIME_KNOWN; do
    if [ "$known" = "$name" ]; then return 0; fi
  done
  return 1
}

# Parse a single scalar from BOT.md frontmatter (handles only flat scalars).
# Usage: bot_field <bot_md_path> <key>
bot_field() {
  local file="$1"
  local key="$2"
  awk -v k="$key" '
    BEGIN { infm = 0; depth = 0 }
    /^---$/ { infm = !infm; next }
    !infm { next }
    {
      # detect indent depth (2-space increments)
      match($0, /^[[:space:]]*/)
      indent = RLENGTH
      if (indent > 0) next  # only top-level scalars
      if ($1 == k":") {
        sub(/^[^:]*:[[:space:]]*/, "")
        gsub(/^["'\''"]|["'\''"]$/, "")
        print
        exit
      }
    }' "$file" 2>/dev/null || true
}

# Count entries in a YAML array field. Counts lines starting with "  -"
# inside a top-level "<key>:" block. Imperfect but good enough for an audit.
yaml_array_count() {
  local file="$1"
  local key="$2"
  awk -v k="$key" '
    BEGIN { infm = 0; inblock = 0; n = 0; printed = 0 }
    /^---$/ {
      infm = !infm
      if (!infm) { if (!printed) { print n; printed = 1 } exit }
      next
    }
    !infm { next }
    {
      if ($0 ~ "^"k":[[:space:]]*\\[\\][[:space:]]*$") { print 0; printed = 1; exit }
      if ($0 ~ "^"k":[[:space:]]*$") { inblock = 1; next }
      if (inblock) {
        if ($0 ~ /^[a-zA-Z]/) { print n; printed = 1; exit }
        if ($0 ~ /^[[:space:]]*-[[:space:]]/) n++
      }
    }
    END { if (!printed) print n }
  ' "$file"
}

# Extract refs from mcpServers list. Looks for "ref:" lines under mcpServers:
mcp_refs() {
  local file="$1"
  awk '
    BEGIN { infm = 0; inblock = 0 }
    /^---$/ { infm = !infm; next }
    !infm { next }
    /^mcpServers:[[:space:]]*\[\][[:space:]]*$/ { exit }
    /^mcpServers:[[:space:]]*$/ { inblock = 1; next }
    inblock && /^[a-zA-Z]/ { exit }
    inblock && /ref:/ {
      sub(/.*ref:[[:space:]]*/, "")
      gsub(/^["'\''"]|["'\''"]$/, "")
      print
    }
  ' "$file"
}

count_none=0
count_shallow=0
count_connected=0
total=0

if [ "${1:-}" = "--counts-only" ]; then
  COUNTS_ONLY=1
else
  COUNTS_ONLY=0
  echo "| Bot | #mcp | egress | web.search | wired/manifest/unknown | Refs | Depth |"
  echo "|-----|-----:|--------|-----------:|----------------------:|------|-------|"
fi

for botdir in "$BOTS_DIR"/*/; do
  bot=$(basename "$botdir")
  bot_md="$botdir/BOT.md"
  [ -f "$bot_md" ] || continue
  total=$((total + 1))

  # NOTE: BOT.md uses nested capabilities — bot_field only reads top-level.
  # We grep for nested fields directly to keep the script honest.
  egress=$(grep -E '^[[:space:]]+mode:' "$bot_md" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '"' || echo "")
  websearch=$(grep -E '^[[:space:]]+search:[[:space:]]+(true|false)' "$bot_md" 2>/dev/null | head -1 | awk '{print $2}' || echo "")
  mcp_count=$(yaml_array_count "$bot_md" "mcpServers")
  refs=$(mcp_refs "$bot_md" | tr '\n' ',' | sed 's/,$//')

  # Score depth — count refs by status
  manifest_only=0
  runtime_wired=0
  unknown=0
  IFS=',' read -ra refarr <<< "$refs"
  for r in "${refarr[@]}"; do
    [ -z "$r" ] && continue
    ref_name="${r#tools/}"
    if runtime_known "$ref_name"; then
      runtime_wired=$((runtime_wired + 1))
    elif manifest_known "$ref_name"; then
      manifest_only=$((manifest_only + 1))
    else
      unknown=$((unknown + 1))
    fi
  done

  if [ "$mcp_count" -eq 0 ] && { [ "$egress" = "none" ] || [ "$egress" = "" ]; }; then
    depth="none"
    count_none=$((count_none + 1))
  elif [ "$runtime_wired" -gt 0 ] && [ "$manifest_only" -eq 0 ] && [ "$unknown" -eq 0 ]; then
    depth="connected"
    count_connected=$((count_connected + 1))
  else
    depth="shallow"
    count_shallow=$((count_shallow + 1))
  fi

  if [ "$COUNTS_ONLY" -eq 0 ]; then
    echo "| $bot | $mcp_count | ${egress:--} | ${websearch:--} | $runtime_wired/$manifest_only/$unknown | ${refs:--} | **$depth** |"
  fi
done

if [ "$COUNTS_ONLY" -eq 0 ]; then
  echo ""
  echo "**Totals:** $total bots — $count_none none · $count_shallow shallow · $count_connected connected"
else
  echo "total=$total none=$count_none shallow=$count_shallow connected=$count_connected"
fi
