# Data Kits

A Data Kit is a full-stack domain data package that deploys holistically with a team: entity schemas, graph relationship templates, vector search configurations, memory bootstraps, and sample data. Data Kits are the data foundation that makes AI agents domain-aware from day one.

**Relationship to Teams**: Teams bundle Data Kits via `dataKits[].ref: "data-kits/{name}@{version}"` in TEAM.md. Activating a team auto-installs its referenced kits.

**Relationship to Bots**: Bots read/write entity types defined by Data Kits. The kit's entity prefix ensures collision-free naming across composed kits.

**Relationship to Entity Schemas**: Data Kits are the recommended way to install entity schemas. Manual schema creation remains available for power users.

## Directory Structure

```
data-kits/{kit-name}/
├── KIT.md                # Manifest (kind: DataKit) — YAML frontmatter parsed by marketplace
├── entity-schemas.json   # Entity type definitions with typed fields
├── graph-templates.json  # Relationship edge type templates (AGE graph)
├── vector-config.json    # Semantic search collection configurations (pgvector)
├── memory-bootstrap.json # Industry KPIs, thresholds, and domain knowledge
└── sample-data.json      # 5-10 example records per entity type
```

## KIT.md Format

```yaml
---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: string           # Kebab-case identifier, matches directory name
  displayName: string    # Human-readable name
  version: string        # SemVer (e.g., "1.0.0")
  description: string    # One-line description (<160 chars)
  domain: string         # Canonical business-function domain slug (see below)
  category: string       # The literal string "domain"
  tags: [string]         # Searchable tags
  author: string
compatibility:
  teams: [string]        # Team names designed for this kit
  composableWith: [string]  # Other kit names this composes well with
entityPrefix: string     # Short collision-avoidance prefix (e.g., "rest", "crm")
entityCount: int         # Number of entity types in this kit
graphEdgeTypes: [string] # Custom AGE edge type labels (e.g., ["SUPPLIED_BY", "REVIEWED"])
vectorCollections: [string]  # Semantic search collections this kit creates
---

# {Display Name}

Extended documentation here. Renders as the kit's marketplace detail page.
```

## Sub-File Schemas

### entity-schemas.json

Array of entity type definitions matching the ADL `ADLEntitySchema` format:

```json
[
  {
    "name": "{prefix}_{entity_name}",
    "displayName": "Human Name",
    "description": "What this entity represents",
    "fields": {
      "field_name": {
        "type": "string | number | boolean | date | array | object",
        "required": true,
        "description": "Field description",
        "enum": ["optional", "allowed", "values"]
      }
    }
  }
]
```

**Field type mapping** (to ADL storage):

| Kit Type | ADL JSONB | pgvector | AGE Property |
|----------|-----------|----------|-------------|
| `string` | text | embeddable | varchar |
| `number` | numeric | - | float8 |
| `boolean` | boolean | - | boolean |
| `date` | text (ISO 8601) | - | varchar |
| `array` | jsonb array | - | - |
| `object` | jsonb nested | - | - |

### graph-templates.json

Defines edge type templates for the AGE graph engine. Agents create actual edges at runtime — these are the allowed relationship types:

```json
{
  "edgeTypes": [
    {
      "label": "SUPPLIED_BY",
      "description": "Links a menu item to its supplier",
      "fromEntity": "rest_menu_items",
      "toEntity": "rest_suppliers",
      "properties": {
        "cost_per_unit": "number",
        "lead_time_days": "number"
      }
    }
  ]
}
```

### vector-config.json

Configures pgvector semantic search collections:

```json
{
  "collections": [
    {
      "name": "{prefix}_{collection_name}",
      "description": "What this collection indexes",
      "sourceEntity": "rest_menu_items",
      "embeddingFields": ["name", "description", "ingredients"],
      "dimensions": 1536,
      "distanceMetric": "cosine"
    }
  ]
}
```

If no vector collections are needed, use: `{"collections": []}`

### memory-bootstrap.json

Seeds the agent memory system with domain-specific knowledge — KPIs, thresholds, terminology:

```json
{
  "namespace": "kit:{kit-name}:defaults",
  "entries": [
    {
      "key": "kpi:food_cost_ratio",
      "value": "Target food cost ratio is 28-35% of revenue. Above 35% indicates waste or pricing issues.",
      "category": "kpi",
      "tags": ["financial", "food-cost"]
    }
  ]
}
```

