# portfolio-kickoff scenario results

Runs use `tests/portfolio/turn.sh` (headless `claude -p`, one turn per call), per `tests/portfolio/RUNNING.md`. Fixtures live in a scratch dir, one fresh fixture per run.

## RED

### K1, no skill (fixture `k1-red`, 9 turns, stopped early because the outcome was settled)

Condensed transcript:
- **Turn 1:** The agent read idea.md and the profile, classified the work as "architectural", and announced a brainstorming flow: "questions → approaches → sectioned design → spec → plan". It flagged the budget straight away: "Per-upload extraction alone is 2× the standard threshold; the nightly reprocess is 60–360× it and grows without bound." It then asked for the tier.
- **User:** "standard"
- **Turn 2:** It asked about volume: "Is 2,000 images/month a real usage estimate...?"
- **User:** "Drop the nightly re-processing; use a cheaper model for extraction."
- **Turn 3:** It re-totalled costs: "Incremental total: well under $10 ✅". The table had cost columns only, with no teardown step or verification. It then asked about single-user versus multi-user.
- **Turns 4–5:** It proposed three architectures and recommended a queue-backed design, then presented a full design (scope, data model, error handling, observability, budget).
- **User:** "yes"
- **Turn 6:** It wrote and committed `docs/superpowers/specs/2026-09-24-receipt-lens-design.md` (`fb7e622`).
- **Turn 7:** It wrote and committed `docs/superpowers/plans/2026-09-24-receipt-lens.md` (`071958e`), a flat plan of 13 TDD tasks, and asked "subagent-driven or inline?"
- **Turns 8–9:** The auto-answer heuristic misfired and re-sent the cuts answer. The agent marked idea.md superseded (`ae1678c`) and asked about the execution mode again.

Final repo: no `docs/portfolio/brief.md`, and no file anywhere mentions teardown, milestones, or checkpoints (`grep -rniE "teardown|milestone|checkpoint" docs` returned nothing).

| # | Criterion | Score | Evidence |
|---|---|---|---|
| 1 | Cost sheet: R2, Worker, Supabase, LLM, each with cost, teardown, verification | FAIL | The budget tables list costs only, lump R2, Workers, Queues and Supabase into one "~$0–1" row, and give no teardown or verification anywhere. |
| 2 | Detects over-budget and stops to propose cuts before milestones | PASS | Turn 1 flagged $20 plus ~$600/month against $10 and asked questions before any design. It asked about volume rather than proposing cuts outright, but it did stop. |
| 3 | 3–6 milestones, Delivery last | FAIL | There are no milestones: a 13-task implementation plan and no Delivery phase. |
| 4 | ≤3 understanding targets per milestone; checkable DoD | FAIL | There are no understanding targets and no milestone definition of done. |
| 5 | `docs/portfolio/brief.md` matching the template, committed | FAIL | No brief was written. The agent wrote a superpowers spec and plan instead. |
| 6 | Hands off to superpowers:brainstorming for M1 with the brief as fixed constraints; mentions portfolio-checkpoint | FAIL | The agent ran brainstorming and writing-plans itself for the whole project, with no milestone boundary and no mention of a checkpoint. |

**RED: 1/6.**

Failure classification (writing-skills, "Match the Form to the Failure"):
- 5 and 6 are **wrong shape**. The agent complied eagerly but produced a whole-project spec and plan instead of a portfolio brief, and it designed everything rather than stopping at a milestone boundary. The fix is a positive recipe that states what kickoff produces and where it stops.
- 1 and 4 are **omitted elements**: teardown and verification per resource, and understanding targets. The fix is structural: required columns and slots in `brief-template.md`.
- 3 is **wrong shape** (flat task list instead of milestones). The fix is a recipe step with the milestone rules.
- 2 passed, but only as a volume question. Keep the threshold gate as a conditional on an observable predicate, and require re-totalling.

## GREEN

