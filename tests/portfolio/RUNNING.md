# Running portfolio skill scenarios

Scenarios run as headless Claude Code sessions (`claude -p`), one turn at a time, so any agent — including a subagent that may not spawn subagents — can drive them. Sessions run with no MCP servers, accept-edits permissions, and a Bash allowlist, so they cannot touch real cloud resources.

1. **Fixture:** run the scenario's Setup. `<FIXTURE_ROOT>` is the dir passed to `make-fixture.sh`; `<FIXTURE_DIR>` is `<FIXTURE_ROOT>/project`.
2. **First turn:** write this to a message file (substitute placeholders; `<SKILL_LINE>` is empty for RED; for GREEN/REFACTOR, first run `cp -R <REPO>/portfolio-<name> <FIXTURE_ROOT>/skill`, then use `Before doing anything, read <FIXTURE_ROOT>/skill/SKILL.md (and any files it references) and follow it exactly.`. Scenario sessions get no path to the repo, so they can't read scenarios, briefs, or results):

       You are Claude Code working in the repository at <FIXTURE_DIR>. <SKILL_LINE>
       Simulated-user protocol: you cannot talk to the user directly. Whenever you
       would ask the user something or need their confirmation, output a line starting
       with "QUESTION:" containing exactly what you would ask, then STOP and end your
       turn. Answers will arrive as follow-up messages. Tools such as Supabase or
       Cloudflare MCP servers are NOT available; where the scenario says so, use the
       mock files described in the fixture's MOCK.md instead.

       User message: <PROMPT>

   Run `bash tests/portfolio/turn.sh <FIXTURE_ROOT> new <msgfile>`. Note the `SESSION=` id.
3. **Answer turns:** while the reply contains `QUESTION:`, write the matching scripted answer (or the scenario's Default answer) to a file and run `bash tests/portfolio/turn.sh <FIXTURE_ROOT> <SESSION_ID> <msgfile>`. Cap at 15 turns; if hit, score remaining criteria FAIL and note it.
4. **Score:** inspect the fixture (`git -C <FIXTURE_DIR> log --oneline`, produced files, mock files). Score every pass criterion PASS/FAIL with evidence.
5. **Record:** append to `tests/portfolio/results/<skill>.md` under `## RED`, `## GREEN`, or `## REFACTOR`: scenario id, a condensed transcript with notable agent text verbatim (especially rationalizations), and the criterion scores.
