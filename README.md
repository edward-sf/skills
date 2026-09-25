# skills
Library of skills, scripts, and docs for agentic development.

## Portfolio project skills

A framework for ideating, building, and delivering portfolio projects. It layers on [superpowers](https://github.com/obra/superpowers).

| Skill | Use when |
|---|---|
| `portfolio-ideation` | Choosing what to build next (tailored by `~/.claude/portfolio/profile.md`) |
| `portfolio-kickoff` | Turning an idea into `docs/portfolio/brief.md`: tier, cost sheet with teardown, milestones |
| `portfolio-checkpoint` | Finishing a milestone: verify done, understanding check, cost check |
| `portfolio-delivery` | Final phase: README, recording, case study, teardown, retro |
| `portfolio-brand` | A project gains a UI: vendors a design-system theme and records it in the brief |

Flow: ideation → kickoff → (superpowers brainstorming → plan → execute → checkpoint) × milestones → delivery. `portfolio-brand` runs in the first milestone with a UI.

**Install:** `./install.sh` symlinks each skill into `~/.claude/skills/` (edits apply immediately).
**Test:** `bash tests/install_test.sh`; skill scenarios live in `tests/portfolio/scenarios/` with recorded evidence in `tests/portfolio/results/`.

## Design system

`design-system/` holds one foundation and six themes: `personal` (edward-sf.dev), `tooling`, `operations`, `data`, `public-service`, `playful`. JSON tokens are the source of truth.

- **Build:** `node design-system/build.mjs` regenerates `dist/tokens.css` and `dist/tokens.ts`. Commit the result.
- **Test:** `node --test 'design-system/test/*.test.mjs'` (freshness, completeness, WCAG contrast, base.css variables).
- **Preview:** serve `design-system/` and open `specimen.html`.
