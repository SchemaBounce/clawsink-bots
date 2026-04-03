# Frontend Handoff: Bot Setup Modal & Goals Dashboard

**Design doc:** `docs/plans/2026-04-01-bot-readiness-goals-design.md`
**Manifest spec:** `bots/README.md` (sections: Setup Section, Goals Section)
**Run report schema:** `shared/output-format.md` (section: Run Report Schema)

---

## What Changed in the Manifest

Every BOT.md now has two new YAML frontmatter sections: `setup:` and `goals:`. The platform parses these from GitHub (same as existing fields) and passes them to the frontend via the marketplace API.

All 59 bots have these sections. All 25 teams with pilot coverage have `teamGoals:`.

---

## 1. Setup Modal

### When It Appears

After a user deploys a bot (or team), show the setup modal for that bot. The modal is the bridge between "bot deployed" and "bot ready to work."

- **On first deploy**: Auto-open after activation succeeds
- **On revisit**: Accessible from the agent detail page ("Setup" tab or button)
- **Re-validation**: Steps should re-check on each visit (a Slack connection may have broken)

### Data Source

The `setup.steps[]` array from the bot's manifest. Available from the existing `getSkillPackDetail()` API response — the manifest already includes all frontmatter fields.

### TypeScript Types

```typescript
// Add to src/types/agentDataLayer/marketplace.ts

interface BotSetupStep {
  id: string;                    // kebab-case, unique within bot
  name: string;                  // Display label (<60 chars)
  description: string;           // Explanation (<200 chars)
  type: 'mcp_connection' | 'secret' | 'config' | 'data_presence' | 'north_star' | 'manual';
  group: 'connections' | 'configuration' | 'data' | 'external';
  priority: 'required' | 'recommended' | 'optional';
  reason: string;                // Why the bot needs this (<200 chars)

  // Type-specific fields (only one set applies per step)
  ref?: string;                  // mcp_connection: "tools/{name}"
  secretName?: string;           // secret: workspace secret key
  entityType?: string;           // data_presence: entity type to query
  minCount?: number;             // data_presence: minimum record count
  target?: {                     // config: where value is stored
    namespace: string;
    key: string;
  };
  key?: string;                  // north_star: zone1 key name

  // UI rendering hints
  ui: BotSetupStepUI;
}

interface BotSetupStepUI {
  icon?: string;                 // Icon identifier (slack, stripe, github, email, etc.)
  inputType?: 'password' | 'text' | 'number' | 'slider' | 'select' | 'toggle';
  actionLabel?: string;          // Button text ("Connect Slack", "I've enabled webhooks")
  placeholder?: string;
  helpUrl?: string;              // External docs link
  validationHint?: string;       // Format hint ("Starts with sk_live_")
  instructions?: string;         // Multi-line markdown (manual type)
  min?: number;                  // Slider/number min
  max?: number;                  // Slider/number max
  step?: number;                 // Slider/number increment
  unit?: string;                 // Display unit (%, min, etc.)
  default?: unknown;             // Default value (string, number, or object)
  options?: { value: string; label: string }[];  // Select dropdown options
  prefillFrom?: string;          // Auto-fill key (e.g., "workspace.industry")
  emptyState?: string;           // data_presence: message when no records found
}

type ReadinessLevel = 'blocked' | 'operational' | 'fully_configured' | 'optimized';

interface BotSetupStatus {
  agentId: string;
  botName: string;
  readinessLevel: ReadinessLevel;
  steps: {
    id: string;
    status: 'complete' | 'incomplete' | 'error';
    completedAt?: string;
    errorMessage?: string;
  }[];
  requiredComplete: number;
  requiredTotal: number;
  recommendedComplete: number;
  recommendedTotal: number;
  lastValidated: string;
}
```

### Component → Step Type Mapping

Each step `type` renders a specific component. The `ui` object provides all props.

| Step Type | Component | User Action | Auto-validates |
|-----------|-----------|-------------|---------------|
| `mcp_connection` | `ConnectionButton` | Click → OAuth/config flow opens | Yes — platform pings server |
| `secret` | `SecretInput` (masked) | Paste key → Save | Yes — non-empty check |
| `config` | Varies by `ui.inputType` | Set value → Save to memory | Yes — type check |
| `data_presence` | `DataStatusBadge` + import CTA | Import data or confirm existing | Yes — query count |
| `north_star` | `NorthStarInput` (text/select) | Enter value → Save to zone1 | Yes — non-empty check |
| `manual` | `ManualCheckbox` + instructions | Check "I've done this" | No — user attestation |

#### Config sub-components by `ui.inputType`

