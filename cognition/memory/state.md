# NTU Router State
Last synced: 2026-04-03

## Course Status
## Member Memories — 2026-04-03

### EEE5023 (eee5023-socv.ydwu)
### ln_rubric_and_lessons.md
# LN Grading Rubric & Lesson Learned

## LN#1 Grading Criteria（LN#2+ 沿用）

| 分數 | 等級 | 標準 |
|------|------|------|
| 95-100 | 頂尖 | 完整深入 + 明顯 insight + 高品質延伸 |
| 90-94 | 優秀 | 完整清楚 + 有 insight 或部分延伸 |
| 85-89 | 良好 | 正確完整，有基本解釋與結構 |
| 80-84 | 基本完成 | 皆答，正確但簡略 |
| 75-79 | 偏弱 | 有回答但過於簡短或缺乏說明 |
| <70 | 不足 | 缺答、錯誤多或與題目無關 |

全班平均：86.5

## 關鍵操作規則（每次寫 LN 前必做）

1. **展開 Notion 所有 toggle** — [LN] 問題和隱藏 task 都藏在 toggle 裡
2. **先找 rubric** — Notion Admin Info 頁面有評分標準，先看再寫
3. **逐題回答每一個 [LN] 小題** — 不能用摘要帶過，每個子題都要明確回答
4. **檢查有沒有實作 task** — [LN] 問題裡可能藏有 Verilog 實作要求（例如 vending machine）
5. **繳交平台** — 主要 HackMD，備份 Notion，不在 COOL 上交

## 已知的 [LN] 問題

- **Ch01 Week 1**: [LN] Common Knowledges about IC Designs (3 小題) + [LN] HW vs. SW Designs (2 小題) = 共 5 小題
- **Ch01 Week 3**: [LN] How to verify the correctness of your (RTL) design? — 含 vending machine RTL 實作 task
- **Ch02 Week 4-5**: (LN) Writing assertions to your RTL design — 為 vending machine 加 assertions
- **Ch04 Week 5-6**: [LN] Exploring BDD constructions with different variable orders — 在 GV 用 BSETOrder -DFS/-RDFS，對 adder/multiplier/comparator 比較 BDD 大小，總結 heuristics
- **Ch04 Week 6**: [LN] Playing with different DDs — 探索 FDD/BMD/ZDD node 數量，比較 arithmetic circuits
- **Ch05 Week 6-7**: [LN] Implement BDD-Based Assertion Checking in GV — 實作 PCHECK/PIMAGE/PINIT/PTRANS 四指令
- **Ch05 Week 7**: [LN] Verify Vending Machine Design by BDD-Based Assertion Checker — 用 BDD checker 驗 vending machine（注意 memory explosion）

## Notion 頁面 URL（已確認）

- Ch04: https://ric2k1.notion.site/04-Advanced-BDD-Techniques-3260e6ef618280b18dfef7f40da39de6
- Ch05: https://ric2k1.notion.site/05-BDD-Based-Verification-32c0e6ef6182809aba26ea0d62dc8812
- 讀 Notion：用 playwright chrome-devtools evaluate_script，toggle 要用 JS click 展開

## CRITICAL: LN1 拿 60 分的原因（全班倒數）

1. **沒有逐題回答 [LN] 問題** — 寫了一篇摘要帶過，沒有對應到每個子題
2. **沒有展開 Notion toggle** — 漏看了 vending machine RTL 實作 task
3. **沒有先看 rubric** — 不知道評分標準就開始寫
4. 浪費時間在 HackMD encoding 問題，而不是用 Notion API（更簡單）

**每次寫 LN，必須先完成：(1) 展開所有 Notion toggle → (2) 列出所有 [LN] 子題 → (3) 查 rubric → (4) 才開始寫內容**


### course_tracking.md
# SoCV Course Tracking

