import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { stat } from "node:fs/promises";
import test from "node:test";

import { create, type MessageInitShape } from "@bufbuild/protobuf";
import {
  Capability,
  ErrorCode,
  MAX_FRAME_BYTES,
  MAX_TRANSFER_CHUNK_BYTES,
  PiTransportFrameSchema,
  SessionAdminOperation,
  SessionExportFormat,
  SessionTreeMutationOperation,
  TransferPurpose,
  decodeTransportFrame,
  encodeTransportFrame,
  type PiTransportFrame,
} from "@pi-client/protocol";

import { PiNodeProtobufConnection } from "../src/protocol/pi-node-protobuf-connection.js";
import { FakeProtocolDomain } from "./support/fake-protocol-domain.js";

const defaultProjectId = "project--project";

type FrameOperationInit = NonNullable<MessageInitShape<typeof PiTransportFrameSchema>["operation"]>;

function clientFrame(frameSequence: bigint, operation: FrameOperationInit): Uint8Array {
  return encodeTransportFrame(create(PiTransportFrameSchema, { frameSequence, operation }));
}

function protocolOffer(
  versions: readonly {
    readonly major: number;
    readonly minor: number;
    readonly patch: number;
  }[] = [{ major: 0, minor: 2, patch: 0 }],
  capabilities: readonly Capability[] = [
    Capability.SESSION_READ,
    Capability.SESSION_CREATE,
    Capability.PROMPT_COMMAND,
    Capability.ABORT_COMMAND,
    Capability.SESSION_EVENTS,
    Capability.PROJECT_DISCOVERY,
    Capability.PROJECT_TRUST,
    Capability.SESSION_ADMIN,
    Capability.SESSION_TREE,
  ],
): FrameOperationInit {
  return {
    case: "clientProtocolOffer",
    value: {
      protocolVersions: [...versions],
      capabilities: [...capabilities],
      clientInstanceId: "test-client",
      implementationName: "Pi Client Test",
      implementationVersion: "0.1.0-dev.0",
      maxFrameBytes: MAX_FRAME_BYTES,
      maxTransferChunkBytes: MAX_TRANSFER_CHUNK_BYTES,
    },
  };
}

function connection(domain = new FakeProtocolDomain()) {
  const output: PiTransportFrame[] = [];
  const server = new PiNodeProtobufConnection({
    domain,
    nodeInstanceId: "test-node",
    implementationVersion: "0.1.0-dev.0",
    streamIdFactory: (_sessionId, ordinal) => `stream-${ordinal}`,
    writeFrame: (payload) => {
      output.push(decodeTransportFrame(payload));
    },
  });
  return { domain, output, server };
}

async function handshake(
  server: PiNodeProtobufConnection,
  operation: FrameOperationInit = protocolOffer(),
): Promise<void> {
  const result = await server.receive(clientFrame(1n, operation));
  assert.equal(result.close, false);
}

async function bootstrapProject(
  server: PiNodeProtobufConnection,
  frameSequence = 2n,
  requestId = 900n,
): Promise<void> {
  const result = await server.receive(
    clientFrame(frameSequence, {
      case: "getProjectBootstrapRequest",
      value: { requestId },
    }),
  );
  assert.equal(result.close, false);
}

test("handshake selects the first explicitly supported offered v0 version and capability subset", async () => {
  const { output, server } = connection();
  try {
    await handshake(
      server,
      protocolOffer(
        [
          { major: 0, minor: 9, patch: 0 },
          { major: 0, minor: 2, patch: 0 },
          { major: 0, minor: 0, patch: 9 },
        ],
        [
          Capability.TRANSFER,
          Capability.ABORT_COMMAND,
          Capability.SESSION_READ,
          Capability.SESSION_EVENTS,
        ],
      ),
    );

    const accepted = output[0];
    assert.equal(accepted?.frameSequence, 1n);
    assert.equal(accepted?.operation.case, "serverHandshakeAccepted");
    if (accepted?.operation.case === "serverHandshakeAccepted") {
      assert.deepEqual(accepted.operation.value.selectedProtocolVersion, {
        $typeName: "pi.client.protocol.v0.ProtocolVersion",
        major: 0,
        minor: 2,
        patch: 0,
      });
      assert.deepEqual(accepted.operation.value.capabilities, [
        Capability.TRANSFER,
        Capability.ABORT_COMMAND,
        Capability.SESSION_READ,
        Capability.SESSION_EVENTS,
      ]);
    }
  } finally {
    await server.dispose();
  }
});

