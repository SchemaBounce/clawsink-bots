#!/usr/bin/env python3
"""Runnability audit for tools/**  manifests.

validate-manifest.sh checks that a manifest is well FORMED. This checks that the
thing it points at can actually START. Those are different failures: a manifest
can be perfectly valid and name a package that has no executable, was deprecated
by its publisher, or is a shim around a runtime the gateway does not provide.

Written after prod 2026-08-12, where tools/bing-webmaster pinned an npm package
that spawns `python3 -m mcp_server_bwt` while declaring no dependencies and
publishing nothing to PyPI. The download succeeded and the child died on
ModuleNotFoundError every single time. Nothing in the catalog, the manifest
schema, or CI could have told us; the only signal was a customer opening a
support thread. Every rule below is a check that would have caught it or one of
its neighbours found in the same sweep.

Usage
-----
  audit-runnability.py                     # every manifest, offline rules only
  audit-runnability.py --network           # add registry lookups (slow)
  audit-runnability.py --network FILES...  # only these manifests (PR path)
  audit-runnability.py --spawn FILES...    # also START each one and handshake

Exit 1 on any unbaselined failure. Warnings never fail the run.
"""

from __future__ import annotations

import argparse
import io
import json
import os
import posixpath
import re
import sys
import tarfile
import urllib.error
import urllib.parse
import urllib.request

try:
    import yaml
except ImportError:
    sys.exit("PyYAML is required: pip3 install pyyaml")

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TOOLS = os.path.join(REPO, "tools")
BASELINE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "runnability-baseline.txt")

# A ref that is not pinned resolves to whatever the publisher pushed last. The
# gateway rejects these outright for github sources; for npm/pypi an unpinned
# spec silently changes what runs under a customer.
UNPINNED = {"latest", "main", "master", "head", "*", ""}

# A Node MCP server talks the protocol through an SDK. A package that declares
# no dependency on one is either a bundled build, a wrapper around a binary, or
# a shim to another runtime. The first two are fine and common; the third is the
# bing-webmaster failure. Only the tarball can tell them apart.
MCP_SDK = re.compile(r"modelcontextprotocol|mcp-sdk|fastmcp|@mcp/", re.I)

# Source files for runtimes the gateway image does not install dependencies for.
FOREIGN_SOURCE = (".py", ".rb", ".php", ".pl")

UA = {"User-Agent": "clawsink-bots-runnability-audit"}


class Finding:
    def __init__(self, server: str, rule: str, level: str, detail: str):
        self.server, self.rule, self.level, self.detail = server, rule, level, detail

    @property
    def key(self) -> str:
        """Stable identity for baselining. Deliberately excludes the detail text
        so a version bump in a message does not silently un-baseline a finding."""
        return f"{self.server}:{self.rule}"

    def __str__(self) -> str:
        return f"{self.level:<7} {self.server:<26} {self.rule:<22} {self.detail}"


def fetch(url: str, timeout: int = 30) -> bytes:
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=timeout).read()


def load_manifest(path: str) -> dict | None:
    """SERVER.md frontmatter or server.json. Returns None when unparseable —
    validate-manifest.sh owns that failure, this script does not duplicate it."""
    try:
        raw = open(path, encoding="utf-8", errors="replace").read()
        if path.endswith(".json"):
            return json.loads(raw)
        if not raw.startswith("---"):
            return None
        end = raw.find("\n---", 3)
        return yaml.safe_load(raw[3:end] if end > 0 else raw[3:])
    except Exception:
        return None


def npm_specs(transport: dict) -> list[str]:
    """The package specs an `npx` invocation would install. Handles both the
    bare form (`npx -y pkg@1.0.0`) and the split form
    (`npx -y --package=pkg@1.0.0 some-bin`), where the trailing token is a
    binary name and must not be looked up as a package."""
    args = [str(a) for a in (transport.get("args") or [])]
    explicit = [a.split("=", 1)[1] for a in args if a.startswith("--package=")]
    if explicit:
        return explicit
    for a in args:
        if a.startswith("-"):
            continue
        return [a]
    return []


def split_spec(spec: str) -> tuple[str, str]:
    at = spec.rfind("@")
    return (spec[:at], spec[at + 1 :]) if at > 0 else (spec, "")


