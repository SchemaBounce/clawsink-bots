# DEPRECATED — Domain Schemas

These domain schema files are **deprecated** as of v1.0.0 of Data Kits.

Entity schemas have been migrated to the full-stack Data Kit system which provides:
- Entity schemas (same as before, with prefixed names)
- Graph relationship templates (AGE)
- Vector search configurations (pgvector)
- Memory bootstraps (industry KPIs and domain knowledge)
- Sample data for seeding

## Migration Map

| Old File | New Data Kit | Location |
|----------|-------------|----------|
| `crm.json` | `crm-contacts` | `data-kits/crm-contacts/` |
| `finance.json` | `financial-ops` | `data-kits/financial-ops/` |
| `support.json` | `customer-feedback` | `data-kits/customer-feedback/` |
| `inventory.json` | _(absorbed into industry kits: restaurant, logistics, ecommerce, manufacturing)_ | - |
| `operations.json` | _(absorbed into industry kits: it-operations, project-management)_ | - |

These files are kept for backward compatibility with existing installations that reference the old `installDomainSchemas` API. New installations should use Data Kits.