test("establishes one observation and sends its response before synchronous events", async () => {
  const domain = new FakeProtocolDomain();
  domain.emitOnObserve = true;
  const { output, server } = connection(domain);
  try {
    await handshake(server);
    await bootstrapProject(server);
    await server.receive(
      clientFrame(3n, {
        case: "listSessionsRequest",
        value: { requestId: 1n, projectId: defaultProjectId },
      }),
    );
    await server.receive(
      clientFrame(4n, {
        case: "getSessionRequest",
        value: {
          requestId: 2n,
          sessionId: "session-1",
          projectId: defaultProjectId,
        },
      }),
    );

    assert.deepEqual(
      output.map((frame) => frame.operation.case),
      [
        "serverHandshakeAccepted",
        "getProjectBootstrapResponse",
        "listSessionsResponse",
        "getSessionResponse",
        "sessionEventStream",
      ],
    );
    assert.equal(domain.observedCount.get("session-1"), 1);
  } finally {
    await server.dispose();
  }
  assert.equal(domain.unsubscribedCount.get("session-1"), 1);
});

test("routes typed session administration outcomes with explicit delete evidence", async () => {
  const { output, server } = connection();
  try {
    await handshake(server);
    await bootstrapProject(server);
    await server.receive(
      clientFrame(3n, {
        case: "listSessionsRequest",
        value: { requestId: 1n, projectId: defaultProjectId },
      }),
    );
    const listed = output.at(-1);
    assert.equal(listed?.operation.case, "listSessionsResponse");
    const revision =
      listed?.operation.case === "listSessionsResponse"
        ? listed.operation.value.sessions[0]?.adminRevision
        : undefined;
    assert.ok(revision);

    await server.receive(
      clientFrame(4n, {
        case: "renameSessionCommand",
        value: {
          requestId: 2n,
          commandId: "admin-rename-1",
          projectId: defaultProjectId,
          sessionId: "session-1",
          name: "Renamed session",
        },
      }),
    );
    const renamed = output.at(-1);
    assert.equal(renamed?.operation.case, "sessionAdminCommandOutcome");
    if (renamed?.operation.case === "sessionAdminCommandOutcome") {
      assert.equal(renamed.operation.value.operation, SessionAdminOperation.RENAME);
      assert.equal(renamed.operation.value.outcome.case, "session");
      if (renamed.operation.value.outcome.case === "session") {
        assert.equal(renamed.operation.value.outcome.value.title, "Renamed session");
      }
    }

    await server.receive(
      clientFrame(5n, {
        case: "autoNameSessionCommand",
        value: {
          requestId: 3n,
          commandId: "admin-auto-1",
          projectId: defaultProjectId,
          sessionId: "session-1",
          timeoutMillis: 15_000,
        },
      }),
    );
    const autoNamed = output.at(-1);
    assert.equal(autoNamed?.operation.case, "sessionAdminCommandOutcome");
    const autoRevision =
      autoNamed?.operation.case === "sessionAdminCommandOutcome" &&
      autoNamed.operation.value.outcome.case === "session"
        ? autoNamed.operation.value.outcome.value.adminRevision
        : undefined;
    assert.ok(autoRevision);

    await server.receive(
      clientFrame(6n, {
        case: "deleteSessionCommand",
        value: {
          requestId: 4n,
          commandId: "admin-delete-1",
          projectId: defaultProjectId,
          sessionId: "session-1",
          confirmation: {
            sessionId: "session-1",
            adminRevision: autoRevision,
            displayedTitle: "Generated session title",
            destructiveActionAcknowledged: true,
          },
        },
      }),
    );
    const deleted = output.at(-1);
    assert.equal(deleted?.operation.case, "sessionAdminCommandOutcome");
    if (deleted?.operation.case === "sessionAdminCommandOutcome") {
      assert.equal(deleted.operation.value.operation, SessionAdminOperation.DELETE);
      assert.equal(deleted.operation.value.outcome.case, "deletion");
      if (deleted.operation.value.outcome.case === "deletion") {
        assert.equal(deleted.operation.value.outcome.value.sessionId, "session-1");
      }
    }
  } finally {
    await server.dispose();
  }
});

