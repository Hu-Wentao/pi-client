import 'dart:async';

import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/protocol/pi_protocol.dart';

final class FakePiNodeApi implements PiNodeApi {
  FakePiNodeApi({
    Iterable<PiSessionSummary> sessions = const <PiSessionSummary>[],
    Map<PiSessionId, PiSessionDetail> details =
        const <PiSessionId, PiSessionDetail>{},
    PiProject? defaultProject,
    Iterable<PiKnownProject> knownProjects = const <PiKnownProject>[],
  }) : sessions = List<PiSessionSummary>.of(sessions),
       details = Map<PiSessionId, PiSessionDetail>.of(details),
       defaultProject = defaultProject ?? fakeProject('/Projects/default'),
       knownProjects = List<PiKnownProject>.of(knownProjects);

  final StreamController<PiNodeConnectionSnapshot> _connectionStates =
      StreamController<PiNodeConnectionSnapshot>.broadcast(sync: true);
  final Map<PiSessionId, StreamController<PiSessionEvent>> _eventControllers =
      <PiSessionId, StreamController<PiSessionEvent>>{};

  List<PiSessionSummary> sessions;
  Map<PiSessionId, PiSessionDetail> details;
  PiProject defaultProject;
  List<PiKnownProject> knownProjects;
  Future<PiProjectBootstrap> Function()? projectBootstrapHandler;
  Future<PiDirectoryListing> Function(PiBrowseDirectoryRequest request)?
  browseDirectoryHandler;
  Future<PiProject> Function(PiValidateProjectRequest request)?
  validateProjectHandler;
  Future<List<PiKnownProject>> Function(int maxProjects)? knownProjectsHandler;
  Future<PiProject> Function(PiProjectTrustApproval approval)?
  approveProjectTrustHandler;
  Object? connectError;
  Future<PiSessionDetail> Function(PiSessionId sessionId)? getSessionHandler;
  Future<PiSessionDetail> Function(PiCreateSessionRequest request)?
  createSessionHandler;
  Future<PiCommandResult> Function(PiPromptCommand command)? promptHandler;
  Future<PiCommandResult> Function(PiAbortCommand command)? abortHandler;

  PiNodeConnectionSnapshot _connection =
      const PiNodeConnectionSnapshot.disconnected();
  int connectCalls = 0;
  int projectBootstrapCalls = 0;
  int browseDirectoryCalls = 0;
  int validateProjectCalls = 0;
  int knownProjectCalls = 0;
  int approveTrustCalls = 0;
  int listCalls = 0;
  int getCalls = 0;
  int createCalls = 0;
  int promptCalls = 0;
  int abortCalls = 0;
  int eventListenCalls = 0;
  int closeCalls = 0;
  PiPromptCommand? lastPrompt;
  PiAbortCommand? lastAbort;
  bool _closed = false;

  @override
  PiNodeConnectionSnapshot get connection => _connection;

  @override
  Stream<PiNodeConnectionSnapshot> get connectionStates =>
      _connectionStates.stream;

  @override
  Future<PiNodeConnectionSnapshot> connect() async {
    connectCalls += 1;
    _setConnection(const PiNodeConnectionSnapshot.connecting());
    final error = connectError;
    if (error != null) {
      _setConnection(const PiNodeConnectionSnapshot.disconnected());
      throw error;
    }
    final connected = PiNodeConnectionSnapshot.connected(
      PiProtocolVersion(0, 1, 0),
      capabilities: const <PiProtocolCapability>{
        PiProtocolCapability.sessionRead,
        PiProtocolCapability.sessionCreate,
        PiProtocolCapability.promptCommand,
        PiProtocolCapability.abortCommand,
        PiProtocolCapability.sessionEvents,
        PiProtocolCapability.projectDiscovery,
        PiProtocolCapability.projectTrust,
      },
    );
    _setConnection(connected);
    return connected;
  }

