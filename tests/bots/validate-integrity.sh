#!/usr/bin/env bash
# Bot Cross-Reference Integrity Validation
# Validates that all references between bots, skills, teams, and tools resolve.
#
# Checks:
# 1. Skill refs in BOT.md point to existing skills/ directories
# 2. MCP server refs point to existing tools/ directories
# 3. messaging.sendsTo agent names exist as bot directories
# 4. messaging.listensTo agent names exist as bot directories
# 5. Sub-agents in agents/ have matching files
#
# Usage: ./validate-integrity.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BOTS_DIR="$REPO_ROOT/bots"
SKILLS_DIR="$REPO_ROOT/skills"
TOOLS_DIR="$REPO_ROOT/tools"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

for bot_dir in "$BOTS_DIR"/*/; do
  bot_name=$(basename "$bot_dir")
  bot_md="$bot_dir/BOT.md"
  errors=0
  warnings=0

  if [ ! -f "$bot_md" ]; then
    continue
  fi

  frontmatter=$(sed -n '/^---$/,/^---$/p' "$bot_md" | tail -n +2 | head -n -1)

  # Check skill refs exist
  while IFS= read -r ref; do
    ref=$(echo "$ref" | tr -d '"' | tr -d ' ')
    if [ -z "$ref" ]; then continue; fi
    skill_name=$(echo "$ref" | sed 's|skills/||' | sed 's|@.*||')
    if [ ! -d "$SKILLS_DIR/$skill_name" ]; then
      echo -e "  ${YELLOW}WARN${NC} [$bot_name] Skill ref '$skill_name' not found in skills/"
      warnings=$((warnings + 1))
    fi
  done < <(echo "$frontmatter" | grep "ref:" | grep "skills/" | sed 's/.*ref: *//')

  # Check MCP server refs exist
  while IFS= read -r ref; do
    ref=$(echo "$ref" | tr -d '"' | tr -d ' ')
    if [ -z "$ref" ]; then continue; fi
    tool_name=$(echo "$ref" | sed 's|tools/||')
    if [ ! -d "$TOOLS_DIR/$tool_name" ]; then
      echo -e "  ${YELLOW}WARN${NC} [$bot_name] MCP server ref '$tool_name' not found in tools/"
      warnings=$((warnings + 1))
    fi
  done < <(echo "$frontmatter" | grep "ref:" | grep "tools/" | sed 's/.*ref: *//')

  # Check messaging.sendsTo/listensTo agent refs exist
  for agent_ref in $(echo "$frontmatter" | grep -E "from:|to:" | grep -oE '\[.*\]' | tr -d '[]"' | tr ',' '\n' | tr -d ' '); do
    if [ -z "$agent_ref" ]; then continue; fi
    if [ ! -d "$BOTS_DIR/$agent_ref" ]; then
      echo -e "  ${YELLOW}WARN${NC} [$bot_name] Messaging ref '$agent_ref' not found in bots/"
      warnings=$((warnings + 1))
    fi
  done

  # Check sub-agents directory
  if [ -d "$bot_dir/agents" ]; then
    agent_files=$(find "$bot_dir/agents" -name "*.md" 2>/dev/null | wc -l)
    if [ "$agent_files" -eq 0 ]; then
      echo -e "  ${YELLOW}WARN${NC} [$bot_name] agents/ directory exists but contains no .md files"
      warnings=$((warnings + 1))
    fi
  fi

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
done

echo ""
echo "Results: $PASS passed, $WARN warnings, $FAIL failures"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