# ---------------------------------------------------------------------------
# Offline rules
# ---------------------------------------------------------------------------


def offline_rules(name: str, man: dict) -> list[Finding]:
    out: list[Finding] = []
    transport = man.get("transport") or {}
    ttype = transport.get("type", "")
    auth = man.get("auth") or {}
    cmd = transport.get("command", "")

    # A Composio-managed server is reached over a per-account remote URL that
    # core-api resolves at connect time. It explicitly "leaves transport_config
    # untouched" when that resolution fails, so a stdio block here is not dead
    # metadata: it is the fallback the gateway will try to spawn.
    if str(auth.get("method", "")).lower() == "composio" and ttype != "streamable-http":
        out.append(
            Finding(name, "composio-not-remote", "FAIL", f"auth.method=composio but transport.type={ttype!r}")
        )

    if ttype == "stdio" and cmd in ("npx", "uvx"):
        for spec in npm_specs(transport):
            pkg, ver = split_spec(spec)
            if ver.lower() in UNPINNED:
                out.append(Finding(name, "unpinned-version", "FAIL", f"{spec!r} is not pinned"))

    # validation.tool names the tool the platform calls to prove the connection
    # works. Naming one the server does not advertise makes every Test fail.
    vtool = ((man.get("validation") or {}).get("tool") or {}).get("name")
    if vtool:
        declared = {t.get("name") for t in (man.get("tools") or [])}
        if declared and vtool not in declared:
            out.append(
                Finding(name, "validation-tool-unknown", "FAIL", f"validation tool {vtool!r} is not in tools:")
            )
    return out


# ---------------------------------------------------------------------------
# Network rules
# ---------------------------------------------------------------------------


def audit_npm(name: str, spec: str) -> list[Finding]:
    out: list[Finding] = []
    pkg, ver = split_spec(spec)
    try:
        doc = json.loads(fetch("https://registry.npmjs.org/" + urllib.parse.quote(pkg, safe="")))
    except urllib.error.HTTPError as e:
        return [Finding(name, "package-missing", "FAIL", f"{pkg} -> HTTP {e.code}")]
    except Exception as e:  # network flake: warn, never fail the build
        return [Finding(name, "registry-unreachable", "WARN", f"{pkg}: {e}")]

    entry = doc.get("versions", {}).get(ver)
    if ver and not entry:
        latest = doc.get("dist-tags", {}).get("latest", "?")
        return [Finding(name, "version-missing", "FAIL", f"{spec} not published (latest {latest})")]
    entry = entry or doc["versions"][doc["dist-tags"]["latest"]]

    # npx resolves the command from `bin`. Without one it exits before the MCP
    # handshake with "could not determine executable to run".
    if not entry.get("bin"):
        out.append(Finding(name, "no-bin", "FAIL", f"{spec} publishes no bin entry"))

    if entry.get("deprecated"):
        out.append(Finding(name, "deprecated", "WARN", f"{spec}: {str(entry['deprecated'])[:90]}"))

    deps = entry.get("dependencies") or {}
    if not any(MCP_SDK.search(d) for d in deps):
        out.extend(inspect_tarball(name, spec, entry))
    return out


def inspect_tarball(name: str, spec: str, entry: dict) -> list[Finding]:
    """Last resort for a package that declares no MCP SDK: look at what it
    actually ships. A bundled build or a binary wrapper is fine. Source for
    another runtime, with nothing to install that runtime's dependencies, is the
    bing-webmaster shape and cannot start."""
    try:
        tf = tarfile.open(fileobj=io.BytesIO(fetch(entry["dist"]["tarball"], timeout=60)))
        names = [m.name for m in tf.getmembers() if m.isfile()]
    except Exception as e:
        return [Finding(name, "tarball-unreadable", "WARN", f"{spec}: {e}")]

    foreign = [n for n in names if n.endswith(FOREIGN_SOURCE)]
    if foreign:
        return [
            Finding(
                name,
                "cross-runtime-shim",
                "FAIL",
                f"{spec} ships {len(foreign)} non-JS source files ({posixpath.basename(foreign[0])}) "
                f"and declares {len(entry.get('dependencies') or {})} dependencies; "
                "the gateway cannot install that runtime's packages",
            )
        ]
    return []


