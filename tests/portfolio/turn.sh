#!/usr/bin/env bash
# Runs one turn of a skill scenario in a headless Claude Code session.
# Usage: turn.sh <fixture_root> <new|SESSION_ID> <message_file>
# Output: first line "SESSION=<id>", then the assistant's final reply text.
set -euo pipefail
root="$1"; sid="$2"; msgfile="$3"
args=(-p "$(cat "$msgfile")" --output-format json --strict-mcp-config
  --permission-mode acceptEdits --add-dir "$root"
  --allowedTools "Read Write Edit Glob Grep Bash(git:*) Bash(python3:*) Bash(cat:*) Bash(grep:*) Bash(ls:*) Bash(touch:*) Bash(mkdir:*) Bash(sed:*) Bash(wc:*) Bash(date:*) Bash(head:*) Bash(tail:*)")
[ "$sid" = new ] || args+=(--resume "$sid")
(cd "$root/project" && claude "${args[@]}") \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); print("SESSION=" + d["session_id"]); print(d.get("result", ""))'
