import assert from "node:assert/strict";
import { mkdir, mkdtemp, readFile, readdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test, { type TestContext } from "node:test";

import { SessionManager } from "@earendil-works/pi-coding-agent";

import {
  PiSdkSessionAdministrationError,
  PublicPiSdkSessionAdministration,
  sanitizeGeneratedSessionName,
  sessionInfoToSummary,
} from "../src/pi-sdk-session-administration.js";
import { ProjectTrustCoordinator } from "../src/project-trust.js";

interface Fixture {
  readonly root: string;
  readonly cwd: string;
  readonly agentDir: string;
  readonly sessionDir: string;
  readonly authorization: Awaited<ReturnType<ProjectTrustCoordinator["authorize"]>>;
}

async function fixture(t: TestContext): Promise<Fixture> {
  const root = await mkdtemp(join(tmpdir(), "pi-client-session-admin-"));
  const cwd = join(root, "project");
  const agentDir = join(root, "agent");
  const sessionDir = join(root, "sessions");
  await Promise.all([mkdir(cwd), mkdir(agentDir), mkdir(sessionDir)]);
  await writeFile(
    join(agentDir, "settings.json"),
    `${JSON.stringify({ sessionDir, enableAnalytics: false })}\n`,
    "utf8",
  );
  t.after(() => rm(root, { recursive: true, force: true }));
  const authorization = await new ProjectTrustCoordinator().authorize({ cwd, agentDir });
  return { root, cwd: authorization.cwd, agentDir, sessionDir, authorization };
}

function createSession(
  cwd: string,
  sessionDir: string,
  id: string,
  options: { readonly parentSession?: string; readonly name?: string } = {},
): string {
  const manager = SessionManager.create(cwd, sessionDir, {
    id,
    ...(options.parentSession === undefined ? {} : { parentSession: options.parentSession }),
  });
  manager.appendMessage({
    role: "user",
    content: [{ type: "text", text: `Question for ${id}` }],
    timestamp: 1,
  });
  manager.appendMessage({
    role: "assistant",
    content: [{ type: "text", text: `Answer for ${id}` }],
    api: "anthropic-messages",
    provider: "anthropic",
    model: "fixture-model",
    usage: {
      input: 1,
      output: 1,
      cacheRead: 0,
      cacheWrite: 0,
      totalTokens: 2,
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
    },
    stopReason: "stop",
    timestamp: 2,
  });
  if (options.name !== undefined) manager.appendSessionInfo(options.name);
  const sessionFile = manager.getSessionFile();
  if (!sessionFile) throw new Error("Expected a persistent session file.");
  return sessionFile;
}

test("rename and clear append canonical SessionManager session_info entries atomically", async (t) => {
  const value = await fixture(t);
  createSession(value.cwd, value.sessionDir, "rename-session", { name: "Old name" });
  const administration = new PublicPiSdkSessionAdministration();

  const renamed = await administration.renamePersistentSession({
    authorization: value.authorization,
    agentDir: value.agentDir,
    sessionId: "rename-session",
    name: "  New\nname  ",
  });
  assert.equal(renamed.name, "New name");
  assert.notEqual(renamed.adminRevision, "");

  const cleared = await administration.clearPersistentSessionName({
    authorization: value.authorization,
    agentDir: value.agentDir,
    sessionId: "rename-session",
  });
  assert.equal(cleared.name, undefined);

  const listed = await SessionManager.list(value.cwd, value.sessionDir);
  const manager = SessionManager.open(listed[0]!.path, value.sessionDir, value.cwd);
  assert.equal(manager.getSessionName(), undefined);
  assert.deepEqual(
    manager
      .getEntries()
      .filter((entry) => entry.type === "session_info")
      .map((entry) => (entry.type === "session_info" ? entry.name : undefined)),
    ["Old name", "New name", ""],
  );
});

test("atomic commit failure preserves the original JSONL bytes and removes staging files", async (t) => {
  const value = await fixture(t);
  const sessionPath = createSession(value.cwd, value.sessionDir, "atomic-session", {
    name: "Original",
  });
  const original = await readFile(sessionPath);
  const administration = new PublicPiSdkSessionAdministration({
    beforeAtomicCommit: () => {
      throw new Error("synthetic atomic commit failure");
    },
  });

  await assert.rejects(
    administration.renamePersistentSession({
      authorization: value.authorization,
      agentDir: value.agentDir,
      sessionId: "atomic-session",
      name: "Must not commit",
    }),
    (error) =>
      error instanceof PiSdkSessionAdministrationError &&
      error.code === "session-admin-write-failed",
  );
  assert.deepEqual(await readFile(sessionPath), original);
  assert.deepEqual(
    (await readdir(value.sessionDir)).filter((name) => name.includes("pi-client-")),
    [],
  );
});

test("delete reparents direct child sessions without deleting unrelated host state", async (t) => {
  const value = await fixture(t);
  const grandParent = join(value.root, "historic-grand-parent.jsonl");
  const parentPath = createSession(value.cwd, value.sessionDir, "parent-session", {
    parentSession: grandParent,
    name: "Parent session",
  });
  const childPath = createSession(value.cwd, value.sessionDir, "child-session", {
    parentSession: parentPath,
    name: "Child session",
  });
  const unrelatedPath = createSession(value.cwd, value.sessionDir, "unrelated-session", {
    name: "Unrelated session",
  });
  const worktreeSentinel = join(value.root, "worktree-sentinel");
  const branchSentinel = join(value.root, "branch-sentinel");
  await Promise.all([
    writeFile(worktreeSentinel, "worktree\n"),
    writeFile(branchSentinel, "branch\n"),
  ]);
  const parentInfo = (await SessionManager.list(value.cwd, value.sessionDir)).find(
    (session) => session.id === "parent-session",
  )!;
  const summary = sessionInfoToSummary(parentInfo);
  const administration = new PublicPiSdkSessionAdministration();

  const deleted = await administration.deletePersistentSession({
    authorization: value.authorization,
    agentDir: value.agentDir,
    sessionId: "parent-session",
    confirmation: {
      sessionId: "parent-session",
      adminRevision: summary.adminRevision,
      displayedTitle: "Parent session",
      destructiveActionAcknowledged: true,
    },
  });

  assert.deepEqual(deleted, {
    sessionId: "parent-session",
    reparentedChildCount: 1,
  });
  await assert.rejects(readFile(parentPath));
  const childHeader = JSON.parse((await readFile(childPath, "utf8")).split("\n")[0]!) as {
    parentSession?: string;
  };
  assert.equal(childHeader.parentSession, grandParent);
  assert.ok((await readFile(unrelatedPath)).length > 0);
  assert.equal(await readFile(worktreeSentinel, "utf8"), "worktree\n");
  assert.equal(await readFile(branchSentinel, "utf8"), "branch\n");
});

test("model-assisted naming is sanitized and never needs a real provider in tests", async (t) => {
  const value = await fixture(t);
  createSession(value.cwd, value.sessionDir, "auto-session");
  const administration = new PublicPiSdkSessionAdministration({
    autoNameGenerator: async ({ sessionManager, signal }) => {
      assert.equal(signal.aborted, false);
      assert.equal(sessionManager.buildSessionContext().model?.modelId, "fixture-model");
      return "  **Title: “Generated\nSession Title”**  ";
    },
  });

  const named = await administration.autoNamePersistentSession({
    authorization: value.authorization,
    agentDir: value.agentDir,
    sessionId: "auto-session",
    timeoutMillis: 1_000,
  });
  assert.equal(named.name, "Generated Session Title");
  assert.equal(sanitizeGeneratedSessionName("`Focused title`"), "Focused title");
});

test("auto-name failures expose stable messages without transcript leakage", async (t) => {
  const value = await fixture(t);
  createSession(value.cwd, value.sessionDir, "redacted-session");
  const administration = new PublicPiSdkSessionAdministration({
    autoNameGenerator: async () => {
      throw new Error("private prompt and transcript detail");
    },
  });

  await assert.rejects(
    administration.autoNamePersistentSession({
      authorization: value.authorization,
      agentDir: value.agentDir,
      sessionId: "redacted-session",
      timeoutMillis: 1_000,
    }),
    (error) => {
      assert.ok(error instanceof PiSdkSessionAdministrationError);
      assert.equal(error.code, "session-auto-name-failed");
      assert.equal(error.message.includes("private prompt"), false);
      assert.equal(error.message.includes("transcript detail"), false);
      return true;
    },
  );
});

test("model-assisted naming enforces caller cancellation and a bounded timeout", async (t) => {
  const value = await fixture(t);
  createSession(value.cwd, value.sessionDir, "cancel-session");
  const administration = new PublicPiSdkSessionAdministration({
    autoNameGenerator: ({ signal }) =>
      new Promise<string>((_resolve, reject) => {
        if (signal.aborted) {
          reject(signal.reason);
          return;
        }
        signal.addEventListener("abort", () => reject(signal.reason), { once: true });
      }),
  });

  const caller = new AbortController();
  caller.abort(new Error("synthetic cancel"));
  await assert.rejects(
    administration.autoNamePersistentSession({
      authorization: value.authorization,
      agentDir: value.agentDir,
      sessionId: "cancel-session",
      timeoutMillis: 1_000,
      signal: caller.signal,
    }),
    (error) =>
      error instanceof PiSdkSessionAdministrationError &&
      error.code === "session-auto-name-cancelled",
  );

  await assert.rejects(
    administration.autoNamePersistentSession({
      authorization: value.authorization,
      agentDir: value.agentDir,
      sessionId: "cancel-session",
      timeoutMillis: 1_000,
    }),
    (error) =>
      error instanceof PiSdkSessionAdministrationError &&
      error.code === "session-auto-name-timeout",
  );
});
