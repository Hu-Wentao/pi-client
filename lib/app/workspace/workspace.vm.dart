part of 'workspace.dart';

class WorkspaceViewModel
    extends FrBlocViewModel<WorkspaceEvent, WorkspaceModel> {
  WorkspaceViewModel({
    required WorkspaceService service,
    PiSessionExportSaver? exportSaver,
  }) : _service = service,
       _exportSaver = exportSaver ?? createPlatformSessionExportSaver(),
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
    on<WorkspaceSessionRenamed>(_onSessionRenamed);
    on<WorkspaceSessionCustomNameCleared>(_onSessionCustomNameCleared);
    on<WorkspaceSessionAutoNamed>(_onSessionAutoNamed);
    on<WorkspaceSessionDeleted>(_onSessionDeleted);
    on<WorkspaceSessionTreeNavigated>(_onSessionTreeNavigated);
    on<WorkspaceSessionForked>(_onSessionForked);
    on<WorkspaceSessionCloned>(_onSessionCloned);
    on<WorkspaceOlderHistoryRequested>(_onOlderHistoryRequested);
    on<WorkspaceSessionStatsRefreshed>(_onSessionStatsRefreshed);
    on<WorkspaceSessionExportRequested>(_onSessionExportRequested);
    on<WorkspaceSessionExportCancelled>(_onSessionExportCancelled);
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
  final PiSessionExportSaver _exportSaver;
  late final StreamSubscription<PiNodeConnectionSnapshot>
  _connectionSubscription;
  StreamSubscription<PiSessionEvent>? _sessionEventSubscription;

  bool _connecting = false;
  bool _browsingProject = false;
  bool _validatingProject = false;
  bool _approvingProjectTrust = false;
  bool _refreshingSessions = false;
  bool _creatingSession = false;
  bool _sessionAdminInFlight = false;
  bool _sessionTreeMutationInFlight = false;
  bool _historyInFlight = false;
  bool _statsInFlight = false;
  bool _exportInFlight = false;
  bool _exportCancellationRequested = false;
  bool _promptInFlight = false;
  bool _abortInFlight = false;
  bool _closing = false;
  int _connectionGeneration = 0;
  int _projectSelectionGeneration = 0;
  int _sessionListGeneration = 0;
  int _sessionLoadGeneration = 0;
  int _sessionAdminGeneration = 0;
  int _sessionTreeMutationGeneration = 0;
  int _exportGeneration = 0;
  int _eventGeneration = 0;
  int _promptGeneration = 0;
  int _commandOrdinal = 0;
  PiCommandId? _activePromptCommandId;
  PiSessionExportHandle? _activeExportHandle;
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
    _sessionAdminGeneration += 1;
    _sessionAdminInFlight = false;
    _sessionTreeMutationGeneration += 1;
    _sessionTreeMutationInFlight = false;
    _promptGeneration += 1;
    _activePromptCommandId = null;
    await _cancelActiveExportForContextChange();

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
        sessionAdminSessionId: null,
        sessionAdminOperation: null,
        sessionAdminLoading: false,
        sessionTree: null,
        sessionTreeLoading: false,
        sessionTreeMutationOperation: null,
        sessionTreeMutationLoading: false,
        sessions: const <PiSessionSummary>[],
        messages: const <PiMessage>[],
        historyCursor: null,
        activeBranchRevision: null,
        treeRevision: null,
        historyHasMore: false,
        historyLoading: false,
        sessionStats: null,
        sessionStatsLoading: false,
        sessionExportLoading: false,
        sessionExportFormat: null,
        sessionExportSavedBytes: 0,
        sessionExportTotalBytes: 0,
        lastExportFileName: null,
        nodeError: null,
        projectError: null,
        sessionError: null,
        sessionAdminError: null,
        sessionTreeError: null,
        conversationError: null,
        sessionStatsError: null,
        sessionExportError: null,
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
    _sessionAdminGeneration += 1;
    _sessionAdminInFlight = false;
    _sessionTreeMutationGeneration += 1;
    _sessionTreeMutationInFlight = false;
    _promptGeneration += 1;
    _activePromptCommandId = null;
    await _cancelActiveExportForContextChange();
    await _stopSessionEvents();
    if (_closing || isClosed || generation != _projectSelectionGeneration) {
      return;
    }

    emit(
      state.copyWith(
        selectedProject: project,
        sessionsLoading: true,
        selectedSessionId: null,
        sessionAdminSessionId: null,
        sessionAdminOperation: null,
        sessionAdminLoading: false,
        sessionTree: null,
        sessionTreeLoading: false,
        sessionTreeMutationOperation: null,
        sessionTreeMutationLoading: false,
        sessions: const <PiSessionSummary>[],
        messages: const <PiMessage>[],
        historyCursor: null,
        activeBranchRevision: null,
        treeRevision: null,
        historyHasMore: false,
        historyLoading: false,
        sessionStats: null,
        sessionStatsLoading: false,
        sessionExportLoading: false,
        sessionExportFormat: null,
        sessionExportSavedBytes: 0,
        sessionExportTotalBytes: 0,
        lastExportFileName: null,
        conversationLoading: false,
        eventStatus: WorkspaceEventStatus.idle,
        promptAdmissionStatus: WorkspacePromptAdmissionStatus.idle,
        sending: false,
        stopping: false,
        projectError: null,
        sessionError: null,
        sessionAdminError: null,
        sessionTreeError: null,
        conversationError: null,
        sessionStatsError: null,
        sessionExportError: null,
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
        sessionAdminError: null,
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
          sessionTree: selectedStillExists ? state.sessionTree : null,
          sessionTreeError: selectedStillExists ? state.sessionTreeError : null,
          eventStatus: selectedStillExists
              ? state.eventStatus
              : WorkspaceEventStatus.idle,
          sessionError: null,
          sessionAdminError: null,
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
    await _cancelActiveExportForContextChange();
    await _stopSessionEvents();
    if (_closing || isClosed || generation != _sessionLoadGeneration) return;

    emit(
      state.copyWith(
        selectedSessionId: sessionId,
        conversationLoading: true,
        sessionTreeLoading: true,
        messages: const <PiMessage>[],
        historyCursor: null,
        activeBranchRevision: null,
        treeRevision: null,
        historyHasMore: false,
        historyLoading: false,
        sessionStats: null,
        sessionStatsLoading: true,
        sessionExportLoading: false,
        sessionExportFormat: null,
        sessionExportSavedBytes: 0,
        sessionExportTotalBytes: 0,
        lastExportFileName: null,
        sessionTree: null,
        eventStatus: WorkspaceEventStatus.idle,
        promptAdmissionStatus: WorkspacePromptAdmissionStatus.idle,
        composerDraft: '',
        composerDraftGeneration: state.composerDraftGeneration + 1,
        sending: false,
        stopping: false,
        conversationError: null,
        sessionTreeError: null,
        sessionStatsError: null,
        sessionExportError: null,
        promptError: null,
        statusMessage:
            'Loading the latest 50 messages, statistics, and branch tree…',
      ),
    );

    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        _service.loadSessionHistory(
          projectId: project.identity.projectId,
          sessionId: sessionId,
          limit: 50,
        ),
        _service.loadSessionTree(project.identity.projectId, sessionId),
        _service.loadSessionStats(project.identity.projectId, sessionId),
      ]);
      if (!_isCurrentSessionLoad(generation, sessionId)) return;
      final history = results[0] as PiSessionHistoryPage;
      final tree = results[1] as PiSessionTree;
      final stats = results[2] as PiSessionStats;
      emit(
        state.copyWith(
          conversationLoading: false,
          sessionTreeLoading: false,
          sessionStatsLoading: false,
          sessions: _replaceSession(state.sessions, history.summary),
          messages: history.messages,
          historyCursor: history.nextCursor,
          activeBranchRevision: history.activeBranchRevision,
          treeRevision: history.treeRevision,
          historyHasMore: history.hasMore,
          historyLoading: false,
          sessionStats: stats,
          sessionTree: tree,
          conversationError: null,
          sessionTreeError: null,
          sessionStatsError: null,
          statusMessage: history.hasMore
              ? 'Latest 50 messages loaded. Older history is available.'
              : 'Complete conversation, statistics, and branch tree loaded.',
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
          sessionTreeLoading: false,
          sessionStatsLoading: false,
          eventStatus: WorkspaceEventStatus.error,
          conversationError: _service.describeError(error),
          sessionTreeError: _service.describeError(error),
          sessionStatsError: _service.describeError(error),
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

  Future<void> _onSessionRenamed(
    WorkspaceSessionRenamed event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) {
      emit(
        state.copyWith(
          sessionAdminError: 'Enter a non-empty session name.',
          statusMessage: 'Session rename requires a name.',
        ),
      );
      return;
    }
    await _runSessionAdministration(
      sessionId: event.sessionId,
      operation: PiSessionAdminOperation.rename,
      emit: emit,
      invoke: (commandId, projectId) => _service.renameSession(
        commandId: commandId,
        projectId: projectId,
        sessionId: event.sessionId,
        name: name,
      ),
    );
  }

  Future<void> _onSessionCustomNameCleared(
    WorkspaceSessionCustomNameCleared event,
    Emitter<WorkspaceModel> emit,
  ) => _runSessionAdministration(
    sessionId: event.sessionId,
    operation: PiSessionAdminOperation.clearName,
    emit: emit,
    invoke: (commandId, projectId) => _service.clearSessionName(
      commandId: commandId,
      projectId: projectId,
      sessionId: event.sessionId,
    ),
  );

  Future<void> _onSessionAutoNamed(
    WorkspaceSessionAutoNamed event,
    Emitter<WorkspaceModel> emit,
  ) => _runSessionAdministration(
    sessionId: event.sessionId,
    operation: PiSessionAdminOperation.autoName,
    emit: emit,
    invoke: (commandId, projectId) => _service.autoNameSession(
      commandId: commandId,
      projectId: projectId,
      sessionId: event.sessionId,
    ),
  );

  Future<void> _onSessionDeleted(
    WorkspaceSessionDeleted event,
    Emitter<WorkspaceModel> emit,
  ) => _runSessionAdministration(
    sessionId: event.confirmation.sessionId,
    operation: PiSessionAdminOperation.delete,
    emit: emit,
    invoke: (commandId, projectId) => _service.deleteSession(
      commandId: commandId,
      projectId: projectId,
      sessionId: event.confirmation.sessionId,
      confirmation: event.confirmation,
    ),
  );

  Future<void> _runSessionAdministration({
    required PiSessionId sessionId,
    required PiSessionAdminOperation operation,
    required Emitter<WorkspaceModel> emit,
    required Future<PiSessionAdminResult> Function(
      PiCommandId commandId,
      PiProjectId projectId,
    )
    invoke,
  }) async {
    final project = state.selectedProject;
    final target = state.sessions
        .where((session) => session.id == sessionId)
        .firstOrNull;
    if (_sessionAdminInFlight || _sessionTreeMutationInFlight || _closing) {
      return;
    }
    if (project == null || target == null) {
      emit(
        state.copyWith(
          sessionAdminError: 'Refresh sessions before using session actions.',
          statusMessage:
              'Session administration requires current project state.',
        ),
      );
      return;
    }
    if (state.connection.status != PiNodeConnectionStatus.connected) {
      emit(
        state.copyWith(
          sessionAdminError: 'Connect to Pi Node before using session actions.',
        ),
      );
      return;
    }
    if (operation == PiSessionAdminOperation.autoName &&
        project.trust.requiresApproval) {
      emit(
        state.copyWith(
          sessionAdminError:
              'Approve project trust before using model-assisted session naming.',
          statusMessage: 'Project trust approval is required for auto-name.',
        ),
      );
      return;
    }

    _sessionAdminInFlight = true;
    final generation = ++_sessionAdminGeneration;
    final projectId = project.identity.projectId;
    final wasSelected = state.selectedSessionId == sessionId;
    _sessionListGeneration += 1;
    _sessionLoadGeneration += 1;
    _sessionTreeMutationGeneration += 1;
    _sessionTreeMutationInFlight = false;
    _promptGeneration += 1;
    _activePromptCommandId = null;
    if (wasSelected) await _stopSessionEvents();
    if (!_isCurrentSessionAdmin(generation, projectId)) return;

    final immediateDeleteCleanup =
        wasSelected && operation == PiSessionAdminOperation.delete;
    emit(
      state.copyWith(
        sessionAdminSessionId: sessionId,
        sessionAdminOperation: operation,
        sessionAdminLoading: true,
        sessionAdminError: null,
        selectedSessionId: immediateDeleteCleanup
            ? null
            : state.selectedSessionId,
        messages: immediateDeleteCleanup ? const <PiMessage>[] : state.messages,
        conversationLoading: wasSelected && !immediateDeleteCleanup,
        sessionTreeLoading: wasSelected && !immediateDeleteCleanup,
        sessionTree: immediateDeleteCleanup ? null : state.sessionTree,
        sessionTreeMutationOperation: null,
        sessionTreeMutationLoading: false,
        eventStatus: wasSelected
            ? WorkspaceEventStatus.idle
            : state.eventStatus,
        sending: wasSelected ? false : state.sending,
        stopping: wasSelected ? false : state.stopping,
        promptError: wasSelected ? null : state.promptError,
        statusMessage: switch (operation) {
          PiSessionAdminOperation.rename => 'Renaming the Pi session…',
          PiSessionAdminOperation.clearName =>
            'Clearing the custom session name…',
          PiSessionAdminOperation.autoName =>
            'Generating a bounded session name with the current model…',
          PiSessionAdminOperation.delete =>
            'Deleting the confirmed Pi session…',
        },
      ),
    );

    PiSessionAdminResult? result;
    Object? invocationError;
    try {
      result = await invoke(_newCommandId('session-admin'), projectId);
    } catch (error, stackTrace) {
      invocationError = error;
      logE(
        'Pi Node session administration failed before an outcome',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (!_isCurrentSessionAdmin(generation, projectId)) return;

    var provisionalSessions = state.sessions;
    var outcomeError = invocationError == null
        ? null
        : _service.describeError(invocationError);
    var deleteSucceeded = false;
    var reparentedChildCount = 0;
    switch (result) {
      case PiSessionAdminUpdated(:final session):
        provisionalSessions = _replaceSession(provisionalSessions, session);
      case PiSessionAdminDeleted(
        sessionId: final deletedSessionId,
        reparentedChildCount: final childCount,
      ):
        deleteSucceeded = true;
        reparentedChildCount = childCount;
        provisionalSessions = provisionalSessions
            .where((session) => session.id != deletedSessionId)
            .toList(growable: false);
      case PiSessionAdminRejected(:final error):
        outcomeError = _service.describeError(error);
      case PiSessionAdminUncertain(:final error):
        outcomeError =
            '${_service.describeError(error)} The session action outcome is uncertain; authoritative state was requested.';
      case null:
        break;
    }

    try {
      final sessions = await _service.loadSessions(projectId);
      if (!_isCurrentSessionAdmin(generation, projectId)) return;
      final targetExists = sessions.any((session) => session.id == sessionId);
      final canRestoreDeletedSelection =
          immediateDeleteCleanup && !deleteSucceeded && targetExists;
      final canRestoreUpdatedSelection =
          wasSelected &&
          operation != PiSessionAdminOperation.delete &&
          state.selectedSessionId == sessionId &&
          targetExists;
      final restoreTarget =
          canRestoreDeletedSelection || canRestoreUpdatedSelection;
      PiSessionHistoryPage? history;
      PiSessionTree? tree;
      PiSessionStats? stats;
      if (restoreTarget && !project.trust.requiresApproval) {
        final restored = await Future.wait<Object>(<Future<Object>>[
          _service.loadSessionHistory(
            projectId: projectId,
            sessionId: sessionId,
            limit: 50,
          ),
          _service.loadSessionTree(projectId, sessionId),
          _service.loadSessionStats(projectId, sessionId),
        ]);
        if (!_isCurrentSessionAdmin(generation, projectId)) return;
        history = restored[0] as PiSessionHistoryPage;
        tree = restored[1] as PiSessionTree;
        stats = restored[2] as PiSessionStats;
      }
      final selectedOtherSession =
          state.selectedSessionId != null &&
          state.selectedSessionId != sessionId;
      emit(
        state.copyWith(
          sessions: history == null
              ? sessions
              : _replaceSession(sessions, history.summary),
          selectedSessionId: history != null
              ? sessionId
              : selectedOtherSession
              ? state.selectedSessionId
              : null,
          messages: history != null
              ? history.messages
              : selectedOtherSession
              ? state.messages
              : const <PiMessage>[],
          historyCursor: history?.nextCursor,
          activeBranchRevision: history?.activeBranchRevision,
          treeRevision: history?.treeRevision,
          historyHasMore: history?.hasMore ?? false,
          historyLoading: false,
          sessionStats: history != null
              ? stats
              : selectedOtherSession
              ? state.sessionStats
              : null,
          sessionStatsLoading: false,
          sessionStatsError: history != null ? null : state.sessionStatsError,
          conversationLoading: false,
          sessionTreeLoading: false,
          sessionTree: history != null
              ? tree
              : selectedOtherSession
              ? state.sessionTree
              : null,
          sessionTreeError: history != null ? null : state.sessionTreeError,
          eventStatus: history != null
              ? WorkspaceEventStatus.idle
              : selectedOtherSession
              ? state.eventStatus
              : WorkspaceEventStatus.idle,
          sessionAdminSessionId: null,
          sessionAdminOperation: null,
          sessionAdminLoading: false,
          sessionAdminError: outcomeError,
          sessionError: null,
          conversationError: history != null ? null : state.conversationError,
          statusMessage: outcomeError != null
              ? 'Session action finished with an error; sessions were refreshed.'
              : deleteSucceeded
              ? reparentedChildCount == 0
                    ? 'Pi session deleted.'
                    : 'Pi session deleted and $reparentedChildCount child sessions reparented.'
              : 'Pi session updated and refreshed.',
        ),
      );
      if (history != null) await _startSessionEvents(sessionId, emit);
    } catch (error, stackTrace) {
      if (!_isCurrentSessionAdmin(generation, projectId)) return;
      logE(
        'Refreshing sessions after administration failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          sessions: provisionalSessions,
          conversationLoading: false,
          sessionTreeLoading: false,
          sessionAdminSessionId: null,
          sessionAdminOperation: null,
          sessionAdminLoading: false,
          sessionAdminError:
              outcomeError ??
              '${_service.describeError(error)} Authoritative session refresh failed.',
          statusMessage: 'Session action could not be reconciled with Pi Node.',
        ),
      );
    } finally {
      if (generation == _sessionAdminGeneration) {
        _sessionAdminInFlight = false;
      }
    }
  }

  Future<void> _onSessionTreeNavigated(
    WorkspaceSessionTreeNavigated event,
    Emitter<WorkspaceModel> emit,
  ) => _runSessionTreeMutation(
    operation: PiSessionTreeMutationOperation.navigate,
    entryId: event.entryId,
    emit: emit,
    invoke: (commandId, projectId, sessionId, revision) =>
        _service.navigateSessionTree(
          commandId: commandId,
          projectId: projectId,
          sessionId: sessionId,
          expectedAdminRevision: revision,
          entryId: event.entryId,
        ),
  );

  Future<void> _onSessionForked(
    WorkspaceSessionForked event,
    Emitter<WorkspaceModel> emit,
  ) => _runSessionTreeMutation(
    operation: PiSessionTreeMutationOperation.fork,
    entryId: event.userEntryId,
    emit: emit,
    invoke: (commandId, projectId, sessionId, revision) => _service.forkSession(
      commandId: commandId,
      projectId: projectId,
      sessionId: sessionId,
      expectedAdminRevision: revision,
      userEntryId: event.userEntryId,
    ),
  );

  Future<void> _onSessionCloned(
    WorkspaceSessionCloned event,
    Emitter<WorkspaceModel> emit,
  ) => _runSessionTreeMutation(
    operation: PiSessionTreeMutationOperation.clone,
    emit: emit,
    invoke: (commandId, projectId, sessionId, revision) =>
        _service.cloneSession(
          commandId: commandId,
          projectId: projectId,
          sessionId: sessionId,
          expectedAdminRevision: revision,
        ),
  );

  Future<void> _runSessionTreeMutation({
    required PiSessionTreeMutationOperation operation,
    PiSessionTreeEntryId? entryId,
    required Emitter<WorkspaceModel> emit,
    required Future<PiSessionTreeMutationResult> Function(
      PiCommandId commandId,
      PiProjectId projectId,
      PiSessionId sessionId,
      PiSessionAdminRevision expectedAdminRevision,
    )
    invoke,
  }) async {
    final project = state.selectedProject;
    final sourceSessionId = state.selectedSessionId;
    final tree = state.sessionTree;
    final selected = _selectedSession(state);
    if (_sessionTreeMutationInFlight ||
        _sessionAdminInFlight ||
        state.conversationLoading ||
        _closing) {
      return;
    }
    if (project == null ||
        sourceSessionId == null ||
        tree == null ||
        selected == null ||
        tree.sessionId != sourceSessionId) {
      emit(
        state.copyWith(
          sessionTreeError:
              'Reload the selected session before using branch actions.',
          statusMessage: 'Branch actions require current session state.',
        ),
      );
      return;
    }
    if (project.trust.requiresApproval) {
      emit(
        state.copyWith(
          sessionTreeError:
              'Approve project trust before changing the session branch.',
          statusMessage: 'Project trust approval is required.',
        ),
      );
      return;
    }
    if (selected.isRunning || state.sending || state.stopping) {
      emit(
        state.copyWith(
          sessionTreeError:
              'Wait for Pi to become idle before changing branches.',
          statusMessage: 'The active session is busy.',
        ),
      );
      return;
    }
    final selectedNode = entryId == null ? null : tree.nodeById(entryId);
    if (operation == PiSessionTreeMutationOperation.fork &&
        selectedNode?.canFork != true) {
      emit(
        state.copyWith(
          sessionTreeError: 'Fork requires a current user-message entry.',
          statusMessage: 'The selected entry cannot be forked.',
        ),
      );
      return;
    }
    if (operation == PiSessionTreeMutationOperation.navigate &&
        selectedNode == null) {
      emit(
        state.copyWith(
          sessionTreeError: 'The selected branch entry is no longer available.',
          statusMessage: 'Refresh the session tree.',
        ),
      );
      return;
    }
    if (operation == PiSessionTreeMutationOperation.clone &&
        !tree.canCloneActiveBranch) {
      emit(
        state.copyWith(
          sessionTreeError: 'The active branch is not eligible for cloning.',
          statusMessage: 'Nothing to clone yet.',
        ),
      );
      return;
    }

    _sessionTreeMutationInFlight = true;
    final generation = ++_sessionTreeMutationGeneration;
    final projectId = project.identity.projectId;
    _sessionListGeneration += 1;
    _sessionLoadGeneration += 1;
    _promptGeneration += 1;
    _activePromptCommandId = null;
    await _stopSessionEvents();
    if (!_isCurrentSessionTreeMutation(generation, projectId)) return;
    emit(
      state.copyWith(
        sessionTreeMutationOperation: operation,
        sessionTreeMutationLoading: true,
        sessionTreeError: null,
        conversationError: null,
        eventStatus: WorkspaceEventStatus.idle,
        statusMessage: switch (operation) {
          PiSessionTreeMutationOperation.navigate =>
            'Changing the active session branch…',
          PiSessionTreeMutationOperation.fork =>
            'Forking the selected user message into a new session…',
          PiSessionTreeMutationOperation.clone =>
            'Cloning the active branch into a new session…',
        },
      ),
    );

    PiSessionTreeMutationResult? result;
    Object? invocationError;
    try {
      result = await invoke(
        _newCommandId('session-tree-${operation.name}'),
        projectId,
        sourceSessionId,
        tree.adminRevision,
      );
    } catch (error, stackTrace) {
      invocationError = error;
      logE(
        'Pi Node session tree mutation failed before an outcome',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (!_isCurrentSessionTreeMutation(generation, projectId)) return;

    PiSessionId targetSessionId = sourceSessionId;
    String? editorText;
    String? outcomeError = invocationError == null
        ? null
        : _service.describeError(invocationError);
    switch (result) {
      case PiSessionTreeMutationUpdated(
        session: final updatedSession,
        editorText: final restoredText,
      ):
        targetSessionId = updatedSession.summary.id;
        editorText = restoredText;
      case PiSessionTreeMutationRejected(:final error):
        outcomeError = _service.describeError(error);
      case PiSessionTreeMutationUncertain(:final error):
        outcomeError =
            '${_service.describeError(error)} The branch action outcome is uncertain; authoritative state was requested.';
      case null:
        break;
    }

    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        _service.loadSessionHistory(
          projectId: projectId,
          sessionId: targetSessionId,
          limit: 50,
        ),
        _service.loadSessionTree(projectId, targetSessionId),
        _service.loadSessions(projectId),
        _service.loadSessionStats(projectId, targetSessionId),
      ]);
      if (!_isCurrentSessionTreeMutation(generation, projectId)) return;
      final history = results[0] as PiSessionHistoryPage;
      final refreshedTree = results[1] as PiSessionTree;
      final sessions = results[2] as List<PiSessionSummary>;
      final stats = results[3] as PiSessionStats;
      final appliedDraft = result is PiSessionTreeMutationUpdated
          ? (editorText ?? '')
          : null;
      emit(
        state.copyWith(
          sessions: _replaceSession(sessions, history.summary),
          selectedSessionId: targetSessionId,
          messages: history.messages,
          historyCursor: history.nextCursor,
          activeBranchRevision: history.activeBranchRevision,
          treeRevision: history.treeRevision,
          historyHasMore: history.hasMore,
          historyLoading: false,
          sessionStats: stats,
          sessionStatsLoading: false,
          sessionStatsError: null,
          sessionTree: refreshedTree,
          conversationLoading: false,
          sessionTreeLoading: false,
          sessionTreeMutationOperation: null,
          sessionTreeMutationLoading: false,
          sessionTreeError: outcomeError,
          conversationError: null,
          promptError: null,
          composerDraft: appliedDraft ?? state.composerDraft,
          composerDraftGeneration: appliedDraft == null
              ? state.composerDraftGeneration
              : state.composerDraftGeneration + 1,
          eventStatus: WorkspaceEventStatus.idle,
          statusMessage: outcomeError != null
              ? 'Branch action finished with an error; authoritative state was refreshed.'
              : switch (operation) {
                  PiSessionTreeMutationOperation.navigate =>
                    'Active branch updated. Edit and submit the restored prompt when ready.',
                  PiSessionTreeMutationOperation.fork =>
                    'Forked session selected. The source prompt is ready to edit.',
                  PiSessionTreeMutationOperation.clone =>
                    'Cloned session selected.',
                },
        ),
      );
      await _startSessionEvents(targetSessionId, emit);
    } catch (error, stackTrace) {
      if (!_isCurrentSessionTreeMutation(generation, projectId)) return;
      logE(
        'Authoritative refresh after a session tree mutation failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          sessionTreeMutationOperation: null,
          sessionTreeMutationLoading: false,
          sessionTreeLoading: false,
          eventStatus: WorkspaceEventStatus.error,
          sessionTreeError:
              outcomeError ??
              '${_service.describeError(error)} Authoritative branch refresh failed.',
          statusMessage:
              'The branch action could not be reconciled with Pi Node.',
        ),
      );
    } finally {
      if (generation == _sessionTreeMutationGeneration) {
        _sessionTreeMutationInFlight = false;
      }
    }
  }

  Future<void> _onOlderHistoryRequested(
    WorkspaceOlderHistoryRequested event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final project = state.selectedProject;
    final sessionId = state.selectedSessionId;
    final cursor = state.historyCursor;
    final activeRevision = state.activeBranchRevision;
    final treeRevision = state.treeRevision;
    if (_historyInFlight ||
        _closing ||
        project == null ||
        sessionId == null ||
        cursor == null ||
        !state.historyHasMore ||
        activeRevision == null ||
        treeRevision == null) {
      return;
    }

    _historyInFlight = true;
    final generation = _sessionLoadGeneration;
    emit(
      state.copyWith(
        historyLoading: true,
        conversationError: null,
        statusMessage: 'Loading older session history…',
      ),
    );
    try {
      final page = await _service.loadSessionHistory(
        projectId: project.identity.projectId,
        sessionId: sessionId,
        cursor: cursor,
        limit: 50,
        expectedActiveBranchRevision: activeRevision,
        expectedTreeRevision: treeRevision,
      );
      if (!_isCurrentSessionLoad(generation, sessionId)) return;
      final existingIds = state.messages.map((message) => message.id).toSet();
      final older = page.messages
          .where((message) => !existingIds.contains(message.id))
          .toList(growable: false);
      emit(
        state.copyWith(
          sessions: _replaceSession(state.sessions, page.summary),
          messages: <PiMessage>[...older, ...state.messages],
          historyCursor: page.nextCursor,
          activeBranchRevision: page.activeBranchRevision,
          treeRevision: page.treeRevision,
          historyHasMore: page.hasMore,
          historyLoading: false,
          conversationError: null,
          statusMessage: page.hasMore
              ? '${older.length} older messages loaded.'
              : 'The complete active-branch history is loaded.',
        ),
      );
    } catch (error, stackTrace) {
      if (!_isCurrentSessionLoad(generation, sessionId)) return;
      logE(
        'Loading older Pi Node session history failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          historyLoading: false,
          conversationError: _service.describeError(error),
          statusMessage: 'Older history could not be loaded.',
        ),
      );
    } finally {
      _historyInFlight = false;
    }
  }

  Future<void> _onSessionStatsRefreshed(
    WorkspaceSessionStatsRefreshed event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final project = state.selectedProject;
    final sessionId = state.selectedSessionId;
    if (_statsInFlight || _closing || project == null || sessionId == null) {
      return;
    }
    _statsInFlight = true;
    final generation = _sessionLoadGeneration;
    emit(
      state.copyWith(
        sessionStatsLoading: true,
        sessionStatsError: null,
        statusMessage: 'Refreshing full-session statistics…',
      ),
    );
    try {
      final stats = await _service.loadSessionStats(
        project.identity.projectId,
        sessionId,
      );
      if (!_isCurrentSessionLoad(generation, sessionId)) return;
      emit(
        state.copyWith(
          sessionStats: stats,
          sessionStatsLoading: false,
          sessionStatsError: null,
          statusMessage: 'Full-session statistics refreshed.',
        ),
      );
    } catch (error, stackTrace) {
      if (!_isCurrentSessionLoad(generation, sessionId)) return;
      logE(
        'Refreshing Pi Node session statistics failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          sessionStatsLoading: false,
          sessionStatsError: _service.describeError(error),
          statusMessage: 'Session statistics refresh failed.',
        ),
      );
    } finally {
      _statsInFlight = false;
    }
  }

  Future<void> _onSessionExportRequested(
    WorkspaceSessionExportRequested event,
    Emitter<WorkspaceModel> emit,
  ) async {
    final project = state.selectedProject;
    final sessionId = state.selectedSessionId;
    if (_exportInFlight ||
        _closing ||
        project == null ||
        sessionId == null ||
        _selectedSession(state)?.isRunning == true) {
      return;
    }
    _exportInFlight = true;
    _exportCancellationRequested = false;
    final generation = ++_exportGeneration;
    emit(
      state.copyWith(
        sessionExportLoading: true,
        sessionExportFormat: event.format,
        sessionExportSavedBytes: 0,
        sessionExportTotalBytes: 0,
        lastExportFileName: null,
        sessionExportError: null,
        statusMessage:
            'Preparing a streamed ${event.format.name.toUpperCase()} export…',
      ),
    );
    try {
      final handle = await _service.exportSession(
        projectId: project.identity.projectId,
        sessionId: sessionId,
        format: event.format,
        expectedActiveBranchRevision: state.activeBranchRevision,
        expectedTreeRevision: state.treeRevision,
      );
      if (!_isCurrentExport(generation, sessionId) ||
          _exportCancellationRequested) {
        await handle.cancel();
        if (_isCurrentExport(generation, sessionId)) {
          throw const PiNodeException(
            PiNodeErrorCode.cancelled,
            retryable: false,
          );
        }
        return;
      }
      _activeExportHandle = handle;
      emit(
        state.copyWith(
          sessionExportTotalBytes: handle.totalBytes,
          statusMessage: 'Choose where to save ${handle.fileName}.',
        ),
      );
      final result = await _exportSaver.save(
        handle,
        onProgress: (savedBytes, totalBytes) {
          if (!_isCurrentExport(generation, sessionId)) return;
          emit(
            state.copyWith(
              sessionExportSavedBytes: savedBytes,
              sessionExportTotalBytes: totalBytes,
              statusMessage: 'Exporting $savedBytes of $totalBytes bytes…',
            ),
          );
        },
      );
      if (!_isCurrentExport(generation, sessionId)) return;
      emit(
        state.copyWith(
          sessionExportLoading: false,
          sessionExportFormat: null,
          sessionExportSavedBytes: result.saved ? handle.totalBytes : 0,
          sessionExportTotalBytes: result.saved ? handle.totalBytes : 0,
          lastExportFileName: result.saved ? result.fileName : null,
          sessionExportError: null,
          statusMessage: result.saved
              ? '${result.fileName} exported with SHA-256 verification.'
              : 'Session export cancelled.',
        ),
      );
    } catch (error, stackTrace) {
      if (!_isCurrentExport(generation, sessionId)) return;
      final cancelled =
          error is PiNodeException && error.code == PiNodeErrorCode.cancelled;
      if (!cancelled) {
        logE(
          'Saving a Pi Node session export failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
      emit(
        state.copyWith(
          sessionExportLoading: false,
          sessionExportFormat: null,
          sessionExportSavedBytes: 0,
          sessionExportTotalBytes: 0,
          sessionExportError: cancelled
              ? null
              : _describeExportSaveError(error),
          statusMessage: cancelled
              ? 'Session export cancelled.'
              : 'Session export failed.',
        ),
      );
    } finally {
      if (generation == _exportGeneration) {
        _activeExportHandle = null;
        _exportInFlight = false;
        _exportCancellationRequested = false;
      }
    }
  }

  Future<void> _onSessionExportCancelled(
    WorkspaceSessionExportCancelled event,
    Emitter<WorkspaceModel> emit,
  ) async {
    if (!_exportInFlight) return;
    _exportCancellationRequested = true;
    final handle = _activeExportHandle;
    await handle?.cancel();
    if (_closing || isClosed) return;
    emit(
      state.copyWith(
        sessionExportLoading: false,
        sessionExportFormat: null,
        sessionExportSavedBytes: 0,
        sessionExportTotalBytes: 0,
        sessionExportError: null,
        statusMessage: 'Session export cancellation requested.',
      ),
    );
  }

  String _describeExportSaveError(Object error) => switch (error) {
    PiSessionExportSaveException(:final code) => switch (code) {
      PiSessionExportSaveErrorCode.unsupported =>
        'This platform does not provide a streaming export destination.',
      PiSessionExportSaveErrorCode.writeFailed =>
        'The selected export destination could not be written.',
      PiSessionExportSaveErrorCode.integrityFailed =>
        'The exported byte count or digest did not match.',
    },
    _ => _service.describeError(error),
  };

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
      _sessionAdminGeneration += 1;
      _sessionAdminInFlight = false;
      _sessionTreeMutationGeneration += 1;
      _sessionTreeMutationInFlight = false;
      _promptGeneration += 1;
      _activePromptCommandId = null;
      await _cancelActiveExportForContextChange();
      await _stopSessionEvents();
      emit(
        state.copyWith(
          connection: snapshot,
          eventStatus: WorkspaceEventStatus.error,
          sessionAdminSessionId: null,
          sessionAdminOperation: null,
          sessionAdminLoading: false,
          sessionTreeMutationOperation: null,
          sessionTreeMutationLoading: false,
          sessionExportLoading: false,
          sessionExportFormat: null,
          sessionExportSavedBytes: 0,
          sessionExportTotalBytes: 0,
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
      final results = await Future.wait<Object>(<Future<Object>>[
        _service.loadSessionHistory(
          projectId: project.identity.projectId,
          sessionId: sessionId,
          limit: 50,
        ),
        _service.loadSessionTree(project.identity.projectId, sessionId),
        _service.loadSessions(project.identity.projectId),
        _service.loadSessionStats(project.identity.projectId, sessionId),
      ]);
      if (!_isCurrentEvent(eventGeneration, sessionId) ||
          sessionListGeneration != _sessionListGeneration) {
        return;
      }
      final history = results[0] as PiSessionHistoryPage;
      final tree = results[1] as PiSessionTree;
      final sessions = results[2] as List<PiSessionSummary>;
      final stats = results[3] as PiSessionStats;
      emit(
        state.copyWith(
          conversationLoading: false,
          sessionsLoading: false,
          sessions: _replaceSession(sessions, history.summary),
          messages: history.messages,
          historyCursor: history.nextCursor,
          activeBranchRevision: history.activeBranchRevision,
          treeRevision: history.treeRevision,
          historyHasMore: history.hasMore,
          historyLoading: false,
          sessionStats: stats,
          sessionStatsLoading: false,
          sessionTree: tree,
          sessionTreeLoading: false,
          eventStatus: WorkspaceEventStatus.listening,
          sessionError: null,
          sessionTreeError: null,
          conversationError: null,
          sessionStatsError: null,
          statusMessage: 'Conversation and statistics reconciled with Pi Node.',
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
          sessionTreeLoading: false,
          sessionStatsLoading: false,
          eventStatus: WorkspaceEventStatus.error,
          sessionTreeError: _service.describeError(error),
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

  Future<void> _cancelActiveExportForContextChange() async {
    _exportGeneration += 1;
    _exportInFlight = false;
    _exportCancellationRequested = true;
    final handle = _activeExportHandle;
    _activeExportHandle = null;
    await handle?.cancel();
    _exportCancellationRequested = false;
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

  bool _isCurrentSessionAdmin(int generation, PiProjectId projectId) =>
      !_closing &&
      !isClosed &&
      generation == _sessionAdminGeneration &&
      state.selectedProject?.identity.projectId == projectId;

  bool _isCurrentSessionTreeMutation(int generation, PiProjectId projectId) =>
      !_closing &&
      !isClosed &&
      generation == _sessionTreeMutationGeneration &&
      state.selectedProject?.identity.projectId == projectId;

  bool _isCurrentExport(int generation, PiSessionId sessionId) =>
      !_closing &&
      !isClosed &&
      generation == _exportGeneration &&
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
    _sessionAdminGeneration += 1;
    _sessionTreeMutationGeneration += 1;
    _promptGeneration += 1;
    _eventGeneration += 1;
    _exportGeneration += 1;
    final exportHandle = _activeExportHandle;
    _activeExportHandle = null;
    _exportInFlight = false;
    final future = Future.wait<void>(<Future<void>>[
      if (_sessionEventSubscription case final subscription?)
        subscription.cancel(),
      if (exportHandle != null) exportHandle.cancel(),
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
              adminRevision: session.adminRevision,
              hasCustomName: session.hasCustomName,
              parentSessionId: session.parentSessionId,
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
