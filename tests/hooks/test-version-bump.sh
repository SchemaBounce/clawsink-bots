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
# The same bump must rewrite every teams/*/TEAM.md pin of the bot (4ebd6c9
# bumped sales-pipeline to 1.0.13 and teams/sales-team still pinned 1.0.12,
# which failed the sales-pipeline contract in CI), and must NOT touch a TEAM.md
# that already carries uncommitted changes.
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

# Every team that pins the bot must now pin the bumped version, in the commit
# and in a clean index.
pinned_teams="$(grep -lE "bots/$BOT_NAME@[0-9]+\.[0-9]+\.[0-9]+" teams/*/TEAM.md 2>/dev/null || true)"
if [ -z "$pinned_teams" ]; then
  fail "no teams/*/TEAM.md pins bots/$BOT_NAME; pick a pinned bot with TEST_BOT"
fi
for team_md in $pinned_teams; do
  if git show "HEAD:$team_md" | grep -q "bots/$BOT_NAME@$expected"; then
    pass "$team_md pins bots/$BOT_NAME@$expected in HEAD"
  else
    fail "$team_md does not pin bots/$BOT_NAME@$expected in HEAD (got: $(git show "HEAD:$team_md" | grep -oE "bots/$BOT_NAME@[0-9.]+" | head -1))"
  fi
  if git show --name-only --format= HEAD | grep -qx "$team_md"; then
    pass "$team_md was part of the by-path commit"
  else
    fail "$team_md was not included in the by-path commit"
  fi
  if [ -z "$(git status --porcelain -- "$team_md")" ]; then
    pass "git status is clean for $team_md"
  else
    fail "git status not clean for $team_md: '$(git status --porcelain -- "$team_md")'"
  fi
done

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

# A TEAM.md with uncommitted changes belongs to someone else: the bump must
# warn and leave it alone rather than sweep it into the commit.
dirty_team="$(echo "$pinned_teams" | head -1)"
if [ -n "$dirty_team" ]; then
  printf '\n<!-- someone else is editing this file -->\n' >> "$dirty_team"
  printf '\n<!-- hook test second edit -->\n' >> "$BOT"
  echo "test: by-path commit with a dirty team manifest" > "$TMP/msg"
  expected2="${major}.${minor}.$((patch + 2))"
  if git commit -q -F "$TMP/msg" -- "$BOT" >"$TMP/commit3.out" 2>&1; then
    pass "by-path commit with a dirty $dirty_team succeeded"
  else
    fail "by-path commit with a dirty $dirty_team failed:"
    sed 's/^/    /' "$TMP/commit3.out"
  fi
  if grep -q "pin not rewritten" "$TMP/commit3.out"; then
    pass "hook warned that the dirty $dirty_team pin was not rewritten"
  else
    fail "hook did not warn about the dirty $dirty_team"
  fi
  if git show --name-only --format= HEAD | grep -qx "$dirty_team"; then
    fail "dirty $dirty_team was swept into the commit"
  else
    pass "dirty $dirty_team was left out of the commit"
  fi
  if grep -q "someone else is editing" "$dirty_team" && grep -q "bots/$BOT_NAME@$expected" "$dirty_team"; then
    pass "dirty $dirty_team keeps its edit and its old pin ($expected) for the owner to update"
  else
    fail "dirty $dirty_team was modified by the hook"
  fi
  head_v3="$(git show "HEAD:$BOT" | version_in)"
  [ "$head_v3" = "$expected2" ] && pass "bot still bumped to $expected2 with the team skipped" || fail "bot version is $head_v3, expected $expected2"
fi

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES hook check(s) failed"
  exit 1
fi
echo "All hook checks passed"
