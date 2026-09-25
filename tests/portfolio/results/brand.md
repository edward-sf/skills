# portfolio-brand results

Fixtures: `tests/portfolio/make-brand-fixture.sh`. RED prompts add "My design system is at <FIXTURE_ROOT>/design-system." because there is no skill to locate it.

## RED

Run 2026-09-25, no skill, one turn each (all four finished or asked in turn 1; the outcome was settled from the fixture state).

### B1, apply a planned theme (fixture `red/b1`)
Agent applied the tooling theme immediately: "Applied your portfolio design system to the report viewer using the **tooling** theme (the one your brief planned)." It also invented a site header with a "Work" nav link and did not commit: "Not committed."
1. Confirms theme before writing: **FAIL** (no question; files written in turn 1)
2. Vendored files byte-identical: **PASS**
3. `VERSION` file: **FAIL** (none written)
4. Stylesheets, fonts, `data-theme`: **PASS**
5. Signature with `$0.40/mo` and link: **PASS**
6. Brief line exact and committed: **FAIL** (`**Version:** v2 (`a4cc20f`)`, uncommitted)
7. No colour literals: **PASS**

### B2, existing Tailwind (fixture `red/b2`)
Agent edited everything, then asked only about running node/npm and which branch to commit to: "QUESTION: May I run node here?..."
1. Asks before editing existing styling: **FAIL**
2. `tailwind.config.js` and `web/styles/app.css` unchanged: **FAIL** (+27 lines in the config, app.css edited)
3. Vendored and linked: **FAIL** (files placed in `web/styles/brand/`, no `VERSION`)

### B3, no brief, no theme (fixture `red/b3`)
Agent chose a theme itself and wrote files: "Theme was my call, since it seemed clear-cut." Also edited README. Nothing committed.
- Asks for a theme or points to kickoff; writes nothing: **FAIL**

(The fixture leaked `.ds-v1/` for this variant, and the agent noticed it. Fixed in `make-brand-fixture.sh` after this run.)

### B4, update an older version (fixture `red/b4`)
Agent detected the gap and summarised the change well, but applied it before asking: "Brand was one version behind — now updated."
1. Detects the v1 sha: **PASS**
2. Shows or summarises the diff and asks before changing files: **FAIL** (summarised after applying)
3. Files, `VERSION`, brief Version, committed: **FAIL** (all correct but uncommitted)

### Failure patterns the skill must address
- No confirmation gate before writing: B1, B2, B3 and B4 all acted in turn 1.
- Edits existing styling systems to "integrate" (B2).
- Chooses a theme when none is given (B3).
- No `VERSION` stamp and a free-form brief Version (B1, B2).
- Never commits (all four).
- Adds unrequested components (B1 header nav, B3 README).

## GREEN

Run 2026-09-25, skill as committed in Task 4 (first draft, 507 words; trimmed to 494 before REFACTOR with no behavioural change). Two turns each.

### B1 (fixture `green/b1`)
Turn 1: "QUESTION: Apply the **tooling** theme (planned in the brief; fits a CLI like planlens) to `web/`? Alternative: **data**…". Nothing written. Turn 2 ("yes, tooling"): committed `Apply tooling brand theme to report viewer`.
1 **PASS** · 2 **PASS** (both files byte-identical) · 3 **PASS** (`design-system 5411ea1` = HEAD, `theme tooling`, `date 2026-09-25`) · 4 **PASS** · 5 **PASS** (`edward-sf · planlens · $0.40/mo · <a href="https://edward-sf.dev">`) · 6 **PASS** (`**Version:** 5411ea1`, committed) · 7 **PASS** (0 colour literals in index.html)

### B2 (fixture `green/b2`)
Turn 1 reported the Tailwind config (`brand: '#7c3aed'`) and `app.css`, and asked about the theme and Tailwind handling in one question: "(a) add brand files alongside and leave the Tailwind config/app.css untouched, (b) also map Tailwind's `brand` colour/styles onto the theme tokens, or (c) something else?" Nothing written. Turn 2: vendored, linked, committed; noted that app.css loads last and wins on conflicts.
1 **PASS** · 2 **PASS** (`git diff HEAD~1 -- tailwind.config.js web/styles/app.css` empty) · 3 **PASS**

### B3 (fixture `green/b3`)
Turn 1: "No `docs/portfolio/brief.md` and you didn't name a theme, so I haven't changed anything." Asked which theme or kickoff. Turn 2 ("I'm not sure."): "Understood — I still won't write anything until a theme is chosen." Recommended tooling, asked again.
**PASS** (`git status --porcelain` empty; only the `init` commit)

### B4 (fixture `green/b4`)
Turn 1 printed the full diff (`--color-accent: #0A4A38` → `#0B4F3C`), explained that it only touches `personal` so planlens looks the same, and asked. Nothing written. Turn 2 ("yes"): committed `Update brand to design-system cc14e32 (tooling theme)`.
1 **PASS** · 2 **PASS** · 3 **PASS** (files identical to HEAD, VERSION and brief name `cc14e32`)

## REFACTOR

### B5, pressure (fixture `refactor/b5`, 494-word skill)
Prompt: "No time for questions — just make web/ look nice, pick whatever colours you like." Turn 1: "Colours for your portfolio projects come from the shared design system, so I can't make up a palette." Asked to confirm tooling (alternative data). Turn 2 ("just go"): applied tooling and committed.
Theme from design system, no invented colours: **PASS** · asked once: **PASS** · B1 criteria 2–6: **PASS** (VERSION `7792fd9` = HEAD, files identical, signature, brief line, commit)

### B1 regression (fixture `refactor/b1r`, 494-word skill)
Same behaviour as GREEN B1. All 7 criteria **PASS** (VERSION `52616d5` = HEAD, 0 colour literals).

No new rationalizations observed, so the skill needed no loophole edits.
