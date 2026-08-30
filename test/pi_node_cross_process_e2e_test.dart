import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/app/workspace/workspace.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';
import 'package:pi_client/protocol/pi_protocol.dart';
import 'package:pi_client/transport/local_direct_pi_transport.dart';

const _expectedCapabilities = <PiProtocolCapability>{
  PiProtocolCapability.sessionRead,
  PiProtocolCapability.sessionCreate,
  PiProtocolCapability.promptCommand,
  PiProtocolCapability.abortCommand,
  PiProtocolCapability.sessionEvents,
};

void main() {
  setUpAll(_requireBuiltPrerequisites);

  group('Flutter to built Pi Node cross-process E2E', () {
    test(
      'uses the offline public SDK for list, create, and get',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'pi-client-flutter-node-sdk-',
        );
        addTearDown(() => root.delete(recursive: true));
        final cwd = await Directory('${root.path}/project').create();
        final agentDir = await Directory('${root.path}/agent').create();
        final sessionDir = await Directory('${root.path}/sessions').create();
        await File('${agentDir.path}/settings.json').writeAsString(
          '${jsonEncode(<String, Object>{'sessionDir': sessionDir.path, 'enableAnalytics': false})}\n',
        );

        final harness = await _startProductionNode(
          cwd: cwd.path,
          agentDir: agentDir.path,
        );
        addTearDown(harness.client.close);
        final connection = await harness.client.connect();
        _expectSupportedHandshake(connection);

        expect(await harness.client.listSessions(), isEmpty);
        final created = await harness.client.createSession(
          PiCreateSessionRequest(workingDirectory: cwd.path),
        );
        final canonicalCwd = await cwd.resolveSymbolicLinks();
        expect(created.summary.workingDirectory, canonicalCwd);
        expect(created.messages, isEmpty);

        final listed = await harness.client.listSessions();
        expect(
          listed.map((session) => session.id),
          contains(created.summary.id),
        );
        final loaded = await harness.client.getSession(created.summary.id);
        expect(loaded.summary.id, created.summary.id);
        expect(loaded.summary.workingDirectory, canonicalCwd);

        await expectLater(
          harness.client.getSession(PiSessionId('missing-offline-session')),
          throwsA(
            isA<PiNodeException>().having(
              (error) => error.code,
              'code',
              PiNodeErrorCode.notFound,
            ),
          ),
        );
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    test(
      'drives the production Workspace through the built first-party Node',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'pi-client-workspace-node-sdk-',
        );
        addTearDown(() => root.delete(recursive: true));
        final cwd = await Directory('${root.path}/project').create();
        final agentDir = await Directory('${root.path}/agent').create();
        final sessionDir = await Directory('${root.path}/sessions').create();
        await File('${agentDir.path}/settings.json').writeAsString(
          '${jsonEncode(<String, Object>{'sessionDir': sessionDir.path, 'enableAnalytics': false})}\n',
        );

        final harness = await _startProductionNode(
          cwd: cwd.path,
          agentDir: agentDir.path,
        );
        final viewModel = WorkspaceViewModel(
          service: WorkspaceService(harness.client),
        );
        addTearDown(() async {
          await viewModel.close();
          await harness.client.close();
        });

        viewModel.add(const WorkspaceStarted());
        await _waitForWorkspace(
          viewModel,
          (state) =>
              state.connection.status == PiNodeConnectionStatus.connected &&
              !state.sessionsLoading,
        );
        expect(viewModel.state.sessions, isEmpty);

        viewModel.add(WorkspaceNewSessionRequested(cwd.path));
        await _waitForWorkspace(
          viewModel,
          (state) =>
              state.sessions.length == 1 &&
              state.selectedSessionId == state.sessions.single.id &&
              !state.conversationLoading &&
              state.eventStatus == WorkspaceEventStatus.listening,
        );
        expect(
          viewModel.state.sessions.single.workingDirectory,
          await cwd.resolveSymbolicLinks(),
        );
        expect(viewModel.state.messages, isEmpty);
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    test(
      'preserves command outcomes, event order, framing, and stderr pressure',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'pi-client-flutter-node-fixture-',
        );
        addTearDown(() => root.delete(recursive: true));
        final evidenceFile = File('${root.path}/framing-evidence.json');
        final harness = await _startFixtureNode(
          cwd: root.path,
          mode: 'normal',
          evidenceFile: evidenceFile.path,
        );
        addTearDown(harness.client.close);
        final connection = await harness.client.connect();
        _expectSupportedHandshake(connection);

        final listed = await harness.client.listSessions();
        expect(listed.single.id, PiSessionId('fixture-session'));
        final sessionId = listed.single.id;
        final loaded = await harness.client.getSession(sessionId);
        expect(loaded.messages.single.text, 'Hello');
        final created = await harness.client.createSession(
          PiCreateSessionRequest(workingDirectory: root.path),
        );
        expect(created.summary.id, PiSessionId('fixture-created-1'));

        final rejected = await harness.client.prompt(
          PiPromptCommand(
            commandId: PiCommandId('fixture-rejected'),
            sessionId: sessionId,
            prompt: 'reject',
          ),
        );
        expect(rejected, isA<PiCommandRejected>());
        expect(
          (rejected as PiCommandRejected).error.code,
          PiNodeErrorCode.invalidRequest,
        );

        final uncertain = await harness.client.prompt(
          PiPromptCommand(
            commandId: PiCommandId('fixture-uncertain'),
            sessionId: sessionId,
            prompt: 'uncertain',
          ),
        );
        expect(uncertain, isA<PiCommandUncertain>());
        expect(
          (uncertain as PiCommandUncertain).error.code,
          PiNodeErrorCode.nodeBusy,
        );

        final eventsFuture = harness.client
            .sessionEvents(sessionId)
            .take(5)
            .toList()
            .timeout(const Duration(seconds: 10));
        final promptCommandId = PiCommandId('fixture-accepted');
        final accepted = await harness.client.prompt(
          PiPromptCommand(
            commandId: promptCommandId,
            sessionId: sessionId,
            prompt: 'accept',
          ),
        );
        expect(accepted, isA<PiCommandAccepted>());
        final abort = await harness.client.abort(
          PiAbortCommand(
            commandId: PiCommandId('fixture-abort'),
            sessionId: sessionId,
          ),
        );
        expect(abort, isA<PiCommandAccepted>());

        final events = await eventsFuture;
        expect(events.map((event) => event.sequence), <int>[1, 2, 3, 4, 5]);
        expect(events.map((event) => event.runtimeType), <Type>[
          PiSessionRunningChangedEvent,
          PiSessionMessageAddedEvent,
          PiSessionMessageDeltaEvent,
          PiSessionRunningChangedEvent,
          PiSessionCommandCompletedEvent,
        ]);
        expect((events[0] as PiSessionRunningChangedEvent).isRunning, isTrue);
        expect(
          (events[1] as PiSessionMessageAddedEvent).message.text,
          'Working',
        );
        expect((events[2] as PiSessionMessageDeltaEvent).delta, ' now');
        expect((events[3] as PiSessionRunningChangedEvent).isRunning, isFalse);
        final completed = events[4] as PiSessionCommandCompletedEvent;
        expect(completed.commandId, promptCommandId);
        expect(completed.succeeded, isFalse);

        final firstClose = harness.client.close();
        final secondClose = harness.client.close();
        expect(identical(firstClose, secondClose), isTrue);
        await firstClose;
        await secondClose;
        expect(harness.client.connection.status, PiNodeConnectionStatus.closed);

        final evidence =
            jsonDecode(await evidenceFile.readAsString())
                as Map<String, Object?>;
        expect(evidence['prefixBytes'], 4);
        expect(evidence['splitWriteCount'], 3);
        expect(
          (evidence['coalescedBatchCount']! as num).toInt(),
          greaterThan(0),
        );
        expect(
          (evidence['maxFramesPerWrite']! as num).toInt(),
          greaterThanOrEqualTo(3),
        );
        expect(evidence['stderrBytes'], 512 * 1024);
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    test(
      'rejects an unsupported version through the real connection',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'pi-client-flutter-node-version-',
        );
        addTearDown(() => root.delete(recursive: true));
        final harness = await _startFixtureNode(
          cwd: root.path,
          mode: 'normal',
          protocolVersion: PiProtocolVersion(0, 99, 0),
        );
        addTearDown(harness.client.close);

        await expectLater(
          harness.client.connect(),
          throwsA(
            isA<PiNodeException>().having(
              (error) => error.code,
              'code',
              PiNodeErrorCode.protocolMismatch,
            ),
          ),
        );
        final firstClose = harness.client.close();
        final secondClose = harness.client.close();
        expect(identical(firstClose, secondClose), isTrue);
        await firstClose;
        await secondClose;
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'turns an in-flight command uncertain when the child exits',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'pi-client-flutter-node-exit-',
        );
        addTearDown(() => root.delete(recursive: true));
        final harness = await _startFixtureNode(
          cwd: root.path,
          mode: 'exit-on-prompt',
        );
        addTearDown(harness.client.close);
        await harness.client.connect();
        final sessionId = (await harness.client.listSessions()).single.id;
        await harness.client.getSession(sessionId);

        final result = await harness.client
            .prompt(
              PiPromptCommand(
                commandId: PiCommandId('fixture-disconnect'),
                sessionId: sessionId,
                prompt: 'disconnect',
              ),
            )
            .timeout(const Duration(seconds: 10));
        expect(result, isA<PiCommandUncertain>());
        expect(
          (result as PiCommandUncertain).error.code,
          PiNodeErrorCode.disconnected,
        );
        expect(
          harness.client.connection.status,
          PiNodeConnectionStatus.disconnected,
        );

        final firstClose = harness.client.close();
        final secondClose = harness.client.close();
        expect(identical(firstClose, secondClose), isTrue);
        await firstClose;
        await secondClose;
        expect(harness.client.connection.status, PiNodeConnectionStatus.closed);
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test('keeps the test fixture outside the production CLI build', () async {
      final productionMain = await File(_productionMainPath()).readAsString();
      final package =
          jsonDecode(
                await File('${_nodeRootPath()}/package.json').readAsString(),
              )
              as Map<String, Object?>;

      expect(productionMain, isNot(contains('flutter-cross-process-server')));
      expect(package['files'], <Object?>['dist']);
    });
  });
}

