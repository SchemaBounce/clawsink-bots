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
- Purge orphan graph edges after record cleanup — orphans accumulate when records are deleted.

Anti-patterns:
- NEVER execute a purge without running dry_run: true first — one wrong filter can destroy production data.
- NEVER purge records from another agent's private namespace — only clean your own domain and shared stale data.
- NEVER skip the verification step after cleanup — re-run stats tools to confirm actual vs expected impact.
