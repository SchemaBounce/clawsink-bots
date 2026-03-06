---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: knowledge-base-curator
  displayName: "Knowledge Base Curator"
  version: "1.0.0"
  description: "Organizes and updates knowledge base articles."
  category: productivity
  tags: ["knowledge", "documentation", "organization"]
agent:
  capabilities: ["content_organization", "knowledge_management"]
  hostingMode: "openclaw"
  defaultDomain: "general"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: "@weekly"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant insight discovered" }
data:
  entityTypesRead: ["kb_articles", "usage_analytics"]
  entityTypesWrite: ["kb_updates", "organization_suggestions"]
  memoryNamespaces: ["content_quality", "search_patterns"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["general"]
skills:
  - ref: "skills/record-monitoring@1.0.0"
plugins:
  - ref: "memory-lancedb@^2.0.0"
    slot: "memory"
    required: true
    reason: "Semantic recall of article content for gap detection, duplicate identification, and content quality tracking across runs"
requirements:
  minTier: "starter"
---

# Knowledge Base Curator

Reviews knowledge base content weekly. Identifies outdated articles, suggests improvements, and organizes content.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
