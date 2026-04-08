# Tool Packs

Tool packs are collections of deterministic Go functions hosted inside the ADL that agents can use for computation, data processing, and domain-specific operations. Unlike MCP servers (external process tools) and skills (prompt-based guidance), tool packs are **native platform functions** — fast, deterministic, zero LLM tokens.

**Relationship to Bots**: Bots declare tool pack dependencies via `toolPacks[].ref: "packs/{name}"` in BOT.md. This gives the agent access to all tools in the declared packs.

**Relationship to Teams**: Teams declare shared tool packs via `toolPacks[]` in TEAM.md, making them available to all member bots.

## Tool Packs vs MCP Servers vs Skills

| | Tool Packs | MCP Servers | Skills |
|---|---|---|---|
| **What** | Native Go functions in the ADL | Standalone processes providing external API tools | Reusable prompt instructions |
| **How they run** | Inside the ADL infrastructure (same process) | Separate process (stdio, SSE, or HTTP) | Appended to bot's system prompt |
| **Execution** | Deterministic, <10ms, zero LLM tokens | Network call to external API | LLM follows instructions |
| **What they provide** | Computation: math, parsing, formatting, analysis | External API access: GitHub, Slack, Stripe | Procedural guidance: how to analyze, categorize |
| **Where defined** | `packs/{pack-name}/PACK.md` (manifest) + Go in core-api | `tools/{server-name}/SERVER.md` | `skills/{skill-name}/SKILL.md` + `prompt.md` |
| **Examples** | CSV parsing, financial ratios, PII detection | GitHub issues, Stripe charges, Slack messages | Invoice categorization, anomaly detection |

## How Bots Reference Tool Packs

Bots declare tool pack dependencies in their `BOT.md` manifest under `toolPacks:`:

```yaml
toolPacks:
  - ref: "packs/data-transform@1.0.0"
    reason: "Parse CSV bank statements and transform transaction data"
  - ref: "packs/financial-toolkit@1.0.0"
    reason: "Calculate amortization, ROI, and financial ratios"
```

- `ref` points to a directory under `packs/` containing a `PACK.md`
- `reason` explains why the bot needs this pack (required, non-empty)
- Version suffix (`@1.0.0`) is optional — latest is used if omitted

## Standard ADL Tools (Always Available)

Every bot automatically has access to the standard ADL tool set (62 tools). Tool packs supplement these with computation and domain-specific functions that are not always needed by every agent.

## Available Tool Packs

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

## PACK.md Manifest Format

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
    category: sub-category     # UI grouping within the pack
---

# Pack Name

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
6. Each tool name must be globally unique across all packs
