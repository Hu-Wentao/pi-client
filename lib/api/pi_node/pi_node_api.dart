import 'pi_node_models.dart';

abstract interface class PiNodeApi {
  PiNodeConnectionSnapshot get connection;

  Stream<PiNodeConnectionSnapshot> get connectionStates;

  Future<PiNodeConnectionSnapshot> connect();

  Future<List<PiSessionSummary>> listSessions();

  Future<PiSessionDetail> getSession(PiSessionId sessionId);

  Future<PiSessionDetail> createSession(PiCreateSessionRequest request);

  Future<PiCommandResult> prompt(PiPromptCommand command);

  Future<PiCommandResult> abort(PiAbortCommand command);

  Stream<PiSessionEvent> sessionEvents(PiSessionId sessionId);

  Future<void> close();
}
