#!/usr/bin/env bash
# dec-121: the word "seat" never names a SchemaBounce concept (agents, agent
# capacity, workspace membership, plans). The one exception is a third-party
# provider's own license unit, in the provider's own term (a Claude Team seat).
#
# Usage:
#   scripts/check-seat-copy.sh --staged     check the staged blobs (pre-commit)
#   scripts/check-seat-copy.sh FILE...      check files on disk
# Exit 1 and print path:line for every shipped line that uses "seat" and is not
# allowlisted. Shipped text = everything except tests, scripts, hooks, .github,
# .claude and .schemabounce.
#
# The allowlist is deliberately small and explicit:
#   1. a line that names a provider next to the word (PROVIDERS below), or
#   2. an entry in scripts/seat-copy-allowlist.txt, "path<TAB>substring".
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ALLOWFILE="$ROOT/scripts/seat-copy-allowlist.txt"
PROVIDERS='Claude|Anthropic|ChatGPT|OpenAI|Codex|Gemini|Copilot|GitHub'

shipped() {
  case "$1" in
    tests/*|scripts/*|hooks/*|.github/*|.claude/*|.schemabounce/*|.git/*|LICENSE|NOTICE) return 1 ;;
  esac
  case "$1" in *.md|*.json|*.yaml|*.yml|*.txt|*.toml) return 0 ;; *) return 1 ;; esac
}

allowed_line() { # path line
  local p="$1" line="$2"
  if printf '%s\n' "$line" | grep -qiE "(${PROVIDERS})[^.]{0,60}seat|seat[^.]{0,60}(${PROVIDERS})"; then return 0; fi
  [ -f "$ALLOWFILE" ] || return 1
  local ap asub
  while IFS=$'\t' read -r ap asub; do
    [ -z "${ap:-}" ] && continue
    case "$ap" in \#*) continue ;; esac
    if [ "$ap" = "$p" ] && [[ "$line" == *"$asub"* ]]; then return 0; fi
  done < "$ALLOWFILE"
  return 1
}

check_stream() { # path  (content on stdin); grep first so clean files cost one process
  local p="$1" bad=0 hit n line
  hit="$(grep -niE '(^|[^a-z])seats?([^a-z]|$)|seat_|seatid' || true)"
  [ -z "$hit" ] && return 0
  while IFS= read -r hit_line; do
    n="${hit_line%%:*}"
    line="${hit_line#*:}"
    if ! allowed_line "$p" "$line"; then
      echo "seat-copy: $p:$n: $line" | cut -c1-220
      bad=1
    fi
  done <<< "$hit"
  return $bad
}

fail=0
if [ "${1:-}" = "--staged" ]; then
  while IFS= read -r f; do
    shipped "$f" || continue
    git show ":$f" 2>/dev/null | check_stream "$f" || fail=1
  done < <(git diff --cached --name-only --diff-filter=ACMR)
else
  for f in "$@"; do
    f="${f#./}"
    shipped "$f" || continue
    check_stream "$f" < "$f" || fail=1
  done
fi

if [ "$fail" -ne 0 ]; then
  echo "seat-copy: dec-121 forbids \"seat\" for agents, capacity, membership or plans. Say \"agent\" or \"agent slot\"."
  echo "seat-copy: a provider's own license unit may keep the word (name the provider on the line)."
  exit 1
fi
exit 0
