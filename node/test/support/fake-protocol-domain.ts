import { writeFile } from "node:fs/promises";

import type {
  PiNodeAbortResult,
  PiNodeConversationEntry,
  PiNodeDirectoryListing,
  PiNodeKnownProjectSnapshot,
  PiNodeMessageContent,
  PiNodeMessageContentRequest,
  PiNodeProjectBootstrap,
  PiNodeProjectSnapshot,
  PiNodePromptAdmission,
  PiNodeSessionEvent,
  PiNodeSessionEventListener,
  PiNodeSessionExportFormat,
  PiNodeSessionHistoryPage,
  PiNodeSessionSnapshot,
  PiNodeSessionStats,
  PiNodeSessionSummary,
  PiNodeSessionTreeMutationResult,
  PiNodeSessionTreeSnapshot,
} from "../../src/pi-node-domain.js";
import type { PiNodeSessionObservation } from "../../src/pi-node-domain-service.js";
import type { PiNodeProtocolDomain } from "../../src/protocol/pi-node-protocol-domain-port.js";

const defaultCwd = "/project";

export class FakeProtocolDomain implements PiNodeProtocolDomain {
  readonly sessions = new Map<string, PiNodeSessionSnapshot>();
  readonly listeners = new Map<string, Set<PiNodeSessionEventListener>>();
  readonly eventSequences = new Map<string, number>();
  readonly activeCommands = new Map<string, string>();
  readonly observedCount = new Map<string, number>();
  readonly unsubscribedCount = new Map<string, number>();

  listError: unknown;
  createOrdinal = 0;
  emitOnObserve = false;
  exportPayload: string | Uint8Array | undefined;
  lastExportPath: string | undefined;
  promptAdmission: PiNodePromptAdmission["status"] = "accepted";

  constructor() {
    this.sessions.set("session-1", sessionSnapshot("session-1", defaultCwd, "Existing session"));
  }

  getProjectBootstrap(): Promise<PiNodeProjectBootstrap> {
    return Promise.resolve({
      homeDirectory: "/home/test",
      defaultProject: projectSnapshot(defaultCwd),
    });
  }

  browseDirectory(input: { readonly directory: string }): Promise<PiNodeDirectoryListing> {
    return Promise.resolve({
      canonicalDirectory: input.directory,
      parentDirectory: "/",
      children: [],
      truncated: false,
    });
  }

  validateProject(input: { readonly candidateDirectory: string }): Promise<PiNodeProjectSnapshot> {
    return Promise.resolve(projectSnapshot(input.candidateDirectory));
  }

  listKnownProjects(): Promise<readonly PiNodeKnownProjectSnapshot[]> {
    return Promise.resolve([
      { project: projectSnapshot(defaultCwd), lastSessionAtMs: 200, sessionCount: 1 },
    ]);
  }

  approveProjectTrust(input: { readonly canonicalCwd: string }): Promise<PiNodeProjectSnapshot> {
    return Promise.resolve(projectSnapshot(input.canonicalCwd, "trusted"));
  }

  listSessions(): Promise<readonly PiNodeSessionSummary[]> {
    if (this.listError !== undefined) return Promise.reject(this.listError);
    return Promise.resolve([...this.sessions.values()].map(copySummary));
  }

  getSession(input: { readonly sessionId: string }): Promise<PiNodeSessionSnapshot> {
    return Promise.resolve(copySnapshot(this.requireSession(input.sessionId)));
  }

  getSessionHistory(input: {
    readonly sessionId: string;
    readonly cursor?: string;
    readonly limit: number;
  }): Promise<PiNodeSessionHistoryPage> {
    const session = this.requireSession(input.sessionId);
    const all = session.conversation.entries;
    const end = input.cursor === undefined ? all.length : Number(input.cursor);
    const start = Math.max(0, end - input.limit);
    return Promise.resolve({
      summary: copySummary(session),
      conversation: {
        sessionId: session.sessionId,
        entries: structuredClone(all.slice(start, end)),
        ...(start > 0 ? { nextCursor: String(start) } : {}),
        hasMore: start > 0,
        activeBranchRevision: `active-${session.adminRevision}`,
        treeRevision: session.adminRevision,
        lastEventSequence: session.conversation.lastEventSequence,
      },
    });
  }

  getMessageContent(_input: {
    readonly cwd: string;
    readonly request: PiNodeMessageContentRequest;
  }): Promise<PiNodeMessageContent> {
    return Promise.reject(new Error("The fake session does not contain referenced content."));
  }

