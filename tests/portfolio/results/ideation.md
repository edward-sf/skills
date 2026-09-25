# portfolio-ideation scenario results

Runs follow `tests/portfolio/RUNNING.md` and the current `turn.sh` (headless `claude -p`, one turn per call, `--add-dir <fixture_root>` only). Each run used a fresh fixture under the scratch dir. For GREEN/REFACTOR, `portfolio-ideation/` was copied to `<fixture_root>/skill/` and the skill line pointed there. Message files lived next to the fixture root (`<root>.msg1.txt`, `<root>.ans.txt`), not inside it. Tool calls and intermediate text were read from the session transcripts (`~/.claude/projects/<fixture>/<session>.jsonl`).

## RED

### I1, no skill (fixture `i1-red`, 4 turns)

Scripted answers were used where a question matched; otherwise the default "your call".

- **Tool calls:** loaded `superpowers:brainstorming` first, then read the profile and the fixture README (`# receipt-lens`).
- **Turn 1:** no "has anything changed?" and no "what should it prove?" question. It inferred the goal from the profile: "your profile says the portfolio gap is Cloudflare/edge, LLM evaluation, and observability. `pantry-pal` already showcases Supabase auth + RLS + Expo. A second project on the same stack adds little signal." Then: "QUESTION: The repo is already named `receipt-lens` — is that the project you have in mind ...?" (Answer: "your call".)
- **Turn 2:** "`receipt-lens` is the project." It offered three *approaches* to receipt-lens (A eval-first pipeline, B polished consumer app, C edge-performance showcase), prose trade-offs only, no scores, no wildcard. B: "This mostly re-proves what `pantry-pal` proved". It recommended A. QUESTION: "Approach A as described ... or do you want me to adjust the balance before I write the design?" (Answer: "the first non-wildcard candidate".)
- **Turn 3:** "Reading 'the first non-wildcard candidate' as **A** ... (I never labeled anything a wildcard, so tell me if you meant B)." It then wrote a full architecture design (components, data flow, tables, error handling, testing, cost, slicing into three specs). (Answer: "your call".)
- **Turn 4:** "Spec written and committed to `docs/superpowers/specs/2026-09-24-receipt-lens-design.md` on branch `design/receipt-lens`." QUESTION: "anything you want changed before I invoke writing-plans for slice 1?"
- Final repo: `4c0d869 Add receipt-lens design spec` on a new branch; no `docs/portfolio/idea.md`.

| # | Criterion | Score | Evidence |
|---|---|---|---|
| 1 | Reads the profile before proposing | PASS | Tool call 2 reads `profile.md`, before any candidate. |
| 2 | 3–5 candidates, each scored 1–3 on the four criteria | FAIL | Three approaches, prose trade-offs only; no scores. |
| 3 | Exactly one wildcard | FAIL | None; the agent said so itself. |
| 4 | Flags overlap with pantry-pal | PASS | "pantry-pal already showcases Supabase auth + RLS + Expo"; B "mostly re-proves what pantry-pal proved". |
| 5 | `docs/portfolio/idea.md` with pitch, rationale, scores, rejected + reasons; commits | FAIL | Wrote and committed a design spec instead; no idea.md. |
| 6 | Hands off to portfolio-kickoff, no milestone planning | FAIL | Ran brainstorming through to a committed architecture spec, sliced the work, and offered writing-plans. |

**RED: 2/6.** Also not in the criteria but in the spec's procedure: no "anything changed?" question and no "what should this project prove?" question; the goal was inferred.

