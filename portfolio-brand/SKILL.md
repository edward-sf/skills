---
name: portfolio-brand
description: Use when a portfolio project gains a web, dashboard, or mobile UI, when the brief's Brand status is planned, when the user asks to apply, change, or update a project's theme or brand files, or when styling the edward-sf.dev portfolio site
---

# Portfolio Brand

## Overview

Vendors one design-system theme into a project. Themes are chosen, not designed: never invent colours, fonts, or components.

**Design system:** resolve this skill's real directory (`realpath` on this `SKILL.md`), then use `../design-system/`. Version = `git -C <design-system> log -1 --format=%h -- .`

## Themes

| Theme | For |
|---|---|
| `personal` | edward-sf.dev, case studies |
| `tooling` | CLIs, dev tools, MCP servers |
| `operations` | Status, SLO, cost dashboards |
| `data` | Tabular/financial data, models |
| `public-service` | Health, GovTech, regulated services |
| `playful` | Consumer apps, games, hobby projects |

## Procedure

1. **Context.** Read `docs/portfolio/brief.md`. No brief and no theme named by the user: ask which theme (or point to portfolio-kickoff) and end your turn having written nothing.
2. **Confirm before writing.** Take the brief's planned theme, or recommend one from the table, and name one alternative. If the project has a styling system (Tailwind config, CSS framework, component library, existing stylesheets), say what you found and ask how to proceed in the same question. End your turn. No file changes until the user answers.
3. **Vendor.** Copy `dist/tokens.css` and `base.css` (plus `dist/tokens.ts` for Expo/React Native) into `brand/` beside the UI entry point. Write `brand/VERSION`:
   ```
   design-system <sha>
   theme <name>
   date <YYYY-MM-DD>
   ```
4. **Wire.** In the entry page only: link both stylesheets and the fonts (Public Sans 400/700/800, IBM Plex Mono 400/600 from Google Fonts), set `data-theme="<name>"` on `<html>`, and add
   ```html
   <footer class="signature">edward-sf · <project> · $<total>/mo · <a href="https://edward-sf.dev">edward-sf.dev</a></footer>
   ```
   `<total>` is the brief's **Total incremental**; with no brief, omit that segment. Add nothing else: no headers, nav, README edits, or config changes.
5. **Record.** Set the brief's Brand line to exactly `**Theme:** <name> · **Status:** applied · **Version:** <sha>` (add `## Brand` after `## Tier` if missing). Commit.

## Update

If `brand/VERSION`'s sha differs from the current version, show `git -C <design-system> diff <old> HEAD -- dist/tokens.css base.css`, summarise it in plain words, ask to apply, and end your turn. On yes: re-copy, rewrite `VERSION`, update the brief's Version, commit.

## Common mistakes

| Mistake | Fix |
|---|---|
| Writing files, then asking | Step 2 question first; end the turn |
| Picking a theme when there's no brief and none named | Ask; write nothing |
| Editing Tailwind config or existing CSS to "integrate" | Never, unless the user asks for it in reply to step 2 |
| No `VERSION`, or "v2 (abc123)" in the brief | Exact formats above; bare short sha |
| Leaving changes uncommitted | Commit (step 5, Update) |
| Updating before showing the diff | Diff, summarise, ask |
