// easychair — bridge to aide-skill easychair
// usage: easychair [reviews|summary|view <id>]

const cmd = process.argv[2] || "summary";
const rest = process.argv.slice(3);

const proc = Bun.spawn(["aide-skill", "easychair", cmd, ...rest], {
  stdout: "inherit",
  stderr: "inherit",
});

await proc.exited;
process.exit(proc.exitCode ?? 0);
