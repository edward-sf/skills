---
name: portfolio-ideation
description: Use when the user wants a new portfolio project, asks what to build next for their portfolio, or has a vague portfolio project idea that needs sharpening
---

# Portfolio Ideation

## Overview

Ideation decides *what* to build, tailored to the profile, and ends at a committed `docs/portfolio/idea.md`. *How* (tier, costs, milestones, architecture) belongs to portfolio-kickoff.

## Profile

Path: `~/.claude/portfolio/profile.md`, or the path the user names.

- **If the profile file is missing:** interview one question per message and write it from `profile-template.md` (in this skill's directory) before ideating. Cover every template section in order, Constraints included. Keep every heading exactly.
- **If it exists:** read it, then ask once whether anything changed; update it if so.

## Procedure

1. **Profile** (above).
2. **Goal.** Ask what this project should prove: the target skill or technology, and why now. End your turn.
3. **Candidates.** 3–5 projects, or variants of the user's idea. **Exactly one is labeled `Wildcard`:** outside the stated interests but still serving the goal.
4. **Scores table.** One row per candidate, columns as in the idea.md Scores table. Each score is 1–3, higher is better:
   - Showcase value: visibly proves the goal.
   - Cost fit: incremental cost within the profile's standard threshold (note flagship-eligible if within the flagship threshold).
   - Demo-ability: shown in 2 minutes or less.
   - Scope risk: lower risk, higher score.
5. **Overlap flags.** Under the table, name each candidate that re-proves a Past project, and which.
6. **User picks.** Show the candidates, table, and flags; you may recommend one. Ask which to build and end your turn. The pick is the user's reply: a candidate, or yes / "your call" to your recommendation.
7. **Repo check.** If the working directory isn't the new project's repo (no git repo, or clearly something else: a skills library, a project with its own `docs/portfolio/brief.md`), ask where it is or offer to `git init` a directory they name. End your turn.
8. **Write `docs/portfolio/idea.md`** (shape below) only after the pick; **commit** it in the project repo.
9. **Hand off.** **REQUIRED NEXT SKILL:** portfolio-kickoff. End your turn.

## idea.md shape

```markdown
# Idea: <name>

**Pitch:** <one or two sentences>

**Showcases:** <skills and technologies this project proves>

**Rationale:** <why this candidate, tied to the goal and profile>

## Scores
| Candidate | Showcase value | Cost fit | Demo-ability | Scope risk | Total |
|---|---|---|---|---|---|
<the chosen candidate's row>

## Rejected candidates
- <name> — <one-line reason>
```

## Common mistakes

| Mistake | Fix |
|---|---|
| Running brainstorming into a design spec or plan | Stop at the committed idea.md. |
| Inferring the goal; unscored "approaches" with no wildcard | Ask the goal; score candidates; one `Wildcard`. |
| Treating the repo's name as the chosen idea | It's one candidate at most. |

## Rationalizations

| Excuse | Reality |
|---|---|
| "They asked for one idea, so I'll pick it" | Show the table and your recommendation; "yes" is one word. |
| "I'll decide and say it's reversible" | Writing idea.md before their reply is picking for them. |

**Red flag:** idea.md written in the same turn as the scores table.