test("routes flat session trees, edit-from-here, fork, and clone outcomes", async () => {
  const { output, server } = connection();
  try {
    await handshake(server);
    await bootstrapProject(server);
    await server.receive(
      clientFrame(3n, {
        case: "getSessionRequest",
        value: {
          requestId: 1n,
          sessionId: "session-1",
          projectId: defaultProjectId,
        },
      }),
    );
    const loaded = output.at(-1);
    const revision =
      loaded?.operation.case === "getSessionResponse"
        ? loaded.operation.value.session?.summary?.adminRevision
        : undefined;
    assert.ok(revision);

    await server.receive(
      clientFrame(4n, {
        case: "getSessionTreeRequest",
        value: { requestId: 2n, projectId: defaultProjectId, sessionId: "session-1" },
      }),
    );
    const treeResponse = output.at(-1);
    assert.equal(treeResponse?.operation.case, "getSessionTreeResponse");
    const userEntryId =
      treeResponse?.operation.case === "getSessionTreeResponse"
        ? treeResponse.operation.value.tree?.nodes.find((node) => node.canFork)?.entryId
        : undefined;
    assert.ok(userEntryId);

    await server.receive(
      clientFrame(5n, {
        case: "navigateSessionTreeCommand",
        value: {
          requestId: 3n,
          commandId: "tree-navigate",
          projectId: defaultProjectId,
          sessionId: "session-1",
          entryId: userEntryId,
          expectedAdminRevision: revision,
        },
      }),
    );
    const navigated = output.at(-1);
    assert.equal(navigated?.operation.case, "sessionTreeMutationOutcome");
    if (navigated?.operation.case === "sessionTreeMutationOutcome") {
      assert.equal(navigated.operation.value.operation, SessionTreeMutationOperation.NAVIGATE);
      assert.equal(navigated.operation.value.outcome.case, "result");
      if (navigated.operation.value.outcome.case === "result") {
        assert.equal(navigated.operation.value.outcome.value.editorText, "Hello");
      }
    }

    await server.receive(
      clientFrame(6n, {
        case: "forkSessionCommand",
        value: {
          requestId: 4n,
          commandId: "tree-fork",
          projectId: defaultProjectId,
          sessionId: "session-1",
          userEntryId,
          expectedAdminRevision: revision,
        },
      }),
    );
    const forked = output.at(-1);
    assert.equal(forked?.operation.case, "sessionTreeMutationOutcome");
    const forkedSessionId =
      forked?.operation.case === "sessionTreeMutationOutcome" &&
      forked.operation.value.outcome.case === "result"
        ? forked.operation.value.outcome.value.session?.summary?.sessionId
        : undefined;
    const forkedRevision =
      forked?.operation.case === "sessionTreeMutationOutcome" &&
      forked.operation.value.outcome.case === "result"
        ? forked.operation.value.outcome.value.session?.summary?.adminRevision
        : undefined;
    assert.ok(forkedSessionId);
    assert.ok(forkedRevision);
    if (
      forked?.operation.case === "sessionTreeMutationOutcome" &&
      forked.operation.value.outcome.case === "result"
    ) {
      assert.equal(
        forked.operation.value.outcome.value.session?.summary?.parentSessionId,
        "session-1",
      );
    }

    await server.receive(
      clientFrame(7n, {
        case: "cloneSessionCommand",
        value: {
          requestId: 5n,
          commandId: "tree-clone",
          projectId: defaultProjectId,
          sessionId: forkedSessionId,
          expectedAdminRevision: forkedRevision,
        },
      }),
    );
    const cloned = output.at(-1);
    assert.equal(cloned?.operation.case, "sessionTreeMutationOutcome");
    if (cloned?.operation.case === "sessionTreeMutationOutcome") {
      assert.equal(cloned.operation.value.operation, SessionTreeMutationOperation.CLONE);
      assert.equal(cloned.operation.value.outcome.case, "result");
      if (cloned.operation.value.outcome.case === "result") {
        assert.equal(
          cloned.operation.value.outcome.value.session?.summary?.parentSessionId,
          forkedSessionId,
        );
      }
    }
  } finally {
    await server.dispose();
  }
});

