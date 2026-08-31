import { createHash, createHmac, randomBytes, timingSafeEqual } from "node:crypto";
import { existsSync } from "node:fs";
import { basename, resolve } from "node:path";

import {
  type AgentSession,
  type AgentSessionEvent,
  type AgentSessionRuntime,
  type CreateAgentSessionRuntimeFactory,
  createAgentSessionFromServices,
  createAgentSessionRuntime,
  createAgentSessionServices,
  getAgentDir,
  type SessionEntry,
  type SessionInfo,
  SessionManager,
  SettingsManager,
} from "@earendil-works/pi-coding-agent";

import {
  type PiNodeCommandCompletion,
  type PiNodeCommandFailure,
  type PiNodeDomainSessionBackend,
  type PiNodeDomainSessionBackendFactory,
  type PiNodeJsonValue,
  type PiNodeMessage,
  type PiNodeMessagePart,
  type PiNodeMessageUsage,
  type PiNodePromptExecution,
  type PiNodeSessionBackendEvent,
  type PiNodeSessionBackendMutationResult,
  type PiNodeSessionBackendSnapshot,
  type PiNodeSessionExportFormat,
  type PiNodeSessionHistoryPage,
  type PiNodeSessionStats,
  type PiNodeSessionSummary,
  type PiNodeSessionTreeEntryKind,
  type PiNodeSessionTreeNode,
  type PiNodeSessionTreeSnapshot,
} from "./pi-node-domain.js";
import {
  assertProjectTrustAuthorization,
  type ProjectTrustAuthorization,
} from "./project-trust.js";
import { assertRuntimeCompatibility } from "./runtime-metadata.js";
import {
  createSessionAdminRevision,
  PublicPiSdkSessionAdministration,
  sessionInfoToSummary,
} from "./pi-sdk-session-administration.js";

export type PiSdkDomainAdapterErrorCode =
  | "agent-dir-mismatch"
  | "session-not-found"
  | "session-id-ambiguous"
  | "session-creation-failed"
  | "session-disposal-failed"
  | "session-tree-entry-invalid"
  | "session-clone-ineligible"
  | "session-mutation-conflict"
  | "session-mutation-locked"
  | "session-mutation-cancelled"
  | "session-mutation-failed"
  | "session-history-cursor-invalid"
  | "session-history-conflict"
  | "session-export-failed";

export class PiSdkDomainAdapterError extends Error {
  constructor(
    readonly code: PiSdkDomainAdapterErrorCode,
    message: string,
    options?: ErrorOptions,
  ) {
    super(message, options);
    this.name = "PiSdkDomainAdapterError";
  }
}

export interface PublicPiSdkDomainSessionFactoryOptions {
  readonly clock?: () => number;
}

export class PublicPiSdkDomainSessionFactory implements PiNodeDomainSessionBackendFactory {
  readonly #clock: () => number;
  readonly #administration = new PublicPiSdkSessionAdministration();

  constructor(options: PublicPiSdkDomainSessionFactoryOptions = {}) {
    this.#clock = options.clock ?? Date.now;
  }

