# Ideation scenarios

## I1 — Profile-driven ideation (baseline + green)
**Setup:** `bash tests/portfolio/make-fixture.sh ideation "$SCRATCH/i1"`
**Prompt:** "I want a new portfolio project, I know React and Supabase. My profile is at <FIXTURE_ROOT>/profile.md."
**Scripted answers:**
- Anything changed in profile? → "no"
- What should it prove? → "Cloudflare Workers and LLM evaluation"
- Pick one → "the first non-wildcard candidate"
**Default answer:** "your call"
**Pass criteria:**
1. Reads the profile before proposing.
2. 3–5 candidates, each scored 1–3 on showcase value, cost fit, demo-ability, scope risk.
3. Exactly one candidate labeled wildcard.
4. Flags any candidate overlapping pantry-pal (Supabase auth/RLS household sharing).
5. Writes `docs/portfolio/idea.md` with pitch, rationale, scores, rejected candidates + reasons; commits.
6. Hands off to portfolio-kickoff (does not start planning milestones itself).

## I2 — Missing profile (green)
**Setup:** `bash tests/portfolio/make-fixture.sh ideation "$SCRATCH/i2" && rm "$SCRATCH/i2/profile.md"`
**Prompt:** "What should I build next for my portfolio? Use <FIXTURE_ROOT>/profile.md as my profile path."
**Scripted answers:** each profile interview question → short plausible answer ("full-stack roles", "React/Supabase", "Workers + LLMs", "cooking", "~$50 existing, defaults fine", "pantry-pal")
**Pass criteria:** interviews one question at a time; writes profile from `profile-template.md` at the given path before generating candidates.

## I3 — Pressure: "just pick for me" (refactor)
**Setup:** as I1. **Prompt:** "Just give me one idea, don't make me choose. Profile at <FIXTURE_ROOT>/profile.md."
**Pass criteria:** still presents scored candidates incl. wildcard (may recommend one); user picks.

## I4 — Wrong repo (final fix wave)
**Setup:** `bash tests/portfolio/make-fixture.sh ideation "$SCRATCH/i4"`, then in `<FIXTURE_ROOT>/project` write `portfolio-kickoff/SKILL.md` containing `# a skills library`, set README.md to `# skills library`, and commit.
**Prompt:** "I want a new portfolio project. My profile is at <FIXTURE_ROOT>/profile.md."
**Scripted answers:** as I1, plus: where's the project repo? → "create it at <FIXTURE_ROOT>/newproj"
**Default answer:** "your call"
**Pass criteria:** asks about the repo before writing idea.md; idea.md ends up committed in `<FIXTURE_ROOT>/newproj`, not in `project`.
