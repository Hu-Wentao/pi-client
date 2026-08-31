import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/protocol/pi_protocol.dart';
import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart' as wire;

void main() {
  group('ProtobufPiProtocolCodec', () {
    late ProtobufPiProtocolCodec codec;
    late _ServerFrameEncoder server;

    setUp(() {
      codec = ProtobufPiProtocolCodec(
        clientInstanceId: 'flutter-test-client',
        implementationVersion: '0.1.0',
      );
      server = _ServerFrameEncoder();
    });

    test('preserves version preference and encodes every client operation', () {
      final preferred = PiProtocolVersion(0, 2, 0);
      final fallback = PiProtocolVersion(0, 1, 0);
      final handshake = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolHandshakeOfferMessage(
            PiProtocolOffer(<PiProtocolVersion>[preferred, fallback]),
          ),
        ),
      );

      expect(
        handshake.whichOperation(),
        wire.PiTransportFrame_Operation.clientProtocolOffer,
      );
      expect(
        handshake.clientProtocolOffer.protocolVersions.map(
          (version) => '${version.major}.${version.minor}.${version.patch}',
        ),
        <String>['0.2.0', '0.1.0'],
      );
      expect(
        handshake.clientProtocolOffer.capabilities,
        containsAll(<wire.Capability>[
          wire.Capability.CAPABILITY_SESSION_READ,
          wire.Capability.CAPABILITY_SESSION_CREATE,
          wire.Capability.CAPABILITY_PROMPT_COMMAND,
          wire.Capability.CAPABILITY_ABORT_COMMAND,
          wire.Capability.CAPABILITY_SESSION_EVENTS,
          wire.Capability.CAPABILITY_PROJECT_DISCOVERY,
          wire.Capability.CAPABILITY_PROJECT_TRUST,
          wire.Capability.CAPABILITY_SESSION_ADMIN,
          wire.Capability.CAPABILITY_SESSION_TREE,
          wire.Capability.CAPABILITY_SESSION_HISTORY,
          wire.Capability.CAPABILITY_SESSION_STATS,
          wire.Capability.CAPABILITY_SESSION_EXPORT,
          wire.Capability.CAPABILITY_CANCELLATION,
          wire.Capability.CAPABILITY_FLOW_CONTROL,
          wire.Capability.CAPABILITY_TRANSFER,
        ]),
      );

      final list = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolListSessionsRequest(requestId: 1, projectId: 'project-1'),
        ),
      );
      final get = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolGetSessionRequest(
            requestId: 2,
            sessionId: 'session-1',
            projectId: 'project-1',
          ),
        ),
      );
      final create = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolCreateSessionRequest(requestId: 3, projectId: 'project-1'),
        ),
      );
      final prompt = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolPromptCommandRequest(
            requestId: 4,
            commandId: 'command-1',
            sessionId: 'session-1',
            prompt: 'private prompt',
          ),
        ),
      );
      final abort = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolAbortCommandRequest(
            requestId: 5,
            commandId: 'command-2',
            sessionId: 'session-1',
          ),
        ),
      );
      final rename = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolRenameSessionCommandRequest(
            requestId: 6,
            commandId: 'admin-rename',
            projectId: 'project-1',
            sessionId: 'session-1',
            name: 'Renamed session',
          ),
        ),
      );
      final clearName = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolClearSessionNameCommandRequest(
            requestId: 7,
            commandId: 'admin-clear',
            projectId: 'project-1',
            sessionId: 'session-1',
          ),
        ),
      );
      final autoName = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolAutoNameSessionCommandRequest(
            requestId: 8,
            commandId: 'admin-auto',
            projectId: 'project-1',
            sessionId: 'session-1',
            timeoutMillis: 15000,
          ),
        ),
      );
      final delete = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolDeleteSessionCommandRequest(
            requestId: 9,
            commandId: 'admin-delete',
            projectId: 'project-1',
            sessionId: 'session-1',
            confirmation: PiProtocolDeleteSessionConfirmationEvidence(
              sessionId: 'session-1',
              adminRevision: 'revision-session-1',
              displayedTitle: 'Session title',
              destructiveActionAcknowledged: true,
            ),
          ),
        ),
      );
      final history = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolGetSessionHistoryRequest(
            requestId: 10,
            projectId: 'project-1',
            sessionId: 'session-1',
            cursor: 'opaque-cursor',
            limit: 50,
            expectedActiveBranchRevision: 'active-1',
            expectedTreeRevision: 'tree-1',
          ),
        ),
      );
      final stats = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolGetSessionStatsRequest(
            requestId: 11,
            projectId: 'project-1',
            sessionId: 'session-1',
          ),
        ),
      );
      final export = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolExportSessionRequest(
            requestId: 12,
            projectId: 'project-1',
            sessionId: 'session-1',
            format: PiProtocolSessionExportFormat.jsonl,
            expectedActiveBranchRevision: 'active-1',
            expectedTreeRevision: 'tree-1',
          ),
        ),
      );
      final window = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolTransferWindowUpdate(
            transferId: 'transfer-1',
            creditBytes: 65536,
          ),
        ),
      );
      final ack = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolTransferAckMessage(
            transferId: 'transfer-1',
            acknowledgedSequence: 2,
            committedBytes: 8,
          ),
        ),
      );
      final cancel = wire.decodeTransportFrame(
        codec.encode(PiProtocolCancelTransferMessage(transferId: 'transfer-1')),
      );

      expect(
        list.whichOperation(),
        wire.PiTransportFrame_Operation.listSessionsRequest,
      );
      expect(list.listSessionsRequest.requestId.toInt(), 1);
      expect(
        get.whichOperation(),
        wire.PiTransportFrame_Operation.getSessionRequest,
      );
      expect(get.getSessionRequest.sessionId, 'session-1');
      expect(get.getSessionRequest.projectId, 'project-1');
      expect(
        create.whichOperation(),
        wire.PiTransportFrame_Operation.createSessionRequest,
      );
      expect(create.createSessionRequest.projectId, 'project-1');
      expect(
        prompt.whichOperation(),
        wire.PiTransportFrame_Operation.promptCommand,
      );
      expect(prompt.promptCommand.prompt, 'private prompt');
      expect(
        abort.whichOperation(),
        wire.PiTransportFrame_Operation.abortCommand,
      );
      expect(abort.abortCommand.commandId, 'command-2');
      expect(rename.renameSessionCommand.name, 'Renamed session');
      expect(
        clearName.whichOperation(),
        wire.PiTransportFrame_Operation.clearSessionNameCommand,
      );
      expect(autoName.autoNameSessionCommand.timeoutMillis, 15000);
      expect(
        delete.deleteSessionCommand.confirmation.adminRevision,
        'revision-session-1',
      );
      expect(
        history.whichOperation(),
        wire.PiTransportFrame_Operation.getSessionHistoryRequest,
      );
      expect(history.getSessionHistoryRequest.cursor, 'opaque-cursor');
      expect(history.getSessionHistoryRequest.limit, 50);
      expect(
        history.getSessionHistoryRequest.expectedActiveBranchRevision,
        'active-1',
      );
      expect(
        stats.whichOperation(),
        wire.PiTransportFrame_Operation.getSessionStatsRequest,
      );
      expect(
        export.whichOperation(),
        wire.PiTransportFrame_Operation.exportSessionRequest,
      );
      expect(
        export.exportSessionRequest.format,
        wire.SessionExportFormat.SESSION_EXPORT_FORMAT_JSONL,
      );
      expect(
        window.whichOperation(),
        wire.PiTransportFrame_Operation.windowUpdate,
      );
      expect(window.windowUpdate.transferId, 'transfer-1');
      expect(window.windowUpdate.creditBytes.toInt(), 65536);
      expect(ack.whichOperation(), wire.PiTransportFrame_Operation.transferAck);
      expect(ack.transferAck.acknowledgedSequence.toInt(), 2);
      expect(cancel.whichOperation(), wire.PiTransportFrame_Operation.cancel);
      expect(cancel.cancel.transferId, 'transfer-1');
      expect(
        <int>[
          handshake.frameSequence.toInt(),
          list.frameSequence.toInt(),
          get.frameSequence.toInt(),
          create.frameSequence.toInt(),
          prompt.frameSequence.toInt(),
          abort.frameSequence.toInt(),
          rename.frameSequence.toInt(),
          clearName.frameSequence.toInt(),
          autoName.frameSequence.toInt(),
          delete.frameSequence.toInt(),
          history.frameSequence.toInt(),
          stats.frameSequence.toInt(),
          export.frameSequence.toInt(),
          window.frameSequence.toInt(),
          ack.frameSequence.toInt(),
          cancel.frameSequence.toInt(),
        ],
        <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
      );
    });

    test('encodes and decodes typed session tree operations', () {
      codec.encode(
        PiProtocolGetSessionTreeRequest(
          requestId: 30,
          projectId: 'project-1',
          sessionId: 'session-1',
        ),
      );
      final getTree = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolGetSessionTreeRequest(
            requestId: 31,
            projectId: 'project-1',
            sessionId: 'session-1',
          ),
        ),
      );
      final navigate = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolNavigateSessionTreeCommandRequest(
            requestId: 32,
            commandId: 'tree-navigate',
            projectId: 'project-1',
            sessionId: 'session-1',
            entryId: 'entry-user-1',
            expectedAdminRevision: 'revision-session-1',
          ),
        ),
      );
      final fork = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolForkSessionCommandRequest(
            requestId: 33,
            commandId: 'tree-fork',
            projectId: 'project-1',
            sessionId: 'session-1',
            userEntryId: 'entry-user-1',
            expectedAdminRevision: 'revision-session-1',
          ),
        ),
      );
      final clone = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolCloneSessionCommandRequest(
            requestId: 34,
            commandId: 'tree-clone',
            projectId: 'project-1',
            sessionId: 'session-1',
            expectedAdminRevision: 'revision-session-1',
          ),
        ),
      );
      expect(
        getTree.whichOperation(),
        wire.PiTransportFrame_Operation.getSessionTreeRequest,
      );
      expect(navigate.navigateSessionTreeCommand.entryId, 'entry-user-1');
      expect(fork.forkSessionCommand.userEntryId, 'entry-user-1');
      expect(
        clone.cloneSessionCommand.expectedAdminRevision,
        'revision-session-1',
      );

      final tree = wire.SessionTreeSnapshot(
        sessionId: 'session-1',
        nodes: <wire.SessionTreeNodeSnapshot>[
          wire.SessionTreeNodeSnapshot(
            entryId: 'entry-user-1',
            kind:
                wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_USER_MESSAGE,
            text: 'Restore this prompt',
            createdAtUnixMillis: Int64(1767268800000),
            isOnActivePath: true,
            canEditFromHere: true,
            canFork: true,
          ),
        ],
        activePathEntryIds: <String>['entry-user-1'],
        activeLeafEntryId: 'entry-user-1',
        canCloneActiveBranch: true,
        adminRevision: 'revision-session-1',
      );
      final response =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    getSessionTreeResponse: wire.GetSessionTreeResponse(
                      requestId: Int64(30),
                      tree: tree,
                    ),
                  ),
                ),
              )
              as PiProtocolSessionTreeResponse;
      expect(response.tree.nodes.single.canFork, isTrue);

      final outcome =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    sessionTreeMutationOutcome: wire.SessionTreeMutationOutcome(
                      requestId: Int64(32),
                      commandId: 'tree-navigate',
                      operation: wire
                          .SessionTreeMutationOperation
                          .SESSION_TREE_MUTATION_OPERATION_NAVIGATE,
                      result: wire.SessionTreeMutationResult(
                        session: _detail('session-1'),
                        tree: tree,
                        editorText: 'Restore this prompt',
                      ),
                    ),
                  ),
                ),
              )
              as PiProtocolSessionTreeMutationOutcomeMessage;
      expect(
        outcome.operation,
        PiProtocolSessionTreeMutationOperation.navigate,
      );
      expect(
        (outcome.outcome as PiProtocolSessionTreeMutationUpdated).editorText,
        'Restore this prompt',
      );
    });

    test('encodes and decodes first-party project operations', () {
      final encoded = <wire.PiTransportFrame>[
        wire.decodeTransportFrame(
          codec.encode(PiProtocolGetProjectBootstrapRequest(requestId: 20)),
        ),
        wire.decodeTransportFrame(
          codec.encode(
            PiProtocolBrowseDirectoryRequest(
              requestId: 21,
              directory: '/safe/home',
              maxChildren: 32,
            ),
          ),
        ),
        wire.decodeTransportFrame(
          codec.encode(
            PiProtocolValidateProjectRequest(
              requestId: 22,
              candidateDirectory: '/safe/project',
            ),
          ),
        ),
        wire.decodeTransportFrame(
          codec.encode(
            PiProtocolListKnownProjectsRequest(requestId: 23, maxProjects: 8),
          ),
        ),
        wire.decodeTransportFrame(
          codec.encode(
            PiProtocolApproveProjectTrustRequest(
              requestId: 24,
              projectId: 'project-1',
              trustRevision:
                  '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
            ),
          ),
        ),
      ];
      expect(
        encoded.map((frame) => frame.whichOperation()),
        <wire.PiTransportFrame_Operation>[
          wire.PiTransportFrame_Operation.getProjectBootstrapRequest,
          wire.PiTransportFrame_Operation.browseDirectoryRequest,
          wire.PiTransportFrame_Operation.validateProjectRequest,
          wire.PiTransportFrame_Operation.listKnownProjectsRequest,
          wire.PiTransportFrame_Operation.approveProjectTrustRequest,
        ],
      );

      final project = _projectSnapshot();
      final bootstrap =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    getProjectBootstrapResponse:
                        wire.GetProjectBootstrapResponse(
                          requestId: Int64(20),
                          homeDirectory: '/safe/home',
                          defaultProject: project,
                        ),
                  ),
                ),
              )
              as PiProtocolProjectBootstrapResponse;
      expect(bootstrap.defaultProject.identity.projectId, 'project-1');
      expect(
        bootstrap.defaultProject.trust.status,
        PiProtocolProjectTrustStatus.approvalRequired,
      );

      final directory =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    browseDirectoryResponse: wire.BrowseDirectoryResponse(
                      requestId: Int64(21),
                      directory: wire.DirectoryListingSnapshot(
                        canonicalDirectory: '/safe/home',
                        parentDirectory: '/safe',
                        children: <wire.DirectoryEntrySnapshot>[
                          wire.DirectoryEntrySnapshot(
                            name: 'project',
                            canonicalPath: '/safe/project',
                            isSymbolicLink: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              as PiProtocolDirectoryResponse;
      expect(directory.directory.children.single.isSymbolicLink, isTrue);

      final known =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    listKnownProjectsResponse: wire.ListKnownProjectsResponse(
                      requestId: Int64(23),
                      projects: <wire.KnownProjectSnapshot>[
                        wire.KnownProjectSnapshot(
                          project: project,
                          lastSessionAtUnixMillis: Int64(1767268800000),
                          sessionCount: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              as PiProtocolKnownProjectsResponse;
      expect(known.projects.single.sessionCount, 2);
    });

    test('decodes handshake, request, and command outcomes', () {
      final accepted =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    serverHandshakeAccepted: wire.ServerHandshakeAccepted(
                      selectedProtocolVersion: wire.ProtocolVersion(
                        major: 0,
                        minor: 1,
                        patch: 0,
                      ),
                      capabilities: <wire.Capability>[
                        wire.Capability.CAPABILITY_SESSION_READ,
                        wire.Capability.CAPABILITY_SESSION_CREATE,
                        wire.Capability.CAPABILITY_PROMPT_COMMAND,
                        wire.Capability.CAPABILITY_ABORT_COMMAND,
                        wire.Capability.CAPABILITY_SESSION_EVENTS,
                      ],
                      nodeInstanceId: 'node-1',
                      implementationName: 'pi-node',
                      implementationVersion: '0.1.0',
                      maxFrameBytes: wire.maxFrameBytes,
                      maxTransferChunkBytes: wire.maxTransferChunkBytes,
                    ),
                  ),
                ),
              )
              as PiProtocolHandshakeAcceptedMessage;
      expect(accepted.negotiatedVersion, PiProtocolVersion(0, 1, 0));
      expect(accepted.capabilities, <PiProtocolCapability>{
        PiProtocolCapability.sessionRead,
        PiProtocolCapability.sessionCreate,
        PiProtocolCapability.promptCommand,
        PiProtocolCapability.abortCommand,
        PiProtocolCapability.sessionEvents,
      });

      final rejected =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    serverHandshakeRejected: wire.ServerHandshakeRejected(
                      error: _stableError(
                        wire.ErrorCode.ERROR_CODE_PERMISSION_DENIED,
                      ),
                    ),
                  ),
                ),
              )
              as PiProtocolHandshakeRejectedMessage;
      expect(rejected.failure.code, 'permission_denied');

      final sessions =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    listSessionsResponse: wire.ListSessionsResponse(
                      requestId: Int64(1),
                      sessions: <wire.SessionSummarySnapshot>[
                        _summary('session-1'),
                      ],
                    ),
                  ),
                ),
              )
              as PiProtocolSessionsResponse;
      expect(sessions.requestId, 1);
      expect(sessions.sessions.single.id, 'session-1');

      final detail =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    getSessionResponse: wire.GetSessionResponse(
                      requestId: Int64(2),
                      session: _detail('session-2'),
                    ),
                  ),
                ),
              )
              as PiProtocolSessionResponse;
      expect(
        detail.session.messages.single.role,
        PiProtocolMessageRole.assistant,
      );
      expect(detail.session.messages.single.createdAt.isUtc, isTrue);

      final created =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    createSessionResponse: wire.CreateSessionResponse(
                      requestId: Int64(3),
                      session: _detail('session-3'),
                    ),
                  ),
                ),
              )
              as PiProtocolSessionCreatedResponse;
      expect(created.session.summary.id, 'session-3');

      final requestRejected =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    requestRejected: wire.RequestRejected(
                      requestId: Int64(4),
                      error: _stableError(wire.ErrorCode.ERROR_CODE_NOT_FOUND),
                    ),
                  ),
                ),
              )
              as PiProtocolRequestRejectedMessage;
      expect(requestRejected.failure.code, 'not_found');

      final commandAccepted =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    commandAccepted: wire.CommandAccepted(
                      requestId: Int64(5),
                      commandId: 'command-accepted',
                    ),
                  ),
                ),
              )
              as PiProtocolCommandAcceptedMessage;
      expect(commandAccepted.commandId, 'command-accepted');

      final commandRejected =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    commandRejected: wire.CommandRejected(
                      requestId: Int64(6),
                      commandId: 'command-rejected',
                      error: _stableError(wire.ErrorCode.ERROR_CODE_CONFLICT),
                    ),
                  ),
                ),
              )
              as PiProtocolCommandRejectedMessage;
      expect(commandRejected.failure.code, 'conflict');

      final adminOutcome =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    sessionAdminCommandOutcome: wire.SessionAdminCommandOutcome(
                      requestId: Int64(8),
                      commandId: 'admin-auto',
                      operation: wire
                          .SessionAdminOperation
                          .SESSION_ADMIN_OPERATION_AUTO_NAME,
                      session: _summary('session-admin'),
                    ),
                  ),
                ),
              )
              as PiProtocolSessionAdminOutcomeMessage;
      expect(adminOutcome.operation, PiProtocolSessionAdminOperation.autoName);
      expect(adminOutcome.outcome, isA<PiProtocolSessionAdminUpdated>());
    });

    test('decodes history statistics and transfer integrity operations', () {
      codec.encode(
        PiProtocolGetSessionHistoryRequest(
          requestId: 30,
          projectId: 'project-1',
          sessionId: 'session-1',
          limit: 50,
        ),
      );
      final history =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    getSessionHistoryResponse: wire.GetSessionHistoryResponse(
                      requestId: Int64(30),
                      summary: _summary('session-1'),
                      messages: <wire.MessageSnapshot>[
                        _message('history-message'),
                      ],
                      nextCursor: 'opaque-next',
                      hasMore: true,
                      activeBranchRevision: 'active-1',
                      treeRevision: 'tree-1',
                    ),
                  ),
                ),
              )
              as PiProtocolSessionHistoryResponse;
      expect(history.messages.single.id, 'history-message');
      expect(history.nextCursor, 'opaque-next');
      expect(history.hasMore, isTrue);
      expect(history.activeBranchRevision, 'active-1');

      codec.encode(
        PiProtocolGetSessionStatsRequest(
          requestId: 31,
          projectId: 'project-1',
          sessionId: 'session-1',
        ),
      );
      final stats =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    getSessionStatsResponse: wire.GetSessionStatsResponse(
                      requestId: Int64(31),
                      stats: wire.SessionStatsSnapshot(
                        projection: wire.SessionSafeProjectionSnapshot(
                          sessionFileName: 'session-1.jsonl',
                          sessionId: 'session-1',
                          projectId: 'project-1',
                          canonicalProjectDirectory: '/safe/project',
                          worktreeId: 'worktree-1',
                          mainProjectId: 'main-project-1',
                        ),
                        userMessages: Int64(2),
                        assistantMessages: Int64(1),
                        totalMessages: Int64(3),
                        inputTokens: Int64(5),
                        outputTokens: Int64(7),
                        totalTokens: Int64(12),
                        activeTimeMillis: Int64(900),
                      ),
                    ),
                  ),
                ),
              )
              as PiProtocolSessionStatsResponse;
      expect(stats.stats.totalMessages, 3);
      expect(stats.stats.totalTokens, 12);
      expect(stats.stats.activeTimeMillis, 900);
      expect(stats.stats.projection.sessionFileName, 'session-1.jsonl');

      codec.encode(
        PiProtocolExportSessionRequest(
          requestId: 32,
          projectId: 'project-1',
          sessionId: 'session-1',
          format: PiProtocolSessionExportFormat.jsonl,
        ),
      );
      final digest = List<int>.generate(32, (index) => index);
      final opened =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    transferOpen: wire.TransferOpen(
                      requestId: Int64(32),
                      transferId: 'transfer-1',
                      direction:
                          wire.TransferDirection.TRANSFER_DIRECTION_DOWNLOAD,
                      purpose: wire.TransferPurpose.TRANSFER_PURPOSE_EXPORT,
                      contentType: 'application/x-ndjson',
                      fileName: 'session.jsonl',
                      totalBytes: Int64(4),
                      chunkBytes: 4,
                      sha256: digest,
                    ),
                  ),
                ),
              )
              as PiProtocolTransferOpenMessage;
      expect(opened.requestId, 32);
      expect(opened.totalBytes, 4);
      expect(opened.sha256, digest);

      final chunk =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    transferChunk: wire.TransferChunk(
                      transferId: 'transfer-1',
                      chunkSequence: Int64(1),
                      offset: Int64.ZERO,
                      data: <int>[1, 2, 3, 4],
                    ),
                  ),
                ),
              )
              as PiProtocolTransferChunkMessage;
      expect(chunk.sequence, 1);
      expect(chunk.offset, 0);
      expect(chunk.data, <int>[1, 2, 3, 4]);

      final complete =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    transferComplete: wire.TransferComplete(
                      transferId: 'transfer-1',
                      totalBytes: Int64(4),
                      sha256: digest,
                    ),
                  ),
                ),
              )
              as PiProtocolTransferCompleteMessage;
      expect(complete.totalBytes, 4);
      expect(complete.sha256, digest);

      final abort =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    transferAbort: wire.TransferAbort(
                      transferId: 'transfer-2',
                      error: _stableError(wire.ErrorCode.ERROR_CODE_CANCELLED),
                    ),
                  ),
                ),
              )
              as PiProtocolTransferAbortMessage;
      expect(abort.failure.code, 'cancelled');
    });

    test('maps correlated error envelopes to command uncertainty', () {
      codec.encode(
        PiProtocolPromptCommandRequest(
          requestId: 7,
          commandId: 'command-uncertain',
          sessionId: 'session-1',
          prompt: 'private prompt',
        ),
      );

      final result =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    error: wire.ErrorEnvelope(
                      requestId: Int64(7),
                      error: _stableError(wire.ErrorCode.ERROR_CODE_NODE_BUSY),
                    ),
                  ),
                ),
              )
              as PiProtocolCommandUncertainMessage;

      expect(result.requestId, 7);
      expect(result.commandId, 'command-uncertain');
      expect(result.failure.code, 'node_busy');
      expect(result.failure.retryable, isTrue);
    });

    test('decodes every current session event payload', () {
      final added =
          codec.decode(
                server.encode(
                  _sessionEventFrame(
                    sequence: 1,
                    messageAdded: wire.MessageAddedEvent(
                      message: _message('message-added'),
                    ),
                  ),
                ),
              )
              as PiProtocolSessionEventMessage;
      expect(added.event, isA<PiProtocolMessageAddedEvent>());

      final delta =
          codec.decode(
                server.encode(
                  _sessionEventFrame(
                    sequence: 2,
                    messageDelta: wire.MessageDeltaEvent(
                      messageId: 'message-added',
                      delta: 'delta',
                    ),
                  ),
                ),
              )
              as PiProtocolSessionEventMessage;
      expect((delta.event as PiProtocolMessageDeltaEvent).delta, 'delta');

      final running =
          codec.decode(
                server.encode(
                  _sessionEventFrame(
                    sequence: 3,
                    runningChanged: wire.SessionRunningChangedEvent(
                      isRunning: true,
                    ),
                  ),
                ),
              )
              as PiProtocolSessionEventMessage;
      expect(
        (running.event as PiProtocolSessionRunningChangedEvent).isRunning,
        isTrue,
      );

      final completed =
          codec.decode(
                server.encode(
                  _sessionEventFrame(
                    sequence: 4,
                    commandCompleted: wire.CommandCompletedEvent(
                      commandId: 'command-completed',
                      succeeded: true,
                    ),
                  ),
                ),
              )
              as PiProtocolSessionEventMessage;
      expect(completed.sequence, 4);
      expect(
        (completed.event as PiProtocolCommandCompletedEvent).succeeded,
        isTrue,
      );
    });

    test('maps all stable Protobuf error codes to machine-safe names', () {
      final expected = <wire.ErrorCode, String>{
        wire.ErrorCode.ERROR_CODE_AUTHENTICATION_REQUIRED:
            'authentication_required',
        wire.ErrorCode.ERROR_CODE_PERMISSION_DENIED: 'permission_denied',
        wire.ErrorCode.ERROR_CODE_NOT_FOUND: 'not_found',
        wire.ErrorCode.ERROR_CODE_INVALID_REQUEST: 'invalid_request',
        wire.ErrorCode.ERROR_CODE_CONFLICT: 'conflict',
        wire.ErrorCode.ERROR_CODE_NODE_BUSY: 'node_busy',
        wire.ErrorCode.ERROR_CODE_PROTOCOL_VERSION_UNSUPPORTED:
            'protocol_version_unsupported',
        wire.ErrorCode.ERROR_CODE_CANCELLED: 'cancelled',
        wire.ErrorCode.ERROR_CODE_DEADLINE_EXCEEDED: 'deadline_exceeded',
        wire.ErrorCode.ERROR_CODE_UNAVAILABLE: 'unavailable',
        wire.ErrorCode.ERROR_CODE_DATA_LOSS: 'data_loss',
        wire.ErrorCode.ERROR_CODE_INTERNAL: 'internal',
        wire.ErrorCode.ERROR_CODE_PROTOCOL_VIOLATION: 'protocol_violation',
        wire.ErrorCode.ERROR_CODE_RESOURCE_EXHAUSTED: 'resource_exhausted',
        wire.ErrorCode.ERROR_CODE_ALREADY_EXISTS: 'already_exists',
        wire.ErrorCode.ERROR_CODE_FAILED_PRECONDITION: 'failed_precondition',
      };

      var requestId = 100;
      for (final entry in expected.entries) {
        final response =
            codec.decode(
                  server.encode(
                    wire.PiTransportFrame(
                      requestRejected: wire.RequestRejected(
                        requestId: Int64(requestId),
                        error: _stableError(entry.key),
                      ),
                    ),
                  ),
                )
                as PiProtocolRequestRejectedMessage;
        expect(response.failure.code, entry.value);
        requestId += 1;
      }
    });

    test('fails closed for committed out-of-range and unknown vectors', () {
      final vectors = Directory.current.uri.resolve('protocol/test-vectors/');

      for (final name in <String>[
        'dart_session_event.pb',
        'ts_session_response.pb',
      ]) {
        expect(
          () => codec.decode(
            Uint8List.fromList(
              File.fromUri(vectors.resolve(name)).readAsBytesSync(),
            ),
          ),
          throwsA(
            isA<PiProtocolCodecException>().having(
              (error) => error.code,
              'code',
              PiProtocolCodecErrorCode.integerOutOfRange,
            ),
          ),
        );
      }

      for (final name in <String>['unknown_enum.pb', 'unknown_operation.pb']) {
        expect(
          () => codec.decode(
            Uint8List.fromList(
              File.fromUri(vectors.resolve(name)).readAsBytesSync(),
            ),
          ),
          throwsA(isA<PiProtocolCodecException>()),
        );
      }
    });

    test('rejects unsupported known operations and oversized Dart IDs', () {
      expect(
        () => codec.decode(
          server.encode(
            wire.PiTransportFrame(
              healthResponse: wire.HealthResponse(
                requestId: Int64(1),
                status: wire.HealthStatus.HEALTH_STATUS_SERVING,
                nodeVersion: '0.1.0',
                uptimeMillis: Int64(1),
              ),
            ),
          ),
        ),
        throwsA(
          isA<PiProtocolCodecException>().having(
            (error) => error.code,
            'code',
            PiProtocolCodecErrorCode.unsupportedOperation,
          ),
        ),
      );

      expect(
        () => codec.encode(
          PiProtocolListSessionsRequest(
            requestId: 9007199254740992,
            projectId: 'project-1',
          ),
        ),
        throwsA(
          isA<PiProtocolCodecException>().having(
            (error) => error.code,
            'code',
            PiProtocolCodecErrorCode.integerOutOfRange,
          ),
        ),
      );
    });
  });
}

