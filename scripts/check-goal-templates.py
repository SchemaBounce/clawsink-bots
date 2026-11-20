#!/usr/bin/env python3
"""Goal templates must measure outcomes, not the bot's own output volume (dec-292, dec-042).

Checks every bots/*/BOT.md `goals:` block:

  R2  A primary goal is never a count of the bot's own output: a `count` over an
      entity listed in `data.entityTypesWrite`, a memory count, a legacy
      `metricType: count`, or any `count` that carries a `condition`. Demote it
      to secondary or health.
  R3  A `count` with a `condition` is never primary. (A demoted indicator may keep
      its condition; the platform refuses to seed a conditional count as a rate.)
  R4  Every bot with goals has at least one primary `rate` or `threshold` goal,
      unless it is listed in scripts/goals-no-outcome-allowlist.txt. The
      allowlist is for bots whose declared entities offer no honest outcome
      metric; it may only shrink.

Usage: check-goal-templates.py [--staged] [bots/<name>/BOT.md ...]
"""
import glob, re, subprocess, sys
import yaml

ALLOW = "scripts/goals-no-outcome-allowlist.txt"


def load(path):
    text = open(path, encoding="utf-8").read()
    m = re.match(r"---\n(.*?)\n---", text, re.S)
    return yaml.safe_load(m.group(1)) if m else {}


def gtype(g):
    m = g.get("metric")
    if isinstance(m, dict):
        return m.get("type", ""), m
    return g.get("metricType", ""), {}


def condition(g):
    t = g.get("target")
    return t.get("condition") if isinstance(t, dict) else None


def check(path, allow):
    d = load(path)
    goals = d.get("goals") or []
    if not goals:
        return []
    bot = d["metadata"]["name"]
    writes = set((d.get("data") or {}).get("entityTypesWrite") or [])
    errs, outcome = [], False
    for g in goals:
        name = g.get("name", "?")
        typ, m = gtype(g)
        prim = g.get("category") == "primary"
        if prim and typ in ("rate", "threshold"):
            outcome = True
        if not prim or typ != "count":
            continue
        if condition(g):
            errs.append(f"{bot}: primary count '{name}' has a condition (R3); demote it to secondary or health")
        elif m.get("source") == "memory" or not m or m.get("entity") in writes:
            errs.append(f"{bot}: primary count '{name}' counts the bot's own output (R2); demote it to secondary or health")
    if not outcome and bot not in allow:
        errs.append(f"{bot}: no primary rate or threshold goal (R4); add an outcome goal or list the bot in {ALLOW}")
    if outcome and bot in allow:
        errs.append(f"{bot}: now has an outcome goal; remove it from {ALLOW}")
    return errs


def main(argv):
    allow = {l.split("#")[0].strip() for l in open(ALLOW, encoding="utf-8") if l.split("#")[0].strip()}
    if "--staged" in argv:
        out = subprocess.run(["git", "diff", "--cached", "--name-only", "--diff-filter=ACMR"], capture_output=True, text=True).stdout.split()
        paths = [p for p in out if re.fullmatch(r"bots/[^/]+/BOT\.md", p)]
        if not paths:
            return 0
    else:
        paths = [a for a in argv if not a.startswith("--")] or sorted(glob.glob("bots/*/BOT.md"))
    errs = [e for p in paths for e in check(p, allow)]
    for e in errs:
        print("FAIL", e)
    print(f"goal templates: {len(paths)} manifests checked, {len(errs)} problems")
    return 1 if errs else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