Categories: `kpi`, `threshold`, `terminology`, `best-practice`, `compliance`

### sample-data.json

Example records for optional seeding during kit installation:

```json
{
  "records": {
    "rest_menu_items": [
      {
        "name": "Classic Margherita Pizza",
        "category": "pizza",
        "price": 14.99,
        "cost": 4.20,
        "allergens": ["gluten", "dairy"],
        "active": true
      }
    ]
  }
}
```

## Domain

Every Data Kit belongs to exactly one canonical business-function domain, matching the team it ships with. `metadata.domain` must be one of these 11 slugs:

`customer-service`, `marketing`, `sales`, `engineering`, `finance`, `operations`, `product`, `data`, `hr`, `legal-compliance`, `leadership`

`metadata.category` is set to the literal string `domain`. The old `industry` / `horizontal` split is retired — there is one data kit per domain, designed to ship with the matching domain team. Multiple domain kits coexist cleanly in a workspace because each uses a unique entity prefix.

## Entity Prefix Convention

Every kit uses a short prefix for all entity type names to prevent collisions when multiple kits are installed together:

| Kit | Prefix | Example Entity |
|-----|--------|---------------|
| customer-service | `cs_` | `cs_tickets` |
| marketing | `mkt_` | `mkt_campaigns` |
| sales | `sal_` | `sal_deals` |
| engineering | `eng_` | `eng_incidents` |
| finance | `fin_` | `fin_transactions` |
| operations | `ops_` | `ops_inventory` |
| product | `prd_` | `prd_features` |
| data | `dat_` | `dat_pipelines` |
| hr | `hr_` | `hr_employees` |
| legal-compliance | `leg_` | `leg_matters` |
| leadership | `ldr_` | `ldr_okrs` |

**Rules:**
- Prefix is 2-4 lowercase characters followed by underscore
- Must be unique across all kits
- Declared in `KIT.md` frontmatter `entityPrefix` field

## Installation

When a Data Kit is installed (manually or via team activation):

1. **Entity schemas** → upserted to `adl_entity_schemas` with `sourceType: "data_kit"`, `sourceName: "{kit-name}"`
2. **Graph templates** → stored as allowed edge type definitions (agents create edges at runtime)
3. **Vector collections** → created in `adl_collections` with embedding configuration
4. **Memory bootstraps** → written to `adl_memory` under the kit's namespace
5. **Sample data** → optionally seeded to `adl_records` (user toggle, default: off)

Installation is **idempotent** — re-installing an already-installed kit is a no-op.

## Composability

Domain kits are self-contained — each ships with its matching domain team and carries the entity schemas that team's bots need. A business that runs several domain teams installs several domain kits, and they coexist cleanly because every kit uses a unique entity prefix.

For example, a workspace running the Customer Service, Sales, and Finance teams installs:
- `customer-service` — `cs_tickets`, `cs_contacts`, `cs_conversations`
- `sales` — `sal_contacts`, `sal_companies`, `sal_deals`
- `finance` — `fin_transactions`, `fin_invoices`, `fin_budgets`

Prefixes prevent entity name collisions, so all three coexist without conflict.

## Validation

1. `KIT.md` has valid YAML frontmatter with `kind: DataKit`
2. `metadata.name` matches the directory name
3. `entityPrefix` is unique across all kits (2-4 chars + underscore)
4. `entity-schemas.json` is valid and all entity names start with the declared prefix
5. `graph-templates.json` edge types reference valid entity names from this kit
6. `vector-config.json` source entities exist in `entity-schemas.json`
7. `memory-bootstrap.json` namespace matches `kit:{name}:defaults`
8. `sample-data.json` keys match entity names in `entity-schemas.json`
9. All `compatibility.teams` reference valid team directories
10. All `compatibility.composableWith` reference valid kit directories

## What the Platform Does

| You Provide | The Platform Will |
|-------------|-------------------|
| `entity-schemas.json` | Create typed entity schemas in the workspace ADL |
| `graph-templates.json` | Register allowed edge types in the AGE graph |
| `vector-config.json` | Create pgvector collections with embedding config |
| `memory-bootstrap.json` | Seed agent memory with domain knowledge |
| `sample-data.json` | Optionally populate entity records with examples |