  async listPersistentSessions(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
  }): Promise<readonly PiNodeSessionSummary[]> {
    assertRuntimeCompatibility();
    assertProjectTrustAuthorization(input.authorization);
    const settingsManager = SettingsManager.create(input.authorization.cwd, input.agentDir, {
      projectTrusted: input.authorization.projectResourcesAllowed,
    });
    const sessionDir = resolveSessionDirectory(settingsManager, input.agentDir);
    const sessions = await SessionManager.list(input.authorization.cwd, sessionDir);
    const parentIds = parentSessionIdsByChildPath(sessions);
    return Object.freeze(
      sessions.map((session) => sessionInfoToSummary(session, parentIds.get(session.path))),
    );
  }

  renamePersistentSession(
    input: Parameters<PublicPiSdkSessionAdministration["renamePersistentSession"]>[0],
  ): Promise<PiNodeSessionSummary> {
    return this.#administration.renamePersistentSession(input);
  }

  clearPersistentSessionName(
    input: Parameters<PublicPiSdkSessionAdministration["clearPersistentSessionName"]>[0],
  ): Promise<PiNodeSessionSummary> {
    return this.#administration.clearPersistentSessionName(input);
  }

  autoNamePersistentSession(
    input: Parameters<PublicPiSdkSessionAdministration["autoNamePersistentSession"]>[0],
  ): Promise<PiNodeSessionSummary> {
    return this.#administration.autoNamePersistentSession(input);
  }

  deletePersistentSession(
    input: Parameters<PublicPiSdkSessionAdministration["deletePersistentSession"]>[0],
  ): ReturnType<PublicPiSdkSessionAdministration["deletePersistentSession"]> {
    return this.#administration.deletePersistentSession(input);
  }

  createPersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
  }): Promise<PiNodeDomainSessionBackend> {
    assertRuntimeCompatibility();
    assertProjectTrustAuthorization(input.authorization);
    return this.#createBackend(input, (sessionDir) =>
      SessionManager.create(input.authorization.cwd, sessionDir),
    );
  }

  async openPersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
    readonly sessionId: string;
  }): Promise<PiNodeDomainSessionBackend> {
    assertRuntimeCompatibility();
    assertProjectTrustAuthorization(input.authorization);

    const settingsManager = SettingsManager.create(input.authorization.cwd, input.agentDir, {
      projectTrusted: input.authorization.projectResourcesAllowed,
    });
    const sessionDir = resolveSessionDirectory(settingsManager, input.agentDir);
    const sessions = await SessionManager.list(input.authorization.cwd, sessionDir);
    const matches = sessions.filter((session) => session.id === input.sessionId);
    if (matches.length === 0) {
      throw new PiSdkDomainAdapterError(
        "session-not-found",
        "The persistent session could not be found.",
      );
    }
    if (matches.length > 1) {
      throw new PiSdkDomainAdapterError(
        "session-id-ambiguous",
        "More than one persistent session has the requested identifier.",
      );
    }

    const match = matches[0];
    if (!match) {
      throw new PiSdkDomainAdapterError(
        "session-not-found",
        "The persistent session could not be found.",
      );
    }

    return this.#createBackendWithSettings(
      input,
      SessionManager.open(match.path, sessionDir, input.authorization.cwd),
      match,
      parentSessionIdsByChildPath(sessions).get(match.path),
    );
  }

  async #createBackend(
    input: {
      readonly authorization: ProjectTrustAuthorization;
      readonly agentDir: string;
    },
    createSessionManager: (sessionDir: string | undefined) => SessionManager,
  ): Promise<PiNodeDomainSessionBackend> {
    const settingsManager = SettingsManager.create(input.authorization.cwd, input.agentDir, {
      projectTrusted: input.authorization.projectResourcesAllowed,
    });
    const sessionDir = resolveSessionDirectory(settingsManager, input.agentDir);
    return this.#createBackendWithSettings(input, createSessionManager(sessionDir));
  }

  async #createBackendWithSettings(
    input: {
      readonly authorization: ProjectTrustAuthorization;
      readonly agentDir: string;
    },
    sessionManager: SessionManager,
    sessionInfo?: SessionInfo,
    parentSessionId?: string,
  ): Promise<PiNodeDomainSessionBackend> {
    const createRuntime: CreateAgentSessionRuntimeFactory = async ({
      cwd,
      agentDir,
      sessionManager: replacementManager,
      sessionStartEvent,
    }) => {
      if (resolve(cwd) !== resolve(input.authorization.cwd)) {
        throw new PiSdkDomainAdapterError(
          "session-creation-failed",
          "Session replacement crossed the authorized project boundary.",
        );
      }
      const settingsManager = SettingsManager.create(cwd, agentDir, {
        projectTrusted: input.authorization.projectResourcesAllowed,
      });
      const services = await createAgentSessionServices({
        cwd,
        agentDir,
        settingsManager,
        resourceLoaderOptions: {
          noContextFiles: !input.authorization.projectResourcesAllowed,
        },
      });
      const result = await createAgentSessionFromServices({
        services,
        sessionManager: replacementManager,
        ...(sessionStartEvent === undefined ? {} : { sessionStartEvent }),
        noTools: "all",
      });
      return {
        ...result,
        services,
        diagnostics: services.diagnostics,
      };
    };

    try {
      const runtime = await createAgentSessionRuntime(createRuntime, {
        cwd: input.authorization.cwd,
        agentDir: input.agentDir,
        sessionManager,
      });
      return new PublicPiSdkDomainSession(runtime, sessionInfo, parentSessionId, this.#clock);
    } catch (error) {
      throw new PiSdkDomainAdapterError(
        "session-creation-failed",
        "The public Pi SDK session runtime could not be created.",
        { cause: error },
      );
    }
  }
}

class PublicPiSdkDomainSession implements PiNodeDomainSessionBackend {
  readonly persistence = "persistent" as const;
  readonly #runtime: AgentSessionRuntime;
  readonly #initialSessionInfo: SessionInfo | undefined;
  readonly #clock: () => number;
  readonly #listeners = new Set<(event: PiNodeSessionBackendEvent) => void>();
  readonly #historyCursorKey = randomBytes(32);

  #parentSessionId: string | undefined;
  #messageIds = new WeakMap<object, string>();
  #unsubscribeSdk: () => void = () => {};
  #messageOrdinal = 0;
  #running = false;
  #promptInFlight = false;
  #mutationInFlight = false;
  #disposed = false;
  #disposePromise: Promise<void> | undefined;

  constructor(
    runtime: AgentSessionRuntime,
    sessionInfo: SessionInfo | undefined,
    parentSessionId: string | undefined,
    clock: () => number,
  ) {
    this.#runtime = runtime;
    this.#initialSessionInfo = sessionInfo;
    this.#parentSessionId = parentSessionId;
    this.#clock = clock;
    this.#bindSdkSession(runtime.session);
    runtime.setRebindSession(async (session) => this.#bindSdkSession(session));
  }

  get #session(): AgentSession {
    return this.#runtime.session;
  }

  get sessionId(): string {
    return this.#session.sessionId;
  }

  get cwd(): string {
    return this.#session.sessionManager.getCwd();
  }

  get isRunning(): boolean {
    return this.#running || this.#promptInFlight || !this.#session.isIdle;
  }

