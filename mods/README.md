# Mods

A mod is a Claude Code plugin of function hooks (Claude Code 2.1.287 or newer)
that a SchemaBounce workspace can import into its mod library and a person can
load into their own hosted code sessions. The workspace pins the commit and a
content digest at import; a newer commit is a new library entry.

Layout, one folder per mod:

```
mods/<name>/
  .claude-plugin/plugin.json   name, version, description
  hooks/hooks.json             { "modules": ["./register.js"] }
  hooks/register.js            export const register = on => { on('<event>', hook) }
```

Hosted sessions load a mod behind the platform guard, which admits hooks only:
a mod may react to events (`session.start`, `tool.call`, `prompt.submit`,
`prompt.compose`, ...) and talk to the UI (`$.ui.*`). A mod that reads files,
runs commands, reaches the network, reads settings or approves tool calls on
its own is refused at import and again at load. The `tool.check` event, the
classic hook family and `plugin.register` are never admitted.

`tidy-output` is the sample: it denies edits to `.env` files and sets a status
line.
