import assert from "node:assert/strict";
import { mkdir, mkdtemp, readdir, realpath, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";

import { SessionManager } from "@earendil-works/pi-coding-agent";

import { PiNodeDomainError } from "../src/pi-node-domain.js";
import { PiNodeDomainService } from "../src/pi-node-domain-service.js";
import {
  normalizePiSdkMessage,
  PublicPiSdkDomainSessionFactory,
} from "../src/pi-sdk-domain-session.js";
import { ProjectTrustCoordinator } from "../src/project-trust.js";

test("SDK messages are copied into Pi Client-owned normalized values", () => {
  const raw = {
    role: "assistant",
    provider: "provider",
    model: "model",
    stopReason: "toolUse",
    timestamp: 42,
    usage: {
      input: 1,
      output: 2,
      cacheRead: 3,
      cacheWrite: 4,
      totalTokens: 10,
      cost: { total: 0.25 },
    },
    content: [
      { type: "text", text: "hello" },
      { type: "thinking", thinking: "hidden", redacted: true },
      {
        type: "toolCall",
        id: "tool-1",
        name: "read",
        arguments: { path: "/tmp/file", nested: { value: 1 } },
      },
    ],
  };

  const normalized = normalizePiSdkMessage(raw, "message-1", () => 99);
  (raw.content[0] as { text: string }).text = "mutated";
  (raw.content[2] as { arguments: { nested: { value: number } } }).arguments.nested.value = 2;

  assert.equal(normalized.id, "message-1");
  assert.equal(normalized.role, "assistant");
  assert.deepEqual(normalized.parts, [
    { type: "text", text: "hello" },
    { type: "thinking", text: "", redacted: true },
    {
      type: "tool-call",
      id: "tool-1",
      name: "read",
      arguments: { nested: { value: 1 }, path: "/tmp/file" },
    },
  ]);
  assert.deepEqual(normalized.assistant?.usage, {
    inputTokens: 1,
    outputTokens: 2,
    cacheReadTokens: 3,
    cacheWriteTokens: 4,
    totalTokens: 10,
    totalCost: 0.25,
  });
  assert.equal("raw" in normalized, false);
  assert.equal("sdk" in normalized, false);
});

test("the real public SDK adapter lists and loads persistent sessions fully offline", async (t) => {
  const root = await mkdtemp(join(tmpdir(), "pi-client-domain-sdk-"));
  const cwd = join(root, "project");
  const agentDir = join(root, "agent");
  const sessionDir = join(root, "sessions");
  await Promise.all([mkdir(cwd), mkdir(agentDir), mkdir(sessionDir)]);
  const canonicalCwd = await realpath(cwd);
  await writeFile(
    join(agentDir, "settings.json"),
    `${JSON.stringify({ sessionDir, enableAnalytics: false })}\n`,
    "utf8",
  );

  const sessionManager = SessionManager.create(canonicalCwd, sessionDir, { id: "offline-session" });
  sessionManager.appendMessage({
    role: "user",
    content: [{ type: "text", text: "offline question" }],
    timestamp: 1,
  });
  sessionManager.appendMessage({
    role: "assistant",
    content: [{ type: "text", text: "offline answer" }],
    api: "anthropic-messages",
    provider: "anthropic",
    model: "offline-model",
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
  const secondUserEntryId = sessionManager.appendMessage({
    role: "user",
    content: [{ type: "text", text: "offline follow-up" }],
    timestamp: 3,
  });
  const originalFetch = globalThis.fetch;
  let fetchCalls = 0;
  globalThis.fetch = (async () => {
    fetchCalls += 1;
    throw new Error("Network access is forbidden in the offline SDK smoke test.");
  }) as typeof fetch;
  t.after(async () => {
    globalThis.fetch = originalFetch;
    await rm(root, { recursive: true, force: true });
  });

  const service = new PiNodeDomainService({
    agentDir,
    trustCoordinator: new ProjectTrustCoordinator(),
    sessionFactory: new PublicPiSdkDomainSessionFactory({ clock: () => 50 }),
    maxOpenSessions: 2,
  });
  t.after(() => service.dispose());

  const listed = await service.listPersistentSessions({ cwd: canonicalCwd });
  assert.equal(listed.length, 1);
  assert.equal(listed[0]?.sessionId, "offline-session");
  assert.equal(listed[0]?.firstMessage, "offline question");
  await assert.rejects(
    service.loadSessionSnapshot({ cwd: canonicalCwd, sessionId: "missing-session" }),
    (error) => error instanceof PiNodeDomainError && error.code === "session-not-found",
  );

  const loaded = await service.loadSessionSnapshot({
    cwd: canonicalCwd,
    sessionId: "offline-session",
  });
  assert.equal(loaded.persistence, "persistent");
  assert.equal(loaded.messages.length, 3);
  assert.deepEqual(
    loaded.messages.map((message) => message.parts[0]),
    [
      { type: "text", text: "offline question" },
      { type: "text", text: "offline answer" },
      { type: "text", text: "offline follow-up" },
    ],
  );

  const created = await service.createPersistentSession({ cwd: canonicalCwd });
  assert.equal(created.persistence, "persistent");
  assert.equal(created.cwd, canonicalCwd);
  assert.equal(created.messages.length, 0);
  const createdTree = await service.getLoadedSessionTree({
    cwd: canonicalCwd,
    sessionId: created.sessionId,
  });
  await assert.rejects(
    service.cloneSessionActiveBranch({
      cwd: canonicalCwd,
      sessionId: created.sessionId,
      expectedAdminRevision: createdTree.adminRevision,
    }),
    (error) => error instanceof PiNodeDomainError && error.code === "session-clone-ineligible",
  );

  const admission = await service.submitPrompt({
    sessionId: "offline-session",
    commandId: "offline-command",
    text: "must reject before provider transport",
  });
  assert.equal(admission.status, "rejected");
  assert.ok(
    admission.failure?.code === "model-unavailable" ||
      admission.failure?.code === "provider-auth-required",
  );
  assert.equal(fetchCalls, 0);

  const initialTree = await service.getLoadedSessionTree({
    cwd: canonicalCwd,
    sessionId: "offline-session",
  });
  assert.ok(initialTree.nodes.length >= 3);
  assert.ok(initialTree.nodes.some((node) => node.entryId === secondUserEntryId));

  await assert.rejects(
    service.navigateSessionTree({
      cwd: canonicalCwd,
      sessionId: "offline-session",
      entryId: secondUserEntryId,
      expectedAdminRevision: "stale-revision",
    }),
    (error) => error instanceof PiNodeDomainError && error.code === "session-mutation-conflict",
  );

  const filesBeforeNavigate = (await readdir(sessionDir)).filter((name) => name.endsWith(".jsonl"));
  const navigated = await service.navigateSessionTree({
    cwd: canonicalCwd,
    sessionId: "offline-session",
    entryId: secondUserEntryId,
    expectedAdminRevision: initialTree.adminRevision,
  });
  assert.equal(navigated.session.sessionId, "offline-session");
  assert.equal(navigated.editorText, "offline follow-up");
  assert.equal(navigated.session.messages.length, 2);
  assert.deepEqual(
    (await readdir(sessionDir)).filter((name) => name.endsWith(".jsonl")),
    filesBeforeNavigate,
  );

  const forked = await service.forkSessionFromUserEntry({
    cwd: canonicalCwd,
    sessionId: "offline-session",
    userEntryId: secondUserEntryId,
    expectedAdminRevision: navigated.tree.adminRevision,
  });
  assert.notEqual(forked.session.sessionId, "offline-session");
  assert.equal(forked.session.parentSessionId, "offline-session");
  assert.equal(forked.editorText, "offline follow-up");
  assert.throws(
    () => service.getLoadedSessionSnapshot("offline-session"),
    (error) => error instanceof PiNodeDomainError && error.code === "session-not-loaded",
  );

  const cloned = await service.cloneSessionActiveBranch({
    cwd: canonicalCwd,
    sessionId: forked.session.sessionId,
    expectedAdminRevision: forked.tree.adminRevision,
  });
  assert.notEqual(cloned.session.sessionId, forked.session.sessionId);
  assert.equal(cloned.session.parentSessionId, forked.session.sessionId);
  assert.throws(
    () => service.getLoadedSessionSnapshot(forked.session.sessionId),
    (error) => error instanceof PiNodeDomainError && error.code === "session-not-loaded",
  );
  const family = await service.listPersistentSessions({ cwd: canonicalCwd });
  const forkSummary = family.find((session) => session.sessionId === forked.session.sessionId);
  const cloneSummary = family.find((session) => session.sessionId === cloned.session.sessionId);
  assert.equal(forkSummary?.parentSessionId, "offline-session");
  assert.equal(cloneSummary?.parentSessionId, forked.session.sessionId);
});