  getSnapshot(): PiNodeSessionBackendSnapshot {
    const { summary, branchEntries } = this.#summaryAndBranch();
    return Object.freeze({
      ...summary,
      persistence: "persistent",
      messages: Object.freeze(
        branchEntries.flatMap((entry) => normalizeSessionEntry(entry, this.#clock)),
      ),
    });
  }

  getHistoryPage(input: {
    readonly cursor?: string;
    readonly limit: number;
    readonly expectedActiveBranchRevision?: string;
    readonly expectedTreeRevision?: string;
  }): PiNodeSessionHistoryPage {
    this.#assertNotDisposed();
    if (!Number.isSafeInteger(input.limit) || input.limit < 1 || input.limit > 200) {
      throw new PiSdkDomainAdapterError(
        "session-history-cursor-invalid",
        "The session history limit is outside the supported bounds.",
      );
    }
    const { summary, branchEntries } = this.#summaryAndBranch();
    const revisions = this.#currentRevisions(summary);
    this.#assertExpectedRevisions(input, revisions);
    const messageEntries = branchEntries.filter(
      (entry) => entry.type === "message" || entry.type === "custom_message",
    );
    const endExclusive =
      input.cursor === undefined
        ? messageEntries.length
        : this.#decodeHistoryCursor(input.cursor, revisions, messageEntries.length);
    const start = Math.max(0, endExclusive - input.limit);
    const messages = messageEntries
      .slice(start, endExclusive)
      .flatMap((entry) => normalizeSessionEntry(entry, this.#clock));
    const hasMore = start > 0;
    return Object.freeze({
      summary,
      messages: Object.freeze(messages),
      ...(hasMore ? { nextCursor: this.#encodeHistoryCursor(start, revisions) } : {}),
      hasMore,
      activeBranchRevision: revisions.activeBranchRevision,
      treeRevision: revisions.treeRevision,
      lastEventSequence: 0,
    });
  }

  getStats(input: {
    readonly project: import("./pi-node-domain.js").PiNodeProjectSnapshot;
  }): PiNodeSessionStats {
    this.#assertNotDisposed();
    const stats = this.#session.getSessionStats();
    const contextUsage = stats.contextUsage;
    const contextTokens = contextUsage?.tokens ?? undefined;
    return Object.freeze({
      projection: Object.freeze({
        sessionFileName: basename(stats.sessionFile ?? `${stats.sessionId}.jsonl`),
        sessionId: stats.sessionId,
        projectId: input.project.identity.projectId,
        canonicalProjectDirectory: input.project.identity.canonicalCwd,
        worktreeId: input.project.identity.worktreeId,
        mainProjectId: input.project.identity.mainProjectId,
        ...(input.project.identity.branch === undefined
          ? {}
          : { branch: input.project.identity.branch }),
        isLinkedWorktree: input.project.identity.isLinkedWorktree,
        isDetachedHead: input.project.identity.isDetachedHead,
      }),
      userMessages: stats.userMessages,
      assistantMessages: stats.assistantMessages,
      toolCalls: stats.toolCalls,
      toolResults: stats.toolResults,
      totalMessages: stats.totalMessages,
      inputTokens: stats.tokens.input,
      outputTokens: stats.tokens.output,
      cacheReadTokens: stats.tokens.cacheRead,
      cacheWriteTokens: stats.tokens.cacheWrite,
      totalTokens: stats.tokens.total,
      cost: stats.cost,
      ...(contextUsage === undefined ? {} : { contextWindow: contextUsage.contextWindow }),
      ...(contextTokens === undefined ? {} : { contextTokens }),
      ...(contextUsage?.percent == null ? {} : { contextPercent: contextUsage.percent }),
      activeTimeMillis: calculateSessionActiveTimeMillis(this.#session.sessionManager.getEntries()),
    });
  }

  async exportToPath(input: {
    readonly format: PiNodeSessionExportFormat;
    readonly outputPath: string;
    readonly expectedActiveBranchRevision?: string;
    readonly expectedTreeRevision?: string;
  }): Promise<void> {
    this.#assertNotDisposed();
    if (this.isRunning || this.#mutationInFlight) {
      throw new PiSdkDomainAdapterError(
        "session-history-conflict",
        "The session must be idle before export.",
      );
    }
    const before = this.#summaryAndBranch().summary;
    const revisions = this.#currentRevisions(before);
    this.#assertExpectedRevisions(input, revisions);
    try {
      if (input.format === "html") {
        await this.#session.exportToHtml(input.outputPath);
      } else {
        this.#session.exportToJsonl(input.outputPath);
      }
    } catch (error) {
      throw new PiSdkDomainAdapterError(
        "session-export-failed",
        "The public Pi SDK session export failed.",
        { cause: error },
      );
    }
    const after = this.#summaryAndBranch().summary;
    const afterRevisions = this.#currentRevisions(after);
    if (
      afterRevisions.activeBranchRevision !== revisions.activeBranchRevision ||
      afterRevisions.treeRevision !== revisions.treeRevision
    ) {
      throw new PiSdkDomainAdapterError(
        "session-history-conflict",
        "The session changed during export.",
      );
    }
  }

  #summaryAndBranch(): {
    readonly summary: PiNodeSessionSummary;
    readonly branchEntries: SessionEntry[];
  } {
    const manager = this.#session.sessionManager;
    const header = manager.getHeader();
    const branchEntries = manager.getBranch();
    const sessionInfo =
      this.#initialSessionInfo?.id === this.sessionId ? this.#initialSessionInfo : undefined;
    const createdAtMs =
      sessionInfo?.created.getTime() ?? parseTimestamp(header?.timestamp, this.#clock());
    const modifiedAtMs =
      sessionInfo?.modified.getTime() ??
      parseTimestamp(branchEntries.at(-1)?.timestamp ?? header?.timestamp, createdAtMs);
    const messageEntries = branchEntries.filter(
      (entry) => entry.type === "message" || entry.type === "custom_message",
    );
    const firstUserEntry = messageEntries.find(
      (entry) => entry.type === "message" && entry.message.role === "user",
    );
    const firstMessage =
      firstUserEntry?.type === "message" ? messageContentText(firstUserEntry.message) : "";
    const base = {
      sessionId: this.sessionId,
      cwd: this.cwd,
      ...(this.#session.sessionName === undefined ? {} : { name: this.#session.sessionName }),
      ...(this.#parentSessionId === undefined ? {} : { parentSessionId: this.#parentSessionId }),
      createdAtMs,
      modifiedAtMs,
      messageCount: messageEntries.length,
      firstMessage,
      running: this.isRunning,
    };
    return Object.freeze({
      summary: Object.freeze({
        ...base,
        adminRevision: createSessionAdminRevision(base),
      }),
      branchEntries,
    });
  }

  #currentRevisions(summary: PiNodeSessionSummary): SessionHistoryRevisions {
    const tree = sessionManagerToTreeSnapshot(this.#session.sessionManager, summary);
    return Object.freeze({
      treeRevision: tree.adminRevision,
      activeBranchRevision: createHash("sha256")
        .update(JSON.stringify([tree.adminRevision, tree.activePathEntryIds]))
        .digest("hex"),
    });
  }

  #assertExpectedRevisions(
    input: {
      readonly expectedActiveBranchRevision?: string;
      readonly expectedTreeRevision?: string;
    },
    revisions: SessionHistoryRevisions,
  ): void {
    if (
      (input.expectedActiveBranchRevision !== undefined &&
        input.expectedActiveBranchRevision !== revisions.activeBranchRevision) ||
      (input.expectedTreeRevision !== undefined &&
        input.expectedTreeRevision !== revisions.treeRevision)
    ) {
      throw new PiSdkDomainAdapterError(
        "session-history-conflict",
        "The active session branch changed.",
      );
    }
  }

  #encodeHistoryCursor(endExclusive: number, revisions: SessionHistoryRevisions): string {
    const payload = Buffer.from(
      JSON.stringify({
        version: 1,
        sessionId: this.sessionId,
        endExclusive,
        activeBranchRevision: revisions.activeBranchRevision,
        treeRevision: revisions.treeRevision,
      }),
      "utf8",
    ).toString("base64url");
    const signature = createHmac("sha256", this.#historyCursorKey)
      .update(payload)
      .digest("base64url");
    return `${payload}.${signature}`;
  }

  #decodeHistoryCursor(
    cursor: string,
    revisions: SessionHistoryRevisions,
    messageCount: number,
  ): number {
    const [payload, signature, extra] = cursor.split(".");
    if (!payload || !signature || extra !== undefined) {
      throw new PiSdkDomainAdapterError(
        "session-history-cursor-invalid",
        "The session history cursor is malformed.",
      );
    }
    const expected = createHmac("sha256", this.#historyCursorKey).update(payload).digest();
    let supplied: Buffer;
    try {
      supplied = Buffer.from(signature, "base64url");
    } catch {
      throw new PiSdkDomainAdapterError(
        "session-history-cursor-invalid",
        "The session history cursor signature is malformed.",
      );
    }
    if (supplied.length !== expected.length || !timingSafeEqual(supplied, expected)) {
      throw new PiSdkDomainAdapterError(
        "session-history-cursor-invalid",
        "The session history cursor signature is invalid.",
      );
    }
    let decoded: unknown;
    try {
      decoded = JSON.parse(Buffer.from(payload, "base64url").toString("utf8"));
    } catch {
      throw new PiSdkDomainAdapterError(
        "session-history-cursor-invalid",
        "The session history cursor payload is invalid.",
      );
    }
    if (
      !isRecord(decoded) ||
      decoded.version !== 1 ||
      decoded.sessionId !== this.sessionId ||
      decoded.activeBranchRevision !== revisions.activeBranchRevision ||
      decoded.treeRevision !== revisions.treeRevision ||
      !Number.isSafeInteger(decoded.endExclusive) ||
      (decoded.endExclusive as number) < 1 ||
      (decoded.endExclusive as number) > messageCount
    ) {
      throw new PiSdkDomainAdapterError(
        "session-history-cursor-invalid",
        "The session history cursor no longer matches this branch.",
      );
    }
    return decoded.endExclusive as number;
  }

  subscribe(listener: (event: PiNodeSessionBackendEvent) => void): () => void {
    this.#assertNotDisposed();
    this.#listeners.add(listener);
    let subscribed = true;
    return () => {
      if (!subscribed) {
        return;
      }
      subscribed = false;
      this.#listeners.delete(listener);
    };
  }

  async startPrompt(input: { readonly text: string }): Promise<PiNodePromptExecution> {
    this.#assertNotDisposed();
    if (this.isRunning || this.#mutationInFlight) {
      const failure = Object.freeze({
        code: "session-busy" as const,
        message: "The session already has an active command.",
      });
      return Object.freeze({
        admission: Object.freeze({ status: "rejected" as const, failure }),
        completion: Promise.resolve({ outcome: "failed" as const, failure }),
      });
    }

    this.#promptInFlight = true;
    let resolvePreflight: ((accepted: boolean) => void) | undefined;
    const preflight = new Promise<boolean>((resolvePreflightPromise) => {
      resolvePreflight = resolvePreflightPromise;
    });
    let preflightObserved = false;
    const promptPromise = this.#session.prompt(input.text, {
      preflightResult: (accepted) => {
        if (preflightObserved) {
          return;
        }
        preflightObserved = true;
        resolvePreflight?.(accepted);
      },
    });
    const completion = promptPromise
      .then(
        () => this.#completionFromSession(),
        (error: unknown) => ({ outcome: "failed" as const, failure: classifySdkFailure(error) }),
      )
      .finally(() => {
        this.#promptInFlight = false;
      });

    const signal = await Promise.race([
      preflight.then((accepted) => ({ type: "preflight" as const, accepted })),
      promptPromise.then(
        () => ({ type: "settled" as const }),
        (error: unknown) => ({ type: "settled-error" as const, error }),
      ),
    ]);

    if (signal.type === "preflight" && signal.accepted) {
      return Object.freeze({
        admission: Object.freeze({ status: "accepted" as const }),
        completion,
      });
    }

    if (signal.type === "preflight" && !signal.accepted) {
      const settled = await completion;
      const failure =
        settled.failure ??
        Object.freeze({
          code: "prompt-rejected" as const,
          message: "The prompt was rejected before execution.",
        });
      return Object.freeze({
        admission: Object.freeze({ status: "rejected" as const, failure }),
        completion,
      });
    }

    if (signal.type === "settled-error") {
      const failure = classifySdkFailure(signal.error);
      return Object.freeze({
        admission: Object.freeze({ status: "rejected" as const, failure }),
        completion,
      });
    }

    return Object.freeze({
      admission: Object.freeze({
        status: "uncertain" as const,
        failure: Object.freeze({
          code: "runtime-failed" as const,
          message: "Prompt admission was not observed before the command settled.",
        }),
      }),
      completion,
    });
  }

  async abort(): Promise<boolean> {
    this.#assertNotDisposed();
    if (!this.isRunning) {
      return false;
    }
    await this.#session.abort();
    return true;
  }

  getTreeSnapshot(): PiNodeSessionTreeSnapshot {
    this.#assertNotDisposed();
    return sessionManagerToTreeSnapshot(this.#session.sessionManager, this.getSnapshot());
  }

  navigateSessionTree(input: {
    readonly entryId: string;
    readonly expectedAdminRevision: string;
  }): Promise<PiNodeSessionBackendMutationResult> {
    return this.#runSessionMutation(input.expectedAdminRevision, async () => {
      const entry = this.#session.sessionManager.getEntry(input.entryId);
      if (!entry) {
        throw new PiSdkDomainAdapterError(
          "session-tree-entry-invalid",
          "The selected session tree entry does not exist.",
        );
      }
      const result = await this.#session.navigateTree(input.entryId, { summarize: false });
      if (result.cancelled || result.aborted) {
        throw new PiSdkDomainAdapterError(
          "session-mutation-cancelled",
          "Session tree navigation was cancelled.",
        );
      }
      return result.editorText;
    });
  }

  forkFromUserEntry(input: {
    readonly userEntryId: string;
    readonly expectedAdminRevision: string;
  }): Promise<PiNodeSessionBackendMutationResult> {
    return this.#runSessionMutation(input.expectedAdminRevision, async () => {
      const entry = this.#session.sessionManager.getEntry(input.userEntryId);
      if (entry?.type !== "message" || entry.message.role !== "user") {
        throw new PiSdkDomainAdapterError(
          "session-tree-entry-invalid",
          "Fork requires a user-message entry.",
        );
      }
      const previousSessionId = this.sessionId;
      const result = await this.#runtime.fork(input.userEntryId);
      if (result.cancelled) {
        throw new PiSdkDomainAdapterError(
          "session-mutation-cancelled",
          "Session fork was cancelled.",
        );
      }
      if (this.sessionId === previousSessionId) {
        throw new PiSdkDomainAdapterError(
          "session-mutation-failed",
          "Session fork did not replace the active runtime.",
        );
      }
      this.#parentSessionId = previousSessionId;
      return result.selectedText;
    });
  }

  cloneActiveBranch(input: {
    readonly expectedAdminRevision: string;
  }): Promise<PiNodeSessionBackendMutationResult> {
    return this.#runSessionMutation(input.expectedAdminRevision, async () => {
      const manager = this.#session.sessionManager;
      const leafId = manager.getLeafId();
      if (
        leafId === null ||
        !manager
          .getBranch()
          .some((entry) => entry.type === "message" && entry.message.role === "user")
      ) {
        throw new PiSdkDomainAdapterError(
          "session-clone-ineligible",
          "The active branch does not contain a cloneable user turn.",
        );
      }
      const previousSessionId = this.sessionId;
      const result = await this.#runtime.fork(leafId, { position: "at" });
      if (result.cancelled) {
        throw new PiSdkDomainAdapterError(
          "session-mutation-cancelled",
          "Session clone was cancelled.",
        );
      }
      if (this.sessionId === previousSessionId) {
        throw new PiSdkDomainAdapterError(
          "session-mutation-failed",
          "Session clone did not replace the active runtime.",
        );
      }
      this.#parentSessionId = previousSessionId;
      return undefined;
    });
  }

  dispose(): Promise<void> {
    this.#disposePromise ??= this.#disposeOnce();
    return this.#disposePromise;
  }

  async #disposeOnce(): Promise<void> {
    if (this.#disposed) {
      return;
    }
    this.#disposed = true;
    this.#listeners.clear();
    this.#unsubscribeSdk();
    const errors: unknown[] = [];

    try {
      await this.#runtime.dispose();
    } catch (error) {
      errors.push(error);
    }
    const settingsManager = this.#runtime.services.settingsManager;
    try {
      await settingsManager.flush();
    } catch (error) {
      errors.push(error);
    }
    for (const settingsError of settingsManager.drainErrors()) {
      errors.push(settingsError.error);
    }

    if (errors.length > 0) {
      throw new PiSdkDomainAdapterError(
        "session-disposal-failed",
        "The public Pi SDK session did not dispose cleanly.",
        { cause: new AggregateError(errors) },
      );
    }
  }

