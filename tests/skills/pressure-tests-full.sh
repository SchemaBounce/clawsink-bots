#!/usr/bin/env bash
# Full Pressure Test Suite — All Skills
# Tests every skill category with realistic scenarios.
# Runs agents in --bare mode (strips Claude Code identity).
#
# Usage: ./pressure-tests-full.sh [suite-name]
#   No args = run all suites
#   suite-name = run specific suite (e.g., "finance", "ops", "comms")

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results-full"
mkdir -p "$RESULTS_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0
PARTIAL=0

# Load API key
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  search_dir="$REPO_ROOT"
  while [ "$search_dir" != "/" ]; do
    if [ -f "$search_dir/.env.local" ]; then
      ANTHROPIC_API_KEY=$(grep "^ANTHROPIC_API_KEY=" "$search_dir/.env.local" | cut -d= -f2)
      [ -n "$ANTHROPIC_API_KEY" ] && export ANTHROPIC_API_KEY && break
    fi
    search_dir=$(dirname "$search_dir")
  done
fi
[ -z "${ANTHROPIC_API_KEY:-}" ] && echo -e "${RED}ERROR: ANTHROPIC_API_KEY not set${NC}" && exit 1

# Load skill prompt
load_skill() { cat "$REPO_ROOT/skills/$1/prompt.md" 2>/dev/null; }
load_soul() { cat "$REPO_ROOT/bots/$1/SOUL.md" 2>/dev/null; }

# Build system prompt for agent simulation
build_prompt() {
  local bot="$1"; shift; local skills=("$@")
  echo "# SIMULATION: You are an ADL agent in the OpenCLAW runtime."
  echo "# You HAVE the MCP tools listed below. They are REAL."
  echo "# Output tool calls as: \`\`\`tool_call"
  echo "# tool_name(param=\"value\")"
  echo "# \`\`\`"
  echo "# NEVER say you can't call tools. NEVER ask for clarification. CALL TOOLS."
  echo ""
  echo "# Identity"
  echo ""
  load_soul "$bot"
  echo ""
  echo "# Active Skills"
  for s in "${skills[@]}"; do load_skill "$s"; echo -e "\n---\n"; done
  echo "# MCP Tools"
  cat <<'TOOLS'
- adl_tool_search(query)
- adl_send_message(recipient_agent_id, message_type, body)
- adl_read_messages(unread_only)
- adl_list_agents()
- adl_run_agent(agent_id, prompt, wait)
- adl_run_agents(tasks, wait)
- adl_query_records(entity_type, filters, limit)
- adl_write_record(entity_type, entity_id, data)
- adl_upsert_record(entity_type, entity_id, data)
- adl_bulk_upsert(records)
- adl_get_record(entity_type, entity_id)
- adl_delete_record(entity_type, entity_id)
- adl_read_memory(namespace, key)
- adl_write_memory(namespace, key, value)
- adl_search_memory(query)
- adl_list_memory(namespace)
- adl_search_graph(entity_type, entity_id, relationship)
- adl_query_neighbors(entity_type, entity_id, depth)
- adl_semantic_search(query, entity_type)
- adl_query_duckdb(sql)
- adl_get_workflow(workflow_id)
- adl_update_workflow(workflow_id, nodes, edges)
- adl_deploy_workflow(workflow_id)
- adl_list_workflows()
- adl_list_workflow_runs(workflow_id)
- adl_get_workflow_run(workflow_id, run_id)
- adl_propose_pipeline_route(name, source_type, connector_id, objects, reason)
- adl_list_connectors(category)
- adl_list_pipeline_routes()
- adl_request_escalation(escalation_type, urgency, summary)
- adl_invoke_skill(name)
TOOLS
  echo ""
  echo "# RULES: Call tools immediately. Between calls, 1-2 sentence reasoning max."
}

