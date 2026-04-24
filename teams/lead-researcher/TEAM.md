---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: lead-researcher
  displayName: "Lead Researcher"
  version: "1.0.0"
  description: "Single-agent team for B2B lead research. Researches leads, surfaces company news signals, and writes AI-generated research briefs to personalize outreach."
  category: sales
  tags: ["sales", "leads", "research", "crm", "outreach", "b2b", "prospecting", "starter"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "low"
requirements:
  minTier: "starter"
bots:
  - ref: "bots/lead-researcher@1.0.0"
plugins: []
mcpServers: []
dataKits:
  - ref: "data-kits/crm@1.0.0"
    required: true
    installSampleData: true
northStar:
  industry: "B2B Sales"
  context: "Teams that need to research leads before outreach. Enriches CRM contacts with company intelligence, news signals, and AI-generated research briefs."
  requiredKeys:
    - mission
    - icp
orgChart:
  lead: lead-researcher
  domains:
    - name: "Lead Research"
      description: "Research leads, surface company signals, generate outreach briefs"
      head: lead-researcher
  roles:
    - bot: lead-researcher
      role: lead
      reportsTo: null
      domain: lead-research
  escalation:
    critical: lead-researcher
    unhandled: lead-researcher
    paths: []
teamGoals:
  - name: research_coverage
    description: "All new leads researched within 48 hours of being added"
    category: primary
    composedFrom:
      - bot: lead-researcher
        goal: lead_coverage
        weight: 1.0
    target:
      operator: ">="
      value: 0.9
      period: weekly
  - name: brief_production
    description: "Research briefs produced daily while unworked leads exist"
    category: primary
    composedFrom:
      - bot: lead-researcher
        goal: briefs_generated
        weight: 1.0
    target:
      operator: ">="
      value: 1
      period: daily
      condition: "when new or contacted leads exist"
  - name: signal_capture
    description: "News signals captured and linked to target companies each week"
    category: secondary
    composedFrom:
      - bot: lead-researcher
        goal: news_signal_capture
        weight: 1.0
    target:
      operator: ">"
      value: 0
      period: weekly
---

# Lead Researcher Team

A single-agent team purpose-built for the QuickStart lead research use case. Deploys one agent — Lead Researcher — backed by the CRM Starter data kit with 20 sample leads and 20 sample companies pre-seeded.

## What Gets Deployed

| Component | What It Is |
|-----------|-----------|
| **Lead Researcher** agent | Researches leads daily, writes research briefs |
| **CRM Starter** data kit | 5 entity types: leads, companies, news_items, outreach_templates, research_briefs |
| **Sample data** | 20 leads + 20 companies pre-seeded so the first run produces real output |

## First Run

On the first scheduled run (within 24 hours of deployment), the agent will:

1. Find all 20 sample leads with `status: new`
2. Pull each lead's company record for context
3. Write a research brief for each lead — verdict, supporting evidence, recommended template
4. Capture any news signals identified during research

## Upgrading Later

This team is intentionally minimal. When you're ready to add live web enrichment, connect an MCP browser tool (Hyperbrowser or Exa) to the Lead Researcher agent. When you need outreach execution, deploy the Sales Pipeline bot from the SaaS Starter team alongside this one.
