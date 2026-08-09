#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BOT_DIR="$ROOT_DIR/bots/demand-signal-scout"
BOT="$BOT_DIR/BOT.md"
TOOLS="$BOT_DIR/TOOLS.md"
NORTH_STAR="$BOT_DIR/data-seeds/zone1-north-star.json"
ENTITY_TYPES="$BOT_DIR/data-seeds/zone2-entity-types.json"
TEAM="$ROOT_DIR/teams/sales-team/TEAM.md"
FAILURES=0

fail() {
  echo "FAIL: $1"
  FAILURES=$((FAILURES + 1))
}

pass() {
  echo "PASS: $1"
}

if grep -q 'key: icp_definition' "$BOT" && jq -e '.seeds | any(.key == "icp_definition")' "$NORTH_STAR" >/dev/null; then
  pass "canonical ICP key is consistent"
else
  fail "BOT.md and North Star seed must use icp_definition"
fi

if grep -q 'key: ideal_customer_profile' "$BOT" || jq -e '.seeds | any(.key == "ideal_customer_profile")' "$NORTH_STAR" >/dev/null; then
  fail "legacy ideal_customer_profile remains in active setup or seed"
else
  pass "legacy ICP key is migration-only"
fi

for entity in prospect_signals company_buying_signals content_opportunities acquisition_queue outreach_drafts receipt; do
  if jq -e --arg entity "$entity" '.entityTypes | any(.name == $entity)' "$ENTITY_TYPES" >/dev/null; then
    pass "entity contract exists: $entity"
  else
    fail "missing entity contract: $entity"
  fi
done

for connector in exa reddit youtube hubspot; do
  if grep -q "ref: tools/$connector" "$BOT"; then
    pass "connector declared: $connector"
  else
    fail "missing connector declaration: $connector"
  fi
done

for contract in 'Acquisition Priority Score' 'Company Buying Signal Contract' 'Content Opportunity Contract' 'Daily Acquisition Queue Contract' 'Feedback And Attribution'; do
  if grep -q "## $contract" "$TOOLS"; then
    pass "tool contract exists: $contract"
  else
    fail "missing tool contract: $contract"
  fi
done

if grep -q 'bots/demand-signal-scout@1\.0\.3' "$TEAM"; then
  pass "Sales team references Demand Signal Scout 1.0.3"
else
  fail "Sales team must reference Demand Signal Scout 1.0.3"
fi

if grep -q 'northstar:icp_definition' "$BOT" && grep -q 'northstar:conversion_url' "$BOT" && ! grep -q 'bot:demand-signal-scout:northstar' "$BOT"; then
  pass "North Star reads use canonical Zone 1 namespaces"
else
  fail "North Star reads must use canonical northstar:{key} namespaces"
fi

if grep -q 'The YouTube connector can read comments and post comment replies; it does not publish Community posts, Shorts, or videos\.' "$TOOLS"; then
  pass "YouTube capability boundary is explicit"
else
  fail "YouTube publishing capability boundary is missing"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES demand-signal contract check(s) failed"
  exit 1
fi

echo "All demand-signal contract checks passed"
