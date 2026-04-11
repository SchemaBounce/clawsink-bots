# Built-in Tools

This directory catalogs the 133 built-in deterministic tools available to all agents. These are native Go functions hosted inside the ADL -- fast, deterministic, zero LLM tokens. Unlike MCP servers (external process tools) and skills (prompt-based guidance), built-in tools are **native platform functions** that every agent gets automatically.

**All 133 tools are available to every agent.** There is no installation, no opt-in, and no activation step. Every agent in every workspace has access to the full tool catalog from the moment it is created.

**Relationship to Bots**: Bots may list `toolPacks[]` in BOT.md as informational documentation indicating which tool categories the bot is designed to use. This field has no effect on tool availability -- it exists for documentation purposes only.

**Relationship to Teams**: Teams may list `toolPacks[]` in TEAM.md for documentation purposes. All tools are available to all team bots regardless of what is declared.

## Built-in Tools vs MCP Servers vs Skills

| | Built-in Tools | MCP Servers | Skills |
|---|---|---|---|
| **What** | Native Go functions in the ADL | Standalone processes providing external API tools | Reusable prompt instructions |
| **How they run** | Inside the ADL infrastructure (same process) | Separate process (stdio, SSE, or HTTP) | Appended to bot's system prompt |
| **Execution** | Deterministic, <10ms, zero LLM tokens | Network call to external API | LLM follows instructions |
| **What they provide** | Computation: math, parsing, formatting, analysis | External API access: GitHub, Slack, Stripe | Procedural guidance: how to analyze, categorize |
| **Where defined** | `packs/{pack-name}/PACK.md` (catalog) + Go in core-api | `tools/{server-name}/SERVER.md` | `skills/{skill-name}/SKILL.md` + `prompt.md` |
| **Availability** | **All 133 tools available to every agent automatically** | Must be declared and configured | Composed into bot's system prompt |
| **Examples** | CSV parsing, financial ratios, PII detection | GitHub issues, Stripe charges, Slack messages | Invoice categorization, anomaly detection |

## How Agents Access Built-in Tools

All 133 built-in tools are automatically available to every agent. No declaration, installation, or activation is required. Agents discover tools at runtime via `adl_tool_search` with domain keywords.

Bots may optionally list `toolPacks[]` in their `BOT.md` manifest for documentation purposes -- indicating which tool categories the bot is designed to use:

```yaml
toolPacks:
  - ref: "packs/data-transform@1.0.0"
    reason: "Parse CSV bank statements and transform transaction data"
  - ref: "packs/financial-toolkit@1.0.0"
    reason: "Calculate amortization, ROI, and financial ratios"
```

This field is informational only. All tools are available regardless of what is declared.

## Tool Catalog

Every agent has access to the standard ADL tool set (62 core tools) plus all 133 built-in deterministic tools across 15 categories.

| Pack | Tools | Category | Description |
|------|-------|----------|-------------|
| [data-transform](data-transform/) | 15 | Data Processing | Parse, validate, transform, and merge structured data |
| [financial-toolkit](financial-toolkit/) | 12 | Finance | Financial calculations, forecasting, invoicing |
| [math-stats](math-stats/) | 10 | Analytics | Statistics, regression, hypothesis testing |
| [document-gen](document-gen/) | 10 | Content | PDF specs, templates, reports, email composition |
| [text-processing](text-processing/) | 10 | NLP | Entity extraction, PII detection, text chunking |
| [datetime-toolkit](datetime-toolkit/) | 8 | Utilities | Date math, timezone conversion, business days |
| [web-toolkit](web-toolkit/) | 8 | Web | HTTP requests, HTML parsing, webhook generation |
| [security-compliance](security-compliance/) | 10 | Security | Encryption, hashing, PII detection, audit logging |
| [ecommerce-toolkit](ecommerce-toolkit/) | 8 | E-commerce | Pricing, SKU generation, inventory, cart totals |
| [hr-toolkit](hr-toolkit/) | 8 | HR | Salary, leave, performance, shift scheduling |
| [marketing-toolkit](marketing-toolkit/) | 8 | Marketing | UTM, funnels, attribution, LTV, lead scoring |
| [devops-toolkit](devops-toolkit/) | 8 | DevOps | Log parsing, diffs, UUID generation, regex testing |
| [healthcare-toolkit](healthcare-toolkit/) | 6 | Healthcare | BMI, dosage, ICD-10 lookup, lab ranges |
| [legal-toolkit](legal-toolkit/) | 6 | Legal | SLA calculations, GDPR mapping, retention policies |
| [geo-toolkit](geo-toolkit/) | 6 | Geospatial | Distance, geofencing, address parsing |
| **Total** | **133** | | |

## PACK.md Catalog Format

Each PACK.md describes a category of built-in tools for the marketplace catalog. This is a reference document -- it does not control tool availability.

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: kebab-case-name        # Must match directory name
  displayName: Human Name      # For marketplace display
  version: 1.0.0              # SemVer
  description: One-line (<120 chars)
  category: Category Name
  tags: [tag1, tag2]
  icon: icon-name              # For marketplace display
tools:
  - name: tool_name
    description: What this tool does
    category: sub-category     # UI grouping within the category
---

# Category Name

Description and documentation rendered as the marketplace page.

## Tools

### tool_name
Description, parameters, return value documentation.
```

## Validation Rules

1. `metadata.name` must be kebab-case and match the directory name
2. `metadata.description` must be under 120 characters
3. `kind` must be `ToolPack`
4. `tools[]` must list all tools with name and description
5. Tool names must use snake_case
6. Each tool name must be globally unique across all categories
