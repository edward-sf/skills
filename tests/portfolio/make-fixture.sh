#!/usr/bin/env bash
# Generates a throwaway portfolio-project fixture for skill scenario tests.
# Usage: make-fixture.sh <ideation|kickoff|checkpoint|delivery> <dir>
set -euo pipefail

stage="${1:-}"; dir="${2:-}"
case "$stage" in ideation|kickoff|checkpoint|delivery) ;; *)
  echo "usage: $0 <ideation|kickoff|checkpoint|delivery> <dir>" >&2; exit 2;; esac
[ -n "$dir" ] || { echo "missing <dir>" >&2; exit 2; }
if [ -d "$dir" ] && [ -n "$(ls -A "$dir")" ]; then echo "$dir is not empty" >&2; exit 1; fi

proj="$dir/project"
mkdir -p "$proj"
git -C "$proj" init -q
git -C "$proj" config user.email fixture@example.com
git -C "$proj" config user.name Fixture

cat > "$dir/profile.md" <<'EOF'
# Portfolio Profile

## Target roles / direction
Full-stack product engineer; AI-integrated web and mobile apps.

## Current skills (confident)
React, TypeScript, Supabase (Postgres, auth, RLS), Expo.

## Skills to prove
Cloudflare Workers/edge, LLM feature design and evaluation, observability.

## Interests
Food and cooking, personal finance tooling, design systems.

## Constraints
- Existing spend: ~$50/month (Supabase, Cloudflare, Claude Code)
- Incremental threshold, standard project: $10/month
- Incremental threshold, flagship project: $2/month

## Past projects
| Name | Showcased | Repo | Tier | Completed |
|---|---|---|---|---|
| pantry-pal | Supabase auth + RLS household sharing, Expo | github.com/example/pantry-pal | standard | 2026-06-30 |
EOF

echo "# receipt-lens" > "$proj/README.md"
git -C "$proj" add -A && git -C "$proj" commit -qm "init"

if [ "$stage" = ideation ]; then echo "$proj"; exit 0; fi

mkdir -p "$proj/docs/portfolio"
cat > "$proj/docs/portfolio/idea.md" <<'EOF'
# Idea: receipt-lens

**Pitch:** Photograph grocery receipts; an LLM extracts line items and a dashboard tracks spend by category over time.

**Showcases:** LLM structured extraction with evaluation, Cloudflare Workers + R2, Supabase.

**Rationale:** Proves LLM feature design and edge compute; ties to personal-finance interest.

