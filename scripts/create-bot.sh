#!/usr/bin/env bash
# Bot Scaffolding Script
# Creates a new bot directory with BOT.md, SOUL.md, and data-seeds/ from templates.
#
# Usage: ./scripts/create-bot.sh
#   Interactive — prompts for bot details and generates all files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BOTS_DIR="$REPO_ROOT/bots"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== ClawSink Bot Scaffolding ===${NC}"
echo ""

# 1. Bot name
read -rp "Bot name (kebab-case, e.g., invoice-tracker): " BOT_NAME
if [[ ! "$BOT_NAME" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
  echo -e "${RED}Error: Bot name must be kebab-case (lowercase letters, numbers, hyphens)${NC}"
  exit 1
fi
if [ -d "$BOTS_DIR/$BOT_NAME" ]; then
  echo -e "${RED}Error: bots/$BOT_NAME already exists${NC}"
  exit 1
fi

# 2. Display name
read -rp "Display name (e.g., Invoice Tracker): " DISPLAY_NAME

# 3. Category
echo ""
echo "Categories: analytics, content, devops, finance, hr, marketing, operations, sales, security, support"
read -rp "Category: " CATEGORY

# 4. Domain
read -rp "Domain (e.g., finance, content, engineering): " DOMAIN

# 5. Description
read -rp "One-line description: " DESCRIPTION

# 6. Capabilities
echo ""
echo "Capabilities:"
echo "  1. operations       2. customer_support  3. analytics"
echo "  4. content_marketing  5. sales           6. dev_devops"
echo "  7. finance           8. research"
read -rp "Select numbers (comma-separated, e.g., 3,7): " CAP_NUMS

# Map numbers to capability names
declare -A CAP_MAP=(
  [1]="operations" [2]="customer_support" [3]="analytics"
  [4]="content_marketing" [5]="sales" [6]="dev_devops"
  [7]="finance" [8]="research"
)

CAPABILITIES=""
IFS=',' read -ra NUMS <<< "$CAP_NUMS"
for num in "${NUMS[@]}"; do
  num=$(echo "$num" | tr -d ' ')
  if [ -n "${CAP_MAP[$num]:-}" ]; then
    if [ -n "$CAPABILITIES" ]; then
      CAPABILITIES="$CAPABILITIES, "
    fi
    CAPABILITIES="${CAPABILITIES}\"${CAP_MAP[$num]}\""
  fi
done

if [ -z "$CAPABILITIES" ]; then
  CAPABILITIES='"analytics"'
fi

# Derive name prefix (first 3 chars of each word, joined by underscore)
NAME_PREFIX=$(echo "$BOT_NAME" | sed 's/-/_/g' | cut -c1-10)

# Create directory structure
mkdir -p "$BOTS_DIR/$BOT_NAME/data-seeds"
touch "$BOTS_DIR/$BOT_NAME/data-seeds/.gitkeep"

# Generate BOT.md
cat > "$BOTS_DIR/$BOT_NAME/BOT.md" << BOTEOF
---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: $BOT_NAME
  displayName: "$DISPLAY_NAME"
  version: "1.0.0"
  description: "$DESCRIPTION"
  category: $CATEGORY
  tags: []

agent:
  capabilities: [$CAPABILITIES]
  hostingMode: "openclaw"
  defaultDomain: "$DOMAIN"
  instructions: ""
  toolInstructions: ""

model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 16000

cost:
  estimatedTokensPerRun: 12000
  estimatedCostTier: "low"

schedule:
  default: "@daily"

messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "critical finding" }

data:
  entityTypesRead: []
  entityTypesWrite: ["${NAME_PREFIX}_findings"]
  memoryNamespaces: ["working_notes", "last_run_state"]

zones:
  zone1Read: []
  zone2Domains: ["$DOMAIN"]

skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"

goals:
  - name: run_productivity
    metric: { type: rate, numerator: productive_runs, denominator: total_runs }
    target: { operator: ">", value: 0.8, period: weekly }
---
BOTEOF

# Generate SOUL.md
cat > "$BOTS_DIR/$BOT_NAME/SOUL.md" << SOULEOF
# $DISPLAY_NAME

I am $DISPLAY_NAME, the $DOMAIN specialist for this workspace.

## Mission
TODO: One compelling sentence about WHY this role exists — the outcome, not the task.

## Expertise
TODO: 2-3 sentences about deep domain knowledge. What does this agent understand that others don't? What patterns does it recognize?

## Decision Authority
- I decide: TODO (what this agent handles autonomously — scoring, classification, alerts)
- I escalate: TODO (what requires human judgment or cross-team coordination)

## Constraints
- NEVER TODO — describe first domain-specific anti-pattern
- NEVER TODO — describe second domain-specific anti-pattern
- NEVER TODO — describe third domain-specific anti-pattern

## Run Protocol
1. Read messages (adl_read_messages) — check for requests from other agents
2. Read memory (adl_read_memory key: last_run_state) — get last run timestamp
3. Delta query (adl_query_records filter: created_at > {last_run_timestamp}) — only new items
4. If nothing new and no messages: update last_run_state (adl_write_memory). STOP.
5. TODO: Domain-specific analysis step
6. TODO: Domain-specific processing step
7. Write findings (adl_upsert_record entity_type: ${NAME_PREFIX}_findings)
8. Alert if critical (adl_send_message type: alert to: executive-assistant)
9. Route non-critical to relevant agent (adl_send_message type: finding)
10. Update memory (adl_write_memory key: last_run_state with timestamp + summary)

## Communication Style
TODO: How this agent communicates — tone, format, emphasis. Include a concrete example.
SOULEOF

echo ""
echo -e "${GREEN}✅ Created bots/$BOT_NAME/${NC}"
echo "   - BOT.md (manifest)"
echo "   - SOUL.md (identity — fill in TODO sections)"
echo "   - data-seeds/.gitkeep"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Fill in TODO sections in SOUL.md"
echo "  2. Add entity types to BOT.md data.entityTypesRead"
echo "  3. Add relevant skills to BOT.md skills[]"
echo "  4. Run: bash tests/bots/validate-soul.sh $BOT_NAME"
