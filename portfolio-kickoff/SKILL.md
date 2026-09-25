---
name: portfolio-kickoff
description: Use when starting to build a portfolio project, when a portfolio project repo has no docs/portfolio/brief.md, or when turning a chosen portfolio idea into a scoped, budgeted plan
---

# Portfolio Kickoff

## Overview

Kickoff produces one artifact: `docs/portfolio/brief.md`, committed. It is the fixed contract later phases work inside. Kickoff decides *what* and *how much*; architecture, specs, plans, and code happen per milestone, after the handoff.

## Precondition

If `docs/portfolio/brief.md` already exists, stop: don't overwrite it. Point to portfolio-checkpoint.

## Inputs

- `docs/portfolio/idea.md` if present; otherwise ask for the pitch and showcased skills.
- Profile thresholds from `~/.claude/portfolio/profile.md`, or the profile path the user names. If no threshold is found: $10/month standard, $2/month flagship.

## Procedure

1. **Tier.** Ask: standard (recorded, then torn down) or flagship (stays live within the flagship threshold).
2. **Cost sheet, as proposed.** Cost the plan exactly as the idea states it (its resources, volumes, and jobs), before any cuts. One row per resource, each with: est. monthly cost, covered by existing plan?, an exact teardown step, and how to verify it's gone. Estimates are fine.
3. **Threshold gate** (below).
4. **Milestones.** 3–6, each reviewable in one sitting. Each has a one-line goal, a checkable definition of done, and at most 3 new-concept understanding targets (more → split it). The last is always `Delivery`.
5. **Write the brief** by filling `brief-template.md` (in this skill's directory) into `docs/portfolio/brief.md`. Keep every heading exactly; all milestones start `pending`. Show it and confirm.
6. **Commit** the brief.
7. **Hand off.** Send a handoff message: the brief's pitch, tier, cost sheet, and M1 boundary are fixed constraints; **REQUIRED NEXT SKILL:** superpowers:brainstorming for M1 only; run portfolio-checkpoint when M1 is done. If the user asked to start M1 now, send this message first, then start brainstorming. Otherwise end your turn.

## Threshold gate

If the as-proposed Total incremental > the tier's threshold: stop and end your turn with the total, the over-budget line items, and concrete cuts or substitutions for the user to choose from. Apply only the cuts the user picks, then re-total. Repeat until Total incremental ≤ threshold. Only then write milestones.

## Quick reference

| Step | Output |
|---|---|
| Tier | `standard` or `flagship` |
| Cost sheet | Per resource: cost, teardown, verification; total vs. threshold |
| Milestones | 3–6, ≤3 targets each, checkable DoD, Delivery last |
| Brief | `docs/portfolio/brief.md`, committed |
| Handoff | Message first; brainstorming M1; checkpoint after |

## Common mistakes

| Mistake | Fix |
|---|---|
| Running brainstorming for the whole project, then writing a spec and a flat task plan | Kickoff ends at the committed brief. Brainstorming runs for M1 only, inside the brief. |
| Cost table with prices but no teardown or verification | Every row needs both. |
| Lumping services into one "~$0–1" row | One row per resource. |
| Choosing cuts yourself and costing the reduced plan, so the gate never fires | Cost the idea as written; the user picks the cuts. |
