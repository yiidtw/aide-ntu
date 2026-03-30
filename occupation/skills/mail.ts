// mail — NTU mail (POP3/SMTP)
// usage: mail [check|unread|read N|search Q|send TO SUBJ BODY]
// env: EMAIL_USER, EMAIL_PASS, POP3_HOST, SMTP_HOST

const user = process.env.EMAIL_USER;
const pass = process.env.EMAIL_PASS;
if (!user) { console.error("EMAIL_USER not set. Run: aide.sh vault set EMAIL_USER=you@ntu.edu.tw"); process.exit(1); }
if (!pass) { console.error("EMAIL_PASS not set. Run: aide.sh vault set EMAIL_PASS=your-password"); process.exit(1); }

const pop3Host = process.env.POP3_HOST || "pop3.ntu.edu.tw";
const smtpHost = process.env.SMTP_HOST || "smtp.ntu.edu.tw";

const cmd = process.argv[2] || "check";
const args = process.argv.slice(3);

// Delegate to python3 for POP3/SMTP — keeping same logic, just wrapped in TS
function runPython(code: string): void {
  const proc = Bun.spawnSync(["python3", "-c", code], {
    stdout: "inherit",
    stderr: "pipe",
  });
  if (proc.exitCode !== 0) {
    const stderr = proc.stderr.toString();
    if (stderr && !stderr.includes("DeprecationWarning")) {
      console.log("  (connection failed — check credentials)");
    }
  }
}

switch (cmd) {
  case "check":
  case "unread": {
    console.log(`=== Inbox (${user} via ${pop3Host}) ===`);
    runPython(`
import poplib, email
from email.header import decode_header

def decode_hdr(h):
    if h is None: return '?'
    parts = decode_header(h)
    return ''.join(
        p.decode(c or 'utf-8') if isinstance(p, bytes) else p
        for p, c in parts
    )

try:
    m = poplib.POP3_SSL('${pop3Host}')
    m.user('${user}')
    m.pass_('${pass}')
    count, size = m.stat()
    print(f'  {count} messages ({size//1024} KB)')
    print()
    start = max(1, count - 9)
    for i in range(count, max(0, count - 10), -1):
        resp, lines, octets = m.retr(i)
        raw = b'\\r\\n'.join(lines)
        msg = email.message_from_bytes(raw)
        frm = decode_hdr(msg['From'])[:40]
        subj = decode_hdr(msg['Subject'])[:50]
        date = msg.get('Date','')[:20]
        print(f'  {i:4d}  {date:20s}  {frm:40s}  {subj}')
    m.quit()
except Exception as e:
    print(f'  Error: {e}')
    print(f'  Check EMAIL_USER, EMAIL_PASS, POP3_HOST in vault')
`);
    break;
  }

  case "read": {
    const n = args[0];
    if (!n) { console.log("usage: mail read N"); process.exit(1); }
    console.log(`=== Message #${n} ===`);
    runPython(`
import poplib, email
from email.header import decode_header

def decode_hdr(h):
    if h is None: return '?'
    parts = decode_header(h)
    return ''.join(
        p.decode(c or 'utf-8') if isinstance(p, bytes) else p
        for p, c in parts
    )

try:
    m = poplib.POP3_SSL('${pop3Host}')
    m.user('${user}')
    m.pass_('${pass}')
    resp, lines, octets = m.retr(${n})
    raw = b'\\r\\n'.join(lines)
    msg = email.message_from_bytes(raw)
    print(f'From:    {decode_hdr(msg["From"])}')
    print(f'To:      {decode_hdr(msg["To"])}')
    print(f'Subject: {decode_hdr(msg["Subject"])}')
    print(f'Date:    {msg.get("Date","?")}')
    print()
    if msg.is_multipart():
        for part in msg.walk():
            ct = part.get_content_type()
            if ct == 'text/plain':
                payload = part.get_payload(decode=True)
                charset = part.get_content_charset() or 'utf-8'
                print(payload.decode(charset, errors='replace'))
                break
    else:
        payload = msg.get_payload(decode=True)
        charset = msg.get_content_charset() or 'utf-8'
        print(payload.decode(charset, errors='replace'))
    m.quit()
except Exception as e:
    print(f'Error: {e}')
`);
    break;
  }

  case "search": {
    const q = args[0];
    if (!q) { console.log("usage: mail search QUERY"); process.exit(1); }
    console.log(`=== Search: ${q} ===`);
    runPython(`
import poplib, email
from email.header import decode_header

def decode_hdr(h):
    if h is None: return '?'
    parts = decode_header(h)
    return ''.join(
        p.decode(c or 'utf-8') if isinstance(p, bytes) else p
        for p, c in parts
    )

try:
    m = poplib.POP3_SSL('${pop3Host}')
    m.user('${user}')
    m.pass_('${pass}')
    count, _ = m.stat()
    q = '${q}'.lower()
    found = 0
    for i in range(count, max(0, count - 50), -1):
        resp, lines, octets = m.top(i, 0)
        raw = b'\\r\\n'.join(lines)
        msg = email.message_from_bytes(raw)
        subj = decode_hdr(msg['Subject']).lower()
        frm = decode_hdr(msg['From']).lower()
        if q in subj or q in frm:
            print(f'  {i:4d}  {decode_hdr(msg["Subject"])[:60]}')
            found += 1
            if found >= 10: break
    if found == 0:
        print('  (no matches)')
    m.quit()
except Exception as e:
    print(f'Error: {e}')
`);
    break;
  }

  case "send": {
    const to = args[0];
    const subj = args[1];
    const body = args[2];
    if (!to || !subj || !body) { console.log("usage: mail send TO SUBJECT BODY"); process.exit(1); }
    console.log("=== Sending mail ===");
    console.log(`  To:      ${to}`);
    console.log(`  Subject: ${subj}`);
    // Pass via env to avoid shell injection
    const proc = Bun.spawnSync(["python3", "-c", `
import smtplib, os
from email.mime.text import MIMEText

msg = MIMEText(os.environ['MAIL_BODY'])
msg['Subject'] = os.environ['MAIL_SUBJ']
msg['From'] = os.environ['MAIL_FROM']
msg['To'] = os.environ['MAIL_TO']

try:
    s = smtplib.SMTP_SSL(os.environ['SMTP_HOST'])
    s.login(os.environ['MAIL_FROM'], os.environ['MAIL_PASS'])
    s.send_message(msg)
    s.quit()
    print('  Sent.')
except Exception as e:
    print(f'  Error: {e}')
`], {
      env: {
        ...process.env,
        MAIL_BODY: body,
        MAIL_SUBJ: subj,
        MAIL_FROM: user,
        MAIL_TO: to,
        MAIL_PASS: pass,
        SMTP_HOST: smtpHost,
      },
      stdout: "inherit",
      stderr: "pipe",
    });
    if (proc.exitCode !== 0) {
      console.log("  (send failed)");
    }
    break;
  }

  default:
    console.log("usage: mail [check|unread|read N|search Q|send TO SUBJ BODY]");
    process.exit(1);
}
