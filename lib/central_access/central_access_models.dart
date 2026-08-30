enum CentralSessionStatus {
  unknown,
  anonymous,
  active,
  reauthenticationRequired,
}

enum WorkspaceLifecycle { provisioning, active, suspended, closing }

enum WorkspaceEntitlementStatus { subscriptionRequired, active, suspended }

enum WorkspaceNodeStatus { unknown, offline, online }

enum WorkspaceAccessStatus {
  provisioning,
  subscriptionRequired,
  active,
  suspended,
  nodeOffline,
}

/// Validates server-provided Workspace origins against trusted local
/// configuration without constructing the origin on behalf of the server.
final class WorkspaceOriginPolicy {
  WorkspaceOriginPolicy.managedBaseDomain(String managedBaseDomain)
    : managedBaseDomain = _validatedManagedBaseDomain(managedBaseDomain);

  final String managedBaseDomain;

  Uri validate({required String slug, required Uri origin}) {
    final expectedHost = '$slug.$managedBaseDomain';
    final hasRootPathOnly = origin.path.isEmpty || origin.path == '/';
    if (origin.scheme != 'https' ||
        !origin.hasAuthority ||
        origin.host.toLowerCase() != expectedHost ||
        origin.userInfo.isNotEmpty ||
        origin.hasPort ||
        !hasRootPathOnly ||
        origin.hasQuery ||
        origin.hasFragment) {
      throw ArgumentError(
        'origin must be a credential-free HTTPS origin under the configured '
        'Friday Workspace domain.',
      );
    }
    return origin;
  }
}

final class CentralUserProjection {
  CentralUserProjection({required String userId, String? displayEmail})
    : userId = _validatedOpaqueId(userId, name: 'userId'),
      displayEmail = _validatedDisplayEmail(displayEmail);

  final String userId;
  final String? displayEmail;

  @override
  String toString() => 'CentralUserProjection(<redacted>)';
}

final class CentralSessionProjection {
  CentralSessionProjection({required this.status, this.user}) {
    if ((status == CentralSessionStatus.active) != (user != null)) {
      throw ArgumentError(
        'An active central session must contain exactly one safe user projection.',
      );
    }
  }

  final CentralSessionStatus status;
  final CentralUserProjection? user;

  @override
  String toString() => 'CentralSessionProjection(status: $status)';
}

final class WorkspaceProjection {
  WorkspaceProjection({
    required String workspaceId,
    required String slug,
    required Uri origin,
    required WorkspaceOriginPolicy originPolicy,
    required this.lifecycle,
    required this.entitlementStatus,
    required this.nodeStatus,
    required this.accessStatus,
  }) : workspaceId = _validatedOpaqueId(workspaceId, name: 'workspaceId'),
       slug = _validatedSlug(slug),
       origin = originPolicy.validate(slug: slug, origin: origin);

  final String workspaceId;
  final String slug;
  final Uri origin;
  final WorkspaceLifecycle lifecycle;
  final WorkspaceEntitlementStatus entitlementStatus;
  final WorkspaceNodeStatus nodeStatus;

  /// The authoritative Friday Relay access decision.
  ///
  /// The client displays this value and must not recompute authorization from
  /// lifecycle, entitlement, or node status projections.
  final WorkspaceAccessStatus accessStatus;

  @override
  String toString() =>
      'WorkspaceProjection(accessStatus: $accessStatus, <redacted>)';
}

String _validatedManagedBaseDomain(String value) {
  if (value.isEmpty ||
      value.trim() != value ||
      value.toLowerCase() != value ||
      value == 'localhost' ||
      value.endsWith('.localhost') ||
      value.endsWith('.local') ||
      value.endsWith('.internal') ||
      RegExp(r'^\d{1,3}(?:\.\d{1,3}){3}$').hasMatch(value)) {
    throw ArgumentError('Invalid managed Workspace base domain.');
  }
  final labels = value.split('.');
  if (labels.length < 2 || labels.any((label) => !_isDnsLabel(label))) {
    throw ArgumentError('Invalid managed Workspace base domain.');
  }
  return value;
}

String _validatedOpaqueId(String value, {required String name}) {
  if (value.isEmpty ||
      value.length > 256 ||
      value.trim() != value ||
      _containsControlCharacter(value)) {
    throw ArgumentError('Invalid $name.');
  }
  return value;
}

String _validatedSlug(String value) {
  if (!_isDnsLabel(value)) {
    throw ArgumentError('Invalid Workspace slug.');
  }
  return value;
}

bool _isDnsLabel(String value) =>
    RegExp(r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$').hasMatch(value);

String? _validatedDisplayEmail(String? value) {
  if (value == null) {
    return null;
  }
  final separator = value.indexOf('@');
  if (value.isEmpty ||
      value.length > 320 ||
      value.trim() != value ||
      _containsControlCharacter(value) ||
      value.contains(RegExp(r'\s')) ||
      separator <= 0 ||
      separator != value.lastIndexOf('@') ||
      separator == value.length - 1) {
    throw ArgumentError('Invalid displayEmail.');
  }
  return value;
}

bool _containsControlCharacter(String value) =>
    value.codeUnits.any((codeUnit) => codeUnit <= 0x1f || codeUnit == 0x7f);