  async #runSessionMutation(
    expectedAdminRevision: string,
    mutate: () => Promise<string | undefined>,
  ): Promise<PiNodeSessionBackendMutationResult> {
    this.#assertNotDisposed();
    if (this.#mutationInFlight) {
      throw new PiSdkDomainAdapterError(
        "session-mutation-locked",
        "Another session mutation is already active.",
      );
    }
    if (this.isRunning) {
      throw new PiSdkDomainAdapterError(
        "session-mutation-locked",
        "The session must be idle before changing its active branch.",
      );
    }
    const before = this.getSnapshot();
    const treeBefore = this.getTreeSnapshot();
    if (treeBefore.adminRevision !== expectedAdminRevision) {
      throw new PiSdkDomainAdapterError(
        "session-mutation-conflict",
        "The session changed before the mutation began.",
      );
    }

    this.#mutationInFlight = true;
    try {
      const editorText = await mutate();
      const session = this.getSnapshot();
      return Object.freeze({
        previousSessionId: before.sessionId,
        session,
        tree: this.getTreeSnapshot(),
        ...(editorText === undefined ? {} : { editorText }),
      });
    } catch (error) {
      if (error instanceof PiSdkDomainAdapterError) {
        throw error;
      }
      throw new PiSdkDomainAdapterError(
        "session-mutation-failed",
        "The public Pi SDK session mutation failed.",
        { cause: error },
      );
    } finally {
      this.#mutationInFlight = false;
    }
  }

  #bindSdkSession(session: AgentSession): void {
    this.#unsubscribeSdk();
    this.#messageIds = new WeakMap<object, string>();
    this.#messageOrdinal = 0;
    this.#running = !session.isIdle;
    this.#promptInFlight = false;
    this.#unsubscribeSdk = session.subscribe((event) => this.#handleSdkEvent(event));
  }

  #handleSdkEvent(event: AgentSessionEvent): void {
    if (this.#disposed) {
      return;
    }

    if (event.type === "agent_start") {
      this.#setRunning(true);
      return;
    }
    if (event.type === "agent_settled") {
      this.#setRunning(false);
      return;
    }
    if (
      event.type === "message_start" ||
      event.type === "message_update" ||
      event.type === "message_end"
    ) {
      const phase =
        event.type === "message_start"
          ? "started"
          : event.type === "message_update"
            ? "updated"
            : "completed";
      this.#emit({
        type: "message",
        phase,
        message: normalizePiSdkMessage(event.message, this.#messageId(event.message), this.#clock),
      });
    }
  }

  #setRunning(running: boolean): void {
    if (this.#running === running) {
      return;
    }
    this.#running = running;
    this.#emit({ type: "running", running });
  }

  #messageId(message: unknown): string {
    if (typeof message === "object" && message !== null) {
      const existing = this.#messageIds.get(message);
      if (existing) {
        return existing;
      }
      const next = `${this.sessionId}:runtime:${++this.#messageOrdinal}`;
      this.#messageIds.set(message, next);
      return next;
    }
    return `${this.sessionId}:runtime:${++this.#messageOrdinal}`;
  }

  #emit(event: PiNodeSessionBackendEvent): void {
    for (const listener of [...this.#listeners]) {
      try {
        listener(event);
      } catch {
        // The adapter keeps SDK event progression independent from its consumers.
      }
    }
  }

  #completionFromSession(): PiNodeCommandCompletion {
    const lastAssistant = ([...this.#session.messages] as unknown[])
      .reverse()
      .find(
        (message): message is Record<string, unknown> =>
          isRecord(message) && message.role === "assistant",
      );
    const stopReason =
      lastAssistant && typeof lastAssistant.stopReason === "string"
        ? lastAssistant.stopReason
        : undefined;
    if (stopReason === "aborted") {
      return Object.freeze({
        outcome: "aborted",
        failure: Object.freeze({ code: "aborted", message: "The command was aborted." }),
      });
    }
    if (stopReason === "error") {
      return Object.freeze({
        outcome: "failed",
        failure: Object.freeze({
          code: "runtime-failed",
          message: "The provider run completed with an error.",
        }),
      });
    }
    return Object.freeze({ outcome: "succeeded" });
  }

  #assertNotDisposed(): void {
    if (this.#disposed) {
      throw new PiSdkDomainAdapterError(
        "session-disposal-failed",
        "The public Pi SDK session is disposed.",
      );
    }
  }
}

