import { writeFile } from "node:fs/promises";
import type { Writable } from "node:stream";
import { setTimeout as delay } from "node:timers/promises";

import { IpcLengthPrefixDecoder, encodeIpcLengthPrefixedFrame } from "@pi-client/protocol";

import type {
  PiNodeAbortResult,
  PiNodeDirectoryListing,
  PiNodeKnownProjectSnapshot,
  PiNodeMessage,
  PiNodeProjectBootstrap,
  PiNodeProjectSnapshot,
  PiNodePromptAdmission,
  PiNodeProtocolDomain,
  PiNodeSessionEvent,
  PiNodeSessionEventListener,
  PiNodeSessionExportFormat,
  PiNodeSessionHistoryPage,
  PiNodeSessionObservation,
  PiNodeSessionSnapshot,
  PiNodeSessionStats,
  PiNodeSessionSummary,
  PiNodeSessionTreeMutationResult,
  PiNodeSessionTreeSnapshot,
} from "../../src/index.js";

interface FixtureOptions {
  readonly cwd: string;
  readonly evidenceFile?: string;
  readonly mode: "normal" | "exit-on-prompt" | "large-export";
}

interface FramingEvidence {
  readonly prefixBytes: 4;
  readonly splitWriteCount: number;
  readonly coalescedBatchCount: number;
  readonly maxFramesPerWrite: number;
  readonly stderrBytes: number;
}

async function main(): Promise<void> {
  const options = parseOptions(process.argv.slice(2));
  const pressure = Buffer.alloc(512 * 1024, 0x78);
  await writeBytes(process.stderr, pressure);

  const productionModuleUrl = new URL("../../dist/index.js", import.meta.url).href;
  const production = (await import(productionModuleUrl)) as typeof import("../../src/index.js");
  const writer = new DeterministicFrameWriter(process.stdout, pressure.length);
  const domain = new FixtureProtocolDomain(options.cwd, options.mode);
  const connection = new production.PiNodeProtobufConnection({
    domain,
    implementationVersion: "0.1.0-dev.0",
    nodeInstanceId: "flutter-cross-process-fixture",
    streamIdFactory: (_sessionId, ordinal) => `flutter-e2e-stream-${ordinal}`,
    logger: {
      info: (code) => process.stderr.write(`[pi-client-node-fixture] ${code}\n`),
      error: (code) => process.stderr.write(`[pi-client-node-fixture] ${code}\n`),
    },
    writeFrame: (payload) => writer.enqueue(payload),
  });
  const decoder = new IpcLengthPrefixDecoder();
  let exitCode = 0;

  try {
    input: for await (const chunk of process.stdin) {
      for (const payload of decoder.push(chunk)) {
        const result = await connection.receive(payload);
        await writer.drain();
        if (result.close) {
          exitCode =
            result.reason === "handshake-rejected" || result.reason === "protocol-error" ? 2 : 1;
          process.stdin.destroy();
          break input;
        }
      }
    }
    if (exitCode === 0) {
      decoder.finish();
    }
  } catch {
    exitCode = 1;
  } finally {
    await connection.dispose();
    await writer.drain();
    if (options.evidenceFile) {
      await writeFile(options.evidenceFile, `${JSON.stringify(writer.evidence)}\n`, "utf8");
    }
  }

  process.exitCode = exitCode;
}

class FixtureProtocolDomain implements PiNodeProtocolDomain {
  readonly #sessions = new Map<string, PiNodeSessionSnapshot>();
  readonly #listeners = new Map<string, Set<PiNodeSessionEventListener>>();
  readonly #eventSequences = new Map<string, number>();
  readonly #activeCommands = new Map<string, string>();
  readonly #cwd: string;
  readonly #mode: FixtureOptions["mode"];
  #createOrdinal = 0;

  constructor(cwd: string, mode: FixtureOptions["mode"]) {
    this.#cwd = cwd;
    this.#mode = mode;
    const initial = sessionSnapshot("fixture-session", cwd, "Fixture session");
    this.#sessions.set(initial.sessionId, initial);
  }

