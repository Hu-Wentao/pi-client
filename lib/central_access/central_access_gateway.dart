import '../platform/auth/platform_auth_adapter.dart';
import 'central_access_models.dart';
import 'workspace_access_grant.dart';

abstract interface class CentralAccessGateway implements PlatformAuthAdapter {
  Stream<CentralSessionProjection> observeSession();

  Future<WorkspaceProjection> loadMyWorkspace();

  Future<WorkspaceAccessGrant> requestWorkspaceAccessGrant(
    WorkspaceAccessGrantRequest request,
  );
}
