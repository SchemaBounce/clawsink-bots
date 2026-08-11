# This Repo Is PUBLIC — No Internal Platform Content, Ever

## Loaded when

Writing or editing ANY file in this repo: SERVER.md manifests, BOT.md, SKILL.md,
rules, docs, comments, commit messages.

## Rule

**`SchemaBounce/clawsink-bots` is a PUBLIC GitHub repo. Everything here — every
branch, every comment, every commit message — is world-readable the moment it
is pushed.** It is the customer-facing marketplace catalog, not an ops
notebook.

Never put in this repo:

1. **Secret values** of any kind (obvious, absolute).
2. **Internal infrastructure layout**: AWS Secrets Manager key names, Helm
   chart flags/values paths, Kubernetes namespaces/service names, ArgoCD
   details, internal hostnames.
3. **Ops runbook content**: deploy sequencing, "operator action" notes,
   incident references, "do not point this back at X" internal guidance.
   That belongs in core-api docs or `.claude/rules` in PRIVATE repos.
4. **Anything you would not paste into a public blog post.**

What MAY appear (the designed catalog contract):

- Functional frontmatter the platform resolves: transport, env SPEC names for
  customer-supplied credentials, `auth.type`, pinned OAuth endpoints, and
  platform env var NAMES (`*_env` keys) — names only, never values.
- Customer-facing markdown: what the server does, how to connect, where to
  create a key on the provider's site.

## Why

2026-08-11: a SERVER.md comment block documenting the platform's secrets-store
key layout, chart flags, and internal ops guidance was pushed to this public
repo (scrubbed in `1190ccb`, but git history is forever). No credentials were
exposed — but internal wiring documentation in a public catalog is an
information-disclosure bug and a compliance smell (RULE 13).

## Related

- schemabounce-mcp `.claude/rules/no-internal-or-test-code.md` — the same
  public/private split for the MCP bundle repo.
- Workspace CLAUDE.md "MCP repos — mind the public/private split".
