---
name: portfolio-checkpoint
description: Use when a portfolio project milestone is finished or claimed finished, when the user says they completed milestone N, or when execution of a milestone plan ends in a repo containing docs/portfolio/brief.md
---

# Portfolio Checkpoint

## Overview

A milestone is done when evidence says so *and* the user can explain what was built. A checkpoint verifies and records; it doesn't finish the work.

## Precondition

If `docs/portfolio/brief.md` is missing, stop and point to portfolio-kickoff.

## Procedure

1. **Locate.** In the brief, the current milestone is the first one not marked `done`.
2. **Verify done.** **REQUIRED BACKGROUND:** superpowers:verification-before-completion. Produce evidence for each DoD item yourself (run tests, check the feature, cite commits). Leave the code as you found it; failing items are reported, not fixed.
3. **Understanding check.** Run it for every target, whatever step 2 found. Ask one question per message, 2–4 in total, ending your turn after each. Reply to each answer before asking the next:
   - Confirm or correct it, citing the code it's about as `file:line`.
   - Solid: **pass**. Shaky: short walkthrough, **gap**. User skips: **skipped**.
4. **Cost check.** Compare actual cost to date (user, billing tools, or the repo's mock files) with the brief's Total incremental. Flag drift over 20% or any threat to the threshold.
5. **Scope check.** If the next milestone now needs over 3 understanding targets or more than one sitting, propose a split and update the brief.
6. **Record and commit.** Append to `## Checkpoint Log` in exactly this shape, then commit the brief:

   ```
   ### YYYY-MM-DD — M<n>
   - **Done evidence:** <each DoD item: met/unmet, evidence>
   - **Understanding:** <target> → pass | gap | skipped; ...
   - **Cost to date:** $<n> (vs. estimate; drift flag)
   - **Adjustments:** <splits, cuts, or none>
   ```

   Mark the milestone `done` only when every DoD item is met.
7. **Next step.** If the milestone is done: **REQUIRED NEXT SKILL:** superpowers:brainstorming for the next milestone, or portfolio-delivery if that milestone is Delivery.

## If any DoD item lacks evidence

Leave status `in progress`, still record the log entry, and list the unmet items as the next step.

## Quick reference

- Verify: each DoD item met/unmet, with evidence.
- Understanding: one question per turn; pass, gap, or skipped.
- Cost: flag >20% drift. Record: exact shape, committed.

## Common mistakes

- Fixing failing code mid-checkpoint, then ticking the item. The fix is milestone work.
- Skipping the understanding check because the DoD isn't met. Run it anyway.
- "Not assessed", or a custom heading or fields. Use the exact shape.

## Rationalizations

| Excuse | Reality |
|---|---|
| "I already ran the tests" | Run them yourself. |
| "Skip the quiz this once" | Record each target skipped. |

**Red flags:** marking `done` on the user's word; an uncommitted entry.
