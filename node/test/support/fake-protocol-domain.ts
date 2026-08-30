import type {
  PiNodeAbortResult,
  PiNodeMessage,
  PiNodePromptAdmission,
  PiNodeSessionEvent,
  PiNodeSessionEventListener,
  PiNodeSessionSnapshot,
  PiNodeSessionSummary,
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

  constructor() {
    this.sessions.set("session-1", sessionSnapshot("session-1", defaultCwd, "Existing session"));
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
): PiNodeSessionSnapshot {
  return {
    sessionId,
    cwd,
    name: title,
    createdAtMs: 100,
    modifiedAtMs: 200,
    messageCount: messages.length,
    firstMessage: messages[0]?.parts[0]?.type === "text" ? messages[0].parts[0].text : title,
    running: false,
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

function copySummary(snapshot: PiNodeSessionSnapshot): PiNodeSessionSummary {
  return {
    sessionId: snapshot.sessionId,
    cwd: snapshot.cwd,
    ...(snapshot.name === undefined ? {} : { name: snapshot.name }),
    createdAtMs: snapshot.createdAtMs,
    modifiedAtMs: snapshot.modifiedAtMs,
    messageCount: snapshot.messageCount,
    firstMessage: snapshot.firstMessage,
    running: snapshot.running,
  };
}

function copySnapshot(snapshot: PiNodeSessionSnapshot): PiNodeSessionSnapshot {
  return structuredClone(snapshot);
}
