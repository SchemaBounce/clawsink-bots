## Design Systems and Tokens

Design the system before the page. Every deliverable is built from tokens.

### Steps
1. Read the brief (`adl_query_records` entity_type `design_briefs`) and any existing `design_tokens` for the brand. Reuse what exists; change it only as a diff with a reason. None yet is the normal first run: build the set from the brief's brand assets.
2. Define semantic color tokens for both modes (`bg`, `surface`, `text`, `text-muted`, `accent`, `accent-contrast`, `border`, `success`, `warning`, `danger`). Body text must reach 4.5:1, large text and controls 3:1.
2a. Measure every text-on-background pair with the `calculate` tool; never write a ratio you did not compute with it (a model's mental arithmetic on hex colors is wrong by up to 2x). `calculate` is a math-stats pack tool this skill is allowed to call; if it is not in your tool list yet, run `adl_tool_search("calculate")` once. Convert each hex color to decimal channels (`#1F6FEB` = r 31, g 111, b 235), then call `calculate` with
   `expression`: `(max(0.2126*((r1/255+0.055)/1.055)^2.4+0.7152*((g1/255+0.055)/1.055)^2.4+0.0722*((b1/255+0.055)/1.055)^2.4, 0.2126*((r2/255+0.055)/1.055)^2.4+0.7152*((g2/255+0.055)/1.055)^2.4+0.0722*((b2/255+0.055)/1.055)^2.4)+0.05)/(min(0.2126*((r1/255+0.055)/1.055)^2.4+0.7152*((g1/255+0.055)/1.055)^2.4+0.0722*((b1/255+0.055)/1.055)^2.4, 0.2126*((r2/255+0.055)/1.055)^2.4+0.7152*((g2/255+0.055)/1.055)^2.4+0.0722*((b2/255+0.055)/1.055)^2.4)+0.05)`
   `variables`: `{"r1":31,"g1":111,"b1":235,"r2":255,"g2":255,"b2":255}`
   For a channel of 10 or less, replace that channel's term `((x/255+0.055)/1.055)^2.4` with `x/3294.6` (the WCAG low-light branch).
2b. Record the tool's number, rounded to two decimals, and the level it reaches (AA body 4.5, AA large 3.0, AAA body 7.0). A pair below its target is changed (darken or lighten the token) and measured again; never ship a failing pair with a passing label.
3. Build the type scale from one base size and one ratio (1.2 to 1.333). Name each step (`text-sm`, `text-base`, `heading-3`, `heading-1`) with size, line height and weight.
4. Build the spacing scale (4 px base, steps 1 to 12), radii, shadows and breakpoints.
5. List the components the page needs and define each only in tokens.
6. Render the tokens for the target platform and write one `design_tokens` record (`adl_upsert_record`): `brand`, `mode_light`, `mode_dark`, `type_scale`, `spacing`, `contrast_report`, `renders` (css, wordpress_theme_json, wix_site_styles, squarespace_site_styles).
7. Save the token set id in memory (`adl_write_memory`, namespace `design_state`, key `active_tokens`) so later runs build on it.

### Never
- Never put a raw hex or pixel value in a component, a page or a CSS block; name the token.
- Never ship a color pair without its contrast number, and never write a contrast number the `calculate` tool did not return.
- Never simplify the expression in step 2a. Send it exactly as written, with `^2.4` and the `+0.055)/1.055` terms; a `^2.2` shortcut moves a ratio by up to 1.0 and turns an AA pair into a false AAA.
- Never introduce a second type scale for one brand.
