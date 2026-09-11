#!/usr/bin/env bash
# Known ADL tool allowlist: generated from the runtime, never hand-edited.
#
# tests/skills/validate-format.sh rejects a skill whose tools.required names a
# tool the OpenCLAW runtime does not serve. The allowlist it checks against is
# tests/skills/known-tools.txt, and this script is the only thing that writes
# that file. The source of truth is ADLTools() in
# core-api/openclaw-runtime/internal/executor/: every served tool is a
# `Name: "adl_..."` field in one of the *_defs.go files there, and the runtime's
# own test (tools_defs_order_test.go) proves that testdata/adl_tools_order.golden
# is the exact sequence ADLTools() returns.
#
# Why generate rather than maintain by hand: the hand list drifted by ten tools
# in one season and every skill that declared a real tool failed CI for it
# (skills/ui-navigation was downgraded to adl_tool_search on 2026-09-10 just to
# get green). A list nobody writes cannot drift silently; it can only be stale,
# and --check turns stale into a failing exit code.
#
# Why grep the defs AND cross-check the golden: the grep is the generator (it
# is what the brief asks for and it survives the golden being retired); the
# golden is the proof that the grep saw exactly what ADLTools() serves. A def
# declared but never appended to ADLTools(), or a golden not regenerated, makes
# the two disagree, and that is a core-api bug worth failing on here.
#
# Usage:
#   tests/skills/sync-known-tools.sh --check   # default; exit 1 if the snapshot is stale
#   tests/skills/sync-known-tools.sh --write   # regenerate tests/skills/known-tools.txt
#
# Environment:
#   CORE_API_DIR   path to a core-api checkout (default: ../core-api next to this repo)
#   CORE_API_REF   git ref to read from the core-api checkout. Default:
#                  origin/development when that ref exists (the branch the
#                  marketplace runtime is built from; a behind or dirty local
#                  checkout is never the source and the shared tree is never
#                  touched), else the working tree. Set CORE_API_REF=worktree to
#                  force the working tree, e.g. for a tool you have not pushed.
#                  The check is as fresh as the last `git fetch` of core-api.
#
# When core-api is not present (public CI without the private checkout) --check
# prints SKIP and exits 0, because staleness cannot be evaluated without the
# source. Set SB_REQUIRE_CORE_API=1 to make that a failure (the runtime
# integration job does).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SNAPSHOT="$SCRIPT_DIR/known-tools.txt"
CORE_API_DIR="${CORE_API_DIR:-$REPO_ROOT/../core-api}"
CORE_API_REF="${CORE_API_REF:-}"
EXECUTOR_DIR="openclaw-runtime/internal/executor"
GOLDEN="$EXECUTOR_DIR/testdata/adl_tools_order.golden"

MODE="${1:---check}"
case "$MODE" in
  --check|--write) ;;
  *) echo "usage: $0 [--check|--write]" >&2; exit 2 ;;
esac

if [ ! -d "$CORE_API_DIR/$EXECUTOR_DIR" ]; then
  if [ "${SB_REQUIRE_CORE_API:-0}" = "1" ]; then
    echo "FAIL: core-api executor not found at $CORE_API_DIR/$EXECUTOR_DIR (set CORE_API_DIR)" >&2
    exit 1
  fi
  echo "SKIP: core-api checkout not found at $CORE_API_DIR; cannot evaluate known-tools.txt staleness"
  echo "      (set CORE_API_DIR to a core-api checkout, or SB_REQUIRE_CORE_API=1 to fail instead)"
  exit 0
fi

if [ -z "$CORE_API_REF" ] && git -C "$CORE_API_DIR" rev-parse --verify -q origin/development >/dev/null 2>&1; then
  CORE_API_REF="origin/development"
fi
[ "$CORE_API_REF" = "worktree" ] && CORE_API_REF=""

# Read a core-api file from the working tree or, when CORE_API_REF is set,
# from that ref without touching the working tree.
read_core_file() {
  if [ -n "$CORE_API_REF" ]; then
    git -C "$CORE_API_DIR" show "$CORE_API_REF:$1" 2>/dev/null
  else
    cat "$CORE_API_DIR/$1" 2>/dev/null
  fi
}

