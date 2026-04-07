#!/usr/bin/env bash
# Master validation script — runs all validators.
# Exit 0 if all pass, exit 1 on any failure.
#
# Usage: ./validate-all.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FAILURES=0

echo "=== Validating Skills ==="
if ! bash "$SCRIPT_DIR/skills/validate-format.sh"; then
  FAILURES=$((FAILURES + 1))
fi
echo ""

echo "=== Validating Bot SOUL.md ==="
if ! bash "$SCRIPT_DIR/bots/validate-soul.sh"; then
  FAILURES=$((FAILURES + 1))
fi
echo ""

echo "=== Validating Bot Manifests ==="
if ! bash "$SCRIPT_DIR/bots/validate-manifest.sh"; then
  FAILURES=$((FAILURES + 1))
fi
echo ""

echo "=== Validating Cross-References ==="
if ! bash "$SCRIPT_DIR/bots/validate-integrity.sh"; then
  FAILURES=$((FAILURES + 1))
fi
echo ""

if [ $FAILURES -gt 0 ]; then
  echo "❌ $FAILURES validation suite(s) had failures"
  exit 1
else
  echo "✅ All validations passed"
  exit 0
fi