def audit_pypi(name: str, spec: str) -> list[Finding]:
    pkg = re.split(r"[=<>@\[]", spec)[0]
    ver = ""
    m = re.search(r"[=@]{1,2}([\w.+-]+)$", spec)
    if m:
        ver = m.group(1)
    try:
        doc = json.loads(fetch(f"https://pypi.org/pypi/{urllib.parse.quote(pkg)}/json"))
    except urllib.error.HTTPError as e:
        return [Finding(name, "package-missing", "FAIL", f"{pkg} -> HTTP {e.code}")]
    except Exception as e:
        return [Finding(name, "registry-unreachable", "WARN", f"{pkg}: {e}")]
    if ver and ver not in doc.get("releases", {}):
        return [
            Finding(name, "version-missing", "FAIL", f"{spec} not on PyPI (latest {doc['info']['version']})")
        ]
    return []


def network_rules(name: str, man: dict) -> list[Finding]:
    transport = man.get("transport") or {}
    if transport.get("type") != "stdio":
        return []
    cmd = transport.get("command", "")
    out: list[Finding] = []
    for spec in npm_specs(transport):
        if cmd == "npx":
            out.extend(audit_npm(name, spec))
        elif cmd == "uvx":
            out.extend(audit_pypi(name, spec))
    return out


# ---------------------------------------------------------------------------
# Spawn rule — start the thing and speak to it
# ---------------------------------------------------------------------------
#
# Every rule above reasons ABOUT the package. None of them can see the one
# failure that is invisible from metadata: the package installs fine, publishes
# a bin, bundles an SDK, and still refuses to serve because its CLI wants a
# subcommand the manifest does not pass. tools/prometheus pinned
# `prometheus-mcp@1.1.3` with no subcommand for its whole life; the binary
# printed its usage text and exited 1, so the gateway reported `child_exited`
# and told the customer it was "usually a packaging or configuration problem".
# tools/azure (`azmcp`, wants `server start`) and tools/cloudflare
# (`mcp-server-cloudflare`, wants `run <account_id>`) were the same shape.
#
# So this rule installs the package and runs it exactly as the gateway would,
# with the manifest's own args, then sends an MCP `initialize`. A server that
# answers is fine. A server that exits with usage text FAILS. Anything else --
# a missing credential, a hang, a network error -- is a WARN, because this
# script has no credentials and must never fail a build for not having them.

# Exit text that means "you invoked me wrong", across the CLI frameworks MCP
# servers actually use (yargs, commander, click, argparse, System.CommandLine)
# plus the hand-rolled dispatch in @cloudflare/mcp-server-cloudflare.
USAGE_MARKERS = (
    "not enough non-option arguments",
    "required command was not provided",
    "expected 'init' or 'run'",
    "unknown command",
    "missing command",
    "no such command",
    "the following arguments are required",
    "usage:",
    "<command>",
)

INITIALIZE = json.dumps(
    {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "clawsink-runnability-audit", "version": "1.0"},
        },
    }
)


def _placeholder_env(man: dict) -> dict:
    """Shape-correct junk for every declared env var. The point is to get past a
    startup that only checks presence, not to authenticate -- a server that
    rejects the junk is a WARN either way."""
    env = dict(os.environ)
    for spec in man.get("env") or []:
        upper = str(spec.get("name") or "").upper()
        if not upper:
            continue
        if any(k in upper for k in ("URL", "URI", "ENDPOINT", "HOST")):
            value = "http://127.0.0.1:19999"
        elif "PORT" in upper:
            value = "19999"
        elif "EMAIL" in upper:
            value = "audit@example.com"
        elif "REGION" in upper:
            value = "us-west-2"
        elif any(k in upper for k in ("PATH", "FILE", "DIR")):
            value = "/tmp"
        else:
            value = "runnability-audit-placeholder"
        env[upper] = value
    return env