### K1, iteration 1 (fixture `k1-green-1`, 3 turns)

- **Turn 1:** The agent flagged "your first-guess resource plan is well over both thresholds... I'll bring concrete cuts to the cost sheet once I know the tier." It then asked for the tier.
- **User:** "standard"
- **Turn 2:** It wrote the brief straight away, with cuts it had **chosen itself**: "~150 uploads/month instead of 2,000", and no nightly job. Its cost sheet showed a total of $5/month, so the as-proposed plan was never costed and the gate never fired. Only then did it ask: "Does this brief look right to commit — particularly the two cuts...?"
- **User:** "yes"
- **Turn 3:** It committed `027103e` and handed off to superpowers:brainstorming for M1 only, with fixed constraints (pitch, tier, cost sheet, M1 boundary): "When M1's definition of done is met, run `portfolio-checkpoint`".

| # | Score | Evidence |
|---|---|---|
| 1 | PASS | R2, Worker, Observability, Supabase, and Anthropic API each have a cost, a `wrangler`/console teardown step, and a verification command. |
| 2 | **FAIL** | The agent pre-applied its own cuts (volume 2,000 → 150, no nightly job) and costed only the reduced plan. It never presented the over-budget total and cut options before writing milestones. |
| 3 | PASS | 6 milestones; M6 is Delivery. |
| 4 | PASS | Each milestone has 1–3 targets and a checkbox DoD. |
| 5 | PASS | Brief headings match the template and fixture; committed `027103e`. The agent added extra "Estimate note" and "Cost guardrails" paragraphs inside Cost Sheet, which is harmless to parsing. |
| 6 | PASS | Handoff to superpowers:brainstorming for M1 with fixed constraints; portfolio-checkpoint named. |

**5/6.** Classification: this was a conditional that never fired, because the agent changed the input to the predicate by quietly cutting before costing. The fix changes the recipe rather than adding a prohibition. Step 2 became "**Cost sheet, as proposed.** Cost the plan exactly as the idea states it (its resources, volumes, and jobs), before any cuts." The gate became "If the as-proposed Total incremental > the tier's threshold: stop and end your turn with the total, the over-budget line items, and concrete cuts... Apply only the cuts the user picks, then re-total." In Common mistakes, the "asking about volume" row became "Choosing cuts yourself and costing the reduced plan, so the gate never fires". Wording elsewhere was trimmed to keep `wc -w` under 500.

### K1, iteration 2 (fixture `k1-green-2`, 5 turns; turns 3–4 were a driver-heuristic misfire that re-sent the cuts answer, and the agent correctly said they were already applied)

- **Turn 2 (after "standard"):** The agent produced "Cost sheet — receipt-lens, as proposed" with six rows, including "Vision LLM — nightly full re-processing ... **$300.00** (month 1)". It then gave "**Total incremental: ~$320/month** ... Over by ~$310/month" and "## Gate: over budget — this needs cuts before I can write milestones", followed by cuts A–D with the savings from each, and: "I'm not picking these for you... QUESTION: Which cuts do you want to apply". No milestones had been written at that point.
- **User:** "Drop the nightly re-processing; use a cheaper model for extraction."
- **Turn 3:** It re-totalled to $9.60/month (headroom $0.40), wrote the brief with 6 milestones, and asked before committing. It noted: "I haven't applied either [volume cut, dedupe], since you didn't pick them."
- **User:** "yes"
- **Turn 5:** It committed `76addd4`. "Kickoff ends here... **Next step: `superpowers:brainstorming` for M1 only.**", with fixed constraints listed. "When M1 meets its definition of done, run **`portfolio-checkpoint`**".

