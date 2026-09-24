---
name: portfolio-delivery
description: Use when a portfolio project reaches its Delivery milestone, or when the user wants to wrap up, demo, ship, write up, or tear down a portfolio project
---

# Portfolio Delivery

## Overview

A portfolio project is incomplete without this phase. The recording must exist before teardown, which destroys what it shows.

## Precondition

- User explicitly says abandoned, not delivered: follow **Abandon path**.
- User asks only for teardown: ask whether they're abandoning or delivering; end your turn.
- Otherwise, if any non-Delivery brief milestone is not `done` or lacks a Checkpoint Log entry: point to portfolio-checkpoint and end your turn. Write, build, and delete nothing. Give the same answer to any insistence.

## Procedure (in dependency order)

1. **README.** From the brief: what, why, architecture sketch, how to run, stack, media slots.
2. **Shot list, then recording gate.** Write `docs/portfolio/media/shot-list.md` (90 s–2 min: setup, core flow, the target skill). Ask the user to record it; end your turn. Confirm the file in `media/` or the link; link it in the README.
3. **Screenshots** into `media/` while resources are live.
4. **Case study.** Fill `case-study-template.md` into `docs/portfolio/case-study.md`. "What I learned" comes only from the Checkpoint Log.
5. **Teardown or keep-live.**
   - *Standard:* per cost-sheet row: show its teardown step, ask to confirm and end your turn, run it, run its `Teardown verification`. Touch only brief resources. Log each in the Checkpoint Log: `<resource> — removed, verified: <evidence>`.
   - *Flagship:* verify the live URL and cost against the brief; add the URL to README and case study.
6. **Retro.** Fill `retro-template.md` into `docs/portfolio/retro.md`; actual cost from user, billing, or mock files.
7. **Close out.** Append a profile `## Past projects` row, set brief `**Status:** complete`, commit.

## Recording gate

If no recording file or link is confirmed: do not start teardown. No one can waive this.

## Abandon path

Confirm once it will be recorded `abandoned`, not complete; end your turn. Then skip the precondition, recording, screenshots, and case study: run step 5 (standard), write a short retro (Cost, Milestones reached, Framework feedback), set `**Status:** abandoned`, commit.

## Writing

README and case study prose: **REQUIRED SUB-SKILL:** elements-of-style:writing-clearly-and-concisely (skip silently if not installed).

## Definition of complete

- [ ] README, recording, case study, retro exist
- [ ] Teardown or live URL verified
- [ ] Profile row; brief `complete`; committed

## Quick reference

README → shot list → recording → case study → teardown → retro → close out.

## Common mistakes

- Tearing down first on "tear it all down".
- Writing "What I learned" from code or memory.
- Replacing template headings; omitting Framework feedback.

## Rationalizations

| Excuse | Reality |
|---|---|
| "Basically done; they insist" | Insistence isn't a checkpoint. |
| "Note the open milestones honestly" | Only checkpoint entries count. |
| "They waived the recording" | No waiver. |
| "'Just do it' confirms teardown, or means build M2 myself" | Ask per row; milestones are portfolio-checkpoint's. |
| "'I'm done, tear it down' means abandoned" | Only explicit abandonment. Ask. |

**Red flags:** "proceeding as you've asked" past a stop; offering workarounds.
