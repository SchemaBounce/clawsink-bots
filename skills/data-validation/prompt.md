## Data Validation

1. Load the schema rules and business constraints for the target entity type.
2. For each incoming record, check required fields are present and non-null.
3. Validate field types and formats against the schema (e.g., email format, date ranges, enum values).
4. Evaluate business constraints such as cross-field dependencies and referential integrity.
5. Collect all violations per record with field name, rule violated, and expected vs actual value.
6. Return a validation report listing passed records, failed records, and a summary of violation counts by rule.
