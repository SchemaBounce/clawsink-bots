#!/usr/bin/env bash
# Layer 3: Skill Format Validation
# Validates all skills in the repo without running any agents.
# Checks:
# 1. SKILL.md exists and has valid YAML frontmatter
# 2. prompt.md exists and is under 200 tokens (~800 chars)
# 3. Required YAML fields present (apiVersion, kind, metadata.name, metadata.description)
# 4. metadata.name matches directory name
# 5. tools.required contains only tools the runtime serves (tests/skills/known-tools.txt)
# 6. kind is "Skill"
#
# Usage: ./validate-format.sh [skill-name]
#   No args = validate all skills
#   skill-name = validate specific skill

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

# Known valid tool names: GENERATED snapshot of the OpenCLAW runtime registry
# (ADLTools() in core-api/openclaw-runtime/internal/executor). Never hand-edit
# the list; refresh it with tests/skills/sync-known-tools.sh --write, and
# tests/validate-all.sh fails when it is stale against a core-api checkout.
KNOWN_TOOLS_FILE="$SCRIPT_DIR/known-tools.txt"
if [ ! -f "$KNOWN_TOOLS_FILE" ]; then
  echo "FAIL: $KNOWN_TOOLS_FILE missing; run tests/skills/sync-known-tools.sh --write" >&2
  exit 1
fi
KNOWN_TOOLS="$(grep -E '^adl_' "$KNOWN_TOOLS_FILE" | tr '\n' ' ')"

# Approximate token count (~4 chars per token for English)
estimate_tokens() {
  local file="$1"
  local chars
  chars=$(wc -c < "$file")
  echo $(( chars / 4 ))
}

validate_skill() {
  local skill_dir="$1"
  local skill_name
  skill_name=$(basename "$skill_dir")
  local errors=0

  echo "  $skill_name:"

  # Check SKILL.md exists
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo -e "    ${RED}FAIL${NC} SKILL.md missing"
    ((FAIL++))
    return
  fi

  # Check prompt.md exists
  if [ ! -f "$skill_dir/prompt.md" ]; then
    echo -e "    ${RED}FAIL${NC} prompt.md missing"
    ((FAIL++))
    return
  fi

  # Extract YAML frontmatter from SKILL.md
  local frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" | sed '1d;$d')

  if [ -z "$frontmatter" ]; then
    echo -e "    ${RED}FAIL${NC} No YAML frontmatter in SKILL.md"
    ((FAIL++))
    return
  fi

  # Check kind: Skill
  if ! echo "$frontmatter" | grep -q "^kind: Skill"; then
    echo -e "    ${RED}FAIL${NC} kind must be 'Skill'"
    ((errors++))
  fi

  # Check apiVersion
  if ! echo "$frontmatter" | grep -q "^apiVersion:"; then
    echo -e "    ${RED}FAIL${NC} Missing apiVersion"
    ((errors++))
  fi

  # Check metadata.name exists
  local yaml_name
  yaml_name=$(echo "$frontmatter" | grep "^  name:" | head -1 | sed 's/.*name: *//' | tr -d '"')
  if [ -z "$yaml_name" ]; then
    echo -e "    ${RED}FAIL${NC} Missing metadata.name"
    ((errors++))
  elif [ "$yaml_name" != "$skill_name" ]; then
    echo -e "    ${RED}FAIL${NC} metadata.name '$yaml_name' != directory name '$skill_name'"
    ((errors++))
  fi

  # Check metadata.description
  if ! echo "$frontmatter" | grep -q "description:"; then
    echo -e "    ${RED}FAIL${NC} Missing metadata.description"
    ((errors++))
  fi

  # Check metadata.version
  if ! echo "$frontmatter" | grep -q "version:"; then
    echo -e "    ${YELLOW}WARN${NC} Missing metadata.version"
    ((WARN++))
  fi

  # Validate tools.required against known tools
  local tools_line
  tools_line=$(echo "$frontmatter" | grep "required:" | head -1)
  if [ -n "$tools_line" ]; then
    # Extract tool names from the YAML array
    local tools
    tools=$(echo "$tools_line" | grep -oE '"[a-z_]+"' | tr -d '"')
    for tool in $tools; do
      if ! echo "$KNOWN_TOOLS" | grep -qw "$tool"; then
        echo -e "    ${RED}FAIL${NC} Unknown tool in tools.required: $tool"
        ((errors++))
      fi
    done
  fi

  # Check prompt.md token count
  local tokens
  tokens=$(estimate_tokens "$skill_dir/prompt.md")
  if [ "$tokens" -gt 200 ]; then
    echo -e "    ${YELLOW}WARN${NC} prompt.md ~${tokens} tokens (limit: 200)"
    ((WARN++))
  fi

  # Check prompt.md isn't empty
  local lines
  lines=$(wc -l < "$skill_dir/prompt.md")
  if [ "$lines" -lt 3 ]; then
    echo -e "    ${RED}FAIL${NC} prompt.md too short ($lines lines)"
    ((errors++))
  fi

  if [ "$errors" -eq 0 ]; then
    echo -e "    ${GREEN}PASS${NC} valid (${tokens} tokens)"
    ((PASS++))
  else
    ((FAIL++))
  fi
}

echo "============================================"
echo "  Layer 3: Skill Format Validation"
echo "============================================"
echo ""

FILTER="${1:-all}"

for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")

  if [ "$FILTER" != "all" ] && [ "$FILTER" != "$skill_name" ]; then
    continue
  fi

  validate_skill "$skill_dir"
done

echo ""
echo "============================================"
echo -e "  Results: ${GREEN}${PASS} PASS${NC}  ${YELLOW}${WARN} WARN${NC}  ${RED}${FAIL} FAIL${NC}"
echo "============================================"

exit $FAIL
