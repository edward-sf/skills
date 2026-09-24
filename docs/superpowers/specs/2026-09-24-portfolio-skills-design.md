# Portfolio Project Skills — Design

**Date:** 2026-09-24
**Branch:** `portfolio-skills`
**Status:** Approved in brainstorming; awaiting spec review

## Purpose

A framework for ideating, building, and delivering standalone portfolio projects (each in its own repo, later showcased on edward-sf.dev) without re-explaining the framework per project.

Problems it addresses:

1. **Scoping and kickoff are loose.** Right-sizing to the cost budget and pacing milestones are hit-or-miss.
2. **Delivery is untested.** Projects get close to demo but have no defined finish line.

Core rules the framework enforces:

- **Cost ceiling:** ~$50/month is already committed (Supabase, Cloudflare, Claude Code). A standard project may add at most **$10/month incremental** while active; a flagship may add at most **$2/month incremental** at steady state. These thresholds live in `profile.md` so they can be changed without editing skills.
- **Milestones are paced for understanding and progress:** each has a checkable definition of done and a small set of understanding targets.
- **Delivery is a mandatory final phase.** A project without it is incomplete.
- **Standing up resources implies tearing them down** during Delivery, unless the project is a designated flagship.

## Relationship to superpowers

These skills **layer on top of** superpowers. They add portfolio-specific constraints and phases; superpowers still does generic brainstorming, planning, and execution.

```
portfolio-ideation → portfolio-kickoff → superpowers:brainstorming → superpowers:writing-plans → execute
                                                    ↑                                               │
                                                    └──────── portfolio-checkpoint ◄────────────────┘
                                                              (after every milestone)
                                                                        │ next milestone is Delivery
                                                                        ▼
                                                              portfolio-delivery
```

## Repository layout

```
skills/                                  (this repo)
  portfolio-ideation/
    SKILL.md
    profile-template.md
  portfolio-kickoff/
    SKILL.md
    brief-template.md
  portfolio-checkpoint/
    SKILL.md
  portfolio-delivery/
    SKILL.md
    case-study-template.md
    retro-template.md
  install.sh
```

**Installation:** `install.sh` symlinks each `portfolio-*` directory into `~/.claude/skills/`. It is idempotent, skips non-symlink conflicts with a warning rather than overwriting, and prints what it linked. Edits in this repo take effect immediately.

The existing `design/` directory is unrelated to this work and is left untouched.

## Files and state

| File | Location | Written by | Read by |
|---|---|---|---|
| `profile.md` | `~/.claude/portfolio/profile.md` (outside any repo; personal data) | ideation (creates/updates), delivery (appends past project) | ideation |
| `idea.md` | `<project>/docs/portfolio/idea.md` | ideation | kickoff |
| `brief.md` | `<project>/docs/portfolio/brief.md` | kickoff (creates), checkpoint (appends), delivery (marks complete) | checkpoint, delivery |
| `case-study.md` | `<project>/docs/portfolio/case-study.md` | delivery | — |
| `retro.md` | `<project>/docs/portfolio/retro.md` | delivery | — (human; feeds framework changes) |
| `media/` | `<project>/docs/portfolio/media/` | delivery | README, case study |

Every skill after ideation starts by reading `brief.md`. If it is missing, the skill stops and directs the user to `portfolio-kickoff` (or `portfolio-ideation`).

### `profile.md` sections

- Target roles / direction
- Current skills (confident)
- Skills to prove (want showcased)
- Interests
- Constraints: existing spend (~$50/month: Supabase, Cloudflare, Claude Code); incremental thresholds (standard $10/month, flagship $2/month)
- Past projects: name, what it showcased, repo link, tier, date completed

### `brief.md` sections

1. **Pitch:** one or two sentences.
2. **Showcases:** the skills and technologies this project proves.
3. **Tier:** `flagship` (stays live) or `standard` (recorded, then torn down).
4. **Cost sheet:** table with columns `resource | purpose | est. monthly cost | covered by existing plan? | teardown step | teardown verification`. Ends with a total and headroom against the ceiling.
5. **Milestones:** 3–6 entries, the last always **Delivery**. Each entry has:
   - Goal (one line)
   - Definition of done (checkable items)
   - Understanding targets (at most 3 new concepts)
   - Status: `pending` | `in progress` | `done`
