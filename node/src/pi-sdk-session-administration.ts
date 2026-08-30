import { createHash, randomUUID } from "node:crypto";
import {
  chmod,
  copyFile,
  open,
  readFile,
  rename,
  rm,
  stat,
  unlink,
  writeFile,
} from "node:fs/promises";
import { basename, dirname, join, resolve } from "node:path";
import { setTimeout as delay } from "node:timers/promises";

import {
  convertToLlm,
  createAgentSessionServices,
  getAgentDir,
  type SessionInfo,
  SessionManager,
  SettingsManager,
} from "@earendil-works/pi-coding-agent";

import type {
  PiNodeSessionAdministrationBackend,
  PiNodeSessionDeleteResult,
  PiNodeSessionSummary,
} from "./pi-node-domain.js";
import {
  assertProjectTrustAuthorization,
  type ProjectTrustAuthorization,
} from "./project-trust.js";
import { assertRuntimeCompatibility } from "./runtime-metadata.js";

const MAX_SESSION_NAME_CHARACTERS = 120;
const MAX_AUTO_NAME_CHARACTERS = 80;
const MAX_AUTO_NAME_CONTEXT_CHARACTERS = 12_000;
const MAX_AUTO_NAME_MESSAGE_CHARACTERS = 1_200;
const MIN_AUTO_NAME_TIMEOUT_MILLIS = 1_000;
const MAX_AUTO_NAME_TIMEOUT_MILLIS = 30_000;
const AUTO_NAME_OUTPUT_TOKENS = 48;
const FILE_LOCK_TIMEOUT_MILLIS = 5_000;
const FILE_LOCK_RETRY_MILLIS = 25;

export type PiSdkSessionAdministrationErrorCode =
  | "session-not-found"
  | "session-id-ambiguous"
  | "session-name-invalid"
  | "session-admin-conflict"
  | "session-admin-locked"
  | "session-admin-write-failed"
  | "session-delete-confirmation-required"
  | "session-auto-name-empty"
  | "session-auto-name-model-unavailable"
  | "session-auto-name-provider-auth-required"
  | "session-auto-name-timeout"
  | "session-auto-name-cancelled"
  | "session-auto-name-failed";

export class PiSdkSessionAdministrationError extends Error {
  constructor(
    readonly code: PiSdkSessionAdministrationErrorCode,
    message: string,
    options?: ErrorOptions,
  ) {
    super(message, options);
    this.name = "PiSdkSessionAdministrationError";
  }
}

export interface PiSessionAutoNameGeneratorInput {
  readonly authorization: ProjectTrustAuthorization;
  readonly agentDir: string;
  readonly sessionManager: SessionManager;
  readonly timeoutMillis: number;
  readonly signal: AbortSignal;
}

export type PiSessionAutoNameGenerator = (
  input: PiSessionAutoNameGeneratorInput,
) => Promise<string>;

export interface PublicPiSdkSessionAdministrationOptions {
  readonly autoNameGenerator?: PiSessionAutoNameGenerator;
  readonly beforeAtomicCommit?: (targetPath: string) => void | Promise<void>;
  readonly lockTimeoutMillis?: number;
}

/**
 * Mutates Pi JSONL sessions without inventing a replacement format.
 *
 * Public SessionManager APIs produce session_info entries. Pi Client performs
 * those appends against a same-directory shadow copy, fsyncs it, then atomically
 * replaces the source while holding a cross-process lock.
 */
export class PublicPiSdkSessionAdministration implements PiNodeSessionAdministrationBackend {
  readonly #autoNameGenerator: PiSessionAutoNameGenerator;
  readonly #beforeAtomicCommit: ((targetPath: string) => void | Promise<void>) | undefined;
  readonly #lockTimeoutMillis: number;