test("routes session requests and admits commands before forwarding ordered session events", async () => {
  const { domain, output, server } = connection();
  try {
    await handshake(server);
    await bootstrapProject(server);
    await server.receive(
      clientFrame(3n, {
        case: "listSessionsRequest",
        value: { requestId: 1n, projectId: defaultProjectId },
      }),
    );
    await server.receive(
      clientFrame(4n, {
        case: "getSessionRequest",
        value: {
          requestId: 2n,
          sessionId: "session-1",
          projectId: defaultProjectId,
        },
      }),
    );
    await server.receive(
      clientFrame(5n, {
        case: "getSessionRequest",
        value: {
          requestId: 3n,
          sessionId: "session-1",
          projectId: defaultProjectId,
        },
      }),
    );
    await server.receive(
      clientFrame(6n, {
        case: "createSessionRequest",
        value: { requestId: 4n, projectId: defaultProjectId },
      }),
    );

    const promptOutputStart = output.length;
    await server.receive(
      clientFrame(7n, {
        case: "promptCommand",
        value: {
          requestId: 5n,
          commandId: "prompt-1",
          sessionId: "session-1",
          prompt: "Continue",
        },
      }),
    );
    const promptCases = output.slice(promptOutputStart).map((frame) => frame.operation.case);
    assert.deepEqual(promptCases, [
      "commandAccepted",
      "sessionEventStream",
      "sessionEventStream",
      "sessionEventStream",
    ]);

    const abortOutputStart = output.length;
    await server.receive(
      clientFrame(8n, {
        case: "abortCommand",
        value: {
          requestId: 6n,
          commandId: "abort-1",
          sessionId: "session-1",
        },
      }),
    );
    assert.deepEqual(
      output.slice(abortOutputStart).map((frame) => frame.operation.case),
      ["commandAccepted", "sessionEventStream", "sessionEventStream"],
    );

    assert.equal(domain.observedCount.get("session-1"), 1);
    assert.equal(domain.observedCount.get("created-1"), 1);
    assert.deepEqual(
      output.map((frame) => frame.frameSequence),
      output.map((_frame, index) => BigInt(index + 1)),
    );
    const sessionEvents = output.filter(
      (
        frame,
      ): frame is PiTransportFrame & {
        operation: Extract<PiTransportFrame["operation"], { case: "sessionEventStream" }>;
      } => frame.operation.case === "sessionEventStream",
    );
    assert.deepEqual(
      sessionEvents.map((frame) => frame.operation.value.eventSequence),
      [1n, 2n, 3n, 4n, 5n],
    );
    const completed = sessionEvents.at(-1);
    assert.equal(completed?.operation.value.event.case, "commandCompleted");
    if (completed?.operation.value.event.case === "commandCompleted") {
      assert.equal(completed.operation.value.event.value.succeeded, false);
      assert.equal(completed.operation.value.event.value.error?.code, ErrorCode.CANCELLED);
      assert.equal(
        completed.operation.value.event.value.error?.safeMessage,
        "The command was aborted.",
      );
    }
  } finally {
    await server.dispose();
  }

  assert.equal(domain.unsubscribedCount.get("session-1"), 1);
  assert.equal(domain.unsubscribedCount.get("created-1"), 1);
});

test("routes bounded project discovery and revision-bound trust operations", async () => {
  const { output, server } = connection();
  try {
    await handshake(server);
    await bootstrapProject(server);
    await server.receive(
      clientFrame(3n, {
        case: "browseDirectoryRequest",
        value: { requestId: 1n, directory: "/project", maxChildren: 16 },
      }),
    );
    await server.receive(
      clientFrame(4n, {
        case: "validateProjectRequest",
        value: { requestId: 2n, candidateDirectory: "/new-project" },
      }),
    );
    await server.receive(
      clientFrame(5n, {
        case: "listKnownProjectsRequest",
        value: { requestId: 3n, maxProjects: 8 },
      }),
    );
    await server.receive(
      clientFrame(6n, {
        case: "approveProjectTrustRequest",
        value: {
          requestId: 4n,
          projectId: "project--new-project",
          trustRevision: "revision-not-required",
        },
      }),
    );
    await server.receive(
      clientFrame(7n, {
        case: "createSessionRequest",
        value: { requestId: 5n, projectId: "project--new-project" },
      }),
    );

    assert.deepEqual(
      output.map((frame) => frame.operation.case),
      [
        "serverHandshakeAccepted",
        "getProjectBootstrapResponse",
        "browseDirectoryResponse",
        "validateProjectResponse",
        "listKnownProjectsResponse",
        "approveProjectTrustResponse",
        "createSessionResponse",
      ],
    );
    const validated = output[3];
    assert.equal(validated?.operation.case, "validateProjectResponse");
    if (validated?.operation.case === "validateProjectResponse") {
      assert.equal(
        validated.operation.value.project?.identity?.canonicalWorkingDirectory,
        "/new-project",
      );
    }
  } finally {
    await server.dispose();
  }
});

test("rejects session creation for a project not validated on the connection", async () => {
  const { output, server } = connection();
  try {
    await handshake(server);
    await server.receive(
      clientFrame(2n, {
        case: "createSessionRequest",
        value: { requestId: 1n, projectId: "unknown-project" },
      }),
    );
    const rejected = output.at(-1);
    assert.equal(rejected?.operation.case, "requestRejected");
    if (rejected?.operation.case === "requestRejected") {
      assert.equal(rejected.operation.value.error?.code, ErrorCode.FAILED_PRECONDITION);
    }
  } finally {
    await server.dispose();
  }
});