  getSessionStats(input: { readonly sessionId: string }): Promise<PiNodeSessionStats> {
    const session = this.requireSession(input.sessionId);
    const entries = session.conversation.entries;
    return Promise.resolve({
      projection: {
        sessionFileName: `${session.sessionId}.jsonl`,
        sessionId: session.sessionId,
        projectId: projectSnapshot(session.cwd).identity.projectId,
        canonicalProjectDirectory: session.cwd,
        worktreeId: projectSnapshot(session.cwd).identity.worktreeId,
        mainProjectId: projectSnapshot(session.cwd).identity.mainProjectId,
        isLinkedWorktree: false,
        isDetachedHead: false,
      },
      userMessages: entries.filter((item) => item.type === "user").length,
      assistantMessages: entries.filter((item) => item.type === "assistant").length,
      toolCalls: entries.flatMap((item) => item.parts).filter((part) => part.type === "tool-call")
        .length,
      toolResults: entries.filter((item) => item.type === "tool-result").length,
      totalMessages: entries.length,
      inputTokens: 10,
      outputTokens: 20,
      cacheReadTokens: 3,
      cacheWriteTokens: 4,
      totalTokens: 37,
      cost: 0.01,
      contextTokens: 37,
      contextWindow: 200000,
      contextPercent: 0.0185,
      activeTimeMillis: 100,
    });
  }

  async exportSession(input: {
    readonly sessionId: string;
    readonly format: PiNodeSessionExportFormat;
    readonly outputPath: string;
  }): Promise<void> {
    const session = this.requireSession(input.sessionId);
    const payload =
      this.exportPayload ??
      (input.format === "html"
        ? `<html><body>${session.conversation.entries.length}</body></html>`
        : `${JSON.stringify({ type: "session", id: session.sessionId })}\n`);
    this.lastExportPath = input.outputPath;
    await writeFile(input.outputPath, payload, { mode: 0o600 });
  }

  createSession(input: { readonly cwd: string }): Promise<PiNodeSessionSnapshot> {
    const session = sessionSnapshot(
      `created-${++this.createOrdinal}`,
      input.cwd,
      `Created ${this.createOrdinal}`,
      [],
    );
    this.sessions.set(session.sessionId, session);
    return Promise.resolve(copySnapshot(session));
  }

  getSessionTree(input: { readonly sessionId: string }): Promise<PiNodeSessionTreeSnapshot> {
    return Promise.resolve(treeSnapshot(this.requireSession(input.sessionId)));
  }

  navigateSessionTree(input: {
    readonly sessionId: string;
    readonly entryId: string;
  }): Promise<PiNodeSessionTreeMutationResult> {
    const session = this.requireSession(input.sessionId);
    const node = treeSnapshot(session).nodes.find(
      (candidate) => candidate.entryId === input.entryId,
    );
    if (!node) return Promise.reject(new Error("Missing fake tree entry."));
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
    const source = this.requireSession(input.sessionId);
    const selected = treeSnapshot(source).nodes.find(
      (node) => node.entryId === input.userEntryId && node.canFork,
    );
    if (!selected) return Promise.reject(new Error("Missing fake fork entry."));
    const forked = sessionSnapshot(
      `forked-${++this.createOrdinal}`,
      source.cwd,
      `Forked ${this.createOrdinal}`,
      source.conversation.entries.filter((entry) => entry.identity.entryId !== selected.entryId),
      source.sessionId,
    );
    this.sessions.set(forked.sessionId, forked);
    return Promise.resolve({
      previousSessionId: source.sessionId,
      session: copySnapshot(forked),
      tree: treeSnapshot(forked),
      editorText: selected.text,
    });
  }

  cloneSession(input: { readonly sessionId: string }): Promise<PiNodeSessionTreeMutationResult> {
    const source = this.requireSession(input.sessionId);
    const cloned = sessionSnapshot(
      `cloned-${++this.createOrdinal}`,
      source.cwd,
      `Cloned ${this.createOrdinal}`,
      source.conversation.entries,
      source.sessionId,
    );
    this.sessions.set(cloned.sessionId, cloned);
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
    const session = this.requireSession(sessionId);
    const listeners = this.listeners.get(sessionId) ?? new Set<PiNodeSessionEventListener>();
    listeners.add(listener);
    this.listeners.set(sessionId, listeners);
    this.observedCount.set(sessionId, (this.observedCount.get(sessionId) ?? 0) + 1);
    if (this.emitOnObserve) this.emit(sessionId, { type: "running", running: false });
    let subscribed = true;
    return {
      snapshot: copySnapshot(session),
      unsubscribe: () => {
        if (!subscribed) return;
        subscribed = false;
        listeners.delete(listener);
        this.unsubscribedCount.set(sessionId, (this.unsubscribedCount.get(sessionId) ?? 0) + 1);
      },
    };
  }

