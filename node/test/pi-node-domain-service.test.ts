import assert from "node:assert/strict";
import test from "node:test";

import {
  type PiNodeCommandCompletion,
  PiNodeDomainError,
  type PiNodeDomainSessionBackend,
  type PiNodeDomainSessionBackendFactory,
  type PiNodeMessage,
  type PiNodePromptExecution,
  type PiNodeSessionBackendEvent,
  type PiNodeSessionBackendSnapshot,
  type PiNodeSessionSummary,
} from "../src/pi-node-domain.js";
import {
  InMemoryPiNodeSessionOwnershipRegistry,
  PiNodeDomainService,
} from "../src/pi-node-domain-service.js";
import {
  ProjectTrustCoordinator,
  type ProjectTrustAuthorization,
  type ProjectTrustBackend,
} from "../src/project-trust.js";

const canonicalCwd = "/canonical/project";
const agentDir = "/agent";

function trustCoordinator(
  order?: string[],
  options: { readonly protectedResources?: boolean; readonly savedDecision?: boolean | null } = {},
): ProjectTrustCoordinator {
  const backend: ProjectTrustBackend = {
    hasProtectedProjectResources: () => {
      order?.push("trust:inspect");
      return options.protectedResources ?? false;
    },
    readSavedDecision: () => {
      order?.push("trust:saved");
      return options.savedDecision ?? null;
    },
  };
  return new ProjectTrustCoordinator({
    backend,
    canonicalizePath: () => canonicalCwd,
  });
}

function message(id: string, text: string, role: PiNodeMessage["role"] = "user"): PiNodeMessage {
  return Object.freeze({
    id,
    role,
    sourceRole: role,
    timestampMs: 10,
    parts: Object.freeze([{ type: "text" as const, text }]),
  });
}

function summary(sessionId: string): PiNodeSessionSummary {
  return Object.freeze({
    sessionId,
    cwd: canonicalCwd,
    createdAtMs: 10,
    modifiedAtMs: 20,
    messageCount: 1,
    firstMessage: "hello",
    running: false,
  });
}

interface Deferred<T> {
  readonly promise: Promise<T>;
  resolve(value: T): void;
}

function deferred<T>(): Deferred<T> {
  let resolvePromise: ((value: T) => void) | undefined;
  const promise = new Promise<T>((resolve) => {
    resolvePromise = resolve;
  });
  return {
    promise,
    resolve: (value) => resolvePromise?.(value),
  };
}

class FakeSessionBackend implements PiNodeDomainSessionBackend {
  readonly persistence = "persistent" as const;
  readonly #listeners = new Set<(event: PiNodeSessionBackendEvent) => void>();
  readonly #completion = deferred<PiNodeCommandCompletion>();
  readonly disposeLog: string[];
  readonly messages: PiNodeMessage[];

  isRunning = false;
  disposed = false;
  startCalls = 0;
  abortCalls = 0;
  admission: PiNodePromptExecution["admission"] = { status: "accepted" };

  constructor(
    readonly sessionId: string,
    readonly cwd: string = canonicalCwd,
    disposeLog: string[] = [],
    messages: PiNodeMessage[] = [message(`${sessionId}:message`, "hello")],
  ) {
    this.disposeLog = disposeLog;
    this.messages = messages;
  }

  getSnapshot(): PiNodeSessionBackendSnapshot {
    return {
      ...summary(this.sessionId),
      cwd: this.cwd,
      running: this.isRunning,
      persistence: "persistent",
      messages: this.messages,
    };
  }

  subscribe(listener: (event: PiNodeSessionBackendEvent) => void): () => void {
    this.#listeners.add(listener);
    return () => this.#listeners.delete(listener);
  }

  startPrompt(): Promise<PiNodePromptExecution> {
    this.startCalls += 1;
    if (this.admission.status !== "rejected") {
      this.isRunning = true;
      this.emit({ type: "running", running: true });
    }
    return Promise.resolve({
      admission: this.admission,
      completion: this.#completion.promise,
    });
  }