export function normalizePiSdkMessage(
  input: unknown,
  messageId: string,
  clock: () => number = Date.now,
): PiNodeMessage {
  const message = isRecord(input) ? input : {};
  const sourceRole = typeof message.role === "string" ? message.role : "unknown";
  const role = normalizeRole(sourceRole);
  const parts = normalizeContent(message.content);
  const timestampMs = finiteNumber(message.timestamp, clock());
  const assistant =
    sourceRole === "assistant"
      ? Object.freeze({
          provider: stringValue(message.provider),
          model: stringValue(message.model),
          stopReason: stringValue(message.stopReason),
          ...(typeof message.errorMessage === "string"
            ? { errorMessage: message.errorMessage }
            : {}),
          ...(isRecord(message.usage) ? { usage: normalizeUsage(message.usage) } : {}),
        })
      : undefined;
  const tool =
    sourceRole === "toolResult"
      ? Object.freeze({
          callId: stringValue(message.toolCallId),
          name: stringValue(message.toolName),
          isError: message.isError === true,
        })
      : undefined;

  return Object.freeze({
    id: messageId,
    role,
    sourceRole,
    timestampMs,
    parts: Object.freeze(parts),
    ...(assistant === undefined ? {} : { assistant }),
    ...(tool === undefined ? {} : { tool }),
  });
}

