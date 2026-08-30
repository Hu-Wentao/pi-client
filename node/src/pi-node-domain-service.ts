import { randomUUID } from "node:crypto";

import {
  PiNodeDomainError,
  type PiNodeAbortResult,
  type PiNodeCommandCompletion,
  type PiNodeCommandFailure,
  type PiNodeDomainSessionBackend,
  type PiNodeDomainSessionBackendFactory,
  type PiNodeEventBase,
  type PiNodeDirectoryListing,
  type PiNodeKnownProjectSnapshot,
  type PiNodeProjectBootstrap,
  type PiNodeProjectSnapshot,
  type PiNodePromptAdmission,
  type PiNodeSessionBackendEvent,
  type PiNodeSessionEvent,
  type PiNodeSessionEventListener,
  type PiNodeSessionSnapshot,
  type PiNodeSessionSummary,
} from "./pi-node-domain.js";
import {
  ProjectTrustCoordinator,
  ProjectTrustError,
  type ProjectTrustAuthorization,
} from "./project-trust.js";
import { PiNodeProjectService } from "./project-service.js";

export interface PiNodeSessionLease {
  release(): void;
}

export interface PiNodeSessionOwnershipRegistry {
  acquire(sessionKey: string, ownerId: string): PiNodeSessionLease;
}

export class InMemoryPiNodeSessionOwnershipRegistry implements PiNodeSessionOwnershipRegistry {
  readonly #owners = new Map<string, string>();

  acquire(sessionKey: string, ownerId: string): PiNodeSessionLease {
    const currentOwner = this.#owners.get(sessionKey);
    if (currentOwner !== undefined && currentOwner !== ownerId) {
      throw new PiNodeDomainError(
        "session-owned",
        "The session is already owned by another Pi Node domain service.",
      );
    }

    this.#owners.set(sessionKey, ownerId);
    let released = false;
    return {
      release: () => {
        if (released) {
          return;
        }
        released = true;
        if (this.#owners.get(sessionKey) === ownerId) {
          this.#owners.delete(sessionKey);
        }
      },
    };
  }
}

const processSessionOwnershipRegistry = new InMemoryPiNodeSessionOwnershipRegistry();

class SerialExecutor {
  #tail: Promise<void> = Promise.resolve();

  run<T>(operation: () => Promise<T> | T): Promise<T> {
    const result = this.#tail.then(operation, operation);
    this.#tail = result.then(
      () => undefined,
      () => undefined,
    );
    return result;
  }
}

interface ActiveCommand {
  readonly commandId: string;
  admission: "accepted" | "uncertain" | "admitting";
  abortRequested: boolean;
}

interface RegistryEntry {
  readonly backend: PiNodeDomainSessionBackend;
  readonly lease: PiNodeSessionLease;
  readonly listeners: Set<PiNodeSessionEventListener>;
  unsubscribeBackend: () => void;
  activeCommand: ActiveCommand | undefined;
  running: boolean;
  lastTouched: number;
}

export interface PiNodeDomainServiceOptions {
  readonly agentDir: string;
  readonly defaultWorkingDirectory?: string;
  readonly trustCoordinator: ProjectTrustCoordinator;
  readonly sessionFactory: PiNodeDomainSessionBackendFactory;
  readonly maxOpenSessions?: number;
  readonly ownershipRegistry?: PiNodeSessionOwnershipRegistry;
  readonly clock?: () => number;
  readonly ownerId?: string;
}

export interface PiNodeSessionObservation {
  readonly snapshot: PiNodeSessionSnapshot;
  unsubscribe(): void;
}

export class PiNodeDomainService {
  readonly #agentDir: string;
  readonly #trustCoordinator: ProjectTrustCoordinator;
  readonly #sessionFactory: PiNodeDomainSessionBackendFactory;
  readonly #projectService: PiNodeProjectService;
  readonly #maxOpenSessions: number;
  readonly #ownershipRegistry: PiNodeSessionOwnershipRegistry;
  readonly #clock: () => number;
  readonly #ownerId: string;
  readonly #executor = new SerialExecutor();
  readonly #sessions = new Map<string, RegistryEntry>();
  readonly #lastSequenceBySession = new Map<string, number>();

  #touchCounter = 0;
  #disposeRequested = false;
  #disposePromise: Promise<void> | undefined;