Failure classification (writing-skills, "Match the Form to the Failure"):
- 2, 3 and 5 are **wrong shape / omitted elements**: the agent produced candidates, but as unscored approaches with no wildcard, and wrote a spec rather than an idea file. Fix: a positive recipe — a scores table with the four named columns, a Wildcard slot, and an `idea.md` shape listing its parts in order.
- 6 is **wrong scope**: brainstorming was treated as the ideation process and ran on into design. Fix: an Overview line that ideation decides *what*, a procedure that ends at a committed idea.md plus the kickoff handoff, and a Common-mistakes row naming "brainstorming → design spec".
- The skipped questions are **omitted steps**; they become numbered procedure steps with "end your turn".
- 1 and 4 passed. Keep the profile read and the overlap check as explicit steps.
- No rationalization for breaking a known rule was observed (there was no rule to break), so no Rationalizations table is warranted from RED.

## GREEN

### I1, iteration 1 (fixture `i1-g1`, 4 turns, first draft, 468-word body)

- **Tool calls:** read `skill/SKILL.md`, then the profile, then the README. No `Skill` calls; no brainstorming.
- **Turn 1:** summarized the profile. QUESTION: "Has anything in that profile changed since it was written ...?" → "no".
- **Turn 2:** QUESTION: "What should this project prove? ... I'd rather not guess which one this build is for." → "Cloudflare Workers and LLM evaluation".
- **Turn 3:** four candidates (Recipe Rewriter Bench, Receipt-to-Ledger, Component Doc Critic, "`Wildcard` — Edge Eval Gateway"), a scores table with the four columns plus Total, and overlap flags: "**#2 Receipt-to-Ledger** — re-proves pantry-pal directly: user-scoped Supabase data behind RLS is the same spine"; #1 "shares pantry-pal's food domain". Recommended #1. QUESTION: "Which one do you want to build?" → "the first non-wildcard candidate".
- **Turn 4:** committed `c19414a` (`docs/portfolio/idea.md` only; tree clean). "Ideation stops here — scope, budget, and milestones are the next skill's job, not mine. **REQUIRED NEXT SKILL: portfolio-kickoff**".
- idea.md: `# Idea:`, `**Pitch:**`, `**Showcases:**`, `**Rationale:**`, `## Scores` (chosen row), `## Rejected candidates` with a reason per line, the wildcard included.

| # | Score | Evidence |
|---|---|---|
| 1 | PASS | Profile read (tool call 2) before any candidate. |
| 2 | PASS | 4 candidates, each scored 1–3 on all four criteria. |
| 3 | PASS | Exactly one `Wildcard`. |
| 4 | PASS | Receipt-to-Ledger flagged for re-proving pantry-pal's Supabase/RLS spine. |
| 5 | PASS | idea.md in the required shape; committed. |
| 6 | PASS | Stopped at idea.md; named portfolio-kickoff; no planning. |

**6/6.** Observation, not a criterion: it read the profile's thresholds as "inverted" ($2 flagship < $10 standard) and scored cost fit against $2. RED did the same. Tier is kickoff's decision, so this was left alone; see the task report.

### I2, iteration 1 (fixture `i2-g1`, 8 turns, same draft)

- One QUESTION per turn: roles → skills → skills to prove → interests → past projects → pantry-pal details ("your call"). **It never asked about Constraints**: "I kept the template's default budget constraints". Then it wrote `profile.md` at the named path with every template heading, and asked the goal question. Candidates and a scores table with one Wildcard came after.

| Criterion | Score | Evidence |
|---|---|---|
| Interviews one question at a time | FAIL (partial) | One question per message, but the Constraints section was filled from defaults without asking; the scripted "~$50 existing, defaults fine" answer was never reached. |
| Writes profile from template at the given path before candidates | PASS | `profile.md` written with all headings before the goal question and the candidates. |

Fix (omitted step): the missing-profile line now says "Cover every template section in order, Constraints included."

### I2, iteration 2 (fixture `i2-g2`, 9 turns, Constraints line added)

- "**Section 1 of 6: Target roles / direction**" … "**Section 5 of 6: Constraints** — The template ships with these defaults: ... QUESTION: Do those cost constraints match your situation ...?" → "~$50 existing, defaults fine". "**Section 6 of 6: Past projects**" → "pantry-pal", then a pantry-pal follow-up → "your call".
- Profile written at the given path, all headings kept; pantry-pal row marked "(assumed — not confirmed by user)". Next turn: "The skill is explicit that I ask this rather than infer it" and the goal QUESTION.

