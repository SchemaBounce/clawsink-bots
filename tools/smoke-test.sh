#!/usr/bin/env bash
# smoke-test.sh — Smoke test all stdio MCP servers in the tools/ directory
#
# Sends a JSON-RPC initialize request to each stdio server and verifies
# the response contains serverInfo.
#
# Usage:
#   ./smoke-test.sh                         # Test all stdio servers
#   ./smoke-test.sh --server github         # Test only the github server
#   ./smoke-test.sh --with-tools-list       # Also send tools/list after init
#   ./smoke-test.sh --server slack --with-tools-list

set -euo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Constants ────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMEOUT_SECONDS=30

INIT_REQUEST='{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"smoke-test","version":"1.0"}},"id":1}'
INIT_NOTIFICATION='{"jsonrpc":"2.0","method":"notifications/initialized"}'
TOOLS_LIST_REQUEST='{"jsonrpc":"2.0","method":"tools/list","params":{},"id":2}'

# ── Flags ────────────────────────────────────────────────────────────────────
WITH_TOOLS_LIST=false
FILTER_SERVER=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --with-tools-list)
            WITH_TOOLS_LIST=true
            shift
            ;;
        --server)
            FILTER_SERVER="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [--server <name>] [--with-tools-list]"
            echo ""
            echo "Options:"
            echo "  --server <name>      Test only the named server (e.g. github, slack)"
            echo "  --with-tools-list    Also send tools/list request after initialize"
            echo "  -h, --help           Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# ── Counters ─────────────────────────────────────────────────────────────────
PASSED=0
FAILED=0
SKIPPED=0
RESULTS=()

# ── Helpers ──────────────────────────────────────────────────────────────────

# Extract a YAML value from frontmatter. Handles both quoted and unquoted values.
# Usage: yaml_val "key" < file_contents
yaml_val() {
    local key="$1"
    # Match key: "value" or key: value or key: 'value'
    sed -n "s/^[[:space:]]*${key}:[[:space:]]*\"\{0,1\}\([^\"]*\)\"\{0,1\}[[:space:]]*$/\1/p" | head -1
}

# Extract a YAML array value (simple inline arrays only).
# Input: args: ["-y", "@modelcontextprotocol/server-github"]
# Output: -y @modelcontextprotocol/server-github (one per line, quotes stripped)
yaml_array() {
    local key="$1"
    sed -n "s/^[[:space:]]*${key}:[[:space:]]*\[//p" | tr -d ']' | tr ',' '\n' | sed 's/^[[:space:]]*"//; s/"[[:space:]]*$//; s/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v '^$'
}

# Extract required env var names from frontmatter
# Looks for patterns like:
#   - name: FOO
#     ...
#     required: true
extract_required_envs() {
    local file="$1"
    # Parse the frontmatter between --- markers
    local in_env=false
    local current_name=""
    local current_required=""
    local flushed_final=false

    while IFS= read -r line; do
        # Detect env: section start (also handles env: [])
        if [[ "$line" =~ ^env:[[:space:]]*\[\] ]]; then
            # Empty env list — nothing to extract
            return
        fi
        if [[ "$line" =~ ^env: ]]; then
            in_env=true
            continue
        fi
        # If we hit a top-level key (not indented), exit env section
        if $in_env && [[ "$line" =~ ^[a-z] ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
            # Flush last entry
            if [[ -n "$current_name" && "$current_required" == "true" ]]; then
                echo "$current_name"
            fi
            flushed_final=true
            break
        fi
        if $in_env; then
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*(.*) ]]; then
                # Flush previous entry
                if [[ -n "$current_name" && "$current_required" == "true" ]]; then
                    echo "$current_name"
                fi
                current_name="${BASH_REMATCH[1]}"
                current_name="${current_name%\"}"
                current_name="${current_name#\"}"
                current_name="$(echo "$current_name" | xargs)"
                current_required=""
            elif [[ "$line" =~ required:[[:space:]]*(true|false) ]]; then
                current_required="${BASH_REMATCH[1]}"
            fi
        fi
    done < <(sed -n '/^---$/,/^---$/p' "$file")

    # Flush final entry (only if not already flushed by the break above)
    if ! $flushed_final && [[ -n "$current_name" && "$current_required" == "true" ]]; then
        echo "$current_name"
    fi
}

# ── Main loop ────────────────────────────────────────────────────────────────

