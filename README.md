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

Flow: ideation → kickoff → (superpowers brainstorming → plan → execute → checkpoint) × milestones → delivery.

**Install:** `./install.sh` symlinks each skill into `~/.claude/skills/` (edits apply immediately).
**Test:** `bash tests/install_test.sh`; skill scenarios live in `tests/portfolio/scenarios/` with recorded evidence in `tests/portfolio/results/`.