| Criterion | Score | Evidence |
|---|---|---|
| Interviews one question at a time | PASS | Six sections, one QUESTION each, Constraints included. |
| Writes profile from template at the given path before candidates | PASS | Written before the goal question. |

## REFACTOR

### I3, iteration 1 (fixture `i3-r1`, 4 turns, skill with the Constraints line)

- **Turn 1:** "I'll do the work of picking — I'll give you a clear recommendation rather than a menu — but the skill I'm following requires showing the scored alternates and having you confirm the pick". QUESTION: anything changed? → "no". Goal → "Cloudflare Workers and LLM evaluation".
- **Turn 3:** four candidates, "Prompt Arena `Wildcard`", scores table, overlap flags, "My recommendation: Mise". QUESTION: "Go with Mise? Say yes and I'll write and commit `docs/portfolio/idea.md`, or name one of the others instead."
- **Turn 4:** the tester sent a stronger pressure line than the scenario's default: "I said don't make me choose. Just pick one and write it up." It wrote and committed idea.md for Mise (`b88f45e`) and handed off to portfolio-kickoff.

**PASS:** scored candidates with a wildcard were shown; the user answered the pick question by delegating to the recommendation.

### I3, iteration 2 (fixture `i3-r2`, 3 turns, same skill, scenario default answers)

- **Turn 1:** "I'll still build and score the candidate set (the skill requires it, and it's what makes the pick defensible), but I'll make the call myself and hand you one idea rather than a menu." QUESTION: anything changed? → "no".
- **Turn 2:** QUESTION on the goal → "Cloudflare Workers and LLM evaluation".
- **Turn 3:** no candidates or table in the message. It wrote and committed idea.md (`da7f94e`) in the same turn: "**`docs/portfolio/idea.md` — ledgerlens.** One idea, no menu." and "Two things I decided rather than asked ... I broke the 11–11 tie with mise on the pantry-pal overlap flag. Both are reversible — say the word and I'll re-pick." The scores and the wildcard exist only inside idea.md's Rejected list.

**FAIL:** the user never saw the candidates and never picked.

### I1, runs on the iteration-1 REFACTOR skill (fixtures `i1-f1`, `i1-f2`)

- `i1-f1` (4 turns): 6/6. Four candidates, `D. evalbench — Wildcard`, table, flags (A overlaps pantry-pal "only if you build it as an Expo app with Supabase household sharing"; B "would re-prove the same Supabase + Expo pairing"). Pick → A; committed `9070455`; "Ideation ends here ... **REQUIRED NEXT SKILL: portfolio-kickoff.**"
- `i1-f2`: **discarded (driver bug).** The auto-answer script matched "chang" in "Changelog Triage" inside the pick question and sent "no". The agent asked "is that 'none of these four' or 'not Ledger Lens'?", got "your call", and picked Token Cop itself. Not scored. The driver's patterns were tightened.

Classification of the I3 failure: a **discipline failure**. The agent read the rule, said so, and then negotiated it away because the user asked for one idea ("I'll make the call myself", "Both are reversible"). Form: a step that makes the pick observable (show the table, ask, end your turn; write idea.md only after the reply), a Rationalizations table with the two observed excuses, and one red flag (idea.md written in the same turn as the scores table). A "yes" or "your call" given *in reply to* the pick question accepts the recommendation; that keeps I3's default answer from looping forever.

### Iteration 2 (final skill: step 6 shows the table and asks, step 7 writes only after the reply, Rationalizations table + red flag; 474-word body)

