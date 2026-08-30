import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { mkdtemp, mkdir, realpath, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";
import test from "node:test";

import { PiNodeDomainError } from "../src/pi-node-domain.js";
import { PiNodeProjectService } from "../src/project-service.js";
import type { PiNodeProjectSessionRecord } from "../src/project-session-catalog.js";
import { ProjectTrustCoordinator } from "../src/project-trust.js";

const execFileAsync = promisify(execFile);

async function fixture(): Promise<{
  readonly root: string;
  readonly home: string;
  readonly agentDir: string;
  readonly project: string;
  readonly close: () => Promise<void>;
}> {
  const root = await mkdtemp(join(tmpdir(), "pi-client-project-service-"));
  const home = await mkdir(join(root, "home"), { recursive: true }).then(() => join(root, "home"));
  const agentDir = await mkdir(join(root, "agent"), { recursive: true }).then(() =>
    join(root, "agent"),
  );
  const project = await mkdir(join(root, "project"), { recursive: true }).then(() =>
    join(root, "project"),
  );
  return { root, home, agentDir, project, close: () => rm(root, { recursive: true, force: true }) };
}

function service(input: {
  readonly home: string;
  readonly agentDir: string;
  readonly project: string;
  readonly closeProjectSessions?: (cwd: string) => Promise<void>;
  readonly sessions?: readonly PiNodeProjectSessionRecord[];
}): PiNodeProjectService {
  return new PiNodeProjectService({
    agentDir: input.agentDir,
    defaultWorkingDirectory: input.project,
    homeDirectory: input.home,
    trustCoordinator: new ProjectTrustCoordinator(),
    closeProjectSessions: input.closeProjectSessions ?? (() => Promise.resolve()),
    ...(input.sessions === undefined
      ? {}
      : { listAllSessions: () => Promise.resolve(input.sessions ?? []) }),
  });
}

function sessionInfo(cwd: string, _id: string, modified: Date): PiNodeProjectSessionRecord {
  return { cwd, modifiedAtMs: modified.getTime() };
}

test("browses only bounded child directories and resolves symlink targets", async (t) => {
  const env = await fixture();
  t.after(env.close);
  const alpha = join(env.project, "alpha");
  const beta = join(env.project, "beta");
  await Promise.all([mkdir(alpha), mkdir(beta)]);
  await writeFile(join(env.project, "plain.txt"), "not a directory\n");
  await symlink(beta, join(env.project, "linked-beta"), "dir");

  const projectService = service(env);
  const full = await projectService.browseDirectory({
    directory: env.project,
    maxChildren: 8,
  });
  assert.equal(full.canonicalDirectory, await realpath(env.project));
  assert.deepEqual(
    full.children.map((entry) => entry.name),
    ["alpha", "beta", "linked-beta"],
  );
  assert.equal(full.children[2]?.isSymbolicLink, true);
  assert.equal(full.children[2]?.canonicalPath, await realpath(beta));
  assert.equal(
    full.children.some((entry) => entry.canonicalPath === join(env.project, "plain.txt")),
    false,
  );

  const bounded = await projectService.browseDirectory({
    directory: env.project,
    maxChildren: 1,
  });
  assert.deepEqual(
    bounded.children.map((entry) => entry.canonicalPath),
    [await realpath(alpha)],
  );
  assert.equal(bounded.truncated, true);
});

test("validates canonical directory-only paths and resolves machine Git identity", async (t) => {
  const env = await fixture();
  t.after(env.close);
  await execFileAsync("git", ["init", "-b", "main", env.project], {
    env: { ...process.env, LC_ALL: "C", LANG: "C" },
  });
  const alias = join(env.root, "project-alias");
  await symlink(env.project, alias, "dir");

  const projectService = service(env);
  const project = await projectService.validateProject(alias);
  assert.equal(project.identity.canonicalCwd, await realpath(env.project));
  assert.equal(project.identity.isGitRepository, true);
  assert.equal(project.identity.gitRoot, await realpath(env.project));
  assert.equal(project.identity.mainWorktreeRoot, await realpath(env.project));
  assert.equal(project.identity.branch, "main");
  assert.equal(project.identity.isLinkedWorktree, false);
  assert.equal(project.trust.status, "not-required");
  assert.deepEqual(project.trust.reasons, []);

  const file = join(env.root, "not-a-directory");
  await writeFile(file, "file\n");
  await assert.rejects(
    projectService.validateProject(file),
    (error) => error instanceof PiNodeDomainError && error.code === "project-validation-failed",
  );
  await assert.rejects(
    projectService.validateProject("relative/project"),
    (error) => error instanceof PiNodeDomainError && error.code === "invalid-project-path",
  );
});

test("distinguishes linked worktree identity from the main project identity", async (t) => {
  const env = await fixture();
  t.after(env.close);
  await execFileAsync("git", ["init", "-b", "main", env.project], {
    env: { ...process.env, LC_ALL: "C", LANG: "C" },
  });
  await execFileAsync("git", ["-C", env.project, "config", "user.email", "test@example.invalid"]);
  await execFileAsync("git", ["-C", env.project, "config", "user.name", "Pi Client Test"]);
  await writeFile(join(env.project, "README.md"), "fixture\n");
  await execFileAsync("git", ["-C", env.project, "add", "README.md"]);
  await execFileAsync("git", ["-C", env.project, "commit", "-m", "fixture"]);
  const linked = join(env.root, "linked");
  await execFileAsync("git", [
    "-C",
    env.project,
    "worktree",
    "add",
    "-b",
    "feature/linked",
    linked,
  ]);

  const projectService = service(env);
  const main = await projectService.validateProject(env.project);
  const worktree = await projectService.validateProject(linked);
  assert.equal(worktree.identity.isLinkedWorktree, true);
  assert.equal(worktree.identity.branch, "feature/linked");
  assert.equal(worktree.identity.gitRoot, await realpath(linked));
  assert.equal(worktree.identity.mainWorktreeRoot, await realpath(env.project));
  assert.notEqual(worktree.identity.worktreeId, main.identity.worktreeId);
  assert.equal(worktree.identity.mainProjectId, main.identity.mainProjectId);
});

test("derives bounded recent projects from session metadata without loading resources", async (t) => {
  const env = await fixture();
  t.after(env.close);
  const second = join(env.root, "second");
  await mkdir(second);
  const missing = join(env.root, "missing");
  const sessions = [
    sessionInfo(env.project, "old", new Date("2026-01-01T00:00:00Z")),
    sessionInfo(second, "new", new Date("2026-01-03T00:00:00Z")),
    sessionInfo(second, "newer", new Date("2026-01-04T00:00:00Z")),
    sessionInfo(missing, "stale", new Date("2026-01-05T00:00:00Z")),
  ];

  const known = await service({ ...env, sessions }).listKnownProjects({ maxProjects: 8 });
  assert.equal(known.length, 2);
  assert.equal(known[0]?.project.identity.canonicalCwd, await realpath(second));
  assert.equal(known[0]?.sessionCount, 2);
  assert.equal(known[0]?.lastSessionAtMs, Date.parse("2026-01-04T00:00:00Z"));
  assert.equal(known[1]?.project.identity.canonicalCwd, await realpath(env.project));
});

test("requires revision-bound explicit approval and persists through the public trust store", async (t) => {
  const env = await fixture();
  t.after(env.close);
  await mkdir(join(env.project, ".pi"));
  await writeFile(join(env.project, ".pi", "settings.json"), "{}\n");
  const closed: string[] = [];
  const projectService = service({
    ...env,
    closeProjectSessions: (cwd) => {
      closed.push(cwd);
      return Promise.resolve();
    },
  });

  const restricted = await projectService.validateProject(env.project);
  assert.equal(restricted.trust.status, "approval-required");
  assert.deepEqual(restricted.trust.reasons, ["pi-settings"]);
  await assert.rejects(
    projectService.approveTrust({
      canonicalCwd: restricted.identity.canonicalCwd,
      trustRevision: "stale-revision",
    }),
    (error) => error instanceof PiNodeDomainError && error.code === "project-trust-revision-stale",
  );
  assert.deepEqual(closed, []);

  const approved = await projectService.approveTrust({
    canonicalCwd: restricted.identity.canonicalCwd,
    trustRevision: restricted.trust.revision,
  });
  assert.equal(approved.trust.status, "trusted");
  assert.equal(approved.trust.reasons.includes("saved-approval"), true);
  assert.deepEqual(closed, [await realpath(env.project)]);

  const trustFile = await import("node:fs/promises").then((fs) =>
    fs.readFile(join(env.agentDir, "trust.json"), "utf8"),
  );
  assert.match(trustFile, /true/u);
});

test("fails closed before persisting approval when session invalidation fails", async (t) => {
  const env = await fixture();
  t.after(env.close);
  await mkdir(join(env.project, ".pi"));
  await writeFile(join(env.project, ".pi", "SYSTEM.md"), "untrusted\n");
  const projectService = service({
    ...env,
    closeProjectSessions: () => Promise.reject(new Error("session close failed")),
  });
  const restricted = await projectService.validateProject(env.project);

  await assert.rejects(
    projectService.approveTrust({
      canonicalCwd: restricted.identity.canonicalCwd,
      trustRevision: restricted.trust.revision,
    }),
    (error) => error instanceof PiNodeDomainError && error.code === "project-trust-persist-failed",
  );
  const after = await projectService.validateProject(env.project);
  assert.equal(after.trust.status, "approval-required");
});
