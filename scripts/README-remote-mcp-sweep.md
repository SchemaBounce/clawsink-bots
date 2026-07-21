# Remote MCP OAuth Sweep

How to find and add new official, hosted, OAuth-based remote MCP servers to
the catalog, and how to avoid re-doing research that's already been done.

## What we're looking for

A vendor's own hosted MCP server (`streamable-http` or `sse` transport,
connect by URL, nothing runs in our gateway) that speaks MCP-spec OAuth 2.1:
RFC 9728 protected-resource challenge, RFC 8414 authorization-server
metadata, and RFC 7591 dynamic client registration (DCR). DCR is what lets
the platform's generic OAuth client (`auth: oauth2_mcp` with no
`client_id`/`client_secret` pin) register itself with the vendor's AS at
connect time, no vendor app registration required on our side.

Servers whose AS has no DCR (GitHub is the reference case) still get added,
but through the pinned-client path (P2-2: `client_id_env`,
`client_secret_env`, `authorization_endpoint`, `token_endpoint` in the
`auth:` block) instead — that requires registering an app with the vendor
first, so it's slower and out of scope for a routine sweep. See
`tools/github-remote/SERVER.md` for the pattern and
`core-api/.claude/rules/mcp-server-hosting.md` for the architecture.

## Before researching a vendor: check `remote-mcp-candidates.txt`

That file has one row per vendor ever probed, across every past sweep, with
a status and a date. If a vendor is already listed:

- `ADDED` - it's in the catalog (`tools/<name>/SERVER.md`). Nothing to do
  unless you're re-verifying the endpoint is still live.
- `NO_OFFICIAL` - confirmed no vendor-hosted server exists. Don't re-search
  from scratch; do a quick check (has the vendor shipped one since?) rather
  than a full research pass.
- `NO_URL` / `BLOCKED` - a server plausibly exists but we couldn't pin down
  or reach a URL. Worth retrying, especially `BLOCKED` (often just Cloudflare
  bot protection on the vendor's marketing/docs domain, not the MCP host
  itself) or `NO_URL` (often gated behind an admin enabling it in-app).
- `NO_DCR` / `NO_CHALLENGE` - see the header of `remote-mcp-candidates.txt`
  for what each status means before spending time re-probing.

## Workflow for a new vendor

1. **Find the real endpoint.** Vendor developer docs are the primary source.
   `pulsemcp.com` and `mcpservers.org` are useful secondary directories that
   distinguish "official" from community servers, but always confirm against
   the vendor's own docs before trusting a listicle. Guessing
   `mcp.<vendor>.com` fails more often than it works — vendors use their own
   API domain (`api.typeform.com/mcp`), a dedicated docs-tool subdomain
   (`coda.io/apis/mcp`), or an unrelated auth-provider domain for the AS
   (Pylon's AS is `o.auth.usepylon.com`, not `usepylon.com`).
2. **Probe it.**
   ```bash
   ./scripts/probe-remote-mcp.sh <name> "<candidate-url>"
   ```
   Try a few path variants if the first guess 404s (bare origin, `/mcp`,
   trailing slash) — see the Gusto and Make rows in
   `remote-mcp-candidates.txt` for real examples of non-obvious paths.
3. **Only `OK|dcr=yes` gets a SERVER.md.** Read `tools/plain/SERVER.md` as
   the template. Fill in:
   - `auth.type: oauth2_mcp` (no pin fields — DCR handles client
     registration).
   - `transport.url` — the exact MCP endpoint you probed.
   - A one-line comment above `auth:` recording the live-probe date, the AS
     hostname, and the scopes decision (usually "omitted, client requests
     the AS's advertised default").
   - `category` — pick from the existing precedents (see the category list
     each SERVER.md's `metadata.category` uses; grep
     `tools/*/SERVER.md` for current values before inventing a new one).
4. **Record the result either way** in `remote-mcp-candidates.txt`, even for
   a miss. A `NO_OFFICIAL` row saves the next sweep from repeating the same
   dead-end search.
5. Do not run `git commit`/`git push` as part of a sweep unless the human
   running it asks you to — leave the new files staged for review.

## Re-sweep cadence

Monthly. Vendors ship official MCP servers on their own timeline; a "no
official server" verdict from last month can be stale. Re-check
`NO_OFFICIAL` and `NO_URL` rows first (cheapest to disprove), then look for
entirely new vendors worth adding to the list.

## Files

- `probe-remote-mcp.sh` — the probe script (self-contained: bash + curl +
  python3 stdlib, no external deps).
- `remote-mcp-candidates.txt` — the running tracker, append-only in spirit
  (edit a row in place only to correct a mistake, otherwise add a new dated
  row under a new sweep heading).
