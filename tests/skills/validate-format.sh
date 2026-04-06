#!/usr/bin/env bash
# Layer 3: Skill Format Validation
# Validates all skills in the repo without running any agents.
# Checks:
# 1. SKILL.md exists and has valid YAML frontmatter
# 2. prompt.md exists and is under 200 tokens (~800 chars)
# 3. Required YAML fields present (apiVersion, kind, metadata.name, metadata.description)
# 4. metadata.name matches directory name
# 5. tools.required contains only known ADL tool names
# 6. kind is "Skill"
#
# Usage: ./validate-format.sh [skill-name]
#   No args = validate all skills
#   skill-name = validate specific skill

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

# Known valid tool names (from OpenCLAW runtime tools.go)
# Tools from both MCP server (adl_upsert_record) AND OpenCLAW runtime (adl_write_record)
KNOWN_TOOLS="adl_tool_search adl_send_message adl_read_messages adl_list_agents adl_run_agent adl_run_agents adl_query_records adl_upsert_record adl_write_record adl_get_record adl_bulk_upsert adl_delete_record adl_list_entity_types adl_get_schema adl_read_memory adl_write_memory adl_delete_memory adl_list_memory adl_add_memory adl_search_memory adl_search_graph adl_graph_query adl_query_neighbors adl_semantic_search adl_query_duckdb adl_get_workflow adl_update_workflow adl_deploy_workflow adl_list_workflows adl_list_workflow_runs adl_get_workflow_run adl_create_workflow adl_trigger_workflow adl_create_trigger adl_list_triggers adl_update_trigger adl_delete_trigger adl_propose_pipeline_route adl_propose_crystallization adl_list_connectors adl_list_sink_types adl_list_pipeline_routes adl_list_workspace_sources adl_get_route_status adl_request_escalation adl_invoke_skill adl_execute_skill adl_discover_skills adl_get_context adl_store_secret adl_get_secret adl_proxy_call adl_get_data_stats adl_purge_stale_records adl_purge_memory_namespace adl_get_namespace_stats adl_consolidate_memory adl_set_memory_ttl adl_get_graph_stats adl_purge_orphan_edges adl_scratch_write adl_scratch_read adl_list_crystallization_candidates adl_list_query_patterns"

# Approximate token count (~4 chars per token for English)
estimate_tokens() {
  local file="$1"
  local chars
  chars=$(wc -c < "$file")
  echo $(( chars / 4 ))
}

validate_skill() {
  local skill_dir="$1"
  local skill_name
  skill_name=$(basename "$skill_dir")
  local errors=0

  echo "  $skill_name:"

  # Check SKILL.md exists
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo -e "    ${RED}FAIL${NC} SKILL.md missing"
    ((FAIL++))
    return
  fi

  # Check prompt.md exists
  if [ ! -f "$skill_dir/prompt.md" ]; then
    echo -e "    ${RED}FAIL${NC} prompt.md missing"
    ((FAIL++))
    return
  fi

  # Extract YAML frontmatter from SKILL.md
  local frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" | sed '1d;$d')

  if [ -z "$frontmatter" ]; then
    echo -e "    ${RED}FAIL${NC} No YAML frontmatter in SKILL.md"
    ((FAIL++))
    return
  fi

  # Check kind: Skill
  if ! echo "$frontmatter" | grep -q "^kind: Skill"; then
    echo -e "    ${RED}FAIL${NC} kind must be 'Skill'"
    ((errors++))
  fi

  # Check apiVersion
  if ! echo "$frontmatter" | grep -q "^apiVersion:"; then
    echo -e "    ${RED}FAIL${NC} Missing apiVersion"
    ((errors++))
  fi

  # Check metadata.name exists
  local yaml_name
  yaml_name=$(echo "$frontmatter" | grep "^  name:" | head -1 | sed 's/.*name: *//' | tr -d '"')
  if [ -z "$yaml_name" ]; then
    echo -e "    ${RED}FAIL${NC} Missing metadata.name"
    ((errors++))
  elif [ "$yaml_name" != "$skill_name" ]; then
    echo -e "    ${RED}FAIL${NC} metadata.name '$yaml_name' != directory name '$skill_name'"
    ((errors++))
  fi

  # Check metadata.description
  if ! echo "$frontmatter" | grep -q "description:"; then
    echo -e "    ${RED}FAIL${NC} Missing metadata.description"
    ((errors++))
  fi

  # Check metadata.version
  if ! echo "$frontmatter" | grep -q "version:"; then
    echo -e "    ${YELLOW}WARN${NC} Missing metadata.version"
    ((WARN++))
  fi

  # Validate tools.required against known tools
  local tools_line
  tools_line=$(echo "$frontmatter" | grep "required:" | head -1)
  if [ -n "$tools_line" ]; then
    # Extract tool names from the YAML array
    local tools
    tools=$(echo "$tools_line" | grep -oE '"[a-z_]+"' | tr -d '"')
    for tool in $tools; do
      if ! echo "$KNOWN_TOOLS" | grep -qw "$tool"; then
        echo -e "    ${RED}FAIL${NC} Unknown tool in tools.required: $tool"
        ((errors++))
      fi
    done
  fi

  # Check prompt.md token count
  local tokens
  tokens=$(estimate_tokens "$skill_dir/prompt.md")
  if [ "$tokens" -gt 200 ]; then
    echo -e "    ${YELLOW}WARN${NC} prompt.md ~${tokens} tokens (limit: 200)"
    ((WARN++))
  fi

  # Check prompt.md isn't empty
  local lines
  lines=$(wc -l < "$skill_dir/prompt.md")
  if [ "$lines" -lt 3 ]; then
    echo -e "    ${RED}FAIL${NC} prompt.md too short ($lines lines)"
    ((errors++))
  fi

  if [ "$errors" -eq 0 ]; then
    echo -e "    ${GREEN}PASS${NC} valid (${tokens} tokens)"
    ((PASS++))
  else
    ((FAIL++))
  fi
}

echo "============================================"
echo "  Layer 3: Skill Format Validation"
echo "============================================"
echo ""

FILTER="${1:-all}"

for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")

  if [ "$FILTER" != "all" ] && [ "$FILTER" != "$skill_name" ]; then
    continue
  fi

  validate_skill "$skill_dir"
done

echo ""
echo "============================================"
echo -e "  Results: ${GREEN}${PASS} PASS${NC}  ${YELLOW}${WARN} WARN${NC}  ${RED}${FAIL} FAIL${NC}"
echo "============================================"

exit $FAIL
