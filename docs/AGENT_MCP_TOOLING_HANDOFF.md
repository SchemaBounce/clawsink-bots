# Agent MCP Tooling Handoff

**Audience:** the next agent picking up this work after the SEO Expert ships its real toolkit.
**Status:** in-flight as of 2026-04-25. SEO Expert work is being executed in parallel (see `bots/seo-expert/` and the new built-ins in `core-api/openclaw-runtime/internal/executor/tools.go`). Everything else in this doc is yours.
**Single source of truth for the gap:** `scripts/audit-bot-tooling.sh` in this repo. Re-run it whenever you finish a bot.

## 1. Executive Summary

We have **63 bot manifests** in `bots/`, but only **41** are actually wired through to runtime tools. The rest are either fully disconnected (10 "none" — the agent has no path to any external system) or silently shallow (12 "shallow" — the agent declares MCP servers that are not in the core-api runtime registry, so activation auto-grant is a no-op and the user never sees a warning). The visible failure mode is the SEO Expert: it audits its own database, writes findings back to the same database, and the user reasonably asks "this is doing what?" The bar going forward: **no agent should be surface-level — every bot's domain has real-world tools and we should wire them.**

The immediate priority is the SEO Expert plus Google Search Console MCP (in flight). The rest of this doc gives you a concrete plan to close the gap on the remaining 22 bots and to prevent it from happening again.

## 2. Audit (run `bash scripts/audit-bot-tooling.sh` to refresh)

The script walks every `bots/*/BOT.md`, parses the `mcpServers[]` block, splits each ref into one of three buckets:

- **wired** — referenced server exists in `core-api/.../adl/mcp_connection_service.go` `embeddedEnvSpecs` map (line 25 onward). At runtime, activation can grant access and the agent can actually call it.
- **manifest** — there is a `tools/<name>/SERVER.md` here, but no entry in the runtime registry. The bot will activate; the tool will silently no-op.
- **unknown** — referenced server is not in `tools/` and not in the registry. Bot is broken-by-spec.

Depth scoring:

- **none** — `mcpServers: []` AND `egress.mode: "none"`. No path to anything external.
- **shallow** — at least one ref is in the `manifest` or `unknown` bucket, OR `mcpServers: []` but `egress.mode != "none"` (loose policy with no tools).
- **connected** — every declared ref is `wired`.

### Current state (snapshot, 2026-04-25)

**Totals:** 63 bots — **10 none · 12 shallow · 41 connected**

The full table is the live output of the audit script. Re-run it any time. Sample lines that matter:

```
| Bot                | #mcp | egress     | wired/manifest/unknown | Depth     |
|--------------------|-----:|------------|----------------------:|-----------|
| blog-writer        | 0    | none       | 0/0/0                 | none      |
| seo-expert         | 0    | none       | 0/0/0                 | none      |
| atlas              | 0    | none       | 0/0/0                 | none      |
| anomaly-detector   | 0    | none       | 0/0/0                 | none      |
| accountant         | 5    | none       | 3/2/0                 | shallow   |
| customer-support   | 10   | none       | 7/3/0                 | shallow   |
| executive-assistant| 10   | none       | 6/4/0                 | shallow   |
| sales-pipeline     | 9    | restricted | 5/4/0                 | shallow   |
| sre-devops         | 10   | restricted | 4/6/0                 | shallow   |
```

The `manifest` count column is the silent-shallow signal: 4 of those 10 SRE devops servers have a `tools/` entry but no runtime registry entry. The bot looks deployed; half its tools are dead.

### The 10 "none" bots

`anomaly-detector, atlas, blog-writer, data-quality-monitor, experiment-tracker, infrastructure-reporter, inventory-alert, mentor-coach, platform-optimizer, seo-expert`

`seo-expert` is being fixed in the current workstream. The other nine each need their own pass — see §3 for proposed integrations.

### The 12 "shallow" bots and their missing-runtime tools

| Bot | Missing from runtime registry |
|-----|---|
| accountant | quickbooks, xero |
| churn-predictor | google-calendar |
| customer-support | zendesk, freshdesk, intercom |
| devops-automator | aws, gcp, kubernetes, docker |
| documentation-writer | confluence, google-docs, codex |
| executive-assistant | google-calendar, gmail, google-docs, zoom |
| sales-pipeline | salesforce, hubspot, google-calendar, gmail |
| software-architect | codex |
| sre-devops | firebase, datadog, aws-cloudwatch, grafana, pagerduty, sentry |
| lead-researcher | (declared none, egress=none, web.search=false → ineffective) |
| shipping-tracker | (no servers, egress=restricted) |
| workflow-designer | (no servers, egress=llm-only) |

