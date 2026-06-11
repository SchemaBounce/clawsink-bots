#!/usr/bin/env bash
# SERVER.md / server.json Manifest Validator for tools/**
#
# Mirrors the contract enforced by core-api's clawsink.ParseMcpServerDef
# (schemabounce-api/internal/clawsink/parsing.go + types.go).
#
# Checks:
#   1.  SERVER.md exists and has valid YAML frontmatter
#   2.  Required top-level fields: apiVersion, kind, metadata, transport
#   3.  kind == "McpServer"
#   4.  metadata.name, displayName, version, description are non-empty
#   5.  metadata.name matches the directory name
#   6.  transport.type is one of: stdio | sse | streamable-http
#   7.  transport shape: stdio requires command (npm/pypi) or repo+ref+asset (github);
#       remote (sse/streamable-http) requires url
#   8.  env entries: name non-empty; required/sensitive are booleans when present
#   9.  tools entries: name non-empty; tool names unique within server
#   10. auth block: type+token_env constraints (mirrors validateMcpAuth)
#   11. validation block: must declare request (HTTP) OR tool (stdio), not both/neither
#       validation.request.url must be https:// or {template}
#       validation.request.method must be a standard HTTP verb
#       on_status state values must be: connected | needs_setup | failed | unverified
#   12. healthProbe block: same rules as validation + interval_seconds >= 30
#   13. network block: scope must be a known value; restricted/private-network require
#       allowedDomains; private-network is forbidden on npm/pypi packageType
#
# Usage:
#   ./tests/tools/validate-manifest.sh               # validate all tools/**
#   ./tests/tools/validate-manifest.sh /tmp/badtool  # validate a specific tools dir

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TOOLS_DIR="${1:-$REPO_ROOT/tools}"

python3 - "$TOOLS_DIR" << 'PYEOF'
import sys
import os

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML is required. Install with: pip3 install pyyaml")
    sys.exit(1)

TOOLS_DIR = sys.argv[1]

RED    = "\033[0;31m"
GREEN  = "\033[0;32m"
YELLOW = "\033[1;33m"
NC     = "\033[0m"

PASS_COUNT = 0
FAIL_COUNT = 0
WARN_COUNT = 0


def extract_frontmatter(content):
    """Extract YAML between opening --- and next line-anchored ---.

    Mirrors ExtractFrontmatter in parsing.go: the closing delimiter must be
    anchored at the start of a line (preceded by a newline) to avoid false
    matches on indented --- inside multi-line YAML scalar blocks.
    """
    if not content.startswith("---"):
        return None, "SERVER.md missing YAML frontmatter (no opening ---)"
    # Strip the opening "---" and its trailing newline.
    tail = content[3:]
    if tail.startswith("\r\n"):
        tail = tail[2:]
    elif tail.startswith("\n") or tail.startswith("\r"):
        tail = tail[1:]
    # Find closing --- anchored at a line start.
    for sep in ("\n---\n", "\n---\r\n", "\n---"):
        idx = tail.find(sep)
        if idx < 0:
            continue
        # Bare "\n---" is only valid at EOF.
        if sep == "\n---" and idx + len(sep) != len(tail):
            continue
        return tail[:idx + 1], None
    return None, "SERVER.md missing closing --- delimiter"