## Grading Method
- SoCV 成績不走 COOL assignment 系統，也不走 COOL 公告文字
- TA 把成績公告在 COOL **檔案** 區，以 PDF 上傳（例如 "SoCV 114-2 Student Scores.pdf"）
- Admin Info Notion 頁面 (https://ric2k1.notion.site/Admin-Info-3180e6ef618280ae9094c1924ac20c85) 會說明成績已公告
- 用 `aide-skill cool scan` + `aide-skill cool download <file_id> <path>` 下載查閱
- COOL file_id for scores PDF: 9511895 (SoCV 114-2 Student Scores.pdf, updated 2026-04-01)

## Submission Method
- **不在 COOL 上交作業**
- 主要繳交方式：HackMD learning note
  - URL: https://hackmd.io/8mIYVaHbTHaH_QA94VU9fQ
- 備份：Notion
  - URL: https://www.notion.so/SoCV-2026-32dab7a51e8a80e7825eca5d1ff0bcf7
- 繳交 deadline: **單數週上課前** 更新線上筆記

## Submission Schedule (114-2)
- Week 1 (2/24): 無
- Week 3 (3/10): LN due ← graded
- Week 5 (3/24): LN due ← graded
- Week 7 (4/7): LN due ← next deadline
- Week 9 (4/21): LN due
- Week 11 (5/5): LN due
- Week 13 (5/19): LN due
- Week 15 (6/2): LN due
- Week 17 (6/16): LN due (if applicable)

## Current Status
- Week 3 LN (LN#1): submitted, graded — **60/100**（全班倒數，全班平均 86.5）
- Week 5 LN (LN#2): submitted, graded — **80/100**
- Week 7 LN (LN#3): ✅ submitted 2026-04-01 23:34 UTC to HackMD — Ch04+Ch05 內容已寫入。Pending grade.

## How to Check
1. 成績: `aide-skill cool scan` 找新 PDF → `aide-skill cool download <file_id> /tmp/scores.pdf` → 讀 PDF
2. 繳交狀態: aide-skill hackmd status <url> <deadline>
3. 課程內容: aide-skill notion read (課程 Notion: https://ric2k1.notion.site/114-2-SoCV-3080e6ef618280309c45c5844a19ccd7)
   - 內容在 **toggle 裡**，必須展開才看得到
   - 週次範圍用 `mm/dd class ends here` 標記
   - 作業繳交位置也在這裡

## Skills
- aide-skill hackmd: ✅ implemented
  - `hackmd status <url> <deadline>` — check if LN was updated before deadline
  - `hackmd read <url>` — read LN content
  - `hackmd append <url> <content>` — add new notes
  - Requires: HACKMD_TOKEN (set via vault write hackmd/token)
  - HackMD note URL: https://hackmd.io/8mIYVaHbTHaH_QA94VU9fQ


### gv_experiment_env.md
# GV 實驗環境

## 實驗機器：formace-00

- SSH: `ssh formace-00`（直接用 SSH key，不需密碼）
- 工作目錄: `~/claude_projects/EEE5023-SoCV-2026/`
- GV 安裝位置: `~/claude_projects/EEE5023-SoCV-2026/gv/`
  - 已 patch fmt::println for Ubuntu 24.04（不需重 build）
- 實驗 repo: yiidtw/eee5023-socv-2026 (private)
  - clone 位置: `~/claude_projects/EEE5023-SoCV-2026/`

## 筆記 repo（本機）

- 位置: `~/claude_projects/eee5023-socv-2026-note/`
- GitHub: yiidtw/eee5023-socv-2026-note (private)
- 內容: 筆記 markdown、vending machine RTL、課程 metadata

## GV 工具說明

- GV 整合 Yosys + Berkeley-ABC，用於課程驗證實驗
- 課程開源 repo: https://github.com/DVLab-NTU/gv
- 在 formace-00 上跑實驗，結果同步到 HackMD（aide-skill hackmd append）

## 實驗完後同步流程

1. 在 formace-00 跑實驗，紀錄數據
2. commit 到 yiidtw/eee5023-socv-2026
3. 用 aide-skill hackmd append 把結果補進 HackMD 學習筆記


### skills_and_tools.md
# 可用 Skills 與工具

## 主要 skill：socv2026（優先使用）

這門課有專屬 skill，優先用這個，不要單獨呼叫 cool/hackmd/notion：

```
aide-skill socv2026 status     — 顯示 LN 截止、HackMD 狀態、成績、storylens jobs
aide-skill socv2026 grades     — 查成績
aide-skill socv2026 push       — 推 HackMD
aide-skill socv2026 pull       — 拉 HackMD 最新內容
aide-skill socv2026 diff       — 比較 local vs HackMD 差異
aide-skill socv2026 videos     — 列出課程影片
aide-skill socv2026 submit     — 繳交
aide-skill socv2026 notion     — 顯示課程 Notion URL
```

## 課程相關 skills

| Skill | 用途 | 常用指令 |
|-------|------|----------|
| `socv2026` | SoCV 主控台 | status, grades, push, pull, diff, videos, submit, notion |
| `cool` | COOL LMS | assignments, announcements, submissions, scan |
| `hackmd` | HackMD 筆記 | read, status, append |
| `notion` | Notion API | read, append, search |
| `storylens` | YouTube 影片轉錄（用 formace-00 GPU） | submit, status, result, list, playlist |
| `process-cool` | 處理 cool-watch GitHub issue | file, assignment, grade, announcement |

## cool-watch 訂閱

- 這個 agent 訂閱了 `cool-watch` 服務（provider: ntu.yiidtw）
- COOL course ID: 61236，course_code: EEE5023
- 當 cool-watch 偵測到課程有新動態，會發 GitHub issue 給這個 agent
- 收到 issue 後，用 `EXEC: process-cool <type> <args>` 處理

## Vault 憑證

| Key | 用途 |
|-----|------|
| `HACKMD_TOKEN` | HackMD API |
| `NOTION_TOKEN` | Notion API，integration: socv-agent |

查憑證：`aide-skill vault get <KEY>`

## 影片處理流程（storylens）

課程 YouTube playlist：https://www.youtube.com/playlist?list=PLIAzIZzCjtLKF0wZqGb30ryFxAWr41wJ8

```
aide-skill storylens submit <youtube_url>   — 送出轉錄任務
aide-skill storylens status                 — 查任務狀態
aide-skill storylens result <job_id>        — 取得逐字稿
```

## knowledge dir 同步

- `occupation/knowledge/` 是從 note repo 複製過來的快照
- 最新內容以 HackMD 為準（aide-skill socv2026 pull）
- 更新 knowledge 要手動從 note repo 複製


### EE5122 (ee5122-formal.ydwu)
### feedback_formace00_env.md
---
name: formace-00 is the working environment for EE courses
description: EE course notebooks and compute work should be done on formace-00, not locally
type: feedback
---

Always use formace-00 for EE course work (notebooks, compute, etc.), not the local macOS machine.

**Why:** The user's course projects live on formace-00 under ~/claude_projects/. Local machine is not the canonical location.

**How to apply:**
- Before cloning repos or installing packages locally, SSH to formace-00 and check ~/claude_projects/ first
- EE5122 working directory: `formace-00:~/claude_projects/ee5122-formal-2026/` (git repo, branch: master)
  - sv-notebooks is a submodule (https://gitlab.com/formace-lab/teaching/sv-notebooks.git)
  - Python venv: `~/.venvs/fm2026/` (pysmt, z3-solver, jupyter installed)
  - Run notebooks: `~/.venvs/fm2026/bin/jupyter nbconvert --to notebook --execute ...`
- Always `git commit` work on formace-00 after completing tasks


### course_tracking.md
# EE5122 Course Tracking

## Assignments
| # | Name | Due | Status | Notes |
|---|------|-----|--------|-------|
| 1 | PA 1 | 2026-04-07 | Submitted | submitted 3/19, score pending |
| 2 | Quiz 1 | 2026-03-24 | Done | in-class |
| 3 | Quiz 2 | 2026-04-14 | — | |
| 4 | PA 2 | TBD | — | Artifact evaluation, Week 8 |
| 5 | Midterm | 2026-05-05 | — | |
| 6 | Project proposal | 2026-04-28 | — | |
| 7 | Final presentation | 2026-06-09 | — | |
| 8 | Final report | 2026-06-23 | — | |

## Exercises
| Week | Topic | Status | Notes |
|------|-------|--------|-------|
| 2 | Lattices: PO, LUB/GLB, height, Hasse diagrams | Done | |
| 3 | CFA + Abstract Domain + ARG drawing | Done | |
| 4 | CPA algorithm, SP computation | Done | |
| 5 | Cartesian predicate abstraction SP^π_C, CPA with Predicate CPA | — | 11 SP^π_C + 2 ARG + Jupyter notebook |

## How to Check
1. `aide-skill formal2026 pending` — pending items as JSON
2. `aide-skill cool submissions` — COOL submission status


### MEMORY.md
# Memory Index

- [formace-00 is the working environment for EE courses](feedback_formace00_env.md) — always SSH to formace-00 first; EE5122 workspace at ~/claude_projects/ee5122-formal-2026/


### EE5184 (ee5184-ml.ydwu)
### course_tracking.md
# EE5184 Course Tracking

## Assignments
| # | Name | Due | Status | Notes |
|---|------|-----|--------|-------|
| 1 | HW1 — LLM Malicious Instruction Defense | 2026-03-26 | Done | graded 10/10 |
| 2 | HW2 — AI Agent as an AI Engineer | 2026-04-02 | Submitted | awaiting grade |
| 3 | HW3 — LLM Fast Inference (Quiz) | 2026-04-09 | Submitted | re-submitted 2026-04-03, all 23 Qs answered |
| 4 | HW4 — Training Transformer | 2026-04-16 | WIP | JudgeBoi: PDR 0.950, FID 69.21 |
| Bonus | Bonus Competition | 2026-05-15 | — | |

## How to Check
1. `aide-skill ml2026 pending` — pending items as JSON
2. `aide-skill cool submissions` — COOL submission + grade status
3. JudgeBoi: https://ml.ee.ntu.edu.tw (browser, NTU SSO)


### EEE5072 (ee5072-rl.ydwu)
### course_tracking.md
# EEE5072 Course Tracking

## Project Milestones
| # | Name | Due | Status | Notes |
|---|------|-----|--------|-------|
| 1 | Proposal | 2026-03-26 | Submitted | EEE5072_Proposal_YDWu.pdf |
| 2 | Progress Report | TBD | — | |
| 3 | Final Presentation | TBD | — | |
| 4 | Final Report | TBD | — | |

## How to Check
1. `aide-skill rl2026 pending` — pending items as JSON
2. `aide-skill cool announcements` — project updates from TAs



## COOL
## COOL — 2026-04-03
### Assignments
📝 11 assignments:
  [2026-03-26 15:59] HW1
    ← 機器學習 (EE5184)
  [2026-04-02 15:59] HW2
    ← 機器學習 (EE5184)
  [2026-04-07 06:20] Programming Assignment 1
    ← 正規方法 (EE5122)
  [2026-04-09 15:59] HW3
    ← 機器學習 (EE5184)
  [2026-04-16 15:59] HW4
    ← 機器學習 (EE5184)
  [2026-05-15 15:59] 加分作業
    ← 機器學習 (EE5184)
  [no due date] 3/2 心得或筆記
    ← 專題演講二 (EEE7004)
  [no due date] 3/9 心得或筆記
    ← 專題演講二 (EEE7004)
  [no due date] 3/16 心得或筆記
    ← 專題演講二 (EEE7004)
  [no due date] 3/23 心得或筆記
    ← 專題演講二 (EEE7004)
  [no due date] 3/30 心得或筆記
    ← 專題演講二 (EEE7004)

### Announcements (last 10)
📢 5 announcements:
  [2026-03-30] [ML HW1 成績公布]
    ← 機器學習 (EE5184)
    同學好： HW1 成績已公告至 NTU COOL，算分方式請參見 HW1 投影片。 同學如果對成績有疑慮，或是發現登記的成績跟前面算分方式得到的不同，請在 4/5 (日) 23:59:59 之前寄信到助教信箱詢問，並且信件以 [ML 2026 Spring HW1] 開頭。在此期限過後，助教不再更改 HW1 成績，請同學務必於期限前檢查好自己的成績。 ML 2026 Spring HW1 TAs
  [2026-03-30] Week 5公告 (Week 5 Announcement)
    ← 機器學習 (EE5184)
    各位同學好，本週課程相關資料以及上課錄影已更新至課程網站，以下是幾點重要事項： 作業發佈與截止日期 作業二 ： 2026/04/02 23:59:59 (UTC+8) 作業三 ： 2026/04/09 23:59:59 (UTC+8) 作業四 ： 2026/04/16 23:59:59 (UTC+8) 作業不接受遲交，請同學盡早完成。 作業問題諮詢 助教時間 地點： 與上課教室相同 作業四： 4/10 13:20-14:10 &amp; 17:30-18:00 透過 Email 聯繫 主旨請務必以 [ML 2026 Spring HW2] 或 [ML 2026 Spring HW3] 或 [M
  [2026-03-30] 上課影片已經上傳
    ← 機器學習 (EE5184)
    各位同學大家好： 再次為上週五未能如期上課向大家致歉。原訂於上週五進行的課程內容，我已經上傳，請同學們參考以下連結觀看： https://youtu.be/Ll-wk8x3G_g 若造成大家安排上的不便，還請見諒，謝謝各位同學的諒解。 李宏毅 敬上
  [2026-03-27] 本週課程異動
    ← 機器學習 (EE5184)
    我太太身體不適，需要緊急就醫，週五下午就助教直接講作業四，講完就下課。原定課程要講的內容跟作業四沒有直接關聯，所以大家可以直接聽作業四的說明。 &nbsp; 錄影一樣會週一上傳，不受影響。 &nbsp; 李宏毅
  [2026-03-25] Week 4 公告 (Week 4 Announcement)
    ← 機器學習 (EE5184)
    各位同學好，本週課程相關資料已更新至課程網站，以下是幾點重要事項： 作業發佈與截止日期 作業一 ： 2026/03/26 23:59:59 (UTC+8) 作業二 ： 2026/04/02 23:59:59 (UTC+8) 作業三 ： 2026/04/09 23:59:59 (UTC+8) 作業不接受遲交，請同學盡早完成。 作業問題諮詢 助教時間 地點： 與上課教室相同 HW2： 3/27 13:20-14:10 &amp; 17:30-18:00 HW3： 3/27 13:20-14:10 &amp; 17:30-18:00 透過 Email 聯繫 主旨請務必以 [ML 2026 Sprin

### Submissions
📋 Submission status:
📚 正規方法 (EE5122):
  📤 Programming Assignment 1  [due: 2026-04-07 06:20]  submitted  submitted: 2026-03-19 13:37

📚 專題演講二 (EEE7004):
  ❌ 3/2 心得或筆記  [due: no due date]  unsubmitted
  📤 3/9 心得或筆記  [due: no due date]  submitted  submitted: 2026-03-09 06:14
  ❌ 3/16 心得或筆記  [due: no due date]  unsubmitted
  ❌ 3/23 心得或筆記  [due: no due date]  unsubmitted
  ❌ 3/30 心得或筆記  [due: no due date]  unsubmitted

📚 機器學習 (EE5184):
  ✅ HW1  [due: 2026-03-26 15:59]  graded score: 10/10 (10)
  📤 HW2  [due: 2026-04-02 15:59]  submitted  submitted: 2026-03-15 19:49
  ⏳ HW3  [due: 2026-04-09 15:59]  pending_review  submitted: 2026-04-03 00:34
  📤 HW4  [due: 2026-04-16 15:59]  submitted  submitted: 2026-03-29 13:26
  ❌ 加分作業  [due: 2026-05-15 15:59]  unsubmitted


## Mail
## Mail — 2026-04-03
### Unread
🆕 42 unread:

🆕 #1179 | 2026-04-02T22:43 | "校內訊息轉發服務" <notice@ntu.edu.tw>
   「校內訊息」2026/04/03 來週校園活動、演講、研討會一覽表

🆕 #1177 | 2026-04-02T10:30 | "朱士維學務長" <ntudeanstudent@ntu.edu.tw>
   「校內訊息」2026全球集思論壇｜早鳥報名開始 GIS Taiwan 2026｜Early Bird Registration

🆕 #1176 | 2026-04-02T08:37 | "臺大電子所(NTU GIEE)" <ntugiee@ntu.edu.tw>
   {電子所公告} FW: 【敬請協助學術訊息刊登】IUMRS-ICA 2026 國際會議徵稿資訊

🆕 #1175 | 2026-04-02T08:38 | "臺大電子所(NTU GIEE)" <ntugiee@ntu.edu.tw>
   {電子所公告} FW: [請協助轉發資訊] 探索隱藏版高薪產業！免費報名 Powering the Future 能源永續科技人才論壇：與施耐德電機、美商奇異能源等國際頂尖企業面對面交流｜Cake 國際人才平台

🆕 #1174 | 2026-04-02T08:35 | "臺大電子所(NTU GIEE)" <ntugiee@ntu.edu.tw>
   {電子所公告} FW: 【實習宣傳邀請】2026 H2U永悅健康 OASIS 綠洲實習計畫

🆕 #1173 | 2026-04-02T08:34 | "臺大電子所(NTU GIEE)" <ntugiee@ntu.edu.tw>
   {電子所公告} FW: 【永續力獎學金】10 萬元支持你的永續行動｜4/15 開放申請

🆕 #1172 | 2026-04-02T07:00 | "朱士維學務長" <ntudeanstudent@ntu.edu.tw>
   「校內訊息」【臺大職涯中心】2027 Passion Worker學生團隊招募中！[NTU Career Center] Passion Worker 2027 Student Team Recruitment Now Open! 

🆕 #1171 | 2026-04-02T06:15 | "朱士維學務長" <ntudeanstudent@ntu.edu.tw>
   「校內訊息」【 2026職涯培訓工作坊】求職全攻略：從 精準 履歷到模擬面試，一次搞定！【 2026 Career Training Workshop】 The Ultimate Job Search Guide: From Winning Résumés to Mock Interviews—All in One!

🆕 #1170 | 2026-04-02T04:08 | "臺大電子所(NTU GIEE)" <ntugiee@ntu.edu.tw>
   {電子所公告} 提醒：資通系統與物聯網設備及大陸廠牌資通訊產品盤點作業

🆕 #1169 | 2026-04-01T06:47 | "AMD" <reply@engage.amd.com>
   Explore Your AI Developer Program Benefits

🆕 #1167 | 2026-03-31T10:55 | "SPIN2026" <spin2026@easychair.org>
   Only 2 weeks to ETAPS 2026 – Register today & join us in Turin

🆕 #1166 | 2026-03-31T03:45 | "王泓仁教務長" <ntudeanacademic@ntu.edu.tw>
   「校內訊息」教發中心及數習中心近期服務與活動Upcoming Services and Events from CTLD and DLC

🆕 #1165 | 2026-03-31T04:09 | "臺大電子所(NTU GIEE)" <ntugiee@ntu.edu.tw>
   {電子所公告} FW: (代轉發)FW: 【🚀 2026 NTU AI Builders Challenge 矽谷創業種子甄選競賽】

🆕 #1164 | 2026-03-30T22:12 | "ntulc" <ntulc@ntu.edu.tw>
   歐語進修班即將開課，報名從速!

🆕 #1163 | 2026-03-30T21:26 | "GitHub" <noreply@github.com>
   [GitHub] A third-party OAuth application has been added to your account

🆕 #1161 | 2026-03-30T15:30 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: banned 107.170.15.73 from formace-00

🆕 #1159 | 2026-03-30T10:02 | "NTU COOL" <ntu-cool@cool.ntu.edu.tw>
   近期 NTU COOL 通知

🆕 #1157 | 2026-03-30T07:40 | "臺大電子所(NTU GIEE)" <ntugiee@ntu.edu.tw>
   {電子所公告} FW: 【IDA Talk】敬邀參加4/7（二）Prof. Xiaobo Sharon Hu 演講

🆕 #1154 | 2026-03-30T04:14 | "機器學習 Machine Learning" <ntu-cool@cool.ntu.edu.tw>
   上課影片已經上傳： 機器學習 Machine Learning

🆕 #1153 | 2026-03-29T22:57 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: banned 112.216.129.27 from formace-00

🆕 #1151 | 2026-03-27T11:58 | "ASE 2026 HotCRP" <noreply-ase26@hotcrp.com>
   [ASE 2026] Updated #2620 "AgentBelt: Deterministic Runtime..."

🆕 #1150 | 2026-03-27T11:55 | "ASE 2026 HotCRP" <noreply-ase26@hotcrp.com>
   [ASE 2026] Submitted #2620 "AgentBelt: Deterministic Runtime..."

🆕 #1149 | 2026-03-27T11:44 | "ASE 2026 HotCRP" <noreply-ase26@hotcrp.com>
   [ASE 2026] Updated #2620 "AgentBelt: Deterministic Runtime..."

🆕 #1148 | 2026-03-27T11:43 | "ASE 2026 HotCRP" <noreply-ase26@hotcrp.com>
   [ASE 2026] Updated #2620 "AgentBelt: Deterministic Runtime..."

🆕 #1147 | 2026-03-27T06:00 | "朱士維學務長" <ntudeanstudent@ntu.edu.tw>
   「校內訊息」國立臺灣大學2026年僑陸國際生歌唱大賽決賽《怦然Sing動》 即將心動登場！The National Taiwan University 2026 International and Overseas Chinese Students Singing Competition Finals are approaching!

🆕 #1146 | 2026-03-27T03:07 | "機器學習 Machine Learning" <ntu-cool@cool.ntu.edu.tw>
   本週課程異動： 機器學習 Machine Learning

🆕 #1145 | 2026-03-26T22:43 | "校內訊息轉發服務" <notice@ntu.edu.tw>
   「校內訊息」2026/03/27 來週校園活動、演講、研討會一覽表

🆕 #1144 | 2026-03-26T15:14 | "學生職業生涯發展中心" <career@ntu.edu.tw>
   「跨領域職涯培訓 - 臺灣引路人計畫」3月底申請即將截止！

🆕 #1143 | 2026-03-26T15:24 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: banned 112.216.129.27 from formace-00

🆕 #1142 | 2026-03-26T14:19 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: banned 112.216.129.27 from formace-00

🆕 #1141 | 2026-03-26T12:15 | "李念澤" <nzlee@g.ntu.edu.tw>
   Invitation: ASE submission @ Fri Mar 27, 2026 4pm - 5pm (GMT+8) (r14943151@ntu.edu.tw)

🆕 #1140 | 2026-03-26T11:44 | "ASE 2026 HotCRP" <noreply-ase26@hotcrp.com>
   [ASE 2026] Updated #2620 "AgentBelt: Deterministic Runtime..."

🆕 #1139 | 2026-03-26T11:44 | "ASE 2026 HotCRP" <noreply-ase26@hotcrp.com>
   [ASE 2026] Updated #2620 "AgentBelt: Deterministic Runtime..."

🆕 #1138 | 2026-03-26T11:44 | "ASE 2026 HotCRP" <noreply-ase26@hotcrp.com>
   [ASE 2026] Contact for #2620 "AgentBelt: Deterministic Runtime..."

🆕 #1137 | 2026-03-26T10:00 | "莊智程會長" <ntugsa@ntu.edu.tw>
   「校內訊息」2026 臺大升學講座｜我不入博班誰入博班！

🆕 #1136 | 2026-03-26T10:07 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: banned 112.216.129.27 from formace-00

🆕 #1135 | 2026-03-26T09:05 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: banned 112.216.129.27 from formace-00

🆕 #1134 | 2026-03-26T08:04 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: banned 112.216.129.27 from formace-00

🆕 #1133 | 2026-03-26T05:59 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: banned 112.216.129.27 from formace-00

🆕 #1132 | 2026-03-26T04:57 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: banned 112.216.129.27 from formace-00

🆕 #1131 | 2026-03-26T03:55 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: banned 112.216.129.27 from formace-00

🆕 #1130 | 2026-03-26T03:33 | "Fail2Ban" <formace-lab@ntu.edu.tw>
   [Fail2Ban] sshd: started on formace-00