The first nine rows are the silent-shallow class — the bot manifests reference real, useful integrations but the runtime registry doesn't know about them, so they activate to a no-op. **This is the highest-leverage cleanup target after SEO Expert.**

## 3. Per-Domain Proposed Integrations

Each row is what a domain practitioner expects the agent to actually be able to do. Priority is ordered by "most impact for shipping value" — P0 should land before claiming the agent is non-surface-level.

### SEO (covered by current workstream)

P0: Google Search Console (real keyword data, CTR, position) ✅ in flight
P0: PageSpeed Insights (Core Web Vitals + Lighthouse) ✅ in flight
P0: in-process meta + JSON-LD audit (replaces orcascan.com OG validator) ✅ in flight
P0: GEO/LLMO citation check across Anthropic / OpenAI / Perplexity (umoren.ai concept) ✅ in flight
P1: Google Analytics 4
P2: SERP rank tracker (DataForSEO, Serper, SerpAPI)
P2: Backlink data (Ahrefs, SEMrush, Moz)

### Marketing / Blog / Content

P0: GitHub publish (already in registry) — wire via `tools/github`
P0: Exa search (already in registry) — wire via `tools/exa`
P0: Firecrawl (already in registry) — wire via `tools/firecrawl`
P1: Image generation (DALL-E, Stable Diffusion, Imagen) — new server needed
P1: Agentmail (already in registry, just declare it)
**Action:** flip blog-writer from "none" to "connected" by adding github+exa+firecrawl+agentmail to `bots/blog-writer/BOT.md.mcpServers`.

### Sales / CRM / Pipeline

P0: Salesforce — needs new runtime registry entry. Use REST API + OAuth2 client credentials.
P0: HubSpot — needs new runtime registry entry. OAuth2.
P0: Gmail — needs new runtime registry entry. Google OAuth (same flow as GSC).
P0: Google Calendar — needs new runtime registry entry. Google OAuth.
P1: Zoom — needs new runtime registry entry. OAuth2.
**Action:** add 5 entries to `embeddedEnvSpecs`; sales-pipeline + executive-assistant flip to connected.

### Support

P0: Zendesk — new runtime registry entry. API token.
P0: Intercom — new runtime registry entry. OAuth2.
P0: Freshdesk — new runtime registry entry. API key.
**Action:** 3 entries; customer-support flips to connected.

### DevOps / SRE / Observability

P0: AWS / GCP / Azure CLI auth — new runtime registry entries (or single multi-cloud entry).
P0: Kubernetes — new runtime registry entry. Use kubeconfig from workspace secret.
P0: Datadog — new runtime registry entry. API key.
P0: Sentry — new runtime registry entry. Auth token.
P0: Grafana — new runtime registry entry. API key.
P0: PagerDuty — new runtime registry entry. API key.
**Action:** 7+ entries; devops-automator + sre-devops flip to connected.

### Finance / Accounting

P0: QuickBooks Online — new runtime registry entry. OAuth2.
P0: Xero — new runtime registry entry. OAuth2.
**Action:** 2 entries; accountant flips to connected.

### Documentation / Knowledge

P0: Confluence — new runtime registry entry. OAuth2 or API token.
P0: Google Docs — new runtime registry entry. Google OAuth.
P0: Notion (already in registry) — wire via `tools/notion`.
**Action:** 2 entries; documentation-writer flips to connected.

### "None" bots needing fresh wiring

| Bot | Domain it should be in | First P0 integration |
|-----|---|---|
| anomaly-detector | Observability | Datadog or Grafana metrics |
| atlas | Geospatial / mapping | Google Maps API |
| data-quality-monitor | Data | dbt Cloud, Great Expectations, the workspace's own DB via existing ADL tools |
| experiment-tracker | Product | Statsig or LaunchDarkly or PostHog |
| infrastructure-reporter | DevOps | AWS Cost Explorer, GCP Billing |
| inventory-alert | Retail | Shopify, Square inventory |
| mentor-coach | HR / personal | LinkedIn Learning, Coursera, agentmail for coaching emails |
| platform-optimizer | DevOps | PageSpeed (reuse SEO built-in), Datadog |

Each gets its own per-bot workstream — don't try to fix all nine at once.

## 4. Install-Wizard Contract

