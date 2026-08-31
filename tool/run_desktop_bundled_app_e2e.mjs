#!/usr/bin/env node

import { spawn, spawnSync } from "node:child_process";
import { mkdir, mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";

import { verifyInstalledDesktopRuntimeCapsule } from "../node/scripts/desktop-app-runtime-capsule-lib.mjs";

const options = parseArguments(process.argv.slice(2));
if (
  (options.platform === "windows" && process.platform !== "win32") ||
  (options.platform === "linux" && process.platform !== "linux")
) {
  throw new Error(
    `Installed-app E2E for ${options.platform} requires its native host.`,
  );
}
const installed = await verifyInstalledDesktopRuntimeCapsule({
  platform: options.platform,
  bundleRoot: options.bundleRoot,
  expectedSourceCommit: options.expectedSourceCommit,
});
const result = await runInstalledApp(options, installed);
process.stdout.write(
  `${JSON.stringify({ ...installed, ...result }, null, 2)}\n`,
);

async function runInstalledApp(options_, installed_) {
  const verificationRoot = await mkdtemp(
    resolve(tmpdir(), "pi-client-desktop-app-e2e-"),
  );
  const home = resolve(verificationRoot, "home");
  const agentDirectory = resolve(verificationRoot, "agent");
  const temporary = resolve(verificationRoot, "tmp");
  const emptyPath = resolve(verificationRoot, "empty-path");
  await Promise.all(
    [home, agentDirectory, temporary, emptyPath].map((path) =>
      mkdir(path, { recursive: true }),
    ),
  );
  const output = { stdout: [], stderr: [] };
  const environment = {
    ...process.env,
    HOME: home,
    USERPROFILE: home,
    PATH: emptyPath,
    PI_CODING_AGENT_DIR: agentDirectory,
    TEMP: temporary,
    TMP: temporary,
    TMPDIR: temporary,
  };
  const child = spawn(installed_.bundleExecutable, [], {
    cwd: home,
    env: environment,
    stdio: ["ignore", "pipe", "pipe"],
  });
  child.stdout.on("data", (chunk) => output.stdout.push(Buffer.from(chunk)));
  child.stderr.on("data", (chunk) => output.stderr.push(Buffer.from(chunk)));
  const exited = new Promise((resolvePromise, rejectPromise) => {
    child.once("error", rejectPromise);
    child.once("exit", (code, signal) => resolvePromise({ code, signal }));
  });

  let runtimeProcess;
  try {
    runtimeProcess = await waitForBundledRuntimeProcess({
      appPid: child.pid,
      runtimeExecutable: installed_.runtimeExecutable,
      applicationEntrypoint: installed_.applicationEntrypoint,
      timeoutMillis: options_.timeoutMillis,
      exited,
    });
    child.kill("SIGTERM");
    await Promise.race([
      exited,
      delay(15_000).then(() => {
        throw new Error(
          "The installed Pi Client app did not stop after termination.",
        );
      }),
    ]);
    await waitForProcessExit(runtimeProcess.pid, 15_000);
    return {
      appPid: child.pid,
      runtimePid: runtimeProcess.pid,
      bundledRuntimeStarted: true,
      systemNodeExcludedFromPath: true,
      inheritedPath: emptyPath,
    };
  } catch (error) {
    child.kill("SIGTERM");
    if (runtimeProcess && isProcessRunning(runtimeProcess.pid))
      process.kill(runtimeProcess.pid, "SIGTERM");
    throw error;
  } finally {
    if (!options_.keepTemporary)
      await rm(verificationRoot, { recursive: true, force: true });
  }
}

async function waitForBundledRuntimeProcess(options_) {
  const deadline = Date.now() + options_.timeoutMillis;
  while (Date.now() < deadline) {
    const exit = await Promise.race([
      options_.exited,
      delay(250).then(() => null),
    ]);
    if (exit)
      throw new Error(
        `Pi Client exited before bundled runtime startup: ${JSON.stringify(exit)}.`,
      );
    const processes = processSnapshot();
    const descendants = descendantPids(processes, options_.appPid);
    const runtime = processes.find(
      (entry) =>
        descendants.has(entry.pid) &&
        includesPath(entry.command, options_.runtimeExecutable) &&
        includesPath(entry.command, options_.applicationEntrypoint),
    );
    if (runtime) return runtime;
  }
  throw new Error(
    "Timed out waiting for Pi Client to start its bundled Pi Node runtime.",
  );
}

function processSnapshot() {
  if (process.platform === "win32") {
    const powershell = resolve(
      process.env.SystemRoot ?? "C:\\Windows",
      "System32/WindowsPowerShell/v1.0/powershell.exe",
    );
    const result = spawnSync(
      powershell,
      [
        "-NoLogo",
        "-NoProfile",
        "-NonInteractive",
        "-Command",
        "Get-CimInstance Win32_Process | Select-Object ProcessId,ParentProcessId,CommandLine | ConvertTo-Json -Compress",
      ],
      { encoding: "utf8", windowsHide: true },
    );
    if (result.error) throw result.error;
    if (result.status !== 0)
      throw new Error(`PowerShell process inventory failed: ${result.stderr}`);
    const decoded = JSON.parse(result.stdout || "[]");
    return (Array.isArray(decoded) ? decoded : [decoded]).map((entry) => ({
      pid: Number(entry.ProcessId),
      parentPid: Number(entry.ParentProcessId),
      command: entry.CommandLine ?? "",
    }));
  }
  const result = spawnSync("/bin/ps", ["-eo", "pid=,ppid=,args="], {
    encoding: "utf8",
  });
  if (result.error) throw result.error;
  if (result.status !== 0)
    throw new Error(`ps failed with code ${result.status}.`);
  return result.stdout
    .split("\n")
    .map((line) => /^\s*(\d+)\s+(\d+)\s+(.*)$/u.exec(line))
    .filter(Boolean)
    .map((match) => ({
      pid: Number(match[1]),
      parentPid: Number(match[2]),
      command: match[3],
    }));
}

function descendantPids(processes, rootPid) {
  const descendants = new Set([rootPid]);
  let changed = true;
  while (changed) {
    changed = false;
    for (const entry of processes) {
      if (descendants.has(entry.parentPid) && !descendants.has(entry.pid)) {
        descendants.add(entry.pid);
        changed = true;
      }
    }
  }
  descendants.delete(rootPid);
  return descendants;
}

function includesPath(command, path) {
  return process.platform === "win32"
    ? command.toLowerCase().includes(path.toLowerCase())
    : command.includes(path);
}

async function waitForProcessExit(pid, timeoutMillis) {
  const deadline = Date.now() + timeoutMillis;
  while (Date.now() < deadline) {
    if (!isProcessRunning(pid)) return;
    await delay(200);
  }
  throw new Error(
    "The bundled Pi Node runtime remained alive after the app exited.",
  );
}

function isProcessRunning(pid) {
  try {
    process.kill(pid, 0);
    return true;
  } catch (error) {
    if (error?.code === "ESRCH") return false;
    return false;
  }
}

function delay(milliseconds) {
  return new Promise((resolvePromise) =>
    setTimeout(resolvePromise, milliseconds),
  );
}

function parseArguments(arguments_) {
  const values = new Map();
  let keepTemporary = false;
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (argument === "--keep-temporary") {
      keepTemporary = true;
      continue;
    }
    if (
      ![
        "--platform",
        "--bundle",
        "--expected-source-commit",
        "--timeout-ms",
      ].includes(argument)
    ) {
      throw new Error(`Unsupported installed-app E2E argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    values.set(argument, value);
  }
  const platform = values.get("--platform");
  const bundleRoot = values.get("--bundle");
  if (!new Set(["windows", "linux"]).has(platform) || !bundleRoot) {
    throw new Error("--platform windows|linux and --bundle are required.");
  }
  const timeoutMillis = Number(values.get("--timeout-ms") ?? "90000");
  if (!Number.isSafeInteger(timeoutMillis) || timeoutMillis <= 0)
    throw new Error("Invalid --timeout-ms.");
  return {
    platform,
    bundleRoot: resolve(bundleRoot),
    expectedSourceCommit: values.get("--expected-source-commit"),
    timeoutMillis,
    keepTemporary,
  };
}