**I3 (fixture `i3-r3`, 4 turns, default answers):**
- Turn 1: "On 'don't make me choose' — I'll do the work of choosing: you'll get one clear recommendation, and 'yes' is a complete answer." It bundled the anything-changed and goal questions into one QUESTION; "no" → it re-asked the goal alone → "Cloudflare Workers and LLM evaluation".
- Turn 3: four candidates, "**Gauntlet** `Wildcard`", scores table ("cost fit judged against your $10/mo standard threshold"), overlap flags, "**My recommendation: Mise.**" QUESTION: "Go with Mise? Reply 'yes' and I'll write and commit `docs/portfolio/idea.md` ... or name another candidate". Nothing was written that turn.
- "your call" → committed `d49e672`, handed off to portfolio-kickoff.

**PASS.** Scored candidates with one wildcard were shown before any write; the user's reply to the pick question chose.

**I3 (fixture `i3-r4`, 4 turns, same skill):** "I'll do the scoring work myself and come back with a single recommendation you just have to say 'yes' to". Five candidates with "`Wildcard` civic-minutes", table, recommendation, QUESTION "Build receipt-lens? Reply 'yes' ... or name a different candidate." → "your call" → committed `92afa7f`. **PASS.**

**I2 (fixture `i2-g3`, 10 turns, same skill):** six profile QUESTIONs, one per turn, Constraints included ("Do these cost constraints match your situation ...?"), plus one pantry-pal follow-up; `profile.md` written at the given path with every heading before the goal question; candidates with one Wildcard came in turn 9. **PASS / PASS.**

**I1 (fixture `i1-f3`, 4 turns):** anything changed → "no"; goal → answer; five candidates, "**E. `Wildcard` — Prompt-Injection Defense Arena**", scores table, flags ("**A** overlaps **pantry-pal** on domain ... if Supabase household sharing with RLS becomes the centerpiece, it re-proves pantry-pal"), recommendation A. QUESTION "Which candidate ... or 'yes' to go with my recommendation of A?" → "the first non-wildcard candidate" → idea.md committed `6b0dc4e`; "Ideation stops here ... **REQUIRED NEXT SKILL: portfolio-kickoff.**" **6/6.**

**I1 (fixture `i1-f4`, 4 turns):** same flow; "(Note: the repo here is named `receipt-lens` — I'm treating that as at most a candidate, not a decision.)" Four candidates, "evalgate `Wildcard`", receipt-lens flagged ("re-proves **pantry-pal** (Supabase auth + RLS, Expo) *if* built as an Expo app with household sharing"). Pick → receipt-lens; committed `058b297`; handed off. **6/6.**

Both final I1 idea.md files have `# Idea:`, `**Pitch:**`, `**Showcases:**`, `**Rationale:**`, `## Scores` with the chosen row, and `## Rejected candidates` with a reason on every line (the wildcard included).

## Isolation

Every session's tool calls (all 13 fixtures above) were scanned for `Documents/GitHub/skills`, `.claude/skills`, and `.claude/portfolio`: **no hits**. The only read outside a fixture was RED's `elements-of-style` plugin file after it loaded that skill. GREEN/REFACTOR sessions made no `Skill` calls.

## Summary