test("preserves an uncertain prompt admission as a correlated error", async () => {
  const domain = new FakeProtocolDomain();
  domain.promptAdmission = "uncertain";
  const { output, server } = connection(domain);
  try {
    await handshake(server);
    await bootstrapProject(server);
    await server.receive(
      clientFrame(3n, {
        case: "listSessionsRequest",
        value: { requestId: 1n, projectId: defaultProjectId },
      }),
    );
    await server.receive(
      clientFrame(4n, {
        case: "getSessionRequest",
        value: {
          requestId: 2n,
          sessionId: "session-1",
          projectId: defaultProjectId,
        },
      }),
    );
    await server.receive(
      clientFrame(5n, {
        case: "promptCommand",
        value: {
          requestId: 3n,
          commandId: "uncertain-command",
          sessionId: "session-1",
          prompt: "Continue",
        },
      }),
    );

    const uncertain = output.at(-1);
    assert.equal(uncertain?.operation.case, "error");
    if (uncertain?.operation.case === "error") {
      assert.deepEqual(uncertain.operation.value.correlation, {
        case: "requestId",
        value: 3n,
      });
      assert.equal(uncertain.operation.value.error?.code, ErrorCode.NODE_BUSY);
      assert.equal(uncertain.operation.value.error?.retryable, true);
    }
  } finally {
    await server.dispose();
  }
});

test("streams exactly bound message content through the existing transfer engine", async () => {
  const domain = new FakeProtocolDomain();
  const payload = Uint8Array.from(Buffer.from("session-scoped content", "utf8"));
  const digest = Uint8Array.from(createHash("sha256").update(payload).digest());
  const binding = {
    sessionId: "session-1",
    entryId: "entry-1",
    partId: "part-1",
    entryRevision: 3,
    partRevision: 2,
    contentId: "content-1",
  } as const;
  domain.getMessageContent = async ({ request }) => ({
    binding,
    reference: {
      contentId: binding.contentId,
      mimeType: request.expectedMimeType,
      displayName: "message.txt",
      totalBytes: payload.length,
      sha256: digest,
    },
    bytes: payload,
  });
  const { output, server } = connection(domain);
  try {
    await handshake(
      server,
      protocolOffer(
        [{ major: 0, minor: 2, patch: 0 }],
        [
          Capability.PROJECT_DISCOVERY,
          Capability.RICH_CONVERSATION,
          Capability.MESSAGE_CONTENT,
          Capability.TRANSFER,
          Capability.FLOW_CONTROL,
          Capability.CANCELLATION,
        ],
      ),
    );
    await bootstrapProject(server);
    await server.receive(
      clientFrame(3n, {
        case: "getMessageContentRequest",
        value: {
          requestId: 1n,
          projectId: defaultProjectId,
          binding: {
            ...binding,
            entryRevision: BigInt(binding.entryRevision),
            partRevision: BigInt(binding.partRevision),
          },
          expectedMimeType: "text/plain; charset=utf-8",
          expectedTotalBytes: BigInt(payload.length),
          expectedSha256: digest,
        },
      }),
    );

    const opened = output.at(-1);
    assert.equal(opened?.operation.case, "transferOpen");
    if (opened?.operation.case !== "transferOpen") return;
    assert.equal(opened.operation.value.purpose, TransferPurpose.MESSAGE_CONTENT);
    assert.equal(opened.operation.value.contentType, "text/plain; charset=utf-8");
    assert.equal(opened.operation.value.totalBytes, BigInt(payload.length));
    assert.deepEqual(opened.operation.value.messageContentBinding, {
      $typeName: "pi.client.protocol.v0.MessageContentBinding",
      sessionId: binding.sessionId,
      entryId: binding.entryId,
      partId: binding.partId,
      entryRevision: BigInt(binding.entryRevision),
      partRevision: BigInt(binding.partRevision),
      contentId: binding.contentId,
    });
    assert.deepEqual(Buffer.from(opened.operation.value.sha256), Buffer.from(digest));

    const transferId = opened.operation.value.transferId;
    await server.receive(
      clientFrame(4n, {
        case: "windowUpdate",
        value: {
          target: { case: "transferId", value: transferId },
          creditMessages: 0,
          creditBytes: BigInt(payload.length),
        },
      }),
    );
    const chunk = output.at(-1);
    assert.equal(chunk?.operation.case, "transferChunk");
    if (chunk?.operation.case !== "transferChunk") return;
    assert.deepEqual(Buffer.from(chunk.operation.value.data), Buffer.from(payload));
    await server.receive(
      clientFrame(5n, {
        case: "transferAck",
        value: {
          transferId,
          acknowledgedSequence: 1n,
          committedBytes: BigInt(payload.length),
        },
      }),
    );
    assert.equal(output.at(-1)?.operation.case, "transferComplete");
  } finally {
    await server.dispose();
  }
});

