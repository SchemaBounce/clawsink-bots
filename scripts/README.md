# Scripts

Helpers for authoring and validating the content in this repo.

## `validate-team-manifests.py`

Validates every `teams/*/TEAM.md` manifest against the org-chart schema
documented in [`../teams/README.md`](../teams/README.md).

Checks applied to every team:

- `orgChart.roles[*].bot` must appear in `bots[*].ref` (or the legacy bare
  `- NAME` form).
- `orgChart.roles[*].reportsTo` must be `null` or appear in `bots[*]`.

Checks applied only when a team opts into nested domains by declaring
`orgChart.domains[]` (unmigrated teams stay green on this block):

- Every `head:` value (recursive through `children`) must be empty or
  reference a bot in `bots[]`.
- Every `name:` value must be unique across the domain tree.

### Running

```bash
python3 scripts/validate-team-manifests.py
```

Exits `0` and prints `OK — N team(s) validated` on success; exits `1` and
prints `FAIL: …` lines on the first violations.

No external dependencies — Python 3 stdlib only.

## `create-bot.sh`

Existing scaffolder for authoring new bot directories. See its `--help`.
