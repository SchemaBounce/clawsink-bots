## Implementation Planning

1. Read the task or issue description and acceptance criteria.
2. Query architecture decisions and codebase patterns from memory.
3. Identify all affected files and modules.
4. Classify risk: low (bug fix, config, docs), medium (feature in existing pattern), high (new API, DB migration, auth/security).
5. Define test strategy: unit tests, integration tests, manual verification steps.
6. Output a structured plan: files to modify, risk level, test approach, and estimated complexity.

Anti-patterns:
- NEVER output a plan without identifying all affected files — missing files means missing risk assessment.
- NEVER classify a DB migration or auth/security change as low risk — these are always medium or high regardless of size.
- NEVER skip the test strategy — a plan without defined verification steps is just a wish list.
