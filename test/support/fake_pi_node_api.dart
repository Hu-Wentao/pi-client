import 'dart:async';
import 'dart:typed_data';

import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/protocol/pi_protocol.dart';

final class FakePiNodeApi implements PiNodeApi {
  FakePiNodeApi({
    Iterable<PiSessionSummary> sessions = const <PiSessionSummary>[],
    Map<PiSessionId, PiSessionDetail> details =
        const <PiSessionId, PiSessionDetail>{},
    Map<PiSessionId, PiSessionTree> trees =
        const <PiSessionId, PiSessionTree>{},
    PiProject? defaultProject,
    Iterable<PiKnownProject> knownProjects = const <PiKnownProject>[],
  }) : sessions = List<PiSessionSummary>.of(sessions),
       details = Map<PiSessionId, PiSessionDetail>.of(details),
       trees = <PiSessionId, PiSessionTree>{
         for (final entry in details.entries) entry.key: fakeTree(entry.value),
         ...trees,
       },
       defaultProject = defaultProject ?? fakeProject('/Projects/default'),
       knownProjects = List<PiKnownProject>.of(knownProjects);

  final StreamController<PiNodeConnectionSnapshot> _connectionStates =
      StreamController<PiNodeConnectionSnapshot>.broadcast(sync: true);
  final Map<PiSessionId, StreamController<PiSessionEvent>> _eventControllers =
      <PiSessionId, StreamController<PiSessionEvent>>{};

