import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

import '../../protocol/pi_protocol.dart';
import '../../transport/pi_transport.dart';
import 'pi_node_api.dart';
import 'pi_node_errors.dart';
import 'pi_node_models.dart';

final class PiNodeClient implements PiNodeApi {
  PiNodeClient({
    required PiTransport transport,
    required PiProtocolCodec codec,
    required PiProtocolOffer protocolOffer,
  }) : _transport = transport,
       _codec = codec,
       _protocolOffer = protocolOffer;

  final PiTransport _transport;
  final PiProtocolCodec _codec;
  final PiProtocolOffer _protocolOffer;
  final StreamController<PiNodeConnectionSnapshot> _connectionStates =
      StreamController<PiNodeConnectionSnapshot>.broadcast(sync: true);
  final Map<int, _PendingOperation> _pending = <int, _PendingOperation>{};
  final Map<PiSessionId, StreamController<PiSessionEvent>> _sessionControllers =
      <PiSessionId, StreamController<PiSessionEvent>>{};
  final Map<PiSessionId, int> _lastSessionSequences = <PiSessionId, int>{};
  final Map<String, _ClientTransfer> _transfers = <String, _ClientTransfer>{};

  PiNodeConnectionSnapshot _connection =
      const PiNodeConnectionSnapshot.disconnected();
  StreamSubscription<PiTransportFrame>? _incomingSubscription;
  Completer<PiNodeConnectionSnapshot>? _handshakeCompleter;
  Future<PiNodeConnectionSnapshot>? _connectFuture;
  Future<void>? _closeFuture;
  var _nextRequestId = 1;
  var _listenerStarted = false;
  var _terminalDisconnected = false;
  var _closing = false;

  @override
  PiNodeConnectionSnapshot get connection => _connection;

  @override
  Stream<PiNodeConnectionSnapshot> get connectionStates =>
      _connectionStates.stream;

  @override
  Future<PiNodeConnectionSnapshot> connect() {
    if (_connection.status == PiNodeConnectionStatus.connected) {
      return Future<PiNodeConnectionSnapshot>.value(_connection);
    }
    if (_connection.status == PiNodeConnectionStatus.closed || _closing) {
      return Future<PiNodeConnectionSnapshot>.error(
        const PiNodeException(PiNodeErrorCode.closed, retryable: false),
      );
    }
    if (_terminalDisconnected) {
      return Future<PiNodeConnectionSnapshot>.error(
        const PiNodeException(PiNodeErrorCode.disconnected, retryable: true),
      );
    }
    final existing = _connectFuture;
    if (existing != null) return existing;

    final completer = Completer<PiNodeConnectionSnapshot>();
    _handshakeCompleter = completer;
    _connectFuture = completer.future;
    _emitConnection(const PiNodeConnectionSnapshot.connecting());
    _startListener();

    scheduleMicrotask(() {
      if (_closing || _terminalDisconnected) return;
      PiTransportFrame frame;
      try {
        frame = _encode(PiProtocolHandshakeOfferMessage(_protocolOffer));
      } on PiNodeException catch (error) {
        _failConnection(error, closeTransport: true);
        return;
      }
      unawaited(_sendHandshake(frame));
    });
    return completer.future;
  }