6. **Checkpoint log:** appended entries (see portfolio-checkpoint).
7. **Status:** `active` | `complete` | `abandoned`.

## Skill 1: `portfolio-ideation`

**Triggers:** "new portfolio project", "what should I build next", or a vague project idea that needs sharpening.

**Scope:** decides *what* to build. It does not plan how.

**Steps:**

1. Read `~/.claude/portfolio/profile.md`. If it is missing, interview the user one question at a time to create it from `profile-template.md`. If it exists, ask whether anything has changed.
2. Ask what this project should prove: the target skill or technology, and why now.
3. Generate 3–5 candidates, or variants of the user's idea. **Exactly one** candidate is a *wildcard*: outside the stated interests but still serving the stated goals.
4. Score each candidate from 1 to 3 on:
   - **Showcase value:** visibly demonstrates the target skill.
   - **Cost fit:** runs within the ceiling headroom, and can be recorded and torn down.
   - **Demo-ability:** can be shown in 2 minutes or less.
   - **Scope risk:** inverse; lower risk scores higher.
   - Flag overlap with past projects in the profile.
5. The user picks one. Write `docs/portfolio/idea.md` (pitch, rationale, chosen scores, rejected candidates with one-line reasons) and commit.
6. Hand off to `portfolio-kickoff`.

## Skill 2: `portfolio-kickoff`

**Triggers:** after ideation, or "start building X" in a repo without `docs/portfolio/brief.md`.

**Steps:**

1. Read `idea.md` if it exists. Otherwise capture the pitch and showcased skills directly.
2. **Tier:** ask whether this project is flagship or standard. Flagship requires steady-state incremental cost within the profile's flagship threshold (default $2/month), via free tier, scale-to-zero, or an existing plan.
3. **Cost sheet:** enumerate every resource to be stood up, with estimated cost, a teardown step, and a verification method. **Hard stop:** if estimated incremental cost exceeds the profile's threshold for the tier (default $10/month standard, $2/month flagship), propose cuts or substitutions and do not proceed until the sheet fits.
4. **Milestones:** draft 3–6. The final milestone is always Delivery. **Sizing rule:** if a milestone has more than 3 new-concept understanding targets, split it. Each milestone must be reviewable in one sitting.
5. Write `brief.md` from `brief-template.md` and commit.
6. Hand off to `superpowers:brainstorming` for milestone 1. The brief's pitch, tier, cost sheet, and milestone boundaries are **fixed constraints**. Brainstorming refines how, not what, and the resulting plan must stay within the milestone. Tell the user to run `portfolio-checkpoint` when the milestone is done.

## Skill 3: `portfolio-checkpoint`

**Triggers:** "finished milestone N", "checkpoint", or completion of a milestone's plan execution.

**Steps:**

1. **Locate:** read the brief. The current milestone is the first one not marked `done`.
2. **Verify done:** check each definition-of-done item against evidence (test run output, running feature, commits). Unmet items are listed and the milestone stays open. **Never mark a milestone done on assertion alone.**
3. **Understanding check:** for each understanding target (2–4 questions total), ask **one question at a time** for an explanation in the user's own words. Then:
   - Confirm or correct the answer, referencing actual `file:line`.
   - If the answer is shaky, offer a short walkthrough and record the target as a *gap*.
   - The user may skip a target; record it as *skipped*.
4. **Cost check:** get actual cost to date, from the user or from dashboards and tools where available. Flag drift over 20% versus the estimate, or anything threatening the ceiling.
5. **Scope check:** if this milestone revealed work that makes the next milestone exceed the sizing rule, propose a split and update the brief.
6. **Record:** append a checkpoint log entry (date, milestone, done evidence, understanding results per target as pass / gap / skipped, cost to date, adjustments). Mark the milestone `done` and commit.
7. **Next:** point to `superpowers:brainstorming` for the next milestone. If the next milestone is Delivery, point to `portfolio-delivery`.

## Skill 4: `portfolio-delivery`

