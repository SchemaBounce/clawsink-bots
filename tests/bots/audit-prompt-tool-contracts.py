#!/usr/bin/env python3
"""Detect prompt instructions that adl_query_records cannot execute.

The runtime accepts one entity_type, exact equality filters over record data,
and a bounded limit. It does not accept metadata ranges, null predicates,
ordering/pagination arguments, or multiple entity types in one call.

Existing repository debt is pinned by an exact-content baseline. A changed or
new instruction gets a new fingerprint and fails validation. Removing debt also
requires deleting its now-stale baseline entry, so the exception set can only
change deliberately.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


SCHEMA_VERSION = 1
DEFAULT_BASELINE = "tests/bots/prompt-tool-contract-baseline.json"
INCLUDED_ROOTS = ("bots", "skills", "shared/platform-prompts")


@dataclass(frozen=True)
class Finding:
    fingerprint: str
    path: str
    line: int
    rule: str
    excerpt: str


RULE_DESCRIPTIONS = {
    "query_records_range_filter": (
        "adl_query_records supports exact data-field equality only; range, recency, "
        "and metadata timestamp filters require a bounded platform capability"
    ),
    "query_records_multi_entity": (
        "adl_query_records accepts one entity_type string per call; it cannot batch "
        "multiple entity types or wildcard type families"
    ),
    "query_records_null_filter": (
        "adl_query_records cannot express IS NULL or IS NOT NULL predicates"
    ),
    "query_records_query_option": (
        "adl_query_records has no order_by, sort, offset, cursor, or page argument"
    ),
}


def normalize_line(line: str) -> str:
    return " ".join(line.strip().split())


def finding_rules(line: str) -> list[str]:
    low = normalize_line(line).lower()
    if "adl_query_records" not in low:
        return []

    rules: list[str] = []
    timestamp_field = r"(?:created_at|updated_at|merged_at|completed_at|run_at|timestamp|date)"
    explicit_range = re.search(rf"{timestamp_field}\s*(?:[<>]=?|\b(?:after|before|since)\b)", low)
    described_range = re.search(r"\b(?:date|time)\s+range\b|\brecency\b|\bsince\s+(?:the\s+)?last\b", low)
    field_delta = re.search(rf"(?:filter(?:s|ed)?\s+by|filter:)\s+`?{timestamp_field}`?.*\b(?:new|delta|recent|upcoming)\b", low)
    if explicit_range or described_range or field_delta:
        rules.append("query_records_range_filter")

    if re.search(r"\bis\s+(?:not\s+)?null\b", low):
        rules.append("query_records_null_filter")

    entity_list_match = re.search(
        r"entity_type\s*[:=]\s*(?:\[)?[`\"']?[a-z0-9_*:.-]+[`\"']?\s*,\s*[`\"']?([a-z0-9_*:.-]+)",
        low,
    )
    second_entity = entity_list_match.group(1) if entity_list_match else ""
    listed_multiple_types = bool(entity_list_match) and second_entity not in {
        "all",
        "filtered",
        "filter",
        "filters",
        "limit",
        "oldest",
        "only",
        "order_by",
        "sorted",
        "sort_by",
        "offset",
        "cursor",
        "page",
        "with",
    }
    multi_entity = (
        re.search(r"\bmulti[-_ ]entity", low)
        or re.search(r"\bentity[_ ]types\b[^\n]{0,120}\b(?:one|single|batched)\b[^\n]{0,40}\b(?:call|query)\b", low)
        or re.search(r"\b(?:one|single|batched)\b[^\n]{0,40}\b(?:call|query)\b[^\n]{0,120}\bentity[_ ]types\b", low)
        or re.search(r"\b(?:one\s+)?batched\s+(?:call|query)\b", low)
        or re.search(r"entity_type\s*[:=]\s*[`\"']?[^\s`\"']*\*", low)
        or listed_multiple_types
    )
    if multi_entity:
        rules.append("query_records_multi_entity")

    unsupported_option = re.search(r"\b(?:order_by|sort_by|offset|cursor|page)\b\s*[:=]", low)
    narrative_order = re.search(r"\b(?:sorted|ordered)\s+(?:by\s+)?[a-z0-9_ -]+|\b(?:oldest|newest)\s+first\b", low)
    if unsupported_option or narrative_order:
        rules.append("query_records_query_option")

    return rules


def candidate_files(root: Path) -> Iterable[Path]:
    for relative_root in INCLUDED_ROOTS:
        base = root / relative_root
        if not base.exists():
            continue
        for path in sorted(base.rglob("*.md")):
            relative_parts = path.relative_to(base).parts
            is_bot_prompt = relative_root == "bots" and (
                path.name in {"BOT.md", "SOUL.md", "TOOLS.md", "IDENTITY.md"}
                or "agents" in relative_parts
            )
            is_skill_prompt = relative_root == "skills" and path.name in {"SKILL.md", "prompt.md"}
            if is_bot_prompt or is_skill_prompt or relative_root == "shared/platform-prompts":
                yield path


def scan(root: Path) -> list[Finding]:
    findings: list[Finding] = []
    occurrences: dict[tuple[str, str, str], int] = {}
    for path in candidate_files(root):
        relative = path.relative_to(root).as_posix()
        for line_number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            normalized = normalize_line(raw)
            for rule in finding_rules(raw):
                occurrence_key = (relative, rule, normalized)
                occurrence = occurrences.get(occurrence_key, 0) + 1
                occurrences[occurrence_key] = occurrence
                digest_input = f"{relative}\0{rule}\0{normalized}\0{occurrence}".encode("utf-8")
                findings.append(
                    Finding(
                        fingerprint=hashlib.sha256(digest_input).hexdigest(),
                        path=relative,
                        line=line_number,
                        rule=rule,
                        excerpt=normalized,
                    )
                )
    return sorted(findings, key=lambda f: (f.path, f.line, f.rule, f.fingerprint))


def load_baseline(path: Path) -> dict[str, dict[str, str]]:
    if not path.exists():
        raise ValueError(f"baseline does not exist: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("schemaVersion") != SCHEMA_VERSION or not isinstance(data.get("findings"), list):
        raise ValueError("invalid prompt-tool contract baseline schema")
    baseline: dict[str, dict[str, str]] = {}
    for item in data["findings"]:
        if not isinstance(item, dict) or not isinstance(item.get("fingerprint"), str):
            raise ValueError("invalid baseline finding")
        fingerprint = item["fingerprint"]
        if fingerprint in baseline:
            raise ValueError(f"duplicate baseline fingerprint: {fingerprint}")
        baseline[fingerprint] = item
    return baseline


def write_baseline(path: Path, findings: list[Finding]) -> None:
    payload = {
        "schemaVersion": SCHEMA_VERSION,
        "contract": {
            "tool": "adl_query_records",
            "supported": "one entity_type, exact data-field equality filters, bounded limit",
        },
        "findings": [
            {"fingerprint": f.fingerprint, "path": f.path, "rule": f.rule}
            for f in findings
        ],
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def print_finding(prefix: str, finding: Finding) -> None:
    print(f"{prefix} {finding.path}:{finding.line} [{finding.rule}]")
    print(f"  {RULE_DESCRIPTIONS[finding.rule]}")
    print(f"  {finding.excerpt}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--baseline", type=Path)
    parser.add_argument("--write-baseline", action="store_true")
    parser.add_argument("--list", action="store_true", help="print current findings without comparing a baseline")
    parser.add_argument("--rule", choices=sorted(RULE_DESCRIPTIONS), help="filter --list output by rule")
    parser.add_argument("--limit", type=int, default=0, help="cap --list output; zero prints every match")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = args.root.resolve()
    baseline_path = args.baseline or (root / DEFAULT_BASELINE)
    findings = scan(root)
    if args.list:
        selected = [finding for finding in findings if not args.rule or finding.rule == args.rule]
        if args.limit > 0:
            selected = selected[: args.limit]
        for finding in selected:
            print_finding("FOUND", finding)
        print(f"Listed {len(selected)} of {len(findings)} current findings")
        return 0
    if args.write_baseline:
        write_baseline(baseline_path, findings)
        print(f"Wrote {len(findings)} prompt-tool contract findings to {baseline_path}")
        return 0

    try:
        baseline = load_baseline(baseline_path)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1

    current = {finding.fingerprint: finding for finding in findings}
    new_fingerprints = sorted(set(current) - set(baseline))
    stale_fingerprints = sorted(set(baseline) - set(current))
    for fingerprint in new_fingerprints:
        print_finding("NEW", current[fingerprint])
    for fingerprint in stale_fingerprints:
        item = baseline[fingerprint]
        print(f"STALE {item.get('path', '<unknown>')} [{item.get('rule', '<unknown>')}] {fingerprint}")
    if new_fingerprints or stale_fingerprints:
        print(
            f"FAIL: prompt-tool contract baseline differs: "
            f"{len(new_fingerprints)} new, {len(stale_fingerprints)} stale"
        )
        return 1

    print(f"PASS: {len(findings)} known prompt-tool contract findings; no new drift")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