  async submitPrompt(input: {
    readonly sessionId: string;
    readonly commandId: string;
    readonly text: string;
  }): Promise<PiNodePromptAdmission> {
    const session = this.requireSession(input.sessionId);
    if (this.promptAdmission !== "accepted") {
      return {
        sessionId: input.sessionId,
        commandId: input.commandId,
        status: this.promptAdmission,
        failure:
          this.promptAdmission === "rejected"
            ? { code: "invalid-prompt", message: "The prompt was rejected." }
            : { code: "session-busy", message: "Prompt admission is uncertain." },
      };
    }
    this.activeCommands.set(input.sessionId, input.commandId);
    this.emit(input.sessionId, { type: "running", running: true, commandId: input.commandId });
    const started = message(`${input.commandId}:assistant`, "Working", "assistant", {
      scope: "runtime",
      originCommandId: input.commandId,
      revision: 1,
      finalized: false,
    });
    this.emit(input.sessionId, { type: "entry-upsert", entry: started });
    this.emit(input.sessionId, {
      type: "part-delta",
      entryId: started.identity.entryId,
      expectedEntryRevision: 1,
      resultingEntryRevision: 2,
      partId: started.parts[0]!.partId,
      expectedPartRevision: 1,
      resultingPartRevision: 2,
      textDelta: " now",
    });
    this.sessions.set(input.sessionId, { ...session, running: true });
    return { sessionId: input.sessionId, commandId: input.commandId, status: "accepted" };
  }

  renameSession(input: {
    readonly sessionId: string;
    readonly name: string;
  }): Promise<PiNodeSessionSummary> {
    const session = this.requireSession(input.sessionId);
    const updated = updatedSession(session, { name: input.name });
    this.sessions.set(input.sessionId, updated);
    return Promise.resolve(copySummary(updated));
  }

  clearSessionName(input: { readonly sessionId: string }): Promise<PiNodeSessionSummary> {
    const session = this.requireSession(input.sessionId);
    const updated = updatedSession(session, { clearName: true });
    this.sessions.set(input.sessionId, updated);
    return Promise.resolve(copySummary(updated));
  }

  autoNameSession(input: { readonly sessionId: string }): Promise<PiNodeSessionSummary> {
    const session = this.requireSession(input.sessionId);
    const updated = updatedSession(session, { name: "Generated session title" });
    this.sessions.set(input.sessionId, updated);
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
    const session = this.requireSession(input.sessionId);
    if (
      !input.confirmation.destructiveActionAcknowledged ||
      input.confirmation.sessionId !== input.sessionId ||
      input.confirmation.adminRevision !== session.adminRevision
    ) {
      return Promise.reject(new Error("Stale fake deletion confirmation."));
    }
    this.sessions.delete(input.sessionId);
    return Promise.resolve({ sessionId: input.sessionId, reparentedChildCount: 0 });
  }

  async abort(input: { readonly sessionId: string }): Promise<PiNodeAbortResult> {
    this.requireSession(input.sessionId);
    const activeCommand = this.activeCommands.get(input.sessionId);
    if (!activeCommand) return { status: "not-running", sessionId: input.sessionId };
    this.activeCommands.delete(input.sessionId);
    this.emit(input.sessionId, { type: "running", running: false, commandId: activeCommand });
    this.emit(input.sessionId, {
      type: "command-completed",
      commandId: activeCommand,
      outcome: "aborted",
      failure: { code: "aborted", message: "private runtime detail must be redacted" },
    });
    return { status: "requested", sessionId: input.sessionId, commandId: activeCommand };
  }

  emit(
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
    const sequence = (this.eventSequences.get(sessionId) ?? 0) + 1;
    this.eventSequences.set(sessionId, sequence);
    const event = {
      ...payload,
      sessionId,
      sequence,
      emittedAtMs: 1_000 + sequence,
    } as PiNodeSessionEvent;
    for (const listener of [...(this.listeners.get(sessionId) ?? [])]) listener(event);
  }

