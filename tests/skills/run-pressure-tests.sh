#!/usr/bin/env bash
# Skill Pressure Test Runner
# Spawns Claude subagents as simulated ADL agents with skill prompts injected,
# presents scenarios, and grades pass/fail based on behavioral assertions.
#
# Usage: ./run-pressure-tests.sh [test-name]
#   No args = run all tests
#   test-name = run specific test (e.g., "workflow-failure")

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"
mkdir -p "$RESULTS_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
SKIP=0

# Load skill prompts
load_skill() {
  local skill_name="$1"
  cat "$REPO_ROOT/skills/$skill_name/prompt.md"
}

# Load bot identity
load_soul() {
  local bot_name="$1"
  cat "$REPO_ROOT/bots/$bot_name/SOUL.md"
}

# Build system prompt for a simulated agent
build_agent_prompt() {
  local bot_name="$1"
  shift
  local skills=("$@")

  echo "# Agent Identity"
  echo ""
  load_soul "$bot_name"
  echo ""
  echo "# Active Skills"
  echo ""
  for skill in "${skills[@]}"; do
    load_skill "$skill"
    echo ""
    echo "---"
    echo ""
  done
  echo "# SIMULATION ENVIRONMENT"
  echo ""
  echo "You are running inside the OpenCLAW runtime. This is NOT Claude Code."
  echo "You ARE an ADL agent. You HAVE the following MCP tools. They are REAL and AVAILABLE."
  echo "You MUST output tool calls to do your work. Output them as:"
  echo ""
  echo '```tool_call'
  echo 'tool_name(param1="value1", param2="value2")'
  echo '```'
  echo ""
  echo "Your available MCP tools:"
  echo "- adl_tool_search(query) — search for tools by keyword"
  echo "- adl_send_message(recipient_agent_id, message_type, body) — send message to another agent"
  echo "- adl_read_messages(unread_only) — read incoming messages"
  echo "- adl_list_agents() — list all agents in workspace"
  echo "- adl_run_agent(agent_id, prompt, wait) — delegate task to another agent"
  echo "- adl_run_agents(tasks, wait) — delegate to multiple agents in parallel"
  echo "- adl_query_records(entity_type, filters) — query records"
  echo "- adl_upsert_record(entity_type, entity_id, data) — create/update record"
  echo "- adl_get_workflow(workflow_id) — get workflow definition"
  echo "- adl_update_workflow(workflow_id, nodes, edges) — update workflow"
  echo "- adl_deploy_workflow(workflow_id) — deploy workflow"
  echo "- adl_list_workflow_runs(workflow_id) — list workflow runs"
  echo "- adl_get_workflow_run(workflow_id, run_id) — get run details"
  echo "- adl_propose_pipeline_route(name, source_type, reason) — propose new pipeline"
  echo ""
  echo "# RULES"
  echo ""
  echo "1. You MUST output tool_call blocks. This is how the runtime executes your actions."
  echo "2. Do NOT say 'I would call' or 'I should call' — OUTPUT THE CALL."
  echo "3. Do NOT ask the user anything. Get data from tools."
  echo "4. Do NOT present numbered menus or options."
  echo "5. Between tool calls, briefly explain your reasoning (1-2 sentences max)."
}