test("rejects message content returned with stale or tampered metadata", async () => {
  const payload = Uint8Array.from(Buffer.from("content", "utf8"));
  const digest = Uint8Array.from(createHash("sha256").update(payload).digest());
  const expectedBinding = {
    sessionId: "session-1",
    entryId: "entry-1",
    partId: "part-1",
    entryRevision: 2,
    partRevision: 1,
    contentId: "content-1",
  } as const;
  const variants = [
    {
      label: "binding",
      binding: { ...expectedBinding, partRevision: 2 },
      mimeType: "image/png",
      totalBytes: payload.length,
      sha256: digest,
      bytes: payload,
    },
    {
      label: "MIME",
      binding: expectedBinding,
      mimeType: "image/jpeg",
      totalBytes: payload.length,
      sha256: digest,
      bytes: payload,
    },
    {
      label: "length",
      binding: expectedBinding,
      mimeType: "image/png",
      totalBytes: payload.length + 1,
      sha256: digest,
      bytes: payload,
    },
    {
      label: "digest",
      binding: expectedBinding,
      mimeType: "image/png",
      totalBytes: payload.length,
      sha256: new Uint8Array(32).fill(7),
      bytes: payload,
    },
    {
      label: "bytes",
      binding: expectedBinding,
      mimeType: "image/png",
      totalBytes: payload.length,
      sha256: digest,
      bytes: Uint8Array.from(Buffer.from("tampere", "utf8")),
    },
  ] as const;

  for (const variant of variants) {
    const domain = new FakeProtocolDomain();
    domain.getMessageContent = async () => ({
      binding: variant.binding,
      reference: {
        contentId: variant.binding.contentId,
        mimeType: variant.mimeType,
        displayName: "image.png",
        totalBytes: variant.totalBytes,
        sha256: variant.sha256,
      },
      bytes: variant.bytes,
    });
    const { output, server } = connection(domain);
    try {
      await handshake(
        server,
        protocolOffer(
          [{ major: 0, minor: 2, patch: 0 }],
          [
            Capability.PROJECT_DISCOVERY,
            Capability.RICH_CONVERSATION,
            Capability.MESSAGE_CONTENT,
            Capability.TRANSFER,
            Capability.FLOW_CONTROL,
            Capability.CANCELLATION,
          ],
        ),
      );
      await bootstrapProject(server);
      await server.receive(
        clientFrame(3n, {
          case: "getMessageContentRequest",
          value: {
            requestId: 1n,
            projectId: defaultProjectId,
            binding: {
              ...expectedBinding,
              entryRevision: BigInt(expectedBinding.entryRevision),
              partRevision: BigInt(expectedBinding.partRevision),
            },
            expectedMimeType: "image/png",
            expectedTotalBytes: BigInt(payload.length),
            expectedSha256: digest,
          },
        }),
      );
      const rejected = output.at(-1);
      assert.equal(rejected?.operation.case, "requestRejected", variant.label);
      if (rejected?.operation.case === "requestRejected") {
        assert.equal(rejected.operation.value.error?.code, ErrorCode.DATA_LOSS, variant.label);
      }
      assert.equal(
        output.some((frame) => frame.operation.case === "transferOpen"),
        false,
        variant.label,
      );
    } finally {
      await server.dispose();
    }
  }
});

