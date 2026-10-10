---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: design-systems
  displayName: "Design Systems and Tokens"
  version: "1.0.0"
  description: "Design from tokens outward: a named palette with checked contrast, a modular type scale, a spacing scale, and components that compose them, with light and dark modes from one source."
  tags: ["design", "design-system", "tokens", "typography", "color", "dark-mode", "components"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_upsert_record", "adl_query_records", "adl_read_memory", "adl_write_memory"]
data:
  producesEntityTypes: ["design_tokens", "design_deliverables"]
  consumesEntityTypes: ["design_briefs", "design_tokens"]
---
# Design Systems and Tokens

A page designed from a system holds together across every screen; a page
designed one element at a time drifts. This skill makes the system first and
the page second: tokens, a type scale, a spacing scale, then components that
only ever use those tokens.

## When to Use

- A new site, a redesign, or a page that must match an existing brand
- Any time two pages must look like one product
- Before any platform-specific output (WordPress theme.json, Wix site styles,
  Squarespace site styles, CSS variables for a code repo)

## What You Produce

- A `design_tokens` record: colors (semantic names, both modes, each pair with
  its measured contrast ratio), type scale (family, sizes, line heights,
  weights), spacing scale, radii, shadows, breakpoints
- The same tokens rendered for the target: CSS custom properties, WordPress
  `theme.json`, Wix site-style values, Squarespace site-style values
- A component list (buttons, cards, nav, forms, sections) that references
  tokens only; no raw hex or pixel values in a component

## Rules

- One source of truth: every color, size and space in a deliverable traces to a token.
- Contrast is measured, not eyeballed: body text 4.5:1 or better, large text and UI 3:1 or better, in both modes.
- The type scale is a ratio (1.2 to 1.333) from one base size; headings come from the scale, never from taste.
- Dark mode is a token swap, not a second design.
- Reuse the brand's existing tokens when it has them; propose changes as a diff, not a replacement.
