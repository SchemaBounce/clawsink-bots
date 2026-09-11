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
# 10. data.entityTypesWrite is a subset of data.entityTypesRead (WARN only, with
#     a count). Issue #81: a bot that writes a type it cannot read never sees
#     its own records back (adl_query_records filters on entityTypesRead), so
#     every "check what I wrote last run" step silently returns nothing. Most
#     of the catalog fails this today; making it a failure would block every
#     commit until the sweep lands, and the sweep bumps every affected bot and
#     forces a full catalog re-sync, which is a release decision. The sweep,
#     when it is decided, is this one line (then commit bots/*/BOT.md; the
#     pre-commit hook bumps the versions and repins the teams):
#       python3 -c 'import re,json,glob; [open(f,"w",encoding="utf-8",newline="").write(re.sub(r"(entityTypesRead:\s*)(\[[^\]]*\])", lambda m: m.group(1)+json.dumps(json.loads(m.group(2))+[w for w in json.loads(re.search(r"entityTypesWrite:\s*(\[[^\]]*\])",t).group(1)) if w not in json.loads(m.group(2))]), t, count=1)) for f in sorted(glob.glob("bots/*/BOT.md")) for t in [open(f,encoding="utf-8",newline="").read()] if re.search(r"entityTypesWrite:\s*(\[[^\]]*\])",t)]'
#     After the sweep, promote this check from WARN to FAIL.
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
TOTAL=0
UNREADABLE_WRITES=0

# Print the items of a frontmatter list field, one per line. Accepts an inline
# JSON-style array (["a", "b"], the form every manifest uses today) or a
# bracketed array spread over several lines.
list_field() {
  local key="$1" block line
  block="$(cat)"
  line="$(grep -m1 "^  ${key}:" <<< "$block")"
  # sed never tests the end pattern on a range's first line, so an inline
  # array must be taken from its own line or the range swallows the next key.
  if [[ "$line" == *"]"* ]]; then
    echo "$line"
  else
    sed -n "/^  ${key}:/,/\]/p" <<< "$block"
  fi | tr '\n' ' ' | sed "s/.*${key}: *//" | tr -d '[]",' | tr ' ' '\n' | grep -v '^$'
}

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
  # Note: use a here-string instead of `echo ... | grep -q` to avoid SIGPIPE
  # from grep -q closing the pipe early, which combined with `set -o pipefail`
  # would intermittently invert the `if !` condition and produce false failures.
  for field in "apiVersion:" "kind:" "name:" "version:" "description:" "category:"; do
    if ! grep -q "$field" <<< "$frontmatter"; then
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

  # model.provider validation — must match the platform model catalog.
  local provider
  provider=$(echo "$frontmatter" | grep "provider:" | head -1 | awk '{print $2}' | tr -d '"')
  if [ -n "$provider" ]; then
    case "$provider" in
      anthropic|openai|google|meta|qwen|cerebras) ;;
      *) echo -e "  ${YELLOW}WARN${NC} Unknown model.provider: $provider"
         warnings=$((warnings + 1)) ;;
    esac
  fi

  # model.preferred / model.fallback validation. Recommended form is an
  # auto-updating alias (resolves to a concrete model at run time). Pinned
  # dated IDs (claude-*, gpt-*, gemini-*, llama-*, qwen-*) are still accepted
  # but discouraged. KEEP THIS ALIAS LIST IN SYNC with catalog.json `aliases`.
  local known_aliases="opus_latest sonnet_latest haiku_latest gpt_latest gpt_mini_latest gemini_pro_latest gemini_flash_latest llama_latest llama_fast_latest cerebras_fast_latest qwen_latest"
  local model_field model_val
  for model_field in preferred fallback; do
    model_val=$(echo "$frontmatter" | grep "${model_field}:" | head -1 | awk '{print $2}' | tr -d '"')
    [ -z "$model_val" ] && continue
    if echo " $known_aliases " | grep -q " $model_val "; then
      continue  # known alias — good
    fi
    # Accept a pinned concrete id (has a provider prefix), but warn it's stale-prone.
    case "$model_val" in
      claude-*|gpt-*|o[0-9]*|gemini-*|llama-*|qwen*)
        echo -e "  ${YELLOW}WARN${NC} model.${model_field} '$model_val' is a pinned ID; prefer an auto-updating alias (e.g. sonnet_latest)"
        warnings=$((warnings + 1)) ;;
      *)
        echo -e "  ${RED}FAIL${NC} model.${model_field} '$model_val' is not a known alias or recognized model ID"
        errors=$((errors + 1)) ;;
    esac
  done

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

  # entityTypesWrite must be a subset of entityTypesRead (issue #81), else the
  # bot cannot read back what it writes. WARN until the sweep lands; see header.
  if grep -q "^  entityTypesWrite:" <<< "$frontmatter"; then
    local read_types unreadable
    read_types=" $(list_field entityTypesRead <<< "$frontmatter" | tr '\n' ' ') "
    unreadable=""
    while IFS= read -r wtype; do
      [ -n "$wtype" ] || continue
      case "$read_types" in
        *" $wtype "*) ;;
        *) unreadable="${unreadable:+$unreadable }$wtype" ;;
      esac
    done < <(list_field entityTypesWrite <<< "$frontmatter")
    if [ -n "$unreadable" ]; then
      echo -e "  ${YELLOW}WARN${NC} writes entity types it cannot read back (add to entityTypesRead): $unreadable"
      warnings=$((warnings + 1))
      UNREADABLE_WRITES=$((UNREADABLE_WRITES + 1))
    fi
  fi

  # entityTypesWrite should follow _findings convention
  while IFS= read -r etype; do
    etype=$(echo "$etype" | tr -d '"' | tr -d ' ' | tr -d '-')
    if [ -n "$etype" ] && [[ ! "$etype" =~ _findings$ ]] && [[ ! "$etype" =~ _alerts$ ]] && [[ ! "$etype" =~ _notes$ ]]; then
      echo -e "  ${YELLOW}WARN${NC} entityTypesWrite '$etype' doesn't follow {prefix}_findings convention"
      warnings=$((warnings + 1))
    fi
  done < <(echo "$frontmatter" | sed -n '/entityTypesWrite/,/]/p' | grep -E "^\s*-" | sed 's/.*- *//')

  # Report
  TOTAL=$((TOTAL + 1))
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
echo "Read-back: $UNREADABLE_WRITES of $TOTAL manifests write entity types they cannot read (issue #81; warning until the sweep lands, see the header of this script)"
echo "Results: $PASS passed, $WARN warnings, $FAIL failures"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
