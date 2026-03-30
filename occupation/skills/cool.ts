// cool — NTU COOL (Canvas LMS) scanner
// usage: cool [courses|assignments|grades|todos|summary|announcements|scan|submissions]
// Delegates to aide-skill cool which has the working ADFS login

const cmd = process.argv[2] || "scan";

const proc = Bun.spawn(["aide-skill", "cool", cmd], {
  stdout: "inherit",
  stderr: "inherit",
});

await proc.exited;
process.exit(proc.exitCode ?? 0);