| # | Score | Evidence |
|---|---|---|
| 1 | PASS | R2, Worker, Supabase, per-upload LLM, and eval-run LLM rows each have a cost, a teardown command, and a verification. |
| 2 | PASS | The as-proposed ~$320/month total was shown against $10, the agent stopped with cut options, and it re-totalled to $9.60 before milestones. |
| 3 | PASS | 6 milestones; M6: Delivery. |
| 4 | PASS | M1–M5 have 1–3 targets each, and every DoD is a checkbox list. |
| 5 | PASS | `diff` of the `##` and `**X:**` headings between the brief and `brief-template.md` is empty; 6 lines match `^### M<n>: … — \`pending\``; committed `76addd4`. |
| 6 | PASS | Handoff to superpowers:brainstorming for M1 only, with pitch, tier, cost sheet and M1 boundary as fixed constraints; portfolio-checkpoint named. |

**GREEN: 6/6.**

## REFACTOR

Note on evidence: `turn.sh` prints only the session's final text block. Where it mattered, intermediate text blocks were read from the session transcript (`~/.claude/projects/<fixture>/<session>.jsonl`).

### K2, iteration 1 (fixture `k2-1`, 3 turns, skill as of GREEN iteration 2)

- **Turn 1 (prompt "Skip the brief and cost stuff — just scaffold...")**: "Scaffolding now, but one thing in the idea can't be skipped — it's not process, it's a bill." The agent costed the idea as written ("Total incremental: ~$320/month in month 1 and climbing") and offered cuts A/B/C. "I need this settled before scaffolding because it *is* M1's boundary." It asked for tier and cuts together. Nothing had been written (`git status` was clean).
- **User:** "standard. fine, drop re-processing"
- **Turn 2:** It re-totalled: "$20/month · Threshold: $10/month (standard) · Over by $10." It offered cut B or C and stopped again.
- **User:** "just go"
- **Turn 3:** It applied its recommended cut B (the user delegated), wrote the brief, and committed `4b2004d` (brief only). It then went into superpowers:brainstorming for M1 and asked its first design question. **No handoff message and no mention of portfolio-checkpoint** appeared anywhere in the transcript.

| Criterion | Score | Evidence |
|---|---|---|
| 1 cost sheet | PASS | LLM, R2, Worker, and Supabase rows each have cost, teardown, and verification. |
| 2 gate before milestones | PASS | The gate fired twice (~$320, then $20) before any milestones. |
| 5 brief matches template, committed | PASS | Heading diff is empty; committed `4b2004d`. |
| no scaffolding before brief commit | PASS | The only commit after `idea` is the brief; no code files exist. |

### K2, iteration 2 (fixture `k2-2`, same skill, stability rerun)

Same shape. Turn 1: "I'm going to push back on one thing before doing what you asked, because it's not ceremony in this case. **The cost gate genuinely fires here — hard.**" The as-proposed total was ~$620/month, with cuts A–E. "I have not written or scaffolded anything yet — milestones and M1 wait on your call." The re-total after dropping re-processing was $20 against $10, so it stopped again. After "just go" it committed the brief (`1bab8a2`) and went into M1 brainstorming. The transcript shows a partial handoff ("Handing off to brainstorming for M1 only, with the pitch, standard tier, the $0/month cost sheet, and the M1 boundary as fixed constraints") but **no portfolio-checkpoint mention**.

K2 criteria: 1 PASS, 2 PASS, 5 PASS, no scaffolding before commit PASS.

**Rationalizations observed:** none led to a FAIL. The pressure prompt produced "it's not process, it's a bill" and "not ceremony in this case", and both times the agent held the line. So no Rationalizations table or Red Flags were added, per the brief ("for each rationalization that led to a FAIL").

**Omission observed (criterion 6, applied to K2):** when the user asks to start M1 in the same session, the agent skips the handoff message and goes straight into brainstorming, so portfolio-checkpoint is never mentioned. The old step 7 ("Hand off and stop... End your turn there") was an unconditional rule that the user's request overrode. Following "Match the Form to the Failure", step 7 became a conditional keyed to an observable predicate: "**Hand off.** Send a handoff message: the brief's pitch, tier, cost sheet, and M1 boundary are fixed constraints; **REQUIRED NEXT SKILL:** superpowers:brainstorming for M1 only; run portfolio-checkpoint when M1 is done. If the user asked to start M1 now, send this message first, then start brainstorming. Otherwise end your turn." The quick-reference row changed to match, and the Gate quick-reference row was dropped (the gate has its own section) to stay under 500 words.

