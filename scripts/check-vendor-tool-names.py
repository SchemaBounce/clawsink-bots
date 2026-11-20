#!/usr/bin/env python3
"""dec-254 clause 4: bot and skill guidance never names a vendor MCP tool.

Rule: .claude/rules/bot-guidance-stays-generic.md

Usage:
  scripts/check-vendor-tool-names.py --staged           check staged blobs (pre-commit)
  scripts/check-vendor-tool-names.py                    check every bot/skill text file on disk
  scripts/check-vendor-tool-names.py --update-baseline  rewrite the baseline from the tree
  scripts/check-vendor-tool-names.py --list             print every hit

Server and tool names come from the repo's own catalog (tools/<name>/ and the
`tools:` list of tools/<name>/SERVER.md), so a new server is covered with no
edit here. A hit is one of:
  1. server.tool( or `server.tool`        (namespaced call, server = a tools/ dir)
  2. server__tool                         (MCP-style qualified name)
  3. `tool_name` or tool_name(            (a tool listed in a SERVER.md; names
                                           with no _ or - are too generic to match;
                                           adl_*, code_session_* and pack tools never match)
Not a hit: `ref: tools/<name>`, anything under tools/, tests, scripts, hooks.

Ratchet: scripts/vendor-tool-names-baseline.tsv ("path<TAB>count"). A file may
not have more hits than its entry (no entry = 0). A baselined file that is now
clean fails until its entry is removed.
"""
import glob, os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
BASE = "scripts/vendor-tool-names-baseline.tsv"


def in_scope(p):
    if not p.endswith(".md"):
        return False
    if p.startswith("bots/") and p.count("/") >= 2 and p != "bots/README.md":
        return True
    return p.startswith("skills/") and p != "skills/README.md"


def catalog():
    servers = sorted((d for d in os.listdir("tools") if os.path.isdir("tools/" + d)), key=len, reverse=True)
    packtools = set()
    for f in glob.glob("packs/*/PACK.md"):
        packtools |= set(re.findall(r"^\s+- name:\s*\"?([A-Za-z0-9_.-]+)", open(f, errors="ignore").read(), re.M))
    names = set()
    for f in glob.glob("tools/*/SERVER.md"):
        txt = open(f, errors="ignore").read()
        m = re.search(r"^tools:\s*\n((?:[ \t]+.*\n|\n)*)", txt, re.M)
        if not m:
            continue
        for x in re.findall(r"^\s+- name:\s*\"?([A-Za-z0-9_.-]+)", m.group(1), re.M):
            if re.search(r"[_-]", x) and not x.startswith(("adl_", "code_session_")) and x not in packtools:
                names.add(x)
    return servers, sorted(names, key=len, reverse=True)


SERVERS, TOOLS = catalog()
_s = "|".join(re.escape(s) for s in SERVERS)
_t = "|".join(re.escape(t) for t in TOOLS)
PATTERNS = [
    re.compile(r"(?<![\w./-])(?:%s)\.[a-z][a-z0-9_]*\(" % _s),
    re.compile(r"`(?:%s)\.[a-z][a-z0-9_]*`" % _s),
    re.compile(r"(?<!\w)(?:%s)__[a-z][a-z0-9_]+" % _s),
    re.compile(r"`(?:%s)`" % _t) if _t else None,
    re.compile(r"(?<![\w.-])(?:%s)\(" % _t) if _t else None,
]
PATTERNS = [p for p in PATTERNS if p]


def hits(text):
    out = []
    for n, line in enumerate(text.splitlines(), 1):
        if re.match(r"\s*-?\s*ref:\s*tools/", line):
            continue
        for p in PATTERNS:
            for m in p.finditer(line):
                out.append((n, m.group(0)))
    return out


def baseline():
    b = {}
    if os.path.exists(BASE):
        for l in open(BASE):
            if l.strip() and not l.startswith("#"):
                p, c = l.rstrip("\n").split("\t")
                b[p] = int(c)
    return b


def tree_files():
    return [f for f in subprocess.check_output(["git", "ls-files"], text=True).splitlines()
            if in_scope(f) and os.path.isfile(f)]


def main():
    arg = sys.argv[1] if len(sys.argv) > 1 else ""
    if arg == "--update-baseline":
        rows = []
        for f in tree_files():
            h = hits(open(f, errors="ignore").read())
            if h:
                rows.append("%s\t%d" % (f, len(h)))
        open(BASE, "w").write("# dec-254: files that still name vendor MCP tools. Only shrinks.\n" + "\n".join(sorted(rows)) + "\n")
        print("vendor-tool-names: baseline rewritten (%d files)" % len(rows))
        return 0
    if arg == "--list":
        for f in tree_files():
            for n, s in hits(open(f, errors="ignore").read()):
                print("%s:%d: %s" % (f, n, s))
        return 0
    base = baseline()
    if arg == "--staged":
        files = subprocess.check_output(["git", "diff", "--cached", "--name-only", "--diff-filter=ACMR"], text=True).splitlines()
        read = lambda f: subprocess.run(["git", "show", ":" + f], capture_output=True, text=True).stdout
    else:
        files = tree_files()
        read = lambda f: open(f, errors="ignore").read()
    fail = False
    for f in files:
        if not in_scope(f):
            continue
        h = hits(read(f))
        b = base.get(f, 0)
        if len(h) > b:
            fail = True
            print("vendor-tool-names: %s has %d vendor tool reference(s), baseline allows %d" % (f, len(h), b))
            for n, s in h[:8]:
                print("  %s:%d: %s" % (f, n, s))
        elif b and not h:
            fail = True
            print("vendor-tool-names: %s is clean now; remove its line from %s" % (f, BASE))
    if arg != "--staged":
        for f in base:
            if not os.path.isfile(f):
                fail = True
                print("vendor-tool-names: baselined file %s no longer exists; remove it from %s" % (f, BASE))
    if fail:
        print("vendor-tool-names: dec-254 clause 4 / .claude/rules/bot-guidance-stays-generic.md: describe the behaviour,")
        print("vendor-tool-names: not a vendor's tool. Platform tools (adl_*, code_session_*, pack tools) and `ref: tools/<name>` are fine.")
        return 1
    return 0


sys.exit(main())