  getProjectBootstrap(): Promise<PiNodeProjectBootstrap> {
    return Promise.resolve({
      homeDirectory: this.#cwd,
      defaultProject: projectSnapshot(this.#cwd),
    });
  }

  browseDirectory(input: { readonly directory: string }): Promise<PiNodeDirectoryListing> {
    return Promise.resolve({
      canonicalDirectory: input.directory,
      children: [],
      truncated: false,
    });
  }

  validateProject(input: { readonly candidateDirectory: string }): Promise<PiNodeProjectSnapshot> {
    return Promise.resolve(projectSnapshot(input.candidateDirectory));
  }

  listKnownProjects(): Promise<readonly PiNodeKnownProjectSnapshot[]> {
    return Promise.resolve([
      {
        project: projectSnapshot(this.#cwd),
        lastSessionAtMs: 1_767_268_860_000,
        sessionCount: 1,
      },
    ]);
  }

  approveProjectTrust(input: { readonly canonicalCwd: string }): Promise<PiNodeProjectSnapshot> {
    return Promise.resolve(projectSnapshot(input.canonicalCwd));
  }

  listSessions(): Promise<readonly PiNodeSessionSummary[]> {
    return Promise.resolve([...this.#sessions.values()].map(copySummary));
  }

  getSession(input: { readonly sessionId: string }): Promise<PiNodeSessionSnapshot> {
    return Promise.resolve(copySnapshot(this.#requireSession(input.sessionId)));
  }

  getSessionHistory(input: {
    readonly sessionId: string;
    readonly cursor?: string;
    readonly limit: number;
  }): Promise<PiNodeSessionHistoryPage> {
    const session = this.#requireSession(input.sessionId);
    const end = input.cursor === undefined ? session.messages.length : Number(input.cursor);
    const start = Math.max(0, end - input.limit);
    return Promise.resolve({
      summary: copySummary(session),
      messages: structuredClone(session.messages.slice(start, end)),
      ...(start > 0 ? { nextCursor: String(start) } : {}),
      hasMore: start > 0,
      activeBranchRevision: `active-${session.adminRevision}`,
      treeRevision: session.adminRevision,
      lastEventSequence: session.lastEventSequence,
    });
  }

  getSessionStats(input: { readonly sessionId: string }): Promise<PiNodeSessionStats> {
    const session = this.#requireSession(input.sessionId);
    const project = projectSnapshot(session.cwd);
    return Promise.resolve({
      projection: {
        sessionFileName: `${session.sessionId}.jsonl`,
        sessionId: session.sessionId,
        projectId: project.identity.projectId,
        canonicalProjectDirectory: session.cwd,
        worktreeId: project.identity.worktreeId,
        mainProjectId: project.identity.mainProjectId,
        isLinkedWorktree: false,
        isDetachedHead: false,
      },
      userMessages: session.messages.filter((item) => item.role === "user").length,
      assistantMessages: session.messages.filter((item) => item.role === "assistant").length,
      toolCalls: 0,
      toolResults: session.messages.filter((item) => item.role === "tool").length,
      totalMessages: session.messages.length,
      inputTokens: 1,
      outputTokens: 2,
      cacheReadTokens: 0,
      cacheWriteTokens: 0,
      totalTokens: 3,
      cost: 0,
      contextTokens: 3,
      contextWindow: 200000,
      contextPercent: 0.0015,
      activeTimeMillis: 100,
    });
  }

  async exportSession(input: {
    readonly sessionId: string;
    readonly format: PiNodeSessionExportFormat;
    readonly outputPath: string;
  }): Promise<void> {
    const session = this.#requireSession(input.sessionId);
    const payload =
      this.#mode === "large-export"
        ? Buffer.alloc(2 * 1024 * 1024 + 17, input.format === "html" ? 0x68 : 0x6a)
        : input.format === "html"
          ? `<html><body>${session.messages.length}</body></html>`
          : `${JSON.stringify({ type: "session", id: session.sessionId })}\n`;
    await writeFile(input.outputPath, payload, { mode: 0o600 });
  }

  createSession(input: { readonly cwd: string }): Promise<PiNodeSessionSnapshot> {
    const session = sessionSnapshot(
      `fixture-created-${++this.#createOrdinal}`,
      input.cwd,
      `Fixture created ${this.#createOrdinal}`,
      [],
    );
    this.#sessions.set(session.sessionId, session);
    return Promise.resolve(copySnapshot(session));
  }

  getSessionTree(input: { readonly sessionId: string }): Promise<PiNodeSessionTreeSnapshot> {
    return Promise.resolve(treeSnapshot(this.#requireSession(input.sessionId)));
  }

  navigateSessionTree(input: {
    readonly sessionId: string;
    readonly entryId: string;
  }): Promise<PiNodeSessionTreeMutationResult> {
    const session = this.#requireSession(input.sessionId);
    const node = treeSnapshot(session).nodes.find(
      (candidate) => candidate.entryId === input.entryId,
    );
    if (!node) return Promise.reject(new Error("Missing fixture tree entry."));
    return Promise.resolve({
      previousSessionId: session.sessionId,
      session: copySnapshot(session),
      tree: treeSnapshot(session),
      ...(node.canEditFromHere ? { editorText: node.text } : {}),
    });
  }

  forkSession(input: {
    readonly sessionId: string;
    readonly userEntryId: string;
  }): Promise<PiNodeSessionTreeMutationResult> {
    const source = this.#requireSession(input.sessionId);
    const selected = treeSnapshot(source).nodes.find(
      (node) => node.entryId === input.userEntryId && node.canFork,
    );
    if (!selected) return Promise.reject(new Error("Missing fixture fork entry."));
    const forked = sessionSnapshot(
      `fixture-forked-${++this.#createOrdinal}`,
      source.cwd,
      `Fixture forked ${this.#createOrdinal}`,
      source.messages.filter((message) => message.id !== selected.entryId),
      source.sessionId,
    );
    this.#sessions.set(forked.sessionId, forked);
    return Promise.resolve({
      previousSessionId: source.sessionId,
      session: copySnapshot(forked),
      tree: treeSnapshot(forked),
      editorText: selected.text,
    });
  }

  cloneSession(input: { readonly sessionId: string }): Promise<PiNodeSessionTreeMutationResult> {
    const source = this.#requireSession(input.sessionId);
    const cloned = sessionSnapshot(
      `fixture-cloned-${++this.#createOrdinal}`,
      source.cwd,
      `Fixture cloned ${this.#createOrdinal}`,
      source.messages,
      source.sessionId,
    );
    this.#sessions.set(cloned.sessionId, cloned);
    return Promise.resolve({
      previousSessionId: source.sessionId,
      session: copySnapshot(cloned),
      tree: treeSnapshot(cloned),
    });
  }

  observeSession(
    sessionId: string,
    listener: PiNodeSessionEventListener,
  ): PiNodeSessionObservation {
    const session = this.#requireSession(sessionId);
    const listeners = this.#listeners.get(sessionId) ?? new Set<PiNodeSessionEventListener>();
    listeners.add(listener);
    this.#listeners.set(sessionId, listeners);
    let subscribed = true;
    return {
      snapshot: copySnapshot(session),
      unsubscribe: () => {
        if (!subscribed) {
          return;
        }
        subscribed = false;
        listeners.delete(listener);
      },
    };
  }

  submitPrompt(input: {
    readonly sessionId: string;
    readonly commandId: string;
    readonly text: string;
  }): Promise<PiNodePromptAdmission> {
    const session = this.#requireSession(input.sessionId);
    if (input.text === "reject") {
      return Promise.resolve({
        sessionId: input.sessionId,
        commandId: input.commandId,
        status: "rejected",
        failure: { code: "invalid-prompt", message: "The fixture rejected the prompt." },
      });
    }
    if (input.text === "uncertain") {
      return Promise.resolve({
        sessionId: input.sessionId,
        commandId: input.commandId,
        status: "uncertain",
        failure: { code: "session-busy", message: "The fixture cannot confirm admission." },
      });
    }
    if (input.text === "disconnect" && this.#mode === "exit-on-prompt") {
      setTimeout(() => process.exit(23), 10);
      return new Promise<PiNodePromptAdmission>(() => undefined);
    }

    this.#activeCommands.set(input.sessionId, input.commandId);
    this.#emit(input.sessionId, {
      type: "running",
      running: true,
      commandId: input.commandId,
    });
    const started = message(`${input.commandId}:assistant`, "Working", "assistant");
    this.#emit(input.sessionId, { type: "message", phase: "started", message: started });
    this.#emit(input.sessionId, {
      type: "message",
      phase: "updated",
      message: message(started.id, "Working now", "assistant"),
    });
    this.#sessions.set(input.sessionId, { ...session, running: true });
    return Promise.resolve({
      sessionId: input.sessionId,
      commandId: input.commandId,
      status: "accepted",
    });
  }

  renameSession(input: {
    readonly sessionId: string;
    readonly name: string;
  }): Promise<PiNodeSessionSummary> {
    const session = this.#requireSession(input.sessionId);
    const updated = updateSessionName(session, input.name);
    this.#sessions.set(input.sessionId, updated);
    return Promise.resolve(copySummary(updated));
  }

  clearSessionName(input: { readonly sessionId: string }): Promise<PiNodeSessionSummary> {
    const session = this.#requireSession(input.sessionId);
    const updated = updateSessionName(session, undefined);
    this.#sessions.set(input.sessionId, updated);
    return Promise.resolve(copySummary(updated));
  }

  autoNameSession(input: { readonly sessionId: string }): Promise<PiNodeSessionSummary> {
    const session = this.#requireSession(input.sessionId);
    const updated = updateSessionName(session, "Generated fixture title");
    this.#sessions.set(input.sessionId, updated);
    return Promise.resolve(copySummary(updated));
  }

  deleteSession(input: {
    readonly sessionId: string;
    readonly confirmation: {
      readonly sessionId: string;
      readonly adminRevision: string;
      readonly destructiveActionAcknowledged: boolean;
    };
  }): Promise<{ readonly sessionId: string; readonly reparentedChildCount: number }> {
    const session = this.#requireSession(input.sessionId);
    if (
      !input.confirmation.destructiveActionAcknowledged ||
      input.confirmation.sessionId !== input.sessionId ||
      input.confirmation.adminRevision !== session.adminRevision
    ) {
      return Promise.reject(new Error("Stale fixture deletion confirmation."));
    }
    this.#sessions.delete(input.sessionId);
    return Promise.resolve({ sessionId: input.sessionId, reparentedChildCount: 0 });
  }

  abort(input: { readonly sessionId: string }): Promise<PiNodeAbortResult> {
    const session = this.#requireSession(input.sessionId);
    const activeCommand = this.#activeCommands.get(input.sessionId);
    if (!activeCommand) {
      return Promise.resolve({ status: "not-running", sessionId: input.sessionId });
    }
    this.#activeCommands.delete(input.sessionId);
    this.#emit(input.sessionId, {
      type: "running",
      running: false,
      commandId: activeCommand,
    });
    this.#emit(input.sessionId, {
      type: "command-completed",
      commandId: activeCommand,
      outcome: "aborted",
      failure: { code: "aborted", message: "Fixture detail must stay redacted." },
    });
    this.#sessions.set(input.sessionId, { ...session, running: false });
    return Promise.resolve({
      status: "requested",
      sessionId: input.sessionId,
      commandId: activeCommand,
    });
  }