  constructor(options: PiNodeDomainServiceOptions) {
    if (!Number.isSafeInteger(options.maxOpenSessions ?? 8) || (options.maxOpenSessions ?? 8) < 1) {
      throw new RangeError("maxOpenSessions must be a positive safe integer.");
    }

    this.#agentDir = options.agentDir;
    this.#trustCoordinator = options.trustCoordinator;
    this.#sessionFactory = options.sessionFactory;
    this.#projectService = new PiNodeProjectService({
      agentDir: options.agentDir,
      defaultWorkingDirectory: options.defaultWorkingDirectory ?? process.cwd(),
      trustCoordinator: options.trustCoordinator,
      closeProjectSessions: (canonicalCwd) => this.#closeProjectSessions(canonicalCwd),
    });
    this.#maxOpenSessions = options.maxOpenSessions ?? 8;
    this.#ownershipRegistry = options.ownershipRegistry ?? processSessionOwnershipRegistry;
    this.#clock = options.clock ?? Date.now;
    this.#ownerId = options.ownerId ?? randomUUID();
  }

  getProjectBootstrap(): Promise<PiNodeProjectBootstrap> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      return this.#projectService.getBootstrap();
    });
  }

  browseProjectDirectory(input: {
    readonly directory: string;
    readonly maxChildren: number;
  }): Promise<PiNodeDirectoryListing> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      return this.#projectService.browseDirectory(input);
    });
  }

  validateProject(input: { readonly candidateDirectory: string }): Promise<PiNodeProjectSnapshot> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      return this.#projectService.validateProject(input.candidateDirectory);
    });
  }

  listKnownProjects(input: {
    readonly maxProjects: number;
  }): Promise<readonly PiNodeKnownProjectSnapshot[]> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      return this.#projectService.listKnownProjects(input);
    });
  }

  approveProjectTrust(input: {
    readonly canonicalCwd: string;
    readonly trustRevision: string;
  }): Promise<PiNodeProjectSnapshot> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      return this.#projectService.approveTrust(input);
    });
  }

  listPersistentSessions(input: {
    readonly cwd: string;
  }): Promise<readonly PiNodeSessionSummary[]> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      const authorization = await this.#authorizeMetadata(input.cwd);

      try {
        const summaries = await this.#sessionFactory.listPersistentSessions({
          authorization,
          agentDir: this.#agentDir,
        });
        const listedIds = new Set(summaries.map((summary) => summary.sessionId));
        const listed = summaries.map((summary) => {
          const loaded = this.#sessions.get(summary.sessionId);
          return loaded
            ? copySummary(loaded.backend.getSnapshot(), loaded.running)
            : copySummary(summary, false);
        });
        for (const loaded of this.#sessions.values()) {
          if (
            loaded.backend.cwd === authorization.cwd &&
            !listedIds.has(loaded.backend.sessionId)
          ) {
            listed.push(copySummary(loaded.backend.getSnapshot(), loaded.running));
          }
        }
        return Object.freeze(listed);
      } catch (error) {
        throw wrapDomainError(
          error,
          "session-list-failed",
          "Persistent sessions could not be listed.",
        );
      }
    });
  }

  createPersistentSession(input: { readonly cwd: string }): Promise<PiNodeSessionSnapshot> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      const authorization = await this.#authorize(input.cwd);
      await this.#ensureCapacity();

      let backend: PiNodeDomainSessionBackend;
      try {
        backend = await this.#sessionFactory.createPersistentSession({
          authorization,
          agentDir: this.#agentDir,
        });
      } catch (error) {
        throw wrapDomainError(
          error,
          "session-create-failed",
          "A persistent session could not be created.",
        );
      }

      try {
        const entry = this.#registerBackend(backend, authorization);
        return this.#snapshot(entry);
      } catch (error) {
        return await disposeAfterRegistrationFailure(backend, error);
      }
    });
  }

  loadSessionSnapshot(input: {
    readonly cwd: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionSnapshot> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      const sessionId = requireIdentifier(input.sessionId, "sessionId");
      const authorization = await this.#authorize(input.cwd);
      const existing = this.#sessions.get(sessionId);
      if (existing) {
        if (existing.backend.cwd !== authorization.cwd) {
          throw new PiNodeDomainError(
            "session-not-found",
            "The requested session does not belong to the canonical project directory.",
          );
        }
        this.#touch(existing);
        return this.#snapshot(existing);
      }

      await this.#ensureCapacity();

      let backend: PiNodeDomainSessionBackend;
      try {
        backend = await this.#sessionFactory.openPersistentSession({
          authorization,
          agentDir: this.#agentDir,
          sessionId,
        });
      } catch (error) {
        if (hasErrorCode(error, "session-not-found")) {
          throw new PiNodeDomainError("session-not-found", "The session could not be found.", {
            cause: error,
          });
        }
        throw wrapDomainError(error, "session-load-failed", "The session could not be loaded.");
      }

      try {
        if (backend.sessionId !== sessionId) {
          throw new PiNodeDomainError(
            "session-load-failed",
            "The session backend returned a different session identifier.",
          );
        }
        const entry = this.#registerBackend(backend, authorization);
        return this.#snapshot(entry);
      } catch (error) {
        return await disposeAfterRegistrationFailure(backend, error);
      }
    });
  }

  getLoadedSessionSnapshot(sessionId: string): PiNodeSessionSnapshot {
    this.#assertAvailable();
    const entry = this.#requireLoadedSession(requireIdentifier(sessionId, "sessionId"));
    this.#touch(entry);
    return this.#snapshot(entry);
  }

  observeSession(
    sessionId: string,
    listener: PiNodeSessionEventListener,
  ): PiNodeSessionObservation {
    this.#assertAvailable();
    const entry = this.#requireLoadedSession(requireIdentifier(sessionId, "sessionId"));
    entry.listeners.add(listener);
    this.#touch(entry);

    let subscribed = true;
    return Object.freeze({
      snapshot: this.#snapshot(entry),
      unsubscribe: () => {
        if (!subscribed) {
          return;
        }
        subscribed = false;
        entry.listeners.delete(listener);
      },
    });
  }

  subscribeSessionEvents(sessionId: string, listener: PiNodeSessionEventListener): () => void {
    return this.observeSession(sessionId, listener).unsubscribe;
  }

  submitPrompt(input: {
    readonly sessionId: string;
    readonly commandId: string;
    readonly text: string;
  }): Promise<PiNodePromptAdmission> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      const sessionId = requireIdentifier(input.sessionId, "sessionId");
      const commandId = requireIdentifier(input.commandId, "commandId");
      const entry = this.#requireLoadedSession(sessionId);
      this.#touch(entry);

      if (input.text.trim().length === 0) {
        return this.#rejectCommand(entry, commandId, {
          code: "invalid-prompt",
          message: "The prompt must contain non-whitespace text.",
        });
      }

      if (entry.activeCommand !== undefined || entry.running || entry.backend.isRunning) {
        return this.#rejectCommand(entry, commandId, {
          code: "session-busy",
          message: "The session already has an active command.",
        });
      }

      entry.activeCommand = {
        commandId,
        admission: "admitting",
        abortRequested: false,
      };

      let execution;
      try {
        execution = await entry.backend.startPrompt({ text: input.text });
      } catch (error) {
        entry.activeCommand = undefined;
        return this.#rejectCommand(entry, commandId, safeRuntimeFailure(error));
      }

      if (execution.admission.status === "rejected") {
        entry.activeCommand = undefined;
        return this.#rejectCommand(
          entry,
          commandId,
          execution.admission.failure ?? {
            code: "prompt-rejected",
            message: "The prompt was rejected before execution.",
          },
        );
      }

      entry.activeCommand.admission = execution.admission.status;
      void execution.completion.then(
        (completion) => this.#settleCommand(sessionId, commandId, completion),
        (error: unknown) =>
          this.#settleCommand(sessionId, commandId, {
            outcome: "failed",
            failure: safeRuntimeFailure(error),
          }),
      );

      return Object.freeze({
        sessionId,
        commandId,
        status: execution.admission.status,
        ...(execution.admission.failure === undefined
          ? {}
          : { failure: copyFailure(execution.admission.failure) }),
      });
    });
  }

  abortActiveRun(input: { readonly sessionId: string }): Promise<PiNodeAbortResult> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      const sessionId = requireIdentifier(input.sessionId, "sessionId");
      const entry = this.#requireLoadedSession(sessionId);
      this.#touch(entry);

      if (entry.activeCommand === undefined && !entry.running && !entry.backend.isRunning) {
        return Object.freeze({ status: "not-running", sessionId });
      }

      if (entry.activeCommand) {
        entry.activeCommand.abortRequested = true;
      }

      try {
        const requested = await entry.backend.abort();
        if (!requested) {
          return Object.freeze({ status: "not-running", sessionId });
        }
        return Object.freeze({
          status: "requested",
          sessionId,
          ...(entry.activeCommand === undefined
            ? {}
            : { commandId: entry.activeCommand.commandId }),
        });
      } catch (error) {
        throw wrapDomainError(error, "abort-failed", "The active run could not be aborted.");
      }
    });
  }

  closeSession(sessionId: string): Promise<void> {
    return this.#executor.run(async () => {
      this.#assertAvailable();
      const entry = this.#requireLoadedSession(requireIdentifier(sessionId, "sessionId"));
      await this.#disposeEntry(entry);
    });
  }

  dispose(): Promise<void> {
    this.#disposeRequested = true;
    this.#disposePromise ??= this.#executor.run(async () => {
      const errors: unknown[] = [];
      const entries = [...this.#sessions.values()].sort((left, right) =>
        left.backend.sessionId.localeCompare(right.backend.sessionId),
      );
      for (const entry of entries) {
        try {
          await this.#disposeEntry(entry);
        } catch (error) {
          errors.push(error);
        }
      }
      if (errors.length > 0) {
        throw new PiNodeDomainError(
          "session-dispose-failed",
          "One or more sessions could not be disposed cleanly.",
          { cause: new AggregateError(errors) },
        );
      }
    });
    return this.#disposePromise;
  }

  async #authorizeMetadata(cwd: string): Promise<ProjectTrustAuthorization> {
    try {
      return await this.#trustCoordinator.authorizeMetadata({
        cwd,
        agentDir: this.#agentDir,
      });
    } catch (error) {
      if (error instanceof ProjectTrustError) {
        const code =
          error.code === "project-path-invalid"
            ? "invalid-project-path"
            : "project-trust-resolution-failed";
        throw new PiNodeDomainError(code, safeTrustMessage(code), { cause: error });
      }
      throw new PiNodeDomainError(
        "project-trust-resolution-failed",
        "Project trust could not be resolved.",
        { cause: error },
      );
    }
  }

  async #authorize(cwd: string): Promise<ProjectTrustAuthorization> {
    try {
      return await this.#trustCoordinator.authorize({ cwd, agentDir: this.#agentDir });
    } catch (error) {
      if (error instanceof ProjectTrustError) {
        const code =
          error.code === "project-path-invalid"
            ? "invalid-project-path"
            : error.code === "project-trust-denied" ||
                error.code === "project-trust-unresolved" ||
                error.code === "project-trust-resolution-failed"
              ? error.code
              : error.code === "project-trust-persist-failed"
                ? "project-trust-persist-failed"
                : "project-trust-resolution-failed";
        throw new PiNodeDomainError(code, safeTrustMessage(code), { cause: error });
      }
      throw new PiNodeDomainError(
        "project-trust-resolution-failed",
        "Project trust could not be resolved.",
        { cause: error },
      );
    }
  }

  #registerBackend(
    backend: PiNodeDomainSessionBackend,
    authorization: ProjectTrustAuthorization,
  ): RegistryEntry {
    if (backend.persistence !== "persistent") {
      throw new PiNodeDomainError(
        "session-load-failed",
        "The domain service accepts only persistent session backends.",
      );
    }
    if (backend.cwd !== authorization.cwd) {
      throw new PiNodeDomainError(
        "session-load-failed",
        "The session backend is not bound to the authorized canonical project directory.",
      );
    }
    if (this.#sessions.has(backend.sessionId)) {
      throw new PiNodeDomainError(
        "session-owned",
        "The session is already loaded by this Pi Node domain service.",
      );
    }

    const lease = this.#ownershipRegistry.acquire(
      sessionOwnershipKey(backend.cwd, backend.sessionId),
      this.#ownerId,
    );
    const listeners = new Set<PiNodeSessionEventListener>();
    const entry = {
      backend,
      lease,
      listeners,
      unsubscribeBackend: () => {},
      activeCommand: undefined,
      running: backend.isRunning,
      lastTouched: ++this.#touchCounter,
    } satisfies RegistryEntry;

    try {
      entry.unsubscribeBackend = backend.subscribe((event) =>
        this.#handleBackendEvent(backend.sessionId, event),
      );
      this.#sessions.set(backend.sessionId, entry);
      return entry;
    } catch (error) {
      lease.release();
      throw error;
    }
  }

  #handleBackendEvent(sessionId: string, event: PiNodeSessionBackendEvent): void {
    const entry = this.#sessions.get(sessionId);
    if (!entry) {
      return;
    }
    this.#touch(entry);

    if (event.type === "running") {
      if (entry.running === event.running) {
        return;
      }
      entry.running = event.running;
      this.#emit(entry, {
        type: "running",
        running: event.running,
        ...(entry.activeCommand === undefined ? {} : { commandId: entry.activeCommand.commandId }),
      });
      return;
    }

    this.#emit(entry, {
      type: "message",
      phase: event.phase,
      message: event.message,
    });
  }

  #settleCommand(
    sessionId: string,
    commandId: string,
    completion: PiNodeCommandCompletion,
  ): Promise<void> {
    return this.#executor.run(() => {
      const entry = this.#sessions.get(sessionId);
      if (!entry || entry.activeCommand?.commandId !== commandId) {
        return;
      }

      const activeCommand = entry.activeCommand;
      entry.activeCommand = undefined;
      if (entry.running) {
        entry.running = false;
        this.#emit(entry, { type: "running", running: false, commandId });
      }

      const outcome =
        activeCommand.abortRequested && completion.outcome === "failed"
          ? "aborted"
          : completion.outcome;
      const failure =
        outcome === "aborted"
          ? (completion.failure ?? {
              code: "aborted" as const,
              message: "The command was aborted.",
            })
          : completion.failure;
      this.#emit(entry, {
        type: "command-completed",
        commandId,
        outcome,
        ...(failure === undefined ? {} : { failure: copyFailure(failure) }),
      });
    });
  }

  #rejectCommand(
    entry: RegistryEntry,
    commandId: string,
    failure: PiNodeCommandFailure,
  ): PiNodePromptAdmission {
    const copiedFailure = copyFailure(failure);
    this.#emit(entry, {
      type: "command-completed",
      commandId,
      outcome: "rejected",
      failure: copiedFailure,
    });
    return Object.freeze({
      sessionId: entry.backend.sessionId,
      commandId,
      status: "rejected",
      failure: copiedFailure,
    });
  }

  #snapshot(entry: RegistryEntry): PiNodeSessionSnapshot {
    const snapshot = entry.backend.getSnapshot();
    return Object.freeze({
      ...copySummary(snapshot, entry.running),
      persistence: "persistent",
      messages: Object.freeze(snapshot.messages.map(copyMessage)),
      lastEventSequence: this.#lastSequenceBySession.get(entry.backend.sessionId) ?? 0,
    });
  }

  #emit(entry: RegistryEntry, payload: PiNodeSessionEventPayload): void {
    const sessionId = entry.backend.sessionId;
    const sequence = (this.#lastSequenceBySession.get(sessionId) ?? 0) + 1;
    this.#lastSequenceBySession.set(sessionId, sequence);
    const event = Object.freeze({
      ...payload,
      sessionId,
      sequence,
      emittedAtMs: this.#clock(),
    }) as PiNodeSessionEvent;

    for (const listener of [...entry.listeners]) {
      try {
        listener(event);
      } catch {
        // A transport listener cannot interrupt domain state progression.
      }
    }
  }

  async #closeProjectSessions(canonicalCwd: string): Promise<void> {
    const entries = [...this.#sessions.values()]
      .filter((entry) => entry.backend.cwd === canonicalCwd)
      .sort((left, right) => left.backend.sessionId.localeCompare(right.backend.sessionId));
    for (const entry of entries) {
      await this.#disposeEntry(entry);
    }
  }

  async #ensureCapacity(): Promise<void> {
    if (this.#sessions.size < this.#maxOpenSessions) {
      return;
    }

    const candidate = [...this.#sessions.values()]
      .filter(
        (entry) =>
          entry.activeCommand === undefined &&
          !entry.running &&
          !entry.backend.isRunning &&
          entry.listeners.size === 0,
      )
      .sort((left, right) => left.lastTouched - right.lastTouched)[0];
    if (!candidate) {
      throw new PiNodeDomainError(
        "session-capacity-exceeded",
        "All loaded sessions are active or observed; no session can be evicted safely.",
      );
    }

    await this.#disposeEntry(candidate);
  }

  async #disposeEntry(entry: RegistryEntry): Promise<void> {
    const sessionId = entry.backend.sessionId;
    if (this.#sessions.get(sessionId) !== entry) {
      return;
    }

    this.#sessions.delete(sessionId);
    entry.listeners.clear();
    entry.unsubscribeBackend();
    try {
      await entry.backend.dispose();
    } catch (error) {
      throw new PiNodeDomainError(
        "session-dispose-failed",
        "The session backend did not dispose cleanly.",
        { cause: error },
      );
    } finally {
      entry.lease.release();
    }
  }

  #requireLoadedSession(sessionId: string): RegistryEntry {
    const entry = this.#sessions.get(sessionId);
    if (!entry) {
      throw new PiNodeDomainError("session-not-loaded", "The session is not loaded.");
    }
    return entry;
  }

  #touch(entry: RegistryEntry): void {
    entry.lastTouched = ++this.#touchCounter;
  }

  #assertAvailable(): void {
    if (this.#disposeRequested) {
      throw new PiNodeDomainError("service-disposed", "The Pi Node domain service is disposed.");
    }
  }
}