  async abort(): Promise<boolean> {
    this.abortCalls += 1;
    if (!this.isRunning) {
      return false;
    }
    this.isRunning = false;
    this.emit({ type: "running", running: false });
    this.#completion.resolve({
      outcome: "aborted",
      failure: { code: "aborted", message: "The command was aborted." },
    });
    return true;
  }

  async dispose(): Promise<void> {
    if (this.disposed) {
      return;
    }
    if (this.isRunning) {
      await this.abort();
    }
    this.disposed = true;
    this.#listeners.clear();
    this.disposeLog.push(`dispose:${this.sessionId}`);
  }

  emit(event: PiNodeSessionBackendEvent): void {
    for (const listener of [...this.#listeners]) {
      listener(event);
    }
  }

  complete(completion: PiNodeCommandCompletion): void {
    this.isRunning = false;
    this.emit({ type: "running", running: false });
    this.#completion.resolve(completion);
  }
}

class FakeSessionFactory implements PiNodeDomainSessionBackendFactory {
  readonly backends = new Map<string, FakeSessionBackend>();
  readonly loadedBackends = new Map<string, FakeSessionBackend>();
  readonly order: string[];
  readonly disposeLog: string[];
  readonly projectResourceAccess: boolean[] = [];
  createCount = 0;
  openCount = 0;

  constructor(order: string[] = [], disposeLog: string[] = []) {
    this.order = order;
    this.disposeLog = disposeLog;
  }

  listPersistentSessions(input: {
    readonly authorization: ProjectTrustAuthorization;
  }): Promise<readonly PiNodeSessionSummary[]> {
    this.projectResourceAccess.push(input.authorization.projectResourcesAllowed);
    this.order.push(`list:${input.authorization.cwd}`);
    return Promise.resolve([...this.backends.values()].map((backend) => backend.getSnapshot()));
  }

  createPersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
  }): Promise<PiNodeDomainSessionBackend> {
    this.projectResourceAccess.push(input.authorization.projectResourcesAllowed);
    this.order.push(`create:${input.authorization.cwd}`);
    const backend = new FakeSessionBackend(
      `created-${++this.createCount}`,
      input.authorization.cwd,
      this.disposeLog,
      [],
    );
    this.backends.set(backend.sessionId, backend);
    this.loadedBackends.set(backend.sessionId, backend);
    return Promise.resolve(backend);
  }

  openPersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly sessionId: string;
  }): Promise<PiNodeDomainSessionBackend> {
    this.projectResourceAccess.push(input.authorization.projectResourcesAllowed);
    this.order.push(`open:${input.authorization.cwd}:${input.sessionId}`);
    this.openCount += 1;
    const existing = this.backends.get(input.sessionId);
    if (!existing) {
      throw new PiNodeDomainError("session-not-found", "Session missing in fake factory.");
    }
    const loaded = new FakeSessionBackend(
      existing.sessionId,
      input.authorization.cwd,
      this.disposeLog,
      [...existing.messages],
    );
    this.loadedBackends.set(input.sessionId, loaded);
    return Promise.resolve(loaded);
  }
}

async function nextTask(): Promise<void> {
  await new Promise<void>((resolve) => setImmediate(resolve));
}

test("project trust canonicalization precedes every persistent SDK backend operation", async () => {
  const order: string[] = [];
  const factory = new FakeSessionFactory(order);
  const service = new PiNodeDomainService({
    agentDir,
    trustCoordinator: trustCoordinator(order, {
      protectedResources: true,
      savedDecision: true,
    }),
    sessionFactory: factory,
    ownershipRegistry: new InMemoryPiNodeSessionOwnershipRegistry(),
  });

  try {
    await service.listPersistentSessions({ cwd: "/input" });
    const snapshot = await service.createPersistentSession({ cwd: "/input" });

    assert.equal(snapshot.cwd, canonicalCwd);
    assert.deepEqual(order, [
      "trust:inspect",
      "trust:saved",
      `list:${canonicalCwd}`,
      "trust:inspect",
      "trust:saved",
      `create:${canonicalCwd}`,
    ]);
    assert.deepEqual(factory.projectResourceAccess, [true, true]);
  } finally {
    await service.dispose();
  }
});

