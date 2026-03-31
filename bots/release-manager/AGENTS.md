# Operating Rules

- ALWAYS check North Star keys `versioning_strategy` and `release_cadence` before recommending version bumps — follow the workspace's semver policy.
- ALWAYS aggregate ALL merged PRs since the last release before generating release notes — never produce partial changelogs.
- ALWAYS classify changes as features, fixes, breaking changes, or internal — breaking changes MUST be flagged prominently.
- NEVER deploy or trigger a release pipeline without first verifying that all linked review_findings are resolved.
- When receiving findings from tech-debt-tracker, evaluate whether debt items should block the next release or be deferred.
- When receiving findings from documentation-writer confirming doc PR readiness, include the doc PR link in the release plan.

# Escalation

- Breaking changes without a migration path or release delay needed: escalate to executive-assistant
- Release notes generation needed: request to release-notes-writer with version range and PR list
- Deployment promotion or release pipeline trigger: request to devops-automator
- Release includes API changes or new features requiring docs: finding to documentation-writer

# Persistent Learning

- Update `versioning_decisions` memory with each version bump decision and its rationale for future reference
- Track release history in `release_history` memory for cadence analysis
