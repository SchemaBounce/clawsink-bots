#!/usr/bin/env bash
# Skill reference validation (dec-202).
#
# clawsink-bots authors no skills. SchemaBounce's one skill, `schemabounce`, lives in
# SchemaBounce/schemabounce-agent-kit (skills/schemabounce) and is referenced as
# `skills/schemabounce` with no local directory. Domain know-how comes from public
# registry skills (`registry:<owner>/<repo>/<skill>[@<40-hex commit>]`).
#
# Checks:
# 1. skills/ holds README.md only: no skill directory, SKILL.md or prompt.md can creep back in
# 2. every `ref: "skills/..."` / `ref: "registry:..."` in a manifest is skills/schemabounce
#    (optionally @x.y.z) or a well-formed registry ref; any other skills/<name> fails
# 3. every rule `appliesTo` entry that names a skill is skills/schemabounce
# 4. every bot lists skills/schemabounce as its first skill
#
# Usage: ./validate-format.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT" || exit 1

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

FAIL=0
fail() { echo -e "  ${RED}FAIL${NC} $1"; FAIL=$((FAIL + 1)); }

SB_RE='^skills/schemabounce(@[0-9]+\.[0-9]+\.[0-9]+)?$'
REG_RE='^registry:[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/[a-z0-9][a-z0-9-]*(@[0-9a-f]{40})?$'

echo "  skills/ directory:"
while IFS= read -r entry; do
  [ "$(basename "$entry")" = "README.md" ] && continue
  fail "skills/$(basename "$entry") must not exist: this repository authors no skills (dec-202)"
done < <(find skills -mindepth 1 -maxdepth 1 2>/dev/null)
while IFS= read -r f; do
  fail "$f must not exist (dec-202)"
done < <(find skills -mindepth 2 \( -name SKILL.md -o -name prompt.md \) 2>/dev/null)

echo "  skill refs in manifests:"
checked=0
while IFS= read -r hit; do
  file="${hit%%:*}"
  rest="${hit#*:}"
  ref=$(echo "$rest" | sed -E 's/^[[:space:]]*-?[[:space:]]*ref:[[:space:]]*//; s/[[:space:]]+#.*$//' | tr -d '"'"'" | tr -d ' ')
  checked=$((checked + 1))
  if [[ "$ref" =~ $SB_RE ]] || [[ "$ref" =~ $REG_RE ]]; then
    continue
  fi
  fail "$file: skill ref '$ref' is not skills/schemabounce or registry:<owner>/<repo>/<skill>[@<40-hex>]"
done < <(grep -rInH --include=BOT.md --include=TEMPLATE.md --include=TEAM.md --include=PLUGIN.md --include=PACK.md \
           --include=KIT.md --include=RULE.md --include=SERVER.md --include=MOD.md \
           -E '^[[:space:]]*-?[[:space:]]*ref:[[:space:]]*"?(skills/|registry:)' bots templates plugins packs data-kits rules tools mods 2>/dev/null \
         | sed -E 's/^([^:]+):[0-9]+:/\1:/')
echo "    $checked skill ref(s) checked"

echo "  rule appliesTo skill entries:"
while IFS= read -r hit; do
  file="${hit%%:*}"
  ref=$(echo "${hit#*:}" | sed -E 's/^[[:space:]]*-[[:space:]]*//' | tr -d '"'"'" | tr -d ' ')
  [[ "$ref" =~ $SB_RE ]] || fail "$file: appliesTo '$ref' must be skills/schemabounce"
done < <(grep -rInH --include=RULE.md -E '^[[:space:]]*-[[:space:]]*"?skills/' rules 2>/dev/null | sed -E 's/^([^:]+):[0-9]+:/\1:/')

echo "  every bot lists skills/schemabounce first:"
for bot_md in bots/*/BOT.md; do
  first=$(awk '/^skills:/{f=1;next} f&&/ref:/{print;exit} f&&/^[^ ]/{exit}' "$bot_md" | sed -E 's/.*ref:[[:space:]]*//' | tr -d '"'"'" | tr -d ' ')
  [[ "$first" =~ $SB_RE ]] || fail "$bot_md: first skill is '${first:-none}', expected skills/schemabounce"
done

echo ""
if [ $FAIL -gt 0 ]; then
  echo "Results: $FAIL failure(s)"
  exit 1
fi
echo -e "${GREEN}PASS${NC} skill references (dec-202)"
exit 0
