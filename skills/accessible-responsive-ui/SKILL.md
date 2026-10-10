---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: accessible-responsive-ui
  displayName: "Accessible, Responsive UI"
  version: "1.0.0"
  description: "Mobile-first layouts that pass WCAG 2.2 AA and Core Web Vitals: fluid type, 44 px targets, keyboard and screen-reader paths, and a measured audit of any live page before and after."
  tags: ["design", "accessibility", "wcag", "responsive", "mobile", "core-web-vitals", "performance"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_upsert_record", "adl_query_records", "adl_proxy_call"]
data:
  producesEntityTypes: ["design_findings", "design_deliverables"]
  consumesEntityTypes: ["design_briefs", "design_tokens"]
---
# Accessible, Responsive UI

A design that only works on a wide screen with a mouse is half a design. This
skill makes every layout work at 390 px with a thumb, with a keyboard, and
with a screen reader, and it proves it with measurements rather than opinion.

## When to Use

- Every page or component deliverable, before it is handed over
- Auditing a live page (the customer's current site) to find what to fix
- Any time a layout uses fixed widths, side-by-side columns, hover-only
  affordances, or drag

## What You Produce

- `design_findings` records from an audit: one per defect, with the WCAG 2.2
  criterion or the Web Vital it fails, where, the measured value, and the fix
- Layout specs that state the phone layout first and the wider layouts as
  additions (what stacks, what collapses behind a menu, what scrolls inside
  its own box)
- A pre-handover checklist on every deliverable: targets, contrast, focus
  order, headings, alt text, reduced motion, LCP, CLS, INP

## Rules

- Phone first: 390 px wide, no horizontal page scroll, every action reachable, every input typeable.
- Touch targets 44 by 44 px or larger, 8 px apart; one visible focus ring on every interactive element.
- One `h1`; headings in order; landmarks (`header`, `nav`, `main`, `footer`); every image has alt text or is marked decorative.
- Motion respects `prefers-reduced-motion`; nothing auto-plays with sound.
- Targets: LCP under 2.5 s on mobile, CLS under 0.1, INP under 200 ms; images sized, fonts preloaded, nothing render-blocking above the fold.
- `adl_proxy_call` fetches a page for audit (read-only, bounded); it never posts.
