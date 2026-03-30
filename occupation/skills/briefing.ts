// briefing — daily executive summary for NTU courses + papers
// usage: briefing [EMAIL]
// Delegates to briefing.sh which has the full Python formatter
// This .ts exists for Bun compatibility; .sh is the source of truth

import { join } from "path";

const scriptDir = import.meta.dir;
const args = process.argv.slice(2);

const proc = Bun.spawn(["bash", join(scriptDir, "briefing.sh"), ...args], {
  stdout: "inherit",
  stderr: "inherit",
  env: process.env,
});

await proc.exited;
process.exit(proc.exitCode ?? 0);