type PiNodeSessionEventPayload = PiNodeSessionEvent extends infer Event
  ? Event extends PiNodeEventBase
    ? Omit<Event, keyof PiNodeEventBase>
    : never
  : never;

function requireIdentifier(value: string, name: string): string {
  const normalized = value.trim();
  if (normalized.length === 0) {
    throw new TypeError(`${name} must not be empty.`);
  }
  return normalized;
}

function sessionOwnershipKey(cwd: string, sessionId: string): string {
  return `${cwd}\u0000${sessionId}`;
}

function copySummary(summary: PiNodeSessionSummary, running: boolean): PiNodeSessionSummary {
  return Object.freeze({
    sessionId: summary.sessionId,
    cwd: summary.cwd,
    ...(summary.name === undefined ? {} : { name: summary.name }),
    createdAtMs: summary.createdAtMs,
    modifiedAtMs: summary.modifiedAtMs,
    messageCount: summary.messageCount,
    firstMessage: summary.firstMessage,
    running,
  });
}

function copyMessage(
  message: import("./pi-node-domain.js").PiNodeMessage,
): import("./pi-node-domain.js").PiNodeMessage {
  return structuredClone(message);
}

function copyFailure(failure: PiNodeCommandFailure): PiNodeCommandFailure {
  return Object.freeze({ code: failure.code, message: failure.message });
}