The current state (`adl_bot_activation_handler.go:641-665`'s `autoGrantMcpAccess`) silently best-effort-grants. If the workspace doesn't have a connection, the activation succeeds and the user never finds out their bot is missing tools. **This must change.**

### Behavior to implement

When a user activates a bot from the marketplace:

1. **Marketplace deploy modal reads `BOT.md.mcpServers[]`.**
2. **For each declared server:**
   - Look up workspace `mcp_connections` (existing table) for that ref.
   - If found → continue.
   - If missing AND `required: true` → block activation. Render a **"Connect <Tool>"** CTA that opens the existing `OAuthPopup.tsx` flow (already used for Composio; reuse, don't reinvent). On success, store the connection and re-check.
   - If missing AND `required: false` → activate, but show a yellow banner on the agent's detail page: **"<Bot> can do more if you connect <Tool>"** with the same CTA.
3. **For each tool, the SERVER.md must declare:**
   - `oauth.scope` (or `auth.method` for non-OAuth)
   - `auth.redirectUri` (template like `https://{tenant}/api/v1/oauth/{provider}/callback`)
   - `setupReason` — a one-line "why this bot needs it" string the wizard renders. The current bots that work well (e.g., `tools/agentmail/SERVER.md`) already document this informally; promote it to a first-class field.
4. **Activation must surface drift.** If a referenced ref is `manifest` or `unknown` (i.e., not in `embeddedEnvSpecs`), the modal must error explicitly: "Tool `<ref>` is declared in the bot but not registered in the runtime. Activate anyway? (Tools will be inert.)" The user can override; we no longer fail silently.

### Files to touch

- `frontend/src/pages/marketplace/<bot-activation-modal>.tsx` — gate logic + CTA rendering
- `frontend/src/hooks/useOAuthPopup.ts` (existing) — reuse for new providers
- `core-api/.../adl_bot_activation_handler.go:autoGrantMcpAccess` — change from "best-effort log" to "return missing list" so the frontend can act on it. Keep the existing auto-grant for the case where the connection does exist.
- `core-api/.../adl/mcp_connection_service.go:embeddedEnvSpecs` — every server you add to a BOT.md must have a registry entry here, full stop.

## 5. Acceptance Criteria for the Receiving Agent

Run the script as the source of truth. The bar:

- [ ] `audit-bot-tooling.sh --counts-only` returns `none=0 shallow=0` for the bots you've worked. Document any deliberate "internal-only" exception in a short comment block at the top of that bot's `BOT.md` (e.g., `# Internal-only by design — runs against the workspace ADL only.`) — and mark it in the audit output.
- [ ] `embeddedEnvSpecs` covers every ref declared in any `BOT.md`. The `manifest` column for every "shallow" bot is 0 after your pass.
- [ ] Marketplace activation blocks (or warns) on missing required connections. No more silent auto-grant of nothing.
- [ ] Each new runtime registry entry has: env spec, OAuth scope (or auth method), redirect URI template, setupReason copy.
- [ ] Each bot you fix has a manual smoke test recorded in its own `bots/<name>/VERIFICATION.md`: what you ran, what you saw, what data ended up in ADL.

## 6. Order of Operations

1. **(in flight)** SEO Expert + GSC + new built-ins. Don't touch.
2. **Blog-writer** — easy win. github + exa + firecrawl + agentmail. All four are already in the runtime registry. Pure manifest update + a verification run.
3. **Sales / Support sweep** — 5 new runtime registry entries (Salesforce, HubSpot, Gmail, GoogleCalendar, Zendesk). Flips sales-pipeline, executive-assistant, customer-support, churn-predictor.
4. **DevOps / SRE sweep** — biggest. 7+ new runtime registry entries. Flips devops-automator, sre-devops.
5. **Wizard rollout** — implement the §4 contract. Frontend + handler change. Lands once, applies everywhere.
6. **The 9 remaining "none" bots** — one workstream per bot, P0 integration each.

## 7. Out of Scope (Future Plans)

- Production credential rotation, refresh-token expiry telemetry, multi-tenant OAuth callback routing.
- Paid integrations that need billing setup (Ahrefs, SEMrush, Salesforce non-trial).
- Cross-workspace credential sharing (e.g., shared "platform" connections owned by SchemaBounce admin used by every customer's bot).
- Customer-supplied MCP server registration UI (today they edit BOT.md; tomorrow they should be able to add a server in workspace settings without forking the marketplace repo).

## 8. Reference

- Audit script: `scripts/audit-bot-tooling.sh`
- Runtime registry: `core-api/schemabounce-api/internal/adl/mcp_connection_service.go:25-71`
- Activation auto-grant logic: `core-api/schemabounce-api/internal/handlers/adl_bot_activation_handler.go:641-665`
- Existing OAuth popup: `frontend/src/hooks/useOAuthPopup.ts`, `frontend/src/components/.../OAuthPopup.tsx`
- Live SEO Expert work: `bots/seo-expert/` and `core-api/openclaw-runtime/internal/executor/tools.go` (new `adl_seo_*` tools)

If anything in here is wrong by the time you pick it up, the script is the truth — re-run it first.
