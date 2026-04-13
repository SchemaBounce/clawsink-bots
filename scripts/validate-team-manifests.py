#!/usr/bin/env python3
"""
Validate TEAM.md manifests in teams/*/TEAM.md.

Checks applied to every team:
  1. orgChart.roles[*].bot must appear in bots[*].ref
  2. orgChart.roles[*].reportsTo must be null or appear in bots[*].ref

Additional checks applied only to teams that declare orgChart.domains[]
(nested domain tree — opt-in; unmigrated teams stay green):
  3. Every head: value (recursive, through children) must be empty or
     appear in bots[*].ref
  4. Domain name: values must be unique within the team (including nested
     children)

Exits 0 on success, 1 on first violation. No external deps — uses stdlib
only. The validator is deliberately regex-based rather than running a
full YAML parser because TEAM.md frontmatter follows a tight,
predictable shape and we don't want to force a pip-install workflow on
a content repo.
"""

from __future__ import annotations
import os
import re
import sys
from glob import glob
from typing import List, Optional, Tuple


REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEAM_GLOB = os.path.join(REPO_ROOT, "teams", "*", "TEAM.md")


def extract_frontmatter(path: str) -> str:
    """Return the YAML frontmatter (text between the first two '---' lines)."""
    with open(path, "r", encoding="utf-8") as fh:
        text = fh.read()
    m = re.search(r"^---\n(.*?)\n---\n", text, flags=re.DOTALL | re.MULTILINE)
    if not m:
        raise ValueError(f"{path}: no YAML frontmatter found")
    return m.group(1)


def extract_bot_refs(frontmatter: str) -> List[str]:
    """
    Pull out the bot 'name' from each entry in the bots: block.
    Accepts both shapes teams use today:
      * canonical: '- ref: "bots/NAME@1.0.0"'
      * legacy:    '- NAME' (bare string)
    Returns the bare NAME in both cases.
    """
    in_bots = False
    refs: List[str] = []
    for line in frontmatter.splitlines():
        # start of the bots: block (top-level key)
        if re.match(r"^bots:\s*$", line):
            in_bots = True
            continue
        if in_bots:
            if line.strip() == "":
                continue
            if not line.startswith(" "):
                in_bots = False
                continue
            # canonical "- ref: "bots/NAME@..."" form
            m = re.match(r'^\s*-\s*ref:\s*"bots/([^@"]+)', line)
            if m:
                refs.append(m.group(1))
                continue
            # legacy "- NAME" form (bare string at list-item indent)
            m = re.match(r"^\s*-\s*([A-Za-z0-9][A-Za-z0-9_-]*)\s*$", line)
            if m:
                refs.append(m.group(1))
    return refs


def extract_roles(frontmatter: str) -> List[Tuple[str, Optional[str]]]:
    """
    Pull out (bot, reportsTo) tuples from orgChart.roles[].
    reportsTo may be None (YAML null) or a bot name.
    """
    # Narrow to the orgChart.roles block.
    m = re.search(r"^  roles:\s*\n((?:    .*\n)+)", frontmatter, flags=re.MULTILINE)
    if not m:
        return []
    block = m.group(1)
    # Each role is a 4-line indented object. Grab bot + reportsTo.
    roles: List[Tuple[str, Optional[str]]] = []
    pattern = re.compile(
        r"^\s*-\s*bot:\s*(\S+)\s*\n"
        r"(?:\s+role:.*\n)?"
        r"\s+reportsTo:\s*(null|\S+)\s*\n",
        re.MULTILINE,
    )
    for role_match in pattern.finditer(block):
        bot = role_match.group(1).strip('"')
        rt = role_match.group(2).strip('"')
        roles.append((bot, None if rt == "null" else rt))
    return roles