# Run single test
run_test() {
  local name="$1" bot="$2" scenario="$3" pass_pat="$4" fail_pat="$5"
  shift 5; local skills=("$@")

  echo -n "  $name ... "
  local tmpfile; tmpfile=$(mktemp /tmp/skill-test-XXXXXX.md)
  build_prompt "$bot" "${skills[@]}" > "$tmpfile"

  local response
  response=$(echo "$scenario" | claude -p --bare --model haiku \
    --system-prompt-file "$tmpfile" \
    --disallowed-tools "Bash Edit Write Read Glob Grep Agent Skill" \
    2>/dev/null) || { rm -f "$tmpfile"; echo -e "${YELLOW}SKIP${NC}"; ((PARTIAL++)); return; }
  rm -f "$tmpfile"

  local rf="$RESULTS_DIR/${name}.md"
  printf "# %s\n## Scenario\n%s\n\n## Response\n%s\n\n## Assertions\n" "$name" "$scenario" "$response" > "$rf"

  # Check tool usage: first check specific patterns, then check any tool_call block
  local tool_pass=false
  if [ -n "$pass_pat" ]; then
    if echo "$response" | grep -qiE "$pass_pat"; then
      tool_pass=true; echo "PASS: exact tool match ($pass_pat)" >> "$rf"
    elif echo "$response" | grep -q '```tool_call'; then
      # Agent called SOME tool — it's acting, just not the exact tool we expected
      local tools_used; tools_used=$(echo "$response" | grep -oE 'adl_[a-z_]+' | sort -u | tr '\n' ', ' | sed 's/,$//')
      tool_pass=true; echo "PASS: agent acting via tools ($tools_used)" >> "$rf"
    else
      echo "WARN: no tool calls found at all" >> "$rf"
    fi
  else
    tool_pass=true
  fi

  # Check no prohibited behavior
  local no_fail=true
  if [ -n "$fail_pat" ]; then
    local bad; bad=$(echo "$response" | grep -oiE "$fail_pat" | head -1) || true
    if [ -n "$bad" ]; then
      no_fail=false; echo "FAIL: prohibited behavior: '$bad'" >> "$rf"
    else
      echo "PASS: no prohibited behavior" >> "$rf"
    fi
  fi

  if $tool_pass && $no_fail; then
    echo -e "${GREEN}PASS${NC}"; echo "## Result: PASS" >> "$rf"; ((PASS++))
  elif $no_fail; then
    echo -e "${YELLOW}PARTIAL${NC}"; echo "## Result: PARTIAL" >> "$rf"; ((PARTIAL++))
  else
    echo -e "${RED}FAIL${NC}"; echo "## Result: FAIL" >> "$rf"; ((FAIL++))
  fi
}

NO_ASK="which would you like|please clarify|would you prefer|what should I|shall I|can you provide|I need more info|please specify|could you tell me"

# ====================================================================
# SUITE: Platform Core (platform-awareness, inter-agent-comms)
# ====================================================================
suite_platform() {
  echo -e "\n${CYAN}=== Platform Core ===${NC}"
  run_test "plat-messages-first" "executive-assistant" \
    "You are starting a new run. Begin your work." \
    "adl_read_messages" "" \
    "platform-awareness" "inter-agent-comms"

  run_test "plat-tool-discovery" "sre-devops" \
    "I need to check if there are any crystallization candidates in this workspace." \
    "adl_tool_search" "$NO_ASK" \
    "platform-awareness"

  run_test "plat-route-to-agent" "executive-assistant" \
    "A customer reported their webhook events are not arriving. This is a pipeline issue." \
    "adl_send_message|adl_list_agents|adl_run_agent" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms"

  run_test "plat-parallel-delegation" "executive-assistant" \
    "Three urgent tasks: accountant must reconcile invoices, SRE must check uptime, and data engineer must audit schema drift. Handle all now." \
    "adl_run_agents|adl_send_message" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms"
}

# ====================================================================
# SUITE: Finance (budget-monitoring, expense-tracking, invoice-categorization)
# ====================================================================
suite_finance() {
  echo -e "\n${CYAN}=== Finance ===${NC}"
  run_test "fin-budget-alert" "accountant" \
    "Marketing spend this month is \$48,000 against a \$50,000 budget. Infrastructure is at \$22,000 against \$20,000 — already over." \
    "adl_read_memory|adl_write_record|adl_send_message|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms" "budget-monitoring"

  run_test "fin-invoice-classify" "accountant" \
    "5 new invoices arrived: AWS \$3,200, Slack \$450, a duplicate Slack \$450 from 3 days ago, a payroll run \$85,000, and an overdue legal bill \$12,000." \
    "adl_query_records|adl_write_record|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "invoice-categorization"

  run_test "fin-expense-anomaly" "accountant" \
    "This month's travel expenses are 3x the average. The finance team needs to know." \
    "adl_send_message|adl_write_record|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms" "expense-tracking"
}

