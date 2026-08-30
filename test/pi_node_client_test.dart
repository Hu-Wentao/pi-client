import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/protocol/pi_protocol.dart';
import 'package:pi_client/transport/in_memory_pi_transport.dart';
import 'package:pi_client/transport/pi_transport.dart';

void main() {
  group('PiNodeClient', () {
    test(
      'handshakes and correlates concurrent out-of-order responses',
      () async {
        final fixture = await _connectedFixture();
        addTearDown(fixture.client.close);
        final session = _protocolSession('session-1');

        final listFuture = fixture.client.listSessions(
          PiProjectId('project-1'),
        );
        final detailFuture = fixture.client.getSession(
          PiProjectId('project-1'),
          PiSessionId('session-1'),
        );
        final listRequest = fixture.take<PiProtocolListSessionsRequest>();
        final detailRequest = fixture.take<PiProtocolGetSessionRequest>();

        expect(detailRequest.sessionId, 'session-1');
        expect(detailRequest.projectId, 'project-1');
        expect(detailRequest.requestId, isNot(listRequest.requestId));
        await fixture.send(
          PiProtocolSessionResponse(
            requestId: detailRequest.requestId,
            session: session,
          ),
        );
        await fixture.send(
          PiProtocolSessionsResponse(
            requestId: listRequest.requestId,
            sessions: <PiProtocolSessionSummary>[session.summary],
          ),
        );

        expect((await detailFuture).summary.id, PiSessionId('session-1'));
        expect((await listFuture).single.id, PiSessionId('session-1'));
        expect(
          fixture.client.connection,
          PiNodeConnectionSnapshot.connected(fixture.version),
        );
      },
    );

    test(
      'maps project discovery, identity, directory, and trust operations',
      () async {
        final fixture = await _connectedFixture();
        addTearDown(fixture.client.close);
        final restricted = _protocolProject(
          '/safe/project',
          trustStatus: PiProtocolProjectTrustStatus.approvalRequired,
        );

        final bootstrapFuture = fixture.client.getProjectBootstrap();
        final bootstrapRequest = fixture
            .take<PiProtocolGetProjectBootstrapRequest>();
        await fixture.send(
          PiProtocolProjectBootstrapResponse(
            requestId: bootstrapRequest.requestId,
            homeDirectory: '/safe/home',
            defaultProject: restricted,
          ),
        );
        final bootstrap = await bootstrapFuture;
        expect(bootstrap.homeDirectory, '/safe/home');
        expect(
          bootstrap.defaultProject.trust.status,
          PiProjectTrustStatus.approvalRequired,
        );
        expect(bootstrap.toString(), isNot(contains('/safe/home')));

        final browseFuture = fixture.client.browseDirectory(
          PiBrowseDirectoryRequest(directory: '/safe/home'),
        );
        final browseRequest = fixture.take<PiProtocolBrowseDirectoryRequest>();
        expect(browseRequest.maxChildren, 64);
        await fixture.send(
          PiProtocolDirectoryResponse(
            requestId: browseRequest.requestId,
            directory: PiProtocolDirectoryListing(
              canonicalDirectory: '/safe/home',
              parentDirectory: '/safe',
              children: <PiProtocolDirectoryEntry>[
                PiProtocolDirectoryEntry(
                  name: 'project',
                  canonicalPath: '/safe/project',
                  isSymbolicLink: true,
                ),
              ],
              truncated: false,
            ),
          ),
        );
        final directory = await browseFuture;
        expect(directory.children.single.isSymbolicLink, isTrue);
        expect(directory.toString(), isNot(contains('/safe/project')));

        final validateFuture = fixture.client.validateProject(
          PiValidateProjectRequest(candidateDirectory: '/safe/project'),
        );
        final validateRequest = fixture
            .take<PiProtocolValidateProjectRequest>();
        await fixture.send(
          PiProtocolProjectValidatedResponse(
            requestId: validateRequest.requestId,
            project: restricted,
          ),
        );
        expect(
          (await validateFuture).identity.projectId,
          PiProjectId('project-1'),
        );

        final knownFuture = fixture.client.listKnownProjects(maxProjects: 4);
        final knownRequest = fixture.take<PiProtocolListKnownProjectsRequest>();
        await fixture.send(
          PiProtocolKnownProjectsResponse(
            requestId: knownRequest.requestId,
            projects: <PiProtocolKnownProjectSnapshot>[
              PiProtocolKnownProjectSnapshot(
                project: restricted,
                lastSessionAt: DateTime.utc(2026, 1, 2),
                sessionCount: 2,
              ),
            ],
          ),
        );
        expect((await knownFuture).single.sessionCount, 2);

        final approvalFuture = fixture.client.approveProjectTrust(
          PiProjectTrustApproval(
            projectId: PiProjectId('project-1'),
            revision: PiProjectTrustRevision('revision-approvalRequired'),
          ),
        );
        final approvalRequest = fixture
            .take<PiProtocolApproveProjectTrustRequest>();
        await fixture.send(
          PiProtocolProjectTrustApprovedResponse(
            requestId: approvalRequest.requestId,
            project: _protocolProject(
              '/safe/project',
              trustStatus: PiProtocolProjectTrustStatus.trusted,
            ),
          ),
        );
        expect(
          (await approvalFuture).trust.status,
          PiProjectTrustStatus.trusted,
        );
      },
    );

    test(
      'creates sessions and preserves typed immutable projections',
      () async {
        final fixture = await _connectedFixture();
        addTearDown(fixture.client.close);
        final future = fixture.client.createSession(
          PiCreateSessionRequest(projectId: PiProjectId('project-1')),
        );
        final request = fixture.take<PiProtocolCreateSessionRequest>();
        final protocolSession = _protocolSession('created-session');

        expect(request.projectId, 'project-1');
        await fixture.send(
          PiProtocolSessionCreatedResponse(
            requestId: request.requestId,
            session: protocolSession,
          ),
        );
        final session = await future;

        expect(session.summary.id, PiSessionId('created-session'));
        expect(session.messages.single.role, PiMessageRole.user);
        expect(
          () => session.messages.add(session.messages.single),
          throwsUnsupportedError,
        );
      },
    );

    test('maps typed session administration requests and outcomes', () async {
      final fixture = await _connectedFixture();
      addTearDown(fixture.client.close);
      final session = _protocolSession('session-admin').summary;
      final projectId = PiProjectId('project-1');
      final sessionId = PiSessionId('session-admin');

      final renameFuture = fixture.client.renameSession(
        PiRenameSessionCommand(
          commandId: PiCommandId('admin-rename'),
          projectId: projectId,
          sessionId: sessionId,
          name: 'Renamed session',
        ),
      );
      final rename = fixture.take<PiProtocolRenameSessionCommandRequest>();
      expect(rename.projectId, 'project-1');
      expect(rename.sessionId, 'session-admin');
      expect(rename.name, 'Renamed session');
      final renamedSummary = PiProtocolSessionSummary(
        id: session.id,
        title: 'Renamed session',
        workingDirectory: session.workingDirectory,
        createdAt: session.createdAt,
        updatedAt: session.updatedAt.add(const Duration(milliseconds: 1)),
        isRunning: false,
        hasUnread: false,
        adminRevision: 'revision-session-admin-2',
        hasCustomName: true,
      );
      await fixture.send(
        PiProtocolSessionAdminOutcomeMessage(
          requestId: rename.requestId,
          commandId: rename.commandId,
          operation: PiProtocolSessionAdminOperation.rename,
          outcome: PiProtocolSessionAdminUpdated(renamedSummary),
        ),
      );
      final renamed = await renameFuture as PiSessionAdminUpdated;
      expect(renamed.operation, PiSessionAdminOperation.rename);
      expect(renamed.session.title, 'Renamed session');
      expect(
        renamed.session.adminRevision,
        PiSessionAdminRevision('revision-session-admin-2'),
      );

      final deleteFuture = fixture.client.deleteSession(
        PiDeleteSessionCommand(
          commandId: PiCommandId('admin-delete'),
          projectId: projectId,
          sessionId: sessionId,
          confirmation: PiDeleteSessionConfirmation.confirmed(renamed.session),
        ),
      );
      final delete = fixture.take<PiProtocolDeleteSessionCommandRequest>();
      expect(delete.confirmation.destructiveActionAcknowledged, isTrue);
      expect(delete.confirmation.adminRevision, 'revision-session-admin-2');
      await fixture.send(
        PiProtocolSessionAdminOutcomeMessage(
          requestId: delete.requestId,
          commandId: delete.commandId,
          operation: PiProtocolSessionAdminOperation.delete,
          outcome: PiProtocolSessionAdminDeleted(
            sessionId: 'session-admin',
            reparentedChildCount: 2,
          ),
        ),
      );
      final deleted = await deleteFuture as PiSessionAdminDeleted;
      expect(deleted.sessionId, sessionId);
      expect(deleted.reparentedChildCount, 2);
    });

    test('returns accepted, rejected, and remote uncertain commands', () async {
      final fixture = await _connectedFixture();
      addTearDown(fixture.client.close);
      final sessionId = PiSessionId('session-1');

      final promptFuture = fixture.client.prompt(
        PiPromptCommand(
          commandId: PiCommandId('command-prompt'),
          sessionId: sessionId,
          prompt: 'private prompt',
        ),
      );
      final prompt = fixture.take<PiProtocolPromptCommandRequest>();
      expect(prompt.prompt, 'private prompt');
      await fixture.send(
        PiProtocolCommandAcceptedMessage(
          requestId: prompt.requestId,
          commandId: prompt.commandId,
        ),
      );
      expect(await promptFuture, isA<PiCommandAccepted>());

      final abortFuture = fixture.client.abort(
        PiAbortCommand(
          commandId: PiCommandId('command-abort'),
          sessionId: sessionId,
        ),
      );
      final abort = fixture.take<PiProtocolAbortCommandRequest>();
      await fixture.send(
        PiProtocolCommandRejectedMessage(
          requestId: abort.requestId,
          commandId: abort.commandId,
          failure: PiProtocolFailure(
            code: 'permission_denied',
            retryable: false,
          ),
        ),
      );
      final rejected = await abortFuture as PiCommandRejected;
      expect(rejected.error.code, PiNodeErrorCode.permissionDenied);

      final uncertainFuture = fixture.client.prompt(
        PiPromptCommand(
          commandId: PiCommandId('command-uncertain'),
          sessionId: sessionId,
          prompt: 'another private prompt',
        ),
      );
      final uncertain = fixture.take<PiProtocolPromptCommandRequest>();
      await fixture.send(
        PiProtocolCommandUncertainMessage(
          requestId: uncertain.requestId,
          commandId: uncertain.commandId,
          failure: PiProtocolFailure(code: 'node_busy', retryable: true),
        ),
      );
      final result = await uncertainFuture as PiCommandUncertain;
      expect(result.error.code, PiNodeErrorCode.nodeBusy);
      expect(result.error.retryable, isTrue);
    });

    test(
      'drops duplicate events and emits a recovery signal for gaps',
      () async {
        final fixture = await _connectedFixture();
        addTearDown(fixture.client.close);
        final sessionId = PiSessionId('session-1');
        final eventsFuture = fixture.client
            .sessionEvents(sessionId)
            .take(3)
            .toList();

        await fixture.send(
          PiProtocolSessionEventMessage(
            sessionId: sessionId.value,
            sequence: 1,
            event: PiProtocolMessageDeltaEvent(
              messageId: 'message-1',
              delta: 'a',
            ),
          ),
        );
        await fixture.send(
          PiProtocolSessionEventMessage(
            sessionId: sessionId.value,
            sequence: 1,
            event: PiProtocolMessageDeltaEvent(
              messageId: 'message-1',
              delta: 'duplicate',
            ),
          ),
        );
        await fixture.send(
          PiProtocolSessionEventMessage(
            sessionId: sessionId.value,
            sequence: 3,
            event: const PiProtocolSessionRunningChangedEvent(isRunning: true),
          ),
        );
        await fixture.send(
          PiProtocolSessionEventMessage(
            sessionId: sessionId.value,
            sequence: 4,
            event: const PiProtocolSessionRunningChangedEvent(isRunning: false),
          ),
        );

        final events = await eventsFuture;
        expect(events, hasLength(3));
        expect((events[0] as PiSessionMessageDeltaEvent).delta, 'a');
        final gap = events[1] as PiSessionSequenceGapEvent;
        expect(gap.expectedSequence, 2);
        expect(gap.receivedSequence, 3);
        expect((events[2] as PiSessionRunningChangedEvent).isRunning, isFalse);
      },
    );

    test(
      'fails queries and makes in-flight commands uncertain on disconnect',
      () async {
        final fixture = await _connectedFixture();
        addTearDown(fixture.client.close);
        final sessionId = PiSessionId('session-1');
        final eventFailure = expectLater(
          fixture.client.sessionEvents(sessionId),
          emitsError(
            isA<PiNodeException>().having(
              (error) => error.code,
              'code',
              PiNodeErrorCode.disconnected,
            ),
          ),
        );
        final listFuture = fixture.client.listSessions(
          PiProjectId('project-1'),
        );
        final commandFuture = fixture.client.prompt(
          PiPromptCommand(
            commandId: PiCommandId('command-disconnect'),
            sessionId: sessionId,
            prompt: 'private prompt',
          ),
        );
        fixture.take<PiProtocolListSessionsRequest>();
        fixture.take<PiProtocolPromptCommandRequest>();
        final listFailure = expectLater(
          listFuture,
          throwsA(
            isA<PiNodeException>().having(
              (error) => error.code,
              'code',
              PiNodeErrorCode.disconnected,
            ),
          ),
        );

        await fixture.server.close();

        await listFailure;
        final command = await commandFuture as PiCommandUncertain;
        expect(command.error.code, PiNodeErrorCode.disconnected);
        await eventFailure;
        expect(
          fixture.client.connection.status,
          PiNodeConnectionStatus.disconnected,
        );
      },
    );

    test(
      'redacts models, failures, protocol frames, and validation errors',
      () {
        final sessionId = PiSessionId('secret-session');
        final command = PiPromptCommand(
          commandId: PiCommandId('secret-command'),
          sessionId: sessionId,
          prompt: 'secret prompt',
        );
        final failure = PiProtocolFailure(
          code: 'secret_remote_code',
          retryable: false,
        );
        final error = PiNodeException.fromProtocolFailure(failure);
        final frame = PiTransportFrame(
          Uint8List.fromList('secret frame'.codeUnits),
        );

        expect(command.toString(), isNot(contains('secret')));
        expect(sessionId.toString(), isNot(contains('secret-session')));
        expect(failure.toString(), isNot(contains('secret_remote_code')));
        expect(error.code, PiNodeErrorCode.remoteRejected);
        expect(error.toString(), isNot(contains('secret_remote_code')));
        expect(frame.toString(), isNot(contains('secret frame')));
        expect(
          () => PiValidateProjectRequest(candidateDirectory: ' secret/path'),
          throwsA(
            isA<ArgumentError>().having(
              (value) => value.toString(),
              'redacted validation error',
              isNot(contains('secret/path')),
            ),
          ),
        );
      },
    );

    test(
      'makes client close idempotent and resolves commands as uncertain',
      () async {
        final fixture = await _connectedFixture();
        final connectionStates = fixture.client.connectionStates
            .take(2)
            .toList();
        final commandFuture = fixture.client.abort(
          PiAbortCommand(
            commandId: PiCommandId('command-close'),
            sessionId: PiSessionId('session-1'),
          ),
        );
        fixture.take<PiProtocolAbortCommandRequest>();

        final firstClose = fixture.client.close();
        final secondClose = fixture.client.close();
        expect(identical(firstClose, secondClose), isTrue);
        await firstClose;
        await secondClose;

        final command = await commandFuture as PiCommandUncertain;
        expect(command.error.code, PiNodeErrorCode.closed);
        expect(
          (await connectionStates).map((state) => state.status),
          <PiNodeConnectionStatus>[
            PiNodeConnectionStatus.closing,
            PiNodeConnectionStatus.closed,
          ],
        );
        expect(fixture.client.connection.status, PiNodeConnectionStatus.closed);
        await expectLater(
          fixture.client.connect(),
          throwsA(
            isA<PiNodeException>().having(
              (error) => error.code,
              'code',
              PiNodeErrorCode.closed,
            ),
          ),
        );
      },
    );

    test('rejects a negotiated version that was not offered', () async {
      final fixture = _Fixture(autoAcceptHandshake: false);
      addTearDown(fixture.client.close);
      final connectionFuture = fixture.client.connect();
      final connectionFailure = expectLater(
        connectionFuture,
        throwsA(
          isA<PiNodeException>().having(
            (error) => error.code,
            'code',
            PiNodeErrorCode.protocolMismatch,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      fixture.take<PiProtocolHandshakeOfferMessage>();

      await fixture.send(
        PiProtocolHandshakeAcceptedMessage(
          negotiatedVersion: PiProtocolVersion(9, 0, 0),
        ),
      );

      await connectionFailure;
      expect(
        fixture.client.connection.status,
        PiNodeConnectionStatus.disconnected,
      );
    });

    test(
      'fails pending requests with a redacted malformed-frame error',
      () async {
        final fixture = await _connectedFixture();
        addTearDown(fixture.client.close);
        final listFuture = fixture.client.listSessions(
          PiProjectId('project-1'),
        );
        fixture.take<PiProtocolListSessionsRequest>();
        final listFailure = expectLater(
          listFuture,
          throwsA(
            isA<PiNodeException>()
                .having(
                  (error) => error.code,
                  'code',
                  PiNodeErrorCode.malformedFrame,
                )
                .having(
                  (error) => error.toString(),
                  'redacted',
                  contains('<redacted>'),
                ),
          ),
        );

        await fixture.server.send(
          PiTransportFrame(Uint8List.fromList(<int>[255, 255, 255, 255])),
        );

        await listFailure;
      },
    );
  });
}

Future<_Fixture> _connectedFixture() async {
  final fixture = _Fixture();
  await fixture.client.connect();
  return fixture;
}

final class _Fixture {
  _Fixture({this.autoAcceptHandshake = true}) {
    final pair = InMemoryPiTransportPair();
    clientTransport = pair.first;
    server = pair.second;
    client = PiNodeClient(
      transport: clientTransport,
      codec: codec,
      protocolOffer: PiProtocolOffer(<PiProtocolVersion>[version]),
    );
    _serverSubscription = server.incoming.listen((frame) {
      final message = codec.decodeClient(frame);
      if (message is PiProtocolHandshakeOfferMessage && autoAcceptHandshake) {
        offered = message.offer;
        unawaited(
          send(PiProtocolHandshakeAcceptedMessage(negotiatedVersion: version)),
        );
      } else {
        _received.add(message);
      }
    });
    unawaited(server.done.whenComplete(_serverSubscription.cancel));
  }

  final bool autoAcceptHandshake;
  final _MemoryProtocolCodec codec = _MemoryProtocolCodec();
  final PiProtocolVersion version = PiProtocolVersion(1, 0, 0);
  late final PiTransport clientTransport;
  late final PiTransport server;
  late final PiNodeClient client;
  late final StreamSubscription<PiTransportFrame> _serverSubscription;
  final List<PiClientProtocolMessage> _received = <PiClientProtocolMessage>[];
  PiProtocolOffer? offered;

  T take<T extends PiClientProtocolMessage>() {
    final index = _received.indexWhere((message) => message is T);
    if (index < 0) {
      throw StateError('No queued protocol message of the requested type.');
    }
    return _received.removeAt(index) as T;
  }

  Future<void> send(PiServerProtocolMessage message) =>
      server.send(codec.encodeServer(message));
}

final class _MemoryProtocolCodec implements PiProtocolCodec {
  final Map<int, Object> _messages = <int, Object>{};
  var _nextToken = 1;

  @override
  Uint8List encode(PiClientProtocolMessage message) => _store(message).bytes;

  @override
  PiServerProtocolMessage decode(Uint8List frame) =>
      _take(PiTransportFrame(frame)) as PiServerProtocolMessage;

  PiClientProtocolMessage decodeClient(PiTransportFrame frame) =>
      _take(frame) as PiClientProtocolMessage;

  PiTransportFrame encodeServer(PiServerProtocolMessage message) =>
      _store(message);

  PiTransportFrame _store(Object message) {
    final token = _nextToken;
    _nextToken += 1;
    _messages[token] = message;
    final data = ByteData(4)..setUint32(0, token);
    return PiTransportFrame(data.buffer.asUint8List());
  }

  Object _take(PiTransportFrame frame) {
    final bytes = frame.bytes;
    if (bytes.length != 4) throw StateError('Invalid test frame.');
    final token = ByteData.sublistView(bytes).getUint32(0);
    final message = _messages.remove(token);
    if (message == null) throw StateError('Unknown test frame.');
    return message;
  }
}

PiProtocolProjectSnapshot _protocolProject(
  String canonicalWorkingDirectory, {
  PiProtocolProjectTrustStatus trustStatus =
      PiProtocolProjectTrustStatus.notRequired,
}) => PiProtocolProjectSnapshot(
  identity: PiProtocolProjectIdentity(
    projectId: 'project-1',
    canonicalWorkingDirectory: canonicalWorkingDirectory,
    isGitRepository: false,
    isLinkedWorktree: false,
    isDetachedHead: false,
    worktreeId: 'worktree-1',
    mainProjectId: 'main-project-1',
  ),
  trust: PiProtocolProjectTrustSnapshot(
    status: trustStatus,
    reasons: trustStatus == PiProtocolProjectTrustStatus.notRequired
        ? const <PiProtocolProjectTrustReason>[]
        : <PiProtocolProjectTrustReason>[
            PiProtocolProjectTrustReason.piSettings,
            if (trustStatus == PiProtocolProjectTrustStatus.trusted)
              PiProtocolProjectTrustReason.savedApproval,
          ],
    revision: 'revision-${trustStatus.name}',
  ),
);

PiProtocolSessionDetail _protocolSession(String id) {
  final createdAt = DateTime.utc(2026, 1, 1, 12);
  return PiProtocolSessionDetail(
    summary: PiProtocolSessionSummary(
      id: id,
      title: 'Session title',
      workingDirectory: '/safe/project',
      createdAt: createdAt,
      updatedAt: createdAt.add(const Duration(minutes: 1)),
      isRunning: false,
      hasUnread: false,
      adminRevision: 'revision-$id-1',
      hasCustomName: true,
    ),
    messages: <PiProtocolMessageSnapshot>[
      PiProtocolMessageSnapshot(
        id: 'message-1',
        role: PiProtocolMessageRole.user,
        text: 'Hello',
        createdAt: createdAt,
        isStreaming: false,
      ),
    ],
  );
}
