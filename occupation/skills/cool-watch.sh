#!/usr/bin/env bash
# cool-watch — detect COOL changes and open GitHub issues in course repos
# usage: cool-watch [--dry-run]
# env: none (uses gh CLI, aide-skill cool)
# schedule: every 4 hours via cron
set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

export INST_DIR="${AIDE_INSTANCE_DIR:-$HOME/.aide/instances/ntu.yiidtw}"
SCAN_DB="$HOME/claude_projects/NTUGIEE/2026Spring/cool_scan.db"
STATE_FILE="$INST_DIR/cognition/cool-watch-state.json"
REGISTRY_FILE="$INST_DIR/cognition/registry.toml"

# Course → repo mapping is now read from registry.toml (no more hardcoding)
if [[ ! -f "$REGISTRY_FILE" ]]; then
  echo "ERROR: registry.toml not found at $REGISTRY_FILE"
  echo "No subscribers registered. Nothing to do."
  exit 0
fi

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
export PREV_STATE ANNOUNCEMENTS SUBMISSIONS SCAN_DB REGISTRY_FILE
$DRY_RUN && export DRY_RUN="true" || export DRY_RUN="false"

NEW_STATE=$(python3 << 'PYEOF'
import json, os, subprocess, sqlite3, sys, re as _re
from datetime import datetime

dry_run = "--dry-run" in sys.argv or os.environ.get("DRY_RUN") == "true"

OUTBOX_FILE = os.environ.get("INST_DIR", os.environ.get("AIDE_INSTANCE_DIR", "")) + "/cognition/outbox.json"

def load_outbox():
    if os.path.exists(OUTBOX_FILE):
        with open(OUTBOX_FILE) as f:
            return json.load(f)
    return {"pending": []}

def save_outbox(outbox):
    os.makedirs(os.path.dirname(OUTBOX_FILE), exist_ok=True)
    with open(OUTBOX_FILE, "w") as f:
        json.dump(outbox, f, indent=2)

def open_issue(repo, title, body, label="cool-watch"):
    """SYN: Open a GitHub issue and track in outbox for ack verification.
    Deduplicates by checking if an open issue with the same title already exists."""
    # Dedup: check if issue with same title already exists
    dup_check = subprocess.run(
        ["gh", "issue", "list", "--repo", repo, "--search", title, "--state", "open", "--json", "title", "--jq", "length"],
        capture_output=True, text=True
    )
    if dup_check.returncode == 0 and dup_check.stdout.strip().isdigit() and int(dup_check.stdout.strip()) > 0:
        print(f"  ⚠ DEDUP: issue already exists on {repo}: {title}")
        return False
    r = subprocess.run(
        ["gh", "issue", "create", "--repo", repo, "--title", title, "--body", body, "--label", label],
        capture_output=True, text=True
    )
    if r.returncode == 0:
        issue_url = r.stdout.strip()
        print(f"  ✓ SYN: issue opened: {issue_url}")
        # Extract issue number from URL: https://github.com/owner/repo/issues/N
        issue_num = issue_url.rstrip("/").split("/")[-1] if "/" in issue_url else ""
        # Save to outbox for ack tracking
        outbox = load_outbox()
        outbox["pending"].append({
            "repo": repo,
            "issue_number": issue_num,
            "issue_url": issue_url,
            "title": title,
            "sent_at": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
            "status": "syn"
        })
        save_outbox(outbox)
        return True
    else:
        print(f"  ✗ SYN failed: {r.stderr.strip()}")
        return False

def check_acks():
    """ACK-ACK: Check outbox for pending SYNs, verify receiver acked (👀 reaction or comment)."""
    outbox = load_outbox()
    if not outbox["pending"]:
        return
    print(f"\n── Handshake: checking {len(outbox['pending'])} pending acks ──")
    still_pending = []
    completed = []
    for item in outbox["pending"]:
        repo = item["repo"]
        num = item.get("issue_number", "")
        if not num:
            still_pending.append(item)
            continue
        # Check for 👀 reaction
        r = subprocess.run(
            ["gh", "api", f"repos/{repo}/issues/{num}/reactions", "--jq", '.[].content'],
            capture_output=True, text=True
        )
        reactions = r.stdout.strip().split("\n") if r.returncode == 0 and r.stdout.strip() else []
        # Check for any comment (receiver ack)
        c = subprocess.run(
            ["gh", "api", f"repos/{repo}/issues/{num}/comments", "--jq", 'length'],
            capture_output=True, text=True
        )
        comment_count = int(c.stdout.strip()) if c.returncode == 0 and c.stdout.strip().isdigit() else 0
        has_eyes = "eyes" in reactions
        has_comment = comment_count > 0
        if has_eyes or has_comment:
            item["status"] = "acked"
            item["acked_at"] = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
            print(f"  ✓ ACK-ACK: {repo}#{num} — {'👀' if has_eyes else ''} {'💬' if has_comment else ''}")
            completed.append(item)
        else:
            sent = datetime.strptime(item["sent_at"], "%Y-%m-%dT%H:%M:%SZ")
            age_h = (datetime.utcnow() - sent).total_seconds() / 3600
            if age_h > 24:
                item["status"] = "timeout"
                print(f"  ✗ TIMEOUT: {repo}#{num} — no ack after {age_h:.0f}h")
                completed.append(item)
            else:
                print(f"  ⏳ PENDING: {repo}#{num} — waiting ({age_h:.1f}h)")
                still_pending.append(item)
    # Update outbox
    outbox["pending"] = still_pending
    history = outbox.get("history", [])
    history.extend(completed)
    outbox["history"] = history[-50:]  # keep last 50
    save_outbox(outbox)
    print(f"  ── pending={len(still_pending)} resolved={len(completed)}")

prev = json.loads(os.environ.get("PREV_STATE", "{}"))
prev_ann_ids = set(prev.get("announcement_ids", []))
prev_assign_ids = set(prev.get("assignment_ids", []))
prev_file_checksums = prev.get("file_checksums", {})

announcements = os.environ.get("ANNOUNCEMENTS", "")
submissions = os.environ.get("SUBMISSIONS", "")
scan_db = os.environ.get("SCAN_DB", "")

# ─── Org-native discovery: scan instances where org matches ours ───
import glob as _glob

inst_base = os.path.expanduser("~/.aide/instances")
my_org = None
inst_dir = os.environ.get("INST_DIR", os.environ.get("AIDE_INSTANCE_DIR", ""))

# Read our own org
if inst_dir:
    my_toml = os.path.join(inst_dir, "cognition/instance.toml")
    if os.path.exists(my_toml):
        for line in open(my_toml):
            m = _re.match(r'^org\s*=\s*"(.+)"', line.strip())
            if m:
                my_org = m.group(1)
                break

course_repo = {}     # course_code → callback GitHub repo
course_cool_id = {}  # course_code → COOL course ID

if my_org:
    # Scan all instances in the same org
    for itoml in _glob.glob(os.path.join(inst_base, "*/cognition/instance.toml")):
        idir = os.path.dirname(os.path.dirname(itoml))
        iname = os.path.basename(idir)
        # Read instance.toml for org + github_repo
        i_org = None
        i_repo = None
        for line in open(itoml):
            line = line.strip()
            m = _re.match(r'^org\s*=\s*"(.+)"', line)
            if m: i_org = m.group(1)
            m = _re.match(r'^github_repo\s*=\s*"(.+)"', line)
            if m: i_repo = m.group(1)
        if i_org != my_org or iname == os.path.basename(inst_dir):
            continue  # different org or self
        if not i_repo:
            continue
        # Read subscriptions.toml for cool_id + course_code
        sub_toml = os.path.join(idir, "cognition/subscriptions.toml")
        if os.path.exists(sub_toml):
            for line in open(sub_toml):
                line = line.strip()
                if "cool_id" in line and "course_code" in line:
                    m_id = _re.search(r'cool_id\s*=\s*(\d+)', line)
                    m_code = _re.search(r'course_code\s*=\s*"(\w+)"', line)
                    if m_id and m_code:
                        code = m_code.group(1)
                        course_repo[code] = i_repo
                        course_cool_id[code] = int(m_id.group(1))
    print(f"Org '{my_org}': {len(course_repo)} members discovered")
    for code, repo in course_repo.items():
        print(f"  {code} (cool_id={course_cool_id.get(code, '?')}) → {repo}")
else:
    # Fallback: try registry.toml
    registry_file = os.environ.get("REGISTRY_FILE", "")
    if registry_file and os.path.exists(registry_file):
        current = {}
        with open(registry_file) as f:
            for line in f:
                line = line.strip()
                if line == "[[subscribers]]":
                    if current.get("course_code") and current.get("callback"):
                        course_repo[current["course_code"]] = current["callback"]
                        if current.get("cool_id"):
                            course_cool_id[current["course_code"]] = current["cool_id"]
                    current = {}
                elif "=" in line and not line.startswith("#"):
                    key, val = line.split("=", 1)
                    key = key.strip()
                    val = val.strip().strip('"')
                    if key == "callback": current["callback"] = val
                    elif key == "filter":
                        m = _re.search(r'cool_id\s*=\s*(\d+)', val)
                        if m: current["cool_id"] = int(m.group(1))
                        m = _re.search(r'course_code\s*=\s*"(\w+)"', val)
                        if m: current["course_code"] = m.group(1)
            if current.get("course_code") and current.get("callback"):
                course_repo[current["course_code"]] = current["callback"]
                if current.get("cool_id"):
                    course_cool_id[current["course_code"]] = current["cool_id"]
        print(f"Registry fallback: {len(course_repo)} subscribers loaded")
    else:
        print("WARNING: no org set and no registry.toml found")

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
                        if open_issue(repo, title, body):
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
                        if open_issue(repo, title, body):
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
            if open_issue(repo, title, body):
                issues_created += 1

# ─── 4. Check acks on previously sent issues ───
check_acks()

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