  List<PiSessionSummary> sessions;
  Map<PiSessionId, PiSessionDetail> details;
  Map<PiSessionId, PiSessionTree> trees;
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
  Future<PiSessionTree> Function(PiProjectId projectId, PiSessionId sessionId)?
  getSessionTreeHandler;
  Future<PiSessionHistoryPage> Function(PiSessionHistoryRequest request)?
  getSessionHistoryHandler;
  Future<PiSessionStats> Function(PiProjectId projectId, PiSessionId sessionId)?
  getSessionStatsHandler;
  Future<PiSessionExportHandle> Function(PiSessionExportRequest request)?
  exportSessionHandler;
  Future<PiMessageContentHandle> Function(PiMessageContentRequest request)?
  messageContentHandler;
  Future<PiSessionTreeMutationResult> Function(
    PiNavigateSessionTreeCommand command,
  )?
  navigateSessionTreeHandler;
  Future<PiSessionTreeMutationResult> Function(PiForkSessionCommand command)?
  forkSessionHandler;
  Future<PiSessionTreeMutationResult> Function(PiCloneSessionCommand command)?
  cloneSessionHandler;
  Future<PiSessionAdminResult> Function(PiRenameSessionCommand command)?
  renameSessionHandler;
  Future<PiSessionAdminResult> Function(PiClearSessionNameCommand command)?
  clearSessionNameHandler;
  Future<PiSessionAdminResult> Function(PiAutoNameSessionCommand command)?
  autoNameSessionHandler;
  Future<PiSessionAdminResult> Function(PiDeleteSessionCommand command)?
  deleteSessionHandler;
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
  int treeCalls = 0;
  int historyCalls = 0;
  int statsCalls = 0;
  int exportCalls = 0;
  int messageContentCalls = 0;
  int navigateTreeCalls = 0;
  int forkCalls = 0;
  int cloneCalls = 0;
  int renameCalls = 0;
  int clearNameCalls = 0;
  int autoNameCalls = 0;
  int deleteCalls = 0;
  int promptCalls = 0;
  int abortCalls = 0;
  int eventListenCalls = 0;
  int closeCalls = 0;
  PiPromptCommand? lastPrompt;
  PiAbortCommand? lastAbort;
  PiSessionAdminCommand? lastSessionAdminCommand;
  PiSessionTreeMutationCommand? lastSessionTreeMutationCommand;
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
      PiProtocolVersion(0, 2, 0),
      capabilities: const <PiProtocolCapability>{
        PiProtocolCapability.sessionRead,
        PiProtocolCapability.sessionCreate,
        PiProtocolCapability.promptCommand,
        PiProtocolCapability.abortCommand,
        PiProtocolCapability.sessionEvents,
        PiProtocolCapability.projectDiscovery,
        PiProtocolCapability.projectTrust,
        PiProtocolCapability.sessionAdmin,
        PiProtocolCapability.sessionTree,
        PiProtocolCapability.richConversation,
        PiProtocolCapability.messageContent,
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
    if (handler != null) {
      final detail = await handler(sessionId);
      details[sessionId] = detail;
      trees[sessionId] = fakeTree(detail);
      return detail;
    }
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
      adminRevision: PiSessionAdminRevision('revision-created-$createCalls-1'),
      hasCustomName: false,
    );
    final detail = PiSessionDetail(
      summary: summary,
      conversation: PiConversationSnapshot(
        sessionId: summary.id,
        entries: const <PiConversationEntry>[],
        lastEventSequence: 0,
      ),
    );
    sessions = <PiSessionSummary>[summary, ...sessions];
    details[summary.id] = detail;
    trees[summary.id] = fakeTree(detail);
    return detail;
  }

  @override
  Future<PiSessionTree> getSessionTree(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) async {
    treeCalls += 1;
    final handler = getSessionTreeHandler;
    if (handler != null) return handler(projectId, sessionId);
    final tree = trees[sessionId];
    if (tree != null) return tree;
    final summary = sessions.where((item) => item.id == sessionId).firstOrNull;
    if (summary == null) {
      throw const PiNodeException(PiNodeErrorCode.notFound, retryable: false);
    }
    return fakeTree(
      PiSessionDetail(
        summary: summary,
        conversation: PiConversationSnapshot(
          sessionId: summary.id,
          entries: const <PiConversationEntry>[],
          lastEventSequence: 0,
        ),
      ),
    );
  }

  @override
  Future<PiSessionHistoryPage> getSessionHistory(
    PiSessionHistoryRequest request,
  ) async {
    historyCalls += 1;
    final handler = getSessionHistoryHandler;
    if (handler != null) return handler(request);
    final detail = await getSession(request.projectId, request.sessionId);
    final end = request.cursor == null
        ? detail.messages.length
        : int.parse(request.cursor!.value);
    final start = (end - request.limit).clamp(0, end);
    final hasMore = start > 0;
    return PiSessionHistoryPage(
      summary: detail.summary,
      conversation: PiConversationPage(
        sessionId: detail.summary.id,
        entries: detail.conversation.entries.sublist(start, end),
        nextCursor: hasMore ? PiSessionHistoryCursor('$start') : null,
        hasMore: hasMore,
        activeBranchRevision: PiSessionBranchRevision(
          'active-${detail.summary.adminRevision.value}',
        ),
        treeRevision: PiSessionTreeRevision(
          'tree-${detail.summary.adminRevision.value}',
        ),
        lastEventSequence: detail.conversation.lastEventSequence,
      ),
    );
  }

  @override
  Future<PiMessageContentHandle> getMessageContent(
    PiMessageContentRequest request,
  ) async {
    messageContentCalls += 1;
    final handler = messageContentHandler;
    if (handler != null) return handler(request);
    throw const PiNodeException(PiNodeErrorCode.notFound, retryable: false);
  }

  @override
  Future<PiSessionStats> getSessionStats(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) async {
    statsCalls += 1;
    final handler = getSessionStatsHandler;
    if (handler != null) return handler(projectId, sessionId);
    final detail = details[sessionId];
    final summary =
        detail?.summary ??
        sessions.where((item) => item.id == sessionId).firstOrNull;
    if (summary == null) {
      throw const PiNodeException(PiNodeErrorCode.notFound, retryable: false);
    }
    final messages = detail?.messages ?? const <PiMessage>[];
    final project = <PiProject>[
      defaultProject,
      ...knownProjects.map((item) => item.project),
    ].firstWhere((item) => item.identity.projectId == projectId);
    return PiSessionStats(
      projection: PiSessionSafeProjection(
        sessionFileName: '${sessionId.value}.jsonl',
        sessionId: sessionId,
        projectId: projectId,
        canonicalProjectDirectory: project.identity.canonicalWorkingDirectory,
        worktreeId: project.identity.worktreeId,
        mainProjectId: project.identity.mainProjectId,
        branch: project.identity.branch,
        isLinkedWorktree: project.identity.isLinkedWorktree,
        isDetachedHead: project.identity.isDetachedHead,
      ),
      userMessages: messages
          .where((message) => message.role == PiMessageRole.user)
          .length,
      assistantMessages: messages
          .where((message) => message.role == PiMessageRole.assistant)
          .length,
      toolCalls: 0,
      toolResults: messages
          .where((message) => message.role == PiMessageRole.tool)
          .length,
      totalMessages: messages.length,
      inputTokens: 0,
      outputTokens: 0,
      cacheReadTokens: 0,
      cacheWriteTokens: 0,
      totalTokens: 0,
      cost: 0,
      activeTime: Duration.zero,
    );
  }

  @override
  Future<PiSessionExportHandle> exportSession(
    PiSessionExportRequest request,
  ) async {
    exportCalls += 1;
    final handler = exportSessionHandler;
    if (handler != null) return handler(request);
    final bytes = Uint8List.fromList(
      (request.format == PiSessionExportFormat.html ? '<html></html>' : '{}\n')
          .codeUnits,
    );
    return FakePiSessionExportHandle(
      fileName: request.format == PiSessionExportFormat.html
          ? 'session.html'
          : 'session.jsonl',
      contentType: request.format == PiSessionExportFormat.html
          ? 'text/html; charset=utf-8'
          : 'application/x-ndjson',
      chunks: <Uint8List>[bytes],
    );
  }

  @override
  Future<PiSessionTreeMutationResult> navigateSessionTree(
    PiNavigateSessionTreeCommand command,
  ) async {
    navigateTreeCalls += 1;
    lastSessionTreeMutationCommand = command;
    final handler = navigateSessionTreeHandler;
    if (handler != null) return handler(command);
    final detail = details[command.sessionId]!;
    final tree = trees[command.sessionId]!;
    final node = tree.nodeById(command.entryId)!;
    return PiSessionTreeMutationUpdated(
      commandId: command.commandId,
      operation: PiSessionTreeMutationOperation.navigate,
      session: detail,
      tree: tree,
      editorText: node.canEditFromHere ? node.text : null,
    );
  }

  @override
  Future<PiSessionTreeMutationResult> forkSession(
    PiForkSessionCommand command,
  ) async {
    forkCalls += 1;
    lastSessionTreeMutationCommand = command;
    final handler = forkSessionHandler;
    if (handler != null) return handler(command);
    return _copySessionBranch(
      commandId: command.commandId,
      operation: PiSessionTreeMutationOperation.fork,
      sourceSessionId: command.sessionId,
      editorEntryId: command.userEntryId,
      newSessionId: PiSessionId('forked-$forkCalls'),
    );
  }

  @override
  Future<PiSessionTreeMutationResult> cloneSession(
    PiCloneSessionCommand command,
  ) async {
    cloneCalls += 1;
    lastSessionTreeMutationCommand = command;
    final handler = cloneSessionHandler;
    if (handler != null) return handler(command);
    return _copySessionBranch(
      commandId: command.commandId,
      operation: PiSessionTreeMutationOperation.clone,
      sourceSessionId: command.sessionId,
      newSessionId: PiSessionId('cloned-$cloneCalls'),
    );
  }

  @override
  Future<PiSessionAdminResult> renameSession(
    PiRenameSessionCommand command,
  ) async {
    renameCalls += 1;
    lastSessionAdminCommand = command;
    final handler = renameSessionHandler;
    if (handler != null) return handler(command);
    final current = sessions.firstWhere(
      (session) => session.id == command.sessionId,
    );
    final updated = _updatedSession(current, command.name, hasCustomName: true);
    _replaceSummary(updated);
    return PiSessionAdminUpdated(
      commandId: command.commandId,
      operation: PiSessionAdminOperation.rename,
      session: updated,
    );
  }

  @override
  Future<PiSessionAdminResult> clearSessionName(
    PiClearSessionNameCommand command,
  ) async {
    clearNameCalls += 1;
    lastSessionAdminCommand = command;
    final handler = clearSessionNameHandler;
    if (handler != null) return handler(command);
    final current = sessions.firstWhere(
      (session) => session.id == command.sessionId,
    );
    final detail = details[current.id];
    final fallback = detail?.messages
        .where((message) => message.role == PiMessageRole.user)
        .map((message) => message.text.trim())
        .firstOrNull;
    final updated = _updatedSession(
      current,
      fallback?.isNotEmpty == true ? fallback! : 'Untitled session',
      hasCustomName: false,
    );
    _replaceSummary(updated);
    return PiSessionAdminUpdated(
      commandId: command.commandId,
      operation: PiSessionAdminOperation.clearName,
      session: updated,
    );
  }

  @override
  Future<PiSessionAdminResult> autoNameSession(
    PiAutoNameSessionCommand command,
  ) async {
    autoNameCalls += 1;
    lastSessionAdminCommand = command;
    final handler = autoNameSessionHandler;
    if (handler != null) return handler(command);
    final current = sessions.firstWhere(
      (session) => session.id == command.sessionId,
    );
    final updated = _updatedSession(
      current,
      'Generated session name',
      hasCustomName: true,
    );
    _replaceSummary(updated);
    return PiSessionAdminUpdated(
      commandId: command.commandId,
      operation: PiSessionAdminOperation.autoName,
      session: updated,
    );
  }

  @override
  Future<PiSessionAdminResult> deleteSession(
    PiDeleteSessionCommand command,
  ) async {
    deleteCalls += 1;
    lastSessionAdminCommand = command;
    final handler = deleteSessionHandler;
    if (handler != null) return handler(command);
    final current = sessions.firstWhere(
      (session) => session.id == command.sessionId,
    );
    if (!command.confirmation.destructiveActionAcknowledged ||
        command.confirmation.sessionId != command.sessionId ||
        command.confirmation.adminRevision != current.adminRevision) {
      return PiSessionAdminRejected(
        commandId: command.commandId,
        operation: PiSessionAdminOperation.delete,
        error: const PiNodeException(
          PiNodeErrorCode.conflict,
          retryable: false,
        ),
      );
    }
    sessions = sessions
        .where((session) => session.id != command.sessionId)
        .toList(growable: false);
    details.remove(command.sessionId);
    trees.remove(command.sessionId);
    return PiSessionAdminDeleted(
      commandId: command.commandId,
      sessionId: command.sessionId,
      reparentedChildCount: 0,
    );
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
    trees[detail.summary.id] = fakeTree(detail);
    _replaceSummary(detail.summary);
  }

  PiSessionTreeMutationResult _copySessionBranch({
    required PiCommandId commandId,
    required PiSessionTreeMutationOperation operation,
    required PiSessionId sourceSessionId,
    required PiSessionId newSessionId,
    PiSessionTreeEntryId? editorEntryId,
  }) {
    final source = details[sourceSessionId]!;
    final now = DateTime.now().toUtc();
    final summary = PiSessionSummary(
      id: newSessionId,
      title: operation == PiSessionTreeMutationOperation.fork
          ? 'Forked session'
          : 'Cloned session',
      workingDirectory: source.summary.workingDirectory,
      createdAt: now,
      updatedAt: now,
      isRunning: false,
      hasUnread: false,
      adminRevision: PiSessionAdminRevision('revision-${newSessionId.value}-1'),
      hasCustomName: false,
      parentSessionId: sourceSessionId,
    );
    final detail = PiSessionDetail(
      summary: summary,
      conversation: PiConversationSnapshot(
        sessionId: summary.id,
        entries: source.conversation.entries,
        lastEventSequence: source.conversation.lastEventSequence,
      ),
    );
    final tree = fakeTree(detail);
    sessions = <PiSessionSummary>[summary, ...sessions];
    details[newSessionId] = detail;
    trees[newSessionId] = tree;
    final editorText = editorEntryId == null
        ? null
        : trees[sourceSessionId]?.nodeById(editorEntryId)?.text;
    return PiSessionTreeMutationUpdated(
      commandId: commandId,
      operation: operation,
      session: detail,
      tree: tree,
      editorText: editorText,
    );
  }

  void _replaceSummary(PiSessionSummary summary) {
    final index = sessions.indexWhere((session) => session.id == summary.id);
    sessions = index == -1
        ? <PiSessionSummary>[summary, ...sessions]
        : <PiSessionSummary>[
            ...sessions.take(index),
            summary,
            ...sessions.skip(index + 1),
          ];
    final currentDetail = details[summary.id];
    if (currentDetail != null) {
      details[summary.id] = PiSessionDetail(
        summary: summary,
        conversation: PiConversationSnapshot(
          sessionId: summary.id,
          entries: currentDetail.conversation.entries,
          lastEventSequence: currentDetail.conversation.lastEventSequence,
        ),
      );
    }
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

final class FakePiSessionExportHandle implements PiSessionExportHandle {
  FakePiSessionExportHandle({
    required this.fileName,
    required this.contentType,
    required Iterable<Uint8List> chunks,
  }) : _chunks = List<Uint8List>.unmodifiable(chunks),
       totalBytes = chunks.fold<int>(0, (sum, chunk) => sum + chunk.length),
       sha256 = List<int>.filled(32, 0, growable: false);

  final List<Uint8List> _chunks;
  final Completer<void> _done = Completer<void>();
  bool cancelled = false;

  @override
  final String fileName;

  @override
  final String contentType;

  @override
  final int totalBytes;

  @override
  final List<int> sha256;

  @override
  Stream<Uint8List> get bytes async* {
    try {
      for (final chunk in _chunks) {
        if (cancelled) return;
        yield Uint8List.fromList(chunk);
      }
      if (!_done.isCompleted) _done.complete();
    } catch (error, stackTrace) {
      if (!_done.isCompleted) _done.completeError(error, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> get done => _done.future;

  @override
  Future<void> cancel() async {
    cancelled = true;
    if (!_done.isCompleted) {
      _done.completeError(
        const PiNodeException(PiNodeErrorCode.cancelled, retryable: false),
      );
    }
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
    adminRevision: PiSessionAdminRevision('revision-$id-1'),
    hasCustomName: true,
  );
}

PiSessionSummary _updatedSession(
  PiSessionSummary current,
  String title, {
  required bool hasCustomName,
}) => PiSessionSummary(
  id: current.id,
  title: title,
  workingDirectory: current.workingDirectory,
  createdAt: current.createdAt,
  updatedAt: current.updatedAt.add(const Duration(milliseconds: 1)),
  isRunning: false,
  hasUnread: current.hasUnread,
  adminRevision: PiSessionAdminRevision(
    '${current.adminRevision.value}-${title.hashCode}-${hasCustomName ? "custom" : "fallback"}',
  ),
  hasCustomName: hasCustomName,
  parentSessionId: current.parentSessionId,
);

PiSessionTree fakeTree(PiSessionDetail detail) {
  final nodes = detail.messages.indexed
      .map(
        (indexed) => PiSessionTreeNode(
          id: PiSessionTreeEntryId(indexed.$2.id.value),
          parentId: indexed.$1 == 0
              ? null
              : PiSessionTreeEntryId(detail.messages[indexed.$1 - 1].id.value),
          kind: switch (indexed.$2.role) {
            PiMessageRole.user => PiSessionTreeEntryKind.userMessage,
            PiMessageRole.assistant => PiSessionTreeEntryKind.assistantMessage,
            PiMessageRole.tool => PiSessionTreeEntryKind.toolMessage,
            PiMessageRole.system => PiSessionTreeEntryKind.customMessage,
          },
          text: indexed.$2.text,
          createdAt: indexed.$2.createdAt,
          depth: indexed.$1,
          isOnActivePath: true,
          hasChildren: indexed.$1 + 1 < detail.messages.length,
          canEditFromHere: indexed.$2.role == PiMessageRole.user,
          canFork: indexed.$2.role == PiMessageRole.user,
        ),
      )
      .toList(growable: false);
  return PiSessionTree(
    sessionId: detail.summary.id,
    nodes: nodes,
    activePathEntryIds: nodes.map((node) => node.id),
    activeLeafEntryId: nodes.lastOrNull?.id,
    canCloneActiveBranch: nodes.any((node) => node.canFork),
    adminRevision: detail.summary.adminRevision,
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
  Iterable<PiConversationEntry>? entries,
  int lastEventSequence = 0,
}) => PiSessionDetail(
  summary: summary,
  conversation: PiConversationSnapshot(
    sessionId: summary.id,
    entries: entries ?? messages.map(fakeConversationEntryFromMessage),
    lastEventSequence: lastEventSequence,
  ),
);

PiConversationEntry fakeConversationEntryFromMessage(
  PiMessage message, {
  int revision = 1,
  PiConversationIdentityScope scope = PiConversationIdentityScope.runtime,
  PiCommandId? originCommandId,
}) {
  final identity = PiConversationEntryIdentity(
    entryId: message.id.value,
    scope: scope,
    originCommandId: originCommandId,
  );
  final parts = <PiConversationPart>[
    PiTextConversationPart(
      partId: '${message.id.value}-part-1',
      revision: revision,
      text: message.text,
    ),
  ];
  return switch (message.role) {
    PiMessageRole.user => PiUserConversationEntry(
      identity: identity,
      revision: revision,
      createdAt: message.createdAt,
      finalized: !message.isStreaming,
      parts: parts,
      toolActivities: const <PiToolActivity>[],
    ),
    PiMessageRole.assistant => PiAssistantConversationEntry(
      identity: identity,
      revision: revision,
      createdAt: message.createdAt,
      finalized: !message.isStreaming,
      parts: parts,
      toolActivities: const <PiToolActivity>[],
      provider: 'fake-provider',
      model: 'fake-model',
      stopReason: message.isStreaming ? 'streaming' : 'stop',
    ),
    PiMessageRole.tool => PiToolResultConversationEntry(
      identity: identity,
      revision: revision,
      createdAt: message.createdAt,
      finalized: !message.isStreaming,
      parts: parts,
      toolActivities: const <PiToolActivity>[],
      toolCallId: 'fake-call-${message.id.value}',
      toolName: 'fake-tool',
      isError: false,
      safeDetails: const PiSafeNull(),
    ),
    PiMessageRole.system => PiCustomConversationEntry(
      identity: identity,
      revision: revision,
      createdAt: message.createdAt,
      finalized: !message.isStreaming,
      parts: parts,
      toolActivities: const <PiToolActivity>[],
      customType: 'fake-system',
      display: true,
      safeDetails: const PiSafeNull(),
    ),
  };
}
