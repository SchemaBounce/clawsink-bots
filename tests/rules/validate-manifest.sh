#!/usr/bin/env bash
# Rule Manifest Validator for rules/**
#
# Mirrors the contract enforced by core-api's clawsink.ParseRuleDef and the
# activation-time composer composeRulePromptEntries
# (schemabounce-api/internal/clawsink/{parsing.go,types.go} and
# internal/handlers/adl_bot_activation_handler.go).
#
# Checks:
#   1. Every rules/{name}/ directory has RULE.md AND prompt.md
#      (prompt.md is the guardrail body — the composer hard-errors when it is
#      missing, which would fail bot activation at deploy time)
#   2. RULE.md has valid YAML frontmatter; kind == "Rule"
#   3. metadata.name, displayName, version, description are non-empty
#   4. metadata.name matches the directory name
#   5. severity is one of: guideline | guardrail | hard (or absent = guardrail)
#   6. appliesTo entries resolve to existing tools/{name} or skills/{name} dirs
#   7. prompt.md is non-empty; FAIL over 1200 chars (runtime per-rule cap),
#      WARN over 1000 chars (crowds out sibling rules in the 4000-char budget)
#   8. Cross-references: every rules[].ref in bots/*/BOT.md resolves to a
#      shared rules/{name}/ or bot-local bots/{bot}/rules/{name}/ body
#   9. Cross-references: every rules[].ref declared by an MCP server
#      (tools/*/SERVER.md) or a skill (skills/*/SKILL.md) resolves to a shared
#      rules/{name}/ body. These attach to any agent granted the artifact, so a
#      broken ref silently drops a guardrail everywhere the tool is used.
#
# Usage:
#   ./tests/rules/validate-manifest.sh                # validate all rules/** + bot refs
#   ./tests/rules/validate-manifest.sh /tmp/badrule   # validate a specific rules dir

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RULES_DIR="${1:-$REPO_ROOT/rules}"

python3 - "$RULES_DIR" "$REPO_ROOT" << 'PYEOF'
import sys
import os
import re

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML is required. Install with: pip3 install pyyaml")
    sys.exit(1)

RULES_DIR = sys.argv[1]
REPO_ROOT = sys.argv[2]

RED    = "\033[0;31m"
GREEN  = "\033[0;32m"
YELLOW = "\033[1;33m"
NC     = "\033[0m"

PASS_COUNT = 0
FAIL_COUNT = 0
WARN_COUNT = 0

VALID_SEVERITIES = {"guideline", "guardrail", "hard"}
PER_RULE_HARD_CAP = 1200   # runtime maxRulePerRuleChars — content beyond this is truncated
PER_RULE_SOFT_CAP = 1000   # quality bar from rules/README.md


def extract_frontmatter(content, label):
    """Extract YAML between opening --- and next line-anchored --- (mirrors
    ExtractFrontmatter in parsing.go)."""
    if not content.startswith("---"):
        return None, f"{label} missing YAML frontmatter (no opening ---)"
    tail = content[3:]
    if tail.startswith("\r\n"):
        tail = tail[2:]
    elif tail.startswith("\n") or tail.startswith("\r"):
        tail = tail[1:]
    for sep in ("\n---\n", "\n---\r\n", "\n---"):
        idx = tail.find(sep)
        if idx < 0:
            continue
        if sep == "\n---" and idx + len(sep) != len(tail):
            continue
        return tail[:idx + 1], None
    return None, f"{label} missing closing --- delimiter"


def _report(name, source_label, errors, warnings):
    global PASS_COUNT, FAIL_COUNT, WARN_COUNT
    if errors:
        print(f"  {RED}FAIL{NC} [{name}] ({source_label})")
        for e in errors:
            print(f"       {RED}x{NC} {e}")
        for w in warnings:
            print(f"       {YELLOW}!{NC} {w}")
        FAIL_COUNT += 1
    elif warnings:
        print(f"  {YELLOW}WARN{NC} [{name}] ({source_label})")
        for w in warnings:
            print(f"       {YELLOW}!{NC} {w}")
        WARN_COUNT += 1
    else:
        print(f"  {GREEN}PASS{NC} [{name}] ({source_label})")
        PASS_COUNT += 1


