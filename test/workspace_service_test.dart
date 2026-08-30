import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';
import 'package:pi_client/core/pi_node_composition.dart';
import 'package:pi_client/platform/platform_capabilities.dart';

import 'support/fake_pi_node_api.dart';

void main() {
  test('delegates semantic workspace operations to PiNodeApi', () async {
    final session = fakeSession(
      id: 'service-session',
      title: 'Service session',
      workingDirectory: '/Projects/service',
    );
    final project = fakeProject('/Projects/service');
    final api = FakePiNodeApi(
      defaultProject: project,
      sessions: <PiSessionSummary>[session],
      details: <PiSessionId, PiSessionDetail>{
        session.id: fakeDetail(
          session,
          messages: <PiMessage>[
            fakeMessage(
              id: 'service-user-entry',
              role: PiMessageRole.user,
              text: 'Service branch prompt',
            ),
          ],
        ),
      },
    );
    final service = WorkspaceService(api);

    expect(service.availability, PiNodeCompositionAvailability.externalNode);
    expect((await service.connect()).status, PiNodeConnectionStatus.connected);
    expect((await service.loadProjectBootstrap()).defaultProject, project);
    expect(
      (await service.loadSessions(project.identity.projectId)).single,
      session,
    );
    expect(
      (await service.loadSession(
        project.identity.projectId,
        session.id,
      )).summary,
      session,
    );

    final tree = await service.loadSessionTree(
      project.identity.projectId,
      session.id,
    );
    expect(tree.nodes.single.canFork, isTrue);
    final navigated = await service.navigateSessionTree(
      commandId: PiCommandId('service-tree-navigate'),
      projectId: project.identity.projectId,
      sessionId: session.id,
      expectedAdminRevision: tree.adminRevision,
      entryId: tree.nodes.single.id,
    );
    expect(
      (navigated as PiSessionTreeMutationUpdated).editorText,
      'Service branch prompt',
    );

    final created = await service.createSession(project.identity.projectId);
    expect(created.summary.workingDirectory, '/Projects/service');

    final promptId = PiCommandId('service-prompt');
    expect(
      await service.submitPrompt(
        commandId: promptId,
        sessionId: session.id,
        prompt: 'Inspect the project',
      ),
      isA<PiCommandAccepted>(),
    );
    expect(api.lastPrompt?.prompt, 'Inspect the project');

    final abortId = PiCommandId('service-abort');
    expect(
      await service.abort(commandId: abortId, sessionId: session.id),
      isA<PiCommandAccepted>(),
    );
    expect(api.lastAbort?.sessionId, session.id);

    await api.close();
  });

  test(
    'reports explicit remote-node-required and unsupported states',
    () async {
      final androidApi = createAppPiNodeApi(
        capabilities: PlatformCapabilities.resolve(
          isWeb: false,
          targetPlatform: TargetPlatform.android,
        ),
      );
      final webApi = createAppPiNodeApi(
        capabilities: PlatformCapabilities.resolve(
          isWeb: true,
          targetPlatform: TargetPlatform.linux,
        ),
      );

      final androidService = WorkspaceService(androidApi);
      final webService = WorkspaceService(webApi);
      expect(
        androidService.availability,
        PiNodeCompositionAvailability.remoteNodeRequired,
      );
      expect(
        webService.availability,
        PiNodeCompositionAvailability.unsupported,
      );

      await expectLater(
        androidService.connect(),
        throwsA(
          isA<PiNodeCompositionException>().having(
            (error) => error.code,
            'code',
            PiNodeCompositionErrorCode.remoteNodeRequired,
          ),
        ),
      );
      await expectLater(
        webService.connect(),
        throwsA(
          isA<PiNodeCompositionException>().having(
            (error) => error.code,
            'code',
            PiNodeCompositionErrorCode.unsupported,
          ),
        ),
      );
      expect(
        androidService.describeError(
          const PiNodeCompositionException(
            PiNodeCompositionErrorCode.remoteNodeRequired,
          ),
        ),
        contains('requires a remote Pi Node'),
      );

      await androidApi.close();
      await webApi.close();
    },
  );
}
