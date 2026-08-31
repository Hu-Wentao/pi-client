import '../../api/pi_node/pi_node.dart';
import '../../core/pi_node_composition.dart';
import '../../platform/agent_host/pi_node_host_controller.dart';

final class WorkspaceService {
  const WorkspaceService(this._api);

  final PiNodeApi _api;

  PiNodeConnectionSnapshot get connection => _api.connection;

  Stream<PiNodeConnectionSnapshot> get connectionStates =>
      _api.connectionStates;

  PiNodeCompositionAvailability get availability {
    final metadata = _api is PiNodeCompositionMetadata
        ? _api as PiNodeCompositionMetadata
        : null;
    return metadata?.availability ?? PiNodeCompositionAvailability.externalNode;
  }

  Future<PiNodeConnectionSnapshot> connect() => _api.connect();

  Future<PiProjectBootstrap> loadProjectBootstrap() =>
      _api.getProjectBootstrap();

  Future<PiDirectoryListing> browseDirectory(
    String directory, {
    int maxChildren = 64,
  }) => _api.browseDirectory(
    PiBrowseDirectoryRequest(directory: directory, maxChildren: maxChildren),
  );

  Future<PiProject> validateProject(String candidateDirectory) =>
      _api.validateProject(
        PiValidateProjectRequest(candidateDirectory: candidateDirectory),
      );

  Future<List<PiKnownProject>> loadKnownProjects({int maxProjects = 24}) =>
      _api.listKnownProjects(maxProjects: maxProjects);

  Future<PiProject> approveProjectTrust(PiProject project) =>
      _api.approveProjectTrust(
        PiProjectTrustApproval(
          projectId: project.identity.projectId,
          revision: project.trust.revision,
        ),
      );

  Future<List<PiSessionSummary>> loadSessions(PiProjectId projectId) =>
      _api.listSessions(projectId);

  Future<PiSessionDetail> loadSession(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) => _api.getSession(projectId, sessionId);

  Future<PiSessionHistoryPage> loadSessionHistory({
    required PiProjectId projectId,
    required PiSessionId sessionId,
    PiSessionHistoryCursor? cursor,
    int limit = 50,
    PiSessionBranchRevision? expectedActiveBranchRevision,
    PiSessionTreeRevision? expectedTreeRevision,
  }) => _api.getSessionHistory(
    PiSessionHistoryRequest(
      projectId: projectId,
      sessionId: sessionId,
      cursor: cursor,
      limit: limit,
      expectedActiveBranchRevision: expectedActiveBranchRevision,
      expectedTreeRevision: expectedTreeRevision,
    ),
  );

  Future<PiSessionStats> loadSessionStats(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) => _api.getSessionStats(projectId, sessionId);

  Future<PiSessionExportHandle> exportSession({
    required PiProjectId projectId,
    required PiSessionId sessionId,
    required PiSessionExportFormat format,
    PiSessionBranchRevision? expectedActiveBranchRevision,
    PiSessionTreeRevision? expectedTreeRevision,
  }) => _api.exportSession(
    PiSessionExportRequest(
      projectId: projectId,
      sessionId: sessionId,
      format: format,
      expectedActiveBranchRevision: expectedActiveBranchRevision,
      expectedTreeRevision: expectedTreeRevision,
    ),
  );

  Future<PiSessionDetail> createSession(PiProjectId projectId) =>
      _api.createSession(PiCreateSessionRequest(projectId: projectId));

  Future<PiSessionTree> loadSessionTree(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) => _api.getSessionTree(projectId, sessionId);

  Future<PiSessionTreeMutationResult> navigateSessionTree({
    required PiCommandId commandId,
    required PiProjectId projectId,
    required PiSessionId sessionId,
    required PiSessionAdminRevision expectedAdminRevision,
    required PiSessionTreeEntryId entryId,
  }) => _api.navigateSessionTree(
    PiNavigateSessionTreeCommand(
      commandId: commandId,
      projectId: projectId,
      sessionId: sessionId,
      expectedAdminRevision: expectedAdminRevision,
      entryId: entryId,
    ),
  );

  Future<PiSessionTreeMutationResult> forkSession({
    required PiCommandId commandId,
    required PiProjectId projectId,
    required PiSessionId sessionId,
    required PiSessionAdminRevision expectedAdminRevision,
    required PiSessionTreeEntryId userEntryId,
  }) => _api.forkSession(
    PiForkSessionCommand(
      commandId: commandId,
      projectId: projectId,
      sessionId: sessionId,
      expectedAdminRevision: expectedAdminRevision,
      userEntryId: userEntryId,
    ),
  );

  Future<PiSessionTreeMutationResult> cloneSession({
    required PiCommandId commandId,
    required PiProjectId projectId,
    required PiSessionId sessionId,
    required PiSessionAdminRevision expectedAdminRevision,
  }) => _api.cloneSession(
    PiCloneSessionCommand(
      commandId: commandId,
      projectId: projectId,
      sessionId: sessionId,
      expectedAdminRevision: expectedAdminRevision,
    ),
  );