  requireSession(sessionId: string): PiNodeSessionSnapshot {
    const session = this.sessions.get(sessionId);
    if (!session) throw new Error("Missing fake session.");
    return session;
  }
}

export function sessionSnapshot(
  sessionId: string,
  cwd = defaultCwd,
  title = "Session",
  entries: readonly PiNodeConversationEntry[] = [message(`${sessionId}:user`, "Hello", "user")],
  parentSessionId?: string,
): PiNodeSessionSnapshot {
  return {
    sessionId,
    cwd,
    name: title,
    ...(parentSessionId === undefined ? {} : { parentSessionId }),
    createdAtMs: 100,
    modifiedAtMs: 200,
    messageCount: entries.length,
    firstMessage: entryText(entries[0]) || title,
    running: false,
    adminRevision: `revision-${sessionId}-1`,
    persistence: "persistent",
    conversation: { sessionId, entries, lastEventSequence: 0 },
  };
}

export function message(
  entryId: string,
  text: string,
  role: "user" | "assistant" = "assistant",
  options: {
    readonly scope?: "persistent" | "runtime";
    readonly originCommandId?: string;
    readonly revision?: number;
    readonly finalized?: boolean;
  } = {},
): PiNodeConversationEntry {
  const common = {
    identity: {
      entryId,
      scope: options.scope ?? ("persistent" as const),
      ...(options.originCommandId === undefined
        ? {}
        : { originCommandId: options.originCommandId }),
    },
    revision: options.revision ?? 1,
    createdAtMs: 100,
    finalized: options.finalized ?? true,
    parts: [
      {
        type: "text" as const,
        partId: `part-${entryId.replaceAll(/[^A-Za-z0-9-]/gu, "-")}`,
        revision: options.revision ?? 1,
        text,
      },
    ],
    toolActivities: [],
  };
  return role === "user"
    ? { ...common, type: "user" }
    : {
        ...common,
        type: "assistant",
        provider: "fake-provider",
        model: "fake-model",
        stopReason: options.finalized === false ? "streaming" : "stop",
      };
}

export function projectSnapshot(
  canonicalCwd: string,
  trustStatus: PiNodeProjectSnapshot["trust"]["status"] = "not-required",
): PiNodeProjectSnapshot {
  const projectId = `project-${canonicalCwd.replaceAll(/[^A-Za-z0-9]+/gu, "-")}`;
  return {
    identity: {
      projectId,
      canonicalCwd,
      isGitRepository: false,
      isLinkedWorktree: false,
      isDetachedHead: false,
      worktreeId: `${projectId}-worktree`,
      mainProjectId: `${projectId}-main`,
    },
    trust: {
      status: trustStatus,
      reasons: trustStatus === "not-required" ? [] : ["pi-settings", "saved-approval"],
      revision: `revision-${trustStatus}`,
    },
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

function updatedSession(
  session: PiNodeSessionSnapshot,
  change: { readonly name?: string; readonly clearName?: boolean },
): PiNodeSessionSnapshot {
  const modifiedAtMs = session.modifiedAtMs + 1;
  const name = change.clearName ? undefined : (change.name ?? session.name);
  const updated = {
    ...session,
    modifiedAtMs,
    adminRevision: `revision-${session.sessionId}-${modifiedAtMs}-${name ?? "clear"}`,
  };
  if (name === undefined) {
    const { name: _discarded, ...withoutName } = updated;
    return withoutName;
  }
  return { ...updated, name };
}

function treeSnapshot(session: PiNodeSessionSnapshot): PiNodeSessionTreeSnapshot {
  const entries = session.conversation.entries;
  const nodes = entries.map((item, index) => ({
    entryId: item.identity.entryId,
    ...(index === 0 ? {} : { parentEntryId: entries[index - 1]!.identity.entryId }),
    kind: item.type === "user" ? ("user-message" as const) : ("assistant-message" as const),
    text: entryText(item),
    createdAtMs: item.createdAtMs,
    depth: index,
    isOnActivePath: true,
    hasChildren: index + 1 < entries.length,
    canEditFromHere: item.type === "user",
    canFork: item.type === "user",
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

function entryText(entry: PiNodeConversationEntry | undefined): string {
  if (entry === undefined) return "";
  return entry.parts
    .filter((part) => part.type === "text" && part.text !== undefined)
    .map((part) => (part.type === "text" ? (part.text ?? "") : ""))
    .join("");
}

function copySnapshot(snapshot: PiNodeSessionSnapshot): PiNodeSessionSnapshot {
  return structuredClone(snapshot);
}
