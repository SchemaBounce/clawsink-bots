## Data Validation

Validate ADL records against schema rules and business constraints, producing structured violation reports.

### Steps

1. `adl_query_records(entity_type="validation_rules")` — load schema rules and business constraints for the target entity type.
2. `adl_query_records(entity_type=<target_type>)` — fetch records to validate. Use filters to scope (e.g., `validated_at IS NULL`).
3. Use `adl_tool_search` with keywords "validate schema" to find deterministic validation tools. Prefer tool pack functions for format checks and constraint evaluation.
4. For each record, check: (a) required fields present and non-null, (b) type/format correctness (email, date, enum), (c) cross-field constraints (e.g., `end_date > start_date`).
5. Collect all violations per record: `{ field, rule, expected, actual, severity }`. Severity: `error` (blocks processing), `warning` (allow but flag).
6. `adl_upsert_record(entity_type="validation_results")` — one record per validated entity: `source_entity_id`, `source_entity_type`, `status` (pass|fail|warn), `violations[]`, `validated_at`.
7. Compute summary: total records, pass count, fail count, top 3 most-violated rules.
8. For error-severity failures exceeding 10% of batch: `adl_send_message(type="alert")` to the data owner agent.

### Output Schema

- `entity_type`: `"validation_results"`
- Required fields: `source_entity_id`, `source_entity_type`, `status`, `violations`, `validated_at`, `rule_version`

### Anti-Patterns

- NEVER silently drop invalid records — always write a `validation_results` entry with the violations.
- NEVER validate without loading the current rule set — stale rules cause false positives.
- NEVER mix warnings and errors into a single severity — errors block, warnings inform.
