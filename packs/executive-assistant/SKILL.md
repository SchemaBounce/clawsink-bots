---
apiVersion: openclaw.schemabounce.com/v1
kind: SkillPack
metadata:
  name: executive-assistant
  displayName: "Executive Assistant"
  version: "1.0.0"
  description: "Synthesizes all bot outputs, prioritizes across domains, delivers daily briefings."
  category: management
  tags: ["synthesis", "briefings", "prioritization", "follow-ups", "coordination"]
agent:
  capabilities: ["management", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "management"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
  maxTokenBudget: 100000
schedule:
  default: "@every 4h"
  recommendations:
    light: "@every 8h"
    standard: "@every 4h"
    intensive: "@every 2h"
messaging:
  listensTo:
    - { type: "alert", from: ["*"] }
    - { type: "finding", from: ["business-analyst", "accountant", "legal-compliance", "product-owner", "mentor-coach"] }
    - { type: "text", from: ["*"] }
  sendsTo:
    - { type: "request", to: ["business-analyst", "sre-devops", "accountant", "mentor-coach"], when: "needs cross-domain analysis" }
    - { type: "text", to: ["*"], when: "daily briefing distribution" }
data:
  entityTypesRead: ["sre_findings", "de_findings", "ba_findings", "acct_findings", "cs_findings", "inv_findings", "legal_findings", "mktg_findings", "sec_findings", "po_findings", "mentor_findings", "tasks", "team_health_reports", "sre_alerts", "de_alerts", "acct_alerts", "cs_alerts", "inv_alerts", "legal_alerts", "mktg_alerts", "sec_alerts", "po_alerts", "mentor_alerts"]
  entityTypesWrite: ["ea_findings", "ea_alerts", "tasks"]
  memoryNamespaces: ["working_notes", "learned_patterns", "follow_ups"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities"]
  zone2Domains: ["management", "operations", "finance", "support"]
requirements:
  minTier: "starter"
---

# Executive Assistant

The central coordinator bot. Synthesizes outputs from ALL other bots, prioritizes findings across domains, produces daily briefings, and tracks follow-up items.

## What It Does

- Reads all bot findings and alerts from every domain
- Prioritizes items against quarterly priorities from North Star
- Generates structured daily briefings
- Tracks action items and follow-ups across runs
- Routes cross-domain requests to the right specialist bot

## Escalation Behavior

This bot is the TOP of the escalation chain. It receives alerts from all bots and does not escalate further — it produces the final prioritized output for the human operator.

## Recommended Setup

Ensure these North Star keys are filled:
- `mission` — Company mission (bots align to this)
- `priorities` — Top 3 quarterly priorities (used for ranking)
- `stage` — Business stage (adjusts formality and detail)
