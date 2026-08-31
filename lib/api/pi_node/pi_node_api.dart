import 'pi_node_models.dart';

abstract interface class PiNodeApi {
  PiNodeConnectionSnapshot get connection;

  Stream<PiNodeConnectionSnapshot> get connectionStates;

  Future<PiNodeConnectionSnapshot> connect();

  Future<PiProjectBootstrap> getProjectBootstrap();

  Future<PiDirectoryListing> browseDirectory(PiBrowseDirectoryRequest request);

  Future<PiProject> validateProject(PiValidateProjectRequest request);

  Future<List<PiKnownProject>> listKnownProjects({int maxProjects = 24});

  Future<PiProject> approveProjectTrust(PiProjectTrustApproval approval);

  Future<List<PiSessionSummary>> listSessions(PiProjectId projectId);

  Future<PiSessionDetail> getSession(
    PiProjectId projectId,
    PiSessionId sessionId,
  );

  Future<PiSessionDetail> createSession(PiCreateSessionRequest request);

  Future<PiSessionTree> getSessionTree(
    PiProjectId projectId,
    PiSessionId sessionId,
  );

  Future<PiSessionHistoryPage> getSessionHistory(
    PiSessionHistoryRequest request,
  );

  Future<PiSessionStats> getSessionStats(
    PiProjectId projectId,
    PiSessionId sessionId,
  );

  Future<PiSessionExportHandle> exportSession(PiSessionExportRequest request);

  Future<PiSessionTreeMutationResult> navigateSessionTree(
    PiNavigateSessionTreeCommand command,
  );

  Future<PiSessionTreeMutationResult> forkSession(PiForkSessionCommand command);

  Future<PiSessionTreeMutationResult> cloneSession(
    PiCloneSessionCommand command,
  );

  Future<PiSessionAdminResult> renameSession(PiRenameSessionCommand command);

  Future<PiSessionAdminResult> clearSessionName(
    PiClearSessionNameCommand command,
  );

  Future<PiSessionAdminResult> autoNameSession(
    PiAutoNameSessionCommand command,
  );

  Future<PiSessionAdminResult> deleteSession(PiDeleteSessionCommand command);

  Future<PiCommandResult> prompt(PiPromptCommand command);

  Future<PiCommandResult> abort(PiAbortCommand command);

  Stream<PiSessionEvent> sessionEvents(PiSessionId sessionId);

  Future<void> close();
}
