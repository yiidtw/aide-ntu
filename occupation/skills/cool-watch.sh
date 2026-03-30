#!/usr/bin/env bash
# cool-watch — detect COOL changes and open GitHub issues in course repos
# usage: cool-watch [--dry-run]
# env: none (uses gh CLI, aide-skill cool)
# schedule: every 4 hours via cron
set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

SCAN_DB="$HOME/claude_projects/NTUGIEE/2026Spring/cool_scan.db"
STATE_FILE="$HOME/.aide/instances/ntu.yiidtw/cognition/cool-watch-state.json"

# Course → GitHub repo mapping is in the Python section below
# EE5184 → yiidtw/ee5184-ml-2026-note
# EE5122 → yiidtw/ee5122-formal-2026-note
# EEE5023 → yiidtw/eee5023-socv-2026-note
# EEE5072 → yiidtw/ee5072-rl-note

# ─── Load previous state ───
if [[ -f "$STATE_FILE" ]]; then
  PREV_STATE=$(cat "$STATE_FILE")
else
  PREV_STATE="{}"
fi

# ─── Run COOL scan to detect changes ───
echo "Running COOL scan..."
SCAN_OUT=$(aide-skill cool scan 2>&1)
echo "$SCAN_OUT"

# ─── Get current announcements ───
echo ""
echo "Checking announcements..."
ANNOUNCEMENTS=$(aide-skill cool announcements 20 2>&1)

# ─── Get current assignments with submissions ───
echo ""
echo "Checking submissions..."
SUBMISSIONS=$(aide-skill cool submissions 2>&1)

# ─── Python: diff against previous state, create issues ───
export PREV_STATE ANNOUNCEMENTS SUBMISSIONS SCAN_DB
$DRY_RUN && export DRY_RUN="true" || export DRY_RUN="false"

