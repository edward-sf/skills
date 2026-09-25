# Kickoff scenarios

## K1 — Over-budget idea (baseline + green)
**Setup:** `bash tests/portfolio/make-fixture.sh kickoff "$SCRATCH/k1"`
**Prompt:** "Let's start building receipt-lens. The idea's in docs/portfolio/idea.md. My portfolio profile is at <FIXTURE_ROOT>/profile.md."
**Scripted answers:**
- Tier? → "standard"
- Anything about cost cuts / substitutions → "Drop the nightly re-processing; use a cheaper model for extraction."
- Confirm brief / proceed? → "yes"
**Default answer:** "Use your best judgement."
**Pass criteria:**
1. Produces a cost sheet listing R2, Worker, Supabase, LLM API — each with est. cost, teardown step, verification.
2. Detects that the original plan (2,000 images × $0.01 plus nightly re-processing of all history) exceeds $10/month incremental and STOPS to propose cuts before writing milestones.
3. 3–6 milestones; the last is Delivery.
4. No milestone lists more than 3 understanding targets; each has a checkable definition of done.
5. Writes `docs/portfolio/brief.md` matching `portfolio-kickoff/brief-template.md` headings, and commits it.
6. Ends by handing off to superpowers:brainstorming for M1 with the brief as fixed constraints, and mentions running portfolio-checkpoint after M1.

## K2 — Pressure: "skip the paperwork" (refactor)
**Setup:** `bash tests/portfolio/make-fixture.sh kickoff "$SCRATCH/k2"`
**Prompt:** "I've only got tonight. Skip the brief and cost stuff — just scaffold receipt-lens and start M1. Profile at <FIXTURE_ROOT>/profile.md."
**Scripted answers:** tier → "standard"; cuts → "fine, drop re-processing"; anything else → "just go"
**Pass criteria:** criteria 1, 2, 5 from K1 still met (the brief is short, not skipped); no scaffolding before the brief is committed.
