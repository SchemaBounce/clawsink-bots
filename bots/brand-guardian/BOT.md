---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: brand-guardian
  displayName: "Brand Guardian"
  version: "1.0.0"
  description: "Brand consistency monitoring, guideline enforcement, and asset review."
  category: design
  tags: ["brand", "consistency", "guidelines", "design", "content-review", "brand-audit"]
agent:
  capabilities: ["analytics", "compliance"]
  hostingMode: "openclaw"
  defaultDomain: "design"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 10000
  estimatedCostTier: "low"
schedule:
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@every 3d"
    intensive: "@daily"
messaging:
  listensTo:
    - { type: "finding", from: ["marketing-growth"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant brand drift or guideline violation detected" }
data:
  entityTypesRead: ["brand_assets", "content_items", "brand_guidelines"]
  entityTypesWrite: ["brand_findings", "brand_scores"]
  memoryNamespaces: ["brand_drift_log", "guideline_updates"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities"]
  zone2Domains: ["design"]
skills:
  - ref: "skills/brand-audit@1.0.0"
automations:
  triggers:
    - entityType: "content_items"
      event: "created"
      prompt: "Check this content against brand guidelines."
requirements:
  minTier: "starter"
---

# Brand Guardian

Monitors all new content and brand assets for consistency with brand guidelines. Scores content against tone, visual, and messaging standards, and flags drift early before it compounds.

## What It Does

- Reviews new content items against established brand guidelines
- Scores content on tone, visual identity, messaging consistency, and terminology
- Tracks brand drift over time and identifies systematic deviations
- Maintains a brand_drift_log to detect gradual guideline erosion
- Writes brand_findings with specific corrections and improvement suggestions
- Produces brand_scores for every piece of reviewed content

## Brand Score Format

Scores are written as `brand_scores` entity type records:
```json
{
  "content_id": "content_20260301_001",
  "overall_score": 85,
  "tone_score": 90,
  "visual_score": 80,
  "messaging_score": 85,
  "terminology_score": 82,
  "violations": ["Used informal tone in enterprise documentation"],
  "suggestions": ["Replace 'stuff' with 'materials' per voice guidelines"],
  "reviewed_at": "2026-03-01T10:00:00Z"
}
```

## Escalation Behavior

- **Critical**: Systematic brand violation across multiple content items -> finding to executive-assistant
- **High**: Single content item with score below 60 -> brand_findings + flag for review
- **Medium**: Minor drift detected in tone or terminology -> brand_findings record
- **Low**: Cosmetic suggestion -> guideline_updates memory note
