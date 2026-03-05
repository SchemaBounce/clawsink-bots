---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: mentor-coach
  displayName: "Mentor / Coach"
  version: "1.0.0"
  description: "Bot team performance analysis, process improvement, harmony monitoring, weekly team health reports."
  category: management
  tags: ["mentor", "coaching", "team-health", "performance", "harmony", "process-improvement"]
agent:
  capabilities: ["analytics", "research"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
schedule:
  default: "@weekly"
  recommendations:
    light: "@every 14d"
    standard: "@weekly"
    intensive: "@every 3d"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "weekly team health report or critical process issue" }
data:
  entityTypesRead: ["sre_findings", "de_findings", "ba_findings", "acct_findings", "cs_findings", "inv_findings", "legal_findings", "mktg_findings", "ea_findings", "sec_findings", "po_findings"]
  entityTypesWrite: ["mentor_findings", "mentor_alerts", "team_health_reports"]
  memoryNamespaces: ["working_notes", "learned_patterns", "team_baselines", "improvement_log"]
zones:
  zone1Read: ["mission", "priorities"]
  zone2Domains: ["operations"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Mentor / Coach

The meta-agent that makes the entire bot team better over time. Analyzes bot performance, identifies process gaps, tracks improvement trends, and writes weekly team health reports.

## What It Does

- Reviews ALL bot findings across the team for quality, consistency, and actionability
- Reads Claw Sink researcher theses and calibration stats for system-level insights
- Monitors harmony scores across the 5 ethical dimensions
- Identifies bots that are underperforming (low finding quality, missed escalations, stale memory)
- Tracks process improvement over time (are recommendations being followed?)
- Writes weekly team health reports with scores, trends, and specific coaching recommendations
- Suggests SOUL.md refinements when a bot's behavior pattern drifts from its mission

## Team Health Report Format

Reports are written as `team_health_reports` entity type records:
```json
{
  "period": "2026-02-17 to 2026-02-24",
  "overall_score": 82,
  "bot_scores": {
    "sre-devops": 90,
    "accountant": 75,
    "customer-support": 88
  },
  "highlights": ["SRE detected 3 incidents before impact", "Accountant needs more transaction data"],
  "coaching": [
    {"bot": "accountant", "issue": "Low finding frequency", "recommendation": "Seed more transaction entity types"},
    {"bot": "inventory-manager", "issue": "Stale stock_levels memory", "recommendation": "Increase schedule to @every 6h"}
  ],
  "harmony": {"composite": 0.85, "trend": "stable"}
}
```

## Escalation Behavior

- **Critical**: Bot consistently failing or producing harmful outputs → alert to executive-assistant
- **High**: Team-wide process gap or harmony score drop → finding to executive-assistant
- **Medium**: Individual bot coaching recommendation → mentor_findings record
- **Low**: Incremental improvement tracking → improvement_log memory update