Future<WorkspaceModel> _waitForWorkspace(
  WorkspaceViewModel viewModel,
  bool Function(WorkspaceModel state) predicate,
) {
  if (predicate(viewModel.state)) {
    return Future<WorkspaceModel>.value(viewModel.state);
  }
  return viewModel.stream
      .firstWhere(predicate)
      .timeout(const Duration(seconds: 15));
}

void _expectSupportedHandshake(PiNodeConnectionSnapshot connection) {
  expect(connection.status, PiNodeConnectionStatus.connected);
  expect(connection.negotiatedVersion, PiProtocolVersion(0, 1, 0));
  expect(connection.capabilities, _expectedCapabilities);
}

Future<_ClientHarness> _startProductionNode({
  required String cwd,
  required String agentDir,
}) => _startClient(
  arguments: <String>[
    _productionMainPath(),
    '--cwd',
    cwd,
    '--agent-dir',
    agentDir,
  ],
  workingDirectory: _repositoryRootPath(),
  protocolVersion: PiProtocolVersion(0, 1, 0),
);

Future<_ClientHarness> _startFixtureNode({
  required String cwd,
  required String mode,
  String? evidenceFile,
  PiProtocolVersion? protocolVersion,
}) => _startClient(
  arguments: <String>[
    '--import',
    'tsx',
    _fixtureMainPath(),
    '--cwd',
    cwd,
    '--mode',
    mode,
    if (evidenceFile != null) ...<String>['--evidence-file', evidenceFile],
  ],
  workingDirectory: _nodeRootPath(),
  protocolVersion: protocolVersion ?? PiProtocolVersion(0, 1, 0),
);