NEW_STATE=$(python3 << 'PYEOF'
import json, os, subprocess, sqlite3, sys
from datetime import datetime

dry_run = "--dry-run" in sys.argv or os.environ.get("DRY_RUN") == "true"

prev = json.loads(os.environ.get("PREV_STATE", "{}"))
prev_ann_ids = set(prev.get("announcement_ids", []))
prev_assign_ids = set(prev.get("assignment_ids", []))
prev_file_checksums = prev.get("file_checksums", {})

announcements = os.environ.get("ANNOUNCEMENTS", "")
submissions = os.environ.get("SUBMISSIONS", "")
scan_db = os.environ.get("SCAN_DB", "")

course_repo = {
    "EE5184": "yiidtw/ee5184-ml-2026-note",
    "EE5122": "yiidtw/ee5122-formal-2026-note",
    "EEE5023": "yiidtw/eee5023-socv-2026-note",
    "EEE5072": "yiidtw/ee5072-rl-note",
}

course_cool_id = {
    "EE5184": 59878,
    "EE5122": 57171,
    "EEE5023": 61236,
    "EEE5072": 60106,
}

# Reverse: cool_id → course_code
id_to_code = {v: k for k, v in course_cool_id.items()}

new_state = {"announcement_ids": [], "assignment_ids": [], "file_checksums": {}}
issues_created = 0

# ─── 1. Parse announcements, detect new ones ───
# Format: "  [DATE] TITLE\n    ← COURSE_NAME (CODE)"
ann_blocks = []
lines = announcements.strip().split("\n")
i = 0
while i < len(lines):
    line = lines[i].strip()
    if line.startswith("[2026-") or line.startswith("[202"):
        # Extract date and title
        import re
        m = re.match(r"\[(\d{4}-\d{2}-\d{2})\]\s*(.*)", line)
        if m:
            date, title = m.group(1), m.group(2)
            course = ""
            code = ""
            if i + 1 < len(lines) and "←" in lines[i + 1]:
                course_line = lines[i + 1].strip().lstrip("← ").strip()
                # Extract code from "機器學習 (EE5184)"
                cm = re.search(r"\((\w+)\)", course_line)
                if cm:
                    code = cm.group(1)
                course = course_line
            ann_id = f"{date}:{title}"
            ann_blocks.append({"date": date, "title": title, "course": course, "code": code, "id": ann_id})
            new_state["announcement_ids"].append(ann_id)
    i += 1

# ─── 2. Check scan DB for new assignments and files ───
if os.path.exists(scan_db):
    db = sqlite3.connect(scan_db)
    cur = db.cursor()

    # Get latest 2 scans
    cur.execute("SELECT id FROM scans ORDER BY id DESC LIMIT 2")
    scan_ids = [r[0] for r in cur.fetchall()]

    if len(scan_ids) >= 2:
        latest, previous = scan_ids[0], scan_ids[1]

        # New assignments
        cur.execute("""
            SELECT a.course_id, a.assignment_id, a.name, a.due_at, a.workflow_state
            FROM assignment_snapshots a
            WHERE a.scan_id = ? AND a.assignment_id NOT IN (
                SELECT assignment_id FROM assignment_snapshots WHERE scan_id = ?
            )
        """, (latest, previous))
        new_assignments = cur.fetchall()

        for course_id, assign_id, name, due, state in new_assignments:
            code = id_to_code.get(course_id, "")
            if code and code in course_repo:
                assign_key = f"{code}:{assign_id}"
                new_state["assignment_ids"].append(assign_key)
                if assign_key not in prev_assign_ids:
                    repo = course_repo[code]
                    due_str = f" (due: {due[:10]})" if due else ""
                    title = f"[COOL] 新作業: {name}{due_str}"
                    body = f"COOL 出現新作業。\n\n- **名稱**: {name}\n- **截止日**: {due or 'TBD'}\n- **來源**: NTU COOL auto-detected by cool-watch"
                    print(f"NEW ASSIGNMENT: [{code}] {name}{due_str} → {repo}")
                    if not dry_run:
                        subprocess.run(["gh", "issue", "create", "--repo", repo,
                                        "--title", title, "--body", body,
                                        "--label", "cool-watch"], capture_output=True)
                        issues_created += 1

        # New files
        cur.execute("""
            SELECT f.course_id, f.file_id, f.name, f.size, f.content_type
            FROM file_snapshots f
            WHERE f.scan_id = ? AND f.file_id NOT IN (
                SELECT file_id FROM file_snapshots WHERE scan_id = ?
            )
        """, (latest, previous))
        new_files = cur.fetchall()

        for course_id, file_id, fname, size, ctype in new_files:
            code = id_to_code.get(course_id, "")
            if code and code in course_repo:
                fkey = f"{code}:{file_id}"
                new_state["file_checksums"][fkey] = f"{size}"
                if fkey not in prev_file_checksums:
                    repo = course_repo[code]
                    size_kb = (size or 0) // 1024
                    title = f"[COOL] 新檔案: {fname}"
                    body = f"COOL 上傳新檔案。\n\n- **檔案**: {fname}\n- **大小**: {size_kb} KB\n- **類型**: {ctype or 'unknown'}\n- **來源**: NTU COOL auto-detected by cool-watch"
                    print(f"NEW FILE: [{code}] {fname} ({size_kb} KB) → {repo}")
                    if not dry_run:
                        subprocess.run(["gh", "issue", "create", "--repo", repo,
                                        "--title", title, "--body", body,
                                        "--label", "cool-watch"], capture_output=True)
                        issues_created += 1

        # Grade changes
        cur.execute("""
            SELECT a.course_id, a.assignment_id, a.name, a.score, a.grade, a.workflow_state
            FROM assignment_snapshots a
            WHERE a.scan_id = ? AND a.workflow_state = 'graded'
            AND a.assignment_id IN (
                SELECT assignment_id FROM assignment_snapshots
                WHERE scan_id = ? AND workflow_state != 'graded'
            )
        """, (latest, previous))
        newly_graded = cur.fetchall()

        for course_id, assign_id, name, score, grade, state in newly_graded:
            code = id_to_code.get(course_id, "")
            if code and code in course_repo:
                repo = course_repo[code]
                score_str = f" (score: {score})" if score else ""
                title = f"[COOL] 成績公佈: {name}{score_str}"
                body = f"成績已公佈。\n\n- **作業**: {name}\n- **分數**: {score or 'N/A'}\n- **等第**: {grade or 'N/A'}\n- **來源**: NTU COOL auto-detected by cool-watch"
                print(f"GRADED: [{code}] {name}{score_str} → {repo}")
                if not dry_run:
                    subprocess.run(["gh", "issue", "create", "--repo", repo,
                                    "--title", title, "--body", body,
                                    "--label", "cool-watch"], capture_output=True)
                    issues_created += 1

    db.close()

# ─── 3. New announcements → issues ───
for ann in ann_blocks:
    code = ann["code"]
    if code in course_repo and ann["id"] not in prev_ann_ids:
        repo = course_repo[code]
        title = f"[COOL] {ann['title']}"
        body = f"COOL 公告 ({ann['date']})。\n\n- **課程**: {ann['course']}\n- **標題**: {ann['title']}\n- **日期**: {ann['date']}\n- **來源**: NTU COOL auto-detected by cool-watch"
        print(f"NEW ANNOUNCEMENT: [{code}] {ann['title']} ({ann['date']}) → {repo}")
        if not dry_run:
            subprocess.run(["gh", "issue", "create", "--repo", repo,
                            "--title", title, "--body", body,
                            "--label", "cool-watch"], capture_output=True)
            issues_created += 1

# ─── Save state ───
import json as j
print(j.dumps(new_state))
PYEOF
)

# ─── Save new state (last line of python output is JSON) ───
LAST_LINE=$(echo "$NEW_STATE" | tail -1)
if echo "$LAST_LINE" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
  mkdir -p "$(dirname "$STATE_FILE")"
  echo "$LAST_LINE" > "$STATE_FILE"
  echo ""
  echo "State saved to $STATE_FILE"
fi

# Print everything except the JSON state line (macOS compat: no head -n -1)
echo "$NEW_STATE" | sed '$d'

if $DRY_RUN; then
  echo ""
  echo "(dry-run mode — no issues created)"
fi
