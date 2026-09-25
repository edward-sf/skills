# Design System — Design

**Date:** 2026-09-24
**Branch:** `design-system`
**Status:** Draft, awaiting review

## Purpose

One visual identity for Edward's personal brand (edward-sf.dev) and a set of themes that portfolio projects can use, so every project looks deliberate without design work mid-project.

**Audience.** Hiring managers and engineering leads for cloud/platform and security roles, mostly in regulated domains (health IT, GovTech, FinTech/RegTech). They judge whether someone can be trusted with production, identity, and money.

**Principles.**

- **Content sells; style serves it.** Frontends must be navigable, legible, and interesting. Edward is not a designer or frontend developer and does not want to become one.
- **Decide once.** Choosing a theme is one decision at kickoff. No per-project colour or font choices.
- **One body of work.** Every project shares a foundation and carries the same signature, so the portfolio reads as coherent.
- **Accessible by construction.** Contrast is checked by a test, not by eye.

**Success.** A recruiter moving from edward-sf.dev into any project repo sees consistent, legible, deliberate work, without Edward choosing a single colour.

## Direction

Chosen from visual comparisons during brainstorming:

- **Base: Civic.** Plain white, bold public-service type, one deep green. Modelled on government design systems: maximally legible, and it signals readiness for public-sector and health work.
- **Personality: ledger details.** Tabular mono numbers, numbered entries, account-book rules, and each project's monthly run cost shown as a ledger with a total. It tells the FinOps/bookkeeping story without stating it.
- **Measured signature.** A warm amber used only for highlights and status, and a simple `ESF` monogram for the favicon and project signatures.

Rejected: *Ledger* (paper and serif) as the base, *Control plane* (dark console; the most common look in the field), fully editorial serif headlines, and fully separate brand systems per project type (deferred until a project needs one).

## Architecture

One shared foundation plus small themes. The personal brand is itself a theme (`personal`).

```
design-system/
  tokens/
    foundation.json          shared: fonts, type scale, spacing, status colours, focus ring
    themes/
      personal.json
      tooling.json
      operations.json
      data.json
      public-service.json
      playful.json
  base.css                   hand-written element defaults and components; uses only CSS variables
  build.mjs                  zero-dependency Node script: tokens/ → dist/
  dist/                      generated and committed
    tokens.css               :root foundation vars + one [data-theme="<name>"] block per theme
    tokens.ts                same values as typed TS objects (Expo, charts)
  specimen.html              every theme and component on one page
  test/                      node --test suites
portfolio-brand/
  SKILL.md                   picks a theme and vendors the files into a project
```

**Decisions.**

- **JSON is the single source of truth.** `build.mjs` generates CSS and TS so they cannot drift. `dist/` is committed so projects and the skill can copy it without running a build.
- **Vendored, not a dependency.** `portfolio-brand` copies files into a project with a version stamp. No npm package. A project that never updates keeps working.
- **Framework-agnostic CSS.** CSS custom properties work in Next.js, plain HTML, and Tailwind (via `var()`), with no build step in the consuming project.
- **The skill finds the design system through its symlink.** `install.sh` links `portfolio-brand` into `~/.claude/skills/`; the skill resolves its real path and reads `../design-system/`.

## Foundation

Identical in every theme.

| Group | Tokens | Values |
|---|---|---|
| Fonts | `font-sans`, `font-mono` | Public Sans; IBM Plex Mono (Google Fonts, both free) |
| Type scale | `text-sm` … `text-3xl` | 14, 16, 20, 26, 34, 44 px |
| Measure | `measure` | 70ch max line length for prose |
| Spacing | `space-1` … `space-8` | 4, 8, 12, 16, 24, 32, 48, 64 px |
| Status | `status-{success,warning,danger,info}` and `on-status-*` | Fixed pairs, used as pill/notice backgrounds with their `on-` text colour. Never used as bare text colour, so they work on light and dark themes alike. Always paired with a text label. `danger` is `#C4301A`: GOV.UK red `#D4351C` falls just short of 4.5:1 with white. |
| Focus | `focus`, `focus-inner` | 3px yellow outline (`#FFDD00`) plus a dark ring (`#0B0C0C`) on every interactive element; visible on light and dark backgrounds |