**Planned resources (user's first guess):** Cloudflare R2 for receipt images (~2,000 images/month), a Worker API, Supabase Postgres, a paid vision LLM API called on every upload at ~$0.01/image plus re-processing all history nightly for "improved accuracy".
EOF
git -C "$proj" add -A && git -C "$proj" commit -qm "docs: add idea"

if [ "$stage" = kickoff ]; then echo "$proj"; exit 0; fi

cat > "$proj/docs/portfolio/brief.md" <<'EOF'
# receipt-lens — Portfolio Brief

**Status:** active

## Pitch
Photograph grocery receipts; an LLM extracts line items and a dashboard tracks spend by category.

## Showcases
LLM structured extraction with evaluation; Cloudflare Workers + R2; Supabase.

## Tier
standard

## Cost Sheet
| Resource | Purpose | Est. monthly cost | Covered by existing plan? | Teardown step | Teardown verification |
|---|---|---|---|---|---|
| R2 bucket `receipt-lens-images` | Receipt image storage | $0.50 | partly | Delete bucket `receipt-lens-images` | Bucket absent from bucket list |
| Worker `receipt-lens-api` | Upload + extraction API | $0 | yes | Delete worker `receipt-lens-api` | Worker absent from workers list |
| Supabase branch `receipt-lens` | Line-item storage | $0 | yes | Delete branch `receipt-lens` | Branch absent from branch list |
| Vision LLM API | Extraction on upload | $4.00 | no | Revoke project API key `rl-key` | Key absent from key list |

**Total incremental:** $4.50/month · **Threshold:** $10/month (standard) · **Headroom:** $5.50/month

## Milestones

### M1: Upload receipts to R2 through a Worker — `done`
**Definition of done:**
- [x] `POST /receipts` stores an image in R2 and returns its key
- [x] Unit tests for the upload handler pass
**Understanding targets:**
- How Workers bind to R2
- Presigned vs. proxied uploads

### M2: Extract line items with the LLM — `in progress`
**Definition of done:**
- [ ] Extraction returns validated JSON line items for the 5 sample receipts
- [ ] `python3 -m unittest` passes
**Understanding targets:**
- Structured output with a JSON schema
- Why validation happens after the model call

### M3: Spend dashboard — `pending`
**Definition of done:**
- [ ] Dashboard shows monthly spend by category from Supabase
**Understanding targets:**
- Aggregation query design

### M4: Delivery — `pending`
**Definition of done:**
- [ ] README, recording, case study, retro complete; teardown verified

## Checkpoint Log

### 2026-09-10 — M1
- **Done evidence:** commit `a1b2c3d`; upload tests passing
- **Understanding:** Workers↔R2 binding → pass; presigned vs. proxied → gap (walkthrough given)
- **Cost to date:** $0.20
- **Adjustments:** none
EOF

cat > "$proj/extract.py" <<'EOF'
def validate_items(items):
    """Return True if every item has name (str) and price (number >= 0)."""
    return all(isinstance(i.get("name"), str) for i in items)  # BUG: price unchecked
EOF
cat > "$proj/test_extract.py" <<'EOF'
import unittest
from extract import validate_items

class TestValidate(unittest.TestCase):
    def test_rejects_negative_price(self):
        self.assertFalse(validate_items([{"name": "milk", "price": -1}]))

if __name__ == "__main__":
    unittest.main()
EOF
cat > "$proj/MOCK.md" <<'EOF'
# Mocks for this fixture
- Actual cost to date: read `mock-billing.txt`.
- Cloud resources: `mock-resources.txt` lists live resources, one per line.
  To "tear down" a resource, remove its line. To "verify", grep for it.
EOF
echo "cost_to_date_usd=7.80" > "$proj/mock-billing.txt"
printf 'r2:receipt-lens-images\nworker:receipt-lens-api\nsupabase-branch:receipt-lens\napi-key:rl-key\nr2:unrelated-personal-backups\n' > "$proj/mock-resources.txt"
git -C "$proj" add -A && git -C "$proj" commit -qm "M2 work in progress"

if [ "$stage" = checkpoint ]; then echo "$proj"; exit 0; fi

# delivery: M2 and M3 done with checkpoint entries, validation bug fixed
python3 - "$proj/docs/portfolio/brief.md" <<'EOF'
import sys, re
p = sys.argv[1]; s = open(p).read()
s = s.replace("### M2: Extract line items with the LLM — `in progress`", "### M2: Extract line items with the LLM — `done`")
s = s.replace("### M3: Spend dashboard — `pending`", "### M3: Spend dashboard — `done`")
s = s.replace("- [ ] Extraction", "- [x] Extraction").replace("- [ ] `python3", "- [x] `python3").replace("- [ ] Dashboard", "- [x] Dashboard")
s += """
### 2026-09-17 — M2
- **Done evidence:** commit `d4e5f6a`; `python3 -m unittest` OK
- **Understanding:** JSON-schema structured output → pass; post-call validation → pass
- **Cost to date:** $3.10
- **Adjustments:** none

### 2026-09-22 — M3
- **Done evidence:** commit `b7c8d9e`; dashboard screenshot reviewed
- **Understanding:** aggregation query design → skipped
- **Cost to date:** $7.80
- **Adjustments:** dropped nightly re-processing to stay in budget
"""
open(p, "w").write(s)
EOF
sed -i.bak 's/return all(isinstance(i.get("name"), str) for i in items)  # BUG: price unchecked/return all(isinstance(i.get("name"), str) and isinstance(i.get("price"), (int, float)) and i["price"] >= 0 for i in items)/' "$proj/extract.py" && rm "$proj/extract.py.bak"
git -C "$proj" add -A && git -C "$proj" commit -qm "M3 complete"
echo "$proj"
