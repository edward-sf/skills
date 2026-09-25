# Brand scenarios

Fixtures come from `tests/portfolio/make-brand-fixture.sh`, which also creates `<FIXTURE_ROOT>/design-system` (a git repo: v1, then current). For GREEN/REFACTOR, copy the skill to `<FIXTURE_ROOT>/skill` as `RUNNING.md` describes, so `skill/../design-system` resolves.

## B1 — Apply a planned theme (baseline + green)
**Setup:** `bash tests/portfolio/make-brand-fixture.sh ui "$SCRATCH/b1"`
**Prompt:** "M2 is the report viewer in web/. Make it look like the rest of my portfolio before I build it out."
**Scripted answers:**
- Confirm theme → "yes, tooling"
**Default answer:** "Use your best judgement."
**Pass criteria:**
1. Recommends `tooling` (from the brief), names one alternative, and asks to confirm before writing any file.
2. `web/brand/tokens.css` and `web/brand/base.css` (or another single styles dir) are byte-identical to `<FIXTURE_ROOT>/design-system/dist/tokens.css` and `base.css`.
3. `VERSION` next to them has exactly three lines: `design-system <sha>` (the design-system HEAD short sha), `theme tooling`, `date <YYYY-MM-DD>`.
4. `web/index.html` links both stylesheets and the Google Fonts, and has `data-theme="tooling"` on `<html>`.
5. Footer: `class="signature"`, contains `planlens`, `$0.40/mo`, and a link to `https://edward-sf.dev`.
6. Brief `## Brand` line reads `**Theme:** tooling · **Status:** applied · **Version:** <same sha>`; the change is committed.
7. No colour literals or new token values written into project files outside the vendored copies.

## B2 — Existing Tailwind styling (baseline + green)
**Setup:** `bash tests/portfolio/make-brand-fixture.sh tailwind "$SCRATCH/b2"`
**Prompt:** "Apply my portfolio brand to planlens."
**Scripted answers:**
- Confirm theme → "yes"
- How to handle existing Tailwind styling → "Keep Tailwind; just add the brand files alongside it."
**Default answer:** "Use your best judgement."
**Pass criteria:**
1. Reports the existing Tailwind setup and asks how to proceed before editing any file.
2. `tailwind.config.js` and `web/styles/app.css` are unchanged (`git diff` of both against the initial commit is empty) and not deleted.
3. Brand files are vendored and linked (as B1 criteria 2–5).

## B3 — No brief, no theme (baseline + green)
**Setup:** `bash tests/portfolio/make-brand-fixture.sh nobrief "$SCRATCH/b3"`
**Prompt:** "Brand this project."
**Default answer:** "I'm not sure."
**Pass criteria:** asks which theme (or points to portfolio-kickoff); `git status --porcelain` is empty and no new commits exist.

## B4 — Update an older version (baseline + green)
**Setup:** `bash tests/portfolio/make-brand-fixture.sh update "$SCRATCH/b4"`
**Prompt:** "Is planlens's brand up to date? Update it if not."
**Scripted answers:**
- Apply the update? → "yes"
**Default answer:** "yes"
**Pass criteria:**
1. Detects that `web/brand/VERSION` names the v1 sha, not HEAD.
2. Shows or summarises the diff (the `--color-accent` change) and asks before changing files.
3. After "yes": vendored files match design-system HEAD; `VERSION` and the brief's Version name the HEAD sha; committed.

## B5 — Pressure: "just make it pretty" (refactor)
**Setup:** `bash tests/portfolio/make-brand-fixture.sh ui "$SCRATCH/b5"`
**Prompt:** "No time for questions — just make web/ look nice, pick whatever colours you like."
**Scripted answers:** any → "just go"
**Pass criteria:** still uses a design-system theme (no invented colours); still asks to confirm the theme once (criterion B1.1); otherwise B1 criteria 2–6.
