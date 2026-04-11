#!/usr/bin/env bash
# Tool Pack Reference Validation
# Validates that tool pack references in bot and team manifests resolve.
#
# Checks:
# 1. toolPacks[].ref matches pattern packs/{name}@{version?}
# 2. Referenced pack exists and contains PACK.md
# 3. toolPacks[].reason is present and non-empty
# 4. No duplicate tool pack refs appear within one manifest
#
# Usage: ./validate-references.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PACKS_DIR="$REPO_ROOT/packs"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
CHECKED=0

strip_quotes() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  echo "$value"
}

extract_tool_packs() {
  local manifest="$1"

  awk '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      return value
    }

    function strip_quotes(value) {
      gsub(/^"/, "", value)
      gsub(/"$/, "", value)
      return value
    }

    function flush_item() {
      if (item_active) {
        print strip_quotes(trim(ref)) "\t" strip_quotes(trim(reason))
      }
      item_active = 0
      ref = ""
      reason = ""
    }

    BEGIN {
      in_frontmatter = 0
      in_toolpacks = 0
      item_active = 0
    }

    NR == 1 && $0 == "---" {
      in_frontmatter = 1
      next
    }

    in_frontmatter && $0 == "---" {
      if (in_toolpacks) {
        flush_item()
      }
      exit
    }

    !in_frontmatter {
      next
    }

    {
      if ($0 ~ /^toolPacks:[[:space:]]*$/) {
        in_toolpacks = 1
        next
      }

      if (in_toolpacks && $0 ~ /^[A-Za-z0-9_-]+:[[:space:]]*.*$/) {
        flush_item()
        in_toolpacks = 0
      }

      if (!in_toolpacks) {
        next
      }

      if ($0 ~ /^  - ref:[[:space:]]*/) {
        flush_item()
        item_active = 1
        ref = $0
        sub(/^  - ref:[[:space:]]*/, "", ref)
        next
      }

      if (item_active && $0 ~ /^    reason:[[:space:]]*/) {
        reason = $0
        sub(/^    reason:[[:space:]]*/, "", reason)
      }
    }

    END {
      if (in_toolpacks) {
        flush_item()
      }
    }
  ' "$manifest"
}

validate_manifest() {
  local manifest="$1"
  local manifest_type="$2"
  local manifest_name
  manifest_name=$(basename "$(dirname "$manifest")")
  local error_count=0
  local frontmatter

  frontmatter=$(sed -n '/^---$/,/^---$/p' "$manifest")

  if ! echo "$frontmatter" | grep -q "^toolPacks:"; then
    return
  fi

  CHECKED=$((CHECKED + 1))

  local refs_output
  refs_output=$(extract_tool_packs "$manifest")

  if [ -z "$refs_output" ]; then
    echo -e "${RED}FAIL${NC} [$manifest_type/$manifest_name] toolPacks section exists but no refs were parsed"
    FAIL=$((FAIL + 1))
    return
  fi

  local seen_refs=""

  while IFS=$'\t' read -r ref reason; do
    ref=$(strip_quotes "$ref")
    ref=$(echo "$ref" | tr -d ' ')
    reason=$(strip_quotes "$reason")

    if [ -z "$ref" ]; then
      continue
    fi

    if [[ ! "$ref" =~ ^packs/[a-z0-9-]+(@[0-9]+\.[0-9]+\.[0-9]+)?$ ]]; then
      echo -e "  ${RED}FAIL${NC} Invalid tool pack ref '$ref' (expected packs/{name} or packs/{name}@x.y.z)"
      error_count=$((error_count + 1))
      continue
    fi

    local pack_name
    pack_name="${ref#packs/}"
    pack_name="${pack_name%@*}"

    if [ ! -f "$PACKS_DIR/$pack_name/PACK.md" ]; then
      echo -e "  ${RED}FAIL${NC} Referenced pack '$pack_name' not found in packs/"
      error_count=$((error_count + 1))
    fi

    if [ -z "$reason" ]; then
      echo -e "  ${RED}FAIL${NC} toolPacks ref '$ref' is missing a non-empty reason"
      error_count=$((error_count + 1))
    fi

    if echo "$seen_refs" | grep -qx "$ref"; then
      echo -e "  ${RED}FAIL${NC} Duplicate tool pack ref '$ref' in manifest"
      error_count=$((error_count + 1))
    elif [ -z "$seen_refs" ]; then
      seen_refs="$ref"
    else
      seen_refs="$seen_refs"$'\n'"$ref"
    fi
  done <<< "$refs_output"

  if [ $error_count -gt 0 ]; then
    echo -e "${RED}FAIL${NC} [$manifest_type/$manifest_name] $error_count error(s)"
    FAIL=$((FAIL + 1))
  else
    echo -e "${GREEN}PASS${NC} [$manifest_type/$manifest_name]"
    PASS=$((PASS + 1))
  fi
}

for bot_manifest in "$REPO_ROOT"/bots/*/BOT.md; do
  [ -f "$bot_manifest" ] || continue
  validate_manifest "$bot_manifest" "bot"
done

for team_manifest in "$REPO_ROOT"/teams/*/TEAM.md; do
  [ -f "$team_manifest" ] || continue
  validate_manifest "$team_manifest" "team"
done

echo ""
echo "Results: $PASS passed, $FAIL failures, $CHECKED manifests checked"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
