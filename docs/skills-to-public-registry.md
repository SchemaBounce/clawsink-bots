# Skills moved to the public registry (dec-202)

Decision dec-202 (proposed 2026-10-24, supersedes dec-200): SchemaBounce authors exactly one skill,
`schemabounce`, which lives in SchemaBounce/schemabounce-agent-kit (`skills/schemabounce`) and is
referenced here as `skills/schemabounce`. This repository authors no skills. Domain know-how comes from
public registry skills (`registry:<owner>/<repo>/<skill>`, see [skills/README.md](../skills/README.md)),
and where no credible public skill exists the bot's own `SOUL.md` / `AGENTS.md` carries the procedure.

This file is the record of why each bot got the skills it has. Every candidate below was checked on
2026-10-24 for three things:

1. **Exists.** The exact id is returned by `https://skills.sh/api/search`, and the `SKILL.md` is present at the
   default branch of its GitHub repository (the resolver reads the repository, not the index).
2. **Audit.** `https://skills.sh/api/v1/skills/audit/<owner>/<repo>/<skill>` has no partner with status `fail`
   and no `CRITICAL` risk level. A `warn` is listed, not hidden.
3. **Fit.** The `SKILL.md` body does the old skill's job.

## Verified replacements

| Old skill(s) | Public skill | Installs | Partner audits | Fit |
|---|---|---:|---|---|
| ab-testing | `coreyhaines31/marketingskills/ab-testing` | 76,376 | Trust Hub, Socket, Snyk pass | Test design, hypotheses, sample size and result reading. |
| seo-operations, rank-tracking | `coreyhaines31/marketingskills/seo-audit` | 236,199 | Trust Hub, Socket, Runlayer, ZeroLeaks pass; Snyk warn | Technical, on-page and content SEO audit. Rank snapshots are not covered; `seo-expert` keeps that procedure in its own BOT.md. |
| geo-aeo | `coreyhaines31/marketingskills/ai-seo` | 149,918 | Trust Hub, Socket, Snyk, ZeroLeaks pass; Runlayer warn | Answer-engine and generative-engine optimization, AI citations. |
| brand-audit | `anthropics/knowledge-work-plugins/brand-review` | 3,135 | all 5 partners pass | Reviews content against brand voice and style guide, flags deviations by severity. Below the 5k install guide; best match found, published by Anthropic. `anthropics/skills/brand-guidelines` was rejected (it applies Anthropic's own brand). |
| social-publishing | `coreyhaines31/marketingskills/social` | 83,687 | Trust Hub, Socket, Runlayer, ZeroLeaks pass; Snyk warn (MEDIUM) | Creating, scheduling and optimizing social content. The index still lists `social-content` (67,002) but that skill was renamed to `social` upstream and no longer exists at the repository head, so it would not resolve. The human-approval gate for publishing is not in any public skill; it stays in `social-media-manager`'s own text and in each publishing server's SERVER.md. |
| implementation-planning | `obra/superpowers/writing-plans` | 282,859 | all 5 pass | Multi-step implementation plans from a spec. |
| test-generation | `obra/superpowers/test-driven-development` | 259,292 | all 5 pass | Test-first discipline. Closest public match; it is about writing the failing test first, not bulk generation. |
| code-review | `mattpocock/skills/code-review` | 791,639 | Trust Hub, Socket pass; Snyk warn | Two-axis review (standards and spec) of a diff. Expects an issue tracker to be configured. |
| ticket-writing | `mattpocock/skills/to-tickets` | 711,230 | Trust Hub, Socket pass; Snyk warn | Breaks a plan into vertical-slice tickets with blocking edges. Declares `disable-model-invocation`, which a hosted agent may ignore. |
| pr-creation | `addyosmani/agent-skills/git-workflow-and-versioning` | 58,536 | Trust Hub, Socket, Snyk, ZeroLeaks pass; Runlayer warn | Commits, branches and pull request hygiene. |
| sprint-planning | `anthropics/knowledge-work-plugins/sprint-planning` | 3,082 | all 5 pass | Sprint scope, capacity and goals. Below the 5k install guide; the named candidate, matches exactly. |
| incident-triage | `anthropics/knowledge-work-plugins/incident-response` | 5,845 | all 5 pass | Severity assessment, response workflow, postmortem. |
| design-systems | `anthropics/skills/frontend-design` | 1,027,758 | all 5 pass | Visual direction, type, spacing and components. |
| accessible-responsive-ui | `addyosmani/web-quality-skills/accessibility` | 63,679 | all 5 pass | WCAG audit guidance. |
| conversion-page-design | `coreyhaines31/marketingskills/cro` | 89,482 | Trust Hub, Socket pass; Snyk warn (MEDIUM) | Conversion optimization of marketing pages. The named `page-cro` (57,463) is indexed but gone from the repository head (renamed `cro`). |
| budget-monitoring | `anthropics/knowledge-work-plugins/variance-analysis` | 3,240 | all 5 pass | Budget against actual, variance drivers and thresholds. Below the 5k install guide; Anthropic finance skill, direct match. |

## Mapped to none

| Old skill(s) | Why none |
|---|---|
| sentiment-analysis | `coreyhaines31/marketingskills/customer-research` (114,222; audit passes, Snyk warn) is voice-of-customer research method, not per-record sentiment classification. The old job stays in the bot's own words. |
| trend-analysis, anomaly-detection | Searches for data analysis, statistics, time series and anomaly detection returned no credible match: the large ones are cloud-vendor tooling (Kusto, Elastic) or office-document skills, the generic ones are under 3,000 installs. |
| invoice-categorization, expense-tracking | The Anthropic finance skills found (`journal-entry` 2,741, `reconciliation` 3,508, `close-management` 3,018) prepare entries and reconcile ledgers; none classifies invoices or flags duplicate charges. |
| channel-listing-sync, dynamic-pricing, guest-message-templating, listing-optimization, review-response-generation, turnover-scheduling, sla-compliance | No public skill for short-term-rental operations or SLA tracking. |

## Covered by `skills/schemabounce`

platform-awareness, inter-agent-comms, task-management, notification-dispatch, ui-navigation, mcp-awareness,
tool-packs-awareness, data-ops, data-maintenance, data-validation, record-monitoring, cdc-event-analysis,
pipeline-monitoring, pipeline-proposer, data-dependency-discovery, workflow-designer, workflow-ops,
scheduled-report, report-generation, daily-briefing, cross-domain-synthesis, follow-up-tracking.

## What each bot got

Every bot lists `skills/schemabounce` first. Bots not listed below carry only that ref. "Dropped" is an old
domain skill with no public replacement (its procedure now lives in the bot's own instructions or is gone).

| Bot | Public skills |
|---|---|
| accountant | `variance-analysis` (dropped: invoice-categorization, expense-tracking) |
| accounts-receivable-manager | none (dropped: invoice-categorization) |
| anomaly-detector | none (dropped: anomaly-detection) |
| api-tester | `test-driven-development` |
| blog-writer | none (dropped: trend-analysis, sentiment-analysis) |
| brand-guardian | `brand-review` |
| bug-triage | `incident-response` |
| ci-medic | `incident-response` |
| code-reviewer | `code-review` |
| coding-agent | `writing-plans`, `test-driven-development`, `git-workflow-and-versioning` |
| crm-hygiene-manager | none (dropped: trend-analysis) |
| demand-signal-scout | `social` |
| devops-automator | `incident-response` |
| devrel | none (dropped: sentiment-analysis, trend-analysis) |
| documentation-writer | `git-workflow-and-versioning` |
| experiment-tracker | `ab-testing` |
| growth-hacker | `ab-testing` (dropped: trend-analysis) |
| incident-commander | `incident-response` (dropped: anomaly-detection) |
| market-intelligence | none (dropped: trend-analysis) |
| meeting-summarizer | `to-tickets` |
| mentor-coach | none (dropped: trend-analysis) |
| platform-optimizer | none (dropped: trend-analysis) |
| release-manager | `git-workflow-and-versioning` |
| release-notes-writer | `git-workflow-and-versioning` |
| renewal-manager | none (dropped: trend-analysis, sentiment-analysis) |
| revenue-leakage-manager | none (dropped: anomaly-detection, trend-analysis) |
| revops | none (dropped: trend-analysis) |
| seo-expert | `seo-audit`, `ai-seo` |
| social-media-manager | `social` |
| social-media-monitor | none (dropped: sentiment-analysis) |
| social-media-strategist | none (dropped: trend-analysis, sentiment-analysis) |
| software-architect | `to-tickets`, `writing-plans`, `test-driven-development`, `git-workflow-and-versioning` |
| sprint-planner | `sprint-planning` |
| sre-devops | `incident-response` (dropped: sla-compliance) |
| str-channel-manager | `social` (dropped: channel-listing-sync) |
| str-guest-communicator | none (dropped: guest-message-templating) |
| str-pricing-optimizer | none (dropped: dynamic-pricing) |
| str-property-marketer | `social` (dropped: listing-optimization) |
| str-review-manager | none (dropped: review-response-generation) |
| str-turnover-coordinator | none (dropped: turnover-scheduling) |
| tech-debt-tracker | none (dropped: trend-analysis) |
| uptime-manager | `incident-response` (dropped: sla-compliance) |
| ux-researcher | `brand-review` |
| web-designer | `frontend-design`, `accessibility`, `cro` |
