part of 'workspace.dart';

class WorkspaceViewModel
    extends FrBlocViewModel<WorkspaceEvent, WorkspaceModel> {
  WorkspaceViewModel({
    required PiWebApi gateway,
    required String initialBaseUrl,
    this.reconnectDelay = const Duration(seconds: 2),
  }) : _gateway = gateway,
       super(WorkspaceModel(baseUrl: initialBaseUrl)) {
    on<WorkspaceStarted>(_onStarted);
    on<WorkspaceConnectionApplied>(_onConnectionApplied);
    on<WorkspaceSessionsRefreshed>(_onSessionsRefreshed);
    on<WorkspaceSessionSelected>(_onSessionSelected);
    on<WorkspaceNewSessionRequested>(_onNewSessionRequested);
    on<WorkspacePromptSubmitted>(_onPromptSubmitted);
    on<WorkspaceAgentStopped>(_onAgentStopped);
    on<_WorkspaceStreamEventReceived>(_onStreamEventReceived);
    on<_WorkspaceStreamFailed>(_onStreamFailed);
    on<_WorkspaceStreamClosed>(_onStreamClosed);
    on<_WorkspaceStreamStatusChanged>(_onStreamStatusChanged);
  }

  final PiWebApi _gateway;
  final Duration reconnectDelay;
  String _password = '';
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;
  int _connectionGeneration = 0;
  int _sessionLoadGeneration = 0;
  int _streamGeneration = 0;

  Future<void> _onStarted(
    WorkspaceStarted event,
    Emitter<WorkspaceModel> emit,
  ) => _connectAndLoad(baseUrl: state.baseUrl, password: _password, emit: emit);

  Future<void> _onConnectionApplied(
    WorkspaceConnectionApplied event,
    Emitter<WorkspaceModel> emit,
  ) async {
    if (state.connectionStatus == WorkspaceConnectionStatus.connecting) return;
    await _connectAndLoad(
      baseUrl: event.baseUrl,
      password: event.password,
      emit: emit,
    );
  }

  Future<void> _connectAndLoad({
    required String baseUrl,
    required String password,
    required Emitter<WorkspaceModel> emit,
  }) async {
    final generation = ++_connectionGeneration;
    _sessionLoadGeneration += 1;
    await _stopEventStream();

    String normalizedBaseUrl;
    try {
      normalizedBaseUrl = _gateway.normalizeBaseUrl(baseUrl);
    } catch (error) {
      emit(
        state.copyWith(
          connectionStatus: WorkspaceConnectionStatus.error,
          sessionsLoading: false,
          error: _messageOf(error),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        baseUrl: normalizedBaseUrl,
        connectionStatus: WorkspaceConnectionStatus.connecting,
        sessionsLoading: true,
        streamStatus: WorkspaceStreamStatus.idle,
        selectedSessionId: null,
        messages: const <PiMessageModel>[],
        error: null,
        statusMessage: 'Connecting to pi-web…',
      ),
    );

    try {
      final payload = await _gateway.loadSessions(
        baseUrl: normalizedBaseUrl,
        password: password,
        force: true,
      );
      if (generation != _connectionGeneration || isClosed) return;
      _password = password;
      final sessions = _parseSessions(payload);
      emit(
        state.copyWith(
          baseUrl: normalizedBaseUrl,
          connectionStatus: WorkspaceConnectionStatus.connected,
          sessionsLoading: false,
          sessions: sessions,
          error: null,
          statusMessage: sessions.isEmpty
              ? 'Connected. No pi sessions were found.'
              : 'Connected. ${sessions.length} sessions loaded.',
        ),
      );
    } catch (error, stackTrace) {
      if (generation != _connectionGeneration || isClosed) return;
      logE('Connecting to pi-web failed', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          connectionStatus: WorkspaceConnectionStatus.error,
          sessionsLoading: false,
          error: _messageOf(error),
          statusMessage: 'Connection failed.',
        ),
      );
    }
  }

  Future<void> _onSessionsRefreshed(
    WorkspaceSessionsRefreshed event,
    Emitter<WorkspaceModel> emit,
  ) async {
    if (state.sessionsLoading ||
        state.connectionStatus == WorkspaceConnectionStatus.connecting) {
      return;
    }
    emit(
      state.copyWith(
        sessionsLoading: true,
        error: null,
        statusMessage: 'Refreshing sessions…',
      ),
    );
    try {
      final payload = await _gateway.loadSessions(
        baseUrl: state.baseUrl,
        password: _password,
        force: true,
      );
      final sessions = _parseSessions(payload);
      final selectedStillExists = sessions.any(
        (session) => session.id == state.selectedSessionId,
      );
      emit(
        state.copyWith(
          connectionStatus: WorkspaceConnectionStatus.connected,
          sessionsLoading: false,
          sessions: sessions,
          selectedSessionId: selectedStillExists
              ? state.selectedSessionId
              : null,
          messages: selectedStillExists
              ? state.messages
              : const <PiMessageModel>[],
          error: null,
          statusMessage: 'Sessions refreshed.',
        ),
      );
      if (!selectedStillExists) await _stopEventStream();
    } catch (error, stackTrace) {
      logE('Refreshing sessions failed', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          sessionsLoading: false,
          error: _messageOf(error),
          statusMessage: 'Session refresh failed.',
        ),
      );
    }
  }

  Future<void> _onSessionSelected(
    WorkspaceSessionSelected event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final sessionId = event.sessionId.trim();
    if (sessionId.isEmpty) return;
    final generation = ++_sessionLoadGeneration;
    await _stopEventStream();
    emit(
      state.copyWith(
        selectedSessionId: sessionId,
        conversationLoading: true,
        messages: const <PiMessageModel>[],
        streamStatus: WorkspaceStreamStatus.connecting,
        error: null,
        statusMessage: 'Loading conversation…',
      ),
    );
    try {
      final payload = await _gateway.loadSession(
        baseUrl: state.baseUrl,
        password: _password,
        sessionId: sessionId,
      );
      if (generation != _sessionLoadGeneration ||
          state.selectedSessionId != sessionId ||
          isClosed) {
        return;
      }
      emit(
        state.copyWith(
          conversationLoading: false,
          messages: _parseMessages(payload),
          error: null,
          statusMessage: 'Conversation loaded.',
        ),
      );
      await _startEventStream(sessionId);
    } catch (error, stackTrace) {
      if (generation != _sessionLoadGeneration || isClosed) return;
      logE(
        'Loading a conversation failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          conversationLoading: false,
          streamStatus: WorkspaceStreamStatus.error,
          error: _messageOf(error),
          statusMessage: 'Conversation load failed.',
        ),
      );
    }
  }

  Future<void> _onNewSessionRequested(
    WorkspaceNewSessionRequested event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final cwd = event.cwd.trim();
    if (cwd.isEmpty || state.creatingSession) {
      if (cwd.isEmpty) {
        emit(state.copyWith(error: 'Enter an absolute working directory.'));
      }
      return;
    }
    emit(
      state.copyWith(
        creatingSession: true,
        error: null,
        statusMessage: 'Creating a pi session…',
      ),
    );
    try {
      final sessionId = await _gateway.ensureSession(
        baseUrl: state.baseUrl,
        password: _password,
        cwd: cwd,
      );
      final payload = await _gateway.loadSessions(
        baseUrl: state.baseUrl,
        password: _password,
        force: true,
      );
      emit(
        state.copyWith(
          creatingSession: false,
          sessions: _parseSessions(payload),
          error: null,
          statusMessage: 'Session created.',
        ),
      );
      add(WorkspaceSessionSelected(sessionId));
    } catch (error, stackTrace) {
      logE('Creating a session failed', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          creatingSession: false,
          error: _messageOf(error),
          statusMessage: 'Session creation failed.',
        ),
      );
    }
  }

  Future<void> _onPromptSubmitted(
    WorkspacePromptSubmitted event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final message = event.message.trim();
    final sessionId = state.selectedSessionId;
    if (message.isEmpty || sessionId == null || state.sending) return;

    final optimisticId = 'optimistic-${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = PiMessageModel(
      id: optimisticId,
      role: PiMessageRole.user,
      text: message,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
    emit(
      state.copyWith(
        messages: <PiMessageModel>[...state.messages, optimistic],
        sending: true,
        streaming: true,
        error: null,
        statusMessage: 'Agent is running…',
      ),
    );
    await _startEventStream(sessionId);

    try {
      await _gateway.sendPrompt(
        baseUrl: state.baseUrl,
        password: _password,
        sessionId: sessionId,
        message: message,
      );
      if (state.selectedSessionId != sessionId || isClosed) return;
      final results = await Future.wait<Map<String, dynamic>>([
        _gateway.loadSession(
          baseUrl: state.baseUrl,
          password: _password,
          sessionId: sessionId,
        ),
        _gateway.loadSessions(
          baseUrl: state.baseUrl,
          password: _password,
          force: true,
        ),
      ]);
      if (state.selectedSessionId != sessionId || isClosed) return;
      emit(
        state.copyWith(
          messages: _parseMessages(results[0]),
          sessions: _parseSessions(results[1]),
          sending: false,
          streaming: false,
          error: null,
          statusMessage: 'Agent run completed.',
        ),
      );
    } catch (error, stackTrace) {
      logE('Submitting a prompt failed', error: error, stackTrace: stackTrace);
      final definitivelyRejected =
          error is PiWebGatewayException && error.accepted == false;
      emit(
        state.copyWith(
          messages: definitivelyRejected
              ? state.messages
                    .where((item) => item.id != optimisticId)
                    .toList(growable: false)
              : state.messages,
          sending: false,
          streaming: false,
          error: _messageOf(error),
          statusMessage: definitivelyRejected
              ? 'Prompt was rejected.'
              : 'Prompt status is uncertain; refresh the conversation.',
        ),
      );
    }
  }

  Future<void> _onAgentStopped(
    WorkspaceAgentStopped event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final sessionId = state.selectedSessionId;
    if (sessionId == null || (!state.sending && !state.streaming)) return;
    emit(state.copyWith(statusMessage: 'Stopping the agent…', error: null));
    try {
      await _gateway.abort(
        baseUrl: state.baseUrl,
        password: _password,
        sessionId: sessionId,
      );
    } catch (error, stackTrace) {
      logE('Stopping the agent failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(error: _messageOf(error)));
    }
  }

  void _onStreamStatusChanged(
    _WorkspaceStreamStatusChanged event,
    Emitter<WorkspaceModel> emit,
  ) {
    emit(state.copyWith(streamStatus: event.status));
  }

  void _onStreamEventReceived(
    _WorkspaceStreamEventReceived event,
    Emitter<WorkspaceModel> emit,
  ) {
    if (event.generation != _streamGeneration ||
        event.sessionId != state.selectedSessionId) {
      return;
    }
    final payload = event.payload;
    final type = payload['type']?.toString();
    switch (type) {
      case 'connected':
        final isStreaming = payload['isStreaming'] == true;
        emit(
          state.copyWith(
            streamStatus: WorkspaceStreamStatus.connected,
            streaming: isStreaming || state.streaming,
            sessions: _setSessionRunning(
              state.sessions,
              event.sessionId,
              isStreaming || state.sending,
            ),
            statusMessage: isStreaming
                ? 'Attached to a running agent.'
                : 'Live updates connected.',
          ),
        );
      case 'agent_start':
        emit(
          state.copyWith(
            streaming: true,
            streamStatus: WorkspaceStreamStatus.connected,
            sessions: _setSessionRunning(state.sessions, event.sessionId, true),
            statusMessage: 'Agent is running…',
          ),
        );
      case 'message_start':
        final message = _parseMessage(
          payload['message'],
          fallbackId: 'stream-${event.sessionId}',
          streaming: true,
        );
        if (message != null && message.role != PiMessageRole.user) {
          emit(
            state.copyWith(messages: _upsertStreaming(state.messages, message)),
          );
        }
      case 'message_update':
        final update = _asMap(payload['assistantMessageEvent']);
        final delta = update?['delta'];
        if (delta is String && delta.isNotEmpty) {
          emit(
            state.copyWith(
              messages: _appendStreamingDelta(
                state.messages,
                event.sessionId,
                delta,
              ),
            ),
          );
        }
      case 'message_end':
        final message = _parseMessage(
          payload['message'],
          fallbackId: 'message-${DateTime.now().microsecondsSinceEpoch}',
        );
        if (message != null) {
          emit(
            state.copyWith(
              messages: _completeStreaming(state.messages, message),
            ),
          );
        }
      case 'tool_execution_start':
        emit(
          state.copyWith(
            statusMessage: 'Running ${payload['toolName'] ?? 'tool'}…',
          ),
        );
      case 'prompt_error':
      case 'startup_error':
      case 'extension_error':
        emit(
          state.copyWith(
            error:
                payload['errorMessage']?.toString() ??
                payload['error']?.toString() ??
                'The agent reported an error.',
          ),
        );
      case 'prompt_done':
      case 'agent_settled':
        emit(
          state.copyWith(
            streaming: false,
            sessions: _setSessionRunning(
              state.sessions,
              event.sessionId,
              false,
            ),
            statusMessage: 'Agent run settled.',
          ),
        );
      default:
        break;
    }
  }

  void _onStreamFailed(
    _WorkspaceStreamFailed event,
    Emitter<WorkspaceModel> emit,
  ) {
    if (event.generation != _streamGeneration ||
        event.sessionId != state.selectedSessionId) {
      return;
    }
    logW('pi-web SSE disconnected: ${event.error}');
    emit(
      state.copyWith(
        streamStatus: WorkspaceStreamStatus.reconnecting,
        statusMessage: 'Live updates disconnected; reconnecting…',
      ),
    );
    _reconnectAfterDelay(event.sessionId, event.generation);
  }

  void _onStreamClosed(
    _WorkspaceStreamClosed event,
    Emitter<WorkspaceModel> emit,
  ) {
    if (event.generation != _streamGeneration ||
        event.sessionId != state.selectedSessionId) {
      return;
    }
    emit(
      state.copyWith(
        streamStatus: WorkspaceStreamStatus.reconnecting,
        statusMessage: 'Live updates closed; reconnecting…',
      ),
    );
    _reconnectAfterDelay(event.sessionId, event.generation);
  }

  Future<void> _startEventStream(String sessionId) async {
    await _stopEventStream();
    if (isClosed || state.selectedSessionId != sessionId) return;
    final generation = ++_streamGeneration;
    add(const _WorkspaceStreamStatusChanged(WorkspaceStreamStatus.connecting));
    final subscription = _gateway
        .watchEvents(
          baseUrl: state.baseUrl,
          password: _password,
          sessionId: sessionId,
        )
        .listen(
          (payload) => add(
            _WorkspaceStreamEventReceived(
              sessionId: sessionId,
              generation: generation,
              payload: payload,
            ),
          ),
          onError: (Object error, StackTrace stackTrace) => add(
            _WorkspaceStreamFailed(
              sessionId: sessionId,
              generation: generation,
              error: error,
            ),
          ),
          onDone: () => add(
            _WorkspaceStreamClosed(
              sessionId: sessionId,
              generation: generation,
            ),
          ),
          cancelOnError: true,
        );
    _eventSubscription = subscription;
  }

  Future<void> _stopEventStream() async {
    _streamGeneration += 1;
    final subscription = _eventSubscription;
    _eventSubscription = null;
    await subscription?.cancel();
  }

  void _reconnectAfterDelay(String sessionId, int generation) {
    Future<void>.delayed(reconnectDelay, () async {
      if (isClosed ||
          generation != _streamGeneration ||
          state.selectedSessionId != sessionId) {
        return;
      }
      await _startEventStream(sessionId);
    });
  }

  static List<PiSessionModel> _parseSessions(Map<String, dynamic> payload) {
    final runningIds =
        (payload['runningSessionIds'] as List? ?? const <Object>[])
            .map((value) => value.toString())
            .toSet();
    final records = payload['sessions'];
    if (records is! List) return const <PiSessionModel>[];
    return records
        .whereType<Map>()
        .map((raw) {
          final map = Map<String, dynamic>.from(raw);
          final id = map['id']?.toString() ?? '';
          return PiSessionModel(
            id: id,
            cwd: map['cwd']?.toString() ?? '',
            name: map['name']?.toString(),
            created: map['created']?.toString() ?? '',
            modified: map['modified']?.toString() ?? '',
            messageCount: (map['messageCount'] as num?)?.toInt() ?? 0,
            firstMessage: map['firstMessage']?.toString() ?? '(no messages)',
            running: runningIds.contains(id),
          );
        })
        .where((session) => session.id.isNotEmpty)
        .toList(growable: false);
  }

  static List<PiMessageModel> _parseMessages(Map<String, dynamic> payload) {
    final context = _asMap(payload['context']);
    final messages = context?['messages'];
    final entryIds = context?['entryIds'];
    if (messages is! List) return const <PiMessageModel>[];
    return List<PiMessageModel>.generate(messages.length, (index) {
      final entryId = entryIds is List && index < entryIds.length
          ? entryIds[index]?.toString()
          : null;
      return _parseMessage(
            messages[index],
            fallbackId: entryId ?? 'message-$index',
          ) ??
          PiMessageModel(
            id: entryId ?? 'message-$index',
            role: PiMessageRole.custom,
            text: '[Unsupported pi message]',
          );
    }, growable: false);
  }

  static PiMessageModel? _parseMessage(
    Object? raw, {
    required String fallbackId,
    bool streaming = false,
  }) {
    final message = _asMap(raw);
    if (message == null) return null;
    final role = switch (message['role']?.toString()) {
      'user' => PiMessageRole.user,
      'assistant' => PiMessageRole.assistant,
      'toolResult' => PiMessageRole.tool,
      'bashExecution' => PiMessageRole.bash,
      _ => PiMessageRole.custom,
    };
    final errorText = message['errorMessage']?.toString();
    var text = _contentText(message['content']);
    if (role == PiMessageRole.bash) {
      final command = message['command']?.toString() ?? '';
      final output = message['output']?.toString() ?? '';
      text = [
        if (command.isNotEmpty) r'$ ' + command,
        if (output.isNotEmpty) output,
      ].join('\n');
    }
    if (text.isEmpty && errorText != null) text = errorText;
    if (text.isEmpty) text = '[${message['role'] ?? 'message'}]';
    final timestamp = message['timestamp'];
    final timestampMs = timestamp is num
        ? timestamp.toInt()
        : DateTime.tryParse(
            timestamp?.toString() ?? '',
          )?.millisecondsSinceEpoch;
    return PiMessageModel(
      id: message['id']?.toString() ?? fallbackId,
      role: role,
      text: text,
      isError: message['isError'] == true || errorText != null,
      timestampMs: timestampMs,
      streaming: streaming,
    );
  }

  static String _contentText(Object? content) {
    if (content is String) return content;
    if (content is! List) return '';
    final parts = <String>[];
    for (final rawBlock in content) {
      final block = _asMap(rawBlock);
      if (block == null) continue;
      switch (block['type']?.toString()) {
        case 'text':
          final text = block['text']?.toString();
          if (text != null && text.isNotEmpty) parts.add(text);
        case 'thinking':
          final thinking = block['thinking']?.toString();
          if (thinking != null && thinking.isNotEmpty) {
            parts.add('Thinking\n$thinking');
          }
        case 'toolCall':
          final name = block['toolName'] ?? block['name'] ?? 'tool';
          parts.add('Tool call: $name');
        case 'image':
          parts.add('[image]');
        default:
          final text = block['text']?.toString();
          if (text != null && text.isNotEmpty) parts.add(text);
      }
    }
    return parts.join('\n\n');
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static List<PiSessionModel> _setSessionRunning(
    List<PiSessionModel> sessions,
    String sessionId,
    bool running,
  ) => sessions
      .map(
        (session) => session.id == sessionId
            ? session.copyWith(running: running)
            : session,
      )
      .toList(growable: false);

  static List<PiMessageModel> _upsertStreaming(
    List<PiMessageModel> messages,
    PiMessageModel message,
  ) {
    final index = messages.lastIndexWhere((item) => item.streaming);
    if (index == -1) return <PiMessageModel>[...messages, message];
    return <PiMessageModel>[
      ...messages.take(index),
      message,
      ...messages.skip(index + 1),
    ];
  }

  static List<PiMessageModel> _appendStreamingDelta(
    List<PiMessageModel> messages,
    String sessionId,
    String delta,
  ) {
    final index = messages.lastIndexWhere((item) => item.streaming);
    if (index == -1) {
      return <PiMessageModel>[
        ...messages,
        PiMessageModel(
          id: 'stream-$sessionId',
          role: PiMessageRole.assistant,
          text: delta,
          streaming: true,
        ),
      ];
    }
    final current = messages[index];
    return <PiMessageModel>[
      ...messages.take(index),
      current.copyWith(text: '${current.text}$delta', streaming: true),
      ...messages.skip(index + 1),
    ];
  }

  static List<PiMessageModel> _completeStreaming(
    List<PiMessageModel> messages,
    PiMessageModel completed,
  ) {
    final streamingIndex = messages.lastIndexWhere((item) => item.streaming);
    if (streamingIndex != -1) {
      return <PiMessageModel>[
        ...messages.take(streamingIndex),
        completed.copyWith(streaming: false),
        ...messages.skip(streamingIndex + 1),
      ];
    }
    if (completed.role == PiMessageRole.user && messages.isNotEmpty) {
      final last = messages.last;
      if (last.role == PiMessageRole.user && last.text == completed.text) {
        return messages;
      }
    }
    return <PiMessageModel>[...messages, completed];
  }

  static String _messageOf(Object error) {
    if (error is PiWebGatewayException) return error.message;
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Future<void> close() async {
    _connectionGeneration += 1;
    _sessionLoadGeneration += 1;
    _streamGeneration += 1;
    await _eventSubscription?.cancel();
    return super.close();
  }
}
