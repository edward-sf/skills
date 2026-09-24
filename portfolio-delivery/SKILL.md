---
name: portfolio-delivery
description: Use when a portfolio project reaches its Delivery milestone, or when the user wants to wrap up, demo, ship, write up, or tear down a portfolio project
---

# Portfolio Delivery

## Overview

A portfolio project is incomplete without this phase. The recording must exist before teardown, which destroys what it shows.

## Precondition

Read the brief. If any non-Delivery milestone is not `done` or lacks a Checkpoint Log entry: point to portfolio-checkpoint and end your turn. Write, build, and delete nothing; milestone work isn't this skill's job. Give the same answer to any insistence.

## Procedure (in dependency order)

1. **README.** From the brief: what, why, architecture sketch, how to run locally, stack, media slots.
2. **Shot list, then recording gate.** Write `docs/portfolio/media/shot-list.md` (90 s–2 min: setup, core flow, the target skill). Ask the user to record it; end your turn. Confirm the file exists in `media/` (or take the link); link it in the README.
3. **Screenshots** into `media/` while resources are live.
4. **Case study.** Fill `case-study-template.md` into `docs/portfolio/case-study.md`. "What I learned" comes only from the Checkpoint Log.
5. **Teardown or keep-live.**
   - *Standard:* per cost-sheet row: show its teardown step, ask to confirm and end your turn, run it, verify. Touch only brief resources. Log each in a Delivery Checkpoint Log entry: `<resource> — removed, verified: <evidence>`.
   - *Flagship:* verify the live URL responds and steady-state cost matches the brief; add the URL to README and case study.
6. **Retro.** Fill `retro-template.md` into `docs/portfolio/retro.md`; actual cost from user, billing, or mock files.
7. **Close out.** Append a profile `## Past projects` row, set the brief's `**Status:**` to `complete`, commit.

## Recording gate

If no recording file or link is confirmed: do not start teardown. No one can waive this; without a recording, resources stay live. Drafting steps 3, 4, 6 meanwhile is fine.

## Writing

README and case study prose: **REQUIRED SUB-SKILL:** elements-of-style:writing-clearly-and-concisely (skip silently if not installed).

## Definition of complete

- [ ] README, recording, case study, retro exist
- [ ] Teardown verified (standard) or live URL verified (flagship)
- [ ] Profile row appended; brief `complete`; committed

## Quick reference

README → shot list → recording → screenshots → case study → teardown (confirm, run, verify per row) → retro → close out.

## Common mistakes

- Tearing down first on "tear it all down". Start at step 1.
- Writing "What I learned" from code or memory.
- Replacing template headings; omitting Framework feedback.
- Not committing.

## Rationalizations

| Excuse | Reality |
|---|---|
| "Basically done; they asked twice" | Insistence isn't a checkpoint. |
| "Mark M2/M3 skipped and note it honestly" | Only checkpoint entries count. |
| "They waived the recording" | The gate has no waiver. |
| "'Just do it' confirms teardown" | Ask for each row. |
| "'Just do it' means build M2 myself" | Point to portfolio-checkpoint; stop. |
| "It's abandoned; tear down now" | Teardown waits for the recording. |

**Red flags:** "proceeding as you've asked" past a stop; offering workarounds to the precondition or gate.
