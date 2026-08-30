enum CentralAccessErrorCode {
  authenticationRequired,
  workspaceSubscriptionRequired,
  workspaceForbidden,
  workspaceProvisioning,
  workspaceSuspended,
  nodeOffline,
  serviceUnavailable,
  unexpectedResponse,
}

enum CentralAccessRecovery { login, purchase, contactSupport, wait, retry }

final class CentralAccessException implements Exception {
  const CentralAccessException._({
    required this.code,
    required this.recovery,
    this.statusCode,
  });

  factory CentralAccessException.fromHttpResponse({
    required int statusCode,
    required String machineCode,
  }) {
    final mapped = switch ((statusCode, machineCode)) {
      (401, 'authentication_required') => const CentralAccessException._(
        code: CentralAccessErrorCode.authenticationRequired,
        recovery: CentralAccessRecovery.login,
        statusCode: 401,
      ),
      (402, 'pi_workspace_subscription_required') =>
        const CentralAccessException._(
          code: CentralAccessErrorCode.workspaceSubscriptionRequired,
          recovery: CentralAccessRecovery.purchase,
          statusCode: 402,
        ),
      (403, 'pi_workspace_forbidden') => const CentralAccessException._(
        code: CentralAccessErrorCode.workspaceForbidden,
        recovery: CentralAccessRecovery.contactSupport,
        statusCode: 403,
      ),
      (409, 'pi_workspace_provisioning') => const CentralAccessException._(
        code: CentralAccessErrorCode.workspaceProvisioning,
        recovery: CentralAccessRecovery.wait,
        statusCode: 409,
      ),
      (423, 'pi_workspace_suspended') => const CentralAccessException._(
        code: CentralAccessErrorCode.workspaceSuspended,
        recovery: CentralAccessRecovery.contactSupport,
        statusCode: 423,
      ),
      (503, 'pi_node_offline') => const CentralAccessException._(
        code: CentralAccessErrorCode.nodeOffline,
        recovery: CentralAccessRecovery.retry,
        statusCode: 503,
      ),
      _ => CentralAccessException._(
        code: CentralAccessErrorCode.unexpectedResponse,
        recovery: CentralAccessRecovery.retry,
        statusCode: statusCode,
      ),
    };
    return mapped;
  }

  const CentralAccessException.serviceUnavailable()
    : this._(
        code: CentralAccessErrorCode.serviceUnavailable,
        recovery: CentralAccessRecovery.retry,
      );

  final CentralAccessErrorCode code;
  final CentralAccessRecovery recovery;
  final int? statusCode;

  @override
  String toString() {
    final status = statusCode == null ? '' : ', statusCode: $statusCode';
    return 'CentralAccessException(code: $code$status)';
  }
}
