part of 'workspace.dart';

class WorkspaceViewModel
    extends FrBlocViewModel<WorkspaceEvent, WorkspaceModel> {
  WorkspaceViewModel({required WorkspaceService service})
    : _service = service,
      super(
        WorkspaceModel(
          connection: service.connection,
          nodeAvailability: service.availability,
        ),
      ) {
    on<WorkspaceStarted>(_onStarted);
    on<WorkspaceConnectionRetried>(_onConnectionRetried);
    on<WorkspaceProjectDirectoryBrowsed>(_onProjectDirectoryBrowsed);
    on<WorkspaceProjectPathValidated>(_onProjectPathValidated);
    on<WorkspaceProjectSelected>(_onProjectSelected);
    on<WorkspaceProjectTrustApproved>(_onProjectTrustApproved);
    on<WorkspaceSessionsRefreshed>(_onSessionsRefreshed);
    on<WorkspaceSessionSelected>(_onSessionSelected);
    on<WorkspaceNewSessionRequested>(_onNewSessionRequested);
    on<WorkspacePromptSubmitted>(_onPromptSubmitted);
    on<WorkspaceAgentStopped>(_onAgentStopped);
    on<_WorkspaceConnectionSnapshotReceived>(_onConnectionSnapshotReceived);
    on<_WorkspaceSessionEventReceived>(_onSessionEventReceived);
    on<_WorkspaceSessionEventsFailed>(_onSessionEventsFailed);
    on<_WorkspaceSessionEventsClosed>(_onSessionEventsClosed);

    _connectionSubscription = _service.connectionStates.listen(
      (snapshot) => _addIfOpen(_WorkspaceConnectionSnapshotReceived(snapshot)),
    );
  }

  final WorkspaceService _service;
  late final StreamSubscription<PiNodeConnectionSnapshot>
  _connectionSubscription;
  StreamSubscription<PiSessionEvent>? _sessionEventSubscription;

  bool _connecting = false;
  bool _browsingProject = false;
  bool _validatingProject = false;
  bool _approvingProjectTrust = false;
  bool _refreshingSessions = false;
  bool _creatingSession = false;
  bool _promptInFlight = false;
  bool _abortInFlight = false;
  bool _closing = false;
  int _connectionGeneration = 0;
  int _projectSelectionGeneration = 0;
  int _sessionListGeneration = 0;
  int _sessionLoadGeneration = 0;
  int _eventGeneration = 0;
  int _promptGeneration = 0;
  int _commandOrdinal = 0;
  PiCommandId? _activePromptCommandId;
  Future<void>? _closeFuture;

  Future<void> _onStarted(
    WorkspaceStarted event,
    Emitter<WorkspaceModel> emit,
  ) => _connectAndLoad(emit);

  Future<void> _onConnectionRetried(
    WorkspaceConnectionRetried event,
    Emitter<WorkspaceModel> emit,
  ) => _connectAndLoad(emit);

  Future<void> _connectAndLoad(Emitter<WorkspaceModel> emit) async {
    if (_connecting || _closing) return;
    _connecting = true;
    final generation = ++_connectionGeneration;
    _projectSelectionGeneration += 1;
    _sessionListGeneration += 1;
    _sessionLoadGeneration += 1;
    _promptGeneration += 1;
    _activePromptCommandId = null;

    emit(
      state.copyWith(
        connection: const PiNodeConnectionSnapshot.connecting(),
        projectLoading: true,
        projectBrowsing: false,
        projectValidating: false,
        projectTrustApproving: false,
        sessionsLoading: true,
        conversationLoading: false,
        sending: false,
        stopping: false,
        eventStatus: WorkspaceEventStatus.idle,
        promptAdmissionStatus: WorkspacePromptAdmissionStatus.idle,
        projectBootstrap: null,
        knownProjects: const <PiKnownProject>[],
        selectedProject: null,
        projectDirectory: null,
        selectedSessionId: null,
        sessions: const <PiSessionSummary>[],
        messages: const <PiMessage>[],
        nodeError: null,
        projectError: null,
        sessionError: null,
        conversationError: null,
        promptError: null,
        statusMessage: 'Connecting to the first-party Pi Node…',
      ),
    );
    await _stopSessionEvents();

    var connected = false;
    try {
      final connection = await _service.connect();
      connected = true;
      final bootstrap = await _service.loadProjectBootstrap();
      final projectResults = await Future.wait<Object>(<Future<Object>>[
        _service.loadKnownProjects(),
        _service.browseDirectory(bootstrap.homeDirectory),
        _service.loadSessions(bootstrap.defaultProject.identity.projectId),
      ]);
      final knownProjects = projectResults[0] as List<PiKnownProject>;
      final directory = projectResults[1] as PiDirectoryListing;
      final sessions = projectResults[2] as List<PiSessionSummary>;
      if (!_isCurrentConnection(generation)) return;
      emit(
        state.copyWith(
          connection: connection,
          projectLoading: false,
          projectBootstrap: bootstrap,
          knownProjects: knownProjects,
          selectedProject: bootstrap.defaultProject,
          projectDirectory: directory,
          sessionsLoading: false,
          sessions: sessions,
          nodeError: null,
          projectError: null,
          sessionError: null,
          statusMessage: sessions.isEmpty
              ? 'Pi Node connected. The default project has no sessions.'
              : 'Pi Node connected. ${sessions.length} project sessions loaded.',
        ),
      );
    } catch (error, stackTrace) {
      if (!_isCurrentConnection(generation)) return;
      logE(
        connected
            ? 'Loading Pi Node sessions failed'
            : 'Connecting to Pi Node failed',
        error: error,
        stackTrace: stackTrace,
      );
      final message = _service.describeError(error);
      final connection = _service.connection;
      emit(
        state.copyWith(
          connection: connection,
          projectLoading: false,
          sessionsLoading: false,
          nodeError: connected ? null : message,
          projectError: connected ? message : null,
          sessionError: null,
          statusMessage: connected
              ? 'Pi Node connected, but project discovery failed.'
              : 'Pi Node connection failed.',
        ),
      );
    } finally {
      if (generation == _connectionGeneration) _connecting = false;
    }
  }

  Future<void> _onProjectDirectoryBrowsed(
    WorkspaceProjectDirectoryBrowsed event,
    Emitter<WorkspaceModel> emit,
  ) async {
    if (_browsingProject || _closing) return;
    if (state.connection.status != PiNodeConnectionStatus.connected) {
      emit(
        state.copyWith(
          projectError: 'Connect to Pi Node before browsing projects.',
        ),
      );
      return;
    }
    _browsingProject = true;
    emit(
      state.copyWith(
        projectBrowsing: true,
        projectError: null,
        statusMessage: 'Browsing project directories…',
      ),
    );
    try {
      final directory = await _service.browseDirectory(event.directory);
      if (_closing || isClosed) return;
      emit(
        state.copyWith(
          projectBrowsing: false,
          projectDirectory: directory,
          projectError: null,
          statusMessage: directory.truncated
              ? 'Directory loaded with a bounded child list.'
              : 'Directory loaded.',
        ),
      );
    } catch (error, stackTrace) {
      if (_closing || isClosed) return;
      logE(
        'Browsing Pi Node project directories failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          projectBrowsing: false,
          projectError: _service.describeError(error),
          statusMessage: 'Project directory browse failed.',
        ),
      );
    } finally {
      _browsingProject = false;
    }
  }

  Future<void> _onProjectPathValidated(
    WorkspaceProjectPathValidated event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final candidate = event.candidateDirectory.trim();
    if (_validatingProject || _closing) return;
    if (candidate.isEmpty) {
      emit(
        state.copyWith(projectError: 'Enter a project directory to validate.'),
      );
      return;
    }
    _validatingProject = true;
    emit(
      state.copyWith(
        projectValidating: true,
        projectError: null,
        statusMessage: 'Validating the project in Pi Node…',
      ),
    );
    try {
      final project = await _service.validateProject(candidate);
      if (_closing || isClosed) return;
      emit(
        state.copyWith(
          projectValidating: false,
          projectError: null,
          statusMessage: 'Project validated by Pi Node.',
        ),
      );
      add(WorkspaceProjectSelected(project));
    } catch (error, stackTrace) {
      if (_closing || isClosed) return;
      logE(
        'Validating a Pi Node project failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          projectValidating: false,
          projectError: _service.describeError(error),
          statusMessage: 'Project validation failed.',
        ),
      );
    } finally {
      _validatingProject = false;
    }
  }

  Future<void> _onProjectSelected(
    WorkspaceProjectSelected event,
    Emitter<WorkspaceModel> emit,
  ) async {
    if (_closing ||
        state.connection.status != PiNodeConnectionStatus.connected) {
      return;
    }
    final project = event.project;
    final generation = ++_projectSelectionGeneration;
    _sessionListGeneration += 1;
    _sessionLoadGeneration += 1;
    _promptGeneration += 1;
    _activePromptCommandId = null;
    await _stopSessionEvents();
    if (_closing || isClosed || generation != _projectSelectionGeneration) {
      return;
    }

    emit(
      state.copyWith(
        selectedProject: project,
        sessionsLoading: true,
        selectedSessionId: null,
        sessions: const <PiSessionSummary>[],
        messages: const <PiMessage>[],
        conversationLoading: false,
        eventStatus: WorkspaceEventStatus.idle,
        promptAdmissionStatus: WorkspacePromptAdmissionStatus.idle,
        sending: false,
        stopping: false,
        projectError: null,
        sessionError: null,
        conversationError: null,
        promptError: null,
        statusMessage: 'Loading the selected project…',
      ),
    );

    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        _service.loadSessions(project.identity.projectId),
        _service.browseDirectory(project.identity.canonicalWorkingDirectory),
      ]);
      if (_closing || isClosed || generation != _projectSelectionGeneration) {
        return;
      }
      final sessions = results[0] as List<PiSessionSummary>;
      final directory = results[1] as PiDirectoryListing;
      emit(
        state.copyWith(
          selectedProject: project,
          knownProjects: _replaceKnownProject(state.knownProjects, project),
          projectDirectory: directory,
          sessionsLoading: false,
          sessions: sessions,
          projectError: null,
          sessionError: null,
          statusMessage: sessions.isEmpty
              ? 'Project selected. No sessions were found.'
              : 'Project selected. ${sessions.length} sessions loaded.',
        ),
      );
    } catch (error, stackTrace) {
      if (_closing || isClosed || generation != _projectSelectionGeneration) {
        return;
      }
      logE(
        'Loading a selected Pi Node project failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          sessionsLoading: false,
          projectError: _service.describeError(error),
          statusMessage: 'Selected project load failed.',
        ),
      );
    }
  }

  Future<void> _onProjectTrustApproved(
    WorkspaceProjectTrustApproved event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final project = state.selectedProject;
    if (_approvingProjectTrust || _closing || project == null) return;
    if (!project.trust.requiresApproval) {
      if (event.createSessionAfterApproval) {
        add(const WorkspaceNewSessionRequested());
      } else if (event.sessionIdAfterApproval case final sessionId?) {
        add(WorkspaceSessionSelected(sessionId));
      }
      return;
    }

    _approvingProjectTrust = true;
    emit(
      state.copyWith(
        projectTrustApproving: true,
        projectError: null,
        sessionError: null,
        statusMessage: 'Persisting explicit project trust approval…',
      ),
    );
    try {
      final approved = await _service.approveProjectTrust(project);
      if (_closing ||
          isClosed ||
          state.selectedProject?.identity.projectId !=
              project.identity.projectId) {
        return;
      }
      emit(
        state.copyWith(
          projectTrustApproving: false,
          selectedProject: approved,
          knownProjects: _replaceKnownProject(state.knownProjects, approved),
          projectError: null,
          statusMessage:
              'Project trust approved. Session runtimes will reload.',
        ),
      );
      if (event.createSessionAfterApproval) {
        add(const WorkspaceNewSessionRequested());
      } else if (event.sessionIdAfterApproval case final sessionId?) {
        add(WorkspaceSessionSelected(sessionId));
      }
    } catch (error, stackTrace) {
      if (_closing || isClosed) return;
      logE(
        'Approving Pi Node project trust failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          projectTrustApproving: false,
          projectError: _service.describeError(error),
          statusMessage: 'Project trust approval failed.',
        ),
      );
    } finally {
      _approvingProjectTrust = false;
    }
  }

  Future<void> _onSessionsRefreshed(
    WorkspaceSessionsRefreshed event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final project = state.selectedProject;
    if (_refreshingSessions ||
        _closing ||
        project == null ||
        state.connection.status != PiNodeConnectionStatus.connected) {
      return;
    }
    _refreshingSessions = true;
    final generation = ++_sessionListGeneration;
    emit(
      state.copyWith(
        sessionsLoading: true,
        sessionError: null,
        statusMessage: 'Refreshing Pi sessions…',
      ),
    );

    try {
      final sessions = await _service.loadSessions(project.identity.projectId);
      if (!_isCurrentSessionList(generation)) return;
      final selectedSessionId = state.selectedSessionId;
      final selectedStillExists =
          selectedSessionId != null &&
          sessions.any((session) => session.id == selectedSessionId);
      emit(
        state.copyWith(
          sessionsLoading: false,
          sessions: sessions,
          selectedSessionId: selectedStillExists ? selectedSessionId : null,
          messages: selectedStillExists ? state.messages : const <PiMessage>[],
          eventStatus: selectedStillExists
              ? state.eventStatus
              : WorkspaceEventStatus.idle,
          sessionError: null,
          conversationError: selectedStillExists
              ? state.conversationError
              : null,
          promptError: selectedStillExists ? state.promptError : null,
          statusMessage: 'Pi sessions refreshed.',
        ),
      );
      if (!selectedStillExists) await _stopSessionEvents();
    } catch (error, stackTrace) {
      if (!_isCurrentSessionList(generation)) return;
      logE(
        'Refreshing Pi Node sessions failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          sessionsLoading: false,
          sessionError: _service.describeError(error),
          statusMessage: 'Session refresh failed.',
        ),
      );
    } finally {
      _refreshingSessions = false;
    }
  }

  Future<void> _onSessionSelected(
    WorkspaceSessionSelected event,
    Emitter<WorkspaceModel> emit,
  ) async {
    if (_closing ||
        state.connection.status != PiNodeConnectionStatus.connected) {
      return;
    }
    if (state.selectedProject?.trust.requiresApproval ?? true) {
      emit(
        state.copyWith(
          sessionError:
              'Approve project trust before opening a resource-bearing session.',
          statusMessage: 'Project trust approval is required.',
        ),
      );
      return;
    }
    final project = state.selectedProject!;
    final sessionId = event.sessionId;
    final generation = ++_sessionLoadGeneration;
    _promptGeneration += 1;
    _activePromptCommandId = null;
    await _stopSessionEvents();
    if (_closing || isClosed || generation != _sessionLoadGeneration) return;

    emit(
      state.copyWith(
        selectedSessionId: sessionId,
        conversationLoading: true,
        messages: const <PiMessage>[],
        eventStatus: WorkspaceEventStatus.idle,
        promptAdmissionStatus: WorkspacePromptAdmissionStatus.idle,
        sending: false,
        stopping: false,
        conversationError: null,
        promptError: null,
        statusMessage: 'Loading the Pi conversation…',
      ),
    );

    try {
      final detail = await _service.loadSession(
        project.identity.projectId,
        sessionId,
      );
      if (!_isCurrentSessionLoad(generation, sessionId)) return;
      emit(
        state.copyWith(
          conversationLoading: false,
          sessions: _replaceSession(state.sessions, detail.summary),
          messages: detail.messages,
          conversationError: null,
          statusMessage: 'Conversation loaded from Pi Node.',
        ),
      );
      await _startSessionEvents(sessionId, emit);
    } catch (error, stackTrace) {
      if (!_isCurrentSessionLoad(generation, sessionId)) return;
      logE(
        'Loading a Pi Node conversation failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          conversationLoading: false,
          eventStatus: WorkspaceEventStatus.error,
          conversationError: _service.describeError(error),
          statusMessage: 'Conversation load failed.',
        ),
      );
    }
  }

  Future<void> _onNewSessionRequested(
    WorkspaceNewSessionRequested event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final project = state.selectedProject;
    if (_creatingSession || _closing) return;
    if (state.connection.status != PiNodeConnectionStatus.connected) {
      emit(
        state.copyWith(
          sessionError: 'Connect to Pi Node before creating a session.',
        ),
      );
      return;
    }
    if (project == null) {
      emit(
        state.copyWith(
          sessionError:
              'Select a Node-validated project before creating a session.',
        ),
      );
      return;
    }
    if (project.trust.requiresApproval) {
      emit(
        state.copyWith(
          sessionError:
              'Approve project trust before creating a resource-bearing session.',
          statusMessage: 'Project trust approval is required.',
        ),
      );
      return;
    }

    _creatingSession = true;
    emit(
      state.copyWith(
        creatingSession: true,
        sessionError: null,
        statusMessage: 'Creating a Pi session in the validated project…',
      ),
    );
    try {
      final detail = await _service.createSession(project.identity.projectId);
      if (_closing ||
          isClosed ||
          state.selectedProject?.identity.projectId !=
              project.identity.projectId) {
        return;
      }
      List<PiSessionSummary> sessions;
      try {
        sessions = await _service.loadSessions(project.identity.projectId);
      } catch (_) {
        sessions = _replaceSession(state.sessions, detail.summary);
      }
      if (_closing || isClosed) return;
      emit(
        state.copyWith(
          creatingSession: false,
          sessions: sessions,
          sessionError: null,
          statusMessage: 'Pi session created.',
        ),
      );
      add(WorkspaceSessionSelected(detail.summary.id));
    } catch (error, stackTrace) {
      if (_closing || isClosed) return;
      logE(
        'Creating a Pi Node session failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          creatingSession: false,
          sessionError: _service.describeError(error),
          statusMessage: 'Session creation failed.',
        ),
      );
    } finally {
      _creatingSession = false;
    }
  }

  Future<void> _onPromptSubmitted(
    WorkspacePromptSubmitted event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final prompt = event.prompt.trim();
    final sessionId = state.selectedSessionId;
    final selected = _selectedSession(state);
    if (_promptInFlight ||
        _closing ||
        prompt.isEmpty ||
        sessionId == null ||
        selected?.isRunning == true ||
        state.connection.status != PiNodeConnectionStatus.connected) {
      return;
    }

    _promptInFlight = true;
    final generation = ++_promptGeneration;
    final commandId = _newCommandId('prompt');
    _activePromptCommandId = commandId;
    final optimisticId = PiMessageId(
      'workspace-optimistic-${DateTime.now().toUtc().microsecondsSinceEpoch}',
    );
    final optimistic = PiMessage(
      id: optimisticId,
      role: PiMessageRole.user,
      text: prompt,
      createdAt: DateTime.now().toUtc(),
      isStreaming: false,
    );
    emit(
      state.copyWith(
        messages: <PiMessage>[...state.messages, optimistic],
        sending: true,
        promptAdmissionStatus: WorkspacePromptAdmissionStatus.idle,
        promptError: null,
        statusMessage: 'Submitting the prompt to Pi Node…',
      ),
    );

    try {
      final result = await _service.submitPrompt(
        commandId: commandId,
        sessionId: sessionId,
        prompt: prompt,
      );
      if (!_isCurrentPrompt(generation, sessionId)) return;
      switch (result) {
        case PiCommandAccepted():
          emit(
            state.copyWith(
              sending: false,
              promptAdmissionStatus: WorkspacePromptAdmissionStatus.accepted,
              sessions: _setSessionRunning(state.sessions, sessionId, true),
              promptError: null,
              statusMessage: 'Prompt accepted. Pi is running…',
            ),
          );
        case PiCommandRejected(:final error):
          _activePromptCommandId = null;
          emit(
            state.copyWith(
              messages: state.messages
                  .where((message) => message.id != optimisticId)
                  .toList(growable: false),
              sending: false,
              promptAdmissionStatus: WorkspacePromptAdmissionStatus.rejected,
              promptError: _service.describeError(error),
              statusMessage: 'Pi Node rejected the prompt.',
            ),
          );
        case PiCommandUncertain(:final error):
          emit(
            state.copyWith(
              sending: false,
              promptAdmissionStatus: WorkspacePromptAdmissionStatus.uncertain,
              sessions: _setSessionRunning(state.sessions, sessionId, true),
              promptError:
                  '${_service.describeError(error)} Prompt admission is uncertain; refresh the conversation before retrying.',
              statusMessage: 'Prompt admission is uncertain.',
            ),
          );
      }
    } catch (error, stackTrace) {
      if (!_isCurrentPrompt(generation, sessionId)) return;
      _activePromptCommandId = null;
      logE(
        'Submitting a Pi Node prompt failed before admission',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          messages: state.messages
              .where((message) => message.id != optimisticId)
              .toList(growable: false),
          sending: false,
          promptAdmissionStatus: WorkspacePromptAdmissionStatus.rejected,
          promptError: _service.describeError(error),
          statusMessage: 'Prompt submission failed.',
        ),
      );
    } finally {
      if (generation == _promptGeneration) _promptInFlight = false;
    }
  }

  Future<void> _onAgentStopped(
    WorkspaceAgentStopped event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final sessionId = state.selectedSessionId;
    if (_abortInFlight ||
        _closing ||
        sessionId == null ||
        _selectedSession(state)?.isRunning != true) {
      return;
    }

    _abortInFlight = true;
    emit(
      state.copyWith(
        stopping: true,
        promptError: null,
        statusMessage: 'Requesting Pi to stop…',
      ),
    );
    try {
      final result = await _service.abort(
        commandId: _newCommandId('abort'),
        sessionId: sessionId,
      );
      if (_closing || isClosed || state.selectedSessionId != sessionId) return;
      switch (result) {
        case PiCommandAccepted():
          emit(
            state.copyWith(
              stopping: false,
              statusMessage: 'Stop requested. Waiting for Pi to settle…',
            ),
          );
        case PiCommandRejected(:final error):
          emit(
            state.copyWith(
              stopping: false,
              promptError: _service.describeError(error),
              statusMessage: 'Pi Node rejected the stop request.',
            ),
          );
        case PiCommandUncertain(:final error):
          emit(
            state.copyWith(
              stopping: false,
              promptError:
                  '${_service.describeError(error)} Stop status is uncertain.',
              statusMessage: 'Stop status is uncertain.',
            ),
          );
      }
    } catch (error, stackTrace) {
      if (_closing || isClosed || state.selectedSessionId != sessionId) return;
      logE(
        'Stopping the Pi Node run failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          stopping: false,
          promptError: _service.describeError(error),
          statusMessage: 'Stop request failed.',
        ),
      );
    } finally {
      _abortInFlight = false;
    }
  }

  Future<void> _onConnectionSnapshotReceived(
    _WorkspaceConnectionSnapshotReceived event,
    Emitter<WorkspaceModel> emit,
  ) async {
    if (_closing) return;
    final snapshot = event.snapshot;
    if (snapshot.status == PiNodeConnectionStatus.disconnected &&
        state.connection.status == PiNodeConnectionStatus.connected) {
      _sessionLoadGeneration += 1;
      _promptGeneration += 1;
      _activePromptCommandId = null;
      await _stopSessionEvents();
      emit(
        state.copyWith(
          connection: snapshot,
          eventStatus: WorkspaceEventStatus.error,
          sending: false,
          stopping: false,
          nodeError: 'The Pi Node disconnected. Retry the connection.',
          statusMessage: 'Pi Node disconnected.',
        ),
      );
      return;
    }
    emit(state.copyWith(connection: snapshot));
  }

  Future<void> _onSessionEventReceived(
    _WorkspaceSessionEventReceived event,
    Emitter<WorkspaceModel> emit,
  ) async {
    if (!_isCurrentEvent(event.generation, event.sessionId)) return;
    final nodeEvent = event.event;
    switch (nodeEvent) {
      case PiSessionSequenceGapEvent():
        emit(
          state.copyWith(
            eventStatus: WorkspaceEventStatus.recovering,
            conversationLoading: true,
            conversationError: null,
            statusMessage:
                'A Pi event sequence gap was detected. Reloading authoritative state…',
          ),
        );
        await _refreshSelectedAuthoritatively(
          event.sessionId,
          event.generation,
          emit,
        );
      case PiSessionMessageAddedEvent(:final message):
        emit(
          state.copyWith(
            eventStatus: WorkspaceEventStatus.listening,
            messages: _mergeAddedMessage(state.messages, message),
            conversationError: null,
            statusMessage: message.isStreaming
                ? 'Receiving Pi output…'
                : state.statusMessage,
          ),
        );
      case PiSessionMessageDeltaEvent(:final messageId, :final delta):
        final messages = _appendMessageDelta(state.messages, messageId, delta);
        if (messages == null) {
          emit(
            state.copyWith(
              eventStatus: WorkspaceEventStatus.recovering,
              conversationLoading: true,
              statusMessage:
                  'A Pi message update could not be applied. Reloading authoritative state…',
            ),
          );
          await _refreshSelectedAuthoritatively(
            event.sessionId,
            event.generation,
            emit,
          );
          return;
        }
        emit(
          state.copyWith(
            eventStatus: WorkspaceEventStatus.listening,
            messages: messages,
            statusMessage: 'Receiving Pi output…',
          ),
        );
      case PiSessionRunningChangedEvent(:final isRunning):
        emit(
          state.copyWith(
            eventStatus: WorkspaceEventStatus.listening,
            sessions: _setSessionRunning(
              state.sessions,
              event.sessionId,
              isRunning,
            ),
            sending: isRunning ? state.sending : false,
            stopping: isRunning ? state.stopping : false,
            statusMessage: isRunning ? 'Pi is running…' : 'Pi run settled.',
          ),
        );
      case PiSessionCommandCompletedEvent(:final commandId, :final succeeded):
        if (_activePromptCommandId == commandId) {
          _activePromptCommandId = null;
        }
        emit(
          state.copyWith(
            eventStatus: WorkspaceEventStatus.recovering,
            conversationLoading: true,
            sending: false,
            stopping: false,
            sessions: _setSessionRunning(
              state.sessions,
              event.sessionId,
              false,
            ),
            promptAdmissionStatus: WorkspacePromptAdmissionStatus.idle,
            promptError: succeeded
                ? null
                : 'The Pi command did not complete successfully.',
            statusMessage: succeeded
                ? 'Pi command completed. Refreshing conversation…'
                : 'Pi command ended with an error. Refreshing conversation…',
          ),
        );
        await _refreshSelectedAuthoritatively(
          event.sessionId,
          event.generation,
          emit,
        );
    }
  }

  void _onSessionEventsFailed(
    _WorkspaceSessionEventsFailed event,
    Emitter<WorkspaceModel> emit,
  ) {
    if (!_isCurrentEvent(event.generation, event.sessionId)) return;
    logW('Pi Node session event stream failed.');
    emit(
      state.copyWith(
        eventStatus: WorkspaceEventStatus.error,
        conversationError: _service.describeError(event.error),
        statusMessage: 'Live Pi events disconnected.',
      ),
    );
  }

  void _onSessionEventsClosed(
    _WorkspaceSessionEventsClosed event,
    Emitter<WorkspaceModel> emit,
  ) {
    if (!_isCurrentEvent(event.generation, event.sessionId)) return;
    emit(
      state.copyWith(
        eventStatus: WorkspaceEventStatus.error,
        conversationError:
            'The Pi Node event stream closed. Reload the conversation or retry the connection.',
        statusMessage: 'Live Pi events closed.',
      ),
    );
  }

  Future<void> _refreshSelectedAuthoritatively(
    PiSessionId sessionId,
    int eventGeneration,
    Emitter<WorkspaceModel> emit,
  ) async {
    final sessionListGeneration = ++_sessionListGeneration;
    final project = state.selectedProject;
    if (project == null) return;
    try {
      final detail = await _service.loadSession(
        project.identity.projectId,
        sessionId,
      );
      final sessions = await _service.loadSessions(project.identity.projectId);
      if (!_isCurrentEvent(eventGeneration, sessionId) ||
          sessionListGeneration != _sessionListGeneration) {
        return;
      }
      emit(
        state.copyWith(
          conversationLoading: false,
          sessionsLoading: false,
          sessions: _replaceSession(sessions, detail.summary),
          messages: detail.messages,
          eventStatus: WorkspaceEventStatus.listening,
          sessionError: null,
          conversationError: null,
          statusMessage: 'Conversation reconciled with Pi Node.',
        ),
      );
    } catch (error, stackTrace) {
      if (!_isCurrentEvent(eventGeneration, sessionId) ||
          sessionListGeneration != _sessionListGeneration) {
        return;
      }
      logE(
        'Authoritative Pi Node refresh failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          conversationLoading: false,
          sessionsLoading: false,
          eventStatus: WorkspaceEventStatus.error,
          conversationError: _service.describeError(error),
          statusMessage: 'Authoritative conversation refresh failed.',
        ),
      );
    }
  }

  Future<void> _startSessionEvents(
    PiSessionId sessionId,
    Emitter<WorkspaceModel> emit,
  ) async {
    await _stopSessionEvents();
    if (_closing || isClosed || state.selectedSessionId != sessionId) return;
    final generation = ++_eventGeneration;
    emit(
      state.copyWith(
        eventStatus: WorkspaceEventStatus.listening,
        conversationError: null,
        statusMessage: 'Listening for first-party Pi events.',
      ),
    );
    _sessionEventSubscription = _service
        .watchSession(sessionId)
        .listen(
          (event) => _addIfOpen(
            _WorkspaceSessionEventReceived(
              sessionId: sessionId,
              generation: generation,
              event: event,
            ),
          ),
          onError: (Object error, StackTrace stackTrace) => _addIfOpen(
            _WorkspaceSessionEventsFailed(
              sessionId: sessionId,
              generation: generation,
              error: error,
            ),
          ),
          onDone: () => _addIfOpen(
            _WorkspaceSessionEventsClosed(
              sessionId: sessionId,
              generation: generation,
            ),
          ),
          cancelOnError: true,
        );
  }

  Future<void> _stopSessionEvents() async {
    _eventGeneration += 1;
    final subscription = _sessionEventSubscription;
    _sessionEventSubscription = null;
    await subscription?.cancel();
  }

  void _addIfOpen(WorkspaceEvent event) {
    if (!_closing && !isClosed) add(event);
  }

  PiCommandId _newCommandId(String operation) => PiCommandId(
    'workspace-$operation-${DateTime.now().toUtc().microsecondsSinceEpoch}-${++_commandOrdinal}',
  );

  bool _isCurrentConnection(int generation) =>
      !_closing && !isClosed && generation == _connectionGeneration;

  bool _isCurrentSessionList(int generation) =>
      !_closing && !isClosed && generation == _sessionListGeneration;

  bool _isCurrentSessionLoad(int generation, PiSessionId sessionId) =>
      !_closing &&
      !isClosed &&
      generation == _sessionLoadGeneration &&
      state.selectedSessionId == sessionId;

  bool _isCurrentPrompt(int generation, PiSessionId sessionId) =>
      !_closing &&
      !isClosed &&
      generation == _promptGeneration &&
      state.selectedSessionId == sessionId;

  bool _isCurrentEvent(int generation, PiSessionId sessionId) =>
      !_closing &&
      !isClosed &&
      generation == _eventGeneration &&
      state.selectedSessionId == sessionId;

  @override
  Future<void> close() {
    final existing = _closeFuture;
    if (existing != null) return existing;
    _closing = true;
    _connectionGeneration += 1;
    _projectSelectionGeneration += 1;
    _sessionListGeneration += 1;
    _sessionLoadGeneration += 1;
    _promptGeneration += 1;
    _eventGeneration += 1;
    final future = Future.wait<void>(<Future<void>>[
      if (_sessionEventSubscription case final subscription?)
        subscription.cancel(),
      _connectionSubscription.cancel(),
    ]).then<void>((_) => super.close());
    _closeFuture = future;
    return future;
  }
}