function normalizeSessionEntry(entry: SessionEntry, clock: () => number): PiNodeMessage[] {
  if (entry.type === "message") {
    return [normalizePiSdkMessage(entry.message, entry.id, clock)];
  }
  if (entry.type === "custom_message") {
    return [
      normalizePiSdkMessage(
        {
          role: "custom",
          content: entry.content,
          timestamp: parseTimestamp(entry.timestamp, clock()),
        },
        entry.id,
        clock,
      ),
    ];
  }
  return [];
}

function parentSessionIdsByChildPath(
  sessions: readonly SessionInfo[],
): ReadonlyMap<string, string> {
  const idsByPath = new Map(sessions.map((session) => [resolve(session.path), session.id]));
  const result = new Map<string, string>();
  for (const session of sessions) {
    if (session.parentSessionPath === undefined) continue;
    const parentId = idsByPath.get(resolve(session.parentSessionPath));
    if (parentId !== undefined) result.set(session.path, parentId);
  }
  return result;
}

export function sessionManagerToTreeSnapshot(
  manager: SessionManager,
  summary: PiNodeSessionSummary,
): PiNodeSessionTreeSnapshot {
  const entries = manager.getEntries();
  const byId = new Map(entries.map((entry) => [entry.id, entry]));
  const childrenById = new Map<string, string[]>();
  const roots: string[] = [];
  for (const entry of entries) {
    const parentId = entry.parentId;
    if (parentId === null || parentId === entry.id || !byId.has(parentId)) {
      roots.push(entry.id);
      continue;
    }
    const children = childrenById.get(parentId) ?? [];
    children.push(entry.id);
    childrenById.set(parentId, children);
  }

  const depthById = new Map<string, number>();
  const queue = roots.map((entryId) => ({ entryId, depth: 0 }));
  for (let index = 0; index < queue.length; index += 1) {
    const current = queue[index]!;
    if (depthById.has(current.entryId)) continue;
    depthById.set(current.entryId, current.depth);
    for (const childId of childrenById.get(current.entryId) ?? []) {
      queue.push({ entryId: childId, depth: current.depth + 1 });
    }
  }
  for (const entry of entries) {
    if (!depthById.has(entry.id)) depthById.set(entry.id, 0);
  }

  const activePath = manager.getBranch();
  const activePathEntryIds = activePath.map((entry) => entry.id);
  const activeIds = new Set(activePathEntryIds);
  const sessionFile = manager.getSessionFile();
  const sourceFileAvailable =
    !manager.isPersisted() || (sessionFile !== undefined && existsSync(sessionFile));
  const nodes = entries.map((entry): PiNodeSessionTreeNode => {
    const kind = sessionTreeEntryKind(entry);
    const label = manager.getLabel(entry.id);
    return Object.freeze({
      entryId: entry.id,
      ...(entry.parentId === null ? {} : { parentEntryId: entry.parentId }),
      kind,
      text: sessionTreeEntryText(entry),
      createdAtMs: parseTimestamp(entry.timestamp, 1),
      ...(label === undefined ? {} : { label }),
      depth: depthById.get(entry.id) ?? 0,
      isOnActivePath: activeIds.has(entry.id),
      hasChildren: (childrenById.get(entry.id)?.length ?? 0) > 0,
      canEditFromHere: kind === "user-message",
      canFork: kind === "user-message" && (entry.parentId === null || sourceFileAvailable),
    });
  });
  const canCloneActiveBranch =
    sourceFileAvailable &&
    manager.getLeafId() !== null &&
    activePath.some((entry) => entry.type === "message" && entry.message.role === "user");
  return Object.freeze({
    sessionId: summary.sessionId,
    nodes: Object.freeze(nodes),
    activePathEntryIds: Object.freeze(activePathEntryIds),
    ...(manager.getLeafId() === null ? {} : { activeLeafEntryId: manager.getLeafId()! }),
    canCloneActiveBranch,
    adminRevision: createSessionTreeRevision(
      summary.adminRevision,
      manager.getLeafId(),
      entries.length,
    ),
  });
}