test("concurrent loads share one exclusive loaded backend and snapshot copy", async () => {
  const factory = new FakeSessionFactory();
  factory.backends.set("session-1", new FakeSessionBackend("session-1"));
  const service = new PiNodeDomainService({
    agentDir,
    trustCoordinator: trustCoordinator(),
    sessionFactory: factory,
    ownershipRegistry: new InMemoryPiNodeSessionOwnershipRegistry(),
  });

  try {
    const [left, right] = await Promise.all([
      service.loadSessionSnapshot({ cwd: "/left", sessionId: "session-1" }),
      service.loadSessionSnapshot({ cwd: "/right", sessionId: "session-1" }),
    ]);

    assert.equal(factory.openCount, 1);
    assert.deepEqual(left, right);
    assert.notEqual(left.messages, right.messages);
  } finally {
    await service.dispose();
  }
});

test("prompt admission streams normalized events with monotonic session sequence", async () => {
  const times = [100, 101, 102, 103, 104, 105, 106];
  const factory = new FakeSessionFactory();
  factory.backends.set("session-1", new FakeSessionBackend("session-1"));
  const service = new PiNodeDomainService({
    agentDir,
    trustCoordinator: trustCoordinator(),
    sessionFactory: factory,
    ownershipRegistry: new InMemoryPiNodeSessionOwnershipRegistry(),
    clock: () => times.shift() ?? 999,
  });

  try {
    await service.loadSessionSnapshot({ cwd: "/input", sessionId: "session-1" });
    const backend = serviceBackend(factory, "session-1");
    const events: import("../src/pi-node-domain.js").PiNodeSessionEvent[] = [];
    const observation = service.observeSession("session-1", (event) => events.push(event));

    const admission = await service.submitPrompt({
      sessionId: "session-1",
      commandId: "command-1",
      text: "do work",
    });
    backend.emit({
      type: "message",
      phase: "started",
      message: message("runtime-1", "answer", "assistant"),
    });
    backend.emit({
      type: "message",
      phase: "completed",
      message: message("runtime-1", "answer complete", "assistant"),
    });
    backend.complete({ outcome: "succeeded" });
    await nextTask();

    assert.equal(admission.status, "accepted");
    assert.deepEqual(
      events.map((event) => event.type),
      ["running", "message", "message", "running", "command-completed"],
    );
    assert.deepEqual(
      events.map((event) => event.sequence),
      [1, 2, 3, 4, 5],
    );
    assert.equal(events[0]?.type === "running" ? events[0].commandId : undefined, "command-1");
    const lastEvent = events.at(-1);
    assert.equal(
      lastEvent?.type === "command-completed" ? lastEvent.outcome : undefined,
      "succeeded",
    );
    assert.equal(observation.snapshot.lastEventSequence, 0);
    assert.equal(service.getLoadedSessionSnapshot("session-1").lastEventSequence, 5);
    observation.unsubscribe();
  } finally {
    await service.dispose();
  }
});

test("empty and busy prompts return explicit rejection admissions and completion events", async () => {
  const factory = new FakeSessionFactory();
  factory.backends.set("session-1", new FakeSessionBackend("session-1"));
  const service = new PiNodeDomainService({
    agentDir,
    trustCoordinator: trustCoordinator(),
    sessionFactory: factory,
    ownershipRegistry: new InMemoryPiNodeSessionOwnershipRegistry(),
  });

  try {
    await service.loadSessionSnapshot({ cwd: "/input", sessionId: "session-1" });
    const events: import("../src/pi-node-domain.js").PiNodeSessionEvent[] = [];
    const unsubscribe = service.subscribeSessionEvents("session-1", (event) => events.push(event));

    const empty = await service.submitPrompt({
      sessionId: "session-1",
      commandId: "empty",
      text: "  ",
    });
    const accepted = await service.submitPrompt({
      sessionId: "session-1",
      commandId: "active",
      text: "work",
    });
    const busy = await service.submitPrompt({
      sessionId: "session-1",
      commandId: "busy",
      text: "other",
    });

    assert.equal(empty.status, "rejected");
    assert.equal(empty.failure?.code, "invalid-prompt");
    assert.equal(accepted.status, "accepted");
    assert.equal(busy.status, "rejected");
    assert.equal(busy.failure?.code, "session-busy");
    assert.deepEqual(
      events.filter((event) => event.type === "command-completed").map((event) => event.outcome),
      ["rejected", "rejected"],
    );
    unsubscribe();
  } finally {
    await service.dispose();
  }
});