def artifact_dir_exists(ref):
    """appliesTo entries reference artifacts by repo path: tools/{n} or skills/{n}."""
    if not isinstance(ref, str) or "/" not in ref:
        return False
    kind, _, name = ref.partition("/")
    if kind not in ("tools", "skills") or not name:
        return False
    return os.path.isdir(os.path.join(REPO_ROOT, kind, name))


def validate_rule_dir(rule_name, rule_path):
    errors = []
    warnings = []

    # -- prompt.md (the guardrail body) --------------------------------------
    prompt_path = os.path.join(rule_path, "prompt.md")
    legacy_path = os.path.join(rule_path, "rule.md")
    body_path = prompt_path if os.path.isfile(prompt_path) else None
    if body_path is None and os.path.isfile(legacy_path):
        # On case-insensitive filesystems rule.md IS RULE.md; only treat it as
        # the body when it is genuinely a distinct file (has no frontmatter).
        with open(legacy_path, "r", encoding="utf-8") as fh:
            if not fh.read().startswith("---"):
                body_path = legacy_path
                warnings.append("uses legacy body name rule.md — rename to prompt.md")
    if body_path is None:
        errors.append(
            "prompt.md is missing — bot activation hard-errors without a rule body"
        )
    else:
        with open(body_path, "r", encoding="utf-8") as fh:
            body = fh.read()
        stripped = body.strip()
        if not stripped:
            errors.append("prompt.md is empty")
        else:
            if len(stripped) > PER_RULE_HARD_CAP:
                errors.append(
                    f"prompt.md is {len(stripped)} chars — over the runtime "
                    f"per-rule cap of {PER_RULE_HARD_CAP}; the excess is truncated"
                )
            elif len(stripped) > PER_RULE_SOFT_CAP:
                warnings.append(
                    f"prompt.md is {len(stripped)} chars — target under "
                    f"{PER_RULE_SOFT_CAP} (aggregate rules budget is 4000)"
                )
            if not stripped.startswith("## "):
                warnings.append("prompt.md should start with a '## {Rule Name}' heading")

    # -- RULE.md (the manifest) ----------------------------------------------
    manifest_path = os.path.join(rule_path, "RULE.md")
    if not os.path.isfile(manifest_path):
        errors.append("RULE.md is missing")
        _report(rule_name, "rules/", errors, warnings)
        return
    with open(manifest_path, "r", encoding="utf-8") as fh:
        content = fh.read()
    fm_text, err = extract_frontmatter(content, "RULE.md")
    if err:
        errors.append(err)
        _report(rule_name, "RULE.md", errors, warnings)
        return
    try:
        fm = yaml.safe_load(fm_text)
    except yaml.YAMLError as exc:
        errors.append(f"YAML parse error: {exc}")
        _report(rule_name, "RULE.md", errors, warnings)
        return
    if not isinstance(fm, dict):
        errors.append("frontmatter did not parse to a mapping")
        _report(rule_name, "RULE.md", errors, warnings)
        return

    kind = fm.get("kind", "")
    if kind != "Rule":
        errors.append(f"kind is {kind!r}, expected 'Rule'")

    meta = fm.get("metadata") or {}
    if isinstance(meta, dict):
        for mfield in ("name", "displayName", "version", "description"):
            if not meta.get(mfield):
                errors.append(f"metadata.{mfield} is missing or empty")
        meta_name = meta.get("name", "")
        if meta_name and meta_name != rule_name:
            errors.append(
                f"metadata.name {meta_name!r} does not match directory name {rule_name!r}"
            )
    else:
        errors.append("metadata must be a mapping")

    severity = fm.get("severity")
    if severity is not None and severity not in VALID_SEVERITIES:
        errors.append(
            f"severity {severity!r} is not one of: {', '.join(sorted(VALID_SEVERITIES))}"
        )

    applies_to = fm.get("appliesTo")
    if applies_to is not None:
        if not isinstance(applies_to, list):
            errors.append("appliesTo must be a sequence")
        else:
            for i, ref in enumerate(applies_to):
                if not artifact_dir_exists(ref):
                    errors.append(
                        f"appliesTo[{i}] {ref!r} does not resolve to an existing "
                        f"tools/{{name}} or skills/{{name}} directory"
                    )

    _report(rule_name, "RULE.md", errors, warnings)