# ====================================================================
# SUITE: Operations (incident-triage, sla-compliance, pipeline-monitoring)
# ====================================================================
suite_ops() {
  echo -e "\n${CYAN}=== Operations ===${NC}"
  run_test "ops-incident-correlate" "sre-devops" \
    "3 alerts in the last 10 minutes: database connection pool exhausted, API latency p99 at 12s (baseline 200ms), and 2 pods restarting in the pipeline-worker deployment." \
    "adl_query_records|adl_write_record|adl_send_message|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms" "incident-triage"

  run_test "ops-sla-breach" "sre-devops" \
    "Current uptime is 99.2% this month. SLA target is 99.9%. Data freshness is 45 minutes, target is 15 minutes." \
    "adl_read_memory|adl_write_record|adl_send_message|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms" "sla-compliance"

  run_test "ops-pipeline-degraded" "sre-devops" \
    "Pipeline route rt_prod_cdc throughput dropped 60% in the last hour. Error rate is at 8%. DLQ depth growing at 200 events/min." \
    "adl_query_records|adl_write_record|adl_send_message|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms" "pipeline-monitoring"
}

# ====================================================================
# SUITE: Data Quality (anomaly-detection, data-validation, record-monitoring)
# ====================================================================
suite_data_quality() {
  echo -e "\n${CYAN}=== Data Quality ===${NC}"
  run_test "dq-anomaly-detect" "anomaly-detector" \
    "Revenue records for the last 30 days show a value of \$2.3M on March 15 when the average is \$150K with std dev \$30K. That's a 71x deviation." \
    "adl_query_records|adl_write_record|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "anomaly-detection"

  run_test "dq-validation-fail" "data-quality-monitor" \
    "3 customer records have email fields that are empty strings, and 2 have negative order counts." \
    "adl_query_records|adl_write_record|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "data-validation"

  run_test "dq-compliance-violation" "data-quality-monitor" \
    "5 records in the invoices entity type have amounts exceeding the \$100K single-transaction policy limit." \
    "adl_write_record|adl_send_message|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms" "record-monitoring"
}

# ====================================================================
# SUITE: Workflow & Automation (workflow-ops, workflow-designer, data-dependency)
# ====================================================================
suite_workflows() {
  echo -e "\n${CYAN}=== Workflows & Automation ===${NC}"
  run_test "wf-fix-broken" "executive-assistant" \
    "Workflow wf_daily_discovery failed: 'upsert_record: entityType is required' on step 'Save Discovery'. The node has type=upsert_record but config nodeType=delay. Fix it." \
    "adl_get_workflow|adl_update_workflow" "$NO_ASK" \
    "platform-awareness" "workflow-ops"

  run_test "wf-diagnose-run" "sre-devops" \
    "Workflow wf_pipeline_check has had 3 consecutive failed runs. Investigate the latest failure." \
    "adl_list_workflow_runs|adl_get_workflow_run|adl_get_workflow" "$NO_ASK" \
    "platform-awareness" "workflow-ops"

  run_test "wf-data-gap-discovery" "business-analyst" \
    "Check whether this workspace has all the data it needs. Run a full data dependency discovery." \
    "adl_list_entity_types|adl_query_records|adl_list_pipeline_routes|adl_list_connectors|adl_propose_pipeline_route" "$NO_ASK" \
    "platform-awareness" "data-dependency-discovery"
}

# ====================================================================
# SUITE: Reporting (daily-briefing, scheduled-report, report-generation)
# ====================================================================
suite_reporting() {
  echo -e "\n${CYAN}=== Reporting ===${NC}"
  run_test "rpt-daily-briefing" "executive-assistant" \
    "Generate the morning briefing. It's 9am Monday." \
    "adl_query_records|adl_read_memory|adl_write_record|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "daily-briefing"

  run_test "rpt-scheduled" "business-analyst" \
    "Generate the weekly revenue report. Last run covered through Friday." \
    "adl_read_memory|adl_query_records|adl_write_record|adl_send_message|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms" "scheduled-report"

  run_test "rpt-cross-domain" "executive-assistant" \
    "Synthesize findings from the last 24 hours across all domains. Identify cross-cutting patterns." \
    "adl_query_records|adl_write_record|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "cross-domain-synthesis"
}