function createSessionTreeRevision(
  sessionAdminRevision: string,
  activeLeafEntryId: string | null,
  entryCount: number,
): string {
  return createHash("sha256")
    .update(JSON.stringify([sessionAdminRevision, activeLeafEntryId, entryCount]))
    .digest("hex");
}

function sessionTreeEntryKind(entry: SessionEntry): PiNodeSessionTreeEntryKind {
  switch (entry.type) {
    case "message":
      switch (entry.message.role) {
        case "user":
          return "user-message";
        case "assistant":
          return "assistant-message";
        case "toolResult":
          return "tool-message";
        default:
          return "custom-message";
      }
    case "custom_message":
      return "custom-message";
    case "thinking_level_change":
      return "thinking-level";
    case "model_change":
      return "model-change";
    case "compaction":
      return "compaction";
    case "branch_summary":
      return "branch-summary";
    case "custom":
      return "custom";
    case "label":
      return "label";
    case "session_info":
      return "session-info";
  }
}

function sessionTreeEntryText(entry: SessionEntry): string {
  switch (entry.type) {
    case "message":
      return messageContentText(entry.message);
    case "custom_message":
      return contentText(entry.content);
    case "thinking_level_change":
      return `Thinking: ${entry.thinkingLevel}`;
    case "model_change":
      return `Model: ${entry.provider}/${entry.modelId}`;
    case "compaction":
      return entry.summary;
    case "branch_summary":
      return entry.summary;
    case "custom":
      return `Extension state: ${entry.customType}`;
    case "label":
      return entry.label?.trim() || "Label cleared";
    case "session_info":
      return entry.name?.trim() || "Session name cleared";
  }
}

function messageContentText(message: unknown): string {
  if (!isRecord(message)) return "";
  if ("content" in message) return contentText(message.content);
  if (typeof message.command === "string") return message.command;
  return "";
}

function contentText(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  return content
    .filter(
      (part): part is Record<string, unknown> =>
        isRecord(part) &&
        ((part.type === "text" && typeof part.text === "string") ||
          (part.type === "thinking" && typeof part.thinking === "string")),
    )
    .map((part) =>
      part.type === "thinking" ? String(part.thinking ?? "") : String(part.text ?? ""),
    )
    .join("");
}

