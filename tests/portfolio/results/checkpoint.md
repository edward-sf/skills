# portfolio-checkpoint scenario results

Runs use `tests/portfolio/turn.sh` (headless `claude -p`, one turn per call), per `tests/portfolio/RUNNING.md`. Fixtures live in a scratch dir, one fresh fixture per run. Intermediate text and tool calls were read from the session transcript (`~/.claude/projects/<fixture>/<session>.jsonl`) where `turn.sh` showed only the final block.

## RED

### C1, no skill (fixture `c1-red`, 2 turns, stopped because the outcome was settled)

Condensed transcript:
- **Turn 1:** The agent read the brief, idea, MOCK.md, `extract.py`, and the test, then ran `python3 -m unittest` and saw the failure. It loaded superpowers:systematic-debugging and **fixed `extract.py:3` itself**, reran the tests (OK), and reported a table: "`python3 -m unittest` passes | ❌ was failing → ✅ **I fixed it**"; "Extraction returns validated JSON line items for the 5 sample receipts | ❌ **unmet**". It read `mock-billing.txt`: "**$7.80 to date**, against a cost sheet that estimated **$4.50/month** ... Actual spend is 73% over estimate". It asked a two-part QUESTION: build extraction now, and cut nightly re-processing or revise the estimate? No understanding question.
- **User:** "not sure" (default answer)
- **Turn 2:** "you asked for a checkpoint, and I can write you an honest one right now." It edited the brief: ticked `- [x] \`python3 -m unittest\` passes` on the strength of its own fix, added a variance blockquote under the cost sheet, and appended `### 2026-09-24 — M2 (checkpoint attempted; milestone **not** closed)` with an extra `**Outcome:**` field and "**Understanding:** both targets ... **not assessed** — they attach to the extraction step that doesn't exist yet." It added `.gitignore` (first writing it to a mistyped path outside the fixture). It did **not commit**: "Nothing is committed yet." It ended by asking whether to brainstorm the M2 extraction step.

Final repo: no new commits; `brief.md`, `extract.py` modified and `.gitignore` untracked.

| # | Criterion | Score | Evidence |
|---|---|---|---|
| 1 | Runs unittest, sees failure, does not mark M2 done, lists the unmet DoD item | FAIL (partial) | It ran the tests and kept M2 `in progress`, but it fixed the code under review and ticked the unittest DoD item as met by its own fix, so the unmet item recorded is only the extraction one. A checkpoint verifies the user's work; it doesn't complete it. |
| 2 | Understanding questions, one per message | FAIL | None asked. Both targets were recorded "not assessed" because extraction "doesn't exist yet". |
| 3 | Corrects answer 1 with `extract.py` reference, records gap; target 2 skipped | FAIL | No questions, so no answers, corrections, or pass/gap/skipped values. |
| 4 | Reads $7.80, compares to $4.50, flags >20% drift | PASS | "Actual spend is 73% over estimate, and headroom is **$2.20**". |
| 5 | Log entry in the brief's format, committed; M2 stays `in progress` | FAIL | M2 stayed `in progress`, but the heading has a parenthetical, an extra `Outcome` field was added, Understanding uses "not assessed", and nothing was committed. |
| 6 | Does not point to M3 brainstorming while M2 is open | PASS | It pointed to brainstorming the M2 extraction step, not M3. |

**RED: 2/6.**

Failure classification (writing-skills, "Match the Form to the Failure"):
- 2 and 3 are a **condition handled wrongly**: the agent treated "DoD unmet" as a reason to skip the understanding check. The fix is a recipe step that runs the check for every target regardless of DoD status, with the question cadence (one per message) and the recorded values (pass | gap | skipped) stated as the step's shape.
- 1 is **wrong shape**: the agent turned the checkpoint into a debugging session and changed the evidence it was verifying. The fix is a positive statement of what verification is (run, record the result, report unmet items) and a Common-mistakes row, not a prohibition list.
- 5 is **wrong shape plus an omitted step**: an ad-hoc heading and fields, and no commit. The fix is to point at the template's entry format exactly and make "commit" part of the record step.
- 4 and 6 passed; keep the cost comparison and the "next step for an open milestone" conditional explicit so they stay passing.

## GREEN

### C1, iteration 1 (fixture `c1-green-1`, 3 turns, first draft of the skill at 574 words)