list_def_files() {
  if [ -n "$CORE_API_REF" ]; then
    git -C "$CORE_API_DIR" ls-tree --name-only "$CORE_API_REF" -- "$EXECUTOR_DIR/" | grep -E '_defs\.go$' | grep -v '_test\.go$'
  else
    (cd "$CORE_API_DIR" && ls "$EXECUTOR_DIR"/*_defs.go 2>/dev/null) | grep -v '_test\.go$'
  fi
}

source_label="$CORE_API_DIR"
[ -n "$CORE_API_REF" ] && source_label="$CORE_API_DIR@$CORE_API_REF"

# 1. Generate: every Name: "adl_..." across the *_defs.go files.
generated="$(
  for f in $(list_def_files); do
    read_core_file "$f" | grep -oE 'Name:[[:space:]]*"adl_[a-z0-9_]+"' | sed -E 's/.*"(adl_[a-z0-9_]+)"/\1/'
  done | sort -u
)"

if [ -z "$generated" ]; then
  echo "FAIL: no adl_ tool names found under $source_label/$EXECUTOR_DIR" >&2
  exit 1
fi

# 2. Cross-check against the runtime's golden order file when it exists.
golden="$(read_core_file "$GOLDEN" | grep -E '^adl_' | sort -u)"
if [ -n "$golden" ]; then
  only_defs="$(comm -23 <(echo "$generated") <(echo "$golden"))"
  only_golden="$(comm -13 <(echo "$generated") <(echo "$golden"))"
  if [ -n "$only_defs" ] || [ -n "$only_golden" ]; then
    echo "FAIL: *_defs.go and $GOLDEN disagree in $source_label; fix core-api before syncing" >&2
    [ -n "$only_defs" ] && echo "  defined but not in ADLTools() golden: $(echo "$only_defs" | tr '\n' ' ')" >&2
    [ -n "$only_golden" ] && echo "  in golden but not in any *_defs.go:   $(echo "$only_golden" | tr '\n' ' ')" >&2
    exit 1
  fi
fi

render() {
  cat <<HDR
# GENERATED by tests/skills/sync-known-tools.sh. Do not edit by hand.
# Source: ADLTools() in core-api/$EXECUTOR_DIR (*_defs.go Name fields).
# Refresh: tests/skills/sync-known-tools.sh --write
# Check:   tests/skills/sync-known-tools.sh --check   (run by tests/validate-all.sh)
HDR
  echo "$generated"
}

if [ "$MODE" = "--write" ]; then
  render > "$SNAPSHOT"
  echo "wrote $(echo "$generated" | wc -l | tr -d ' ') tools to ${SNAPSHOT#"$REPO_ROOT/"} from $source_label"
  exit 0
fi

if [ ! -f "$SNAPSHOT" ]; then
  echo "FAIL: ${SNAPSHOT#"$REPO_ROOT/"} missing; run $0 --write" >&2
  exit 1
fi

committed="$(grep -E '^adl_' "$SNAPSHOT" | sort -u)"
missing="$(comm -23 <(echo "$generated") <(echo "$committed"))"
extra="$(comm -13 <(echo "$generated") <(echo "$committed"))"
if [ -n "$missing" ] || [ -n "$extra" ]; then
  echo "FAIL: ${SNAPSHOT#"$REPO_ROOT/"} is stale against $source_label" >&2
  [ -n "$missing" ] && echo "  runtime serves, snapshot lacks: $(echo "$missing" | tr '\n' ' ')" >&2
  [ -n "$extra" ] && echo "  snapshot lists, runtime lacks:  $(echo "$extra" | tr '\n' ' ')" >&2
  echo "  fix: tests/skills/sync-known-tools.sh --write" >&2
  exit 1
fi

echo "OK: ${SNAPSHOT#"$REPO_ROOT/"} matches $source_label ($(echo "$generated" | wc -l | tr -d ' ') tools)"