def _handshake(argv: list[str], env: dict, timeout: int) -> tuple[bool, str, int | None]:
    """Run argv, send one initialize, return (answered, captured output, exit code)."""
    import subprocess
    import threading
    import time

    try:
        proc = subprocess.Popen(
            argv,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            text=True,
            bufsize=1,
        )
    except OSError as exc:
        return False, f"spawn failed: {exc}", None

    captured: list[str] = []
    answered: list[bool] = []

    def drain(stream, watch_for_result: bool) -> None:
        for line in stream:
            captured.append(line.rstrip("\n"))
            if watch_for_result and '"result"' in line and '"jsonrpc"' in line:
                answered.append(True)

    threading.Thread(target=drain, args=(proc.stdout, True), daemon=True).start()
    threading.Thread(target=drain, args=(proc.stderr, False), daemon=True).start()
    try:
        proc.stdin.write(INITIALIZE + "\n")
        proc.stdin.flush()
    except OSError:
        pass

    deadline = time.time() + timeout
    while time.time() < deadline and not answered and proc.poll() is None:
        time.sleep(0.25)
    code = proc.poll()
    if code is None:
        proc.kill()
        try:
            proc.wait(timeout=5)
        except Exception:
            pass
    return bool(answered), "\n".join(captured), code


def _npm_launch(name: str, transport: dict, workdir: str) -> tuple[list[str] | None, Finding | None]:
    """Install the manifest's npm spec and return the argv the gateway would run."""
    import shutil
    import subprocess

    if not shutil.which("npm"):
        return None, Finding(name, "spawn-unavailable", "WARN", "npm is not on PATH")

    args = [str(a) for a in (transport.get("args") or [])]
    args = [a for a in args if a != "-y"]
    binary = None
    if args and args[0].startswith("--package="):
        spec = args[0].split("=", 1)[1]
        args = args[1:]
        if args:
            binary, args = args[0], args[1:]
    elif args:
        spec, args = args[0], args[1:]
    else:
        return None, Finding(name, "spawn-unavailable", "WARN", "no package spec in args")

    proc = subprocess.run(
        ["npm", "install", "--no-audit", "--no-fund", "--prefix", workdir, spec],
        capture_output=True,
        text=True,
        timeout=300,
    )
    if proc.returncode != 0:
        # npm's last stderr line is always the debug-log path. The reason is the
        # first `npm error` line that carries text of its own.
        candidates = []
        for line in (proc.stderr or "").splitlines():
            line = line.strip()
            if not line.startswith("npm error") or "log of this run" in line:
                continue
            rest = line[len("npm error") :].strip()
            if rest:
                candidates.append(rest)
        # Prefer a sentence ("No matching version found for x@^0.1.0.") over the
        # bare error code npm prints first.
        reason = next((c for c in candidates if len(c.split()) >= 4), candidates[0] if candidates else "")
        return None, Finding(
            name, "install-failed", "FAIL", f"{spec} will not install: {(reason or 'see npm output')[:160]}"
        )

    pkg, _ = split_spec(spec)
    manifest_path = os.path.join(workdir, "node_modules", *pkg.split("/"), "package.json")
    bins: dict = {}
    if os.path.isfile(manifest_path):
        declared = (json.load(open(manifest_path, encoding="utf-8")) or {}).get("bin")
        if isinstance(declared, str):
            bins = {pkg.split("/")[-1]: declared}
        elif isinstance(declared, dict):
            bins = declared
    if binary is None:
        short = pkg.split("/")[-1]
        binary = short if short in bins else (sorted(bins)[0] if bins else None)
    if not binary:
        return None, Finding(name, "no-bin", "FAIL", f"{spec} publishes no bin entry")
    entry = os.path.join(workdir, "node_modules", ".bin", binary)
    if not os.path.exists(entry):
        return None, Finding(name, "no-bin", "FAIL", f"{spec} does not install a {binary!r} bin")
    # Through `node` rather than the shim: some published bins ship without an
    # executable bit or a shebang, which is npx's problem to solve, not a
    # catalog bug.
    return ["node", entry] + args, None