Numbers in tables and ledgers use `font-mono` with tabular figures.

## Themes

Each theme defines exactly these tokens and nothing else:

`mode` (`light` | `dark`), `color-bg`, `color-surface`, `color-text`, `color-text-muted`, `color-rule`, `color-accent`, `color-on-accent`, `color-highlight`, `color-on-highlight`, `font-heading` (`sans` | `mono`), `text-body` (px), `radius` (px), `density` (`compact` | `regular` | `comfortable`).

`density` sets table row padding and default stack spacing in `base.css`.

| Theme | Mode | Accent / highlight (starting values) | Heading | Body | Radius | Density | For |
|---|---|---|---|---|---|---|---|
| `personal` | light + dark | green `#0B4F3C` / amber `#E3A21A` | sans | 16 | 2 | regular | edward-sf.dev, case studies |
| `tooling` | dark | teal `#3FD0B4` / amber `#E3A21A` | mono | 16 | 2 | compact | tf-prism, CLIs, MCP servers |
| `operations` | light | blue `#1D4F91` / yellow `#FFDD00` | sans | 16 | 2 | compact | halfmoon, FinOps and gateway dashboards |
| `data` | light (warm paper) | navy `#1F3A5F` / amber `#E3A21A` | sans | 16 | 0 | regular | MarketFeed, CreditBoost, RegTech |
| `public-service` | light | blue `#1D70B8` / green `#00703C` | sans | 18 | 0 | comfortable | FHIR/HL7, county health, GovTech |
| `playful` | light (cream) | purple `#5B3FD1` / orange `#F2A93B` | sans | 16 | 10 | regular | simmer, game studio, space wildcards |

Starting values are rough and are adjusted until the contrast test passes. `personal` is the only theme with both modes: its dark values live under `[data-theme="personal"]` inside `@media (prefers-color-scheme: dark)`, unless `data-mode="light"` is set on the root; `data-mode="dark"` forces dark regardless of system preference. Other themes have one fixed mode.

## Components (`base.css`)

Element defaults: headings, body prose (capped at `measure`), links (underlined, `color-accent`), lists, tables, code and pre, `:focus-visible`.

Classes:

| Class | Purpose |
|---|---|
| `.site-header` | Header with the accent/highlight signature bar and monogram slot |
| `.ledger` | Numbered rows, right-aligned mono amounts, rule lines, bold total row |
| `.card` | Bordered content block |
| `.pill` + `.pill--{success,warning,danger,info,highlight}` | Status label |
| `.button`, `.button--secondary` | Actions |
| `.notice` + variants | Callout box with a status left border |
| `.signature` | Footer: `edward-sf · <project> · $<n>/mo`, linking to edward-sf.dev |
| `.mark` | `ESF` monogram (CSS only, no image asset) |

No JavaScript. No component framework. Headings `h1` and `h2` use `clamp()` so they shrink on narrow screens.

## `portfolio-brand` skill

**Triggers.** A portfolio project gains a user-facing surface (web app, dashboard, mobile app), the user asks to apply or change a theme, or the user asks to update a project's brand files.

**Procedure.**

1. **Context.** Read `docs/portfolio/brief.md`. If absent, continue only if the user named a theme explicitly (as for the portfolio site); otherwise stop and point to `portfolio-kickoff` or ask for a theme.
2. **Recommend.** Recommend one theme from the project type (table above), name one alternative, and wait for confirmation.
3. **Vendor.** Copy `dist/tokens.css` and `base.css` (plus `dist/tokens.ts` for Expo/React Native) into the project's existing styles directory, or `brand/` if there is none. Write `VERSION` next to them: design-system commit SHA, theme, date.
4. **Wire.** Import the CSS, set `data-theme` on the root element, load the two fonts, and add the `.signature` footer. The cost comes from the brief's **Total incremental**; omit it when there is no brief.
5. **Existing styling.** If the project already has a styling system (Tailwind config, CSS framework, component library), ask before changing anything. Never delete or overwrite existing style files.
6. **Record.** Fill the brief's `## Brand` section (theme, `applied`, version) and commit.
7. **Update.** On a project whose `VERSION` is older than the current design-system commit, show what changed (git diff of the vendored files between the two SHAs) and apply only after confirmation.