  #emit(
    sessionId: string,
    payload: PiNodeSessionEvent extends infer Event
      ? Event extends {
          readonly sessionId: string;
          readonly sequence: number;
          readonly emittedAtMs: number;
        }
        ? Omit<Event, "sessionId" | "sequence" | "emittedAtMs">
        : never
      : never,
  ): void {
    const sequence = (this.#eventSequences.get(sessionId) ?? 0) + 1;
    this.#eventSequences.set(sessionId, sequence);
    const event = {
      ...payload,
      sessionId,
      sequence,
      emittedAtMs: 1_767_268_800_000 + sequence,
    } as PiNodeSessionEvent;
    for (const listener of [...(this.#listeners.get(sessionId) ?? [])]) {
      listener(event);
    }
  }

  #requireSession(sessionId: string): PiNodeSessionSnapshot {
    const session = this.#sessions.get(sessionId);
    if (!session) {
      throw new Error("The fixture session does not exist.");
    }
    return session;
  }
}

class DeterministicFrameWriter {
  readonly #output: Writable;
  readonly #pending: Uint8Array[] = [];
  readonly #stderrBytes: number;
  #scheduled: Promise<void> | undefined;
  #firstBatch = true;
  #splitWriteCount = 0;
  #coalescedBatchCount = 0;
  #maxFramesPerWrite = 0;

  constructor(output: Writable, stderrBytes: number) {
    this.#output = output;
    this.#stderrBytes = stderrBytes;
  }

  get evidence(): FramingEvidence {
    return {
      prefixBytes: 4,
      splitWriteCount: this.#splitWriteCount,
      coalescedBatchCount: this.#coalescedBatchCount,
      maxFramesPerWrite: this.#maxFramesPerWrite,
      stderrBytes: this.#stderrBytes,
    };
  }

  enqueue(payload: Uint8Array): void {
    this.#pending.push(encodeIpcLengthPrefixedFrame(payload));
    this.#schedule();
  }

  async drain(): Promise<void> {
    while (this.#scheduled) {
      await this.#scheduled;
    }
  }

  #schedule(): void {
    if (this.#scheduled) {
      return;
    }
    this.#scheduled = new Promise<void>((resolve, reject) => {
      setImmediate(() => {
        this.#flush().then(resolve, reject);
      });
    }).finally(() => {
      this.#scheduled = undefined;
      if (this.#pending.length > 0) {
        this.#schedule();
      }
    });
  }

  async #flush(): Promise<void> {
    const batch = this.#pending.splice(0);
    if (batch.length === 0) {
      return;
    }
    this.#maxFramesPerWrite = Math.max(this.#maxFramesPerWrite, batch.length);
    const bytes = Buffer.concat(batch.map((frame) => Buffer.from(frame)));
    if (this.#firstBatch) {
      this.#firstBatch = false;
      for (const part of [bytes.subarray(0, 2), bytes.subarray(2, 7), bytes.subarray(7)]) {
        await writeBytes(this.#output, part);
        this.#splitWriteCount += 1;
        await delay(2);
      }
      return;
    }
    if (batch.length > 1) {
      this.#coalescedBatchCount += 1;
    }
    await writeBytes(this.#output, bytes);
  }
}

