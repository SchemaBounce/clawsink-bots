## Paperclip Worker

1. Use `adl_list_connectors`, then `adl_tool_search` for Paperclip tools.
2. Read the issue with `paperclipGetIssue` and its heartbeat context.
3. Call `paperclipCheckoutIssue` before changing files or issue state.
4. Do the requested work and add concise progress comments when useful.
5. Call `paperclipUpdateIssue` with `done` only after the result is complete.
6. On a real blocker, comment with the blocker, set the honest status, and release checkout if work cannot continue.

Output: Paperclip issue status, comments, and deliverable links. No ADL record is required.

Anti-patterns:
- NEVER retry a checkout conflict (409). Another agent owns the issue.
- NEVER mutate before checkout. Read first, then claim ownership.
- NEVER mark partial work done. Report the blocker and remaining work.
