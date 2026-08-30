import type {
  PiNodeAbortResult,
  PiNodeDirectoryListing,
  PiNodeKnownProjectSnapshot,
  PiNodeMessage,
  PiNodeProjectBootstrap,
  PiNodeProjectSnapshot,
  PiNodePromptAdmission,
  PiNodeSessionEvent,
  PiNodeSessionEventListener,
  PiNodeSessionSnapshot,
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
      {
        project: projectSnapshot(defaultCwd),
        lastSessionAtMs: 200,
        sessionCount: 1,
      },
    ]);
  }

  approveProjectTrust(input: { readonly canonicalCwd: string }): Promise<PiNodeProjectSnapshot> {
    return Promise.resolve(projectSnapshot(input.canonicalCwd, "trusted"));
  }

  listSessions(): Promise<readonly PiNodeSessionSummary[]> {
    if (this.listError !== undefined) {
      return Promise.reject(this.listError);
    }
    return Promise.resolve([...this.sessions.values()].map(copySummary));
  }

  getSession(input: { readonly sessionId: string }): Promise<PiNodeSessionSnapshot> {
    const session = this.sessions.get(input.sessionId);
    if (!session) {
      return Promise.reject(new Error("Missing fake session."));
    }
    return Promise.resolve(copySnapshot(session));
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
    const sourceTree = treeSnapshot(source);
    const selected = sourceTree.nodes.find(
      (node) => node.entryId === input.userEntryId && node.canFork,
    );
    if (!selected) return Promise.reject(new Error("Missing fake fork entry."));
    const forked = sessionSnapshot(
      `forked-${++this.createOrdinal}`,
      source.cwd,
      `Forked ${this.createOrdinal}`,
      source.messages.filter((message) => message.id !== selected.entryId),
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
      source.messages,
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
    if (this.emitOnObserve) {
      this.emit(sessionId, { type: "running", running: false });
    }

    let subscribed = true;
    return {
      snapshot: copySnapshot(session),
      unsubscribe: () => {
        if (!subscribed) {
          return;
        }
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
    this.emit(input.sessionId, {
      type: "running",
      running: true,
      commandId: input.commandId,
    });
    const started = message(`${input.commandId}:assistant`, "Working", "assistant");
    this.emit(input.sessionId, { type: "message", phase: "started", message: started });
    this.emit(input.sessionId, {
      type: "message",
      phase: "updated",
      message: message(started.id, "Working now", "assistant"),
    });
    this.sessions.set(input.sessionId, { ...session, running: true });
    return {
      sessionId: input.sessionId,
      commandId: input.commandId,
      status: "accepted",
    };
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
    if (!activeCommand) {
      return { status: "not-running", sessionId: input.sessionId };
    }
    this.activeCommands.delete(input.sessionId);
    this.emit(input.sessionId, {
      type: "running",
      running: false,
      commandId: activeCommand,
    });
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
    for (const listener of [...(this.listeners.get(sessionId) ?? [])]) {
      listener(event);
    }
  }

  requireSession(sessionId: string): PiNodeSessionSnapshot {
    const session = this.sessions.get(sessionId);
    if (!session) {
      throw new Error("Missing fake session.");
    }
    return session;
  }
}

export function sessionSnapshot(
  sessionId: string,
  cwd = defaultCwd,
  title = "Session",
  messages: readonly PiNodeMessage[] = [message(`${sessionId}:user`, "Hello", "user")],
  parentSessionId?: string,
): PiNodeSessionSnapshot {
  return {
    sessionId,
    cwd,
    name: title,
    ...(parentSessionId === undefined ? {} : { parentSessionId }),
    createdAtMs: 100,
    modifiedAtMs: 200,
    messageCount: messages.length,
    firstMessage: messages[0]?.parts[0]?.type === "text" ? messages[0].parts[0].text : title,
    running: false,
    adminRevision: `revision-${sessionId}-1`,
    persistence: "persistent",
    messages,
    lastEventSequence: 0,
  };
}

export function message(id: string, text: string, role: PiNodeMessage["role"]): PiNodeMessage {
  return {
    id,
    role,
    sourceRole: role,
    timestampMs: 100,
    parts: [{ type: "text", text }],
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