def _check_rule_refs(rules, local_rules_dir, local_hint):
    """Shared ref resolution for a manifest's rules[] block."""
    errors = []
    for i, r in enumerate(rules):
        if not isinstance(r, dict):
            errors.append(f"rules[{i}] must be a mapping with ref or inline")
            continue
        ref = r.get("ref", "") or r.get("inline", "")
        if not ref:
            errors.append(f"rules[{i}] has neither ref nor inline")
            continue
        # "rules/{name}@{ver}" or bare "{name}" → trailing segment sans version
        name = re.sub(r"@.*$", "", ref).rstrip("/").split("/")[-1]
        candidates = [os.path.join(REPO_ROOT, "rules", name)]
        if local_rules_dir:
            candidates.append(os.path.join(local_rules_dir, name))
        has_body = any(
            os.path.isfile(os.path.join(d, f))
            for d in candidates
            for f in ("prompt.md", "rule.md")
        )
        if not has_body:
            expected = f"rules/{name}/prompt.md"
            if local_hint:
                expected += f" or {local_hint}/{name}/prompt.md"
            errors.append(
                f"rules[{i}] ref {ref!r} does not resolve — expected {expected}"
            )
    return errors


def _manifest_frontmatter(path, label):
    """Parse a manifest's YAML frontmatter, or None when absent/invalid."""
    if not os.path.isfile(path):
        return None
    with open(path, "r", encoding="utf-8") as fh:
        content = fh.read()
    fm_text, err = extract_frontmatter(content, label)
    if err:
        return None  # manifest structure is validated by its own suite
    try:
        return yaml.safe_load(fm_text)
    except yaml.YAMLError:
        return None


def validate_bot_rule_refs():
    """Every rules[].ref in bots/*/BOT.md must resolve to a rule body."""
    bots_dir = os.path.join(REPO_ROOT, "bots")
    if not os.path.isdir(bots_dir):
        return
    for entry in sorted(os.scandir(bots_dir), key=lambda e: e.name):
        if not entry.is_dir():
            continue
        fm = _manifest_frontmatter(os.path.join(entry.path, "BOT.md"), "BOT.md")
        rules = (fm or {}).get("rules") or []
        if not isinstance(rules, list) or not rules:
            continue
        errors = _check_rule_refs(
            rules,
            os.path.join(entry.path, "rules"),
            f"bots/{entry.name}/rules",
        )
        _report(entry.name, "BOT.md rules refs", errors, [])


def validate_artifact_rule_refs():
    """rules[].ref declared by an MCP server (tools/) or a skill (skills/) must
    resolve. These rules attach to any agent granted that artifact, so a broken
    ref here silently drops a guardrail from every agent that uses the tool."""
    for kind, manifest_name in (("tools", "SERVER.md"), ("skills", "SKILL.md")):
        base = os.path.join(REPO_ROOT, kind)
        if not os.path.isdir(base):
            continue
        for entry in sorted(os.scandir(base), key=lambda e: e.name):
            if not entry.is_dir():
                continue
            fm = _manifest_frontmatter(
                os.path.join(entry.path, manifest_name), manifest_name
            )
            rules = (fm or {}).get("rules") or []
            if not isinstance(rules, list) or not rules:
                continue
            errors = _check_rule_refs(rules, None, None)
            _report(entry.name, f"{manifest_name} rules refs", errors, [])


# -- Main ---------------------------------------------------------------------
if not os.path.isdir(RULES_DIR):
    print(f"WARNING: rules directory not found: {RULES_DIR} (nothing to validate)")
    sys.exit(0)

rule_entries = sorted(
    [e for e in os.scandir(RULES_DIR) if e.is_dir()],
    key=lambda e: e.name,
)

for entry in rule_entries:
    validate_rule_dir(entry.name, entry.path)

# Cross-reference pass only runs against the real repo layout.
if RULES_DIR == os.path.join(REPO_ROOT, "rules"):
    validate_bot_rule_refs()
    validate_artifact_rule_refs()

print()
print(f"Results: {PASS_COUNT} passed, {WARN_COUNT} warnings, {FAIL_COUNT} failures")

if FAIL_COUNT > 0:
    sys.exit(1)
PYEOF