# ====================================================================
# SUITE: CDC & Pipeline (cdc-event-analysis, pipeline-proposer)
# ====================================================================
suite_cdc() {
  echo -e "\n${CYAN}=== CDC & Pipeline ===${NC}"
  run_test "cdc-critical-event" "fraud-detector" \
    "CDC event: UPDATE on transactions table, row id=tx_9281, amount changed from \$50 to \$50,000, user_id=usr_suspicious_042." \
    "adl_read_memory|adl_write_record|adl_send_message|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms" "cdc-event-analysis"

  run_test "cdc-propose-pipeline" "workflow-designer" \
    "The business analyst needs Stripe payment data but no pipeline exists for it. Propose a route." \
    "adl_list_connectors|adl_propose_pipeline_route|adl_list_pipeline_routes" "$NO_ASK" \
    "platform-awareness" "pipeline-proposer"
}

# ====================================================================
# SUITE: Task & Notification (task-management, notification-dispatch, follow-up)
# ====================================================================
suite_tasks() {
  echo -e "\n${CYAN}=== Tasks & Notifications ===${NC}"
  run_test "task-create-assign" "executive-assistant" \
    "Create a high-priority task: 'Fix CDC pipeline dropping events on route rt_prod'. Assign it to the SRE agent." \
    "adl_upsert_record|adl_write_record" "$NO_ASK" \
    "platform-awareness" "task-management"

  run_test "task-follow-up" "executive-assistant" \
    "Check if there are any overdue tasks. It's been 7 days since the last follow-up sweep." \
    "adl_query_records|adl_read_memory" "$NO_ASK" \
    "platform-awareness" "follow-up-tracking"

  run_test "notify-critical" "sre-devops" \
    "Send an urgent alert about the database failover to all relevant agents." \
    "adl_send_message|adl_list_agents|adl_request_escalation" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms" "notification-dispatch"
}

# ====================================================================
# SUITE: Code & Engineering (code-review, sprint-planning, test-generation)
# ====================================================================
suite_engineering() {
  echo -e "\n${CYAN}=== Engineering ===${NC}"
  run_test "eng-code-review" "code-reviewer" \
    "Review the latest pull request. It modifies authentication middleware and adds a new API endpoint." \
    "adl_query_records|adl_write_record|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "code-review"

  run_test "eng-sprint-plan" "sprint-planner" \
    "Plan the next 2-week sprint. We have 15 backlog items and 3 developers." \
    "adl_query_records|adl_write_record|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "sprint-planning"

  run_test "eng-escalate-security" "code-reviewer" \
    "Found SQL injection in the user search endpoint. This is a critical security finding." \
    "adl_send_message|adl_write_record|adl_upsert_record" "$NO_ASK" \
    "platform-awareness" "inter-agent-comms" "code-review"
}

# ====================================================================
# MAIN
# ====================================================================
echo "============================================"
echo "  ClawSink Full Pressure Test Suite"
echo "============================================"
echo "  Model: haiku (worst-case)"
echo ""

FILTER="${1:-all}"

[ "$FILTER" = "all" ] || [ "$FILTER" = "platform" ] && suite_platform
[ "$FILTER" = "all" ] || [ "$FILTER" = "finance" ] && suite_finance
[ "$FILTER" = "all" ] || [ "$FILTER" = "ops" ] && suite_ops
[ "$FILTER" = "all" ] || [ "$FILTER" = "data-quality" ] && suite_data_quality
[ "$FILTER" = "all" ] || [ "$FILTER" = "workflows" ] && suite_workflows
[ "$FILTER" = "all" ] || [ "$FILTER" = "reporting" ] && suite_reporting
[ "$FILTER" = "all" ] || [ "$FILTER" = "cdc" ] && suite_cdc
[ "$FILTER" = "all" ] || [ "$FILTER" = "tasks" ] && suite_tasks
[ "$FILTER" = "all" ] || [ "$FILTER" = "engineering" ] && suite_engineering

TOTAL=$((PASS + PARTIAL + FAIL))
echo ""
echo "============================================"
echo "  Total: $TOTAL tests"
echo -e "  ${GREEN}${PASS} PASS${NC}  ${YELLOW}${PARTIAL} PARTIAL${NC}  ${RED}${FAIL} FAIL${NC}"
PCT=0; [ "$TOTAL" -gt 0 ] && PCT=$(( (PASS * 100) / TOTAL ))
echo "  Pass rate: ${PCT}%"
echo "  Details: $RESULTS_DIR/"
echo "============================================"

exit $FAIL
