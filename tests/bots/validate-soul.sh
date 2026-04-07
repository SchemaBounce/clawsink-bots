#!/usr/bin/env bash
# Bot SOUL.md Validation
# Validates all SOUL.md files against required section and quality standards.
#
# Checks:
# 1. Required sections: Mission, Expertise, Decision Authority, Constraints,
#    Run Protocol, Communication Style
# 2. Constraints has at least 3 NEVER rules
# 3. Run Protocol has at least 6 numbered steps
# 4. Uses first person (not "You are")
# 5. References ADL tools in Run Protocol
# 6. Under character budget (warn >2000, fail >4000)
#
# Usage: ./validate-soul.sh [bot-name]

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

validate_soul() {
  local bot_name="$1"
  local soul_md="$BOTS_DIR/$bot_name/SOUL.md"
  local errors=0
  local warnings=0

  if [ ! -f "$soul_md" ]; then
    echo -e "${RED}FAIL${NC} [$bot_name] SOUL.md not found"
    FAIL=$((FAIL + 1))
    return
  fi

  # Check file is non-empty
  if [ ! -s "$soul_md" ]; then
    echo -e "${RED}FAIL${NC} [$bot_name] SOUL.md is empty"
    FAIL=$((FAIL + 1))
    return
  fi

  # Required sections (with common aliases)
  if ! grep -q "## Mission" "$soul_md"; then
    echo -e "  ${RED}FAIL${NC} Missing required section: ## Mission"
    errors=$((errors + 1))
  fi
  if ! grep -qE "## Expertise|## Mandates|## Testing Strategy|## Review Checklist|## Monitoring Focus" "$soul_md"; then
    echo -e "  ${RED}FAIL${NC} Missing required section: ## Expertise (or ## Mandates)"
    errors=$((errors + 1))
  fi
  if ! grep -qE "## Decision Authority|## Mandates" "$soul_md"; then
    echo -e "  ${RED}FAIL${NC} Missing required section: ## Decision Authority (or ## Mandates)"
    errors=$((errors + 1))
  fi
  if ! grep -q "## Constraints" "$soul_md"; then
    echo -e "  ${RED}FAIL${NC} Missing required section: ## Constraints"
    errors=$((errors + 1))
  fi
  if ! grep -qE "## Run Protocol|## Mandates" "$soul_md"; then
    echo -e "  ${RED}FAIL${NC} Missing required section: ## Run Protocol (or ## Mandates with numbered steps)"
    errors=$((errors + 1))
  fi
  if ! grep -qE "## Communication Style|## Communication|## Writing Style|## Escalation|## Entity Types" "$soul_md"; then
    echo -e "  ${RED}FAIL${NC} Missing required section: ## Communication Style (or ## Escalation / ## Entity Types)"
    errors=$((errors + 1))
  fi

  # Constraints: at least 3 NEVER rules
  never_count=$(grep -c "NEVER" "$soul_md" 2>/dev/null || true)
  never_count=$((never_count + 0))  # force integer
  if [ "$never_count" -lt 3 ]; then
    echo -e "  ${YELLOW}WARN${NC} Only $never_count NEVER constraints (minimum 3)"
    warnings=$((warnings + 1))
  fi

  # Run Protocol: at least 6 numbered steps
  step_count=$(grep -cE "^[0-9]+\." "$soul_md" 2>/dev/null || true)
  step_count=$((step_count + 0))  # force integer
  if [ "$step_count" -lt 6 ]; then
    echo -e "  ${YELLOW}WARN${NC} Run Protocol has only $step_count numbered steps (minimum 6)"
    warnings=$((warnings + 1))
  fi

  # First person check
  if grep -qi "^You are" "$soul_md"; then
    echo -e "  ${YELLOW}WARN${NC} Uses 'You are' — should use first person ('I am')"
    warnings=$((warnings + 1))
  fi

  # ADL tool references in Run Protocol
  if ! grep -q "adl_" "$soul_md"; then
    echo -e "  ${YELLOW}WARN${NC} No adl_ tool references found"
    warnings=$((warnings + 1))
  fi

  # Character budget
  char_count=$(wc -c < "$soul_md")
  if [ "$char_count" -gt 4000 ]; then
    echo -e "  ${RED}FAIL${NC} SOUL.md is $char_count chars (max 4000)"
    errors=$((errors + 1))
  elif [ "$char_count" -gt 2000 ]; then
    echo -e "  ${YELLOW}WARN${NC} SOUL.md is $char_count chars (recommended under 2000)"
    warnings=$((warnings + 1))
  fi

  # Duplicate section headers
  dupes=$(grep -E "^## " "$soul_md" | sort | uniq -d)
  if [ -n "$dupes" ]; then
    echo -e "  ${RED}FAIL${NC} Duplicate section headers: $dupes"
    errors=$((errors + 1))
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
}

# Main
if [ $# -eq 1 ]; then
  validate_soul "$1"
else
  for bot_dir in "$BOTS_DIR"/*/; do
    bot_name=$(basename "$bot_dir")
    validate_soul "$bot_name"
  done
fi

echo ""
echo "Results: $PASS passed, $WARN warnings, $FAIL failures"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
