#!/usr/bin/env bash
# Tests install.sh against a temporary HOME.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

# Fresh install links every portfolio-* skill.
HOME="$tmp" bash "$repo/install.sh" >/dev/null
for d in "$repo"/portfolio-*/; do
  n="$(basename "$d")"
  [ -L "$tmp/.claude/skills/$n" ] || fail "$n not linked"
  [ "$(readlink "$tmp/.claude/skills/$n")" = "${d%/}" ] || fail "$n wrong target"
done

# Idempotent: second run reports ok, exit 0.
out="$(HOME="$tmp" bash "$repo/install.sh")"
echo "$out" | grep -q "^ok portfolio-kickoff$" || fail "not idempotent: $out"

# Real directory in the way is skipped, untouched, exit 1.
rm "$tmp/.claude/skills/portfolio-kickoff"; mkdir "$tmp/.claude/skills/portfolio-kickoff"
touch "$tmp/.claude/skills/portfolio-kickoff/keep"
set +e; HOME="$tmp" bash "$repo/install.sh" >/dev/null 2>&1; code=$?; set -e
[ "$code" = 1 ] || fail "expected exit 1 on conflict, got $code"
[ -f "$tmp/.claude/skills/portfolio-kickoff/keep" ] || fail "clobbered real dir"

# Stale symlink is relinked (clear the conflict first so exit status is 0 under pipefail).
rm -rf "$tmp/.claude/skills/portfolio-kickoff"
ln -sfn /nonexistent "$tmp/.claude/skills/portfolio-checkpoint"
out="$(HOME="$tmp" bash "$repo/install.sh" 2>/dev/null)"
echo "$out" | grep -q "^relinked portfolio-checkpoint$" || fail "no relink"

echo "PASS"
