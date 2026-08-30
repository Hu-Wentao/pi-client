import 'dart:async';

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
      PiProtocolSessionResponse(:final session) => _sessionDetailFromProtocol(
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
            _sessionDetailFromProtocol(session),
          PiProtocolRequestRejectedMessage(:final failure) =>
            throw PiNodeException.fromProtocolFailure(failure),
          _ => throw const PiNodeException(
            PiNodeErrorCode.unexpectedResponse,
            retryable: false,
          ),
        },
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
    try {
      await _transport.close();
    } catch (_) {
      // Raw transport details are intentionally not exposed by client close.
    }
    await _incomingSubscription?.cancel();
    _emitConnection(const PiNodeConnectionSnapshot.closed());
    await _connectionStates.close();
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
    );

PiSessionDetail _sessionDetailFromProtocol(PiProtocolSessionDetail value) =>
    PiSessionDetail(
      summary: _sessionSummaryFromProtocol(value.summary),
      messages: value.messages.map(_messageFromProtocol),
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