  @override
  Future<PiProjectBootstrap> getProjectBootstrap() async {
    projectBootstrapCalls += 1;
    final handler = projectBootstrapHandler;
    return handler?.call() ??
        PiProjectBootstrap(
          homeDirectory: '/Projects',
          defaultProject: defaultProject,
        );
  }

  @override
  Future<PiDirectoryListing> browseDirectory(
    PiBrowseDirectoryRequest request,
  ) async {
    browseDirectoryCalls += 1;
    final handler = browseDirectoryHandler;
    return handler?.call(request) ??
        PiDirectoryListing(
          canonicalDirectory: request.directory,
          parentDirectory: '/',
          children: const <PiDirectoryEntry>[],
          truncated: false,
        );
  }

  @override
  Future<PiProject> validateProject(PiValidateProjectRequest request) async {
    validateProjectCalls += 1;
    final handler = validateProjectHandler;
    return handler?.call(request) ?? fakeProject(request.candidateDirectory);
  }

  @override
  Future<List<PiKnownProject>> listKnownProjects({int maxProjects = 24}) async {
    knownProjectCalls += 1;
    final handler = knownProjectsHandler;
    if (handler != null) return handler(maxProjects);
    return List<PiKnownProject>.unmodifiable(knownProjects.take(maxProjects));
  }

  @override
  Future<PiProject> approveProjectTrust(PiProjectTrustApproval approval) async {
    approveTrustCalls += 1;
    final handler = approveProjectTrustHandler;
    if (handler != null) return handler(approval);
    final current = <PiProject>[
      defaultProject,
      ...knownProjects.map((item) => item.project),
    ].firstWhere((project) => project.identity.projectId == approval.projectId);
    final trusted = fakeProject(
      current.identity.canonicalWorkingDirectory,
      trustStatus: PiProjectTrustStatus.trusted,
    );
    if (defaultProject.identity.projectId == approval.projectId) {
      defaultProject = trusted;
    }
    return trusted;
  }

  @override
  Future<List<PiSessionSummary>> listSessions(PiProjectId projectId) async {
    listCalls += 1;
    return List<PiSessionSummary>.unmodifiable(sessions);
  }

  @override
  Future<PiSessionDetail> getSession(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) async {
    getCalls += 1;
    final handler = getSessionHandler;
    if (handler != null) return handler(sessionId);
    final detail = details[sessionId];
    if (detail == null) {
      throw const PiNodeException(PiNodeErrorCode.notFound, retryable: false);
    }
    return detail;
  }

  @override
  Future<PiSessionDetail> createSession(PiCreateSessionRequest request) async {
    createCalls += 1;
    final handler = createSessionHandler;
    if (handler != null) return handler(request);
    final now = DateTime.utc(2026, 1, 1, 12);
    final project = <PiProject>[
      defaultProject,
      ...knownProjects.map((item) => item.project),
    ].firstWhere((item) => item.identity.projectId == request.projectId);
    final summary = PiSessionSummary(
      id: PiSessionId('created-$createCalls'),
      title: 'New Pi session',
      workingDirectory: project.identity.canonicalWorkingDirectory,
      createdAt: now,
      updatedAt: now,
      isRunning: false,
      hasUnread: false,
    );
    final detail = PiSessionDetail(
      summary: summary,
      messages: const <PiMessage>[],
    );
    sessions = <PiSessionSummary>[summary, ...sessions];
    details[summary.id] = detail;
    return detail;
  }

  @override
  Future<PiCommandResult> prompt(PiPromptCommand command) async {
    promptCalls += 1;
    lastPrompt = command;
    final handler = promptHandler;
    return handler?.call(command) ?? PiCommandAccepted(command.commandId);
  }

  @override
  Future<PiCommandResult> abort(PiAbortCommand command) async {
    abortCalls += 1;
    lastAbort = command;
    final handler = abortHandler;
    return handler?.call(command) ?? PiCommandAccepted(command.commandId);
  }

  @override
  Stream<PiSessionEvent> sessionEvents(PiSessionId sessionId) {
    eventListenCalls += 1;
    return _eventControllers
        .putIfAbsent(
          sessionId,
          () => StreamController<PiSessionEvent>.broadcast(sync: true),
        )
        .stream;
  }

