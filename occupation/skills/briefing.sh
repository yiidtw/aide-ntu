#!/usr/bin/env bash
# briefing — daily executive summary for NTU courses + papers
# usage: briefing [EMAIL]
# env: RESEND_API_KEY, BRIEFING_TO
set -euo pipefail

TO="${1:-${BRIEFING_TO:?BRIEFING_TO not set}}"
RESEND="${RESEND_API_KEY:?RESEND_API_KEY not set}"
DATE=$(date '+%Y-%m-%d %A')

echo "Generating daily briefing for ${TO}..."

# ─── Gather raw data ───
COOL_ANNOUNCEMENTS=$(aide-skill cool announcements 2>&1) || COOL_ANNOUNCEMENTS=""
COOL_ASSIGNMENTS=$(aide-skill cool assignments 2>&1) || COOL_ASSIGNMENTS=""
COOL_SUBMISSIONS=$(aide-skill cool submissions 2>&1) || COOL_SUBMISSIONS=""
COOL_SCAN=$(aide-skill cool scan 2>&1) || COOL_SCAN=""
MAIL_RAW=$(aide-skill email unread 2>&1) || MAIL_RAW=""

# ─── Python formatter: produce actionable summary ───
export RAW_ANNOUNCEMENTS="$COOL_ANNOUNCEMENTS"
export RAW_ASSIGNMENTS="$COOL_ASSIGNMENTS"
export RAW_SUBMISSIONS="$COOL_SUBMISSIONS"
export RAW_SCAN="$COOL_SCAN"
export RAW_MAIL="$MAIL_RAW"
export BRIEFING_DATE="$DATE"