def spawn_rules(name: str, man: dict) -> list[Finding]:
    import shutil
    import tempfile

    transport = man.get("transport") or {}
    if transport.get("type") != "stdio":
        return []
    command = transport.get("command", "")
    if command == "uvx":
        # PyPI servers need a resolver this script does not ship. The registry
        # rules still cover them; skip rather than guess.
        return [Finding(name, "spawn-skipped", "WARN", "uvx launch not exercised by --spawn")]
    if command != "npx":
        return []

    workdir = tempfile.mkdtemp(prefix=f"runnability-{name}-")
    try:
        argv, failure = _npm_launch(name, transport, workdir)
        if failure is not None:
            return [failure]
        answered, output, code = _handshake(argv, _placeholder_env(man), timeout=45)
        if answered:
            return []
        haystack = output.lower()
        if any(marker in haystack for marker in USAGE_MARKERS):
            first = next((line for line in output.splitlines() if line.strip()), "")
            return [
                Finding(
                    name,
                    "requires-subcommand",
                    "FAIL",
                    f"started with args {list(transport.get('args') or [])} and printed usage "
                    f"instead of serving: {first.strip()[:140]}",
                )
            ]
        first = next((line for line in output.splitlines() if line.strip()), "")
        return [
            Finding(
                name,
                "no-handshake",
                "WARN",
                f"no initialize response (exit={code}); likely needs real credentials: {first.strip()[:120]}",
            )
        ]
    except Exception as exc:  # a harness failure is never a manifest verdict
        return [Finding(name, "spawn-error", "WARN", f"{type(exc).__name__}: {exc}")]
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


# ---------------------------------------------------------------------------


def read_baseline() -> set[str]:
    if not os.path.exists(BASELINE):
        return set()
    keys = set()
    for line in open(BASELINE, encoding="utf-8"):
        line = line.split("#", 1)[0].strip()
        if line:
            keys.add(line)
    return keys


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--network", action="store_true", help="also query npm/PyPI (slow)")
    ap.add_argument(
        "--spawn",
        action="store_true",
        help="also install each npm server and check it answers an MCP initialize (slowest; "
        "pass explicit FILES -- this installs packages)",
    )
    ap.add_argument("--write-baseline", action="store_true", help="record current failures as accepted")
    ap.add_argument("files", nargs="*", help="manifest paths to audit; default is all")
    args = ap.parse_args()

    if args.files:
        targets = [(os.path.basename(os.path.dirname(f)), f) for f in args.files if os.path.isfile(f)]
    else:
        targets = []
        for d in sorted(os.listdir(TOOLS)):
            for fn in ("server.json", "SERVER.md"):
                p = os.path.join(TOOLS, d, fn)
                if os.path.isfile(p):
                    targets.append((d, p))
                    break

    findings: list[Finding] = []
    for name, path in targets:
        man = load_manifest(path)
        if not man:
            continue
        findings.extend(offline_rules(name, man))
        if args.network:
            findings.extend(network_rules(name, man))
        if args.spawn:
            findings.extend(spawn_rules(name, man))

    if args.write_baseline:
        fails = sorted({f.key for f in findings if f.level == "FAIL"})
        with open(BASELINE, "w", encoding="utf-8") as fh:
            fh.write(
                "# Known runnability failures, accepted for now so the gate blocks NEW ones.\n"
                "# Shrink this list; never grow it without saying why in the PR.\n"
                "# Regenerate: tests/tools/audit-runnability.py --network --write-baseline\n"
            )
            fh.write("\n".join(fails) + "\n")
        print(f"baselined {len(fails)} failures")
        return 0

    baseline = read_baseline()
    blocking = [f for f in findings if f.level == "FAIL" and f.key not in baseline]
    accepted = [f for f in findings if f.level == "FAIL" and f.key in baseline]
    warnings = [f for f in findings if f.level == "WARN"]

    for f in sorted(warnings, key=lambda f: f.key):
        print(f)
    for f in sorted(accepted, key=lambda f: f.key):
        print(f"BASELINE {f.server:<26} {f.rule:<22} {f.detail}")
    for f in sorted(blocking, key=lambda f: f.key):
        print(f)

    print(
        f"\naudited {len(targets)} manifests: "
        f"{len(blocking)} blocking, {len(accepted)} baselined, {len(warnings)} warnings"
    )
    if blocking:
        print("\nA blocking finding means the server cannot start. Fix the pin, or remove the server.")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