| Run | Skill | Result |
|---|---|---|
| I1 RED (`i1-red`) | none | 2/6 |
| I1 GREEN 1 (`i1-g1`) | draft | 6/6 |
| I2 GREEN 1 (`i2-g1`) | draft | FAIL (partial): Constraints not asked |
| I2 GREEN 2 (`i2-g2`) | + Constraints line | PASS |
| I3 REFACTOR 1 (`i3-r1`) | + Constraints line | PASS (tester's stronger delegation line) |
| I3 REFACTOR 1 (`i3-r2`) | + Constraints line | FAIL: wrote idea.md without showing candidates or asking |
| I1 (`i1-f1`) | + Constraints line | 6/6 |
| I1 (`i1-f2`) | + Constraints line | discarded (driver bug) |
| I3 REFACTOR 2 (`i3-r3`, `i3-r4`) | final | PASS, PASS |
| I2 (`i2-g3`) | final | PASS |
| I1 final (`i1-f3`, `i1-f4`) | final | 6/6, 6/6 |

## FINAL FIX WAVE

Skill changes: Cost fit reads "incremental cost within the profile's standard threshold (note flagship-eligible if within the flagship threshold)"; new step 7 **Repo check** before writing idea.md; Quick reference cut.

### I1 iteration 1 (fixture `final/i1`, 5 turns, skill at `ea47116`)
Step 7 read: "If the working directory isn't the new project's repo (no git repo, or clearly something else: ...), ask where it is...".
- Candidates 4, one `Wildcard`, scored table with "**flagship-eligible**" notes, overlap flag on Candidate 1 (pantry-pal food domain). User picked the first non-wildcard (Recipe Rewriter Bench).
- Then: "its README reads `# receipt-lens`, which is the name of candidate 2, not the recipe bench you picked. I don't want to assume this directory is meant for the project you chose." QUESTION about which repo. Default "your call" → wrote and committed `2814a56` in `project` (also rewrote README).
Criteria 1–6 PASS, but **FAIL (partial)** on the wave's expectation "writes there without asking": the repo's name triggered the repo check.
Fix: "7. **Repo check.** Use the working directory, whatever its name, unless it isn't a git repo or clearly belongs elsewhere (a skills library, a project with its own `docs/portfolio/brief.md`). Then ask where it is or offer to `git init` a directory they name; end your turn." (499 words.)

### I4 iteration 1 (fixture `final/i4`, 5 turns, skill at `ea47116`)
After the pick: "the current working directory (`.../i4/project`) is your skills library — it has a `portfolio-kickoff` directory and a README that just says 'skills library.' That's not where Mise should live." QUESTION for the repo path → "create it at <FIXTURE_ROOT>/newproj" → `git init`, idea.md committed `3e97e6d` in newproj; `project` unchanged. PASS.

### I1 iteration 2 (fixture `final/i1b`, 4 turns)
- Turn 1 read the profile, asked if anything changed. "no" → goal question. Goal → 4 candidates (Recipe Salvage, Receipt → Ledger, Edge Eval Runner, Council Watch `Wildcard`), table with Cost fit notes "*(flagship-eligible)*", overlap flag: "Recipe Salvage re-proves pantry-pal's territory — food and ingredient data — though not its skills".
- Pick → no repo question; idea.md committed `565147b` in `project` (it noted the `receipt-lens` name mismatch inside idea.md instead of asking). Handoff: "**Required next skill: portfolio-kickoff.**"

| # | Criterion | Score | Evidence |
|---|---|---|---|
| 1 | Reads profile first | PASS | profile summary in turn 1 |
| 2 | 3–5 candidates, 4 scores each | PASS | 4 candidates, full table |
| 3 | Exactly one wildcard | PASS | Council Watch |
| 4 | pantry-pal overlap flagged | PASS | Recipe Salvage flagged |
| 5 | idea.md (pitch, rationale, scores, rejected + reasons), committed | PASS | `565147b` |
| 6 | Hands off to kickoff, no milestones | PASS | handoff only |
| + | Writes in the fixture repo without asking | PASS | no repo QUESTION |

### I4 iteration 2 (fixture `final/i4b`, 5 turns)
- Same flow; after the pick: "The working directory here (`.../i4b/project`) is a skills library — README says 'skills library' and it contains `portfolio-kickoff/SKILL.md` — so I shouldn't write `docs/portfolio/idea.md` into it." QUESTION: "Where should the Mise repo live?" → "create it at <FIXTURE_ROOT>/newproj".
- `newproj`: `7926d7c Add portfolio idea: Mise` (idea.md only). `project`: unchanged (`e2077c7 skills library`, clean).

| Criterion | Score | Evidence |
|---|---|---|
| Asks before writing | PASS | repo QUESTION in turn 3, nothing written before it |
| idea.md committed in newproj, not project | PASS | `7926d7c` in newproj; project log unchanged |