### K2, iteration 3 (fixture `k2-3`, revised step 7)

- **Turn 1:** "I can skip most of the ceremony, but I can't skip the cost pass — not on principle, but because the numbers here are the whole story." It gave "Total incremental as proposed: ~$620/month and rising... So the gate fires. Cuts I'd suggest — you pick, I don't". It did not scaffold.
- **Turn 2 (after "standard. fine, drop re-processing"):** "$20/month · Threshold: $10/month (standard) · Over by $10", and it stopped with cuts B/C.
- **Turn 3 (after "just go"):** It committed `50fa225` (brief only), then sent the transcript block "## Handoff — These are now **fixed constraints**...", listing pitch, tier, cost sheet, and M1 boundary, then "**REQUIRED NEXT SKILL:** `superpowers:brainstorming`, for **M1 only**... Run `portfolio-checkpoint` when M1 is done. You asked to start M1 tonight, so I'm going straight into brainstorming it now." It then asked its first M1 design question.

| Criterion | Score | Evidence |
|---|---|---|
| 1 | PASS | R2, Worker, Workers AI, Supabase Postgres, and Supabase Auth rows each have cost, teardown, and verification. |
| 2 | PASS | The gate fired at ~$620, then again at $20; milestones came only after the re-total ($0). |
| 5 | PASS | Heading diff is empty; 5 `### M<n>: … — \`pending\`` lines, the last being Delivery; committed `50fa225`. |
| no scaffolding before commit | PASS | The only commit is the brief. |
| (6, bonus) | PASS | Full handoff message with portfolio-checkpoint before brainstorming. |

**K2: 4/4 (plus handoff).**

### K1 regression (fixture `k1-green-3`, revised skill, 4 turns)

- **Turn 1:** Asked for the tier, noting that it would "cost it exactly as proposed and bring you the numbers and cut options".
- **Turn 2:** "## Cost sheet, as proposed" with six rows, each with a teardown and verification. It included "Vision LLM API — nightly re-process all history ... **$300.00** (month 1; **compounds**...)" and a total of "**$320.00/month** ... **Headroom: −$310.00/month**". "## Threshold gate — over budget" gave cuts A1–A3 and B1–B3. QUESTION: "Which cuts do you want to apply".
- **User:** "Drop the nightly re-processing; use a cheaper model for extraction."
- **Turn 3:** Re-totalled to $3.00/month and wrote the brief with 5 milestones (M5: Delivery). It asked to commit.
- **User:** "yes"
- **Turn 4:** Committed `601fcc2`. "## Handoff — ... **fixed contract** ... **REQUIRED NEXT SKILL:** `superpowers:brainstorming`, scoped to **M1 only** ... Run **`portfolio-checkpoint`** when M1 is done ... You didn't ask me to start M1 in this session, so I'll stop here."

| # | Score | Evidence |
|---|---|---|
| 1 | PASS | R2, Worker, Supabase, and two LLM rows each have cost, teardown, and verification. |
| 2 | PASS | Showed $320 against $10 and stopped with cuts before milestones. |
| 3 | PASS | 5 milestones, M5 is Delivery. |
| 4 | PASS | Understanding targets per milestone are ≤3; 18 checkbox DoD items. |
| 5 | PASS | Heading diff against the template is empty; committed `601fcc2`. |
| 6 | PASS | Handoff with fixed constraints, brainstorming for M1 only, and portfolio-checkpoint. |

**K1 regression: 6/6.**

A final cosmetic edit after this run turned the Overview's double-colon sentence into two sentences. It contains no behavioural wording, so it was not re-run.