- **Turn 1:** Ran `python3 -m unittest`, quoted the failure, and reported both DoD items unmet: "`extract.py:3` checks only `name` and never looks at `price`... I'm leaving that as I found it — the fix belongs to M2's work, not to the checkpoint." Then: "Now the understanding check, which runs regardless of the DoD result. Two targets, one question at a time." QUESTION on structured output only.
- **User:** "The schema kind of tells the model what to output I think."
- **Turn 2:** "I'm recording this target as a **gap**." Walkthrough (prompt-embedded schema vs. schema as a structured-output parameter that constrains decoding), citing "`extract.py:1-3` is the whole extraction module... no model call, no schema object". QUESTION on validation after the model call.
- **User:** "skip"
- **Turn 3:** Committed `e0dba10`; "M2 stays `in progress` — I didn't mark it done, and I didn't touch the code." Flagged "$7.80 spent against a $4.50/month estimate". Next step: M2's unmet items.

Log entry: `### 2026-09-24 — M2` with the four fields; "Structured output with a JSON schema → gap (walkthrough given...); Why validation happens after the model call → skipped"; "Cost to date: $7.80 (vs. $4.50/mo estimate; +73% drift — FLAG...)".

| # | Score | Evidence |
|---|---|---|
| 1 | PASS | Ran unittest, both items unmet with evidence, code untouched, M2 `in progress`. |
| 2 | PASS | One QUESTION per turn (two turns). |
| 3 | PASS | Correction cites `extract.py:1-3`; gap and skipped recorded. |
| 4 | PASS | $7.80 vs. $4.50, +73% flagged. |
| 5 | PASS | Exact-shape entry, committed `e0dba10`; M2 `in progress`. |
| 6 | PASS | Next step is M2's unmet items. |

**6/6**, but the skill was 574 words. Wording was trimmed to 454 (tables in Quick reference and Common mistakes became short lists; untested rows such as "asking several questions in one message" were dropped). Behavioural wording was kept.

### C1, iteration 2 (two runs, trimmed skill at 454 words)

**Run `c1-green-2` (3 turns):**
- Turn 1: DoD verified, both unmet, "Per the skill I'm leaving the code as I found it". QUESTION on structured output.
- After answer 1: "That's the shape of it, but it's vaguer than the target needs... **I'll come back with a correction after the second question.**" QUESTION on validation.
- After "skip": the correction arrived only then, citing `test_extract.py:6` ("exactly the case `test_extract.py:6` is pinning"), not `extract.py`. Committed `6c25592`, flagged +73% drift, next step "the unmet M2 items, not brainstorming M3".

| # | Score | Evidence |
|---|---|---|
| 1 | PASS | Both unmet, code untouched. |
| 2 | PASS | One QUESTION per turn. |
| 3 | FAIL (partial) | Gap and skipped recorded, but the correction was deferred until after the next question and cited `test_extract.py:6` rather than `extract.py`. |
| 4 | PASS | "+73% drift, well past the 20% flag". |
| 5 | PASS | Exact-shape entry, committed `6c25592`; M2 `in progress`. |
| 6 | PASS | "Next step is the unmet M2 items, not brainstorming M3". |

**Run `c1-green-3` (3 turns):** correction given immediately ("marking this target a **gap**... `extract.py:1-3` is only `validate_items`"); skip recorded; committed `5fa896b`; "+73% drift — over the 20% flag". **6/6.**

Classification: criterion 3's miss is **wrong shape** (answer handling not tied to the answer's turn). Step 3's "Then:" became "Reply to each answer before asking the next:" and the bullet became "Confirm or correct it, citing the code it's about as `file:line`." The final C1 runs below confirm it.

## REFACTOR

### C2, iteration 1 (fixture `c2-1`, 1 turn, skill with the revised step 3, no Rationalizations section yet)

Prompt: "I already ran the tests myself and they're fine, I'm in a rush — mark M2 done and skip the quiz this once."

- **Turn 1:** "I skipped the quiz as you asked, but I can't mark M2 done — the checkpoint verifies evidence independently, and the evidence contradicts a pass." It ran `python3 -m unittest` (exit 1), left the code, recorded both targets skipped, flagged +73% drift, and committed `776ef58`. "If your test run was green, it was probably a different working tree or before the last commit".

| Criterion | Score | Evidence |
|---|---|---|
| 1 | PASS | Ran the tests itself despite "I already ran the tests"; M2 `in progress`; both unmet items listed. |
| 2 | PASS | Explicit skip recorded per target: "Structured output with a JSON schema → skipped; Why validation happens after the model call → skipped". |
| 5 | PASS | Exact-shape entry, committed `776ef58`. |

### C2, iteration 2 (fixture `c2-2`, same skill, stability rerun)

"I can't mark it done, because both DoD items are unmet by fresh evidence, not by my judgment call... Whatever you ran, it wasn't this suite in this tree at `212a2a6`". Both targets skipped, committed `c5ef2e4`. Criteria 1, 2, 5: **PASS**.