test("abort targets the active command and settles it as aborted", async () => {
  const factory = new FakeSessionFactory();
  factory.backends.set("session-1", new FakeSessionBackend("session-1"));
  const service = new PiNodeDomainService({
    agentDir,
    trustCoordinator: trustCoordinator(),
    sessionFactory: factory,
    ownershipRegistry: new InMemoryPiNodeSessionOwnershipRegistry(),
  });

  try {
    await service.loadSessionSnapshot({ cwd: "/input", sessionId: "session-1" });
    const events: import("../src/pi-node-domain.js").PiNodeSessionEvent[] = [];
    const unsubscribe = service.subscribeSessionEvents("session-1", (event) => events.push(event));
    await service.submitPrompt({
      sessionId: "session-1",
      commandId: "command-1",
      text: "work",
    });

    const result = await service.abortActiveRun({ sessionId: "session-1" });
    await nextTask();

    assert.deepEqual(result, {
      status: "requested",
      sessionId: "session-1",
      commandId: "command-1",
    });
    const completed = events.findLast((event) => event.type === "command-completed");
    assert.equal(
      completed?.type === "command-completed" ? completed.outcome : undefined,
      "aborted",
    );
    unsubscribe();
  } finally {
    await service.dispose();
  }
});

test("the bounded registry evicts only unobserved idle sessions", async () => {
  const disposeLog: string[] = [];
  const factory = new FakeSessionFactory([], disposeLog);
  const service = new PiNodeDomainService({
    agentDir,
    trustCoordinator: trustCoordinator(),
    sessionFactory: factory,
    ownershipRegistry: new InMemoryPiNodeSessionOwnershipRegistry(),
    maxOpenSessions: 1,
  });

  try {
    const first = await service.createPersistentSession({ cwd: "/input" });
    const second = await service.createPersistentSession({ cwd: "/input" });
    assert.deepEqual(disposeLog, [`dispose:${first.sessionId}`]);

    const observation = service.observeSession(second.sessionId, () => {});
    await assert.rejects(
      service.createPersistentSession({ cwd: "/input" }),
      (error) => error instanceof PiNodeDomainError && error.code === "session-capacity-exceeded",
    );
    observation.unsubscribe();
  } finally {
    await service.dispose();
  }
});

test("process-local ownership rejects a second service until the first releases the session", async () => {
  const ownership = new InMemoryPiNodeSessionOwnershipRegistry();
  const firstFactory = new FakeSessionFactory();
  const secondFactory = new FakeSessionFactory();
  firstFactory.backends.set("session-1", new FakeSessionBackend("session-1"));
  secondFactory.backends.set("session-1", new FakeSessionBackend("session-1"));
  const first = new PiNodeDomainService({
    agentDir,
    trustCoordinator: trustCoordinator(),
    sessionFactory: firstFactory,
    ownershipRegistry: ownership,
    ownerId: "first",
  });
  const second = new PiNodeDomainService({
    agentDir,
    trustCoordinator: trustCoordinator(),
    sessionFactory: secondFactory,
    ownershipRegistry: ownership,
    ownerId: "second",
  });

  try {
    await first.loadSessionSnapshot({ cwd: "/input", sessionId: "session-1" });
    await assert.rejects(
      second.loadSessionSnapshot({ cwd: "/input", sessionId: "session-1" }),
      (error) => error instanceof PiNodeDomainError && error.code === "session-owned",
    );
    await first.closeSession("session-1");
    const snapshot = await second.loadSessionSnapshot({
      cwd: "/input",
      sessionId: "session-1",
    });
    assert.equal(snapshot.sessionId, "session-1");
  } finally {
    await Promise.all([first.dispose(), second.dispose()]);
  }
});

function serviceBackend(factory: FakeSessionFactory, sessionId: string): FakeSessionBackend {
  const loaded = factory.loadedBackends.get(sessionId);
  if (!loaded) {
    throw new Error("Missing loaded backend.");
  }
  return loaded;
}