final class _ServerFrameEncoder {
  var _sequence = 1;

  Uint8List encode(wire.PiTransportFrame frame) {
    frame.frameSequence = Int64(_sequence);
    _sequence += 1;
    return wire.encodeTransportFrame(frame);
  }
}

wire.StableError _stableError(wire.ErrorCode code) => wire.StableError(
  code: code,
  retryable: code == wire.ErrorCode.ERROR_CODE_NODE_BUSY,
  safeMessage: 'Safe remote failure.',
);

wire.ProjectSnapshot _projectSnapshot() => wire.ProjectSnapshot(
  identity: wire.ProjectIdentitySnapshot(
    projectId: 'project-1',
    canonicalWorkingDirectory: '/safe/project',
    isGitRepository: true,
    gitRoot: '/safe/project',
    mainWorktreeRoot: '/safe/main',
    branch: 'feature/project',
    isLinkedWorktree: true,
    isDetachedHead: false,
    worktreeId: 'worktree-1',
    mainProjectId: 'main-project-1',
  ),
  trust: wire.ProjectTrustSnapshot(
    status: wire.ProjectTrustStatus.PROJECT_TRUST_STATUS_APPROVAL_REQUIRED,
    reasons: <wire.ProjectTrustReason>[
      wire.ProjectTrustReason.PROJECT_TRUST_REASON_PI_SETTINGS,
    ],
    revision:
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
  ),
);