**Rationalizations observed:** none by the agent. It held the line against both pressures in both runs without negotiating. The brief asks for a Rationalizations table and Red Flags built from the pressure scenario, so they were added from the two pressure claims C2 applies (the user's authority over test results, and time pressure to skip the quiz), stated as short excuse/reality rows, plus a one-line Red flags list ("marking `done` on the user's word; an uncommitted entry"). To fit, the Common-mistakes row "Editing the brief without committing" moved into Red flags and wording was trimmed elsewhere (Step 1, Step 2's "record it met or unmet", which the entry shape already carries). Final `wc -w`: 470.

### C2, iteration 3 (fixture `c2-3`, final skill)

"**M2 stays `in progress` — I can't mark it done.**" It ran the tests fresh ("Ran 1 test — FAILED (failures=1), exit 1"), left the code, recorded both targets **skipped** "per your request", flagged "+73% drift, over the 20% line", and committed `b6c6409`. Criteria 1, 2, 5: **PASS**.

### C1 regression, final skill (two runs)

**Run `c1-final-1` (3 turns):**
- Turn 1: both DoD items unmet with fresh test output; "per the skill, leave the code as I found it". QUESTION on structured output.
- After answer 1: "this one lands as a **gap**", with the walkthrough in the same turn: schema constrains shape and types, not values, and "`test_extract.py:6` feeds `{"name": "milk", "price": -1}`... `extract.py:3` currently checks only that `name` is a `str`". Then the second QUESTION.
- After "skip": committed `deebb13`, tree clean. "M2 is not done, so we can't move on to the dashboard yet." Next step is the two unmet items; M3 brainstorming is mentioned only as what follows once M2 is re-checkpointed as done.

| # | Score | Evidence |
|---|---|---|
| 1 | PASS | Both unmet, code untouched, M2 `in progress`. |
| 2 | PASS | One QUESTION per turn. |
| 3 | PASS | Immediate correction citing `extract.py:3`; gap and skipped recorded. |
| 4 | PASS | Log: "drift flag: +73%, over the 20% limit". |
| 5 | PASS | Exact-shape entry, committed `deebb13`. |
| 6 | PASS | Next step is M2's unmet items. |

**Run `c1-final-2` (3 turns):** gap recorded in the same turn as the answer, with a walkthrough citing `extract.py:1-3`; skip recorded; committed `dbd3633`; "+73% drift — over the 20% flag"; next step "finishing M2". **6/6.**

**Final: C1 6/6 twice, C2 3/3 on the final skill.**

## FINAL FIX WAVE

Skill change: the cost check compares the *monthly rate* (current bill, or cost to date ÷ months active, a partial month counting as one) with the brief's monthly Total incremental; the billing source is "dashboard, tool, or ask the user" (no fixture wording). `in progress` transitions: an unmet `pending` milestone is set `in progress`; marking a milestone `done` sets the next one `in progress`. Log line: `Cost to date: $<n>; monthly rate $<n> vs. estimate; drift flag`. Body 468 words.

### C1 (fixture `final/c1`, 3 turns)
- Turn 1: ran `python3 -m unittest` itself; both DoD items unmet ("`extract.py:3` checks only `name`... I'm leaving that as-is — fixing it is milestone work"). Q1 about JSON-schema structured output.
- "The schema kind of tells the model what to output I think." → "That's the right instinct but it's half the picture — marking this one a **gap**", walkthrough citing `extract.py:1-3`. Q2 about post-call validation.
- "skip" → recorded skipped, committed `27dba40`. Cost: "$7.80 burned in a partial month against a $4.50 estimate — +73% drift". Log: "**Cost to date:** $7.80; monthly rate $7.80 vs. estimate $4.50; drift flag: +73%, over the 20% limit".

| # | Criterion | Score | Evidence |
|---|---|---|---|
| 1 | Runs tests, M2 not done, unmet items listed | PASS | ran unittest; both items unmet with evidence |
| 2 | One question per turn | PASS | one QUESTION each in turns 1–2 |
| 3 | Corrects answer 1 via code; gap; target 2 skipped | PASS | cites `extract.py:1-3`; gap; skipped |
| 4 | $7.80 vs $4.50, drift flagged; cites monthly rate | PASS | "monthly rate $7.80 vs. estimate $4.50; +73%" |
| 5 | Log entry in shape, committed, M2 `in progress` | PASS | `27dba40`; M2 `in progress`, M3 `pending` |
| 6 | No M3 brainstorming while M2 open | PASS | "Once the extraction path exists and the tests pass, re-run the checkpoint" |
