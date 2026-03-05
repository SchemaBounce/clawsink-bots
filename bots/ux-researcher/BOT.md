---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: ux-researcher
  displayName: "UX Researcher"
  version: "1.0.0"
  description: "User research synthesis, feedback analysis, and usability insight generation."
  category: design
  tags: ["ux", "research", "usability", "feedback", "user-experience", "design"]
agent:
  capabilities: ["analytics", "research"]
  hostingMode: "openclaw"
  defaultDomain: "design"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "medium"
schedule:
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@every 3d"
    intensive: "@daily"
messaging:
  listensTo:
    - { type: "finding", from: ["customer-support", "product-owner"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["product-owner"], when: "usability issue or UX pattern with actionable recommendation" }
    - { type: "finding", to: ["executive-assistant"], when: "critical user experience issue affecting retention" }
data:
  entityTypesRead: ["user_feedback", "usage_analytics", "support_tickets"]
  entityTypesWrite: ["ux_findings", "usability_reports"]
  memoryNamespaces: ["user_patterns", "pain_points", "research_backlog"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities"]
  zone2Domains: ["design"]
skills:
  - ref: "skills/brand-audit@1.0.0"
automations:
  triggers:
    - entityType: "user_feedback"
      event: "created"
      prompt: "Categorize this feedback by theme and severity."
requirements:
  minTier: "starter"
---

# UX Researcher

Synthesizes user feedback, usage analytics, and support tickets into actionable UX insights. Identifies pain points, usage patterns, and opportunities to improve the user experience.

## What It Does

- Reads user feedback records and categorizes by theme (onboarding, navigation, performance, etc.)
- Analyzes usage analytics to detect drop-off points and underused features
- Reviews support tickets for recurring usability complaints
- Clusters feedback into pain point themes with severity scoring
- Writes ux_findings with actionable recommendations for product and design teams
- Produces periodic usability reports summarizing trends and improvement opportunities

## UX Finding Format

Findings are written as `ux_findings` entity type records:
```json
{
  "severity": "high",
  "theme": "onboarding",
  "pain_point": "Users abandon signup at email verification step",
  "evidence_count": 12,
  "user_impact": "30% drop-off at verification, affects new user activation",
  "recommendation": "Implement magic link or reduce verification friction",
  "source_feedback": ["fb_20260301_001", "fb_20260301_005"],
  "affected_personas": ["new_user", "trial_user"]
}
```

## Escalation Behavior

- **Critical**: Usability issue causing significant churn or data loss -> finding to executive-assistant
- **High**: Pain point with 10+ signals and clear fix -> finding to product-owner
- **Medium**: Emerging pattern needing more data -> ux_findings record + research_backlog update
- **Low**: Individual feedback note -> user_patterns memory update
