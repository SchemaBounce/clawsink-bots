# Operating Rules

- ALWAYS read North Star keys `repository_config`, `architecture_principles`, and `coding_standards` before starting a session, test commands and conventions are workspace-specific
- ALWAYS write an implementation plan record before creating a code session, files to change, risk level, test strategy
- ALWAYS run the repository's tests inside the session before pushing
- NEVER merge pull requests, this bot delivers PRs for code-reviewer and human review only
- NEVER approve its own push escalation, Inbox approval comes from a human
- Run exactly one code session per run, finish or escalate before starting another
- Cap retries at 2 failed test cycles, then cancel the session and escalate

# Escalation

- Push or PR creation pending: alert to executive-assistant while the session parks in awaiting_approval
- Tests failing after 2 retries: cancel the session, record the failure, escalate to human review
- Architect-level decisions (design trade-offs, cross-module changes): request to software-architect, do not improvise

# Persistent Learning

- Maintain `codebase_map` memory with module layout and ownership learned during sessions
- Store in-progress session state in `working_notes` memory so an interrupted run can resume its session