def validate_server(tool_name, server_path):
    global PASS_COUNT, FAIL_COUNT, WARN_COUNT
    errors = []
    warnings = []

    if not os.path.isfile(server_path):
        print(f"  {RED}FAIL{NC} [{tool_name}] SERVER.md not found at {server_path}")
        FAIL_COUNT += 1
        return

    with open(server_path, "r", encoding="utf-8") as fh:
        content = fh.read()

    fm_text, err = extract_frontmatter(content)
    if err:
        print(f"  {RED}FAIL{NC} [{tool_name}] {err}")
        FAIL_COUNT += 1
        return

    try:
        fm = yaml.safe_load(fm_text)
    except yaml.YAMLError as exc:
        print(f"  {RED}FAIL{NC} [{tool_name}] YAML parse error: {exc}")
        FAIL_COUNT += 1
        return

    if not isinstance(fm, dict):
        print(f"  {RED}FAIL{NC} [{tool_name}] frontmatter did not parse to a YAML mapping")
        FAIL_COUNT += 1
        return

    # ── 1. Required top-level fields ─────────────────────────────────────────
    for field in ("apiVersion", "kind", "metadata", "transport"):
        if not fm.get(field):
            errors.append(f"missing required field: {field}")

    # ── 2. kind ───────────────────────────────────────────────────────────────
    kind = fm.get("kind", "")
    if kind and kind != "McpServer":
        errors.append(f"kind is {kind!r}, expected 'McpServer'")

    # ── 3. metadata block ────────────────────────────────────────────────────
    meta = fm.get("metadata") or {}
    if isinstance(meta, dict):
        for mfield in ("name", "displayName", "version", "description"):
            if not meta.get(mfield):
                errors.append(f"metadata.{mfield} is missing or empty")
        meta_name = meta.get("name", "")
        if meta_name and meta_name != tool_name:
            errors.append(
                f"metadata.name {meta_name!r} does not match directory name {tool_name!r}"
            )
    else:
        errors.append("metadata must be a YAML mapping")

    # ── 4. transport block ───────────────────────────────────────────────────
    transport = fm.get("transport") or {}
    if isinstance(transport, dict):
        t_type = transport.get("type", "")
        valid_types = {"stdio", "sse", "streamable-http"}
        if not t_type:
            errors.append("transport.type is missing or empty")
        elif t_type not in valid_types:
            errors.append(
                f"transport.type {t_type!r} is not one of: {', '.join(sorted(valid_types))}"
            )
        else:
            if t_type == "stdio":
                pkg = transport.get("packageType", "")
                if pkg == "github":
                    for gf in ("repo", "ref", "asset"):
                        if not transport.get(gf):
                            errors.append(
                                f"transport.{gf} is required for packageType=github"
                            )
                else:
                    # npm / pypi / unspecified: command is required
                    if not transport.get("command"):
                        errors.append(
                            "transport.command is required for stdio transport "
                            "(npm/pypi or unspecified packageType)"
                        )
            else:
                # sse / streamable-http
                if not transport.get("url"):
                    errors.append(
                        f"transport.url is required for transport.type={t_type!r}"
                    )
    else:
        errors.append("transport must be a YAML mapping")

    # ── 5. env entries ───────────────────────────────────────────────────────
    env_list = fm.get("env") or []
    if env_list:
        if not isinstance(env_list, list):
            errors.append("env must be a YAML sequence")
        else:
            for i, entry in enumerate(env_list):
                if not isinstance(entry, dict):
                    errors.append(f"env[{i}] must be a YAML mapping")
                    continue
                if not entry.get("name"):
                    errors.append(f"env[{i}].name is missing or empty")
                for bfield in ("required", "sensitive"):
                    val = entry.get(bfield)
                    if val is not None and not isinstance(val, bool):
                        errors.append(
                            f"env[{i}].{bfield} must be a boolean "
                            f"(got {type(val).__name__}: {val!r})"
                        )

    # ── 6. tools entries — names unique within server ────────────────────────
    tools_list = fm.get("tools") or []
    if tools_list:
        if not isinstance(tools_list, list):
            errors.append("tools must be a YAML sequence")
        else:
            seen: dict = {}
            for i, t in enumerate(tools_list):
                if not isinstance(t, dict):
                    errors.append(f"tools[{i}] must be a YAML mapping")
                    continue
                tname = t.get("name", "")
                if not tname:
                    errors.append(f"tools[{i}].name is missing or empty")
                elif tname in seen:
                    errors.append(
                        f"duplicate tool name {tname!r} "
                        f"(at index {seen[tname]} and {i})"
                    )
                else:
                    seen[tname] = i

    # ── 7. auth block (optional) ─────────────────────────────────────────────
    auth = fm.get("auth")
    if auth is not None:
        if isinstance(auth, dict):
            has_type = bool(auth.get("type"))
            has_injection = isinstance(auth.get("injection"), dict)
            if has_type and has_injection:
                errors.append(
                    "auth: set EITHER 'type' OR 'injection', not both"
                )
            elif has_type:
                atype = auth["type"]
                valid_auth = {"http_bearer", "http_basic", "api_key_header", "none"}
                if atype not in valid_auth:
                    errors.append(
                        f"auth.type {atype!r} is not one of: "
                        f"{', '.join(sorted(valid_auth))}"
                    )
                elif atype in ("http_bearer", "api_key_header"):
                    if not auth.get("token_env"):
                        errors.append(
                            f"auth.type={atype!r} requires 'token_env'"
                        )
                elif atype == "http_basic":
                    has_single = bool(auth.get("token_env"))
                    has_pair = (
                        bool(auth.get("username_env")) or bool(auth.get("password_env"))
                    )
                    if not has_single and not has_pair:
                        errors.append(
                            "auth.type=http_basic requires 'token_env' "
                            "or 'username_env'+'password_env'"
                        )
            elif has_injection:
                inj = auth["injection"]
                if not inj.get("header_name"):
                    errors.append("auth.injection.header_name is required")
                if not inj.get("header_template"):
                    errors.append("auth.injection.header_template is required")

    # ── 8. validation block (optional) ──────────────────────────────────────
    def check_request_block(req, block):
        errs = []
        url = req.get("url", "") if isinstance(req, dict) else ""
        if url:
            if not (url.startswith("https://") or url.startswith("{")):
                errs.append(
                    f"{block}.request.url must start with https:// or "
                    f"{{{{template}}}} (got {url!r}) — credentials over plain "
                    f"http violate RULE 13 TLS-in-transit"
                )
            elif url.startswith("{") and "}" not in url:
                errs.append(
                    f"{block}.request.url has unclosed {{{{template}}}} "
                    f"placeholder (got {url!r})"
                )
        method = req.get("method", "") if isinstance(req, dict) else ""
        if method:
            valid_methods = {"GET", "POST", "PUT", "DELETE", "PATCH", "HEAD"}
            if method.upper() not in valid_methods:
                errs.append(
                    f"{block}.request.method {method!r} is not a supported HTTP verb"
                )
        on_status = (req.get("on_status") or {}) if isinstance(req, dict) else {}
        # on_status may live on the parent block, not on request — check parent too
        return errs

    def check_on_status(on_status, block):
        errs = []
        valid_states = {"connected", "needs_setup", "failed", "unverified"}
        if isinstance(on_status, dict):
            for code, outcome in on_status.items():
                if isinstance(outcome, dict):
                    state = outcome.get("state", "")
                    if state and state not in valid_states:
                        errs.append(
                            f"{block}.on_status[{code}].state {state!r} is not "
                            f"one of: {', '.join(sorted(valid_states))}"
                        )
        return errs

    validation = fm.get("validation")
    if validation is not None:
        if isinstance(validation, dict):
            req = validation.get("request") or {}
            tool_v = validation.get("tool") or {}
            has_request = bool(req.get("url") if isinstance(req, dict) else "")
            has_tool_v = bool(
                tool_v.get("name") if isinstance(tool_v, dict) else ""
            )
            if has_request and has_tool_v:
                errors.append(
                    "validation: declare EITHER request (HTTP probe) "
                    "OR tool (stdio), not both"
                )
            elif not has_request and not has_tool_v:
                errors.append(
                    "validation block present but empty — declare "
                    "request (HTTP probe) or tool (stdio MCP call); "
                    "credentials stored without a real check is a false-green"
                )
            elif has_request:
                errors.extend(check_request_block(req, "validation"))
                errors.extend(
                    check_on_status(validation.get("on_status"), "validation")
                )
            elif has_tool_v:
                if not tool_v.get("name"):
                    errors.append("validation.tool.name is required")

    # ── 9. healthProbe block (optional) ─────────────────────────────────────
    health = fm.get("healthProbe")
    if health is not None:
        if isinstance(health, dict):
            req = health.get("request") or {}
            tool_h = health.get("tool") or {}
            has_request = bool(req.get("url") if isinstance(req, dict) else "")
            has_tool_h = bool(
                tool_h.get("name") if isinstance(tool_h, dict) else ""
            )
            if has_request and has_tool_h:
                errors.append(
                    "healthProbe: declare EITHER request OR tool, not both"
                )
            elif not has_request and not has_tool_h:
                errors.append(
                    "healthProbe block present but empty — declare request or tool"
                )
            elif has_request:
                errors.extend(check_request_block(req, "healthProbe"))
                errors.extend(
                    check_on_status(health.get("on_status"), "healthProbe")
                )
            interval = health.get("interval_seconds", 0)
            if interval and isinstance(interval, int) and interval < 30:
                errors.append(
                    f"healthProbe.interval_seconds must be 0 (use default) "
                    f"or >= 30 (got {interval}) — sub-30s probes risk "
                    f"hammering upstream"
                )

    # ── 10. network block (optional) ─────────────────────────────────────────
    network = fm.get("network")
    if network is not None:
        if isinstance(network, dict):
            scope = network.get("scope", "")
            valid_scopes = {"open", "llm-only", "restricted", "private-network"}
            if scope and scope not in valid_scopes:
                errors.append(
                    f"network.scope {scope!r} is not one of: "
                    f"{', '.join(sorted(valid_scopes))}"
                )
            elif scope in ("restricted", "private-network"):
                if not network.get("allowedDomains"):
                    errors.append(
                        f"network.scope={scope!r} requires at least one "
                        f"allowedDomains entry (e.g. '*.googleapis.com:443')"
                    )
            # private-network on unpinned npm/pypi is forbidden (no supply-chain
            # provenance — mirrors validateMcpNetworkDef in parsing.go).
            if scope == "private-network" and isinstance(transport, dict):
                pkg = transport.get("packageType", "")
                if pkg in ("npm", "pypi"):
                    errors.append(
                        f"network.scope=private-network is not allowed for "
                        f"packageType={pkg!r} (unpinned supply chain — "
                        f"no checksum provenance)"
                    )

    # ── Report ────────────────────────────────────────────────────────────────
    if errors:
        print(f"  {RED}FAIL{NC} [{tool_name}]")
        for e in errors:
            print(f"       {RED}x{NC} {e}")
        for w in warnings:
            print(f"       {YELLOW}!{NC} {w}")
        FAIL_COUNT += 1
    elif warnings:
        print(f"  {YELLOW}WARN{NC} [{tool_name}]")
        for w in warnings:
            print(f"       {YELLOW}!{NC} {w}")
        WARN_COUNT += 1
    else:
        print(f"  {GREEN}PASS{NC} [{tool_name}]")
        PASS_COUNT += 1