  Future<PiSessionAdminResult> renameSession({
    required PiCommandId commandId,
    required PiProjectId projectId,
    required PiSessionId sessionId,
    required String name,
  }) => _api.renameSession(
    PiRenameSessionCommand(
      commandId: commandId,
      projectId: projectId,
      sessionId: sessionId,
      name: name,
    ),
  );

  Future<PiSessionAdminResult> clearSessionName({
    required PiCommandId commandId,
    required PiProjectId projectId,
    required PiSessionId sessionId,
  }) => _api.clearSessionName(
    PiClearSessionNameCommand(
      commandId: commandId,
      projectId: projectId,
      sessionId: sessionId,
    ),
  );

  Future<PiSessionAdminResult> autoNameSession({
    required PiCommandId commandId,
    required PiProjectId projectId,
    required PiSessionId sessionId,
  }) => _api.autoNameSession(
    PiAutoNameSessionCommand(
      commandId: commandId,
      projectId: projectId,
      sessionId: sessionId,
    ),
  );

  Future<PiSessionAdminResult> deleteSession({
    required PiCommandId commandId,
    required PiProjectId projectId,
    required PiSessionId sessionId,
    required PiDeleteSessionConfirmation confirmation,
  }) => _api.deleteSession(
    PiDeleteSessionCommand(
      commandId: commandId,
      projectId: projectId,
      sessionId: sessionId,
      confirmation: confirmation,
    ),
  );

  Future<PiCommandResult> submitPrompt({
    required PiCommandId commandId,
    required PiSessionId sessionId,
    required String prompt,
  }) => _api.prompt(
    PiPromptCommand(commandId: commandId, sessionId: sessionId, prompt: prompt),
  );

  Future<PiCommandResult> abort({
    required PiCommandId commandId,
    required PiSessionId sessionId,
  }) => _api.abort(PiAbortCommand(commandId: commandId, sessionId: sessionId));

  Stream<PiSessionEvent> watchSession(PiSessionId sessionId) =>
      _api.sessionEvents(sessionId);

  String describeError(Object error) => switch (error) {
    PiNodeCompositionException(:final code) => switch (code) {
      PiNodeCompositionErrorCode.remoteNodeRequired =>
        'This platform requires a remote Pi Node. Remote transport is not configured yet.',
      PiNodeCompositionErrorCode.unsupported =>
        'Pi Node hosting and remote transport are unavailable on this platform.',
      PiNodeCompositionErrorCode.notConnected =>
        'The Pi Node is not connected. Retry the connection.',
      PiNodeCompositionErrorCode.closed =>
        'The Pi Node connection has been closed.',
    },
    PiNodeHostException(:final code) => switch (code) {
      PiNodeHostErrorCode.unsupportedPlatform =>
        'This platform cannot host a local Pi Node.',
      PiNodeHostErrorCode.launchFailed =>
        'The local Pi Node could not start. Verify the Node runtime and built stdio entrypoint.',
      PiNodeHostErrorCode.closed => 'The local Pi Node host has been closed.',
    },
    PiNodeException(:final code) => switch (code) {
      PiNodeErrorCode.authenticationRequired =>
        'The Pi Node requires authentication.',
      PiNodeErrorCode.permissionDenied =>
        'Pi Node denied access to this operation.',
      PiNodeErrorCode.notFound => 'The requested Pi session was not found.',
      PiNodeErrorCode.invalidRequest => 'Pi Node rejected an invalid request.',
      PiNodeErrorCode.conflict =>
        'The Pi session changed before the operation completed.',
      PiNodeErrorCode.nodeBusy => 'Pi Node is busy. Try again shortly.',
      PiNodeErrorCode.cancelled => 'The Pi Node operation was cancelled.',
      PiNodeErrorCode.deadlineExceeded =>
        'The Pi Node operation exceeded its deadline.',
      PiNodeErrorCode.failedPrecondition =>
        'The Pi Node operation requires refreshed or additional state.',
      PiNodeErrorCode.protocolMismatch =>
        'Pi Node does not support protocol 0.2.0.',
      PiNodeErrorCode.malformedFrame || PiNodeErrorCode.unexpectedResponse =>
        'Pi Node returned an invalid protocol response.',
      PiNodeErrorCode.dataLoss =>
        'The Pi Node export failed integrity verification.',
      PiNodeErrorCode.resourceExhausted =>
        'Pi Node has reached a bounded resource limit.',
      PiNodeErrorCode.protocolViolation =>
        'The Pi Node transfer violated the negotiated protocol.',
      PiNodeErrorCode.unavailable || PiNodeErrorCode.internal =>
        'The Pi Node operation is temporarily unavailable.',
      PiNodeErrorCode.disconnected =>
        'The Pi Node disconnected. Retry the connection.',
      PiNodeErrorCode.closed => 'The Pi Node connection has been closed.',
      PiNodeErrorCode.remoteRejected => 'Pi Node rejected the operation.',
    },
    ArgumentError() => 'Enter a valid working directory or prompt.',
    _ => 'The Pi Node operation failed.',
  };
}