function parseOptions(arguments_: readonly string[]): FixtureOptions {
  let cwd: string | undefined;
  let evidenceFile: string | undefined;
  let mode: FixtureOptions["mode"] = "normal";
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (argument === "--cwd") {
      cwd = requireValue(arguments_, ++index);
      continue;
    }
    if (argument === "--evidence-file") {
      evidenceFile = requireValue(arguments_, ++index);
      continue;
    }
    if (argument === "--mode") {
      const value = requireValue(arguments_, ++index);
      if (value !== "normal" && value !== "exit-on-prompt" && value !== "large-export") {
        throw new Error("Unsupported fixture mode.");
      }
      mode = value;
      continue;
    }
    throw new Error("Unsupported fixture option.");
  }
  if (!cwd) {
    throw new Error("The fixture requires --cwd.");
  }
  return { cwd, ...(evidenceFile === undefined ? {} : { evidenceFile }), mode };
}

function requireValue(arguments_: readonly string[], index: number): string {
  const value = arguments_[index];
  if (!value?.trim()) {
    throw new Error("A fixture option is missing its value.");
  }
  return value;
}

function projectSnapshot(canonicalCwd: string): PiNodeProjectSnapshot {
  return {
    identity: {
      projectId: "fixture-project",
      canonicalCwd,
      isGitRepository: false,
      isLinkedWorktree: false,
      isDetachedHead: false,
      worktreeId: "fixture-worktree",
      mainProjectId: "fixture-main-project",
    },
    trust: {
      status: "not-required",
      reasons: [],
      revision: "fixture-trust-revision",
    },
  };
}