List<PiKnownProject> _replaceKnownProject(
  List<PiKnownProject> projects,
  PiProject replacement,
) => projects
    .map(
      (known) =>
          known.project.identity.projectId == replacement.identity.projectId
          ? PiKnownProject(
              project: replacement,
              lastSessionAt: known.lastSessionAt,
              sessionCount: known.sessionCount,
            )
          : known,
    )
    .toList(growable: false);

PiSessionSummary? _selectedSession(WorkspaceModel model) {
  final selectedSessionId = model.selectedSessionId;
  if (selectedSessionId == null) return null;
  for (final session in model.sessions) {
    if (session.id == selectedSessionId) return session;
  }
  return null;
}

List<PiSessionSummary> _replaceSession(
  List<PiSessionSummary> sessions,
  PiSessionSummary replacement,
) {
  final index = sessions.indexWhere((session) => session.id == replacement.id);
  if (index == -1) return <PiSessionSummary>[replacement, ...sessions];
  return <PiSessionSummary>[
    ...sessions.take(index),
    replacement,
    ...sessions.skip(index + 1),
  ];
}

List<PiSessionSummary> _setSessionRunning(
  List<PiSessionSummary> sessions,
  PiSessionId sessionId,
  bool isRunning,
) => sessions
    .map(
      (session) => session.id == sessionId
          ? PiSessionSummary(
              id: session.id,
              title: session.title,
              workingDirectory: session.workingDirectory,
              createdAt: session.createdAt,
              updatedAt: session.updatedAt,
              isRunning: isRunning,
              hasUnread: session.hasUnread,
            )
          : session,
    )
    .toList(growable: false);

