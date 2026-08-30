import '../../protocol/pi_protocol.dart';

enum PiNodeErrorCode {
  authenticationRequired,
  permissionDenied,
  notFound,
  invalidRequest,
  conflict,
  nodeBusy,
  cancelled,
  deadlineExceeded,
  failedPrecondition,
  protocolMismatch,
  malformedFrame,
  unexpectedResponse,
  disconnected,
  closed,
  remoteRejected,
}

/// A stable, redacted error safe to expose to application state and logs.
final class PiNodeException implements Exception {
  const PiNodeException(this.code, {required this.retryable});

  factory PiNodeException.fromProtocolFailure(PiProtocolFailure failure) =>
      PiNodeException(
        _mapProtocolFailureCode(failure.code),
        retryable: failure.retryable,
      );

  final PiNodeErrorCode code;
  final bool retryable;

  @override
  String toString() =>
      'PiNodeException(code: ${code.name}, retryable: $retryable, '
      'details: <redacted>)';
}

PiNodeErrorCode _mapProtocolFailureCode(String value) => switch (value) {
  'authentication_required' => PiNodeErrorCode.authenticationRequired,
  'permission_denied' => PiNodeErrorCode.permissionDenied,
  'session_not_found' || 'not_found' => PiNodeErrorCode.notFound,
  'invalid_request' => PiNodeErrorCode.invalidRequest,
  'conflict' => PiNodeErrorCode.conflict,
  'node_busy' => PiNodeErrorCode.nodeBusy,
  'cancelled' => PiNodeErrorCode.cancelled,
  'deadline_exceeded' => PiNodeErrorCode.deadlineExceeded,
  'failed_precondition' => PiNodeErrorCode.failedPrecondition,
  'protocol_version_unsupported' => PiNodeErrorCode.protocolMismatch,
  _ => PiNodeErrorCode.remoteRejected,
};