| `inputType` | Component | Notes |
|-------------|-----------|-------|
| `text` | `<Input>` | Use `placeholder` from ui |
| `password` | `<Input type="password">` | Use `validationHint` |
| `number` | `<NumberInput>` | Use `min`, `max`, `step` |
| `slider` | `<Slider>` | Use `min`, `max`, `step`, `default` |
| `select` | `<Select>` | Use `ui.options[]` for dropdown items |
| `toggle` | `<Switch>` | Boolean config |

### Modal Layout

```
┌─────────────────────────────────────────────────────┐
│  Setup: Fraud Detector                         [X]  │
│  ─────────────────────────────────────────────────── │
│  ████████░░ 3 of 4 required steps complete          │
│                                                     │
│  CONNECTIONS                                        │
│  ┌─────────────────────────────────────────────┐    │
│  │ ✅ Connect payment processor    [Connected]  │    │
│  │ ⬜ Connect Slack for alerts     [Connect]    │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  CONFIGURATION                                      │
│  ┌─────────────────────────────────────────────┐    │
│  │ ✅ Define risk policy          [Balanced ▾]  │    │
│  │ ✅ Set business industry       [FinTech  ▾]  │    │
│  │ ✅ Set fraud score threshold   [═══●═══ 0.8] │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  DATA                                               │
│  ┌─────────────────────────────────────────────┐    │
│  │ ⬜ Import historical transactions            │    │
│  │    0 records — Import via CSV or connect     │    │
│  │    your payment processor first.             │    │
│  │                            [Import →]        │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  ─────────────────────────────────────────────────── │
│  [Skip for now]              [Activate Bot ✓]       │
│  (bot won't run until required steps complete)      │
└─────────────────────────────────────────────────────┘
```

**Grouping:** Steps grouped by `group` field. Group display order: connections → configuration → data → external.

**Within groups:** Required steps first (red/green indicator), then recommended (yellow), then optional (gray).

**Progress bar:** Shows required step completion only. "N of M required steps complete."

**Activate button:** Enabled when all `required` steps are complete. Disabled state shows tooltip: "Complete all required steps to activate."

**Skip for now:** Always available. Bot deploys in `blocked` state. User can return later.

### Readiness Badge (Agent Card / Agent List)

Show a colored badge on the agent card in the roster:

| Level | Color | Label | When |
|-------|-------|-------|------|
| `blocked` | Red | "Setup Required" | Any required step incomplete |
| `operational` | Yellow | "Basic Setup" | All required done, some recommended missing |
| `fully_configured` | Green | "Ready" | All required + recommended done |
| `optimized` | Blue | "Optimized" | All steps done (rare, nice to have) |

Clicking the badge opens the setup modal for that agent.

### API Endpoints Needed (core-api)

```
GET  /workspaces/{id}/agents/{agentId}/setup-status
     → BotSetupStatus (computed from manifest + current state)

POST /workspaces/{id}/agents/{agentId}/setup-steps/{stepId}/validate
     → { status: 'complete' | 'incomplete' | 'error', message?: string }

POST /workspaces/{id}/agents/{agentId}/setup-steps/{stepId}/complete
     → Saves the value (secret, config, north star, or manual attestation)
```

The GET endpoint re-validates all steps on each call. The frontend should call it when the modal opens and after each step completion to refresh state.

### `prefillFrom` Resolution

When a step has `ui.prefillFrom: "workspace.industry"`, the frontend should:
1. Read the workspace business profile (already available from settings API)
2. Pre-fill the input with the matching value
3. User can override

Pattern: `prefillFrom` is dot-notation into workspace context. Currently only `workspace.{key}` is supported.

---

## 2. Goals Dashboard

### Where It Appears

- **Agent detail page**: New "Goals" tab alongside existing tabs (Config, Runs, Messages)
- **Team page**: Team-level goal rollup section
- **Workspace dashboard**: ROI summary widget

### Data Sources

Two new entity types in the ADL (computed by platform, not written by frontend):

1. **`bot_goal_health`** — Weekly aggregation of goal achievement from run reports
2. **`run_report`** — Per-run self-assessment written by the bot

The frontend reads these via existing `adl_query_records` patterns (same API as other entity queries).

### TypeScript Types

