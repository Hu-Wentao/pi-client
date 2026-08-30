import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/central_access/central_access.dart';

void main() {
  group('safe central projections', () {
    final originPolicy = WorkspaceOriginPolicy.managedBaseDomain(
      'pi.example.test',
    );

    test('enforces central session and user invariants', () {
      final user = CentralUserProjection(
        userId: 'user_123',
        displayEmail: 'person@example.test',
      );

      expect(
        CentralSessionProjection(
          status: CentralSessionStatus.active,
          user: user,
        ).user,
        same(user),
      );
      expect(
        () => CentralSessionProjection(status: CentralSessionStatus.active),
        throwsArgumentError,
      );
      expect(
        () => CentralSessionProjection(
          status: CentralSessionStatus.anonymous,
          user: user,
        ),
        throwsArgumentError,
      );
      expect(
        () => CentralUserProjection(userId: ' secret-user-id'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.toString(),
            'redacted user id error',
            isNot(contains('secret-user-id')),
          ),
        ),
      );
      expect(
        () => CentralUserProjection(
          userId: 'user_123',
          displayEmail: 'secret-invalid-email',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.toString(),
            'redacted email error',
            isNot(contains('secret-invalid-email')),
          ),
        ),
      );
      expect(user.toString(), isNot(contains('person@example.test')));
      expect(user.toString(), isNot(contains('user_123')));
    });

    test(
      'validates workspace data without recomputing the server decision',
      () {
        WorkspaceProjection projection({
          WorkspaceLifecycle lifecycle = WorkspaceLifecycle.active,
          WorkspaceEntitlementStatus entitlement =
              WorkspaceEntitlementStatus.active,
          WorkspaceNodeStatus node = WorkspaceNodeStatus.online,
          WorkspaceAccessStatus access = WorkspaceAccessStatus.active,
        }) => WorkspaceProjection(
          workspaceId: 'workspace_123',
          slug: 'my-workspace',
          origin: Uri.parse('https://my-workspace.pi.example.test'),
          originPolicy: originPolicy,
          lifecycle: lifecycle,
          entitlementStatus: entitlement,
          nodeStatus: node,
          accessStatus: access,
        );

        expect(projection().accessStatus, WorkspaceAccessStatus.active);
        expect(
          projection(
            lifecycle: WorkspaceLifecycle.provisioning,
            access: WorkspaceAccessStatus.provisioning,
          ).accessStatus,
          WorkspaceAccessStatus.provisioning,
        );
        expect(
          projection(
            entitlement: WorkspaceEntitlementStatus.subscriptionRequired,
            access: WorkspaceAccessStatus.subscriptionRequired,
          ).accessStatus,
          WorkspaceAccessStatus.subscriptionRequired,
        );
        expect(
          projection(
            node: WorkspaceNodeStatus.offline,
            access: WorkspaceAccessStatus.nodeOffline,
          ).accessStatus,
          WorkspaceAccessStatus.nodeOffline,
        );
        expect(
          projection(
            lifecycle: WorkspaceLifecycle.suspended,
            entitlement: WorkspaceEntitlementStatus.suspended,
            access: WorkspaceAccessStatus.suspended,
          ).accessStatus,
          WorkspaceAccessStatus.suspended,
        );
        expect(
          projection(
            node: WorkspaceNodeStatus.offline,
            access: WorkspaceAccessStatus.active,
          ).accessStatus,
          WorkspaceAccessStatus.active,
          reason: 'The client must preserve the server-provided Decision.',
        );
        expect(
          () => WorkspaceProjection(
            workspaceId: 'workspace_123',
            slug: 'Invalid_Slug',
            origin: Uri.parse('https://example.test'),
            originPolicy: originPolicy,
            lifecycle: WorkspaceLifecycle.active,
            entitlementStatus: WorkspaceEntitlementStatus.active,
            nodeStatus: WorkspaceNodeStatus.online,
            accessStatus: WorkspaceAccessStatus.active,
          ),
          throwsArgumentError,
        );
        expect(
          () => WorkspaceProjection(
            workspaceId: 'workspace_123',
            slug: 'workspace',
            origin: Uri.parse('http://workspace.pi.example.test'),
            originPolicy: originPolicy,
            lifecycle: WorkspaceLifecycle.active,
            entitlementStatus: WorkspaceEntitlementStatus.active,
            nodeStatus: WorkspaceNodeStatus.online,
            accessStatus: WorkspaceAccessStatus.active,
          ),
          throwsArgumentError,
        );
        expect(
          () => WorkspaceProjection(
            workspaceId: 'workspace_123',
            slug: 'workspace',
            origin: Uri.parse('https://attacker.example.test'),
            originPolicy: originPolicy,
            lifecycle: WorkspaceLifecycle.active,
            entitlementStatus: WorkspaceEntitlementStatus.active,
            nodeStatus: WorkspaceNodeStatus.online,
            accessStatus: WorkspaceAccessStatus.active,
          ),
          throwsArgumentError,
        );
        expect(
          () => WorkspaceOriginPolicy.managedBaseDomain('localhost'),
          throwsArgumentError,
        );
        expect(
          () => WorkspaceProjection(
            workspaceId: 'workspace_123',
            slug: 'workspace',
            origin: Uri.parse('https://user:secret@example.test'),
            originPolicy: originPolicy,
            lifecycle: WorkspaceLifecycle.active,
            entitlementStatus: WorkspaceEntitlementStatus.active,
            nodeStatus: WorkspaceNodeStatus.online,
            accessStatus: WorkspaceAccessStatus.active,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.toString(),
              'redacted error',
              isNot(contains('secret')),
            ),
          ),
        );
      },
    );
  });

  test('maps only the stable central access error pairs', () {
    const expected =
        <(int, String, CentralAccessErrorCode, CentralAccessRecovery)>[
          (
            401,
            'authentication_required',
            CentralAccessErrorCode.authenticationRequired,
            CentralAccessRecovery.login,
          ),
          (
            402,
            'pi_workspace_subscription_required',
            CentralAccessErrorCode.workspaceSubscriptionRequired,
            CentralAccessRecovery.purchase,
          ),
          (
            403,
            'pi_workspace_forbidden',
            CentralAccessErrorCode.workspaceForbidden,
            CentralAccessRecovery.contactSupport,
          ),
          (
            409,
            'pi_workspace_provisioning',
            CentralAccessErrorCode.workspaceProvisioning,
            CentralAccessRecovery.wait,
          ),
          (
            423,
            'pi_workspace_suspended',
            CentralAccessErrorCode.workspaceSuspended,
            CentralAccessRecovery.contactSupport,
          ),
          (
            503,
            'pi_node_offline',
            CentralAccessErrorCode.nodeOffline,
            CentralAccessRecovery.retry,
          ),
        ];

    for (final (status, machineCode, code, recovery) in expected) {
      final error = CentralAccessException.fromHttpResponse(
        statusCode: status,
        machineCode: machineCode,
      );
      expect(error.code, code);
      expect(error.recovery, recovery);
      expect(error.statusCode, status);
    }

    final mismatched = CentralAccessException.fromHttpResponse(
      statusCode: 403,
      machineCode: 'authentication_required',
    );
    expect(mismatched.code, CentralAccessErrorCode.unexpectedResponse);
    expect(mismatched.toString(), isNot(contains('authentication_required')));
  });

  group('workspace access grant', () {
    final issuedAt = DateTime.utc(2026, 1, 1, 12);
    final request = WorkspaceAccessGrantRequest(
      clientKeyThumbprint: 'client_thumbprint_123',
      protocolVersion: PiProtocolVersion(0, 0, 1),
    );
    final workspace = WorkspaceProjection(
      workspaceId: 'workspace_123',
      slug: 'my-workspace',
      origin: Uri.parse('https://my-workspace.pi.example.test'),
      originPolicy: WorkspaceOriginPolicy.managedBaseDomain('pi.example.test'),
      lifecycle: WorkspaceLifecycle.active,
      entitlementStatus: WorkspaceEntitlementStatus.active,
      nodeStatus: WorkspaceNodeStatus.online,
      accessStatus: WorkspaceAccessStatus.active,
    );
    final policy = WorkspaceAccessGrantPolicy(
      maxTimeToLive: const Duration(minutes: 5),
      connectPath: '/_pi/connect',
    );

    WorkspaceAccessGrant grant(Uint8List envelope) => WorkspaceAccessGrant(
      request: request,
      workspace: workspace,
      policy: policy,
      grantId: 'grant_123',
      nodeKeyThumbprint: 'node_thumbprint_123',
      connectUri: Uri.parse('wss://my-workspace.pi.example.test/_pi/connect'),
      issuedAt: issuedAt,
      expiresAt: issuedAt.add(policy.maxTimeToLive),
      envelope: envelope,
    );

    test('keeps bindings and envelope opaque, redacted, and copied', () {
      final source = Uint8List.fromList(<int>[1, 2, 3]);
      final accessGrant = grant(source);
      source[0] = 9;

      final firstRead = accessGrant.envelope;
      expect(firstRead, <int>[1, 2, 3]);
      firstRead[1] = 9;
      expect(accessGrant.envelope, <int>[1, 2, 3]);
      expect(accessGrant.workspaceId, workspace.workspaceId);
      expect(accessGrant.workspaceOrigin, workspace.origin);
      expect(accessGrant.clientKeyThumbprint, request.clientKeyThumbprint);
      expect(accessGrant.protocolVersion, request.protocolVersion);
      expect(accessGrant.toString(), isNot(contains('workspace_123')));
      expect(accessGrant.toString(), isNot(contains('1, 2, 3')));
    });

    test('enforces trusted grant lifetime and connection policy', () {
      expect(grant(Uint8List.fromList(<int>[1])), isA<WorkspaceAccessGrant>());
      expect(
        () => WorkspaceAccessGrant(
          request: request,
          workspace: workspace,
          policy: policy,
          grantId: 'grant_123',
          nodeKeyThumbprint: 'node_thumbprint_123',
          connectUri: Uri.parse(
            'wss://my-workspace.pi.example.test/_pi/connect',
          ),
          issuedAt: issuedAt,
          expiresAt: issuedAt.add(const Duration(minutes: 5, seconds: 1)),
          envelope: Uint8List.fromList(<int>[1]),
        ),
        throwsArgumentError,
      );
      expect(
        () => WorkspaceAccessGrant(
          request: request,
          workspace: workspace,
          policy: policy,
          grantId: 'grant_123',
          nodeKeyThumbprint: 'node_thumbprint_123',
          connectUri: Uri.parse(
            'ws://my-workspace.pi.example.test/_pi/connect',
          ),
          issuedAt: issuedAt,
          expiresAt: issuedAt.add(const Duration(minutes: 1)),
          envelope: Uint8List.fromList(<int>[1]),
        ),
        throwsArgumentError,
      );
      expect(
        () => WorkspaceAccessGrant(
          request: request,
          workspace: workspace,
          policy: policy,
          grantId: 'grant_123',
          nodeKeyThumbprint: 'node_thumbprint_123',
          connectUri: Uri.parse('wss://other.pi.example.test/_pi/connect'),
          issuedAt: issuedAt,
          expiresAt: issuedAt.add(const Duration(minutes: 1)),
          envelope: Uint8List.fromList(<int>[1]),
        ),
        throwsArgumentError,
      );
      expect(
        () => WorkspaceAccessGrant(
          request: request,
          workspace: workspace,
          policy: policy,
          grantId: 'grant_123',
          nodeKeyThumbprint: 'node_thumbprint_123',
          connectUri: Uri.parse(
            'wss://my-workspace.pi.example.test/other-path',
          ),
          issuedAt: issuedAt,
          expiresAt: issuedAt.add(const Duration(minutes: 1)),
          envelope: Uint8List.fromList(<int>[1]),
        ),
        throwsArgumentError,
      );
      expect(
        () => WorkspaceAccessGrant(
          request: request,
          workspace: workspace,
          policy: policy,
          grantId: 'grant_123',
          nodeKeyThumbprint: 'node_thumbprint_123',
          connectUri: Uri.parse(
            'wss://my-workspace.pi.example.test/_pi/connect?secret=value',
          ),
          issuedAt: issuedAt,
          expiresAt: issuedAt.add(const Duration(minutes: 1)),
          envelope: Uint8List.fromList(<int>[1]),
        ),
        throwsArgumentError,
      );
      expect(
        () => WorkspaceAccessGrant(
          request: request,
          workspace: workspace,
          policy: policy,
          grantId: 'grant_123',
          nodeKeyThumbprint: 'node_thumbprint_123',
          connectUri: Uri.parse(
            'wss://my-workspace.pi.example.test/_pi/connect',
          ),
          issuedAt: issuedAt,
          expiresAt: issuedAt,
          envelope: Uint8List.fromList(<int>[1]),
        ),
        throwsArgumentError,
      );
      expect(
        () => WorkspaceAccessGrant(
          request: request,
          workspace: workspace,
          policy: policy,
          grantId: 'grant_123',
          nodeKeyThumbprint: 'node_thumbprint_123',
          connectUri: Uri.parse(
            'wss://my-workspace.pi.example.test/_pi/connect',
          ),
          issuedAt: DateTime(2026, 1, 1, 12),
          expiresAt: issuedAt.add(const Duration(minutes: 1)),
          envelope: Uint8List.fromList(<int>[1]),
        ),
        throwsArgumentError,
      );
      expect(() => grant(Uint8List(0)), throwsArgumentError);
    });
  });

  test(
    'CentralAccessGateway derives the personal Workspace server-side',
    () async {
      final gateway = _FakeCentralAccessGateway();
      final request = WorkspaceAccessGrantRequest(
        clientKeyThumbprint: 'client_thumbprint_123',
        protocolVersion: PiProtocolVersion(0, 0, 1),
      );

      expect(gateway, isA<CentralAccessGateway>());
      await gateway.beginLogin();
      expect(
        await gateway.completeLoginCallback(),
        PlatformAuthCallbackResult.completed,
      );

      final grant = await gateway.requestWorkspaceAccessGrant(request);
      expect(grant.workspaceId, 'workspace_123');
      expect(grant.clientKeyThumbprint, request.clientKeyThumbprint);
      expect(request.toString(), isNot(contains('client_thumbprint_123')));
    },
  );
}

