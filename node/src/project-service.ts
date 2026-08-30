import { createHash } from "node:crypto";
import { execFile } from "node:child_process";
import { lstat, readdir, realpath, stat } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, isAbsolute, join } from "node:path";
import { promisify } from "node:util";

import {
  PiNodeDomainError,
  type PiNodeDirectoryEntry,
  type PiNodeDirectoryListing,
  type PiNodeKnownProjectSnapshot,
  type PiNodeProjectBootstrap,
  type PiNodeProjectIdentity,
  type PiNodeProjectSnapshot,
  type PiNodeProjectTrustReason,
  type PiNodeProjectTrustSnapshot,
} from "./pi-node-domain.js";
import { PublicPiSdkProjectSessionCatalog } from "./pi-sdk-project-session-catalog.js";
import type {
  PiNodeProjectSessionCatalog,
  PiNodeProjectSessionRecord,
} from "./project-session-catalog.js";
import {
  ProjectTrustCoordinator,
  ProjectTrustError,
  type ProjectTrustInspection,
} from "./project-trust.js";

const execFileAsync = promisify(execFile);
const MAX_DIRECTORY_CHILDREN = 128;
const MAX_KNOWN_PROJECTS = 64;
const MAX_SESSION_SCAN = 4_096;
const MAX_GIT_OUTPUT_BYTES = 64 * 1024;
const GIT_TIMEOUT_MILLIS = 5_000;
const forbiddenPathControl = /[\u0000-\u001f\u007f]/u;

const projectConfigReasons = Object.freeze([
  ["settings.json", "pi-settings"],
  ["extensions", "pi-extensions"],
  ["skills", "pi-skills"],
  ["prompts", "pi-prompts"],
  ["themes", "pi-themes"],
  ["SYSTEM.md", "pi-system-prompt"],
  ["APPEND_SYSTEM.md", "pi-system-prompt"],
] as const satisfies readonly (readonly [string, PiNodeProjectTrustReason])[]);

export interface PiNodeProjectServiceOptions {
  readonly agentDir: string;
  readonly defaultWorkingDirectory: string;
  readonly trustCoordinator: ProjectTrustCoordinator;
  readonly closeProjectSessions: (canonicalCwd: string) => Promise<void>;
  readonly homeDirectory?: string;
  readonly gitExecutable?: string;
  readonly sessionCatalog?: PiNodeProjectSessionCatalog;
  readonly listAllSessions?: () => Promise<readonly PiNodeProjectSessionRecord[]>;
}

/**
 * Owns the bounded project-selection surface. It exposes directory metadata,
 * Git identity, session-derived recency, and trust decisions, but never file
 * contents or an arbitrary command/shell boundary.
 */
export class PiNodeProjectService {
  readonly #agentDir: string;
  readonly #defaultWorkingDirectory: string;
  readonly #trustCoordinator: ProjectTrustCoordinator;
  readonly #closeProjectSessions: (canonicalCwd: string) => Promise<void>;
  readonly #homeDirectory: string;
  readonly #gitExecutable: string;
  readonly #sessionCatalog: PiNodeProjectSessionCatalog;

  constructor(options: PiNodeProjectServiceOptions) {
    this.#agentDir = options.agentDir;
    this.#defaultWorkingDirectory = options.defaultWorkingDirectory;
    this.#trustCoordinator = options.trustCoordinator;
    this.#closeProjectSessions = options.closeProjectSessions;
    this.#homeDirectory = options.homeDirectory ?? homedir();
    this.#gitExecutable = options.gitExecutable ?? "git";
    this.#sessionCatalog =
      options.sessionCatalog ??
      (options.listAllSessions
        ? { listAll: options.listAllSessions }
        : new PublicPiSdkProjectSessionCatalog({
            agentDir: options.agentDir,
            defaultWorkingDirectory: options.defaultWorkingDirectory,
          }));
  }

