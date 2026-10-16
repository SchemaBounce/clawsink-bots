#!/usr/bin/env bash
# scripts/check-seat-copy.sh (dec-121): one bad line fails, one good line passes.
# Usage: bash tests/hooks/test-seat-copy.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/scripts" "$T/bots/x"
cp "$ROOT/scripts/check-seat-copy.sh" "$T/scripts/"
cd "$T"
fails=0
check() { # name expected-rc content
  printf '%s\n' "$3" > bots/x/BOT.md
  bash scripts/check-seat-copy.sh bots/x/BOT.md >/dev/null 2>&1; rc=$?
  if [ "$rc" -eq "$2" ]; then echo "PASS $1"; else echo "FAIL $1 (rc=$rc)"; fails=$((fails+1)); fi
}
check "bad: agent called a seat"            1 "Deploy the bot to a seat."
check "bad: per-seat plan"                  1 "Pricing is per-seat."
check "bad: seat_ id"                       1 "Pass the seat_5022a23e id."
check "good: provider license seat"         0 "The session needs a Claude Team seat."
check "good: agent slots"                   0 "Capacity is counted in agent slots."
exit $fails
