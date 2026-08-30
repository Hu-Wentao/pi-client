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

  Future<PiCommandResult> prompt(PiPromptCommand command);

  Future<PiCommandResult> abort(PiAbortCommand command);

  Stream<PiSessionEvent> sessionEvents(PiSessionId sessionId);

  Future<void> close();
}