Future<_ClientHarness> _startClient({
  required List<String> arguments,
  required String workingDirectory,
  required PiProtocolVersion protocolVersion,
}) async {
  final transport = await LocalDirectPiTransport.start(
    LocalDirectPiProcessConfiguration(
      executable: _nodeExecutable(),
      arguments: arguments,
      workingDirectory: workingDirectory,
      environment: const <String, String>{
        'PI_OFFLINE': '1',
        'PI_SKIP_VERSION_CHECK': '1',
        'PI_TELEMETRY': '0',
      },
      includeParentEnvironment: false,
      shutdownTimeout: const Duration(seconds: 10),
    ),
  );
  return _ClientHarness(
    PiNodeClient(
      transport: transport,
      codec: ProtobufPiProtocolCodec(
        clientInstanceId: 'flutter-cross-process-e2e',
        implementationVersion: '0.1.0-dev.0',
      ),
      protocolOffer: PiProtocolOffer(<PiProtocolVersion>[protocolVersion]),
    ),
  );
}

Future<void> _requireBuiltPrerequisites() async {
  final missing = <String>[
    '${_repositoryRootPath()}/protocol/dist/src/index.js',
    '${_nodeRootPath()}/dist/index.js',
    _productionMainPath(),
  ].where((path) => !File(path).existsSync()).toList(growable: false);
  if (missing.isNotEmpty) {
    throw StateError(
      'Missing Pi Node E2E build prerequisites. Run '
      '`node tool/run_pi_node_cross_process_e2e.mjs --build-only` first.',
    );
  }
}

String _repositoryRootPath() => Directory.current.absolute.path;

String _nodeRootPath() => '${_repositoryRootPath()}/node';

String _productionMainPath() => '${_nodeRootPath()}/dist/stdio-main.js';

String _fixtureMainPath() =>
    '${_nodeRootPath()}/test/fixtures/flutter-cross-process-server.ts';

String _nodeExecutable() {
  final injected = Platform.environment['PI_CLIENT_E2E_NODE_EXECUTABLE'];
  if (injected != null && File(injected).existsSync()) {
    return injected;
  }
  final result = Process.runSync(
    Platform.isWindows ? 'where.exe' : 'which',
    <String>['node'],
  );
  if (result.exitCode != 0) {
    throw StateError('Unable to resolve the Node.js executable for E2E.');
  }
  final path = (result.stdout as String)
      .split(RegExp(r'[\r\n]+'))
      .firstWhere((value) => value.trim().isNotEmpty)
      .trim();
  if (!File(path).existsSync()) {
    throw StateError('The resolved Node.js executable does not exist.');
  }
  return path;
}

final class _ClientHarness {
  const _ClientHarness(this.client);

  final PiNodeClient client;
}