  async getBootstrap(): Promise<PiNodeProjectBootstrap> {
    try {
      const [homeDirectory, defaultProject] = await Promise.all([
        canonicalDirectory(this.#homeDirectory),
        this.validateProject(this.#defaultWorkingDirectory),
      ]);
      return Object.freeze({ homeDirectory, defaultProject });
    } catch (error) {
      throw wrapProjectError(
        error,
        "project-validation-failed",
        "The default project location could not be resolved.",
      );
    }
  }

  async browseDirectory(input: {
    readonly directory: string;
    readonly maxChildren: number;
  }): Promise<PiNodeDirectoryListing> {
    const maxChildren = boundedLimit(input.maxChildren, MAX_DIRECTORY_CHILDREN, 64);
    let canonical: string;
    try {
      canonical = await canonicalDirectory(input.directory);
      const before = await stat(canonical);
      const entries = (await readdir(canonical, { withFileTypes: true })).sort((left, right) =>
        compareNames(left.name, right.name),
      );
      const children: PiNodeDirectoryEntry[] = [];
      let directoryCount = 0;
      for (const entry of entries) {
        if (!entry.isDirectory() && !entry.isSymbolicLink()) {
          continue;
        }
        const child = await inspectDirectoryChild(canonical, entry.name);
        if (!child) {
          continue;
        }
        directoryCount += 1;
        if (children.length < maxChildren) {
          children.push(child);
        } else {
          break;
        }
      }
      const after = await stat(canonical);
      if (!sameFile(before, after)) {
        throw new Error("The browsed directory changed during inspection.");
      }
      const parent = dirname(canonical);
      return Object.freeze({
        canonicalDirectory: canonical,
        ...(parent === canonical ? {} : { parentDirectory: await canonicalDirectory(parent) }),
        children: Object.freeze(children),
        truncated: directoryCount > children.length,
      });
    } catch (error) {
      throw wrapProjectError(
        error,
        "project-browse-failed",
        "The directory could not be browsed safely.",
      );
    }
  }

  async validateProject(candidateDirectory: string): Promise<PiNodeProjectSnapshot> {
    try {
      const canonicalCwd = await canonicalDirectory(candidateDirectory);
      const [identity, trust] = await Promise.all([
        this.#resolveIdentity(canonicalCwd),
        this.#resolveTrust(canonicalCwd),
      ]);
      return Object.freeze({ identity, trust });
    } catch (error) {
      throw wrapProjectError(
        error,
        "project-validation-failed",
        "The project directory could not be validated.",
      );
    }
  }

  async listKnownProjects(input: {
    readonly maxProjects: number;
  }): Promise<readonly PiNodeKnownProjectSnapshot[]> {
    const maxProjects = boundedLimit(input.maxProjects, MAX_KNOWN_PROJECTS, 24);
    let sessions: readonly PiNodeProjectSessionRecord[];
    try {
      sessions = await this.#sessionCatalog.listAll();
    } catch (error) {
      throw wrapProjectError(
        error,
        "project-list-failed",
        "Known projects could not be derived from Pi sessions.",
      );
    }

    const grouped = new Map<
      string,
      { readonly canonicalCwd: string; lastSessionAtMs: number; sessionCount: number }
    >();
    const orderedSessions = [...sessions]
      .sort((left, right) => right.modifiedAtMs - left.modifiedAtMs)
      .slice(0, MAX_SESSION_SCAN);
    for (const session of orderedSessions) {
      if (!session.cwd.trim()) {
        continue;
      }
      let canonicalCwd: string;
      try {
        canonicalCwd = await canonicalDirectory(session.cwd);
      } catch (error) {
        if (isMissingPathError(error)) {
          continue;
        }
        throw wrapProjectError(
          error,
          "project-list-failed",
          "A known project path could not be validated.",
        );
      }
      const timestamp = finiteMillis(session.modifiedAtMs);
      const existing = grouped.get(canonicalCwd);
      if (existing) {
        existing.sessionCount += 1;
        existing.lastSessionAtMs = Math.max(existing.lastSessionAtMs, timestamp);
      } else {
        grouped.set(canonicalCwd, { canonicalCwd, lastSessionAtMs: timestamp, sessionCount: 1 });
      }
    }

    const candidates = [...grouped.values()]
      .sort(
        (left, right) =>
          right.lastSessionAtMs - left.lastSessionAtMs ||
          compareNames(left.canonicalCwd, right.canonicalCwd),
      )
      .slice(0, maxProjects);
    try {
      return Object.freeze(
        await Promise.all(
          candidates.map(async (candidate) =>
            Object.freeze({
              project: await this.validateProject(candidate.canonicalCwd),
              lastSessionAtMs: candidate.lastSessionAtMs,
              sessionCount: candidate.sessionCount,
            }),
          ),
        ),
      );
    } catch (error) {
      throw wrapProjectError(
        error,
        "project-list-failed",
        "Known project metadata could not be validated.",
      );
    }
  }

  async approveTrust(input: {
    readonly canonicalCwd: string;
    readonly trustRevision: string;
  }): Promise<PiNodeProjectSnapshot> {
    const initial = await this.validateProject(input.canonicalCwd);
    if (initial.identity.canonicalCwd !== input.canonicalCwd) {
      throw new PiNodeDomainError(
        "project-trust-revision-stale",
        "The project path changed after validation.",
      );
    }
    if (initial.trust.revision !== input.trustRevision) {
      throw new PiNodeDomainError(
        "project-trust-revision-stale",
        "The project trust evidence changed before approval.",
      );
    }
    if (initial.trust.status === "not-required" || initial.trust.status === "trusted") {
      return initial;
    }

    try {
      await this.#closeProjectSessions(initial.identity.canonicalCwd);
    } catch (error) {
      throw new PiNodeDomainError(
        "project-trust-persist-failed",
        "Existing project sessions could not be closed before trust approval.",
        { cause: error },
      );
    }

    const revalidated = await this.validateProject(initial.identity.canonicalCwd);
    if (revalidated.trust.revision !== input.trustRevision) {
      throw new PiNodeDomainError(
        "project-trust-revision-stale",
        "The project trust evidence changed while sessions were closing.",
      );
    }

    try {
      await this.#trustCoordinator.approve({
        cwd: initial.identity.canonicalCwd,
        agentDir: this.#agentDir,
      });
    } catch (error) {
      if (error instanceof ProjectTrustError) {
        throw new PiNodeDomainError(
          error.code === "project-trust-persist-failed"
            ? "project-trust-persist-failed"
            : "project-trust-resolution-failed",
          "Project trust approval could not be completed.",
          { cause: error },
        );
      }
      throw new PiNodeDomainError(
        "project-trust-persist-failed",
        "Project trust approval could not be completed.",
        { cause: error },
      );
    }

    const approved = await this.validateProject(initial.identity.canonicalCwd);
    if (approved.trust.status !== "trusted" && approved.trust.status !== "not-required") {
      throw new PiNodeDomainError(
        "project-trust-persist-failed",
        "Persisted project trust approval could not be confirmed.",
      );
    }
    return approved;
  }