def extract_domain_tree(frontmatter: str) -> List[dict]:
    """
    Return a nested list of {name, head, children[]} dicts for orgChart.domains[].
    Returns [] when the team has no domains block (unmigrated teams — that's fine).
    """
    # Isolate the orgChart.domains: block using indentation — it sits inside
    # orgChart: at indent 2, so entries are indented at 4 spaces and deeper.
    lines = frontmatter.splitlines()
    # Find the line "  domains:" under orgChart.
    start = None
    for i, line in enumerate(lines):
        if line.rstrip() == "  domains:":
            start = i + 1
            break
    if start is None:
        return []

    # Collect lines until we leave the domains block (next top-level-under-orgChart
    # entry is "  roles:" or "  escalation:" at two-space indent).
    block_lines: List[str] = []
    for line in lines[start:]:
        if re.match(r"^  \S", line):
            break
        block_lines.append(line)

    # Simple line-based recursive-descent parser. Each node starts with
    # a list marker "- name: …" at some indent level; children of that
    # node live at indent + 2 with their own "- name: …" markers after a
    # "children:" key. Heads look like "<indent>head: bot-name".
    def parse(indent: int, start_idx: int) -> Tuple[List[dict], int]:
        nodes: List[dict] = []
        i = start_idx
        while i < len(block_lines):
            line = block_lines[i]
            if not line.strip():
                i += 1
                continue
            stripped_indent = len(line) - len(line.lstrip(" "))
            if stripped_indent < indent:
                break
            if stripped_indent > indent:
                # Already consumed by a recursive call; safe to skip.
                i += 1
                continue
            m = re.match(r"^\s*-\s*name:\s*(.+?)\s*$", line)
            if not m:
                i += 1
                continue
            name = m.group(1).strip('"').strip("'")
            head: Optional[str] = None
            children: List[dict] = []
            j = i + 1
            # Read fields that belong to THIS node. Fields live at
            # indent + 2. A nested "children:" key introduces a deeper
            # list at indent + 4.
            field_indent = indent + 2
            while j < len(block_lines):
                line2 = block_lines[j]
                if not line2.strip():
                    j += 1
                    continue
                ind2 = len(line2) - len(line2.lstrip(" "))
                if ind2 < field_indent:
                    break
                if ind2 == field_indent:
                    mh = re.match(r"^\s*head:\s*(.*?)\s*$", line2)
                    if mh:
                        head = mh.group(1).strip('"').strip("'") or None
                        j += 1
                        continue
                    if re.match(r"^\s*children:\s*\[?\s*\]?\s*$", line2):
                        # Parse children at indent + 4.
                        children, j = parse(indent + 4, j + 1)
                        continue
                    # other fields (description, etc.) — skip
                    j += 1
                    continue
                # Deeper indent is handled by recursion; skip.
                j += 1
            nodes.append({"name": name, "head": head, "children": children})
            i = j
        return nodes, i

    parsed, _ = parse(4, 0)
    return parsed


def walk_domains(nodes: List[dict]) -> List[dict]:
    """Flatten the domain tree into a list of {name, head} entries."""
    out: List[dict] = []
    for n in nodes:
        out.append({"name": n["name"], "head": n["head"]})
        out.extend(walk_domains(n["children"]))
    return out


def validate_team(path: str) -> List[str]:
    """Return a list of error messages (empty = team is valid)."""
    team = os.path.basename(os.path.dirname(path))
    errors: List[str] = []
    try:
        frontmatter = extract_frontmatter(path)
    except ValueError as exc:
        return [f"{team}: {exc}"]

    bots = set(extract_bot_refs(frontmatter))

    # Check 1 + 2: roles reference real bots
    for bot, reports_to in extract_roles(frontmatter):
        if bot not in bots:
            errors.append(
                f"{team}: orgChart.roles references bot '{bot}' but "
                f"it is not in bots[]"
            )
        if reports_to is not None and reports_to not in bots:
            errors.append(
                f"{team}: orgChart.roles[{bot}].reportsTo='{reports_to}' "
                f"is not in bots[]"
            )

    # Check 3 + 4: if domains block exists, validate heads + uniqueness.
    domains_flat = walk_domains(extract_domain_tree(frontmatter))
    if domains_flat:
        names_seen: set[str] = set()
        for d in domains_flat:
            if d["name"] in names_seen:
                errors.append(
                    f"{team}: orgChart.domains has duplicate name '{d['name']}'"
                )
            names_seen.add(d["name"])
            head = d["head"]
            if head and head not in bots:
                errors.append(
                    f"{team}: orgChart.domains[{d['name']}].head='{head}' "
                    f"is not in bots[]"
                )

    return errors


def main() -> int:
    paths = sorted(glob(TEAM_GLOB))
    if not paths:
        print(f"no TEAM.md files found under {TEAM_GLOB}", file=sys.stderr)
        return 1

    total_errors = 0
    for path in paths:
        errors = validate_team(path)
        if errors:
            total_errors += len(errors)
            for err in errors:
                print(f"FAIL: {err}")
    if total_errors:
        print(f"\n{total_errors} validation error(s) across {len(paths)} team(s)")
        return 1
    print(f"OK — {len(paths)} team(s) validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
