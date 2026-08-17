## Ticket Writing

1. Restate the request as the outcome someone sees when it is done. If you cannot, ask first.
2. Decide how many tickets it is. One ticket = one outcome, finishable and verifiable alone.
3. Split anything that fails this test: could someone picking it up cold finish it and know they were done?
4. Write acceptance criteria as observable behavior — what a user or caller can now do.
5. Give each ticket what it needs to start: the repository for code work, and what "wrong" looks like.

Anti-patterns:
- NEVER write "tests pass" as acceptance criteria — that restates the pipeline, not the change.
- NEVER split by layer (hooks / components / tests) — those cannot be verified alone.
- NEVER leave a coding ticket without a repository.
- NEVER put two independent outcomes in one ticket; when it half-fails, nothing is recoverable.
