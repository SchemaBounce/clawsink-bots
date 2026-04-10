#!/usr/bin/env bash
# Tool Pack Manifest Validation
# Validates YAML frontmatter and tool definitions in all PACK.md files.
#
# Checks:
# 1. PACK.md exists and has YAML frontmatter
# 2. Required fields: apiVersion, kind, metadata.name, metadata.version,
#    metadata.description, metadata.category, tools
# 3. metadata.name matches directory name
# 4. kind is "ToolPack"
# 5. metadata.version is SemVer
# 6. metadata.description is under 120 characters
# 7. tools[] entries each have name, description, and category
# 8. Tool names use snake_case and are unique within a pack
# 9. Tool names are globally unique across all packs
#
# Usage: ./validate-manifest.sh [pack-name]

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PACKS_DIR="$REPO_ROOT/packs"
TMP_TOOLS="$(mktemp)"

trap 'rm -f "$TMP_TOOLS"' EXIT

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0
GLOBAL_FAIL=0

strip_quotes() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  echo "$value"
}

validate_pack() {
  local pack_name="$1"
  local pack_md="$PACKS_DIR/$pack_name/PACK.md"
  local errors=0
  local warnings=0

  if [ ! -f "$pack_md" ]; then
    echo -e "${RED}FAIL${NC} [$pack_name] PACK.md not found"
    FAIL=$((FAIL + 1))
    return
  fi

  if ! head -1 "$pack_md" | grep -q "^---"; then
    echo -e "${RED}FAIL${NC} [$pack_name] PACK.md missing YAML frontmatter (no opening ---)"
    FAIL=$((FAIL + 1))
    return
  fi

  local frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$pack_md" | sed '1d;$d')

  if [ -z "$frontmatter" ]; then
    echo -e "${RED}FAIL${NC} [$pack_name] PACK.md has empty frontmatter"
    FAIL=$((FAIL + 1))
    return
  fi

  for field in "apiVersion:" "kind:" "metadata:" "name:" "displayName:" "version:" "description:" "category:" "tools:"; do
    if ! echo "$frontmatter" | grep -q "$field"; then
      echo -e "  ${RED}FAIL${NC} Missing required field: $field"
      errors=$((errors + 1))
    fi
  done

  local kind
  kind=$(echo "$frontmatter" | grep -m1 "^kind:" | awk '{print $2}')
  if [ "$kind" != "ToolPack" ]; then
    echo -e "  ${RED}FAIL${NC} kind is '$kind', expected 'ToolPack'"
    errors=$((errors + 1))
  fi

  local meta_name
  meta_name=$(echo "$frontmatter" | grep -A8 "^metadata:" | grep "^  name:" | head -1 | sed 's/^  name: *//')
  meta_name=$(strip_quotes "$meta_name")
  if [ -n "$meta_name" ] && [ "$meta_name" != "$pack_name" ]; then
    echo -e "  ${RED}FAIL${NC} metadata.name '$meta_name' doesn't match directory '$pack_name'"
    errors=$((errors + 1))
  fi

  local version
  version=$(echo "$frontmatter" | grep -A8 "^metadata:" | grep "^  version:" | head -1 | sed 's/^  version: *//')
  version=$(strip_quotes "$version")
  if [ -n "$version" ] && [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "  ${RED}FAIL${NC} metadata.version '$version' is not valid SemVer"
    errors=$((errors + 1))
  fi

  local description
  description=$(echo "$frontmatter" | grep -A8 "^metadata:" | grep "^  description:" | head -1 | sed 's/^  description: *//')
  description=$(strip_quotes "$description")
  if [ -n "$description" ] && [ "${#description}" -gt 120 ]; then
    echo -e "  ${RED}FAIL${NC} metadata.description exceeds 120 characters (${#description})"
    errors=$((errors + 1))
  fi

  local tool_names
  tool_names=$(echo "$frontmatter" | grep "^  - name:" | sed 's/^  - name: *//')
  local tool_count
  tool_count=$(echo "$tool_names" | sed '/^$/d' | wc -l | tr -d ' ')
  if [ "$tool_count" -eq 0 ]; then
    echo -e "  ${RED}FAIL${NC} tools[] is empty"
    errors=$((errors + 1))
  fi

  local tool_desc_count
  tool_desc_count=$(echo "$frontmatter" | grep -c "^    description:")
  if [ "$tool_desc_count" -ne "$tool_count" ]; then
    echo -e "  ${RED}FAIL${NC} tools[] entries must each include description"
    errors=$((errors + 1))
  fi

  local tool_category_count
  tool_category_count=$(echo "$frontmatter" | grep -c "^    category:")
  if [ "$tool_category_count" -ne "$tool_count" ]; then
    echo -e "  ${RED}FAIL${NC} tools[] entries must each include category"
    errors=$((errors + 1))
  fi

  while IFS= read -r tool_name; do
    tool_name=$(strip_quotes "$tool_name")
    tool_name=$(echo "$tool_name" | tr -d ' ')
    if [ -z "$tool_name" ]; then
      continue
    fi

    if [[ ! "$tool_name" =~ ^[a-z][a-z0-9_]*$ ]]; then
      echo -e "  ${RED}FAIL${NC} Tool name '$tool_name' must be snake_case"
      errors=$((errors + 1))
    fi

    printf '%s\t%s\n' "$tool_name" "$pack_name" >> "$TMP_TOOLS"
  done <<< "$tool_names"

  local duplicate_local
  duplicate_local=$(echo "$tool_names" | sed '/^$/d' | sed 's/^"//; s/"$//' | tr -d ' ' | sort | uniq -d)
  if [ -n "$duplicate_local" ]; then
    while IFS= read -r tool_name; do
      [ -z "$tool_name" ] && continue
      echo -e "  ${RED}FAIL${NC} Duplicate tool name '$tool_name' within pack"
      errors=$((errors + 1))
    done <<< "$duplicate_local"
  fi

  local body_line
  body_line=$(awk 'BEGIN { delimiters=0 } /^---$/ { delimiters++; next } delimiters >= 2 && $0 !~ /^[[:space:]]*$/ { print; exit }' "$pack_md")
  if [ -z "$body_line" ]; then
    echo -e "  ${YELLOW}WARN${NC} PACK.md has no markdown body after frontmatter"
    warnings=$((warnings + 1))
  fi

  if [ $errors -gt 0 ]; then
    echo -e "${RED}FAIL${NC} [$pack_name] $errors error(s), $warnings warning(s)"
    FAIL=$((FAIL + 1))
  elif [ $warnings -gt 0 ]; then
    echo -e "${YELLOW}WARN${NC} [$pack_name] $warnings warning(s)"
    WARN=$((WARN + 1))
  else
    echo -e "${GREEN}PASS${NC} [$pack_name]"
    PASS=$((PASS + 1))
  fi
}

FILTER="${1:-all}"

for pack_dir in "$PACKS_DIR"/*/; do
  [ -d "$pack_dir" ] || continue
  pack_name=$(basename "$pack_dir")

  if [ "$FILTER" != "all" ] && [ "$FILTER" != "$pack_name" ]; then
    continue
  fi

  validate_pack "$pack_name"
done

duplicate_global=$(cut -f1 "$TMP_TOOLS" | sort | uniq -d)
if [ -n "$duplicate_global" ]; then
  GLOBAL_FAIL=1
  while IFS= read -r tool_name; do
    [ -z "$tool_name" ] && continue
    packs=$(awk -F '\t' -v tool="$tool_name" '$1 == tool { print $2 }' "$TMP_TOOLS" | paste -sd ', ' -)
    echo -e "${RED}FAIL${NC} [global] Duplicate tool name '$tool_name' used in packs: $packs"
  done <<< "$duplicate_global"
fi

echo ""
echo "Results: $PASS passed, $WARN warnings, $FAIL failures"

if [ $FAIL -gt 0 ] || [ $GLOBAL_FAIL -gt 0 ]; then
  exit 1
fi