```typescript
// Add to src/types/agentDataLayer/marketplace.ts

interface BotGoal {
  name: string;                  // snake_case, unique within bot
  description: string;           // (<120 chars)
  category: 'primary' | 'secondary' | 'health';
  metric: BotGoalMetric;
  target: BotGoalTarget;
  feedback?: BotGoalFeedback;
}

interface BotGoalMetric {
  type: 'count' | 'rate' | 'threshold' | 'boolean';
  // count
  entity?: string;
  filter?: Record<string, unknown>;
  source?: 'memory';
  namespace?: string;
  // rate
  numerator?: { entity: string; filter?: Record<string, unknown> };
  denominator?: { entity: string; filter?: Record<string, unknown> };
  // threshold
  measurement?: string;
  // boolean
  check?: string;
}

interface BotGoalTarget {
  operator: '>' | '<' | '>=' | '<=' | '==' | 'between';
  value: number;
  period: 'per_run' | 'daily' | 'weekly' | 'monthly';
  condition?: string;            // Human-readable qualifier
}

interface BotGoalFeedback {
  enabled: boolean;
  entityType: string;            // Which records get feedback buttons
  actions: { value: string; label: string }[];
}

// Run report (read from ADL records)
interface RunReport {
  runId: string;
  agentId: string;
  timestamp: string;
  durationMs: number;
  goals: RunReportGoalStatus[];
  setupIssues: { stepId: string; impact: string }[];
  blockers: { type: string; description: string }[];
  overall: 'productive' | 'limited' | 'idle' | 'blocked';
}

interface RunReportGoalStatus {
  name: string;
  status: 'achieved' | 'partial' | 'missed' | 'blocked' | 'not_applicable';
  value?: number;
  target?: string;
  context?: string;
  reason?: string;
}

// Goal health (weekly aggregation, computed by platform)
interface BotGoalHealth {
  agentId: string;
  botName: string;
  period: 'weekly';
  periodStart: string;
  goals: {
    name: string;
    achievementRate: number;      // 0-1
    trend: 'improving' | 'stable' | 'declining';
    lastValue?: number;
    feedbackScore?: number;       // 0-1 (if feedback enabled)
  }[];
  overallHealth: 'healthy' | 'degraded' | 'underperforming';
  productiveRuns: number;
  limitedRuns: number;
  idleRuns: number;
  blockedRuns: number;
}
```

### Agent Detail — Goals Tab Layout

```
┌────────────────────────────────────────────────────────┐
│  Fraud Detector  ●  Online  [Setup ✓] [Goals] [Runs]  │
│  ────────────────────────────────────────────────────── │
│                                                        │
│  PRIMARY GOALS                                         │
│  ┌──────────────────────┐ ┌──────────────────────┐     │
│  │ Flag Transactions    │ │ Detection Accuracy   │     │
│  │      12              │ │      87%             │     │
│  │  flagged this run    │ │  confirmed rate      │     │
│  │  target: >0  ✅      │ │  target: >85%  ✅    │     │
│  │  trend: stable ━━━   │ │  trend: improving ↗  │     │
│  └──────────────────────┘ └──────────────────────┘     │
│                                                        │
│  SECONDARY                          HEALTH             │
│  ┌──────────────────────┐ ┌──────────────────────┐     │
│  │ Escalation Speed     │ │ Pattern Learning     │     │
│  │ 2.3 min avg          │ │ 14 patterns learned  │     │
│  │ target: <5 min  ✅   │ │ target: >0/mo  ✅    │     │
│  └──────────────────────┘ └──────────────────────┘     │
│                                                        │
│  RECENT RUNS                                           │
│  ┌─────┬────────────┬──────────┬──────────────────┐    │
│  │ Run │ Overall    │ Goals    │ Issues           │    │
│  ├─────┼────────────┼──────────┼──────────────────┤    │
│  │ #47 │ productive │ 3/4 ✅   │ —                │    │
│  │ #46 │ limited    │ 1/4 ⚠️   │ Slack not setup  │    │
│  │ #45 │ idle       │ 0/4 ⏸️   │ No new data      │    │
│  │ #44 │ productive │ 4/4 ✅   │ —                │    │
│  └─────┴────────────┴──────────┴──────────────────┘    │
└────────────────────────────────────────────────────────┘
```

**Primary goals:** Large stat cards. Show current value, target, achievement status (check/x), trend arrow.

**Secondary + Health goals:** Smaller cards in a grid below.

**Recent runs:** Table of last 10 run reports. Click a row to expand goal details.

**Overall status color coding:**
- `productive` → green
- `limited` → yellow
- `idle` → gray
- `blocked` → red

### Trend Indicators

Computed from the last 4 `bot_goal_health` weekly records:

| Trend | Icon | When |
|-------|------|------|
| `improving` | ↗ (green) | Achievement rate increased 2+ consecutive periods |
| `stable` | → (gray) | Fluctuation < 5% |
| `declining` | ↘ (red) | Achievement rate decreased 2+ consecutive periods |

