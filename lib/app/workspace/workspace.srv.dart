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

  Future<List<PiSessionSummary>> loadSessions() => _api.listSessions();

  Future<PiSessionDetail> loadSession(PiSessionId sessionId) =>
      _api.getSession(sessionId);

  Future<PiSessionDetail> createSession(String workingDirectory) =>
      _api.createSession(
        PiCreateSessionRequest(workingDirectory: workingDirectory),
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
      PiNodeErrorCode.protocolMismatch =>
        'Pi Node does not support protocol 0.1.0.',
      PiNodeErrorCode.malformedFrame || PiNodeErrorCode.unexpectedResponse =>
        'Pi Node returned an invalid protocol response.',
      PiNodeErrorCode.disconnected =>
        'The Pi Node disconnected. Retry the connection.',
      PiNodeErrorCode.closed => 'The Pi Node connection has been closed.',
      PiNodeErrorCode.remoteRejected => 'Pi Node rejected the operation.',
    },
    ArgumentError() => 'Enter a valid working directory or prompt.',
    _ => 'The Pi Node operation failed.',
  };
}
