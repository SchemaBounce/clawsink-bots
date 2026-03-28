## Data Maintenance Protocol

1. **Assess first**: Run adl_get_data_stats and adl_get_namespace_stats to identify cleanup candidates.
2. **Dry run**: Always run purge tools with dry_run: true before any destructive operation.
3. **Document**: Write an opt_recommendation record before executing cleanup.
4. **Execute**: Run with dry_run: false only after assessment and documentation.
5. **Verify**: Re-run stats tools after cleanup to confirm expected impact.

### Safety Rules
- Never purge records newer than 7 days.
- Never purge northstar or other agents' private namespaces.
- Always log cleanup actions for audit trail.
- Cap: 10K records per purge call, 5K memory entries per purge call.