test("streams large exports only within byte credit and the 16-chunk ACK window", async () => {
  const domain = new FakeProtocolDomain();
  const payload = new Uint8Array(20 * 64 * 1024 + 7);
  for (let index = 0; index < payload.length; index += 1) payload[index] = index % 251;
  domain.exportPayload = payload;
  const { output, server } = connection(domain);
  try {
    await handshake(
      server,
      protocolOffer(
        [{ major: 0, minor: 2, patch: 0 }],
        [
          Capability.PROJECT_DISCOVERY,
          Capability.SESSION_EXPORT,
          Capability.TRANSFER,
          Capability.FLOW_CONTROL,
          Capability.CANCELLATION,
        ],
      ),
    );
    await bootstrapProject(server);
    await server.receive(
      clientFrame(3n, {
        case: "exportSessionRequest",
        value: {
          requestId: 1n,
          projectId: defaultProjectId,
          sessionId: "session-1",
          format: SessionExportFormat.JSONL,
          expectedActiveBranchRevision: "active-revision-session-1-1",
          expectedTreeRevision: "revision-session-1-1",
        },
      }),
    );

    const opened = output.at(-1);
    assert.equal(opened?.operation.case, "transferOpen");
    if (opened?.operation.case !== "transferOpen") return;
    const transferId = opened.operation.value.transferId;
    const chunkBytes = opened.operation.value.chunkBytes;
    assert.equal(chunkBytes, 64 * 1024);
    assert.equal(opened.operation.value.totalBytes, BigInt(payload.length));
    assert.deepEqual(
      Buffer.from(opened.operation.value.sha256),
      createHash("sha256").update(payload).digest(),
    );
    assert.equal(
      output.some((frame) => frame.operation.case === "transferChunk"),
      false,
    );
    assert.ok(domain.lastExportPath);
    await stat(domain.lastExportPath);

    await server.receive(
      clientFrame(4n, {
        case: "windowUpdate",
        value: {
          target: { case: "transferId", value: transferId },
          creditMessages: 0,
          creditBytes: BigInt(payload.length),
        },
      }),
    );
    let chunks = output.filter((frame) => frame.operation.case === "transferChunk");
    assert.equal(chunks.length, 16);
    for (let index = 0; index < chunks.length; index += 1) {
      const frame = chunks[index]!;
      assert.equal(frame.operation.case, "transferChunk");
      if (frame.operation.case === "transferChunk") {
        assert.equal(frame.operation.value.chunkSequence, BigInt(index + 1));
        assert.equal(frame.operation.value.offset, BigInt(index * chunkBytes));
      }
    }

    const sixteenth = chunks[15]!;
    assert.equal(sixteenth.operation.case, "transferChunk");
    if (sixteenth.operation.case !== "transferChunk") return;
    const committedAtSixteen =
      sixteenth.operation.value.offset + BigInt(sixteenth.operation.value.data.length);
    await server.receive(
      clientFrame(5n, {
        case: "transferAck",
        value: {
          transferId,
          acknowledgedSequence: 16n,
          committedBytes: committedAtSixteen,
        },
      }),
    );
    chunks = output.filter((frame) => frame.operation.case === "transferChunk");
    assert.equal(chunks.length, 21);
    const last = chunks.at(-1)!;
    assert.equal(last.operation.case, "transferChunk");
    if (last.operation.case !== "transferChunk") return;
    assert.equal(last.operation.value.chunkSequence, 21n);
    assert.equal(
      last.operation.value.offset + BigInt(last.operation.value.data.length),
      BigInt(payload.length),
    );

    await server.receive(
      clientFrame(6n, {
        case: "transferAck",
        value: {
          transferId,
          acknowledgedSequence: 21n,
          committedBytes: BigInt(payload.length),
        },
      }),
    );
    const completed = output.at(-1);
    assert.equal(completed?.operation.case, "transferComplete");
    if (completed?.operation.case === "transferComplete") {
      assert.equal(completed.operation.value.totalBytes, BigInt(payload.length));
      assert.deepEqual(
        Buffer.from(completed.operation.value.sha256),
        createHash("sha256").update(payload).digest(),
      );
    }
    await assert.rejects(() => stat(domain.lastExportPath!));
  } finally {
    await server.dispose();
  }
});

test("aborts invalid export ACKs and explicit cancellation with temp-file cleanup", async () => {
  for (const mode of ["invalid-ack", "cancel"] as const) {
    const domain = new FakeProtocolDomain();
    domain.exportPayload = new Uint8Array(1024).fill(7);
    const { output, server } = connection(domain);
    try {
      await handshake(
        server,
        protocolOffer(
          [{ major: 0, minor: 2, patch: 0 }],
          [
            Capability.PROJECT_DISCOVERY,
            Capability.SESSION_EXPORT,
            Capability.TRANSFER,
            Capability.FLOW_CONTROL,
            Capability.CANCELLATION,
          ],
        ),
      );
      await bootstrapProject(server);
      await server.receive(
        clientFrame(3n, {
          case: "exportSessionRequest",
          value: {
            requestId: 1n,
            projectId: defaultProjectId,
            sessionId: "session-1",
            format: SessionExportFormat.HTML,
            expectedActiveBranchRevision: "",
            expectedTreeRevision: "",
          },
        }),
      );
      const opened = output.at(-1);
      assert.equal(opened?.operation.case, "transferOpen");
      if (opened?.operation.case !== "transferOpen") continue;
      const transferId = opened.operation.value.transferId;
      assert.ok(domain.lastExportPath);
      await stat(domain.lastExportPath);

      if (mode === "invalid-ack") {
        await server.receive(
          clientFrame(4n, {
            case: "windowUpdate",
            value: {
              target: { case: "transferId", value: transferId },
              creditMessages: 0,
              creditBytes: 1024n,
            },
          }),
        );
        await server.receive(
          clientFrame(5n, {
            case: "transferAck",
            value: {
              transferId,
              acknowledgedSequence: 1n,
              committedBytes: 1000n,
            },
          }),
        );
      } else {
        await server.receive(
          clientFrame(4n, {
            case: "cancel",
            value: { target: { case: "transferId", value: transferId } },
          }),
        );
      }

      const aborted = output.at(-1);
      assert.equal(aborted?.operation.case, "transferAbort");
      if (aborted?.operation.case === "transferAbort") {
        assert.equal(
          aborted.operation.value.error?.code,
          mode === "invalid-ack" ? ErrorCode.PROTOCOL_VIOLATION : ErrorCode.CANCELLED,
        );
      }
      await assert.rejects(() => stat(domain.lastExportPath!));
    } finally {
      await server.dispose();
    }
  }
});