  @override
  Future<PiProjectBootstrap> getProjectBootstrap() =>
      _sendRequest<PiProjectBootstrap>(
        (requestId) =>
            PiProtocolGetProjectBootstrapRequest(requestId: requestId),
        (message) => switch (message) {
          PiProtocolProjectBootstrapResponse(
            :final homeDirectory,
            :final defaultProject,
          ) =>
            PiProjectBootstrap(
              homeDirectory: homeDirectory,
              defaultProject: _projectFromProtocol(defaultProject),
            ),
          PiProtocolRequestRejectedMessage(:final failure) =>
            throw PiNodeException.fromProtocolFailure(failure),
          _ => throw const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: false,
          ),
        },
      );

  @override
  Future<PiDirectoryListing> browseDirectory(
    PiBrowseDirectoryRequest request,
  ) => _sendRequest<PiDirectoryListing>(
    (requestId) => PiProtocolBrowseDirectoryRequest(
      requestId: requestId,
      directory: request.directory,
      maxChildren: request.maxChildren,
    ),
    (message) => switch (message) {
      PiProtocolDirectoryResponse(:final directory) => _directoryFromProtocol(
        directory,
      ),
      PiProtocolRequestRejectedMessage(:final failure) =>
        throw PiNodeException.fromProtocolFailure(failure),
      _ => throw const PiNodeException(
        PiNodeErrorCode.unexpectedResponse,
        retryable: false,
      ),
    },
  );

  @override
  Future<PiProject> validateProject(PiValidateProjectRequest request) =>
      _sendRequest<PiProject>(
        (requestId) => PiProtocolValidateProjectRequest(
          requestId: requestId,
          candidateDirectory: request.candidateDirectory,
        ),
        (message) => switch (message) {
          PiProtocolProjectValidatedResponse(:final project) =>
            _projectFromProtocol(project),
          PiProtocolRequestRejectedMessage(:final failure) =>
            throw PiNodeException.fromProtocolFailure(failure),
          _ => throw const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: false,
          ),
        },
      );

  @override
  Future<List<PiKnownProject>> listKnownProjects({int maxProjects = 24}) =>
      _sendRequest<List<PiKnownProject>>(
        (requestId) => PiProtocolListKnownProjectsRequest(
          requestId: requestId,
          maxProjects: maxProjects,
        ),
        (message) => switch (message) {
          PiProtocolKnownProjectsResponse(:final projects) =>
            List<PiKnownProject>.unmodifiable(
              projects.map(
                (known) => PiKnownProject(
                  project: _projectFromProtocol(known.project),
                  lastSessionAt: known.lastSessionAt,
                  sessionCount: known.sessionCount,
                ),
              ),
            ),
          PiProtocolRequestRejectedMessage(:final failure) =>
            throw PiNodeException.fromProtocolFailure(failure),
          _ => throw const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: false,
          ),
        },
      );

  @override
  Future<PiProject> approveProjectTrust(PiProjectTrustApproval approval) =>
      _sendRequest<PiProject>(
        (requestId) => PiProtocolApproveProjectTrustRequest(
          requestId: requestId,
          projectId: approval.projectId.value,
          trustRevision: approval.revision.value,
        ),
        (message) => switch (message) {
          PiProtocolProjectTrustApprovedResponse(:final project) =>
            _projectFromProtocol(project),
          PiProtocolRequestRejectedMessage(:final failure) =>
            throw PiNodeException.fromProtocolFailure(failure),
          _ => throw const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: false,
          ),
        },
      );

  @override
  Future<List<PiSessionSummary>> listSessions(PiProjectId projectId) =>
      _sendRequest<List<PiSessionSummary>>(
        (requestId) => PiProtocolListSessionsRequest(
          requestId: requestId,
          projectId: projectId.value,
        ),
        (message) => switch (message) {
          PiProtocolSessionsResponse(:final sessions) =>
            List<PiSessionSummary>.unmodifiable(
              sessions.map(_sessionSummaryFromProtocol),
            ),
          PiProtocolRequestRejectedMessage(:final failure) =>
            throw PiNodeException.fromProtocolFailure(failure),
          _ => throw const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: false,
          ),
        },
      );

  @override
  Future<PiSessionDetail> getSession(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) => _sendRequest<PiSessionDetail>(
    (requestId) => PiProtocolGetSessionRequest(
      requestId: requestId,
      sessionId: sessionId.value,
      projectId: projectId.value,
    ),
    (message) => switch (message) {
      PiProtocolSessionResponse(:final session) => _acceptSessionDetail(
        session,
      ),
      PiProtocolRequestRejectedMessage(:final failure) =>
        throw PiNodeException.fromProtocolFailure(failure),
      _ => throw const PiNodeException(
        PiNodeErrorCode.unexpectedResponse,
        retryable: false,
      ),
    },
  );

  @override
  Future<PiSessionDetail> createSession(PiCreateSessionRequest request) =>
      _sendRequest<PiSessionDetail>(
        (requestId) => PiProtocolCreateSessionRequest(
          requestId: requestId,
          projectId: request.projectId.value,
        ),
        (message) => switch (message) {
          PiProtocolSessionCreatedResponse(:final session) =>
            _acceptSessionDetail(session),
          PiProtocolRequestRejectedMessage(:final failure) =>
            throw PiNodeException.fromProtocolFailure(failure),
          _ => throw const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: false,
          ),
        },
      );

  @override
  Future<PiSessionTree> getSessionTree(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) => _sendRequest<PiSessionTree>(
    (requestId) => PiProtocolGetSessionTreeRequest(
      requestId: requestId,
      projectId: projectId.value,
      sessionId: sessionId.value,
    ),
    (message) => switch (message) {
      PiProtocolSessionTreeResponse(:final tree) => _sessionTreeFromProtocol(
        tree,
      ),
      PiProtocolRequestRejectedMessage(:final failure) =>
        throw PiNodeException.fromProtocolFailure(failure),
      _ => throw const PiNodeException(
        PiNodeErrorCode.unexpectedResponse,
        retryable: false,
      ),
    },
  );

  @override
  Future<PiSessionHistoryPage> getSessionHistory(
    PiSessionHistoryRequest request,
  ) => _sendRequest<PiSessionHistoryPage>(
    (requestId) => PiProtocolGetSessionHistoryRequest(
      requestId: requestId,
      projectId: request.projectId.value,
      sessionId: request.sessionId.value,
      cursor: request.cursor?.value,
      limit: request.limit,
      expectedActiveBranchRevision: request.expectedActiveBranchRevision?.value,
      expectedTreeRevision: request.expectedTreeRevision?.value,
    ),
    (message) => switch (message) {
      PiProtocolSessionHistoryResponse(:final summary, :final conversation) =>
        _acceptSessionHistory(summary, conversation),
      PiProtocolRequestRejectedMessage(:final failure) =>
        throw PiNodeException.fromProtocolFailure(failure),
      _ => throw const PiNodeException(
        PiNodeErrorCode.unexpectedResponse,
        retryable: false,
      ),
    },
  );

  @override
  Future<PiMessageContentHandle> getMessageContent(
    PiMessageContentRequest request,
  ) => _sendRequest<PiMessageContentHandle>(
    (requestId) => PiProtocolGetMessageContentRequest(
      requestId: requestId,
      projectId: request.projectId.value,
      binding: _protocolContentBinding(request.binding),
      expectedMimeType: request.reference.mimeType,
      expectedTotalBytes: request.reference.totalBytes,
      expectedSha256: request.reference.sha256,
    ),
    (message) => switch (message) {
      PiProtocolTransferOpenMessage() => _openMessageContentTransfer(
        message,
        request,
      ),
      PiProtocolRequestRejectedMessage(:final failure) =>
        throw PiNodeException.fromProtocolFailure(failure),
      _ => throw const PiNodeException(
        PiNodeErrorCode.unexpectedResponse,
        retryable: false,
      ),
    },
  );

  @override
  Future<PiSessionStats> getSessionStats(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) => _sendRequest<PiSessionStats>(
    (requestId) => PiProtocolGetSessionStatsRequest(
      requestId: requestId,
      projectId: projectId.value,
      sessionId: sessionId.value,
    ),
    (message) => switch (message) {
      PiProtocolSessionStatsResponse(:final stats) => _statsFromProtocol(stats),
      PiProtocolRequestRejectedMessage(:final failure) =>
        throw PiNodeException.fromProtocolFailure(failure),
      _ => throw const PiNodeException(
        PiNodeErrorCode.unexpectedResponse,
        retryable: false,
      ),
    },
  );

  @override
  Future<PiSessionExportHandle> exportSession(PiSessionExportRequest request) =>
      _sendRequest<PiSessionExportHandle>(
        (requestId) => PiProtocolExportSessionRequest(
          requestId: requestId,
          projectId: request.projectId.value,
          sessionId: request.sessionId.value,
          format: switch (request.format) {
            PiSessionExportFormat.html => PiProtocolSessionExportFormat.html,
            PiSessionExportFormat.jsonl => PiProtocolSessionExportFormat.jsonl,
          },
          expectedActiveBranchRevision:
              request.expectedActiveBranchRevision?.value,
          expectedTreeRevision: request.expectedTreeRevision?.value,
        ),
        (message) => switch (message) {
          PiProtocolTransferOpenMessage() => _openExportTransfer(message),
          PiProtocolRequestRejectedMessage(:final failure) =>
            throw PiNodeException.fromProtocolFailure(failure),
          _ => throw const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: false,
          ),
        },
      );

  @override
  Future<PiSessionTreeMutationResult> navigateSessionTree(
    PiNavigateSessionTreeCommand command,
  ) => _sendSessionTreeMutation(
    command,
    PiSessionTreeMutationOperation.navigate,
    (requestId) => PiProtocolNavigateSessionTreeCommandRequest(
      requestId: requestId,
      commandId: command.commandId.value,
      projectId: command.projectId.value,
      sessionId: command.sessionId.value,
      entryId: command.entryId.value,
      expectedAdminRevision: command.expectedAdminRevision.value,
    ),
  );

  @override
  Future<PiSessionTreeMutationResult> forkSession(
    PiForkSessionCommand command,
  ) => _sendSessionTreeMutation(
    command,
    PiSessionTreeMutationOperation.fork,
    (requestId) => PiProtocolForkSessionCommandRequest(
      requestId: requestId,
      commandId: command.commandId.value,
      projectId: command.projectId.value,
      sessionId: command.sessionId.value,
      userEntryId: command.userEntryId.value,
      expectedAdminRevision: command.expectedAdminRevision.value,
    ),
  );

  @override
  Future<PiSessionTreeMutationResult> cloneSession(
    PiCloneSessionCommand command,
  ) => _sendSessionTreeMutation(
    command,
    PiSessionTreeMutationOperation.clone,
    (requestId) => PiProtocolCloneSessionCommandRequest(
      requestId: requestId,
      commandId: command.commandId.value,
      projectId: command.projectId.value,
      sessionId: command.sessionId.value,
      expectedAdminRevision: command.expectedAdminRevision.value,
    ),
  );

  @override
  Future<PiSessionAdminResult> renameSession(PiRenameSessionCommand command) =>
      _sendSessionAdminCommand(
        command,
        PiSessionAdminOperation.rename,
        (requestId) => PiProtocolRenameSessionCommandRequest(
          requestId: requestId,
          commandId: command.commandId.value,
          projectId: command.projectId.value,
          sessionId: command.sessionId.value,
          name: command.name,
        ),
      );

  @override
  Future<PiSessionAdminResult> clearSessionName(
    PiClearSessionNameCommand command,
  ) => _sendSessionAdminCommand(
    command,
    PiSessionAdminOperation.clearName,
    (requestId) => PiProtocolClearSessionNameCommandRequest(
      requestId: requestId,
      commandId: command.commandId.value,
      projectId: command.projectId.value,
      sessionId: command.sessionId.value,
    ),
  );

  @override
  Future<PiSessionAdminResult> autoNameSession(
    PiAutoNameSessionCommand command,
  ) => _sendSessionAdminCommand(
    command,
    PiSessionAdminOperation.autoName,
    (requestId) => PiProtocolAutoNameSessionCommandRequest(
      requestId: requestId,
      commandId: command.commandId.value,
      projectId: command.projectId.value,
      sessionId: command.sessionId.value,
      timeoutMillis: command.timeout.inMilliseconds,
    ),
  );

  @override
  Future<PiSessionAdminResult> deleteSession(PiDeleteSessionCommand command) =>
      _sendSessionAdminCommand(
        command,
        PiSessionAdminOperation.delete,
        (requestId) => PiProtocolDeleteSessionCommandRequest(
          requestId: requestId,
          commandId: command.commandId.value,
          projectId: command.projectId.value,
          sessionId: command.sessionId.value,
          confirmation: PiProtocolDeleteSessionConfirmationEvidence(
            sessionId: command.confirmation.sessionId.value,
            adminRevision: command.confirmation.adminRevision.value,
            displayedTitle: command.confirmation.displayedTitle,
            destructiveActionAcknowledged:
                command.confirmation.destructiveActionAcknowledged,
          ),
        ),
      );

  @override
  Future<PiCommandResult> prompt(PiPromptCommand command) => _sendCommand(
    command,
    (requestId) => PiProtocolPromptCommandRequest(
      requestId: requestId,
      commandId: command.commandId.value,
      sessionId: command.sessionId.value,
      prompt: command.prompt,
    ),
  );

  @override
  Future<PiCommandResult> abort(PiAbortCommand command) => _sendCommand(
    command,
    (requestId) => PiProtocolAbortCommandRequest(
      requestId: requestId,
      commandId: command.commandId.value,
      sessionId: command.sessionId.value,
    ),
  );

  @override
  Stream<PiSessionEvent> sessionEvents(PiSessionId sessionId) {
    if (_connection.status == PiNodeConnectionStatus.closed || _closing) {
      return Stream<PiSessionEvent>.error(
        const PiNodeException(PiNodeErrorCode.closed, retryable: false),
      );
    }
    if (_terminalDisconnected) {
      return Stream<PiSessionEvent>.error(
        const PiNodeException(PiNodeErrorCode.disconnected, retryable: true),
      );
    }
    return _sessionControllers
        .putIfAbsent(
          sessionId,
          () => StreamController<PiSessionEvent>.broadcast(sync: true),
        )
        .stream;
  }

  @override
  Future<void> close() => _closeFuture ??= _close();

  void _startListener() {
    if (_listenerStarted) return;
    _listenerStarted = true;
    _incomingSubscription = _transport.incoming.listen(
      _handleFrame,
      onError: (Object _, StackTrace _) {
        _failConnection(
          const PiNodeException(PiNodeErrorCode.disconnected, retryable: true),
        );
      },
      onDone: () {
        _failConnection(
          const PiNodeException(PiNodeErrorCode.disconnected, retryable: true),
        );
      },
      cancelOnError: false,
    );
    unawaited(
      _transport.done.then<void>(
        (_) {
          _failConnection(
            const PiNodeException(
              PiNodeErrorCode.disconnected,
              retryable: true,
            ),
          );
        },
        onError: (Object _, StackTrace _) {
          _failConnection(
            const PiNodeException(
              PiNodeErrorCode.disconnected,
              retryable: true,
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendHandshake(PiTransportFrame frame) async {
    try {
      await _transport.send(frame);
    } catch (_) {
      _failConnection(
        const PiNodeException(PiNodeErrorCode.disconnected, retryable: true),
      );
    }
  }

  void _handleFrame(PiTransportFrame frame) {
    PiServerProtocolMessage message;
    try {
      message = _codec.decode(frame.bytes);
    } catch (_) {
      _failConnection(
        const PiNodeException(PiNodeErrorCode.malformedFrame, retryable: false),
        closeTransport: true,
      );
      return;
    }

    if (_connection.status == PiNodeConnectionStatus.connecting) {
      _handleHandshakeMessage(message);
      return;
    }
    if (_connection.status != PiNodeConnectionStatus.connected) return;

    if (message is PiProtocolResponseMessage) {
      _handleResponse(message);
    } else if (message is PiProtocolSessionEventMessage) {
      _handleSessionEvent(message);
    } else if (message is PiProtocolTransferChunkMessage) {
      _transfers[message.transferId]?.acceptChunk(message);
    } else if (message is PiProtocolTransferCompleteMessage) {
      _transfers[message.transferId]?.acceptComplete(message);
    } else if (message is PiProtocolTransferAbortMessage) {
      _transfers[message.transferId]?.acceptAbort(message);
    } else {
      _failConnection(
        const PiNodeException(
          PiNodeErrorCode.unexpectedResponse,
          retryable: false,
        ),
        closeTransport: true,
      );
    }
  }

  void _handleHandshakeMessage(PiServerProtocolMessage message) {
    if (message is PiProtocolHandshakeAcceptedMessage) {
      if (!_protocolOffer.supports(message.negotiatedVersion)) {
        _failConnection(
          const PiNodeException(
            PiNodeErrorCode.protocolMismatch,
            retryable: false,
          ),
          closeTransport: true,
        );
        return;
      }
      final connected = PiNodeConnectionSnapshot.connected(
        message.negotiatedVersion,
        capabilities: message.capabilities,
      );
      _emitConnection(connected);
      final completer = _handshakeCompleter;
      _handshakeCompleter = null;
      if (completer != null && !completer.isCompleted) {
        completer.complete(connected);
      }
      return;
    }
    if (message is PiProtocolHandshakeRejectedMessage) {
      _failConnection(
        PiNodeException.fromProtocolFailure(message.failure),
        closeTransport: true,
      );
      return;
    }
    _failConnection(
      const PiNodeException(
        PiNodeErrorCode.unexpectedResponse,
        retryable: false,
      ),
      closeTransport: true,
    );
  }

  void _handleResponse(PiProtocolResponseMessage message) {
    final pending = _pending.remove(message.requestId);
    if (pending == null) {
      _failConnection(
        const PiNodeException(
          PiNodeErrorCode.unexpectedResponse,
          retryable: false,
        ),
        closeTransport: true,
      );
      return;
    }
    pending.complete(message);
  }

  PiSessionExportHandle _openExportTransfer(
    PiProtocolTransferOpenMessage message,
  ) {
    if (message.purpose != PiProtocolTransferPurpose.export ||
        message.messageContentBinding != null) {
      throw const PiNodeException(
        PiNodeErrorCode.protocolViolation,
        retryable: false,
      );
    }
    return _openTransfer(message);
  }

  PiMessageContentHandle _openMessageContentTransfer(
    PiProtocolTransferOpenMessage message,
    PiMessageContentRequest request,
  ) {
    final binding = message.messageContentBinding;
    if (message.purpose != PiProtocolTransferPurpose.messageContent ||
        binding == null ||
        !_sameContentBinding(binding, request.binding) ||
        message.contentType != request.reference.mimeType ||
        message.totalBytes != request.reference.totalBytes ||
        !_sameBytes(message.sha256, request.reference.sha256)) {
      throw const PiNodeException(PiNodeErrorCode.dataLoss, retryable: false);
    }
    return _openTransfer(message);
  }

  _ClientTransfer _openTransfer(PiProtocolTransferOpenMessage message) {
    if (_transfers.containsKey(message.transferId)) {
      throw const PiNodeException(
        PiNodeErrorCode.protocolViolation,
        retryable: false,
      );
    }
    final transfer = _ClientTransfer(
      metadata: message,
      send: _sendControl,
      onFinished: () => _transfers.remove(message.transferId),
    );
    _transfers[message.transferId] = transfer;
    return transfer;
  }

  PiSessionDetail _acceptSessionDetail(PiProtocolSessionDetail value) {
    final detail = _sessionDetailFromProtocol(value);
    _lastSessionSequences[detail.summary.id] =
        detail.conversation.lastEventSequence;
    return detail;
  }

  PiSessionHistoryPage _acceptSessionHistory(
    PiProtocolSessionSummary summary,
    PiProtocolConversationPage conversation,
  ) {
    final page = PiSessionHistoryPage(
      summary: _sessionSummaryFromProtocol(summary),
      conversation: _conversationPageFromProtocol(conversation),
    );
    _lastSessionSequences[page.summary.id] =
        page.conversation.lastEventSequence;
    return page;
  }

  Future<void> _sendControl(PiClientProtocolMessage message) async {
    _ensureConnected();
    try {
      await _transport.send(_encode(message));
    } catch (_) {
      throw const PiNodeException(
        PiNodeErrorCode.disconnected,
        retryable: true,
      );
    }
  }

  void _handleSessionEvent(PiProtocolSessionEventMessage message) {
    final sessionId = PiSessionId(message.sessionId);
    final controller = _sessionControllers[sessionId];
    if (controller == null || controller.isClosed) return;

    final lastSequence = _lastSessionSequences[sessionId] ?? 0;
    if (message.sequence <= lastSequence) return;

    final expectedSequence = lastSequence + 1;
    _lastSessionSequences[sessionId] = message.sequence;
    if (message.sequence > expectedSequence) {
      controller.add(
        PiSessionSequenceGapEvent(
          sessionId: sessionId,
          expectedSequence: expectedSequence,
          receivedSequence: message.sequence,
        ),
      );
      return;
    }
    controller.add(_sessionEventFromProtocol(sessionId, message));
  }

  Future<T> _sendRequest<T>(
    PiProtocolRequestMessage Function(int requestId) buildMessage,
    T Function(PiProtocolResponseMessage message) parse,
  ) {
    try {
      _ensureConnected();
    } catch (error, stackTrace) {
      return Future<T>.error(error, stackTrace);
    }
    final requestId = _takeRequestId();
    final completer = Completer<T>();
    final pending = _PendingRequest<T>(completer, parse);
    _pending[requestId] = pending;

    PiTransportFrame frame;
    try {
      frame = _encode(buildMessage(requestId));
    } catch (error, stackTrace) {
      _pending.remove(requestId);
      return Future<T>.error(error, stackTrace);
    }

    try {
      unawaited(
        _transport.send(frame).catchError((Object _) {
          if (identical(_pending.remove(requestId), pending)) {
            pending.fail(
              const PiNodeException(
                PiNodeErrorCode.disconnected,
                retryable: true,
              ),
            );
          }
        }),
      );
    } catch (_) {
      if (identical(_pending.remove(requestId), pending)) {
        pending.fail(
          const PiNodeException(PiNodeErrorCode.disconnected, retryable: true),
        );
      }
    }
    return completer.future;
  }

  Future<PiSessionAdminResult> _sendSessionAdminCommand(
    PiSessionAdminCommand command,
    PiSessionAdminOperation operation,
    PiProtocolSessionAdminCommandRequest Function(int requestId) buildMessage,
  ) {
    try {
      _ensureConnected();
    } catch (error, stackTrace) {
      return Future<PiSessionAdminResult>.error(error, stackTrace);
    }
    final requestId = _takeRequestId();
    final completer = Completer<PiSessionAdminResult>();
    final pending = _PendingSessionAdmin(
      command.commandId,
      command.sessionId,
      operation,
      completer,
      _resetSessionEventState,
    );
    _pending[requestId] = pending;

    PiTransportFrame frame;
    try {
      frame = _encode(buildMessage(requestId));
    } catch (error, stackTrace) {
      _pending.remove(requestId);
      return Future<PiSessionAdminResult>.error(error, stackTrace);
    }

    try {
      unawaited(
        _transport.send(frame).catchError((Object _) {
          if (identical(_pending.remove(requestId), pending)) {
            pending.fail(
              const PiNodeException(
                PiNodeErrorCode.disconnected,
                retryable: true,
              ),
            );
          }
        }),
      );
    } catch (_) {
      if (identical(_pending.remove(requestId), pending)) {
        pending.fail(
          const PiNodeException(PiNodeErrorCode.disconnected, retryable: true),
        );
      }
    }
    return completer.future;
  }

  Future<PiSessionTreeMutationResult> _sendSessionTreeMutation(
    PiSessionTreeMutationCommand command,
    PiSessionTreeMutationOperation operation,
    PiProtocolSessionTreeMutationCommandRequest Function(int requestId)
    buildMessage,
  ) {
    try {
      _ensureConnected();
    } catch (error, stackTrace) {
      return Future<PiSessionTreeMutationResult>.error(error, stackTrace);
    }
    final requestId = _takeRequestId();
    final completer = Completer<PiSessionTreeMutationResult>();
    final pending = _PendingSessionTreeMutation(
      command.commandId,
      command.sessionId,
      operation,
      completer,
      _resetSessionEventState,
    );
    _pending[requestId] = pending;

    PiTransportFrame frame;
    try {
      frame = _encode(buildMessage(requestId));
    } catch (error, stackTrace) {
      _pending.remove(requestId);
      return Future<PiSessionTreeMutationResult>.error(error, stackTrace);
    }

    try {
      unawaited(
        _transport.send(frame).catchError((Object _) {
          if (identical(_pending.remove(requestId), pending)) {
            pending.fail(
              const PiNodeException(
                PiNodeErrorCode.disconnected,
                retryable: true,
              ),
            );
          }
        }),
      );
    } catch (_) {
      if (identical(_pending.remove(requestId), pending)) {
        pending.fail(
          const PiNodeException(PiNodeErrorCode.disconnected, retryable: true),
        );
      }
    }
    return completer.future;
  }

  Future<PiCommandResult> _sendCommand(
    PiSessionCommand command,
    PiProtocolCommandRequest Function(int requestId) buildMessage,
  ) {
    try {
      _ensureConnected();
    } catch (error, stackTrace) {
      return Future<PiCommandResult>.error(error, stackTrace);
    }
    final requestId = _takeRequestId();
    final completer = Completer<PiCommandResult>();
    final pending = _PendingCommand(command.commandId, completer);
    _pending[requestId] = pending;

    PiTransportFrame frame;
    try {
      frame = _encode(buildMessage(requestId));
    } catch (error, stackTrace) {
      _pending.remove(requestId);
      return Future<PiCommandResult>.error(error, stackTrace);
    }

    try {
      unawaited(
        _transport.send(frame).catchError((Object _) {
          if (identical(_pending.remove(requestId), pending)) {
            pending.fail(
              const PiNodeException(
                PiNodeErrorCode.disconnected,
                retryable: true,
              ),
            );
          }
        }),
      );
    } catch (_) {
      if (identical(_pending.remove(requestId), pending)) {
        pending.fail(
          const PiNodeException(PiNodeErrorCode.disconnected, retryable: true),
        );
      }
    }
    return completer.future;
  }

  PiTransportFrame _encode(PiClientProtocolMessage message) {
    try {
      return PiTransportFrame(_codec.encode(message));
    } catch (_) {
      throw const PiNodeException(
        PiNodeErrorCode.malformedFrame,
        retryable: false,
      );
    }
  }

  int _takeRequestId() {
    final requestId = _nextRequestId;
    _nextRequestId += 1;
    return requestId;
  }

  void _ensureConnected() {
    if (_connection.status == PiNodeConnectionStatus.closed || _closing) {
      throw const PiNodeException(PiNodeErrorCode.closed, retryable: false);
    }
    if (_connection.status != PiNodeConnectionStatus.connected) {
      throw const PiNodeException(
        PiNodeErrorCode.disconnected,
        retryable: true,
      );
    }
  }

  void _emitConnection(PiNodeConnectionSnapshot value) {
    _connection = value;
    if (!_connectionStates.isClosed) _connectionStates.add(value);
  }

  void _failConnection(PiNodeException error, {bool closeTransport = false}) {
    if (_closing ||
        _connection.status == PiNodeConnectionStatus.closed ||
        _terminalDisconnected) {
      return;
    }
    _terminalDisconnected = true;

    final handshake = _handshakeCompleter;
    _handshakeCompleter = null;
    if (handshake != null && !handshake.isCompleted) {
      handshake.completeError(error);
    }
    final pending = _pending.values.toList(growable: false);
    _pending.clear();
    for (final operation in pending) {
      operation.fail(error);
    }
    _failAndCloseSessionStreams(error);
    _failTransfers(error);
    _emitConnection(const PiNodeConnectionSnapshot.disconnected());
    if (closeTransport) {
      scheduleMicrotask(() {
        unawaited(_transport.close());
      });
    }
  }

  Future<void> _close() async {
    if (_connection.status == PiNodeConnectionStatus.closed) return;
    _closing = true;
    _emitConnection(const PiNodeConnectionSnapshot.closing());
    const error = PiNodeException(PiNodeErrorCode.closed, retryable: false);

    final handshake = _handshakeCompleter;
    _handshakeCompleter = null;
    if (handshake != null && !handshake.isCompleted) {
      handshake.completeError(error);
    }
    final pending = _pending.values.toList(growable: false);
    _pending.clear();
    for (final operation in pending) {
      operation.fail(error);
    }
    await _closeSessionStreams();
    _failTransfers(error);
    try {
      await _transport.close();
    } catch (_) {
      // Raw transport details are intentionally not exposed by client close.
    }
    await _incomingSubscription?.cancel();
    _emitConnection(const PiNodeConnectionSnapshot.closed());
    await _connectionStates.close();
  }

  void _resetSessionEventState(PiSessionId sessionId) {
    _lastSessionSequences.remove(sessionId);
    final controller = _sessionControllers.remove(sessionId);
    if (controller != null && !controller.isClosed) {
      unawaited(controller.close());
    }
  }

  void _failAndCloseSessionStreams(PiNodeException error) {
    final controllers = _sessionControllers.values.toList(growable: false);
    _sessionControllers.clear();
    _lastSessionSequences.clear();
    for (final controller in controllers) {
      if (!controller.isClosed) {
        controller.addError(error);
        unawaited(controller.close());
      }
    }
  }

  void _failTransfers(PiNodeException error) {
    final transfers = _transfers.values.toList(growable: false);
    _transfers.clear();
    for (final transfer in transfers) {
      transfer.fail(error, notifyPeer: false);
    }
  }

  Future<void> _closeSessionStreams() async {
    final controllers = _sessionControllers.values.toList(growable: false);
    _sessionControllers.clear();
    _lastSessionSequences.clear();
    await Future.wait<void>(
      controllers
          .where((controller) => !controller.isClosed)
          .map((controller) => controller.close()),
    );
  }
}

final class _ClientTransfer
    implements PiSessionExportHandle, PiMessageContentHandle {
  _ClientTransfer({
    required PiProtocolTransferOpenMessage metadata,
    required Future<void> Function(PiClientProtocolMessage message) send,
    required void Function() onFinished,
  }) : _metadata = metadata,
       _send = send,
       _onFinished = onFinished {
    _bytes = _consume();
  }

  final PiProtocolTransferOpenMessage _metadata;
  final Future<void> Function(PiClientProtocolMessage message) _send;
  final void Function() _onFinished;
  late final Stream<Uint8List> _bytes;
  final Completer<void> _done = Completer<void>();
  final StreamController<_TransferSignal> _signals =
      StreamController<_TransferSignal>(sync: true);
  var _nextSequence = 1;
  var _receivedBytes = 0;
  var _creditBytes = 0;
  var _terminal = false;
  var _cancelSent = false;

  @override
  String get fileName => _metadata.fileName;

  @override
  String get contentType => _metadata.contentType;

  @override
  int get totalBytes => _metadata.totalBytes;

  @override
  List<int> get sha256 => List<int>.unmodifiable(_metadata.sha256);

  @override
  PiMessageContentBinding get binding {
    final value = _metadata.messageContentBinding;
    if (value == null) {
      throw StateError('Export transfers do not expose a message binding.');
    }
    return _contentBindingFromProtocol(value);
  }

  @override
  PiMessageContentReference get reference {
    if (_metadata.purpose != PiProtocolTransferPurpose.messageContent) {
      throw StateError('Export transfers do not expose a message reference.');
    }
    return PiMessageContentReference(
      contentId: binding.contentId,
      mimeType: _metadata.contentType,
      displayName: _metadata.fileName,
      totalBytes: _metadata.totalBytes,
      sha256: Uint8List.fromList(_metadata.sha256),
    );
  }

  @override
  Stream<Uint8List> get bytes => _bytes;

  @override
  Future<void> get done => _done.future;

  void acceptChunk(PiProtocolTransferChunkMessage chunk) {
    if (_terminal) return;
    final dataLength = chunk.data.length;
    if (chunk.sequence != _nextSequence ||
        chunk.offset != _receivedBytes ||
        dataLength > _metadata.chunkBytes ||
        dataLength > _creditBytes ||
        _receivedBytes + dataLength > _metadata.totalBytes) {
      fail(
        const PiNodeException(PiNodeErrorCode.dataLoss, retryable: false),
        notifyPeer: true,
      );
      return;
    }
    _nextSequence += 1;
    _receivedBytes += dataLength;
    _creditBytes -= dataLength;
    _signals.add(_TransferChunkSignal(chunk));
  }

  void acceptComplete(PiProtocolTransferCompleteMessage complete) {
    if (_terminal) return;
    if (complete.totalBytes != _metadata.totalBytes ||
        !_sameBytes(complete.sha256, _metadata.sha256)) {
      fail(
        const PiNodeException(PiNodeErrorCode.dataLoss, retryable: false),
        notifyPeer: true,
      );
      return;
    }
    _signals.add(_TransferCompleteSignal(complete));
  }

  void acceptAbort(PiProtocolTransferAbortMessage abort) {
    if (_terminal) return;
    fail(PiNodeException.fromProtocolFailure(abort.failure), notifyPeer: false);
  }

  @override
  Future<void> cancel() async {
    if (_terminal) return;
    if (!_cancelSent) {
      _cancelSent = true;
      try {
        await _send(
          PiProtocolCancelTransferMessage(transferId: _metadata.transferId),
        );
      } catch (_) {
        // The local cancellation outcome remains definitive even after a disconnect.
      }
    }
    fail(
      const PiNodeException(PiNodeErrorCode.cancelled, retryable: false),
      notifyPeer: false,
    );
  }

  void fail(PiNodeException error, {required bool notifyPeer}) {
    if (_terminal) return;
    if (notifyPeer && !_cancelSent) {
      _cancelSent = true;
      unawaited(
        _send(
          PiProtocolCancelTransferMessage(transferId: _metadata.transferId),
        ).catchError((Object _) {}),
      );
    }
    _terminal = true;
    _onFinished();
    if (!_done.isCompleted) _done.completeError(error);
    if (!_signals.isClosed) {
      _signals.addError(error);
      unawaited(_signals.close());
    }
  }

  Stream<Uint8List> _consume() async* {
    final metadata = _metadata;
    final digestSink = _DigestSink();
    final digestInput = crypto.sha256.startChunkedConversion(digestSink);
    var committedBytes = 0;
    var consumedSequence = 0;
    try {
      await _grantCredit(_minimum(metadata.chunkBytes, metadata.totalBytes));
      await for (final signal in _signals.stream) {
        switch (signal) {
          case _TransferChunkSignal(:final chunk):
            digestInput.add(chunk.data);
            yield Uint8List.fromList(chunk.data);
            committedBytes += chunk.data.length;
            consumedSequence = chunk.sequence;
            await _send(
              PiProtocolTransferAckMessage(
                transferId: metadata.transferId,
                acknowledgedSequence: consumedSequence,
                committedBytes: committedBytes,
              ),
            );
            if (committedBytes < metadata.totalBytes) {
              await _grantCredit(
                _minimum(
                  metadata.chunkBytes,
                  metadata.totalBytes - committedBytes,
                ),
              );
            }
          case _TransferCompleteSignal(:final complete):
            digestInput.close();
            final digest = digestSink.value;
            if (committedBytes != metadata.totalBytes ||
                complete.totalBytes != metadata.totalBytes ||
                digest == null ||
                !_sameBytes(digest.bytes, metadata.sha256)) {
              throw const PiNodeException(
                PiNodeErrorCode.dataLoss,
                retryable: false,
              );
            }
            _terminal = true;
            _onFinished();
            if (!_done.isCompleted) _done.complete();
            unawaited(_signals.close());
            return;
        }
      }
    } catch (error, stackTrace) {
      final safeError = error is PiNodeException
          ? error
          : const PiNodeException(
              PiNodeErrorCode.disconnected,
              retryable: true,
            );
      fail(safeError, notifyPeer: true);
      Error.throwWithStackTrace(safeError, stackTrace);
    } finally {
      if (!_terminal) await cancel();
    }
  }

  Future<void> _grantCredit(int bytes) async {
    if (_terminal) {
      throw const PiNodeException(PiNodeErrorCode.cancelled, retryable: false);
    }
    _creditBytes += bytes;
    await _send(
      PiProtocolTransferWindowUpdate(
        transferId: _metadata.transferId,
        creditBytes: bytes,
      ),
    );
  }
}

sealed class _TransferSignal {
  const _TransferSignal();
}

final class _TransferChunkSignal extends _TransferSignal {
  const _TransferChunkSignal(this.chunk);

  final PiProtocolTransferChunkMessage chunk;
}

final class _TransferCompleteSignal extends _TransferSignal {
  const _TransferCompleteSignal(this.complete);

  final PiProtocolTransferCompleteMessage complete;
}

final class _DigestSink implements Sink<crypto.Digest> {
  crypto.Digest? value;

  @override
  void add(crypto.Digest data) => value = data;

  @override
  void close() {}
}

int _minimum(int left, int right) => left < right ? left : right;

bool _sameBytes(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  var difference = 0;
  for (var index = 0; index < left.length; index += 1) {
    difference |= left[index] ^ right[index];
  }
  return difference == 0;
}

abstract interface class _PendingOperation {
  void complete(PiProtocolResponseMessage message);

  void fail(PiNodeException error);
}

final class _PendingRequest<T> implements _PendingOperation {
  const _PendingRequest(this._completer, this._parse);

  final Completer<T> _completer;
  final T Function(PiProtocolResponseMessage message) _parse;

  @override
  void complete(PiProtocolResponseMessage message) {
    if (_completer.isCompleted) return;
    try {
      _completer.complete(_parse(message));
    } catch (error, stackTrace) {
      _completer.completeError(error, stackTrace);
    }
  }

  @override
  void fail(PiNodeException error) {
    if (!_completer.isCompleted) _completer.completeError(error);
  }
}

final class _PendingSessionAdmin implements _PendingOperation {
  const _PendingSessionAdmin(
    this._commandId,
    this._sessionId,
    this._operation,
    this._completer,
    this._onSettled,
  );

  final PiCommandId _commandId;
  final PiSessionId _sessionId;
  final PiSessionAdminOperation _operation;
  final Completer<PiSessionAdminResult> _completer;
  final void Function(PiSessionId sessionId) _onSettled;

  @override
  void complete(PiProtocolResponseMessage message) {
    if (_completer.isCompleted) return;
    _onSettled(_sessionId);
    if (message is PiProtocolCommandRejectedMessage &&
        message.commandId == _commandId.value) {
      _completer.complete(
        PiSessionAdminRejected(
          commandId: _commandId,
          operation: _operation,
          error: PiNodeException.fromProtocolFailure(message.failure),
        ),
      );
      return;
    }
    if (message is! PiProtocolSessionAdminOutcomeMessage ||
        message.commandId != _commandId.value ||
        _sessionAdminOperationFromProtocol(message.operation) != _operation) {
      _completer.complete(
        PiSessionAdminUncertain(
          commandId: _commandId,
          operation: _operation,
          error: const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: true,
          ),
        ),
      );
      return;
    }
    final result = switch (message.outcome) {
      PiProtocolSessionAdminUpdated(:final session) => PiSessionAdminUpdated(
        commandId: _commandId,
        operation: _operation,
        session: _sessionSummaryFromProtocol(session),
      ),
      PiProtocolSessionAdminDeleted(
        :final sessionId,
        :final reparentedChildCount,
      ) =>
        PiSessionAdminDeleted(
          commandId: _commandId,
          sessionId: PiSessionId(sessionId),
          reparentedChildCount: reparentedChildCount,
        ),
      PiProtocolSessionAdminFailed(:final failure) => PiSessionAdminRejected(
        commandId: _commandId,
        operation: _operation,
        error: PiNodeException.fromProtocolFailure(failure),
      ),
    };
    _completer.complete(result);
  }

  @override
  void fail(PiNodeException error) {
    if (_completer.isCompleted) return;
    _onSettled(_sessionId);
    _completer.complete(
      PiSessionAdminUncertain(
        commandId: _commandId,
        operation: _operation,
        error: error,
      ),
    );
  }
}

final class _PendingSessionTreeMutation implements _PendingOperation {
  const _PendingSessionTreeMutation(
    this._commandId,
    this._sessionId,
    this._operation,
    this._completer,
    this._onSettled,
  );

  final PiCommandId _commandId;
  final PiSessionId _sessionId;
  final PiSessionTreeMutationOperation _operation;
  final Completer<PiSessionTreeMutationResult> _completer;
  final void Function(PiSessionId sessionId) _onSettled;

  @override
  void complete(PiProtocolResponseMessage message) {
    if (_completer.isCompleted) return;
    _onSettled(_sessionId);
    if (message is PiProtocolCommandRejectedMessage &&
        message.commandId == _commandId.value) {
      _completer.complete(
        PiSessionTreeMutationRejected(
          commandId: _commandId,
          operation: _operation,
          error: PiNodeException.fromProtocolFailure(message.failure),
        ),
      );
      return;
    }
    if (message is! PiProtocolSessionTreeMutationOutcomeMessage ||
        message.commandId != _commandId.value ||
        _sessionTreeMutationOperationFromProtocol(message.operation) !=
            _operation) {
      _completer.complete(
        PiSessionTreeMutationUncertain(
          commandId: _commandId,
          operation: _operation,
          error: const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: true,
          ),
        ),
      );
      return;
    }
    final result = switch (message.outcome) {
      PiProtocolSessionTreeMutationUpdated(
        :final session,
        :final tree,
        :final editorText,
      ) =>
        PiSessionTreeMutationUpdated(
          commandId: _commandId,
          operation: _operation,
          session: _sessionDetailFromProtocol(session),
          tree: _sessionTreeFromProtocol(tree),
          editorText: editorText,
        ),
      PiProtocolSessionTreeMutationFailed(:final failure) =>
        PiSessionTreeMutationRejected(
          commandId: _commandId,
          operation: _operation,
          error: PiNodeException.fromProtocolFailure(failure),
        ),
    };
    _completer.complete(result);
  }

  @override
  void fail(PiNodeException error) {
    if (_completer.isCompleted) return;
    _onSettled(_sessionId);
    _completer.complete(
      PiSessionTreeMutationUncertain(
        commandId: _commandId,
        operation: _operation,
        error: error,
      ),
    );
  }
}

final class _PendingCommand implements _PendingOperation {
  const _PendingCommand(this._commandId, this._completer);

  final PiCommandId _commandId;
  final Completer<PiCommandResult> _completer;

  @override
  void complete(PiProtocolResponseMessage message) {
    if (_completer.isCompleted) return;
    if (message is! PiProtocolCommandResponseMessage ||
        message.commandId != _commandId.value) {
      _completer.complete(
        PiCommandUncertain(
          _commandId,
          const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: true,
          ),
        ),
      );
      return;
    }
    final result = switch (message) {
      PiProtocolCommandAcceptedMessage() => PiCommandAccepted(_commandId),
      PiProtocolCommandRejectedMessage(:final failure) => PiCommandRejected(
        _commandId,
        PiNodeException.fromProtocolFailure(failure),
      ),
      PiProtocolCommandUncertainMessage(:final failure) => PiCommandUncertain(
        _commandId,
        PiNodeException.fromProtocolFailure(failure),
      ),
      PiProtocolSessionAdminOutcomeMessage() ||
      PiProtocolSessionTreeMutationOutcomeMessage() => PiCommandUncertain(
        _commandId,
        const PiNodeException(
          PiNodeErrorCode.unexpectedResponse,
          retryable: true,
        ),
      ),
    };
    _completer.complete(result);
  }

  @override
  void fail(PiNodeException error) {
    if (!_completer.isCompleted) {
      _completer.complete(PiCommandUncertain(_commandId, error));
    }
  }
}

PiProject _projectFromProtocol(PiProtocolProjectSnapshot value) => PiProject(
  identity: PiProjectIdentity(
    projectId: PiProjectId(value.identity.projectId),
    canonicalWorkingDirectory: value.identity.canonicalWorkingDirectory,
    isGitRepository: value.identity.isGitRepository,
    gitRoot: value.identity.gitRoot,
    mainWorktreeRoot: value.identity.mainWorktreeRoot,
    branch: value.identity.branch,
    isLinkedWorktree: value.identity.isLinkedWorktree,
    isDetachedHead: value.identity.isDetachedHead,
    worktreeId: PiWorktreeId(value.identity.worktreeId),
    mainProjectId: PiMainProjectId(value.identity.mainProjectId),
  ),
  trust: PiProjectTrustSnapshot(
    status: switch (value.trust.status) {
      PiProtocolProjectTrustStatus.notRequired =>
        PiProjectTrustStatus.notRequired,
      PiProtocolProjectTrustStatus.trusted => PiProjectTrustStatus.trusted,
      PiProtocolProjectTrustStatus.approvalRequired =>
        PiProjectTrustStatus.approvalRequired,
      PiProtocolProjectTrustStatus.denied => PiProjectTrustStatus.denied,
    },
    reasons: value.trust.reasons.map(
      (reason) => switch (reason) {
        PiProtocolProjectTrustReason.piSettings =>
          PiProjectTrustReason.piSettings,
        PiProtocolProjectTrustReason.piExtensions =>
          PiProjectTrustReason.piExtensions,
        PiProtocolProjectTrustReason.piSkills => PiProjectTrustReason.piSkills,
        PiProtocolProjectTrustReason.piPrompts =>
          PiProjectTrustReason.piPrompts,
        PiProtocolProjectTrustReason.piThemes => PiProjectTrustReason.piThemes,
        PiProtocolProjectTrustReason.piSystemPrompt =>
          PiProjectTrustReason.piSystemPrompt,
        PiProtocolProjectTrustReason.agentSkills =>
          PiProjectTrustReason.agentSkills,
        PiProtocolProjectTrustReason.savedApproval =>
          PiProjectTrustReason.savedApproval,
        PiProtocolProjectTrustReason.savedDenial =>
          PiProjectTrustReason.savedDenial,
      },
    ),
    revision: PiProjectTrustRevision(value.trust.revision),
  ),
);

PiDirectoryListing _directoryFromProtocol(PiProtocolDirectoryListing value) =>
    PiDirectoryListing(
      canonicalDirectory: value.canonicalDirectory,
      parentDirectory: value.parentDirectory,
      children: value.children.map(
        (child) => PiDirectoryEntry(
          name: child.name,
          canonicalPath: child.canonicalPath,
          isSymbolicLink: child.isSymbolicLink,
        ),
      ),
      truncated: value.truncated,
    );

PiSessionSummary _sessionSummaryFromProtocol(PiProtocolSessionSummary value) =>
    PiSessionSummary(
      id: PiSessionId(value.id),
      title: value.title,
      workingDirectory: value.workingDirectory,
      createdAt: value.createdAt,
      updatedAt: value.updatedAt,
      isRunning: value.isRunning,
      hasUnread: value.hasUnread,
      adminRevision: PiSessionAdminRevision(value.adminRevision),
      hasCustomName: value.hasCustomName,
      parentSessionId: value.parentSessionId == null
          ? null
          : PiSessionId(value.parentSessionId!),
    );

PiSessionDetail _sessionDetailFromProtocol(PiProtocolSessionDetail value) =>
    PiSessionDetail(
      summary: _sessionSummaryFromProtocol(value.summary),
      conversation: _conversationSnapshotFromProtocol(value.conversation),
    );

PiConversationSnapshot _conversationSnapshotFromProtocol(
  PiProtocolConversationSnapshot value,
) => PiConversationSnapshot(
  sessionId: PiSessionId(value.sessionId),
  entries: value.entries.map(_conversationEntryFromProtocol),
  lastEventSequence: value.lastEventSequence,
);

PiConversationPage _conversationPageFromProtocol(
  PiProtocolConversationPage value,
) => PiConversationPage(
  sessionId: PiSessionId(value.sessionId),
  entries: value.entries.map(_conversationEntryFromProtocol),
  nextCursor: value.nextCursor == null
      ? null
      : PiSessionHistoryCursor(value.nextCursor!),
  hasMore: value.hasMore,
  activeBranchRevision: PiSessionBranchRevision(value.activeBranchRevision),
  treeRevision: PiSessionTreeRevision(value.treeRevision),
  lastEventSequence: value.lastEventSequence,
);

PiConversationEntry _conversationEntryFromProtocol(
  PiProtocolConversationEntry value,
) {
  final identity = PiConversationEntryIdentity(
    entryId: value.entryId,
    scope: switch (value.scope) {
      PiProtocolConversationIdentityScope.persistent =>
        PiConversationIdentityScope.persistent,
      PiProtocolConversationIdentityScope.runtime =>
        PiConversationIdentityScope.runtime,
    },
    originCommandId: value.originCommandId == null
        ? null
        : PiCommandId(value.originCommandId!),
  );
  final parts = value.parts.map(_conversationPartFromProtocol);
  final activities = value.toolActivities.map(_toolActivityFromProtocol);
  final metrics = value.metrics == null
      ? null
      : _conversationMetricsFromProtocol(value.metrics!);
  return switch (value.type) {
    PiProtocolConversationEntryType.user => PiUserConversationEntry(
      identity: identity,
      revision: value.revision,
      createdAt: value.createdAt,
      finalized: value.finalized,
      parts: parts,
      toolActivities: activities,
      metrics: metrics,
    ),
    PiProtocolConversationEntryType.assistant => PiAssistantConversationEntry(
      identity: identity,
      revision: value.revision,
      createdAt: value.createdAt,
      finalized: value.finalized,
      parts: parts,
      toolActivities: activities,
      metrics: metrics,
      provider: value.provider!,
      model: value.model!,
      stopReason: value.stopReason!,
      safeErrorMessage: value.safeErrorMessage,
    ),
    PiProtocolConversationEntryType.toolResult => PiToolResultConversationEntry(
      identity: identity,
      revision: value.revision,
      createdAt: value.createdAt,
      finalized: value.finalized,
      parts: parts,
      toolActivities: activities,
      metrics: metrics,
      toolCallId: value.toolCallId!,
      toolName: value.toolName!,
      isError: value.isError!,
      safeDetails: _safeValueFromProtocol(value.safeDetails!),
    ),
    PiProtocolConversationEntryType.bash => PiBashConversationEntry(
      identity: identity,
      revision: value.revision,
      createdAt: value.createdAt,
      finalized: value.finalized,
      parts: parts,
      toolActivities: activities,
      metrics: metrics,
      command: value.command!,
      exitCode: value.exitCode,
      cancelled: value.cancelled!,
      truncated: value.truncated!,
      excludedFromContext: value.excludedFromContext!,
    ),
    PiProtocolConversationEntryType.custom => PiCustomConversationEntry(
      identity: identity,
      revision: value.revision,
      createdAt: value.createdAt,
      finalized: value.finalized,
      parts: parts,
      toolActivities: activities,
      metrics: metrics,
      customType: value.customType!,
      display: value.display!,
      safeDetails: _safeValueFromProtocol(value.safeDetails!),
    ),
    PiProtocolConversationEntryType.compaction => PiCompactionConversationEntry(
      identity: identity,
      revision: value.revision,
      createdAt: value.createdAt,
      finalized: value.finalized,
      parts: parts,
      toolActivities: activities,
      metrics: metrics,
      firstKeptEntryId: value.firstKeptEntryId!,
      tokensBefore: value.tokensBefore!,
      fromHook: value.fromHook!,
      safeDetails: _safeValueFromProtocol(value.safeDetails!),
    ),
    PiProtocolConversationEntryType.branchSummary =>
      PiBranchSummaryConversationEntry(
        identity: identity,
        revision: value.revision,
        createdAt: value.createdAt,
        finalized: value.finalized,
        parts: parts,
        toolActivities: activities,
        metrics: metrics,
        fromEntryId: value.fromEntryId!,
        fromHook: value.fromHook!,
        safeDetails: _safeValueFromProtocol(value.safeDetails!),
      ),
    PiProtocolConversationEntryType.marker => PiMarkerConversationEntry(
      identity: identity,
      revision: value.revision,
      createdAt: value.createdAt,
      finalized: value.finalized,
      parts: parts,
      toolActivities: activities,
      metrics: metrics,
      markerKind: switch (value.markerKind!) {
        PiProtocolConversationMarkerKind.thinkingLevel =>
          PiConversationMarkerKind.thinkingLevel,
        PiProtocolConversationMarkerKind.modelChange =>
          PiConversationMarkerKind.modelChange,
        PiProtocolConversationMarkerKind.label =>
          PiConversationMarkerKind.label,
        PiProtocolConversationMarkerKind.sessionInfo =>
          PiConversationMarkerKind.sessionInfo,
      },
      targetEntryId: value.targetEntryId,
      label: value.label,
      provider: value.provider,
      model: value.model,
      thinkingLevel: value.thinkingLevel,
    ),
    PiProtocolConversationEntryType.unknown => PiUnknownConversationEntry(
      identity: identity,
      revision: value.revision,
      createdAt: value.createdAt,
      finalized: value.finalized,
      parts: parts,
      toolActivities: activities,
      metrics: metrics,
      sourceType: value.sourceType!,
    ),
  };
}

PiConversationPart _conversationPartFromProtocol(
  PiProtocolConversationPart value,
) => switch (value.type) {
  PiProtocolConversationPartType.text => PiTextConversationPart(
    partId: value.partId,
    revision: value.revision,
    text: value.text,
    contentReference: value.contentReference == null
        ? null
        : _contentReferenceFromProtocol(value.contentReference!),
  ),
  PiProtocolConversationPartType.thinking => PiThinkingConversationPart(
    partId: value.partId,
    revision: value.revision,
    visibility: switch (value.thinkingVisibility!) {
      PiProtocolThinkingVisibility.visible => PiThinkingVisibility.visible,
      PiProtocolThinkingVisibility.redacted => PiThinkingVisibility.redacted,
      PiProtocolThinkingVisibility.deferred => PiThinkingVisibility.deferred,
    },
    text: value.text,
    contentReference: value.contentReference == null
        ? null
        : _contentReferenceFromProtocol(value.contentReference!),
  ),
  PiProtocolConversationPartType.image => PiImageConversationPart(
    partId: value.partId,
    revision: value.revision,
    contentReference: _contentReferenceFromProtocol(value.contentReference!),
  ),
  PiProtocolConversationPartType.toolCall => PiToolCallConversationPart(
    partId: value.partId,
    revision: value.revision,
    toolCallId: value.toolCallId!,
    toolName: value.toolName!,
    safeArguments: _safeValueFromProtocol(value.safeArguments!),
  ),
  PiProtocolConversationPartType.unsupported => PiUnsupportedConversationPart(
    partId: value.partId,
    revision: value.revision,
    sourceType: value.sourceType!,
  ),
};

PiMessageContentReference _contentReferenceFromProtocol(
  PiProtocolMessageContentReference value,
) => PiMessageContentReference(
  contentId: value.contentId,
  mimeType: value.mimeType,
  displayName: value.displayName,
  totalBytes: value.totalBytes,
  sha256: value.sha256,
);

PiMessageContentBinding _contentBindingFromProtocol(
  PiProtocolMessageContentBinding value,
) => PiMessageContentBinding(
  sessionId: PiSessionId(value.sessionId),
  entryId: value.entryId,
  partId: value.partId,
  entryRevision: value.entryRevision,
  partRevision: value.partRevision,
  contentId: value.contentId,
);

PiProtocolMessageContentBinding _protocolContentBinding(
  PiMessageContentBinding value,
) => PiProtocolMessageContentBinding(
  sessionId: value.sessionId.value,
  entryId: value.entryId,
  partId: value.partId,
  entryRevision: value.entryRevision,
  partRevision: value.partRevision,
  contentId: value.contentId,
);

bool _sameContentBinding(
  PiProtocolMessageContentBinding left,
  PiMessageContentBinding right,
) =>
    left.sessionId == right.sessionId.value &&
    left.entryId == right.entryId &&
    left.partId == right.partId &&
    left.entryRevision == right.entryRevision &&
    left.partRevision == right.partRevision &&
    left.contentId == right.contentId;

PiSafeValue _safeValueFromProtocol(PiProtocolSafeValue value) =>
    switch (value) {
      PiProtocolSafeNull() => const PiSafeNull(),
      PiProtocolSafeRedacted() => const PiSafeRedacted(),
      PiProtocolSafeBool(:final value) => PiSafeBool(value),
      PiProtocolSafeInt(:final value) => PiSafeInt(value),
      PiProtocolSafeDouble(:final value) => PiSafeDouble(value),
      PiProtocolSafeString(:final value) => PiSafeString(value),
      PiProtocolSafeList(:final values) => PiSafeList(
        values.map(_safeValueFromProtocol),
      ),
      PiProtocolSafeObject(:final fields) => PiSafeObject(
        fields.map(
          (field) => PiSafeObjectField(
            key: field.key,
            value: _safeValueFromProtocol(field.value),
          ),
        ),
      ),
    };

PiToolActivity _toolActivityFromProtocol(
  PiProtocolToolActivity value,
) => PiToolActivity(
  activityId: value.activityId,
  toolCallId: value.toolCallId,
  toolName: value.toolName,
  sourceOrdinal: value.sourceOrdinal,
  revision: value.revision,
  status: switch (value.status) {
    PiProtocolToolActivityStatus.pending => PiToolActivityStatus.pending,
    PiProtocolToolActivityStatus.running => PiToolActivityStatus.running,
    PiProtocolToolActivityStatus.succeeded => PiToolActivityStatus.succeeded,
    PiProtocolToolActivityStatus.failed => PiToolActivityStatus.failed,
    PiProtocolToolActivityStatus.cancelled => PiToolActivityStatus.cancelled,
  },
  progressBasisPoints: value.progressBasisPoints,
  safeDetails: _safeValueFromProtocol(value.safeDetails),
);

PiConversationMetrics _conversationMetricsFromProtocol(
  PiProtocolConversationMetrics value,
) => PiConversationMetrics(
  usage: PiUsageMetrics(
    inputTokens: value.usage.inputTokens,
    outputTokens: value.usage.outputTokens,
    cacheReadTokens: value.usage.cacheReadTokens,
    cacheWriteTokens: value.usage.cacheWriteTokens,
    totalTokens: value.usage.totalTokens,
  ),
  cost: PiMoneyAmount(
    currencyCode: value.cost.currencyCode,
    decimalAmount: value.cost.decimalAmount,
  ),
  context: value.context == null
      ? null
      : PiContextMetrics(
          tokens: value.context!.tokens,
          contextWindow: value.context!.contextWindow,
          percentDecimal: value.context!.percentDecimal,
        ),
);

PiMessage _messageFromProtocol(PiProtocolMessageSnapshot value) => PiMessage(
  id: PiMessageId(value.id),
  role: switch (value.role) {
    PiProtocolMessageRole.user => PiMessageRole.user,
    PiProtocolMessageRole.assistant => PiMessageRole.assistant,
    PiProtocolMessageRole.tool => PiMessageRole.tool,
    PiProtocolMessageRole.system => PiMessageRole.system,
  },
  text: value.text,
  createdAt: value.createdAt,
  isStreaming: value.isStreaming,
);

PiSessionStats _statsFromProtocol(PiProtocolSessionStatsSnapshot value) =>
    PiSessionStats(
      projection: PiSessionSafeProjection(
        sessionFileName: value.projection.sessionFileName,
        sessionId: PiSessionId(value.projection.sessionId),
        projectId: PiProjectId(value.projection.projectId),
        canonicalProjectDirectory: value.projection.canonicalProjectDirectory,
        worktreeId: PiWorktreeId(value.projection.worktreeId),
        mainProjectId: PiMainProjectId(value.projection.mainProjectId),
        branch: value.projection.branch,
        isLinkedWorktree: value.projection.isLinkedWorktree,
        isDetachedHead: value.projection.isDetachedHead,
      ),
      userMessages: value.userMessages,
      assistantMessages: value.assistantMessages,
      toolCalls: value.toolCalls,
      toolResults: value.toolResults,
      totalMessages: value.totalMessages,
      inputTokens: value.inputTokens,
      outputTokens: value.outputTokens,
      cacheReadTokens: value.cacheReadTokens,
      cacheWriteTokens: value.cacheWriteTokens,
      totalTokens: value.totalTokens,
      cost: value.cost,
      contextTokens: value.contextTokens,
      contextWindow: value.contextWindow,
      contextPercent: value.contextPercent,
      activeTime: Duration(milliseconds: value.activeTimeMillis),
    );

PiSessionTree _sessionTreeFromProtocol(
  PiProtocolSessionTreeSnapshot value,
) => PiSessionTree(
  sessionId: PiSessionId(value.sessionId),
  nodes: value.nodes.map(
    (node) => PiSessionTreeNode(
      id: PiSessionTreeEntryId(node.entryId),
      parentId: node.parentEntryId == null
          ? null
          : PiSessionTreeEntryId(node.parentEntryId!),
      kind: switch (node.kind) {
        PiProtocolSessionTreeEntryKind.userMessage =>
          PiSessionTreeEntryKind.userMessage,
        PiProtocolSessionTreeEntryKind.assistantMessage =>
          PiSessionTreeEntryKind.assistantMessage,
        PiProtocolSessionTreeEntryKind.toolMessage =>
          PiSessionTreeEntryKind.toolMessage,
        PiProtocolSessionTreeEntryKind.customMessage =>
          PiSessionTreeEntryKind.customMessage,
        PiProtocolSessionTreeEntryKind.thinkingLevel =>
          PiSessionTreeEntryKind.thinkingLevel,
        PiProtocolSessionTreeEntryKind.modelChange =>
          PiSessionTreeEntryKind.modelChange,
        PiProtocolSessionTreeEntryKind.compaction =>
          PiSessionTreeEntryKind.compaction,
        PiProtocolSessionTreeEntryKind.branchSummary =>
          PiSessionTreeEntryKind.branchSummary,
        PiProtocolSessionTreeEntryKind.custom => PiSessionTreeEntryKind.custom,
        PiProtocolSessionTreeEntryKind.label => PiSessionTreeEntryKind.label,
        PiProtocolSessionTreeEntryKind.sessionInfo =>
          PiSessionTreeEntryKind.sessionInfo,
      },
      text: node.text,
      createdAt: node.createdAt,
      label: node.label,
      depth: node.depth,
      isOnActivePath: node.isOnActivePath,
      hasChildren: node.hasChildren,
      canEditFromHere: node.canEditFromHere,
      canFork: node.canFork,
    ),
  ),
  activePathEntryIds: value.activePathEntryIds.map(PiSessionTreeEntryId.new),
  activeLeafEntryId: value.activeLeafEntryId == null
      ? null
      : PiSessionTreeEntryId(value.activeLeafEntryId!),
  canCloneActiveBranch: value.canCloneActiveBranch,
  adminRevision: PiSessionAdminRevision(value.adminRevision),
);

PiSessionTreeMutationOperation _sessionTreeMutationOperationFromProtocol(
  PiProtocolSessionTreeMutationOperation value,
) => switch (value) {
  PiProtocolSessionTreeMutationOperation.navigate =>
    PiSessionTreeMutationOperation.navigate,
  PiProtocolSessionTreeMutationOperation.fork =>
    PiSessionTreeMutationOperation.fork,
  PiProtocolSessionTreeMutationOperation.clone =>
    PiSessionTreeMutationOperation.clone,
};

PiSessionAdminOperation _sessionAdminOperationFromProtocol(
  PiProtocolSessionAdminOperation value,
) => switch (value) {
  PiProtocolSessionAdminOperation.rename => PiSessionAdminOperation.rename,
  PiProtocolSessionAdminOperation.clearName =>
    PiSessionAdminOperation.clearName,
  PiProtocolSessionAdminOperation.autoName => PiSessionAdminOperation.autoName,
  PiProtocolSessionAdminOperation.delete => PiSessionAdminOperation.delete,
};

PiSessionEvent _sessionEventFromProtocol(
  PiSessionId sessionId,
  PiProtocolSessionEventMessage message,
) => switch (message.event) {
  PiProtocolMessageAddedEvent(message: final addedMessage) =>
    PiSessionMessageAddedEvent(
      sessionId: sessionId,
      sequence: message.sequence,
      message: _messageFromProtocol(addedMessage),
    ),
  PiProtocolMessageDeltaEvent(:final messageId, :final delta) =>
    PiSessionMessageDeltaEvent(
      sessionId: sessionId,
      sequence: message.sequence,
      messageId: PiMessageId(messageId),
      delta: delta,
    ),
  PiProtocolConversationEntryUpsertEvent(
    :final entry,
    :final expectedPreviousRevision,
  ) =>
    PiSessionEntryUpsertEvent(
      sessionId: sessionId,
      sequence: message.sequence,
      entry: _conversationEntryFromProtocol(entry),
      expectedPreviousRevision: expectedPreviousRevision,
    ),
  PiProtocolConversationPartDeltaEvent(
    :final entryId,
    :final expectedEntryRevision,
    :final resultingEntryRevision,
    :final partId,
    :final expectedPartRevision,
    :final resultingPartRevision,
    :final textDelta,
  ) =>
    PiSessionPartDeltaEvent(
      sessionId: sessionId,
      sequence: message.sequence,
      entryId: entryId,
      expectedEntryRevision: expectedEntryRevision,
      resultingEntryRevision: resultingEntryRevision,
      partId: partId,
      expectedPartRevision: expectedPartRevision,
      resultingPartRevision: resultingPartRevision,
      textDelta: textDelta,
    ),
  PiProtocolConversationEntryFinalizedEvent(
    :final entry,
    :final expectedPreviousRevision,
  ) =>
    PiSessionEntryFinalizedEvent(
      sessionId: sessionId,
      sequence: message.sequence,
      entry: _conversationEntryFromProtocol(entry),
      expectedPreviousRevision: expectedPreviousRevision,
    ),
  PiProtocolConversationToolActivityEvent(
    :final entryId,
    :final expectedEntryRevision,
    :final resultingEntryRevision,
    :final activity,
  ) =>
    PiSessionToolActivityEvent(
      sessionId: sessionId,
      sequence: message.sequence,
      entryId: entryId,
      expectedEntryRevision: expectedEntryRevision,
      resultingEntryRevision: resultingEntryRevision,
      activity: _toolActivityFromProtocol(activity),
    ),
  PiProtocolConversationMetricsEvent(
    :final entryId,
    :final expectedEntryRevision,
    :final resultingEntryRevision,
    :final metrics,
  ) =>
    PiSessionMetricsEvent(
      sessionId: sessionId,
      sequence: message.sequence,
      entryId: entryId,
      expectedEntryRevision: expectedEntryRevision,
      resultingEntryRevision: resultingEntryRevision,
      metrics: _conversationMetricsFromProtocol(metrics),
    ),
  PiProtocolSessionRunningChangedEvent(:final isRunning) =>
    PiSessionRunningChangedEvent(
      sessionId: sessionId,
      sequence: message.sequence,
      isRunning: isRunning,
    ),
  PiProtocolCommandCompletedEvent(:final commandId, :final succeeded) =>
    PiSessionCommandCompletedEvent(
      sessionId: sessionId,
      sequence: message.sequence,
      commandId: PiCommandId(commandId),
      succeeded: succeeded,
    ),
};