function resolveSessionDirectory(
  settingsManager: SettingsManager,
  agentDir: string,
): string | undefined {
  const configuredSessionDir = settingsManager.getSessionDir();
  if (configuredSessionDir !== undefined) {
    return configuredSessionDir;
  }
  if (resolve(agentDir) !== resolve(getAgentDir())) {
    throw new PiSdkDomainAdapterError(
      "agent-dir-mismatch",
      "A non-default agent directory requires an explicit sessionDir setting.",
    );
  }
  return undefined;
}

function normalizeRole(sourceRole: string): PiNodeMessage["role"] {
  switch (sourceRole) {
    case "user":
      return "user";
    case "assistant":
      return "assistant";
    case "toolResult":
      return "tool";
    default:
      return "custom";
  }
}

function normalizeContent(content: unknown): PiNodeMessagePart[] {
  if (typeof content === "string") {
    return [Object.freeze({ type: "text", text: content })];
  }
  if (!Array.isArray(content)) {
    return [];
  }

  return content.map((part): PiNodeMessagePart => {
    if (!isRecord(part) || typeof part.type !== "string") {
      return Object.freeze({ type: "unsupported", sourceType: "unknown" });
    }
    if (part.type === "text" && typeof part.text === "string") {
      return Object.freeze({ type: "text", text: part.text });
    }
    if (part.type === "thinking" && typeof part.thinking === "string") {
      return Object.freeze({
        type: "thinking",
        text: part.redacted === true ? "" : part.thinking,
        redacted: part.redacted === true,
      });
    }
    if (
      part.type === "image" &&
      typeof part.mimeType === "string" &&
      typeof part.data === "string"
    ) {
      return Object.freeze({
        type: "image",
        mimeType: part.mimeType,
        data: part.data,
      });
    }
    if (part.type === "toolCall") {
      return Object.freeze({
        type: "tool-call",
        id: stringValue(part.id),
        name: stringValue(part.name),
        arguments: normalizeJsonValue(part.arguments),
      });
    }
    return Object.freeze({ type: "unsupported", sourceType: part.type });
  });
}

function normalizeUsage(usage: Record<string, unknown>): PiNodeMessageUsage {
  const cost = isRecord(usage.cost) ? usage.cost : {};
  return Object.freeze({
    inputTokens: finiteNumber(usage.input, 0),
    outputTokens: finiteNumber(usage.output, 0),
    cacheReadTokens: finiteNumber(usage.cacheRead, 0),
    cacheWriteTokens: finiteNumber(usage.cacheWrite, 0),
    totalTokens: finiteNumber(usage.totalTokens, 0),
    totalCost: finiteNumber(cost.total, 0),
  });
}

function normalizeJsonValue(value: unknown, depth = 0): PiNodeJsonValue {
  if (value === null || typeof value === "string" || typeof value === "boolean") {
    return value;
  }
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : String(value);
  }
  if (depth >= 20) {
    return "[depth-limit]";
  }
  if (Array.isArray(value)) {
    return Object.freeze(value.map((item) => normalizeJsonValue(item, depth + 1)));
  }
  if (isRecord(value)) {
    const normalized: Record<string, PiNodeJsonValue> = {};
    for (const key of Object.keys(value).sort()) {
      normalized[key] = normalizeJsonValue(value[key], depth + 1);
    }
    return Object.freeze(normalized);
  }
  return String(value);
}

function classifySdkFailure(error: unknown): PiNodeCommandFailure {
  const message = error instanceof Error ? error.message : "";
  if (/no model selected/i.test(message)) {
    return Object.freeze({
      code: "model-unavailable",
      message: "No model is selected for this session.",
    });
  }
  if (/api key|authentication failed|credentials/i.test(message)) {
    return Object.freeze({
      code: "provider-auth-required",
      message: "The selected provider requires authentication.",
    });
  }
  if (/already processing|compaction is in progress/i.test(message)) {
    return Object.freeze({
      code: "session-busy",
      message: "The session already has an active operation.",
    });
  }
  if (/abort/i.test(message)) {
    return Object.freeze({ code: "aborted", message: "The command was aborted." });
  }
  return Object.freeze({
    code: "prompt-rejected",
    message: "The public Pi SDK rejected the prompt before execution.",
  });
}

interface SessionHistoryRevisions {
  readonly activeBranchRevision: string;
  readonly treeRevision: string;
}

function calculateSessionActiveTimeMillis(entries: readonly SessionEntry[]): number {
  let activeStart: number | undefined;
  let lastActivity: number | undefined;
  let total = 0;
  for (const entry of entries) {
    if (entry.type !== "message") continue;
    const timestamp = parseTimestamp(entry.timestamp, Number.NaN);
    if (!Number.isFinite(timestamp)) continue;
    if (entry.message.role === "user") {
      if (activeStart !== undefined && lastActivity !== undefined) {
        total += Math.max(0, lastActivity - activeStart);
      }
      activeStart = timestamp;
      lastActivity = timestamp;
      continue;
    }
    if (activeStart !== undefined) {
      lastActivity = Math.max(lastActivity ?? timestamp, timestamp);
    }
  }
  if (activeStart !== undefined && lastActivity !== undefined) {
    total += Math.max(0, lastActivity - activeStart);
  }
  return Math.max(0, Math.floor(total));
}

function parseTimestamp(value: unknown, fallback: number): number {
  if (typeof value !== "string") {
    return fallback;
  }
  const parsed = Date.parse(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function finiteNumber(value: unknown, fallback: number): number {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function stringValue(value: unknown): string {
  return typeof value === "string" ? value : "";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
