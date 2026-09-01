import assert from "node:assert/strict";
import { mkdir, mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";

import { PiNodeRuntime } from "../src/pi-node-runtime.js";
import { PublicPiSdkRuntimeSessionFactory } from "../src/pi-sdk-session-factory.js";
import {
  ProjectTrustCoordinator,
  ProjectTrustError,
  type ProjectTrustAuthorization,
} from "../src/project-trust.js";

test("the public SDK factory rejects forged project authorizations", async () => {
  const factory = new PublicPiSdkRuntimeSessionFactory();
  const authorization = {
    cwd: "/forged/project",
    projectResourcesAllowed: true,
    source: "decision-provider",
  } as unknown as ProjectTrustAuthorization;

  await assert.rejects(
    factory.create({ authorization, agentDir: "/forged/agent" }),
    (error) => error instanceof ProjectTrustError && error.code === "project-authorization-invalid",
  );
});

test("the public Pi SDK adapter starts offline without provider credentials", async () => {
  const root = await mkdtemp(join(tmpdir(), "pi-client-node-sdk-"));
  const cwd = join(root, "project");
  const agentDir = join(root, "agent");
  await Promise.all([mkdir(cwd), mkdir(agentDir)]);

  const runtime = new PiNodeRuntime({
    cwd,
    agentDir,
    trustCoordinator: new ProjectTrustCoordinator(),
    sessionFactory: new PublicPiSdkRuntimeSessionFactory(),
  });

  try {
    await runtime.start();
    const health = runtime.getHealth();
    assert.equal(health.state, "ready");
    assert.equal(health.projectResourceAccess, "restricted");
    assert.equal(health.session.active, true);
    assert.equal(health.runtime.piSdkVersion, "0.84.3");
  } finally {
    await runtime.stop();
    await rm(root, { recursive: true, force: true });
  }
});

test("the default trust coordinator rejects protected resources before SDK creation", async () => {
  const root = await mkdtemp(join(tmpdir(), "pi-client-node-trust-"));
  const cwd = join(root, "project");
  const agentDir = join(root, "agent");
  await Promise.all([mkdir(join(cwd, ".pi"), { recursive: true }), mkdir(agentDir)]);
  await writeFile(join(cwd, ".pi", "settings.json"), "{}\n", "utf8");

  let factoryCalls = 0;
  const runtime = new PiNodeRuntime({
    cwd,
    agentDir,
    trustCoordinator: new ProjectTrustCoordinator(),
    sessionFactory: {
      create: async () => {
        factoryCalls += 1;
        throw new Error("The SDK factory must not run before trust is resolved.");
      },
    },
  });

  try {
    await assert.rejects(runtime.start());
    assert.equal(factoryCalls, 0);
    assert.equal(runtime.getHealth().failure?.code, "project-trust-unresolved");
  } finally {
    await runtime.stop();
    await rm(root, { recursive: true, force: true });
  }
});

test("an explicit trust decision enables protected resources before public SDK startup", async () => {
  const root = await mkdtemp(join(tmpdir(), "pi-client-node-approved-"));
  const cwd = join(root, "project");
  const agentDir = join(root, "agent");
  await Promise.all([mkdir(join(cwd, ".pi"), { recursive: true }), mkdir(agentDir)]);
  await writeFile(
    join(cwd, ".pi", "settings.json"),
    `${JSON.stringify({ defaultTools: [] })}\n`,
    "utf8",
  );

  const runtime = new PiNodeRuntime({
    cwd,
    agentDir,
    trustCoordinator: new ProjectTrustCoordinator({ decisionProvider: () => "trust" }),
    sessionFactory: new PublicPiSdkRuntimeSessionFactory(),
  });

  try {
    await runtime.start();
    const health = runtime.getHealth();
    assert.equal(health.state, "ready");
    assert.equal(health.projectResourceAccess, "trusted");
    assert.equal(health.trustSource, "decision-provider");
  } finally {
    await runtime.stop();
    await rm(root, { recursive: true, force: true });
  }
});