function safeRuntimeFailure(error: unknown): PiNodeCommandFailure {
  if (
    typeof error === "object" &&
    error !== null &&
    "code" in error &&
    "message" in error &&
    typeof error.code === "string" &&
    typeof error.message === "string"
  ) {
    const supportedCodes = new Set([
      "invalid-prompt",
      "session-busy",
      "model-unavailable",
      "provider-auth-required",
      "prompt-rejected",
      "runtime-failed",
      "aborted",
    ]);
    if (supportedCodes.has(error.code)) {
      return Object.freeze({
        code: error.code as PiNodeCommandFailure["code"],
        message: error.message,
      });
    }
  }
  return Object.freeze({
    code: "runtime-failed",
    message: "The command failed in the session runtime.",
  });
}

function safeTrustMessage(code: PiNodeDomainError["code"]): string {
  switch (code) {
    case "invalid-project-path":
      return "The project path could not be canonicalized.";
    case "project-trust-denied":
      return "The project trust decision denied access.";
    case "project-trust-unresolved":
      return "The project requires an explicit trust decision.";
    default:
      return "Project trust could not be resolved.";
  }
}

function hasErrorCode(error: unknown, code: string): boolean {
  return typeof error === "object" && error !== null && "code" in error && error.code === code;
}

function wrapDomainError(
  error: unknown,
  code: PiNodeDomainError["code"],
  message: string,
): PiNodeDomainError {
  if (error instanceof PiNodeDomainError) {
    return error;
  }
  return new PiNodeDomainError(code, message, { cause: error });
}

async function disposeAfterRegistrationFailure(
  backend: PiNodeDomainSessionBackend,
  registrationError: unknown,
): Promise<never> {
  try {
    await backend.dispose();
  } catch (disposeError) {
    throw new PiNodeDomainError(
      "session-dispose-failed",
      "Session registration failed and the backend could not be disposed.",
      { cause: new AggregateError([registrationError, disposeError]) },
    );
  }
  throw registrationError;
}