  async #resolveIdentity(canonicalCwd: string): Promise<PiNodeProjectIdentity> {
    const inside = await this.#git(canonicalCwd, ["rev-parse", "--is-inside-work-tree"], true);
    if (inside === null) {
      const identity = stableIdentity("path", canonicalCwd);
      return Object.freeze({
        projectId: stableIdentity("project", canonicalCwd),
        canonicalCwd,
        isGitRepository: false,
        isLinkedWorktree: false,
        isDetachedHead: false,
        worktreeId: identity,
        mainProjectId: identity,
      });
    }
    if (inside !== "true") {
      throw new Error("Git returned an invalid work-tree identity response.");
    }

    const gitRoot = await canonicalDirectory(
      await this.#requireGit(canonicalCwd, ["rev-parse", "--show-toplevel"]),
    );
    const worktreeList = await this.#requireGit(canonicalCwd, [
      "worktree",
      "list",
      "--porcelain",
      "-z",
    ]);
    const mainWorktree = firstWorktreePath(worktreeList);
    const mainWorktreeRoot = await canonicalDirectory(mainWorktree);
    const branchResult = await this.#git(canonicalCwd, [
      "symbolic-ref",
      "--quiet",
      "--short",
      "HEAD",
    ]);
    const detached = branchResult === null;
    return Object.freeze({
      projectId: stableIdentity("project", canonicalCwd),
      canonicalCwd,
      isGitRepository: true,
      gitRoot,
      mainWorktreeRoot,
      ...(detached ? {} : { branch: branchResult }),
      isLinkedWorktree: gitRoot !== mainWorktreeRoot,
      isDetachedHead: detached,
      worktreeId: stableIdentity("worktree", gitRoot),
      mainProjectId: stableIdentity("main", mainWorktreeRoot),
    });
  }

  async #resolveTrust(canonicalCwd: string): Promise<PiNodeProjectTrustSnapshot> {
    let inspection: ProjectTrustInspection;
    let reasons: readonly PiNodeProjectTrustReason[];
    try {
      [inspection, reasons] = await Promise.all([
        this.#trustCoordinator.inspect({ cwd: canonicalCwd, agentDir: this.#agentDir }),
        detectTrustReasons(canonicalCwd, this.#homeDirectory),
      ]);
    } catch (error) {
      throw new PiNodeDomainError(
        "project-trust-resolution-failed",
        "Project trust evidence could not be resolved.",
        { cause: error },
      );
    }
    if (inspection.cwd !== canonicalCwd) {
      throw new PiNodeDomainError(
        "project-trust-resolution-failed",
        "Project trust resolved a different canonical directory.",
      );
    }
    if (inspection.hasProtectedProjectResources !== reasons.length > 0) {
      throw new PiNodeDomainError(
        "project-trust-resolution-failed",
        "Project trust evidence was internally inconsistent.",
      );
    }

    const status = !inspection.hasProtectedProjectResources
      ? "not-required"
      : inspection.savedDecision === true
        ? "trusted"
        : inspection.savedDecision === false
          ? "denied"
          : "approval-required";
    const completeReasons = [
      ...reasons,
      ...(inspection.savedDecision === true ? (["saved-approval"] as const) : []),
      ...(inspection.savedDecision === false ? (["saved-denial"] as const) : []),
    ];
    return Object.freeze({
      status,
      reasons: Object.freeze(completeReasons),
      revision: trustRevision(canonicalCwd, status, completeReasons),
    });
  }

  async #requireGit(cwd: string, arguments_: readonly string[]): Promise<string> {
    const value = await this.#git(cwd, arguments_);
    if (value === null || value.length === 0) {
      throw new Error("Git did not return the required project identity field.");
    }
    return value;
  }

  async #git(
    cwd: string,
    arguments_: readonly string[],
    allowNotRepository = false,
  ): Promise<string | null> {
    try {
      const result = await execFileAsync(this.#gitExecutable, ["-C", cwd, ...arguments_], {
        encoding: "utf8",
        env: {
          ...process.env,
          LC_ALL: "C",
          LANG: "C",
          GIT_OPTIONAL_LOCKS: "0",
          GIT_TERMINAL_PROMPT: "0",
        },
        timeout: GIT_TIMEOUT_MILLIS,
        maxBuffer: MAX_GIT_OUTPUT_BYTES,
        windowsHide: true,
      });
      return result.stdout.replace(/[\r\n]+$/u, "");
    } catch (error) {
      if (allowNotRepository && isNotGitRepository(error)) {
        return null;
      }
      if (isDetachedHeadResult(error, arguments_)) {
        return null;
      }
      throw new Error("A bounded Git identity query failed.", { cause: error });
    }
  }
}

