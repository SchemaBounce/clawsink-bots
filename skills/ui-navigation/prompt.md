## UI Navigation

Console navigation changes. The paths you remember are probably wrong. Look them up.

- `adl_find_ui_path("api token")` gives you one destination: its section, its
  label, its path, the permission it requires, and whether it is enabled.
- `adl_get_ui_map()` gives you the whole tree. `adl_get_ui_map("Settings")`
  gives you one section.
- `adl_search_docs("rotate a service account secret")` gives you the docs, for
  when the answer is a procedure rather than a screen.

Sections: Work, Agents, Context Engine, Data, Kolumn, Settings.

### Rules

1. **Call the tool, do not recall the path.** This applies everywhere you write
   a path, not just chat: messages to other agents, records, reports, docs.
2. **Give the breadcrumb AND the link.** The breadcrumb tells them where they
   are, the link gets them there in one click.
3. **Fill `{workspaceId}` from the workspace you are running in.** Never ship
   the literal placeholder. Never invent an id.
4. **State the permission when the destination is gated.** A member without it
   sees nothing at that link, and a link to nothing reads as a broken product.
5. **Never send anyone to a disabled destination.** If the lookup says it is
   not enabled, say so and offer the nearest destination that is.
6. **Prefer a deep link over a navigation lesson.** Query params are part of
   the path.
7. **Say plainly when you do not know.** If the lookup returns nothing, say you
   could not find it. A plausible invented path costs more than an honest miss.

### Worked example

Someone asks: "where do I rotate the token my deploy script uses?"

1. `adl_find_ui_path("api token")` returns section `Settings`, label
   `API & Tokens`, path `/workspaces/{workspaceId}/settings/service-accounts`,
   permission `service_accounts:manage`, enabled.
2. Substitute the workspace you are running in.
3. Answer:

> Settings > API & Tokens
> `/workspaces/ws_abc123/settings/service-accounts`
> Rotate the secret on the service account your script authenticates with.
> That page needs `service_accounts:manage`, so ask an owner if you do not
> hold it.

A deep link beats a walkthrough the same way. To put someone in one agent's
terminal, send
`/workspaces/ws_abc123/agent-data-layer/agents?agent=blog-writer&tab=terminal`,
not "open Agents, find blog-writer, click the Terminal tab".

Compare the guess this replaces: "go to Settings > API Keys". No such item
exists, so they hunt for it and conclude the product moved on them.

Anti-patterns:

- **NEVER write a console path from memory.** Most of the `Settings > X`
  breadcrumbs in older docs name items that are gone. If you did not look it up
  this run, you do not know it.
- **NEVER invent a URL.** A path you assembled from a pattern is a guess wearing
  the shape of an answer, and nobody can tell the difference until it 404s.
- **NEVER name a gated destination without naming its permission.** Sending a
  member to `Settings > Billing & Usage` without saying it needs `billing:view`
  hands them a page that shows them nothing.
- **NEVER send anyone to a destination the lookup reports as disabled.** Three
  launch gates are off right now, so some items in the tree are not reachable
  yet. Say that instead of pointing at them.
- **NEVER hand back a navigation walkthrough when a deep link does the same job
  in one click.**