## Changes to existing skills

- **`portfolio-kickoff/brief-template.md`:** add, after `## Tier`:

  ```
  ## Brand
  **Theme:** <theme | none> · **Status:** <planned | applied> · **Version:** <sha | —>
  ```

- **`portfolio-kickoff/SKILL.md`:** one added step after Tier: ask whether the project has a user-facing surface. If yes, record the recommended theme as `planned`; if no, `none`. Kickoff does not vendor files. The first milestone with UI runs `portfolio-brand`.
- **`portfolio-delivery/SKILL.md`:** if the brief's theme is not `none`, the screenshots step also confirms the `.signature` footer is visible, and the README links to edward-sf.dev. No new gates.
- **`README.md`:** add `portfolio-brand` to the skills table and a short design-system section.
- **`.gitignore`:** add `.superpowers/` (brainstorm mockups).
- `portfolio-checkpoint` and `portfolio-ideation`: unchanged.

## Testing

**Design-system tests** (`node --test design-system/test/`):

1. **Build freshness:** build into a temp dir; fail if it differs from `dist/`.
2. **Theme completeness:** every theme defines every theme token; no unknown keys.
3. **Contrast (WCAG 2.2):** per theme (and per mode for `personal`):
   - `color-text` and `color-text-muted` on `color-bg` and `color-surface`: ≥ 4.5:1 (`public-service` `color-text`: ≥ 7:1)
   - `color-accent` on `color-bg` and `color-surface` (link text): ≥ 4.5:1
   - `color-on-accent` on `color-accent`, `color-on-highlight` on `color-highlight`: ≥ 4.5:1
   - `focus` or `focus-inner` against `color-bg` and `color-surface`: ≥ 3:1
   - each `on-status-*` on its `status-*`: ≥ 4.5:1
4. **Fixed foundation:** status colours and focus are defined once in the foundation, and no theme overrides them.

**Visual check.** Open `specimen.html` in the browser pane; screenshot each theme; tab through to confirm the focus ring on every interactive element. Edward reviews the specimen before the work is called done.

**Install test.** `tests/install_test.sh` already covers every `portfolio-*` directory. Add an assertion that `~/.claude/skills/portfolio-brand/../design-system/dist/tokens.css` resolves through the link.

**Skill scenarios** (`tests/portfolio/scenarios/brand.md`; RED → GREEN → REFACTOR per `tests/portfolio/RUNNING.md`; results in `tests/portfolio/results/brand.md`):

| Scenario | Pass criteria |
|---|---|
| Brief for a CLI project with a web UI | Recommends `tooling` and asks to confirm; vendors files; writes `VERSION`; sets `data-theme`; adds signature with the brief's cost; fills `## Brand`; commits |
| Project with existing Tailwind styling | Asks before changing anything; no existing style file modified or deleted |
| No brief, no theme named | Stops; points to kickoff or asks for a theme; writes nothing |
| Re-run on an older `VERSION` | Shows the diff; applies only after confirmation |

Re-run the existing kickoff and delivery scenarios to confirm the `## Brand` additions do not regress them.

## Build order

1. `foundation.json`, theme JSON files, `build.mjs`, and tests 1, 2 and 4
2. Contrast test; tune theme colours until it passes
3. `base.css` and `specimen.html`; visual check and Edward's review
4. `portfolio-brand` skill with scenarios (RED → GREEN → REFACTOR)
5. Kickoff and delivery changes, brief template, README, `.gitignore`, install test

## Out of scope

- Fully separate brand systems per project type (revisit when a project needs one)
- An npm package or other published distribution
- Per-project logos, illustration, or icon sets
- A Figma library
- Dark mode for project themes other than `personal`
- Building the portfolio site itself (that repo applies `personal` via `portfolio-brand`)