async function canonicalDirectory(input: string): Promise<string> {
  validatePathInput(input);
  const canonical = await realpath(input);
  const metadata = await stat(canonical);
  if (!metadata.isDirectory()) {
    throw new Error("The project path is not a directory.");
  }
  return canonical;
}

async function inspectDirectoryChild(
  parent: string,
  name: string,
): Promise<PiNodeDirectoryEntry | null> {
  const sourcePath = join(parent, name);
  const sourceBefore = await lstat(sourcePath);
  if (!sourceBefore.isDirectory() && !sourceBefore.isSymbolicLink()) {
    return null;
  }
  let canonicalPath: string;
  try {
    canonicalPath = await realpath(sourcePath);
  } catch (error) {
    if (isMissingPathError(error)) {
      return null;
    }
    throw error;
  }
  const targetBefore = await stat(canonicalPath);
  if (!targetBefore.isDirectory()) {
    return null;
  }
  const sourceAfter = await lstat(sourcePath);
  const targetAfter = await stat(canonicalPath);
  if (!sameFile(sourceBefore, sourceAfter) || !sameFile(targetBefore, targetAfter)) {
    throw new Error("A directory entry changed during inspection.");
  }
  return Object.freeze({
    name,
    canonicalPath,
    isSymbolicLink: sourceBefore.isSymbolicLink(),
  });
}