  void emitEvent(PiSessionEvent event) {
    _eventControllers
        .putIfAbsent(
          event.sessionId,
          () => StreamController<PiSessionEvent>.broadcast(sync: true),
        )
        .add(event);
  }

  void emitConnection(PiNodeConnectionSnapshot snapshot) =>
      _setConnection(snapshot);

  void updateDetail(PiSessionDetail detail) {
    details[detail.summary.id] = detail;
    final index = sessions.indexWhere(
      (session) => session.id == detail.summary.id,
    );
    sessions = index == -1
        ? <PiSessionSummary>[detail.summary, ...sessions]
        : <PiSessionSummary>[
            ...sessions.take(index),
            detail.summary,
            ...sessions.skip(index + 1),
          ];
  }

  Future<void> closeEventStream(PiSessionId sessionId) async {
    await _eventControllers[sessionId]?.close();
  }

  @override
  Future<void> close() async {
    closeCalls += 1;
    if (_closed) return;
    _closed = true;
    _connection = const PiNodeConnectionSnapshot.closed();
    for (final controller in _eventControllers.values) {
      if (!controller.isClosed) await controller.close();
    }
    await _connectionStates.close();
  }

  void _setConnection(PiNodeConnectionSnapshot snapshot) {
    _connection = snapshot;
    if (!_connectionStates.isClosed) _connectionStates.add(snapshot);
  }
}

PiProject fakeProject(
  String canonicalWorkingDirectory, {
  PiProjectTrustStatus trustStatus = PiProjectTrustStatus.notRequired,
}) {
  final slug = canonicalWorkingDirectory.replaceAll(
    RegExp(r'[^A-Za-z0-9]+'),
    '-',
  );
  final reasons = trustStatus == PiProjectTrustStatus.notRequired
      ? const <PiProjectTrustReason>[]
      : <PiProjectTrustReason>[
          PiProjectTrustReason.piSettings,
          if (trustStatus == PiProjectTrustStatus.trusted)
            PiProjectTrustReason.savedApproval,
          if (trustStatus == PiProjectTrustStatus.denied)
            PiProjectTrustReason.savedDenial,
        ];
  return PiProject(
    identity: PiProjectIdentity(
      projectId: PiProjectId('project-$slug'),
      canonicalWorkingDirectory: canonicalWorkingDirectory,
      isGitRepository: false,
      isLinkedWorktree: false,
      isDetachedHead: false,
      worktreeId: PiWorktreeId('worktree-$slug'),
      mainProjectId: PiMainProjectId('main-$slug'),
    ),
    trust: PiProjectTrustSnapshot(
      status: trustStatus,
      reasons: reasons,
      revision: PiProjectTrustRevision('revision-$slug-${trustStatus.name}'),
    ),
  );
}

PiSessionSummary fakeSession({
  required String id,
  required String title,
  required String workingDirectory,
  bool isRunning = false,
  bool hasUnread = false,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final created = createdAt ?? DateTime.utc(2026, 1, 1, 8);
  return PiSessionSummary(
    id: PiSessionId(id),
    title: title,
    workingDirectory: workingDirectory,
    createdAt: created,
    updatedAt: updatedAt ?? created.add(const Duration(minutes: 5)),
    isRunning: isRunning,
    hasUnread: hasUnread,
  );
}

PiMessage fakeMessage({
  required String id,
  required PiMessageRole role,
  required String text,
  bool isStreaming = false,
  DateTime? createdAt,
}) => PiMessage(
  id: PiMessageId(id),
  role: role,
  text: text,
  createdAt: createdAt ?? DateTime.utc(2026, 1, 1, 9),
  isStreaming: isStreaming,
);

PiSessionDetail fakeDetail(
  PiSessionSummary summary, {
  Iterable<PiMessage> messages = const <PiMessage>[],
}) => PiSessionDetail(summary: summary, messages: messages);