# Run a single test
run_test() {
  local test_name="$1"
  local bot_name="$2"
  local scenario="$3"
  local pass_patterns="$4"   # pipe-separated patterns that MUST appear
  local fail_patterns="$5"   # pipe-separated patterns that MUST NOT appear
  shift 5
  local skills=("$@")

  echo -n "  TEST: $test_name ... "

  local system_prompt
  system_prompt=$(build_agent_prompt "$bot_name" "${skills[@]}")

  local result_file="$RESULTS_DIR/${test_name}.md"

  # Write system prompt to temp file (avoids shell escaping issues with long prompts)
  local tmpfile
  tmpfile=$(mktemp /tmp/skill-test-XXXXXX.md)
  echo "$system_prompt" > "$tmpfile"

  # Run the subagent in --bare mode (strips Claude Code identity entirely)
  local response
  response=$(echo "$scenario" | claude -p \
    --bare \
    --model haiku \
    --system-prompt-file "$tmpfile" \
    --disallowed-tools "Bash Edit Write Read Glob Grep Agent Skill" \
    2>/dev/null) || {
    rm -f "$tmpfile"
    echo -e "${YELLOW}SKIP${NC} (claude CLI error)"
    ((SKIP++))
    return
  }
  rm -f "$tmpfile"

  # Save result
  cat > "$result_file" << RESULT_EOF
# Test: $test_name
## Scenario
$scenario

## Response
$response

## Assertions
RESULT_EOF

  # Check pass patterns — ANY match = pass (OR logic, pipe-separated grep pattern)
  local tool_call_pass=false
  if [ -n "$pass_patterns" ]; then
    if echo "$response" | grep -qiE "$pass_patterns"; then
      echo "PASS: found expected tool usage (matched: $pass_patterns)" >> "$result_file"
      tool_call_pass=true
    else
      echo "WARN: no exact tool call syntax found (expected any of: $pass_patterns)" >> "$result_file"
    fi
  fi

  # Conceptual awareness check — does the agent mention the right concepts?
  local awareness_pass=false
  local awareness_patterns="send.*message|route.*agent|delegate|list.*agent|tool_search|get_workflow|update_workflow|run_agent|send_message|list_agents|handoff|propose.*pipeline|query.*record"
  if echo "$response" | grep -qiE "$awareness_patterns"; then
    echo "PASS: agent shows tool/concept awareness" >> "$result_file"
    awareness_pass=true
  else
    echo "FAIL: agent shows no awareness of platform tools" >> "$result_file"
  fi

  # Check fail patterns — ANY match = fail (pipe-separated grep pattern)
  local no_fails=true
  if [ -n "$fail_patterns" ]; then
    local matched_fail=""
    matched_fail=$(echo "$response" | grep -oiE "$fail_patterns" | head -1) || true
    if [ -n "$matched_fail" ]; then
      echo "FAIL: found prohibited behavior: '$matched_fail'" >> "$result_file"
      no_fails=false
    else
      echo "PASS: no prohibited behaviors detected" >> "$result_file"
    fi
  fi

  # Grade: PASS = tool calls + no prohibited behavior
  #        PARTIAL = awareness but no tool calls
  #        FAIL = no awareness or prohibited behavior
  if $tool_call_pass && $no_fails; then
    echo -e "${GREEN}PASS${NC}"
    echo "## Result: PASS" >> "$result_file"
    ((PASS++))
  elif $awareness_pass && $no_fails; then
    echo -e "${YELLOW}PARTIAL${NC} (knows tools but didn't call them)"
    echo "## Result: PARTIAL (awareness without action)" >> "$result_file"
    ((SKIP++))
  else
    echo -e "${RED}FAIL${NC} (see $result_file)"
    echo "## Result: FAIL" >> "$result_file"
    ((FAIL++))
  fi
}

# ============================================================
# TEST SUITE: Platform Awareness
# ============================================================
test_platform_awareness() {
  echo ""
  echo "=== Platform Awareness Tests ==="

  # Test 1: Workflow failure — agent should act, not ask
  run_test "workflow-failure-act-not-ask" \
    "executive-assistant" \
    "A workflow 'wf_daily_discovery' just failed with error: 'upsert_record: entityType is required' on the 'Save Discovery (Gaps)' step. The node config has type 'upsert_record' but nodeType 'delay' in the config. Handle this." \
    "adl_get_workflow|adl_tool_search|adl_update_workflow|adl_send_message" \
    "which would you like|please clarify|would you prefer|let me know which|option 1|option 2|option 3" \
    "platform-awareness" "inter-agent-comms" "workflow-ops"

  # Test 2: Three stalled blockers — agent should create tasks and route
  run_test "stalled-blockers-route-not-menu" \
    "executive-assistant" \
    "Three critical blockers have been stalled for 21 days: FU-001 (API credentials setup), FU-003 (CRM pipeline provisioning), FU-005 (Ticketing pipeline provisioning). All three need to be assigned to the right agents and tracked." \
    "adl_send_message|adl_list_agents|adl_upsert_record|adl_run_agent" \
    "which would you like|please clarify|would you prefer|what should I|shall I" \
    "platform-awareness" "inter-agent-comms"

  # Test 3: Agent should check messages first
  run_test "check-messages-first" \
    "executive-assistant" \
    "You are starting a new run. Begin your work." \
    "adl_read_messages" \
    "" \
    "platform-awareness" "inter-agent-comms"

  # Test 4: Agent should use tool search for unknown capability
  run_test "tool-search-for-discovery" \
    "executive-assistant" \
    "I need to check the health of pipeline route rt_abc123 but I'm not sure which tool does that." \
    "adl_tool_search" \
    "I don't have|I cannot|not available|I'm unable" \
    "platform-awareness"
}

