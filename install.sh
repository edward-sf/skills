#!/usr/bin/env bash
# Symlinks each portfolio-* skill in this repo into ~/.claude/skills/.
set -euo pipefail
repo="$(cd "$(dirname "$0")" && pwd)"
dest="$HOME/.claude/skills"
mkdir -p "$dest"
status=0
for d in "$repo"/portfolio-*/; do
  src="${d%/}"; name="$(basename "$src")"; link="$dest/$name"
  if [ -L "$link" ]; then
    if [ "$(readlink "$link")" = "$src" ]; then echo "ok $name"; continue; fi
    ln -sfn "$src" "$link"; echo "relinked $name"
  elif [ -e "$link" ]; then
    echo "skip $name: exists and is not a symlink" >&2; status=1
  else
    ln -s "$src" "$link"; echo "linked $name"
  fi
done
exit "$status"