# ── Main ─────────────────────────────────────────────────────────────────────
if not os.path.isdir(TOOLS_DIR):
    print(f"ERROR: tools directory not found: {TOOLS_DIR}")
    sys.exit(1)

tool_entries = sorted(
    [e for e in os.scandir(TOOLS_DIR) if e.is_dir()],
    key=lambda e: e.name,
)

if not tool_entries:
    print(f"WARNING: no tool directories found under {TOOLS_DIR}")
    sys.exit(0)

for entry in tool_entries:
    tool_name = entry.name
    server_json = os.path.join(entry.path, "server.json")
    server_md   = os.path.join(entry.path, "SERVER.md")
    # server.json takes precedence (McpServerDefFilenames order in parsing.go).
    # JSON validation uses the same McpServerDef struct; for now only SERVER.md
    # is validated here because no server.json files exist in the catalog yet.
    # TODO: add JSON-form validation when server.json files are introduced.
    if os.path.isfile(server_md):
        validate_server(tool_name, server_md)
    elif os.path.isfile(server_json):
        print(
            f"  {YELLOW}WARN{NC} [{tool_name}] server.json found but "
            f"JSON-form validation is not yet implemented in this script"
        )
        WARN_COUNT += 1
    else:
        print(
            f"  {YELLOW}WARN{NC} [{tool_name}] no SERVER.md or server.json found"
        )
        WARN_COUNT += 1

print()
print(f"Results: {PASS_COUNT} passed, {WARN_COUNT} warnings, {FAIL_COUNT} failures")

if FAIL_COUNT > 0:
    sys.exit(1)
PYEOF