wire.SessionSummarySnapshot _summary(String id) => wire.SessionSummarySnapshot(
  sessionId: id,
  title: 'Session title',
  workingDirectory: '/safe/project',
  createdAtUnixMillis: Int64(1767268800000),
  updatedAtUnixMillis: Int64(1767268860000),
  isRunning: false,
  hasUnread: false,
  adminRevision: 'revision-$id-1',
  hasCustomName: true,
);

wire.SessionDetailSnapshot _detail(String id) => wire.SessionDetailSnapshot(
  summary: _summary(id),
  messages: <wire.MessageSnapshot>[_message('message-1')],
);

wire.MessageSnapshot _message(String id) => wire.MessageSnapshot(
  messageId: id,
  role: wire.MessageRole.MESSAGE_ROLE_ASSISTANT,
  text: 'Message text',
  createdAtUnixMillis: Int64(1767268800000),
  isStreaming: false,
);

wire.PiTransportFrame _sessionEventFrame({
  required int sequence,
  wire.MessageAddedEvent? messageAdded,
  wire.MessageDeltaEvent? messageDelta,
  wire.SessionRunningChangedEvent? runningChanged,
  wire.CommandCompletedEvent? commandCompleted,
}) => wire.PiTransportFrame(
  sessionEventStream: wire.SessionEventStreamEnvelope(
    streamId: 'session-events-1',
    sessionId: 'session-1',
    eventSequence: Int64(sequence),
    messageAdded: messageAdded,
    messageDelta: messageDelta,
    runningChanged: runningChanged,
    commandCompleted: commandCompleted,
  ),
);