List<PiMessage> _mergeAddedMessage(
  List<PiMessage> messages,
  PiMessage message,
) {
  final existingIndex = messages.indexWhere((item) => item.id == message.id);
  if (existingIndex != -1) {
    return <PiMessage>[
      ...messages.take(existingIndex),
      message,
      ...messages.skip(existingIndex + 1),
    ];
  }
  if (message.role == PiMessageRole.user) {
    final optimisticIndex = messages.lastIndexWhere(
      (item) =>
          item.role == PiMessageRole.user &&
          item.id.value.startsWith('workspace-optimistic-') &&
          item.text == message.text,
    );
    if (optimisticIndex != -1) {
      return <PiMessage>[
        ...messages.take(optimisticIndex),
        message,
        ...messages.skip(optimisticIndex + 1),
      ];
    }
  }
  return <PiMessage>[...messages, message];
}

List<PiMessage>? _appendMessageDelta(
  List<PiMessage> messages,
  PiMessageId messageId,
  String delta,
) {
  final index = messages.indexWhere((message) => message.id == messageId);
  if (index == -1) return null;
  final current = messages[index];
  final updated = PiMessage(
    id: current.id,
    role: current.role,
    text: '${current.text}$delta',
    createdAt: current.createdAt,
    isStreaming: true,
  );
  return <PiMessage>[
    ...messages.take(index),
    updated,
    ...messages.skip(index + 1),
  ];
}
