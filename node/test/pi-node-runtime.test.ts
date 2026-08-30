import assert from "node:assert/strict";
import test from "node:test";

import {
  PiNodeLifecycleError,
  PiNodeRuntime,
  type PiNodeFailureCode,
} from "../src/pi-node-runtime.js";
import type {
  PiSdkRuntimeSessionFactory,
  PiSdkSessionHandle,
} from "../src/pi-sdk-session-factory.js";
import { ProjectTrustCoordinator, type ProjectTrustBackend } from "../src/project-trust.js";

const cwd = "/canonical/project";
const agentDir = "/agent";

function trustCoordinator(
  options: {
    protectedResources?: boolean;
    savedDecision?: boolean | null;
  } = {},
): ProjectTrustCoordinator {
  const backend: ProjectTrustBackend = {
    hasProtectedProjectResources: () => options.protectedResources ?? false,
    readSavedDecision: () => options.savedDecision ?? null,
  };
  return new ProjectTrustCoordinator({
    backend,
    canonicalizePath: () => cwd,
  });
}

function createHandle(onDispose: () => void): PiSdkSessionHandle {
  let disposePromise: Promise<void> | undefined;
  return {
    cwd,
    sessionId: "session-1",
    persistence: "memory",
    projectResourcesLoaded: false,
    diagnosticCounts: { info: 0, warning: 0, error: 0 },
    dispose: () => {
      disposePromise ??= Promise.resolve().then(onDispose);
      return disposePromise;
    },
  };
}

test("trust resolution completes before the injected session factory runs", async () => {
  const order: string[] = [];
  const coordinator = new ProjectTrustCoordinator({
    backend: {
      hasProtectedProjectResources: () => {
        order.push("trust:inspect");
        return false;
      },
      readSavedDecision: () => null,
    },
    canonicalizePath: () => cwd,
  });
  const sessionFactory: PiSdkRuntimeSessionFactory = {
    create: async ({ authorization }) => {
      order.push("session:create");
      assert.equal(authorization.projectResourcesAllowed, false);
      return createHandle(() => order.push("session:dispose"));
    },
  };
  const clockValues = [100, 110, 120, 130];
  const runtime = new PiNodeRuntime({
    cwd,
    agentDir,
    trustCoordinator: coordinator,
    sessionFactory,
    clock: () => clockValues.shift() ?? 130,
  });

  await runtime.start();
  const health = runtime.getHealth();

  assert.deepEqual(order, ["trust:inspect", "session:create"]);
  assert.equal(runtime.state, "ready");
  assert.equal(health.healthy, true);
  assert.equal(health.projectResourceAccess, "restricted");
  assert.equal(health.session.active, true);
  assert.equal(health.session.persistence, "memory");
  assert.equal(health.uptimeMs, 10);

  await runtime.stop();
  assert.deepEqual(order, ["trust:inspect", "session:create", "session:dispose"]);
  assert.equal(runtime.state, "stopped");
});

test("concurrent start and stop calls create and dispose exactly once", async () => {
  let createCalls = 0;
  let disposeCalls = 0;
  const sessionFactory: PiSdkRuntimeSessionFactory = {
    create: async () => {
      createCalls += 1;
      return createHandle(() => {
        disposeCalls += 1;
      });
    },
  };
  const runtime = new PiNodeRuntime({
    cwd,
    agentDir,
    trustCoordinator: trustCoordinator(),
    sessionFactory,
  });

  await Promise.all([runtime.start(), runtime.start()]);
  await Promise.all([runtime.stop(), runtime.stop(), runtime.dispose()]);

  assert.equal(createCalls, 1);
  assert.equal(disposeCalls, 1);
  assert.equal(runtime.state, "stopped");
  assert.throws(() => runtime.start(), PiNodeLifecycleError);
});

test("an unresolved trust decision blocks the session factory and projects a stable failure", async () => {
  let createCalls = 0;
  const runtime = new PiNodeRuntime({
    cwd,
    agentDir,
    trustCoordinator: trustCoordinator({ protectedResources: true, savedDecision: null }),
    sessionFactory: {
      create: async () => {
        createCalls += 1;
        return createHandle(() => {});
      },
    },
  });

  await assert.rejects(runtime.start());

  const health = runtime.getHealth();
  assert.equal(createCalls, 0);
  assert.equal(runtime.state, "failed");
  assert.equal(health.healthy, false);
  assert.equal(health.failure?.code, "project-trust-unresolved" satisfies PiNodeFailureCode);
  assert.equal(health.session.active, false);
});

test("health and capability projection do not expose SDK objects or claim a wire protocol", () => {
  const runtime = new PiNodeRuntime({
    cwd,
    agentDir,
    trustCoordinator: trustCoordinator(),
    sessionFactory: {
      create: async () => createHandle(() => {}),
    },
    clock: () => 500,
  });

  const health = runtime.getHealth();
  const capabilities = runtime.getCapabilities();

  assert.deepEqual(health.session, { active: false, persistence: "none" });
  assert.equal(capabilities.projectTrustGate, "fail-closed");
  assert.equal(capabilities.providerCredentialsRequiredForStartup, false);
  assert.equal(capabilities.providerNetworkRequiredForHealth, false);
  assert.equal(capabilities.wireProtocol, "not-defined");
  assert.equal("agent" in health, false);
  assert.equal("services" in health, false);
  assert.equal("resourceLoader" in health, false);
});