---

## 3. Feedback Buttons

### Where They Appear

On entity record cards/rows in the agent detail view. Only for entities referenced by a goal with `feedback.enabled: true`.

### How It Works

1. Bot writes a finding (e.g., `fraud_scores` entity)
2. Frontend renders the finding card with feedback action buttons from `goals[].feedback.actions[]`
3. User clicks "Confirmed fraud" or "Not fraud"
4. Frontend writes the feedback value to the entity record via existing `adl_upsert_record` API
5. Bot reads feedback on next run → updates its `rate` metric goals
6. `bot_goal_health` aggregation reflects the feedback

### UI Pattern

```
┌────────────────────────────────────────────┐
│ ⚠️ Suspicious Transaction #TXN-2847       │
│ $4,200 charge from unusual location        │
│ Risk score: 0.91 | Category: geo_anomaly   │
│                                            │
│ Was this helpful?                           │
│ [✅ Confirmed fraud] [❌ Not fraud] [🔍 Needs review] │
│                                            │
│ Selected: ✅ Confirmed fraud  (2 min ago)  │
└────────────────────────────────────────────┘
```

- Buttons are rendered from `feedback.actions[]` — label and value come from the manifest
- After selection, show the selected action with timestamp
- Allow changing the selection (overwrite)
- Store as `{ feedback: "confirmed" }` field on the entity record

---

## 4. Team Health View

### Where It Appears

Team detail page (accessible from org chart or marketplace). Shows aggregated health from member bots.

### Data

Read `teamGoals` from TEAM.md manifest + `bot_goal_health` records for each member bot.

### Layout

```
┌─────────────────────────────────────────────────────┐
│  SaaS Starter Team                    Health: 87%   │
│  ─────────────────────────────────────────────────── │
│                                                     │
│  TEAM GOALS                                         │
│  ┌───────────────────────────┐ ┌──────────────────┐ │
│  │ Engineering Reliability   │ │ Customer Health  │ │
│  │ 96% SLA compliance       │ │ 82% resolution   │ │
│  │ target: >95%  ✅          │ │ target: >80%  ✅  │ │
│  │ sre-devops (60%)         │ │ cs (50%) + cs    │ │
│  │ + sre-devops (40%)       │ │ (50%)            │ │
│  └───────────────────────────┘ └──────────────────┘ │
│                                                     │
│  MEMBER BOT STATUS                                  │
│  ┌──────────────────┬──────────┬──────────┬───────┐ │
│  │ Bot              │ Setup    │ Goals    │ Runs  │ │
│  ├──────────────────┼──────────┼──────────┼───────┤ │
│  │ Executive Asst   │ ✅ Ready │ 3/4 ✅   │ 12/wk │ │
│  │ SRE / DevOps     │ ✅ Ready │ 4/5 ✅   │ 42/wk │ │
│  │ Code Reviewer    │ ⚠️ Basic │ 2/4 ⚠️   │ 8/wk  │ │
│  │ Marketing Growth │ ✅ Ready │ 3/4 ✅   │ 7/wk  │ │
│  │ Sales Pipeline   │ 🔴 Setup │ —        │ 0/wk  │ │
│  │ Customer Support │ ✅ Ready │ 4/5 ✅   │ 84/wk │ │
│  │ Platform Optim.  │ ✅ Ready │ 3/5 ✅   │ 7/wk  │ │
│  └──────────────────┴──────────┴──────────┴───────┘ │
│                                                     │
│  ⚠️ Sales Pipeline needs setup → [Open Setup]       │
└─────────────────────────────────────────────────────┘
```

**Team health score** = weighted composite (40% setup, 40% goals, 20% comms) — computed by platform API.

**Member bot table:** Click row → navigates to agent detail page.

**Setup CTA:** If any bot is `blocked`, show prominent CTA to open that bot's setup modal.

---

## 5. Workspace ROI Dashboard

### Where It Appears

ADL Dashboard page — new "Workforce Health" widget at the top.

### Metrics (all computed by platform API)

| Metric | Source | Display |
|--------|--------|---------|
| Workforce Readiness | `bot_setup_status` | "32/38 fully configured" + progress ring |
| Goal Achievement | `bot_goal_health` | "78% this week" + trend sparkline |
| Productivity | `run_report` overall | Donut: productive/limited/idle/blocked |
| Feedback Score | Feedback on findings | "89% confirmed useful" |
| Token Efficiency | Tokens per productive run | "Avg 4.2K tokens/run" |

### Layout