async function detectTrustReasons(
  canonicalCwd: string,
  homeDirectory: string,
): Promise<readonly PiNodeProjectTrustReason[]> {
  const reasons = new Set<PiNodeProjectTrustReason>();
  const projectConfigDirectory = join(canonicalCwd, ".pi");
  for (const [entry, reason] of projectConfigReasons) {
    if (await pathExists(join(projectConfigDirectory, entry))) {
      reasons.add(reason);
    }
  }

  const canonicalHome = await canonicalDirectory(homeDirectory);
  const userSkillsDirectory = join(canonicalHome, ".agents", "skills");
  let current = canonicalCwd;
  while (true) {
    const skillsDirectory = join(current, ".agents", "skills");
    if (skillsDirectory !== userSkillsDirectory && (await pathExists(skillsDirectory))) {
      reasons.add("agent-skills");
    }
    const parent = dirname(current);
    if (parent === current) {
      break;
    }
    current = parent;
  }
  return Object.freeze([...reasons].sort(compareNames));
}

async function pathExists(path: string): Promise<boolean> {
  try {
    await lstat(path);
    return true;
  } catch (error) {
    if (isMissingPathError(error)) {
      return false;
    }
    throw error;
  }
}

function trustRevision(
  canonicalCwd: string,
  status: PiNodeProjectTrustSnapshot["status"],
  reasons: readonly PiNodeProjectTrustReason[],
): string {
  return createHash("sha256")
    .update(JSON.stringify({ canonicalCwd, status, reasons }))
    .digest("hex");
}

function stableIdentity(kind: string, canonicalPath: string): string {
  return `${kind}-${createHash("sha256").update(canonicalPath).digest("hex").slice(0, 32)}`;
}

function firstWorktreePath(output: string): string {
  const firstField = output.split("\u0000", 1)[0];
  if (!firstField?.startsWith("worktree ")) {
    throw new Error("Git worktree porcelain output did not contain a main worktree.");
  }
  const path = firstField.slice("worktree ".length);
  validatePathInput(path);
  return path;
}

function boundedLimit(value: number, maximum: number, fallback: number): number {
  if (value === 0) {
    return fallback;
  }
  if (!Number.isSafeInteger(value) || value < 1 || value > maximum) {
    throw new RangeError("The requested project result limit is invalid.");
  }
  return value;
}

function validatePathInput(value: string): void {
  if (
    value.length === 0 ||
    value.length > 32_768 ||
    value.trim() !== value ||
    !isAbsolute(value) ||
    forbiddenPathControl.test(value)
  ) {
    throw new TypeError("The project path is invalid.");
  }
}

function finiteMillis(value: number): number {
  return Number.isFinite(value) ? Math.max(1, Math.floor(value)) : 1;
}

function compareNames(left: string, right: string): number {
  return left < right ? -1 : left > right ? 1 : 0;
}

function sameFile(
  left: { readonly dev: number | bigint; readonly ino: number | bigint },
  right: { readonly dev: number | bigint; readonly ino: number | bigint },
): boolean {
  return left.dev === right.dev && left.ino === right.ino;
}

function isMissingPathError(error: unknown): boolean {
  return (
    typeof error === "object" &&
    error !== null &&
    "code" in error &&
    (error.code === "ENOENT" || error.code === "ENOTDIR")
  );
}

function isNotGitRepository(error: unknown): boolean {
  if (typeof error !== "object" || error === null) {
    return false;
  }
  const candidate = error as { readonly code?: unknown; readonly stderr?: unknown };
  return (
    candidate.code === 128 &&
    typeof candidate.stderr === "string" &&
    candidate.stderr.startsWith("fatal: not a git repository")
  );
}

function isDetachedHeadResult(error: unknown, arguments_: readonly string[]): boolean {
  if (arguments_[0] !== "symbolic-ref") {
    return false;
  }
  return typeof error === "object" && error !== null && "code" in error && error.code === 1;
}

function wrapProjectError(
  error: unknown,
  code: "project-browse-failed" | "project-validation-failed" | "project-list-failed",
  message: string,
): PiNodeDomainError {
  if (error instanceof PiNodeDomainError) {
    return error;
  }
  if (error instanceof ProjectTrustError && error.code === "project-path-invalid") {
    return new PiNodeDomainError("invalid-project-path", "The project path is invalid.", {
      cause: error,
    });
  }
  if (error instanceof TypeError || error instanceof RangeError) {
    return new PiNodeDomainError("invalid-project-path", "The project path is invalid.", {
      cause: error,
    });
  }
  return new PiNodeDomainError(code, message, { cause: error });
}

export const PI_NODE_MAX_DIRECTORY_CHILDREN = MAX_DIRECTORY_CHILDREN;
export const PI_NODE_MAX_KNOWN_PROJECTS = MAX_KNOWN_PROJECTS;
