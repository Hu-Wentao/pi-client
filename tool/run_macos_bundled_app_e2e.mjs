#!/usr/bin/env node

import { spawn, spawnSync } from "node:child_process";
import { mkdir, mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, resolve } from "node:path";

import { verifyInstalledRuntimeCapsule } from "../node/scripts/macos-app-runtime-capsule-lib.mjs";

const options = parseArguments(process.argv.slice(2));
const installed = await verifyInstalledRuntimeCapsule({
  appBundle: options.appBundle,
  expectedSourceCommit: options.expectedSourceCommit,
});
const result = await runInstalledApp(options, installed);
process.stdout.write(
  `${JSON.stringify({ ...installed, ...result }, null, 2)}\n`,
);

async function runInstalledApp(options, installed) {
  const verificationRoot = await mkdtemp(
    resolve(tmpdir(), "pi-client-installed-app-e2e-"),
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
  const appExecutable = resolve(options.appBundle, "Contents/MacOS/Pi Client");
  const stdout = [];
  const stderr = [];
  const child = spawn(appExecutable, [], {
    cwd: home,
    env: {
      HOME: home,
      LANG: "C",
      LC_ALL: "C",
      PATH: emptyPath,
      PI_CODING_AGENT_DIR: agentDirectory,
      TMPDIR: temporary,
    },
    stdio: ["ignore", "pipe", "pipe"],
  });
  child.stdout.on("data", (chunk) => stdout.push(Buffer.from(chunk)));
  child.stderr.on("data", (chunk) => stderr.push(Buffer.from(chunk)));
  const exited = new Promise((resolvePromise, rejectPromise) => {
    child.once("error", rejectPromise);
    child.once("exit", (code, signal) => resolvePromise({ code, signal }));
  });

  let nodeProcess;
  try {
    nodeProcess = await waitForBundledRuntimeProcess({
      appPid: child.pid,
      runtimeExecutable: installed.runtimeExecutable,
      applicationEntrypoint: installed.applicationEntrypoint,
      timeoutMillis: options.timeoutMillis,
      exited,
    });
    if (!child.kill("SIGTERM")) {
      throw new Error("The installed Pi Client app could not be stopped.");
    }
    await Promise.race([
      exited,
      delay(15_000).then(() => {
        throw new Error(
          "The installed Pi Client app did not stop after SIGTERM.",
        );
      }),
    ]);
    await waitForProcessExit(nodeProcess.pid, 15_000);
    const output = `${Buffer.concat(stdout).toString("utf8")}\n${Buffer.concat(stderr).toString("utf8")}`;
    if (
      /-34018|errSecMissingEntitlement|keychain.*entitlement/iu.test(output)
    ) {
      throw new Error(
        "The unsigned preview attempted unavailable Keychain access.",
      );
    }
    return {
      appExecutable,
      appPid: child.pid,
      runtimePid: nodeProcess.pid,
      runtimeCommand: `${basename(installed.runtimeExecutable)} <bundled-entrypoint>`,
      systemNodeExcludedFromPath: true,
      appPath: emptyPath,
      bundledRuntimeStarted: true,
      unsignedPreviewKeychainError: false,
    };
  } catch (error) {
    child.kill("SIGTERM");
    if (nodeProcess && isProcessRunning(nodeProcess.pid)) {
      process.kill(nodeProcess.pid, "SIGTERM");
    }
    throw error;
  } finally {
    if (!options.keepTemporary) {
      await rm(verificationRoot, { recursive: true, force: true });
    }
  }
}

async function waitForBundledRuntimeProcess(options) {
  const deadline = Date.now() + options.timeoutMillis;
  while (Date.now() < deadline) {
    const exit = await Promise.race([
      options.exited,
      delay(250).then(() => null),
    ]);
    if (exit) {
      throw new Error(
        `Pi Client exited before its bundled runtime started: code=${exit.code} signal=${exit.signal}.`,
      );
    }
    const processes = processSnapshot();
    const descendants = descendantPids(processes, options.appPid);
    const runtime = processes.find(
      (entry) =>
        descendants.has(entry.pid) &&
        entry.command.includes(options.runtimeExecutable) &&
        entry.command.includes(options.applicationEntrypoint),
    );
    if (runtime) return runtime;
  }
  throw new Error(
    "Timed out waiting for Pi Client to start its bundled Pi Node runtime.",
  );
}

function processSnapshot() {
  const result = spawnSync("/bin/ps", ["-axo", "pid=,ppid=,command="], {
    encoding: "utf8",
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`ps failed with code ${result.status}.`);
  }
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
    throw error;
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
      !["--app", "--expected-source-commit", "--timeout-ms"].includes(argument)
    ) {
      throw new Error(`Unsupported installed-app E2E argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    if (values.has(argument))
      throw new Error(`${argument} may be supplied only once.`);
    values.set(argument, value);
  }
  const appBundle = values.get("--app");
  if (!appBundle) throw new Error("--app is required.");
  const timeoutMillis = Number(values.get("--timeout-ms") ?? "90000");
  if (!Number.isSafeInteger(timeoutMillis) || timeoutMillis <= 0) {
    throw new Error("--timeout-ms must be a positive integer.");
  }
  return {
    appBundle: resolve(appBundle),
    expectedSourceCommit: values.get("--expected-source-commit"),
    timeoutMillis,
    keepTemporary,
  };
}
