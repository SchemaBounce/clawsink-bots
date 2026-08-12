#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BOT="$ROOT_DIR/bots/sales-pipeline/BOT.md"
TEAM="$ROOT_DIR/teams/sales-team/TEAM.md"
FAILURES=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES + 1)); }

if grep -q 'ref: tools/hubspot' "$BOT"; then
  pass "HubSpot is the CRM setup connection"
else
  fail "HubSpot must be the CRM setup connection"
fi

if grep -q 'ref: tools/composio' "$BOT"; then
  fail "umbrella Composio setup remains"
else
  pass "umbrella Composio setup is absent"
fi

if awk '/id: connect-email/{found=1} found && /priority: recommended/{ok=1; exit} found && /priority: required/{exit} END{exit !(found && ok)}' "$BOT"; then
  pass "email is a recommended setup capability"
else
  fail "email must not block pipeline analysis"
fi

if grep -q 'Never write to the source CRM' "$BOT" && grep -q 'Never send unsolicited email or direct messages' "$BOT"; then
  pass "CRM writes and unsolicited outreach are prohibited"
else
  fail "CRM write and outreach guardrails are required"
fi

if grep -q 'filter: { insight_type: "stalled" }' "$BOT" && ! grep -q 'insight_type: "stalled_deal"' "$BOT"; then
  pass "stalled-deal goal matches the entity enum"
else
  fail "stalled-deal goal must use the stalled entity enum"
fi

BOT_VERSION="$(awk '/^  version: / { gsub(/"/, "", $2); print $2; exit }' "$BOT")"
if grep -q "bots/sales-pipeline@$BOT_VERSION" "$TEAM"; then
  pass "sales team pins the current pipeline contract"
else
  fail "sales team must pin sales-pipeline@$BOT_VERSION"
fi

for legacy in 'cold-outreach' 'agentmail.send' 'GMAIL_SEND_EMAIL' 'SALESFORCE_LIST_OPPORTUNITIES'; do
  if grep -q "$legacy" "$BOT"; then
    fail "legacy instruction remains: $legacy"
  else
    pass "legacy instruction absent: $legacy"
  fi
done

if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES sales-pipeline contract check(s) failed"
  exit 1
fi

echo "All sales-pipeline contract checks passed"