test("rejects reused request and command identifiers without invoking the domain twice", async () => {
  const { output, server } = connection();
  try {
    await handshake(server);
    await bootstrapProject(server);
    await server.receive(
      clientFrame(3n, {
        case: "listSessionsRequest",
        value: { requestId: 9n, projectId: defaultProjectId },
      }),
    );
    await server.receive(
      clientFrame(4n, {
        case: "listSessionsRequest",
        value: { requestId: 9n, projectId: defaultProjectId },
      }),
    );
    await server.receive(
      clientFrame(5n, {
        case: "getSessionRequest",
        value: {
          requestId: 10n,
          sessionId: "session-1",
          projectId: defaultProjectId,
        },
      }),
    );
    await server.receive(
      clientFrame(6n, {
        case: "promptCommand",
        value: {
          requestId: 11n,
          commandId: "same-command",
          sessionId: "session-1",
          prompt: "One",
        },
      }),
    );
    await server.receive(
      clientFrame(7n, {
        case: "promptCommand",
        value: {
          requestId: 12n,
          commandId: "same-command",
          sessionId: "session-1",
          prompt: "Two",
        },
      }),
    );

    const duplicateRequest = output.find(
      (frame) =>
        frame.operation.case === "requestRejected" && frame.operation.value.requestId === 9n,
    );
    assert.equal(
      duplicateRequest?.operation.case === "requestRejected"
        ? duplicateRequest.operation.value.error?.code
        : undefined,
      ErrorCode.ALREADY_EXISTS,
    );
    const duplicateCommand = output.find(
      (frame) =>
        frame.operation.case === "commandRejected" && frame.operation.value.requestId === 12n,
    );
    assert.equal(
      duplicateCommand?.operation.case === "commandRejected"
        ? duplicateCommand.operation.value.error?.code
        : undefined,
      ErrorCode.ALREADY_EXISTS,
    );
  } finally {
    await server.dispose();
  }
});

test("maps unknown domain failures to redacted stable errors", async () => {
  const domain = new FakeProtocolDomain();
  domain.listError = new Error("provider-token=secret-value /private/project/path");
  const { output, server } = connection(domain);
  try {
    await handshake(server);
    await bootstrapProject(server);
    await server.receive(
      clientFrame(3n, {
        case: "listSessionsRequest",
        value: { requestId: 1n, projectId: defaultProjectId },
      }),
    );

    const rejection = output[2];
    assert.equal(rejection?.operation.case, "requestRejected");
    if (rejection?.operation.case === "requestRejected") {
      assert.equal(rejection.operation.value.error?.code, ErrorCode.INTERNAL);
      assert.equal(rejection.operation.value.error?.safeMessage, "The Pi Node operation failed.");
      assert.equal(rejection.operation.value.error?.safeMessage.includes("secret-value"), false);
    }
  } finally {
    await server.dispose();
  }
});

test("closes the connection on a non-contiguous client frame sequence", async () => {
  const { output, server } = connection();
  try {
    await handshake(server);
    const result = await server.receive(
      clientFrame(3n, {
        case: "listSessionsRequest",
        value: { requestId: 1n, projectId: defaultProjectId },
      }),
    );
    assert.deepEqual(result, { close: true, reason: "protocol-error" });
    const lastFrame = output.at(-1);
    assert.equal(lastFrame?.operation.case, "error");
    if (lastFrame?.operation.case === "error") {
      assert.equal(lastFrame.operation.value.error?.code, ErrorCode.PROTOCOL_VIOLATION);
    }
  } finally {
    await server.dispose();
  }
});
