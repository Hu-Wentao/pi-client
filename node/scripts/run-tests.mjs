import { readdirSync } from "node:fs";
import { join } from "node:path";
import { spawnSync } from "node:child_process";

function collectTests(directory) {
  const files = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...collectTests(path));
    } else if (entry.isFile() && entry.name.endsWith(".test.ts")) {
      files.push(path);
    }
  }
  return files.sort();
}

const env = { ...process.env };
for (const name of Object.keys(env)) {
  if (
    name.endsWith("_API_KEY") ||
    [
      "ANTHROPIC_AUTH_TOKEN",
      "ANTHROPIC_API_KEY",
      "OPENAI_API_KEY",
      "GEMINI_API_KEY",
      "GOOGLE_API_KEY",
      "MISTRAL_API_KEY",
      "GROQ_API_KEY",
      "OPENROUTER_API_KEY",
      "XAI_API_KEY",
    ].includes(name)
  ) {
    delete env[name];
  }
}

env.PI_OFFLINE = "1";
env.PI_SKIP_VERSION_CHECK = "1";
env.PI_TELEMETRY = "0";

const tests = collectTests(new URL("../test", import.meta.url).pathname);
if (tests.length === 0) {
  console.error("No Node test files found.");
  process.exit(1);
}

const result = spawnSync(
  process.execPath,
  ["--import", "tsx", "--test", "--test-reporter", "spec", ...tests],
  {
    cwd: new URL("..", import.meta.url),
    env,
    stdio: "inherit",
  },
);

if (result.error) {
  throw result.error;
}
process.exit(result.status ?? 1);
