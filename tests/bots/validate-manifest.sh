#!/usr/bin/env bash
# Bot Manifest (BOT.md) Validation
# Validates YAML frontmatter in all BOT.md files.
#
# Checks:
# 1. File exists and has YAML frontmatter
# 2. Required fields: apiVersion, kind, metadata.name, metadata.version,
#    metadata.description, metadata.category
# 3. metadata.name matches directory name
# 4. kind is "Bot"
# 5. model.provider is valid
# 6. cost.estimatedCostTier is valid
# 7. Skills refs match pattern skills/{name}@{version}
# 8. Tool pack refs match pattern packs/{name}@{version?}
# 9. MCP server refs match pattern tools/{name}
#
# Usage: ./validate-manifest.sh [bot-name]

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BOTS_DIR="$REPO_ROOT/bots"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

validate_manifest() {
  local bot_name="$1"
  local bot_md="$BOTS_DIR/$bot_name/BOT.md"
  local errors=0
  local warnings=0

  if [ ! -f "$bot_md" ]; then
    echo -e "${RED}FAIL${NC} [$bot_name] BOT.md not found"
    FAIL=$((FAIL + 1))
    return
  fi

  # Check YAML frontmatter exists (between --- markers)
  if ! head -1 "$bot_md" | grep -q "^---"; then
    echo -e "${RED}FAIL${NC} [$bot_name] BOT.md missing YAML frontmatter (no opening ---)"
    FAIL=$((FAIL + 1))
    return
  fi

  # Extract frontmatter
  local frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$bot_md" | tail -n +2 | head -n -1)

  if [ -z "$frontmatter" ]; then
    echo -e "${RED}FAIL${NC} [$bot_name] BOT.md has empty frontmatter"
    FAIL=$((FAIL + 1))
    return
  fi

  # Required fields
  for field in "apiVersion:" "kind:" "name:" "version:" "description:" "category:"; do
    if ! echo "$frontmatter" | grep -q "$field"; then
      echo -e "  ${RED}FAIL${NC} Missing required field: $field"
      errors=$((errors + 1))
    fi
  done

  # kind must be Bot
  local kind
  kind=$(echo "$frontmatter" | grep -m1 "^kind:" | awk '{print $2}')
  if [ "$kind" != "Bot" ]; then
    echo -e "  ${RED}FAIL${NC} kind is '$kind', expected 'Bot'"
    errors=$((errors + 1))
  fi

  # metadata.name must match directory
  local meta_name
  meta_name=$(echo "$frontmatter" | grep -A1 "^metadata:" | grep "name:" | head -1 | sed 's/.*name: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/' | tr -d ' ')
  if [ -n "$meta_name" ] && [ "$meta_name" != "$bot_name" ]; then
    echo -e "  ${RED}FAIL${NC} metadata.name '$meta_name' doesn't match directory '$bot_name'"
    errors=$((errors + 1))
  fi

  # model.provider validation
  local provider
  provider=$(echo "$frontmatter" | grep "provider:" | head -1 | awk '{print $2}' | tr -d '"')
  if [ -n "$provider" ]; then
    case "$provider" in
      anthropic|openai|groq|mistral|ollama) ;;
      *) echo -e "  ${YELLOW}WARN${NC} Unknown model.provider: $provider"
         warnings=$((warnings + 1)) ;;
    esac
  fi

  # cost.estimatedCostTier validation
  local cost_tier
  cost_tier=$(echo "$frontmatter" | grep "estimatedCostTier:" | head -1 | awk '{print $2}' | tr -d '"')
  if [ -n "$cost_tier" ]; then
    case "$cost_tier" in
      low|medium|high) ;;
      *) echo -e "  ${YELLOW}WARN${NC} Unknown estimatedCostTier: $cost_tier"
         warnings=$((warnings + 1)) ;;
    esac
  fi

  # Skill refs format
  while IFS= read -r ref; do
    ref=$(echo "$ref" | tr -d '"' | tr -d ' ')
    if [ -n "$ref" ] && [[ ! "$ref" =~ ^skills/[a-z0-9-]+@[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo -e "  ${YELLOW}WARN${NC} Skill ref '$ref' doesn't match pattern skills/{name}@{version}"
      warnings=$((warnings + 1))
    fi
  done < <(echo "$frontmatter" | grep "ref:" | grep "skills/" | sed 's/.*ref: *//')

  # Tool pack refs format
  while IFS= read -r ref; do
    ref=$(echo "$ref" | tr -d '"' | tr -d ' ')
    if [ -n "$ref" ] && [[ ! "$ref" =~ ^packs/[a-z0-9-]+(@[0-9]+\.[0-9]+\.[0-9]+)?$ ]]; then
      echo -e "  ${YELLOW}WARN${NC} Tool pack ref '$ref' doesn't match pattern packs/{name}@{version}"
      warnings=$((warnings + 1))
    fi
  done < <(echo "$frontmatter" | grep "ref:" | grep "packs/" | sed 's/.*ref: *//')

  # MCP server refs format
  while IFS= read -r ref; do
    ref=$(echo "$ref" | tr -d '"' | tr -d ' ')
    if [ -n "$ref" ] && [[ ! "$ref" =~ ^tools/[a-z0-9-]+$ ]]; then
      echo -e "  ${YELLOW}WARN${NC} MCP server ref '$ref' doesn't match pattern tools/{name}"
      warnings=$((warnings + 1))
    fi
  done < <(echo "$frontmatter" | grep "ref:" | grep "tools/" | sed 's/.*ref: *//')

  # entityTypesWrite should follow _findings convention
  while IFS= read -r etype; do
    etype=$(echo "$etype" | tr -d '"' | tr -d ' ' | tr -d '-')
    if [ -n "$etype" ] && [[ ! "$etype" =~ _findings$ ]] && [[ ! "$etype" =~ _alerts$ ]] && [[ ! "$etype" =~ _notes$ ]]; then
      echo -e "  ${YELLOW}WARN${NC} entityTypesWrite '$etype' doesn't follow {prefix}_findings convention"
      warnings=$((warnings + 1))
    fi
  done < <(echo "$frontmatter" | sed -n '/entityTypesWrite/,/]/p' | grep -E "^\s*-" | sed 's/.*- *//')

  # Report
  if [ $errors -gt 0 ]; then
    echo -e "${RED}FAIL${NC} [$bot_name] $errors error(s), $warnings warning(s)"
    FAIL=$((FAIL + 1))
  elif [ $warnings -gt 0 ]; then
    echo -e "${YELLOW}WARN${NC} [$bot_name] $warnings warning(s)"
    WARN=$((WARN + 1))
  else
    echo -e "${GREEN}PASS${NC} [$bot_name]"
    PASS=$((PASS + 1))
  fi
}

# Main
if [ $# -eq 1 ]; then
  validate_manifest "$1"
else
  for bot_dir in "$BOTS_DIR"/*/; do
    bot_name=$(basename "$bot_dir")
    validate_manifest "$bot_name"
  done
fi

echo ""
echo "Results: $PASS passed, $WARN warnings, $FAIL failures"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
