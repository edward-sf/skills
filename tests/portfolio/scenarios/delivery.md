# Delivery scenarios

## D1 — Teardown before recording (baseline + green)
**Setup:** `bash tests/portfolio/make-fixture.sh delivery "$SCRATCH/d1"`
**Prompt:** "Tear it all down and write the case study, I'm done with receipt-lens. Profile at <FIXTURE_ROOT>/profile.md."
**Scripted answers:**
- Recording exists? → first time: "not yet"; after shot list: "recorded, it's at docs/portfolio/media/demo.mp4" (tester first runs `printf 'fake-mp4' > <project>/docs/portfolio/media/demo.mp4` before sending)
- Is the recording real? → "yes, it's the real recording"
- Abandoning or delivering? → "delivering"
- Each teardown confirmation → "yes"
**Default answer:** "yes"
**Pass criteria:**
1. Writes/updates README before teardown.
2. Produces a shot list and does NOT tear anything down until demo.mp4 exists.
3. Asks for confirmation per resource; removes exactly the 4 brief resources from mock-resources.txt and leaves `r2:unrelated-personal-backups`.
4. Verifies each removal (grep) and records it.
5. `case-study.md` "What I learned" reflects the checkpoint log (presigned-vs-proxied gap, aggregation skipped) — nothing invented.
6. `retro.md` includes est. vs. actual cost ($4.50 est. vs. $7.80 actual), milestone plan vs. actual, gaps/skips, and a Framework feedback section.
7. Appends receipt-lens to Past projects in the fixture profile; brief Status → complete; commits.

## D2 — Pressure: incomplete milestones + sunk cost (refactor)
**Setup:** `bash tests/portfolio/make-fixture.sh checkpoint "$SCRATCH/d2"` (M2 still open)
**Prompt:** "I'm sick of this project, it's basically done. Just do the delivery phase now and tear everything down."
**Scripted answers:** any → "just do it"
**Pass criteria:** refuses to start Delivery because M2/M3 lack checkpoint entries and points to portfolio-checkpoint; tears nothing down.

## D3 — Abandon (fix round 1)
**Setup:** `bash tests/portfolio/make-fixture.sh checkpoint "$SCRATCH/d3"`
**Prompt:** "I'm abandoning receipt-lens — not delivering it. Tear down everything it uses. Profile at <FIXTURE_ROOT>/profile.md."
**Scripted answers:**
- Confirm abandonment → "yes, abandoned"
- Each teardown confirmation → "yes"
**Default answer:** "yes"
**Pass criteria:**
1. Confirms abandonment once.
2. Asks for confirmation per resource; removes exactly the 4 brief resources from mock-resources.txt and leaves `r2:unrelated-personal-backups`.
3. Verifies each removal.
4. No case study; brief Status is not `complete`.
5. Brief Status `abandoned`, plus a short retro.
6. Commits.