  constructor(options: PublicPiSdkSessionAdministrationOptions = {}) {
    this.#autoNameGenerator = options.autoNameGenerator ?? generateSessionNameWithCurrentModel;
    this.#beforeAtomicCommit = options.beforeAtomicCommit;
    this.#lockTimeoutMillis = options.lockTimeoutMillis ?? FILE_LOCK_TIMEOUT_MILLIS;
  }

  async renamePersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
    readonly sessionId: string;
    readonly name: string;
  }): Promise<PiNodeSessionSummary> {
    const normalizedName = normalizeRequestedSessionName(input.name);
    return this.#mutateName(input, normalizedName);
  }

  async clearPersistentSessionName(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionSummary> {
    return this.#mutateName(input, "");
  }

  async autoNamePersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
    readonly sessionId: string;
    readonly timeoutMillis: number;
    readonly signal?: AbortSignal;
  }): Promise<PiNodeSessionSummary> {
    assertRuntimeCompatibility();
    assertProjectTrustAuthorization(input.authorization);
    const timeoutMillis = validateAutoNameTimeout(input.timeoutMillis);
    const located = await locateSession(input.authorization, input.agentDir, input.sessionId);
    const controller = new AbortController();
    const onAbort = () => controller.abort(input.signal?.reason);
    if (input.signal?.aborted) {
      controller.abort(input.signal.reason);
    } else {
      input.signal?.addEventListener("abort", onAbort, { once: true });
    }
    const timeout = setTimeout(
      () => controller.abort(new Error("auto-name-timeout")),
      timeoutMillis,
    );

    let generated: string;
    try {
      const manager = SessionManager.open(
        located.info.path,
        located.sessionDir,
        input.authorization.cwd,
      );
      generated = await this.#autoNameGenerator({
        authorization: input.authorization,
        agentDir: input.agentDir,
        sessionManager: manager,
        timeoutMillis,
        signal: controller.signal,
      });
    } catch (error) {
      if (controller.signal.aborted) {
        const timedOut = !input.signal?.aborted;
        throw new PiSdkSessionAdministrationError(
          timedOut ? "session-auto-name-timeout" : "session-auto-name-cancelled",
          timedOut
            ? "The bounded session naming operation exceeded its deadline."
            : "The session naming operation was cancelled.",
          { cause: error },
        );
      }
      throw classifyAutoNameError(error);
    } finally {
      clearTimeout(timeout);
      input.signal?.removeEventListener("abort", onAbort);
    }

    const sanitized = sanitizeGeneratedSessionName(generated);
    return this.#mutateName(input, sanitized);
  }

  async deletePersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
    readonly sessionId: string;
    readonly confirmation: {
      readonly sessionId: string;
      readonly adminRevision: string;
      readonly displayedTitle: string;
      readonly destructiveActionAcknowledged: boolean;
    };
  }): Promise<PiNodeSessionDeleteResult> {
    assertRuntimeCompatibility();
    assertProjectTrustAuthorization(input.authorization);
    if (
      !input.confirmation.destructiveActionAcknowledged ||
      input.confirmation.sessionId !== input.sessionId ||
      input.confirmation.displayedTitle.trim().length === 0
    ) {
      throw new PiSdkSessionAdministrationError(
        "session-delete-confirmation-required",
        "Explicit deletion confirmation evidence is required.",
      );
    }

    for (let attempt = 0; attempt < 3; attempt += 1) {
      const discovery = await discoverDeleteTransaction(
        input.authorization,
        input.agentDir,
        input.sessionId,
      );
      assertAdminRevision(discovery.target.info, input.confirmation.adminRevision);
      assertConfirmationTitle(discovery.target.info, input.confirmation.displayedTitle);
      const lockedPaths = [
        discovery.target.info.path,
        ...discovery.children.map((child) => child.path),
      ].sort();
      const releaseLocks = await acquireFileLocks(lockedPaths, this.#lockTimeoutMillis);
      try {
        const current = await discoverDeleteTransaction(
          input.authorization,
          input.agentDir,
          input.sessionId,
        );
        const currentPaths = [
          current.target.info.path,
          ...current.children.map((child) => child.path),
        ].sort();
        if (!samePaths(lockedPaths, currentPaths)) {
          continue;
        }
        assertAdminRevision(current.target.info, input.confirmation.adminRevision);
        assertConfirmationTitle(current.target.info, input.confirmation.displayedTitle);
        return await this.#commitDelete(current, input.sessionId);
      } finally {
        await releaseLocks();
      }
    }

    throw new PiSdkSessionAdministrationError(
      "session-admin-conflict",
      "The session family changed during deletion. Refresh and confirm again.",
    );
  }

  async #mutateName(
    input: {
      readonly authorization: ProjectTrustAuthorization;
      readonly agentDir: string;
      readonly sessionId: string;
    },
    name: string,
  ): Promise<PiNodeSessionSummary> {
    assertRuntimeCompatibility();
    assertProjectTrustAuthorization(input.authorization);
    const located = await locateSession(input.authorization, input.agentDir, input.sessionId);
    const releaseLocks = await acquireFileLocks([located.info.path], this.#lockTimeoutMillis);
    try {
      const current = await locateSession(input.authorization, input.agentDir, input.sessionId);
      await atomicSessionManagerMutation(
        current.info.path,
        current.sessionDir,
        input.authorization.cwd,
        (manager) => manager.appendSessionInfo(name),
        this.#beforeAtomicCommit,
      );
    } catch (error) {
      if (error instanceof PiSdkSessionAdministrationError) {
        throw error;
      }
      throw new PiSdkSessionAdministrationError(
        "session-admin-write-failed",
        "The session metadata could not be written atomically.",
        { cause: error },
      );
    } finally {
      await releaseLocks();
    }

    const updated = await locateSession(input.authorization, input.agentDir, input.sessionId);
    return sessionInfoToSummary(updated.info);
  }

  async #commitDelete(
    transaction: DeleteTransaction,
    sessionId: string,
  ): Promise<PiNodeSessionDeleteResult> {
    const originals = new Map<string, Uint8Array>();
    for (const child of transaction.children) {
      originals.set(child.path, await readFile(child.path));
    }

    const committedChildren: string[] = [];
    try {
      for (const child of transaction.children) {
        const original = originals.get(child.path);
        if (!original) {
          throw new Error("Missing child rollback snapshot.");
        }
        const rewritten = reparentSessionHeader(
          original,
          transaction.target.info.path,
          transaction.target.info.parentSessionPath,
        );
        await atomicReplaceBytes(child.path, rewritten, this.#beforeAtomicCommit);
        committedChildren.push(child.path);
      }

      await atomicDeleteFile(transaction.target.info.path, this.#beforeAtomicCommit);
      return Object.freeze({
        sessionId,
        reparentedChildCount: transaction.children.length,
      });
    } catch (error) {
      const rollbackErrors: unknown[] = [];
      for (const childPath of committedChildren.reverse()) {
        const original = originals.get(childPath);
        if (!original) continue;
        try {
          await atomicReplaceBytes(childPath, original);
        } catch (rollbackError) {
          rollbackErrors.push(rollbackError);
        }
      }
      throw new PiSdkSessionAdministrationError(
        "session-admin-write-failed",
        "The session deletion transaction could not be committed atomically.",
        {
          cause:
            rollbackErrors.length === 0 ? error : new AggregateError([error, ...rollbackErrors]),
        },
      );
    }
  }
}

interface LocatedSession {
  readonly info: SessionInfo;
  readonly sessionDir: string | undefined;
}

interface DeleteTransaction {
  readonly target: LocatedSession;
  readonly children: readonly SessionInfo[];
}

async function locateSession(
  authorization: ProjectTrustAuthorization,
  agentDir: string,
  sessionId: string,
): Promise<LocatedSession> {
  const settingsManager = SettingsManager.create(authorization.cwd, agentDir, {
    projectTrusted: authorization.projectResourcesAllowed,
  });
  const sessionDir = resolveSessionDirectory(settingsManager, agentDir);
  const matches = (await SessionManager.list(authorization.cwd, sessionDir)).filter(
    (session) => session.id === sessionId,
  );
  if (matches.length === 0) {
    throw new PiSdkSessionAdministrationError(
      "session-not-found",
      "The persistent session could not be found.",
    );
  }
  if (matches.length > 1) {
    throw new PiSdkSessionAdministrationError(
      "session-id-ambiguous",
      "More than one persistent session has the requested identifier.",
    );
  }
  return { info: matches[0]!, sessionDir };
}

async function discoverDeleteTransaction(
  authorization: ProjectTrustAuthorization,
  agentDir: string,
  sessionId: string,
): Promise<DeleteTransaction> {
  const target = await locateSession(authorization, agentDir, sessionId);
  const allSessions =
    target.sessionDir === undefined
      ? await SessionManager.listAll()
      : await SessionManager.listAll(target.sessionDir);
  const targetPath = resolve(target.info.path);
  const children = allSessions
    .filter(
      (session) =>
        session.path !== target.info.path &&
        session.parentSessionPath !== undefined &&
        resolve(session.parentSessionPath) === targetPath,
    )
    .sort((left, right) => left.path.localeCompare(right.path));
  return { target, children };
}

export function sessionInfoToSummary(info: SessionInfo): PiNodeSessionSummary {
  const summary = {
    sessionId: info.id,
    cwd: info.cwd,
    ...(info.name === undefined ? {} : { name: info.name }),
    createdAtMs: info.created.getTime(),
    modifiedAtMs: info.modified.getTime(),
    messageCount: info.messageCount,
    firstMessage: info.firstMessage,
    running: false,
  };
  return Object.freeze({
    ...summary,
    adminRevision: createSessionAdminRevision(summary),
  });
}

export function createSessionAdminRevision(
  summary: Omit<PiNodeSessionSummary, "adminRevision">,
): string {
  return createHash("sha256")
    .update(
      JSON.stringify([
        summary.sessionId,
        summary.cwd,
        summary.name ?? null,
        summary.createdAtMs,
        summary.modifiedAtMs,
        summary.messageCount,
        summary.firstMessage,
      ]),
    )
    .digest("hex");
}

export function sanitizeGeneratedSessionName(value: string): string {
  const line = value
    .replaceAll(/[\u0000-\u001f\u007f]+/gu, " ")
    .replaceAll(/\s+/gu, " ")
    .trim()
    .replaceAll(/^[\s`*_#>\-–—"'“”‘’]+|[\s`*_#>\-–—"'“”‘’]+$/gu, "")
    .replace(/^title\s*:\s*/iu, "")
    .replaceAll(/^[\s`*_#>\-–—"'“”‘’]+|[\s`*_#>\-–—"'“”‘’]+$/gu, "")
    .trim();
  const bounded = [...line].slice(0, MAX_AUTO_NAME_CHARACTERS).join("").trim();
  if (bounded.length === 0) {
    throw new PiSdkSessionAdministrationError(
      "session-auto-name-empty",
      "The selected model did not return a usable session name.",
    );
  }
  return bounded;
}

function normalizeRequestedSessionName(value: string): string {
  const normalized = value
    .replaceAll(/[\r\n]+/gu, " ")
    .replaceAll(/\s+/gu, " ")
    .trim();
  if (
    normalized.length === 0 ||
    [...normalized].length > MAX_SESSION_NAME_CHARACTERS ||
    /[\u0000-\u001f\u007f]/u.test(normalized)
  ) {
    throw new PiSdkSessionAdministrationError(
      "session-name-invalid",
      "The session name is outside the supported bounds.",
    );
  }
  return normalized;
}

function validateAutoNameTimeout(value: number): number {
  if (
    !Number.isSafeInteger(value) ||
    value < MIN_AUTO_NAME_TIMEOUT_MILLIS ||
    value > MAX_AUTO_NAME_TIMEOUT_MILLIS
  ) {
    throw new PiSdkSessionAdministrationError(
      "session-name-invalid",
      "The auto-name deadline is outside the supported bounds.",
    );
  }
  return value;
}

async function generateSessionNameWithCurrentModel(
  input: PiSessionAutoNameGeneratorInput,
): Promise<string> {
  const context = input.sessionManager.buildSessionContext();
  if (context.messages.length === 0) {
    throw new PiSdkSessionAdministrationError(
      "session-auto-name-empty",
      "A session without conversation context cannot be named automatically.",
    );
  }
  if (!context.model) {
    throw new PiSdkSessionAdministrationError(
      "session-auto-name-model-unavailable",
      "The session does not have a current model.",
    );
  }

  const settingsManager = SettingsManager.create(input.authorization.cwd, input.agentDir, {
    projectTrusted: input.authorization.projectResourcesAllowed,
  });
  const services = await createAgentSessionServices({
    cwd: input.authorization.cwd,
    agentDir: input.agentDir,
    settingsManager,
    modelRuntimeSignal: input.signal,
    resourceLoaderOptions: {
      noContextFiles: !input.authorization.projectResourcesAllowed,
    },
  });
  const model = services.modelRuntime.getModel(context.model.provider, context.model.modelId);
  if (!model) {
    throw new PiSdkSessionAdministrationError(
      "session-auto-name-model-unavailable",
      "The session model is not available in the current runtime.",
    );
  }
  if (!services.modelRuntime.hasConfiguredAuth(model.provider)) {
    throw new PiSdkSessionAdministrationError(
      "session-auto-name-provider-auth-required",
      "The session model provider requires authentication.",
    );
  }

  const transcript = boundedTranscript(convertToLlm(context.messages));
  const response = await services.modelRuntime.completeSimple(
    model,
    {
      systemPrompt:
        "Create a concise session title. Return only the title, without quotes, markdown, labels, or explanation.",
      messages: [
        {
          role: "user",
          content: `Name this coding-agent session from the bounded transcript below. Use at most eight words.\n\n${transcript}`,
          timestamp: Date.now(),
        },
      ],
      tools: [],
    },
    {
      signal: input.signal,
      timeoutMs: input.timeoutMillis,
      maxRetries: 0,
      maxRetryDelayMs: 0,
      maxTokens: AUTO_NAME_OUTPUT_TOKENS,
      temperature: 0.2,
      toolChoice: "none",
    },
  );
  if (response.stopReason === "error") {
    throw new PiSdkSessionAdministrationError(
      "session-auto-name-failed",
      "The selected model could not generate a session name.",
    );
  }
  if (response.stopReason === "aborted") {
    throw new PiSdkSessionAdministrationError(
      "session-auto-name-cancelled",
      "The session naming operation was cancelled.",
    );
  }
  return response.content
    .filter(
      (part): part is Extract<(typeof response.content)[number], { type: "text" }> =>
        part.type === "text",
    )
    .map((part) => part.text)
    .join(" ");
}

function boundedTranscript(messages: ReturnType<typeof convertToLlm>): string {
  const selected: string[] = [];
  let remaining = MAX_AUTO_NAME_CONTEXT_CHARACTERS;
  for (const message of [...messages].reverse()) {
    const content =
      typeof message.content === "string"
        ? message.content
        : message.content
            .filter(
              (part): part is Extract<(typeof message.content)[number], { type: "text" }> =>
                part.type === "text",
            )
            .map((part) => part.text)
            .join(" ");
    const normalized = content.replaceAll(/\s+/gu, " ").trim();
    if (normalized.length === 0) continue;
    const bounded = [...normalized].slice(0, MAX_AUTO_NAME_MESSAGE_CHARACTERS).join("");
    const line = `${message.role}: ${bounded}`;
    if (line.length > remaining && selected.length > 0) break;
    selected.push(line.slice(0, remaining));
    remaining -= line.length;
    if (remaining <= 0) break;
  }
  return selected.reverse().join("\n");
}

function classifyAutoNameError(error: unknown): PiSdkSessionAdministrationError {
  if (error instanceof PiSdkSessionAdministrationError) {
    return error;
  }
  const message = error instanceof Error ? error.message : "";
  if (/api key|auth|credential/iu.test(message)) {
    return new PiSdkSessionAdministrationError(
      "session-auto-name-provider-auth-required",
      "The session model provider requires authentication.",
      { cause: error },
    );
  }
  if (/model/iu.test(message)) {
    return new PiSdkSessionAdministrationError(
      "session-auto-name-model-unavailable",
      "The session model is unavailable.",
      { cause: error },
    );
  }
  return new PiSdkSessionAdministrationError(
    "session-auto-name-failed",
    "The selected model could not generate a session name.",
    { cause: error },
  );
}

function resolveSessionDirectory(
  settingsManager: SettingsManager,
  agentDir: string,
): string | undefined {
  const configuredSessionDir = settingsManager.getSessionDir();
  if (configuredSessionDir !== undefined) return configuredSessionDir;
  if (resolve(agentDir) !== resolve(getAgentDir())) {
    throw new PiSdkSessionAdministrationError(
      "session-admin-write-failed",
      "A non-default agent directory requires an explicit sessionDir setting.",
    );
  }
  return undefined;
}

function assertAdminRevision(info: SessionInfo, expected: string): void {
  const actual = sessionInfoToSummary(info).adminRevision;
  if (actual !== expected) {
    throw new PiSdkSessionAdministrationError(
      "session-admin-conflict",
      "The session changed after deletion was confirmed.",
    );
  }
}

function assertConfirmationTitle(info: SessionInfo, displayedTitle: string): void {
  const actual = info.name?.trim() || info.firstMessage.trim() || "Untitled session";
  const displayed = displayedTitle.trim();
  if (displayed.length === 0 || (actual !== displayed && !actual.startsWith(displayed))) {
    throw new PiSdkSessionAdministrationError(
      "session-admin-conflict",
      "The displayed session title no longer matches the confirmed session.",
    );
  }
}

async function atomicSessionManagerMutation(
  targetPath: string,
  sessionDir: string | undefined,
  cwd: string,
  mutate: (manager: SessionManager) => void,
  beforeAtomicCommit?: (targetPath: string) => void | Promise<void>,
): Promise<void> {
  const temporaryPath = temporarySiblingPath(targetPath);
  try {
    const targetStat = await stat(targetPath);
    await copyFile(targetPath, temporaryPath, 1);
    await chmod(temporaryPath, targetStat.mode);
    const manager = SessionManager.open(temporaryPath, sessionDir, cwd);
    mutate(manager);
    const handle = await open(temporaryPath, "r");
    try {
      await handle.sync();
    } finally {
      await handle.close();
    }
    await beforeAtomicCommit?.(targetPath);
    await rename(temporaryPath, targetPath);
    await syncDirectory(dirname(targetPath));
  } finally {
    await rm(temporaryPath, { force: true });
  }
}

async function atomicReplaceBytes(
  targetPath: string,
  bytes: Uint8Array,
  beforeAtomicCommit?: (targetPath: string) => void | Promise<void>,
): Promise<void> {
  const temporaryPath = temporarySiblingPath(targetPath);
  try {
    const targetStat = await stat(targetPath);
    await writeFile(temporaryPath, bytes, { flag: "wx", mode: targetStat.mode });
    const handle = await open(temporaryPath, "r");
    try {
      await handle.sync();
    } finally {
      await handle.close();
    }
    await beforeAtomicCommit?.(targetPath);
    await rename(temporaryPath, targetPath);
    await syncDirectory(dirname(targetPath));
  } finally {
    await rm(temporaryPath, { force: true });
  }
}

async function atomicDeleteFile(
  targetPath: string,
  beforeAtomicCommit?: (targetPath: string) => void | Promise<void>,
): Promise<void> {
  const tombstonePath = `${targetPath}.pi-client-deleted-${randomUUID()}`;
  await beforeAtomicCommit?.(targetPath);
  await rename(targetPath, tombstonePath);
  try {
    await unlink(tombstonePath);
    await syncDirectory(dirname(targetPath));
  } catch (error) {
    try {
      await rename(tombstonePath, targetPath);
    } catch (rollbackError) {
      throw new AggregateError([error, rollbackError]);
    }
    throw error;
  }
}

function reparentSessionHeader(
  original: Uint8Array,
  expectedParentPath: string,
  replacementParentPath: string | undefined,
): Uint8Array {
  const text = new TextDecoder("utf-8", { fatal: true }).decode(original);
  const newline = text.indexOf("\n");
  const headerText = newline === -1 ? text : text.slice(0, newline);
  const remainder = newline === -1 ? "" : text.slice(newline + 1);
  const header = JSON.parse(headerText) as Record<string, unknown>;
  if (header.type !== "session") {
    throw new Error("The child session header is invalid.");
  }
  const currentParent = typeof header.parentSession === "string" ? header.parentSession : undefined;
  if (currentParent === undefined || resolve(currentParent) !== resolve(expectedParentPath)) {
    throw new PiSdkSessionAdministrationError(
      "session-admin-conflict",
      "A child session changed before reparenting completed.",
    );
  }
  if (replacementParentPath === undefined) {
    delete header.parentSession;
  } else {
    header.parentSession = replacementParentPath;
  }
  const rewritten = `${JSON.stringify(header)}\n${remainder}`;
  return new TextEncoder().encode(rewritten);
}

async function acquireFileLocks(
  targetPaths: readonly string[],
  timeoutMillis: number,
): Promise<() => Promise<void>> {
  const releases: Array<() => Promise<void>> = [];
  try {
    for (const targetPath of [...new Set(targetPaths)].sort()) {
      releases.push(await acquireFileLock(targetPath, timeoutMillis));
    }
  } catch (error) {
    for (const release of releases.reverse()) await release();
    throw error;
  }
  return async () => {
    for (const release of releases.reverse()) await release();
  };
}

async function acquireFileLock(
  targetPath: string,
  timeoutMillis: number,
): Promise<() => Promise<void>> {
  const lockPath = `${targetPath}.pi-client-admin.lock`;
  const deadline = Date.now() + timeoutMillis;
  for (;;) {
    try {
      const handle = await open(lockPath, "wx", 0o600);
      await handle.writeFile(`${process.pid}\n`, "utf8");
      return async () => {
        await handle.close();
        await rm(lockPath, { force: true });
      };
    } catch (error) {
      if (!hasCode(error, "EEXIST")) throw error;
      if (Date.now() >= deadline) {
        throw new PiSdkSessionAdministrationError(
          "session-admin-locked",
          "The session is locked by another administration operation.",
        );
      }
      await delay(FILE_LOCK_RETRY_MILLIS);
    }
  }
}

function temporarySiblingPath(targetPath: string): string {
  return join(
    dirname(targetPath),
    `.${basename(targetPath)}.pi-client-${process.pid}-${randomUUID()}.tmp`,
  );
}

async function syncDirectory(directory: string): Promise<void> {
  try {
    const handle = await open(directory, "r");
    try {
      await handle.sync();
    } finally {
      await handle.close();
    }
  } catch {
    // Some supported filesystems do not permit directory fsync.
  }
}

function samePaths(left: readonly string[], right: readonly string[]): boolean {
  return left.length === right.length && left.every((path, index) => path === right[index]);
}

function hasCode(error: unknown, code: string): boolean {
  return typeof error === "object" && error !== null && "code" in error && error.code === code;
}
