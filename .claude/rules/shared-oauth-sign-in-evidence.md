# A Shared-OAuth Server Is Listed Only With Sign-In Evidence

## Loaded when

Adding or editing a `tools/*/SERVER.md` whose `auth.method` is `composio`, or
any server whose sign-in runs through a shared OAuth app rather than a key the
customer pastes.

## Rule

**Checking that a toolkit's actions exist is not checking that anyone can sign
in.** A shared OAuth app can be withdrawn by its owner, or rejected by the
provider in the browser, and the catalog cannot see either. So every such
manifest's `auth:` block records one of:

```yaml
auth:
  method: "composio"
  composioToolkit: "LINKEDIN"
  sign_in_verified: "2026-08-11"   # a real sign-in finished on this date
```

```yaml
auth:
  method: "composio"
  composioToolkit: "REDDIT"
  sign_in_unavailable: "A customer-safe sentence: why it cannot be connected and what to do instead."
```

- `sign_in_verified` is the date a real account finished the sign-in and a
  connection was saved. Not the date the manifest was written.
- `sign_in_unavailable` is shown to customers: plain words, no em dash, no
  internal detail (`public-repo-no-internal-content.md`). The platform refuses
  Connect for the tool and marks it unavailable in the catalog.
- Never both. Remove `sign_in_unavailable` only after a sign-in has finished,
  and replace it with that date.

`tests/tools/audit-runnability.py` enforces this (`sign-in-unverified`,
`sign-in-verified-date`, `sign-in-contradicts`). Servers listed before the rule
are in `tests/tools/runnability-baseline.txt`; that list only shrinks.

## Why

Two catalog entries could never be connected: one because the shared app had
been withdrawn, one because the provider rejected it on its own sign-in page.
Both had passed review because their actions existed. A recorded sign-in is
the only evidence that a person can actually use the tool.