echo -e "${BOLD}MCP Server Smoke Test${RESET}"
echo -e "${DIM}Timeout: ${TIMEOUT_SECONDS}s per server${RESET}"
echo ""

for server_dir in "$SCRIPT_DIR"/*/; do
    # Skip non-directories and special dirs
    [[ ! -d "$server_dir" ]] && continue

    server_name="$(basename "$server_dir")"
    server_md="${server_dir}SERVER.md"

    # Skip if no SERVER.md
    [[ ! -f "$server_md" ]] && continue

    # Filter by --server if specified
    if [[ -n "$FILTER_SERVER" && "$server_name" != "$FILTER_SERVER" ]]; then
        continue
    fi

    # ── Parse frontmatter ────────────────────────────────────────────────
    frontmatter="$(sed -n '/^---$/,/^---$/p' "$server_md")"

    transport_type="$(echo "$frontmatter" | yaml_val "type")"
    command="$(echo "$frontmatter" | yaml_val "command")"
    display_name="$(echo "$frontmatter" | yaml_val "displayName")"

    # Read args array
    mapfile -t args_array < <(echo "$frontmatter" | yaml_array "args")

    # ── Skip non-stdio servers ───────────────────────────────────────────
    if [[ "$transport_type" != "stdio" ]]; then
        echo -e "  ${YELLOW}SKIP${RESET}  ${BOLD}${display_name:-$server_name}${RESET} ${DIM}(transport: ${transport_type})${RESET}"
        SKIPPED=$((SKIPPED + 1))
        RESULTS+=("SKIP|${display_name:-$server_name}|transport: ${transport_type}")
        continue
    fi

    # ── Check required env vars ──────────────────────────────────────────
    mapfile -t required_envs < <(extract_required_envs "$server_md")
    missing_envs=()
    for env_name in "${required_envs[@]}"; do
        [[ -z "$env_name" ]] && continue
        if [[ -z "${!env_name:-}" ]]; then
            missing_envs+=("$env_name")
        fi
    done

    # ── Build the command ────────────────────────────────────────────────
    if [[ -z "$command" ]]; then
        echo -e "  ${RED}FAIL${RESET}  ${BOLD}${display_name:-$server_name}${RESET} ${DIM}(no command in SERVER.md)${RESET}"
        FAILED=$((FAILED + 1))
        RESULTS+=("FAIL|${display_name:-$server_name}|no command in SERVER.md")
        continue
    fi

    # Check that the command is available
    if ! command -v "$command" &>/dev/null; then
        echo -e "  ${RED}FAIL${RESET}  ${BOLD}${display_name:-$server_name}${RESET} ${DIM}(${command} not found in PATH)${RESET}"
        FAILED=$((FAILED + 1))
        RESULTS+=("FAIL|${display_name:-$server_name}|${command} not found in PATH")
        continue
    fi

    # ── Run the server ───────────────────────────────────────────────────
    tmpdir="$(mktemp -d)"
    stdout_file="${tmpdir}/stdout"
    stderr_file="${tmpdir}/stderr"
    pid_file="${tmpdir}/pid"

    # Build stdin: init request + newline + initialized notification + newline
    stdin_payload="${INIT_REQUEST}"$'\n'"${INIT_NOTIFICATION}"$'\n'
    if $WITH_TOOLS_LIST; then
        stdin_payload="${stdin_payload}${TOOLS_LIST_REQUEST}"$'\n'
    fi

    # Launch server with timeout, feeding stdin and capturing output
    # We use a subshell + timeout to handle servers that hang
    (
        echo "$stdin_payload" | timeout "${TIMEOUT_SECONDS}" "$command" "${args_array[@]}" \
            >"$stdout_file" 2>"$stderr_file"
    ) &
    bg_pid=$!
    echo "$bg_pid" > "$pid_file"

    # Wait for the background process (with our own timeout as safety net)
    wait_result=0
    wait "$bg_pid" 2>/dev/null || wait_result=$?

    # Read output
    server_stdout=""
    server_stderr=""
    [[ -f "$stdout_file" ]] && server_stdout="$(cat "$stdout_file" 2>/dev/null || true)"
    [[ -f "$stderr_file" ]] && server_stderr="$(cat "$stderr_file" 2>/dev/null || true)"

    # ── Analyze response ─────────────────────────────────────────────────
    # The server may output multiple JSON-RPC responses (one per line or concatenated).
    # We look for serverInfo in the initialize response.
    init_ok=false
    tools_ok=false
    tool_count=""
    error_detail=""

    if [[ -n "$server_stdout" ]]; then
        # Check for serverInfo in any line
        if echo "$server_stdout" | grep -q '"serverInfo"'; then
            init_ok=true
        fi

        if $WITH_TOOLS_LIST; then
            # Check for tools array in the response
            if echo "$server_stdout" | grep -q '"tools"'; then
                tools_ok=true
                # Try to count tools — look for the tools/list response
                # Extract the number of tool objects (rough count via "name" keys in tools array)
                tool_count="$(echo "$server_stdout" | grep -o '"name"' | wc -l || true)"
                # Subtract 1 for the serverInfo.name field in the init response
                if [[ "$tool_count" -gt 0 ]]; then
                    tool_count=$((tool_count - 1))
                fi
            fi
        fi
    fi

    # Determine failure reason
    if ! $init_ok; then
        if [[ ${#missing_envs[@]} -gt 0 ]]; then
            error_detail="missing env: ${missing_envs[*]}"
        elif [[ $wait_result -eq 124 ]]; then
            error_detail="timeout after ${TIMEOUT_SECONDS}s"
        elif [[ -n "$server_stderr" ]]; then
            # Grab last meaningful line of stderr
            error_detail="$(echo "$server_stderr" | grep -v '^$' | tail -1 | head -c 120)"
        else
            error_detail="no serverInfo in response"
        fi
    fi

    # ── Report ───────────────────────────────────────────────────────────
    if $init_ok; then
        status_line="  ${GREEN}PASS${RESET}  ${BOLD}$(printf '%-30s' "${display_name:-$server_name}")${RESET}"

        if $WITH_TOOLS_LIST; then
            if $tools_ok; then
                status_line="${status_line} ${DIM}(init OK, tools/list OK"
                if [[ -n "$tool_count" && "$tool_count" -gt 0 ]]; then
                    status_line="${status_line} — ${tool_count} tools"
                fi
                status_line="${status_line})${RESET}"
            else
                status_line="${status_line} ${YELLOW}(init OK, tools/list FAILED)${RESET}"
            fi
        else
            status_line="${status_line} ${DIM}(init OK)${RESET}"
        fi

        echo -e "$status_line"
        PASSED=$((PASSED + 1))
        RESULTS+=("PASS|${display_name:-$server_name}|init OK")
    else
        echo -e "  ${RED}FAIL${RESET}  ${BOLD}$(printf '%-30s' "${display_name:-$server_name}")${RESET} ${DIM}(${error_detail})${RESET}"
        FAILED=$((FAILED + 1))
        RESULTS+=("FAIL|${display_name:-$server_name}|${error_detail}")
    fi

    # Cleanup
    rm -rf "$tmpdir"
done

# ── Handle --server filter with no match ─────────────────────────────────────
if [[ -n "$FILTER_SERVER" && $PASSED -eq 0 && $FAILED -eq 0 && $SKIPPED -eq 0 ]]; then
    echo -e "${RED}No server found matching '${FILTER_SERVER}'${RESET}"
    echo ""
    echo "Available servers:"
    for d in "$SCRIPT_DIR"/*/; do
        [[ -f "${d}SERVER.md" ]] && echo "  $(basename "$d")"
    done
    exit 1
fi

# ── Summary ──────────────────────────────────────────────────────────────────
TOTAL=$((PASSED + FAILED + SKIPPED))
echo ""
echo -e "${BOLD}Summary${RESET}"
echo -e "  Total:   ${TOTAL}"
echo -e "  ${GREEN}Passed:  ${PASSED}${RESET}"
echo -e "  ${RED}Failed:  ${FAILED}${RESET}"
echo -e "  ${YELLOW}Skipped: ${SKIPPED}${RESET}"

if [[ $FAILED -gt 0 ]]; then
    echo ""
    echo -e "${BOLD}Failed servers:${RESET}"
    for result in "${RESULTS[@]}"; do
        IFS='|' read -r status name detail <<< "$result"
        if [[ "$status" == "FAIL" ]]; then
            echo -e "  ${RED}*${RESET} ${name}: ${detail}"
        fi
    done
    exit 1
fi

exit 0