# ============================================================
# TEST SUITE: Inter-Agent Communication
# ============================================================
test_inter_agent_comms() {
  echo ""
  echo "=== Inter-Agent Communication Tests ==="

  # Test 5: Should send request to another agent, not ask human to relay
  run_test "send-request-not-relay" \
    "executive-assistant" \
    "The SRE team needs to investigate a database connection timeout affecting 3 environments. Route this to the right agent." \
    "adl_send_message|adl_list_agents|adl_run_agent" \
    "please tell the|ask the sre|you should contact|have someone" \
    "platform-awareness" "inter-agent-comms"

  # Test 6: Should use correct message type
  run_test "correct-message-type-alert" \
    "executive-assistant" \
    "URGENT: Production pipeline is dropping 40% of events. This needs immediate attention from the DevOps agent." \
    "alert|adl_send_message" \
    "finding|text|when you get a chance" \
    "platform-awareness" "inter-agent-comms"

  # Test 7: Should delegate to multiple agents in parallel
  run_test "parallel-delegation" \
    "executive-assistant" \
    "We need three things done simultaneously: the business analyst needs to run a revenue report, the accountant needs to reconcile Q1 invoices, and the data engineer needs to check pipeline health. Handle all three now." \
    "adl_run_agents|adl_send_message" \
    "one at a time|which one first|let's start with" \
    "platform-awareness" "inter-agent-comms"

  # Test 8: Should use handoff for cross-domain work
  run_test "handoff-cross-domain" \
    "executive-assistant" \
    "A customer support ticket #4521 contains detailed technical information about a recurring API timeout. This is an engineering issue, not a support issue. Transfer it appropriately." \
    "handoff|adl_send_message" \
    "I'll let them know|please forward|you should send" \
    "platform-awareness" "inter-agent-comms"
}

# ============================================================
# TEST SUITE: Workflow Operations
# ============================================================
test_workflow_ops() {
  echo ""
  echo "=== Workflow Operations Tests ==="

  # Test 9: Should diagnose workflow with correct tool sequence
  run_test "workflow-diagnose-sequence" \
    "executive-assistant" \
    "Workflow wf_8pjixri0 has been failing for 3 days. Run ID run_latest shows 'Save Discovery' step failed. Investigate and fix it." \
    "adl_get_workflow|adl_list_workflow_runs|adl_get_workflow_run" \
    "I need more information|can you provide|what is the workflow" \
    "platform-awareness" "workflow-ops"

  # Test 10: Should fix the nodeType mismatch pattern
  run_test "fix-nodetype-mismatch" \
    "executive-assistant" \
    "Workflow wf_abc has a node n_disc_4 with type 'upsert_record' but its config has nodeType 'delay' and durationMinutes 0. This is clearly wrong — the node should save discovery results. Fix it." \
    "adl_update_workflow" \
    "which approach|would you like me to|I'm not sure|please confirm" \
    "platform-awareness" "workflow-ops"
}

# ============================================================
# MAIN
# ============================================================
echo "============================================"
echo "  ClawSink Platform Skills Pressure Tests"
echo "============================================"
echo "  Bot: executive-assistant"
echo "  Skills: platform-awareness, inter-agent-comms, workflow-ops"
echo "  Model: haiku (fast, cheap, worst-case scenario)"
echo ""

# Check claude CLI exists
if ! command -v claude &> /dev/null; then
  echo -e "${RED}ERROR: 'claude' CLI not found. Install Claude Code first.${NC}"
  exit 1
fi

# Load API key for --bare mode (strips Claude Code identity)
# Set ANTHROPIC_API_KEY env var or place it in .env.local in this repo or a parent dir
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  search_dir="$REPO_ROOT"
  while [ "$search_dir" != "/" ]; do
    if [ -f "$search_dir/.env.local" ]; then
      ANTHROPIC_API_KEY=$(grep "^ANTHROPIC_API_KEY=" "$search_dir/.env.local" | cut -d= -f2)
      if [ -n "$ANTHROPIC_API_KEY" ]; then
        export ANTHROPIC_API_KEY
        break
      fi
    fi
    search_dir=$(dirname "$search_dir")
  done
fi

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo -e "${RED}ERROR: ANTHROPIC_API_KEY not set. Export it or add to .env.local${NC}"
  exit 1
fi

FILTER="${1:-all}"

if [ "$FILTER" = "all" ] || [ "$FILTER" = "platform-awareness" ]; then
  test_platform_awareness
fi
if [ "$FILTER" = "all" ] || [ "$FILTER" = "inter-agent-comms" ]; then
  test_inter_agent_comms
fi
if [ "$FILTER" = "all" ] || [ "$FILTER" = "workflow-ops" ]; then
  test_workflow_ops
fi

echo ""
echo "============================================"
echo -e "  Results: ${GREEN}${PASS} PASS${NC}  ${YELLOW}${SKIP} PARTIAL${NC}  ${RED}${FAIL} FAIL${NC}"
echo "  Details: $RESULTS_DIR/"
echo "============================================"

exit $FAIL
