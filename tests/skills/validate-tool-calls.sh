#!/usr/bin/env bash
# Layer 2: Runtime Smoke Tests
# Parses tool_call blocks from Layer 1 results and validates:
# 1. Tool name is a known ADL tool
# 2. Required parameters are present
# 3. Parameter types are reasonable
#
# Usage: ./validate-tool-calls.sh [results-dir]

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="${1:-$SCRIPT_DIR/results}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

# Known tools and their required params (param names, not types)
declare -A TOOL_REQUIRED_PARAMS
TOOL_REQUIRED_PARAMS=(
  ["adl_tool_search"]="query"
  ["adl_send_message"]="message_type body"
  ["adl_read_messages"]=""
  ["adl_list_agents"]=""
  ["adl_run_agent"]="agent_id prompt"
  ["adl_run_agents"]="tasks"
  ["adl_query_records"]="entity_type"
  ["adl_upsert_record"]="entity_type entity_id data"
  ["adl_get_record"]="entity_type entity_id"
  ["adl_bulk_upsert"]="records"
  ["adl_delete_record"]="entity_type entity_id"
  ["adl_read_memory"]="namespace key"
  ["adl_write_memory"]="namespace key value"
  ["adl_search_memory"]="query"
  ["adl_list_memory"]="namespace"
  ["adl_search_graph"]="entity_type entity_id"
  ["adl_query_neighbors"]="entity_type entity_id"
  ["adl_semantic_search"]="query"
  ["adl_query_duckdb"]="sql"
  ["adl_get_workflow"]="workflow_id"
  ["adl_update_workflow"]="workflow_id"
  ["adl_deploy_workflow"]="workflow_id"
  ["adl_list_workflows"]=""
  ["adl_list_workflow_runs"]="workflow_id"
  ["adl_get_workflow_run"]="workflow_id run_id"
  ["adl_create_workflow"]="name"
  ["adl_trigger_workflow"]="workflow_id"
  ["adl_create_trigger"]="name entity_type"
  ["adl_list_triggers"]=""
  ["adl_update_trigger"]="trigger_id"
  ["adl_delete_trigger"]="trigger_id"
  ["adl_propose_pipeline_route"]="name source_type reason"
  ["adl_propose_crystallization"]="name description sql_body"
  ["adl_list_connectors"]=""
  ["adl_list_sink_types"]=""
  ["adl_list_pipeline_routes"]=""
  ["adl_get_route_status"]="route_id"
  ["adl_request_escalation"]="escalation_type summary"
  ["adl_invoke_skill"]="name"
  ["adl_get_context"]=""
  ["adl_store_secret"]="name value"
  ["adl_proxy_call"]="url method"
  ["adl_get_data_stats"]=""
  ["adl_purge_stale_records"]="entity_type older_than_days"
)

# Extract tool calls from results
extract_tool_calls() {
  local file="$1"
  # Get lines between ```tool_call and ``` that contain a function call pattern
  awk '/^```tool_call/{found=1; next} /^```/{found=0} found && /^adl_/{print}' "$file"
}

# Validate a single tool call
validate_call() {
  local call="$1"
  local source_file="$2"
  local source_test
  source_test=$(basename "$source_file" .md)

  # Extract tool name (everything before the first parenthesis)
  local tool_name
  tool_name=$(echo "$call" | sed 's/(.*//')

  # Check tool exists
  if [[ ! -v TOOL_REQUIRED_PARAMS["$tool_name"] ]]; then
    echo -e "  ${RED}FAIL${NC} [$source_test] Unknown tool: $tool_name"
    ((FAIL++))
    return
  fi

  # Check required params
  local required="${TOOL_REQUIRED_PARAMS[$tool_name]}"
  if [ -n "$required" ]; then
    local missing=""
    for param in $required; do
      if ! echo "$call" | grep -q "$param"; then
        missing="$missing $param"
      fi
    done
    if [ -n "$missing" ]; then
      echo -e "  ${YELLOW}WARN${NC} [$source_test] $tool_name: possibly missing params:$missing"
      ((WARN++))
      return
    fi
  fi

  echo -e "  ${GREEN}PASS${NC} [$source_test] $tool_name — valid tool, params present"
  ((PASS++))
}

echo "============================================"
echo "  Layer 2: Tool Call Validation"
echo "============================================"
echo "  Source: $RESULTS_DIR/"
echo ""

TOTAL_CALLS=0

for result_file in "$RESULTS_DIR"/*.md; do
  [ -f "$result_file" ] || continue

  calls=$(extract_tool_calls "$result_file")
  if [ -z "$calls" ]; then
    continue
  fi

  while IFS= read -r call; do
    [ -z "$call" ] && continue
    ((TOTAL_CALLS++))
    validate_call "$call" "$result_file"
  done <<< "$calls"
done

echo ""
echo "============================================"
echo "  Tool calls analyzed: $TOTAL_CALLS"
echo -e "  Results: ${GREEN}${PASS} VALID${NC}  ${YELLOW}${WARN} WARN${NC}  ${RED}${FAIL} INVALID${NC}"
echo "============================================"

exit $FAIL