BODY=$(python3 << 'PYEOF'
import os, re
from datetime import datetime, timedelta

today = datetime.now()
date_str = os.environ.get("BRIEFING_DATE", "")
dow = today.weekday()  # 0=Mon

announcements = os.environ.get("RAW_ANNOUNCEMENTS", "")
assignments = os.environ.get("RAW_ASSIGNMENTS", "")
submissions = os.environ.get("RAW_SUBMISSIONS", "")
scan = os.environ.get("RAW_SCAN", "")
mail = os.environ.get("RAW_MAIL", "")

out = []
out.append(f"Daily Briefing — {date_str}")
out.append("")

# ══════════════════════════════════════════
# 1. ACTION ITEMS
# ══════════════════════════════════════════
out.append("⏰ ACTION ITEMS:")

actions = []

# EEE7004 心得: only flag if it's a 碩單 attendance week AND not a known absence
# Local overrides: assignments confirmed submitted outside COOL (e.g. paper copy)
local_submitted = {"3/23 心得或筆記"}  # 3/23 已紙本繳交

eee7004_known_skip_hw = {"3/2", "3/16"}  # 3/2 有事沒去, 3/16 碩雙免出席
eee7004_shuodan_hw = {"3/9", "3/23", "4/20", "5/4", "5/18"}  # 碩單要交心得的日期
eee7004_quanquan_hw = {"2/23", "6/1"}  # 碩全要交心得的日期
eee7004_must_submit = eee7004_shuodan_hw | eee7004_quanquan_hw

# Parse unsubmitted assignments from submissions output
course_ctx = ""
for line in submissions.split("\n"):
    line_s = line.strip()
    if line_s.startswith("📚"):
        course_ctx = re.sub(r"📚\s*", "", line_s).rstrip(":")
    if "unsubmitted" in line_s:
        m = re.search(r"❌\s*(.+?)\s+\[due:\s*([^\]]+)\]", line_s)
        if m:
            name, due = m.group(1).strip(), m.group(2).strip()
            prefix = f"[{course_ctx}] " if course_ctx else ""

            # Skip locally confirmed submissions (e.g. paper copy)
            if name in local_submitted:
                continue

            # Skip EEE7004 心得 that are known skips or non-碩單 weeks
            if "EEE7004" in course_ctx or "專題演講" in course_ctx:
                date_match = re.match(r"(\d+/\d+)", name)
                if date_match:
                    hw_date = date_match.group(1)
                    if hw_date in eee7004_known_skip_hw:
                        continue  # known absence, skip
                    if hw_date not in eee7004_must_submit:
                        continue  # not a 碩單 week, skip

            if due == "no due date":
                actions.append(f"  ❌ {prefix}{name} — 未交 (no deadline)")
            else:
                try:
                    due_dt = datetime.strptime(due[:10], "%Y-%m-%d")
                    days = (due_dt - today).days
                    if days < 0:
                        actions.append(f"  🚨 {prefix}{name} — OVERDUE by {-days} days!")
                    elif days <= 3:
                        actions.append(f"  🔴 {prefix}{name} — due {due[:10]} ({days}d left!)")
                    elif days <= 7:
                        actions.append(f"  🟡 {prefix}{name} — due {due[:10]} ({days}d)")
                    else:
                        actions.append(f"  📋 {prefix}{name} — due {due[:10]} ({days}d)")
                except:
                    actions.append(f"  ❌ {prefix}{name} — due {due}")

if not actions:
    actions.append("  ✅ Nothing overdue!")
for a in actions:
    out.append(a)
out.append("")

# ══════════════════════════════════════════
# 2. NEXT WEEK ATTENDANCE (EEE7004 碩單 + EEE7007)
# ══════════════════════════════════════════
out.append("🏫 ATTENDANCE:")

# EEE7004 碩單 attendance dates (博全碩單 or 博全碩全)
eee7004_attend = {
    "2026-02-23": ("博全碩全", "吳聲欣/陳良基", "BL-101+113"),
    "2026-03-02": ("博全碩全", "林子茗", "BL-101+113"),
    "2026-03-09": ("博全碩單", "何婕 (PicCollage)", "BL-113"),
    "2026-03-23": ("博全碩單", "林捷昇 (華晶科技)", "BL-113"),
    "2026-04-20": ("博全碩單", "姜慧如 (台積電)", "BL-113"),
    "2026-05-04": ("博全碩單", "TBD (群聯電子)", "BL-113"),
    "2026-05-18": ("博全碩單", "TBD (台灣美光)", "BL-113"),
    "2026-06-01": ("博全碩全", "鄭雲謙 (台大電機)", "BL-101+113"),
}
# EEE7004 skip dates (碩雙 or holiday)
eee7004_skip = {
    "2026-03-16": "碩雙週",
    "2026-03-30": "碩雙週",
    "2026-04-13": "期中考",
    "2026-04-27": "碩雙週",
    "2026-05-11": "碩雙週",
    "2026-05-25": "碩雙週",
    "2026-06-08": "期末考",
}

# EEE7007 schedule
eee7007_schedule = {
    "2026-03-30": ("TBC", "聯發科技"),
    "2026-04-20": ("Lydia Ni", "Synopsys"),
    "2026-04-27": ("TBD", "Siemens EDA"),
    "2026-05-04": ("Peter Feldmann", "Ansys"),
    "2026-05-11": ("Danny Jiang", "SiFive"),
    "2026-05-18": ("鄭武東", "Siemens EDA"),
    "2026-05-25": ("吳凱強", "交大資工所"),
    "2026-06-01": ("Shane Hsu", "Cadence"),
}
eee7007_skip = {"2026-04-06": "春假", "2026-04-13": "期中考", "2026-06-08": "期末考"}

# Find next Monday
days_until_mon = (0 - dow) % 7
if days_until_mon == 0 and today.hour >= 18:
    days_until_mon = 7
next_mon = today + timedelta(days=days_until_mon if days_until_mon > 0 else 7 if dow == 0 else days_until_mon)
next_mon_str = next_mon.strftime("%Y-%m-%d")

# Also check this Monday if today is Mon
this_mon = today if dow == 0 else today - timedelta(days=dow) + timedelta(days=7 if dow > 0 else 0)

for mon_label, mon_str in [("Next Monday" if days_until_mon > 0 else "Today", next_mon_str)]:
    pass

# Show next Monday info
out.append(f"  Next Monday ({next_mon_str}):")
if next_mon_str in eee7004_attend:
    grp, speaker, loc = eee7004_attend[next_mon_str]
    out.append(f"    ✅ EEE7004: {grp} — {speaker} @ {loc} → 要出席")
elif next_mon_str in eee7004_skip:
    reason = eee7004_skip[next_mon_str]
    out.append(f"    ⏭️  EEE7004: {reason} → 免出席")
else:
    out.append(f"    ❓ EEE7004: 未知週次，請確認")

if next_mon_str in eee7007_schedule:
    speaker, org = eee7007_schedule[next_mon_str]
    out.append(f"    ✅ EEE7007: {speaker} ({org}) @ 博理112 → 要出席")
elif next_mon_str in eee7007_skip:
    reason = eee7007_skip[next_mon_str]
    out.append(f"    ⏭️  EEE7007: {reason} → 免出席")
else:
    out.append(f"    ✅ EEE7007: EDA Seminar @ 博理112 → 要出席")
out.append("")

# ══════════════════════════════════════════
# 3. GRADES & SUBMISSIONS
# ══════════════════════════════════════════
out.append("📊 GRADES & SUBMISSIONS:")
graded = []
pending = []
for line in submissions.split("\n"):
    line = line.strip()
    if "graded" in line and "📊" not in line:
        m = re.search(r"[✅]\s*(.+?)\s+\[due:", line)
        if m:
            graded.append(f"  ✅ {m.group(1).strip()} — graded")
    elif "pending_review" in line:
        m = re.search(r"[⏳]\s*(.+?)\s+\[due:", line)
        if m:
            pending.append(f"  ⏳ {m.group(1).strip()} — pending review")
    elif "submitted" in line and "unsubmitted" not in line and "📋" not in line and "📚" not in line:
        m = re.search(r"[📤]\s*(.+?)\s+\[due:", line)
        if m:
            graded.append(f"  📤 {m.group(1).strip()} — submitted")

for g in graded:
    out.append(g)
for p in pending:
    out.append(p)
if not graded and not pending:
    out.append("  (no grade updates)")
out.append("")

# ══════════════════════════════════════════
# 4. ANNOUNCEMENTS (extract key info)
# ══════════════════════════════════════════
out.append("📢 COURSE ANNOUNCEMENTS:")
ann_lines = [l.strip() for l in announcements.split("\n") if l.strip() and not l.strip().startswith("📢")]
if ann_lines:
    for l in ann_lines:
        out.append(f"  {l}")
else:
    out.append("  (none)")
out.append("")

# ══════════════════════════════════════════
# 5. COOL SCAN DIFF
# ══════════════════════════════════════════
if "No changes" not in scan:
    out.append("🔄 COOL CHANGES:")
    out.append(f"  {scan.strip()}")
    out.append("")

# ══════════════════════════════════════════
# 6. PAPER / CONFERENCE MAIL
# ══════════════════════════════════════════
paper_keywords = ["spin", "easychair", "conference", "review", "submission", "camera-ready",
                   "artifact", "paper", "ieee", "acm", "accepted", "rejected", "rebuttal",
                   "springer", "lncs", "deadline", "proceedings", "nian-ze", "laura",
                   "hotcrp", "ase", "fmcad", "cav", "tacas", "atva", "vmcai",
                   "arxiv", "dblp", "doi", "journal"]
out.append("📬 PAPER / CONFERENCE:")
mail_lines = mail.split("\n")
paper_mail = []
other_mail = []
cool_count = 0
for line in mail_lines:
    ll = line.lower()
    if "ntu-cool@cool.ntu.edu.tw" in ll or "ntudigital@ntu.edu.tw" in ll:
        cool_count += 1
        continue
    if any(kw in ll for kw in paper_keywords):
        paper_mail.append(f"  {line.strip()}")
    elif line.strip() and not line.startswith("===") and "messages" not in ll:
        other_mail.append(line.strip())

if paper_mail:
    for p in paper_mail[:10]:
        out.append(p)
else:
    out.append("  (no paper-related mail)")
out.append("")

# ══════════════════════════════════════════
# 7. OTHER MAIL (non-COOL, non-paper)
# ══════════════════════════════════════════
out.append("📬 OTHER MAIL:")
if other_mail:
    for m in other_mail[:8]:
        out.append(f"  {m}")
else:
    out.append("  (none)")
out.append(f"  ({cool_count} COOL notification emails filtered)")
out.append("")

out.append("---")
out.append("Sent by ntu-student agent via aide.sh")

print("\n".join(out))
PYEOF
)

# ─── Send via Resend ───
export BRIEFING_BODY="$BODY"
export BRIEFING_TO_ADDR="$TO"

PAYLOAD=$(python3 << 'PYEOF'
import json, os
body = os.environ.get("BRIEFING_BODY", "")
to = os.environ.get("BRIEFING_TO_ADDR", "")
date = os.environ.get("BRIEFING_DATE", "")
print(json.dumps({
    "from": "ntu-student <yiidtw.ntu@aide.sh>",
    "to": [to],
    "subject": f"Daily Briefing \u2014 {date}",
    "text": body
}))
PYEOF
)

RESPONSE=$(curl -s -X POST https://api.resend.com/emails \
  -H "Authorization: Bearer $RESEND" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" 2>&1)

if echo "$RESPONSE" | grep -q '"id"'; then
  echo "Briefing sent to ${TO} from yiidtw.ntu@aide.sh"
else
  echo "Failed to send: ${RESPONSE}"
  exit 1
fi
