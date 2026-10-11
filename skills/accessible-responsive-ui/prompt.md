## Accessible, Responsive UI

Phone first, then wider. Prove it, do not assert it.

### Audit a live page
1. Fetch the page with `adl_proxy_call` (GET only). Read the DOM: heading order, landmarks, alt text, form labels, link text, focus order, `prefers-reduced-motion` handling, viewport meta.
2. Measure or estimate the Web Vitals from the markup: largest above-the-fold image or text block (LCP candidate), unsized images and late-loading fonts (CLS), heavy scripts before content (INP).
3. Write one `design_findings` record per defect (`adl_upsert_record`): `url`, `criterion` (WCAG 2.2 SC or vital name), `severity` (critical, high, medium, low), `location`, `measured`, `fix`. "Looks fine" is not a finding; an audit with zero findings states what was checked.

### Design a layout
4. Describe the 390 px layout first: what stacks, what goes behind a menu, what scrolls inside its own box. Then say what changes at 768 px and 1024 px.
5. Every interactive element: 44 px target, visible focus ring, a text label (icons alone are not labels).
6. Every image: dimensions and alt text (or decorative). Every form field: a label, an error message, no placeholder-as-label.
7. Attach the checklist to the deliverable: targets, contrast (from the tokens' contrast report), focus order, headings, alt text, reduced motion, LCP, CLS, INP.

### Never
- Never rely on hover, color alone, or drag for anything a person must do.
- Never fix a layout by hiding content on phones; reflow it.
- Never report a Web Vital number you did not measure or derive; say "estimated from markup" when it is.