function sessionSnapshot(
  sessionId: string,
  cwd: string,
  title: string,
  messages: readonly PiNodeMessage[] = [message(`${sessionId}:user`, "Hello", "user")],
  parentSessionId?: string,
): PiNodeSessionSnapshot {
  return {
    sessionId,
    cwd,
    name: title,
    ...(parentSessionId === undefined ? {} : { parentSessionId }),
    createdAtMs: 1_767_268_800_000,
    modifiedAtMs: 1_767_268_860_000,
    messageCount: messages.length,
    firstMessage: messages[0]?.parts[0]?.type === "text" ? messages[0].parts[0].text : title,
    running: false,
    adminRevision: `fixture-revision-${sessionId}-1`,
    persistence: "persistent",
    messages,
    lastEventSequence: 0,
  };
}

function message(id: string, text: string, role: PiNodeMessage["role"]): PiNodeMessage {
  return {
    id,
    role,
    sourceRole: role,
    timestampMs: 1_767_268_800_000,
    parts: [{ type: "text", text }],
  };
}

function copySummary(snapshot: PiNodeSessionSnapshot): PiNodeSessionSummary {
  return {
    sessionId: snapshot.sessionId,
    cwd: snapshot.cwd,
    ...(snapshot.name === undefined ? {} : { name: snapshot.name }),
    ...(snapshot.parentSessionId === undefined
      ? {}
      : { parentSessionId: snapshot.parentSessionId }),
    createdAtMs: snapshot.createdAtMs,
    modifiedAtMs: snapshot.modifiedAtMs,
    messageCount: snapshot.messageCount,
    firstMessage: snapshot.firstMessage,
    running: snapshot.running,
    adminRevision: snapshot.adminRevision,
  };
}

