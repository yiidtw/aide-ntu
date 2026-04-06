#!/usr/bin/env bash
# pending-scan — call each course bot's `aide-skill <course> pending`, open GitHub issues for unlisted items
# usage: pending-scan [--dry-run]
# schedule: 0 9 * * * (daily 9am)
set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

INST_BASE="$HOME/.aide/instances"
MY_NAME="ntu.yiidtw"
TODAY=$(date +%Y-%m-%d)
TMPFILE=$(mktemp /tmp/pending-scan-XXXXXX.json)
trap "rm -f $TMPFILE" EXIT

echo "=== pending-scan $TODAY ==="
echo ""

declare_course_skill() {
  case "$1" in
    EE5122)  echo "formal2026" ;;
    EE5184)  echo "ml2026" ;;
    EEE5072) echo "rl2026" ;;
    EEE5023) echo "socv2026" ;;
    *)       echo "" ;;
  esac
}

check_and_open() {
  local json_file="$1" repo="$2" code="$3" dry_run="$4"
  python3 - "$json_file" "$repo" "$code" "$dry_run" << 'PYEOF'
import sys, json, subprocess
from datetime import date

json_file, repo, code, dry_run_str = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
dry_run = dry_run_str == "true"
today = date.today().isoformat()

with open(json_file) as f:
    data = json.load(f)
items = data.get("pending", [])

def issue_exists(repo, search_term):
    for state in ("open", "closed"):
        r = subprocess.run(
            ["gh", "issue", "list", "--repo", repo, "--state", state,
             "--search", search_term[:50], "--json", "title", "--jq", "length"],
            capture_output=True, text=True
        )
        if r.returncode == 0 and r.stdout.strip().isdigit() and int(r.stdout.strip()) > 0:
            return True
    return False

opened = 0
for item in items:
    name = item.get("name", "")
    due = item.get("due", "TBD")
    status = item.get("status", "—")
    source = item.get("source", "")
    if not name:
        continue
    due_suffix = f" (due {due[:10]})" if due and due not in ("TBD", "—", "") else ""
    title = f"[{code}] Pending: {name}{due_suffix}"
    if issue_exists(repo, name[:50]):
        print(f"  SKIP (issue exists): {name}")
        continue
    print(f"  PENDING: {title}")
    if not dry_run:
        skill_name = code.lower().replace("eee", "eee").replace("ee", "ee") + "2026"
        body = f"""Pending item detected by `ntu.yiidtw pending-scan` on {today}.

- **Item**: {name}
- **Due**: {due or 'TBD'}
- **Status**: {status}
- **Source**: `{source}` (from `aide-skill {skill_name} pending`)

cc: Auto-opened because no tracking issue was found."""
        r = subprocess.run(
            ["gh", "issue", "create", "--repo", repo,
             "--title", title, "--body", body, "--label", "pending-scan"],
            capture_output=True, text=True
        )
        if r.returncode == 0 and "https://github.com" in r.stdout:
            print(f"  ✓ Opened: {r.stdout.strip()}")
            opened += 1
        else:
            print(f"  ✗ Failed: {r.stderr.strip()}")
    else:
        print(f"  (dry-run) would open issue")
        opened += 1

if not items:
    print("  (no pending items)")
print(f"  → {opened} issues {'would be ' if dry_run else ''}opened")
PYEOF
}

for itoml in "$INST_BASE"/*/cognition/instance.toml; do
  idir=$(dirname "$(dirname "$itoml")")
  iname=$(basename "$idir")
  [[ "$iname" == "$MY_NAME" ]] && continue

  i_org=$(grep -E '^org\s*=' "$itoml" 2>/dev/null | sed 's/.*= *"\([^"]*\)".*/\1/' || true)
  [[ "$i_org" != "ntu" ]] && continue

  i_repo=$(grep -E '^github_repo\s*=' "$itoml" 2>/dev/null | sed 's/.*= *"\([^"]*\)".*/\1/' || true)
  [[ -z "$i_repo" ]] && continue

  sub_toml="$idir/cognition/subscriptions.toml"
  i_code=$(grep -oE 'course_code = "[^"]*"' "$sub_toml" 2>/dev/null | head -1 | sed 's/.*= *"\([^"]*\)".*/\1/' || true)
  [[ -z "$i_code" ]] && continue

  course_skill=$(declare_course_skill "$i_code")
  [[ -z "$course_skill" ]] && continue

  echo "── $iname ($i_code) → $i_repo ──"

  if AIDE_INSTANCE_DIR="$idir" aide-skill "$course_skill" pending > "$TMPFILE" 2>&1; then
    if python3 -c "import json; json.load(open('$TMPFILE'))" 2>/dev/null; then
      check_and_open "$TMPFILE" "$i_repo" "$i_code" "$DRY_RUN"
    else
      echo "  ✗ non-JSON output from $course_skill pending:"
      head -3 "$TMPFILE"
    fi
  else
    echo "  ✗ aide-skill $course_skill pending failed"
    head -3 "$TMPFILE"
  fi

  echo ""
done

$DRY_RUN && echo "(dry-run — no issues created)"
