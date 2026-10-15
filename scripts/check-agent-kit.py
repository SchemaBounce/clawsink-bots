#!/usr/bin/env python3
# Copied from SchemaBounce/schemabounce-agent-kit scripts/agents_md.py (kit 0.3.0).
# Do not edit here: change the kit, then copy the file again. Only check and
# check-settings run in this repository; render needs the kit checkout.
"""Render the kit's decisions text into a repository's instruction file, and
check that it is still there and unchanged.

The block lives between two HTML comments, so it survives next to hand-written
text and a regenerated mirror alike:

    <!-- schemabounce-agent-kit:decisions start kit=0.3.0 sha256=... -->
    ## SchemaBounce decisions
    ...
    <!-- schemabounce-agent-kit:decisions end -->

Commands (run with python3, no third-party packages):

    agents_md.py render <file> [--before "## Heading"]
        Writes the block from templates/AGENTS.decisions.md into <file>.
        An existing block is replaced in place. A new block goes before the
        first line equal to --before, or at the end of the file.

    agents_md.py check <file>
        Fails when the block is missing or its text no longer matches the
        sha256 the start marker records. Run from the kit checkout it also
        fails when the block is older than templates/AGENTS.decisions.md.

    agents_md.py check-settings <settings.json>
        Fails when a Claude Code settings file does not enable the kit:
        extraKnownMarketplaces.schemabounce pointing at the SchemaBounce
        marketplace (SchemaBounce/claude-plugins) and
        enabledPlugins["schemabounce@schemabounce"].

A repository keeps a copy of this file (scripts/check-agent-kit.py) so its
pre-commit hook can run check and check-settings without the kit checkout.
The copy has no template beside it, so it skips the freshness comparison.

Why a script and not a paste: dec-125 clause 1 says nobody copies the kit's
rules by hand. A rendered block carries the kit version and a hash, so a
repository that edits or drops the text fails its own check.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

KIT_NAME = "schemabounce-agent-kit"
PLUGIN_ID = "schemabounce@schemabounce"
MARKETPLACE_NAME = "schemabounce"
MARKETPLACE_REPO = "SchemaBounce/claude-plugins"
BLOCK_ID = f"{KIT_NAME}:decisions"
START_RE = re.compile(
    rf"^<!-- {re.escape(BLOCK_ID)} start kit=(?P<kit>[^ ]+) sha256=(?P<sha>[0-9a-f]{{64}}) -->$"
)
END_LINE = f"<!-- {BLOCK_ID} end -->"

HERE = Path(__file__).resolve().parent
KIT_ROOT = HERE.parent
TEMPLATE = KIT_ROOT / "templates" / "AGENTS.decisions.md"
PLUGIN_MANIFEST = KIT_ROOT / ".claude-plugin" / "plugin.json"


def fail(message: str) -> int:
    print(f"agents_md: {message}", file=sys.stderr)
    return 1


def normalize(text: str) -> str:
    """One canonical form so a trailing newline or CRLF never changes the hash."""
    return text.replace("\r\n", "\n").strip() + "\n"


def digest(text: str) -> str:
    return hashlib.sha256(normalize(text).encode("utf-8")).hexdigest()


def kit_version() -> str:
    if not PLUGIN_MANIFEST.exists():
        return "unknown"
    with PLUGIN_MANIFEST.open(encoding="utf-8") as handle:
        return str(json.load(handle).get("version", "unknown"))


def find_block(lines: list[str]) -> tuple[int, int, str, str] | None:
    """Returns (start_index, end_index, kit, sha) of the block, or None."""
    for index, line in enumerate(lines):
        match = START_RE.match(line.rstrip("\n"))
        if not match:
            continue
        for end in range(index + 1, len(lines)):
            if lines[end].rstrip("\n") == END_LINE:
                return index, end, match.group("kit"), match.group("sha")
        return None
    return None


def render_block(body: str, version: str) -> list[str]:
    body = normalize(body)
    start = f"<!-- {BLOCK_ID} start kit={version} sha256={digest(body)} -->"
    return [start + "\n", *[line + "\n" for line in body.rstrip("\n").split("\n")], END_LINE + "\n"]


def cmd_render(path: Path, before: str | None) -> int:
    if not TEMPLATE.exists():
        return fail(f"template not found at {TEMPLATE}; run render from the kit checkout")
    body = TEMPLATE.read_text(encoding="utf-8")
    block = render_block(body, kit_version())
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True) if path.exists() else []
    found = find_block(lines)
    if found:
        start, end, _, _ = found
        lines[start : end + 1] = block
    else:
        insert_at = len(lines)
        if before is not None:
            for index, line in enumerate(lines):
                if line.rstrip("\n") == before:
                    insert_at = index
                    break
            else:
                return fail(f"no line equal to {before!r} in {path}")
        padded = block + ["\n"]
        if insert_at > 0 and lines[insert_at - 1].strip() != "":
            padded = ["\n"] + padded
        lines[insert_at:insert_at] = padded
    path.write_text("".join(lines), encoding="utf-8")
    print(f"agents_md: rendered {BLOCK_ID} (kit {kit_version()}) into {path}")
    return 0


def cmd_check(path: Path) -> int:
    if not path.exists():
        return fail(f"{path} does not exist")
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    found = find_block(lines)
    if not found:
        return fail(
            f"{path} has no {BLOCK_ID} block. Render it with the kit: "
            f"python3 scripts/agents_md.py render {path}"
        )
    start, end, kit, recorded = found
    body = "".join(lines[start + 1 : end])
    actual = digest(body)
    if actual != recorded:
        return fail(
            f"{path}: the {BLOCK_ID} block was edited by hand (sha256 {actual[:12]} "
            f"recorded {recorded[:12]}). Re-render it from the kit instead."
        )
    if TEMPLATE.exists() and digest(TEMPLATE.read_text(encoding="utf-8")) != actual:
        return fail(
            f"{path}: the {BLOCK_ID} block (kit {kit}) is older than "
            f"templates/AGENTS.decisions.md. Re-render it."
        )
    print(f"agents_md: {path} carries {BLOCK_ID} from kit {kit}")
    return 0


def cmd_check_settings(path: Path) -> int:
    if not path.exists():
        return fail(f"{path} does not exist")
    with path.open(encoding="utf-8") as handle:
        settings = json.load(handle)
    marketplace = (settings.get("extraKnownMarketplaces") or {}).get(MARKETPLACE_NAME) or {}
    source = marketplace.get("source") or {}
    if source.get("source") != "github" or source.get("repo") != MARKETPLACE_REPO:
        return fail(
            f"{path}: extraKnownMarketplaces.{MARKETPLACE_NAME} must be "
            f'{{"source": {{"source": "github", "repo": "{MARKETPLACE_REPO}"}}}}'
        )
    if (settings.get("enabledPlugins") or {}).get(PLUGIN_ID) is not True:
        return fail(f'{path}: enabledPlugins["{PLUGIN_ID}"] must be true')
    print(f"agents_md: {path} enables {PLUGIN_ID}")
    return 0


def main(argv: list[str]) -> int:
    if len(argv) < 3:
        print(__doc__, file=sys.stderr)
        return 2
    command, target = argv[1], Path(argv[2])
    if command == "render":
        before = None
        if len(argv) == 5 and argv[3] == "--before":
            before = argv[4]
        elif len(argv) != 3:
            print(__doc__, file=sys.stderr)
            return 2
        return cmd_render(target, before)
    if command == "check":
        return cmd_check(target)
    if command == "check-settings":
        return cmd_check_settings(target)
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
