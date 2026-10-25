#!/usr/bin/env bash
# dec-185, dec-186: a SchemaBounce Team is now a Domain, and a marketplace "team" is a
# domain template. This gate stops new "team" wording from creeping back into shipped text.
#
# Usage:
#   scripts/check-team-copy.sh --staged        check staged blobs (pre-commit)
#   scripts/check-team-copy.sh FILE...         check files on disk
#   scripts/check-team-copy.sh --update-baseline   rewrite the baseline from the tree
#
# A file may not have more non-allowlisted "team"/"teams" lines than its entry in
# scripts/team-copy-baseline.tsv ("path<TAB>count"; a file with no entry has zero).
# Lowering a count is always fine. Raising one is not: fix the wording instead.
#
# Allowed on a line: the Team plan, team_seat, Microsoft Teams, Linear, Slack, a Claude Team
# seat, and a bot or template id such as `sales-team` or `teams/` (the old layout path).
# Bot prose also uses "teams" as plain English for a customer's own staff; those lines are in
# the baseline and are not a defect, but new ones are counted so the list only shrinks.
# Shipped text = everything except tests, scripts, hooks, .github, .claude and .schemabounce.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
BASE="$ROOT/scripts/team-copy-baseline.tsv"
ALLOW='Team plan|team plan|team_seat|Microsoft Teams|Teams app|Linear|Slack|Claude Team|[a-z0-9]-team|team-[a-z0-9]|teams/|TEAM\.md|kind: Team|/marketplace/teams'

shipped() {
  case "$1" in
    tests/*|scripts/*|hooks/*|.github/*|.claude/*|.schemabounce/*|.git/*|LICENSE|NOTICE) return 1 ;;
  esac
  case "$1" in *.md|*.json|*.yaml|*.yml|*.txt|*.toml) return 0 ;; *) return 1 ;; esac
}

count_stream() { # content on stdin -> number of non-allowlisted lines
  grep -iE '(^|[^a-z_-])teams?([^a-z_-]|$)' | grep -vE "$ALLOW" | wc -l
}

baseline_for() { # path
  [ -f "$BASE" ] || { echo 0; return; }
  awk -F'\t' -v p="$1" '$1==p {print $2; found=1} END {if(!found) print 0}' "$BASE"
}

if [ "${1:-}" = "--update-baseline" ]; then
  tmp="$(mktemp)"
  git ls-files | while IFS= read -r f; do
    shipped "$f" || continue
    [ -f "$f" ] || continue
    n="$(count_stream < "$f")"
    [ "$n" -gt 0 ] && printf '%s\t%s\n' "$f" "$n"
  done | LC_ALL=C sort > "$tmp"
  mv "$tmp" "$BASE"
  echo "team-copy: baseline rewritten ($(wc -l < "$BASE") files)"
  exit 0
fi

fail=0
check() { # path  (content on stdin)
  local p="$1" n b
  n="$(count_stream)"
  b="$(baseline_for "$p")"
  if [ "$n" -gt "$b" ]; then
    echo "team-copy: $p has $n lines with \"team\" wording, baseline allows $b"
    fail=1
  fi
}

if [ "${1:-}" = "--staged" ]; then
  while IFS= read -r f; do
    shipped "$f" || continue
    check "$f" < <(git show ":$f" 2>/dev/null)
  done < <(git diff --cached --name-only --diff-filter=ACMR)
else
  for f in "$@"; do
    f="${f#./}"
    shipped "$f" || continue
    check "$f" < "$f"
  done
fi

if [ "$fail" -ne 0 ]; then
  echo "team-copy: dec-185/dec-186 renamed Team to Domain and the marketplace team to a domain template."
  echo "team-copy: say \"domain\" or \"domain template\". The Team plan, team_seat, Microsoft Teams and Linear teams are allowed."
  exit 1
fi
exit 0