```
┌────────────────────────────────────────────────────────────┐
│  AI Workforce Health                                       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│  │ Readiness│ │  Goals   │ │Productive│ │ Feedback │     │
│  │  32/38   │ │   78%    │ │   82%    │ │   89%    │     │
│  │  ██████░ │ │   ↗ +3%  │ │ ████████ │ │  ✅ Good  │     │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘     │
│                                                            │
│  ⚠️ 6 bots need attention:                                │
│  • Sales Pipeline — setup incomplete  [Fix →]             │
│  • Code Reviewer — 3 runs blocked this week  [View →]     │
│  • Bug Triage — goal achievement declining  [View →]      │
└────────────────────────────────────────────────────────────┘
```

**"Needs attention" list:** Bots with `blocked` readiness or `declining` goal trends. Links to setup modal or goal tab respectively.

---

## 6. API Endpoints Summary (core-api must provide)

| Method | Path | Returns | Used By |
|--------|------|---------|---------|
| `GET` | `/agents/{id}/setup-status` | `BotSetupStatus` | Setup modal, readiness badge |
| `POST` | `/agents/{id}/setup-steps/{stepId}/validate` | Step validation result | Setup modal (per-step check) |
| `POST` | `/agents/{id}/setup-steps/{stepId}/complete` | Updated step status | Setup modal (save value) |
| `GET` | `/agents/{id}/goal-health` | `BotGoalHealth` | Goals tab |
| `GET` | `/agents/{id}/run-reports?limit=10` | `RunReport[]` | Goals tab (recent runs) |
| `GET` | `/teams/{id}/health` | Team health composite | Team health view |
| `GET` | `/workspace/roi-summary` | Workspace ROI metrics | Dashboard widget |
| `POST` | `/records/{entityType}/{id}/feedback` | Updated record | Feedback buttons |

All endpoints follow existing ADL API patterns: camelCase JSON, bearer auth, workspace-scoped.

---

## 7. Implementation Priority

### Phase 1 (MVP — ship first)
1. **Setup modal** — Renders from manifest, validates steps, blocks bot if required steps incomplete
2. **Readiness badge** — Shows on agent cards in the roster
3. **Setup status on agent detail** — "Setup" tab with step checklist

### Phase 2 (Goals visibility)
4. **Goals tab** — Agent detail page, reads run_reports + bot_goal_health
5. **Feedback buttons** — On finding cards for goals with feedback.enabled
6. **Run report history** — Table in goals tab

### Phase 3 (Rollup)
7. **Team health view** — Aggregated member bot health
8. **Workspace ROI widget** — Dashboard summary
9. **"Needs attention" alerts** — Proactive list of blocked/declining bots

---

## 8. Existing Code to Extend

| What | File | Change |
|------|------|--------|
| Bot manifest types | `src/types/agentDataLayer/marketplace.ts` | Add `BotSetupStep`, `BotGoal`, `BotSetupStatus`, `BotGoalHealth`, `RunReport` |
| Team manifest types | `src/types/agentDataLayer/marketplace.ts` | Add `TeamGoal` to `TeamPackManifest` |
| API client | `src/services/api/agentDataLayer/agents.ts` | Add `getSetupStatus()`, `validateStep()`, `completeStep()`, `getGoalHealth()`, `getRunReports()` |
| React Query hooks | `src/hooks/useAgentDataLayer.ts` | Add `useSetupStatus()`, `useGoalHealth()`, `useRunReports()` |
| Agent detail page | `src/pages/workspaces/agent-data-layer/AgentManagementPage.tsx` | Add Setup tab, Goals tab |
| Agent card | Roster grid component | Add readiness badge |
| Activation flow | `TeamActivationModal.tsx` / deploy bot modal | Open setup modal after activation |
| ADL Dashboard | Dashboard page | Add ROI widget |

---

## 9. Key Decisions for Frontend

1. **JSON casing**: ADL APIs use **camelCase**. The YAML manifest uses snake_case for field names within setup/goals, but the API will serialize to camelCase. Use the API response types, not raw YAML parsing.

2. **Setup modal is per-agent, not per-bot**: Two agents deployed from the same bot have independent setup status. The manifest defines WHAT steps exist; the platform tracks completion per agent.

3. **Feedback is additive**: Once a user provides feedback on a finding, the bot reads it on next run. The frontend never needs to compute goal metrics — just write the feedback value and let the platform aggregate.

4. **Re-validation**: Call `GET /agents/{id}/setup-status` fresh each time the modal opens. Don't cache setup status aggressively — connections can break between visits. Use `staleTime: 0` for this query.

5. **No new pages needed**: Everything fits into existing pages (agent detail, team detail, dashboard). Just new tabs and widgets.
