import assert from "node:assert/strict";
import test from "node:test";

import {
  ProjectTrustCoordinator,
  ProjectTrustError,
  type ProjectTrustBackend,
} from "../src/project-trust.js";

const canonicalCwd = "/canonical/project";
const agentDir = "/agent";

function backend(options: {
  protectedResources: boolean;
  savedDecision: boolean | null;
}): ProjectTrustBackend {
  return {
    hasProtectedProjectResources: () => options.protectedResources,
    readSavedDecision: () => options.savedDecision,
  };
}

function errorCode(error: unknown): string | undefined {
  return error instanceof ProjectTrustError ? error.code : undefined;
}

test("projects without protected resources remain restricted and do not ask for trust", async () => {
  let decisionCalls = 0;
  const coordinator = new ProjectTrustCoordinator({
    backend: backend({ protectedResources: false, savedDecision: null }),
    canonicalizePath: () => canonicalCwd,
    decisionProvider: () => {
      decisionCalls += 1;
      return "trust";
    },
  });

  const authorization = await coordinator.authorize({ cwd: "/input", agentDir });

  assert.equal(authorization.cwd, canonicalCwd);
  assert.equal(authorization.projectResourcesAllowed, false);
  assert.equal(authorization.source, "not-required");
  assert.equal(decisionCalls, 0);
});

test("metadata inspection stays restricted without loading protected resources", async () => {
  const coordinator = new ProjectTrustCoordinator({
    backend: backend({ protectedResources: true, savedDecision: null }),
    canonicalizePath: () => canonicalCwd,
  });

  const authorization = await coordinator.authorizeMetadata({ cwd: "/input", agentDir });
  assert.equal(authorization.projectResourcesAllowed, false);
  assert.equal(authorization.source, "restricted");
});

test("protected project resources fail closed without an explicit decision", async () => {
  const coordinator = new ProjectTrustCoordinator({
    backend: backend({ protectedResources: true, savedDecision: null }),
    canonicalizePath: () => canonicalCwd,
  });

  await assert.rejects(
    coordinator.authorize({ cwd: "/input", agentDir }),
    (error) => errorCode(error) === "project-trust-unresolved",
  );
});

test("a saved denial fails closed before session construction", async () => {
  const coordinator = new ProjectTrustCoordinator({
    backend: backend({ protectedResources: true, savedDecision: false }),
    canonicalizePath: () => canonicalCwd,
  });

  await assert.rejects(
    coordinator.authorize({ cwd: "/input", agentDir }),
    (error) => errorCode(error) === "project-trust-denied",
  );
});

test("saved and injected approvals authorize protected project resources", async (t) => {
  await t.test("saved approval", async () => {
    const coordinator = new ProjectTrustCoordinator({
      backend: backend({ protectedResources: true, savedDecision: true }),
      canonicalizePath: () => canonicalCwd,
    });

    const authorization = await coordinator.authorize({ cwd: "/input", agentDir });
    assert.equal(authorization.projectResourcesAllowed, true);
    assert.equal(authorization.source, "saved");
  });

  await t.test("decision provider approval", async () => {
    const coordinator = new ProjectTrustCoordinator({
      backend: backend({ protectedResources: true, savedDecision: null }),
      canonicalizePath: () => canonicalCwd,
      decisionProvider: () => "trust",
    });

    const authorization = await coordinator.authorize({ cwd: "/input", agentDir });
    assert.equal(authorization.projectResourcesAllowed, true);
    assert.equal(authorization.source, "decision-provider");
  });
});

test("explicit approval persists and confirms through the trust backend", async () => {
  let savedDecision: boolean | null = null;
  const coordinator = new ProjectTrustCoordinator({
    backend: {
      hasProtectedProjectResources: () => true,
      readSavedDecision: () => savedDecision,
      writeSavedDecision: (_cwd, _agentDir, decision) => {
        savedDecision = decision;
      },
    },
    canonicalizePath: () => canonicalCwd,
  });

  const authorization = await coordinator.approve({ cwd: "/input", agentDir });
  assert.equal(savedDecision, true);
  assert.equal(authorization.cwd, canonicalCwd);
  assert.equal(authorization.projectResourcesAllowed, true);
  assert.equal(authorization.source, "saved");
});

test("decision provider and evidence failures remain closed", async (t) => {
  await t.test("decision provider failure", async () => {
    const coordinator = new ProjectTrustCoordinator({
      backend: backend({ protectedResources: true, savedDecision: null }),
      canonicalizePath: () => canonicalCwd,
      decisionProvider: () => {
        throw new Error("provider unavailable");
      },
    });

    await assert.rejects(
      coordinator.authorize({ cwd: "/input", agentDir }),
      (error) => errorCode(error) === "project-trust-resolution-failed",
    );
  });

  await t.test("evidence failure", async () => {
    const coordinator = new ProjectTrustCoordinator({
      backend: {
        hasProtectedProjectResources: () => {
          throw new Error("filesystem unavailable");
        },
        readSavedDecision: () => null,
      },
      canonicalizePath: () => canonicalCwd,
    });

    await assert.rejects(
      coordinator.authorize({ cwd: "/input", agentDir }),
      (error) => errorCode(error) === "project-trust-resolution-failed",
    );
  });
});