**Triggers:** the Delivery milestone, or "wrap up / demo / ship this project".

**Precondition:** every non-Delivery milestone has a checkpoint log entry and is `done`. Otherwise the skill refuses and points to `portfolio-checkpoint`.

**Steps, in dependency order:**

1. **README:** write or update it with: what the project is, why it exists, an architecture sketch, how to run it locally, the stack, and media slots. The brief is the source of truth.
2. **Demo recording:** write a shot list (90 seconds to 2 minutes: setup, core flow, one moment showing the target skill). The user records it. The skill confirms the file exists in `docs/portfolio/media/` (or at an external link) and embeds or links it in the README. **Gate:** step 5 cannot start until this passes.
3. **Screenshots:** capture them while resources are live (browser tools where possible) into `docs/portfolio/media/`.
4. **Case study:** write `docs/portfolio/case-study.md` from `case-study-template.md`: problem, approach, key decisions and trade-offs, challenges, what I learned. "What I learned" draws on the checkpoint log's understanding results and must not be invented. The draft is written to move to edward-sf.dev with minimal edits.
5. **Teardown / keep-live:**
   - *Standard:* for each cost-sheet resource, show the teardown step, **get the user's confirmation**, run or guide it, and run its verification. Record each resource as confirmed-removed.
   - *Flagship:* verify the live URL responds and that steady-state cost matches the brief. Record the URL in the README and case study.
6. **Retrospective:** write `docs/portfolio/retro.md` from `retro-template.md`: estimated vs. actual cost, planned vs. actual milestones, understanding gaps and skips, what went well, and **framework feedback** (concrete suggested changes to these skills).
7. **Close out:** append the project to past projects in `profile.md`, set the brief status to `complete`, and commit.

**Definition of complete:** README, recording, case study, and retro all exist; teardown is verified for standard projects (or the live URL is verified for flagship projects); the profile is updated.

**Abandon path:** if the user explicitly declares the project abandoned (not delivered), the skill confirms once that it will be recorded as `abandoned`, not complete. It then bypasses the milestone precondition and skips the recording, screenshots, and case study. It runs the step-5 teardown per cost-sheet row (confirmation and verification, brief resources only), writes a short retro (cost, milestones reached, framework feedback), sets the brief status to `abandoned`, and commits. Pressure such as "I'm done, just tear it down" is not an explicit abandonment: the skill asks whether the user is abandoning or delivering. The recording gate still applies to Delivery.

## Testing

Follow `superpowers:writing-skills` (RED → GREEN → REFACTOR) using subagent scenarios.

**Fixtures:** a fake project repo and a fake profile in the session scratchpad. Tests never touch the real `~/.claude/portfolio/` or real cloud resources. Teardown is tested against mock resource lists.

| Skill | Baseline (RED) scenario | Pass criteria |
|---|---|---|
| ideation | "I want a portfolio project, I know React and Supabase", with a fake profile listing a past Supabase-auth project | Reads the profile; gives 3–5 scored candidates with exactly one wildcard; flags the duplicate; writes `idea.md` |
| kickoff | An idea requiring R2 plus a paid LLM API at volume | Produces a cost sheet with teardown steps; stops when over the ceiling; milestones have ≤3 concepts each; Delivery is last |
| checkpoint | "Milestone 2 is done, move on" with a failing test and a vague answer to an understanding question | Refuses to mark done; asks one question at a time; records the gap; flags cost drift |
| delivery | "Tear it all down and write the case study" with no recording present | Enforces recording before teardown; asks before each deletion; verifies removal; writes a retro with framework feedback |

REFACTOR adds pressure variants (urgency, "just skip it", ambiguity) and closes any rationalizations observed.

**Out of scope:** formal trigger-accuracy evals. Descriptions are written carefully and refined from real use.

## Build order

1. `portfolio-kickoff`, which defines the brief format everything else reads
2. `portfolio-checkpoint`
3. `portfolio-delivery`
4. `portfolio-ideation`
5. `install.sh` and a README update

## Out of scope (for now)

- A centralized idea backlog across projects
- Plugin/marketplace packaging
- Automated video capture
- Publishing case studies to edward-sf.dev automatically
