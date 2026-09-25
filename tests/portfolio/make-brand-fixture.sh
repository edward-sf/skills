#!/usr/bin/env bash
# Generates a throwaway fixture for portfolio-brand scenario tests.
# Usage: make-brand-fixture.sh <ui|tailwind|nobrief|update|dirty|gone> <dir>
# Creates <dir>/project (git repo) and <dir>/design-system (git repo with two
# commits: an older version, then the current one). Prints <dir>/project.
set -euo pipefail

variant="${1:-}"; dir="${2:-}"
case "$variant" in ui|tailwind|nobrief|update|dirty|gone) ;; *)
  echo "usage: $0 <ui|tailwind|nobrief|update|dirty|gone> <dir>" >&2; exit 2;; esac
[ -n "$dir" ] || { echo "missing <dir>" >&2; exit 2; }
if [ -d "$dir" ] && [ -n "$(ls -A "$dir")" ]; then echo "$dir is not empty" >&2; exit 1; fi

repo="$(cd "$(dirname "$0")/../.." && pwd)"
ds_src="${DS_SRC:-$repo/design-system}"
[ -f "$ds_src/dist/tokens.css" ] || { echo "no design system at $ds_src" >&2; exit 1; }

gitinit() { git -C "$1" init -q; git -C "$1" config user.email fixture@example.com; git -C "$1" config user.name Fixture; }

# Design system: commit 1 is an "older" version (different personal accent), commit 2 is current.
ds="$dir/design-system"
mkdir -p "$ds"
cp -R "$ds_src/." "$ds/"
rm -rf "$ds/test"
gitinit "$ds"
sed -i.bak 's/--color-accent: #0B4F3C;/--color-accent: #0A4A38;/' "$ds/dist/tokens.css" && rm "$ds/dist/tokens.css.bak"
git -C "$ds" add -A && git -C "$ds" commit -qm "design system v1"
old_sha="$(git -C "$ds" rev-parse --short HEAD)"
old_dir="$dir/.ds-v1"; mkdir -p "$old_dir"; cp "$ds/dist/tokens.css" "$ds/base.css" "$old_dir/"
cp "$ds_src/dist/tokens.css" "$ds/dist/tokens.css"
git -C "$ds" add -A && git -C "$ds" commit -qm "design system v2: darker personal accent contrast fix"

proj="$dir/project"
mkdir -p "$proj"
gitinit "$proj"

cat > "$proj/README.md" <<'EOF'
# planlens
CLI that summarises Terraform plans, plus a static HTML report viewer in `web/`.
EOF

if [ "$variant" = nobrief ]; then
  rm -rf "$old_dir"
  mkdir -p "$proj/web"
  printf '<!DOCTYPE html>\n<html lang="en">\n<head><meta charset="utf-8"><title>planlens</title></head>\n<body><h1>planlens report</h1></body>\n</html>\n' > "$proj/web/index.html"
  git -C "$proj" add -A && git -C "$proj" commit -qm "init"
  echo "$proj"; exit 0
fi

brand_line='**Theme:** tooling · **Status:** planned · **Version:** —'
[ "$variant" = update ] || [ "$variant" = gone ] && brand_line="**Theme:** tooling · **Status:** applied · **Version:** $old_sha"

mkdir -p "$proj/docs/portfolio"
cat > "$proj/docs/portfolio/brief.md" <<EOF
# planlens — Portfolio Brief

**Status:** active

## Pitch
A CLI that summarises Terraform plans for reviewers, with a static HTML report viewer.

## Showcases
Terraform plan internals, policy checks in CI, GitHub Actions.

## Tier
standard

## Brand
$brand_line

## Cost Sheet
| Resource | Purpose | Est. monthly cost | Covered by existing plan? | Teardown step | Teardown verification |
|---|---|---|---|---|---|
| Cloudflare Pages project \`planlens\` | Hosts the report viewer | \$0 | yes | Delete Pages project \`planlens\` | Project absent from Pages list |
| Azure storage account \`planlensstate\` | Terraform remote state | \$0.40 | no | Delete storage account \`planlensstate\` | Account absent from \`az storage account list\` |

**Total incremental:** \$0.40/month · **Threshold:** \$10/month (standard) · **Headroom:** \$9.60/month

## Milestones

### M1: CLI parses a plan and prints a summary — \`done\`
**Definition of done:**
- [x] \`planlens plan.json\` prints resource counts by action
**Understanding targets:**
- Terraform plan JSON structure

### M2: HTML report viewer — \`in progress\`
**Definition of done:**
- [ ] \`web/index.html\` renders a report from \`report.json\`
**Understanding targets:**
- Static hosting on Cloudflare Pages

### M3: Delivery — \`pending\`
**Definition of done:**
- [ ] README, recording, case study, retro complete; teardown verified (standard) or live URL verified (flagship)

## Checkpoint Log

### 2026-09-20 — M1
- **Done evidence:** commit \`abc1234\`; CLI tests pass
- **Understanding:** plan JSON structure → pass
- **Cost to date:** \$0.00
- **Adjustments:** none
EOF

mkdir -p "$proj/web"
cat > "$proj/web/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>planlens report</title>
</head>
<body>
<main>
  <h1>planlens report</h1>
  <table id="summary"><thead><tr><th>Action</th><th>Count</th></tr></thead><tbody></tbody></table>
</main>
</body>
</html>
EOF

if [ "$variant" = tailwind ]; then
  cat > "$proj/package.json" <<'EOF'
{ "name": "planlens-web", "private": true, "devDependencies": { "tailwindcss": "^3.4.0" } }
EOF
  cat > "$proj/tailwind.config.js" <<'EOF'
module.exports = { content: ['./web/**/*.html'], theme: { extend: { colors: { brand: '#7c3aed' } } } };
EOF
  mkdir -p "$proj/web/styles"
  cat > "$proj/web/styles/app.css" <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

.report-title { @apply text-3xl font-bold text-brand; }
EOF
  perl -pi -e 's#<title>planlens report</title>#<title>planlens report</title>\n<link rel="stylesheet" href="styles/app.css">#' "$proj/web/index.html"
fi

if [ "$variant" = update ] || [ "$variant" = gone ]; then
  mkdir -p "$proj/web/brand"
  cp "$old_dir/tokens.css" "$old_dir/base.css" "$proj/web/brand/"
  printf 'design-system %s\ntheme tooling\ndate 2026-09-01\n' "$old_sha" > "$proj/web/brand/VERSION"
  perl -pi -e 's#<html lang="en">#<html lang="en" data-theme="tooling">#; s#<title>planlens report</title>#<title>planlens report</title>\n<link rel="stylesheet" href="brand/tokens.css">\n<link rel="stylesheet" href="brand/base.css">#' "$proj/web/index.html"
fi
rm -rf "$old_dir"

# gone: the vendored version's commit no longer exists in the design system (e.g. squash-merged away).
if [ "$variant" = gone ]; then
  sed -i.bak "s/$old_sha/deadbee/" "$proj/web/brand/VERSION" "$proj/docs/portfolio/brief.md"
  rm "$proj/web/brand/VERSION.bak" "$proj/docs/portfolio/brief.md.bak"
fi
# dirty: the design system has uncommitted edits.
if [ "$variant" = dirty ]; then
  printf '\n/* wip: experimental tweak */\n.card { border-width: 3px; }\n' >> "$ds/base.css"
fi

git -C "$proj" add -A && git -C "$proj" commit -qm "init planlens"
echo "$proj"