final class _FakeCentralAccessGateway implements CentralAccessGateway {
  @override
  Future<void> beginLogin() async {}

  @override
  Future<PlatformAuthCallbackResult> completeLoginCallback() async =>
      PlatformAuthCallbackResult.completed;

  @override
  Future<WorkspaceProjection> loadMyWorkspace() async => WorkspaceProjection(
    workspaceId: 'workspace_123',
    slug: 'my-workspace',
    origin: Uri.parse('https://my-workspace.pi.example.test'),
    originPolicy: WorkspaceOriginPolicy.managedBaseDomain('pi.example.test'),
    lifecycle: WorkspaceLifecycle.active,
    entitlementStatus: WorkspaceEntitlementStatus.active,
    nodeStatus: WorkspaceNodeStatus.online,
    accessStatus: WorkspaceAccessStatus.active,
  );

  @override
  Future<void> logout() async {}

  @override
  Stream<CentralSessionProjection> observeSession() => Stream.value(
    CentralSessionProjection(status: CentralSessionStatus.anonymous),
  );

  @override
  Future<WorkspaceAccessGrant> requestWorkspaceAccessGrant(
    WorkspaceAccessGrantRequest request,
  ) async {
    final now = DateTime.now().toUtc();
    return WorkspaceAccessGrant(
      request: request,
      workspace: await loadMyWorkspace(),
      policy: WorkspaceAccessGrantPolicy(
        maxTimeToLive: const Duration(minutes: 5),
        connectPath: '/_pi/connect',
      ),
      grantId: 'grant_123',
      nodeKeyThumbprint: 'node_thumbprint_123',
      connectUri: Uri.parse('wss://my-workspace.pi.example.test/_pi/connect'),
      issuedAt: now,
      expiresAt: now.add(const Duration(minutes: 1)),
      envelope: Uint8List.fromList(<int>[1]),
    );
  }
}