function updateSessionName(
  session: PiNodeSessionSnapshot,
  name: string | undefined,
): PiNodeSessionSnapshot {
  const modifiedAtMs = session.modifiedAtMs + 1;
  const updated = {
    ...session,
    modifiedAtMs,
    adminRevision: `fixture-revision-${session.sessionId}-${modifiedAtMs}-${name ?? "clear"}`,
  };
  if (name === undefined) {
    const { name: _discarded, ...withoutName } = updated;
    return withoutName;
  }
  return { ...updated, name };
}

function treeSnapshot(session: PiNodeSessionSnapshot): PiNodeSessionTreeSnapshot {
  const nodes = session.messages.map((item, index) => ({
    entryId: item.id,
    ...(index === 0 ? {} : { parentEntryId: session.messages[index - 1]!.id }),
    kind: item.role === "user" ? ("user-message" as const) : ("assistant-message" as const),
    text: item.parts[0]?.type === "text" ? item.parts[0].text : "",
    createdAtMs: item.timestampMs,
    depth: index,
    isOnActivePath: true,
    hasChildren: index + 1 < session.messages.length,
    canEditFromHere: item.role === "user",
    canFork: item.role === "user",
  }));
  return {
    sessionId: session.sessionId,
    nodes,
    activePathEntryIds: nodes.map((node) => node.entryId),
    ...(nodes.at(-1) === undefined ? {} : { activeLeafEntryId: nodes.at(-1)!.entryId }),
    canCloneActiveBranch: nodes.some((node) => node.canFork),
    adminRevision: session.adminRevision,
  };
}

function copySnapshot(snapshot: PiNodeSessionSnapshot): PiNodeSessionSnapshot {
  return structuredClone(snapshot);
}

function writeBytes(output: Writable, bytes: Uint8Array): Promise<void> {
  return new Promise((resolve, reject) => {
    output.write(bytes, (error) => {
      if (error) {
        reject(new Error("Fixture output failed."));
      } else {
        resolve();
      }
    });
  });
}

try {
  await main();
} catch {
  process.stderr.write("[pi-client-node-fixture] fixture-failed\n");
  process.exitCode = 1;
}
