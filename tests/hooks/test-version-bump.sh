#!/usr/bin/env bash
# Git hook regression test (issue #82).
#
# The pre-commit hook auto-bumps a changed bot's patch version. In a by-path
# commit (git commit -F msg -- bots/x/BOT.md) git runs that hook against a
# temporary index while the real index is locked, so without hooks/post-commit
# the commit ends with HEAD and the working tree bumped and the index one patch
# behind (status MM, `git diff HEAD` empty). This test performs exactly that
# commit in a throwaway clone and requires HEAD, the index, and the working tree
# to agree afterwards, then makes an unrelated plain commit and requires it not
# to touch the bot at all.
#
# It tests the hooks as they are in THIS working tree (copied into the clone),
# so a hook fix is verified before it is committed. Override with
# HOOKS_SRC=<dir> to test another set of hooks.
#
# Usage: bash tests/hooks/test-version-bump.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOKS_SRC="${HOOKS_SRC:-$REPO_ROOT/hooks}"
BOT_NAME="${TEST_BOT:-sales-pipeline}"
BOT="bots/$BOT_NAME/BOT.md"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
FAILURES=0
pass() { echo -e "${GREEN}PASS${NC} $1"; }
fail() { echo -e "${RED}FAIL${NC} $1"; FAILURES=$((FAILURES + 1)); }

version_in() { grep -m1 'version:' | sed 's/.*version: *"\(.*\)"/\1/'; }

# A fresh Linux clone only runs a hook that is executable in the tree.
for h in pre-commit post-commit; do
  mode="$(git -C "$REPO_ROOT" ls-files -s "hooks/$h" | awk '{print $1}')"
  if [ "$mode" = "100755" ]; then
    pass "hooks/$h is executable in the index ($mode)"
  else
    fail "hooks/$h must be tracked as 100755 so a fresh clone runs it (got '${mode:-untracked}')"
  fi
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if ! git clone -q "$REPO_ROOT" "$TMP/repo" 2>/dev/null; then
  fail "could not clone $REPO_ROOT into a temp dir"
  exit 1
fi
cd "$TMP/repo" || exit 1
git config user.name "hook-test"
git config user.email "hook-test@localhost"
git config commit.gpgsign false
for h in pre-commit post-commit; do
  if [ -f "$HOOKS_SRC/$h" ]; then
    cp "$HOOKS_SRC/$h" ".git/hooks/$h"
    chmod +x ".git/hooks/$h"
  fi
done

if [ ! -f "$BOT" ]; then
  fail "$BOT not found in clone"
  exit 1
fi

before="$(version_in < "$BOT")"
IFS='.' read -r major minor patch <<< "$before"
expected="${major}.${minor}.$((patch + 1))"

printf '\n<!-- hook test %s -->\n' "$(date +%s)" >> "$BOT"
echo "test: by-path commit" > "$TMP/msg"
if git commit -q -F "$TMP/msg" -- "$BOT" >"$TMP/commit.out" 2>&1; then
  pass "by-path commit of $BOT succeeded"
else
  fail "by-path commit of $BOT failed:"
  sed 's/^/    /' "$TMP/commit.out"
  exit 1
fi

head_v="$(git show "HEAD:$BOT" | version_in)"
index_v="$(git show ":$BOT" | version_in)"
tree_v="$(version_in < "$BOT")"

[ "$head_v" = "$expected" ] && pass "HEAD carries the bump ($before -> $head_v)" || fail "HEAD version is $head_v, expected $expected"
[ "$tree_v" = "$head_v" ] && pass "working tree matches HEAD ($tree_v)" || fail "working tree version $tree_v != HEAD $head_v"
[ "$index_v" = "$head_v" ] && pass "index matches HEAD ($index_v)" || fail "index version $index_v != HEAD $head_v (stale index entry, issue #82)"
if git diff --cached --quiet HEAD -- "$BOT"; then
  pass "index and HEAD agree byte for byte on $BOT"
else
  fail "index differs from HEAD on $BOT after the commit"
fi
status="$(git status --porcelain -- "$BOT")"
[ -z "$status" ] && pass "git status is clean for $BOT" || fail "git status not clean for $BOT: '$status'"

# An unrelated plain commit must not carry the bot along (phantom bump or revert).
printf '\nhook test\n' >> README.md
git add -- README.md
echo "test: unrelated plain commit" > "$TMP/msg"
if git commit -q -F "$TMP/msg" >"$TMP/commit2.out" 2>&1; then
  pass "unrelated plain commit succeeded"
else
  fail "unrelated plain commit failed:"
  sed 's/^/    /' "$TMP/commit2.out"
fi
if git show --name-only --format= HEAD | grep -qx "$BOT"; then
  fail "unrelated commit swept $BOT in (index was stale)"
else
  pass "unrelated commit left $BOT alone"
fi
after_v="$(git show "HEAD:$BOT" | version_in)"
[ "$after_v" = "$expected" ] && pass "bot version still $expected after the unrelated commit" || fail "bot version changed to $after_v by an unrelated commit"

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES hook check(s) failed"
  exit 1
fi
echo "All hook checks passed"
