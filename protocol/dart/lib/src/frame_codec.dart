import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';

import 'gen/pi/client/protocol/v0/protocol.pb.dart';
import 'limits.dart';

final _semanticVersionPattern = RegExp(
  r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'
  r'(?:-((?:0|[1-9]\d*|[0-9A-Za-z-]*[A-Za-z-][0-9A-Za-z-]*)'
  r'(?:\.(?:0|[1-9]\d*|[0-9A-Za-z-]*[A-Za-z-][0-9A-Za-z-]*))*))?'
  r'(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$',
);
final _knownCapabilities = <Capability>{
  Capability.CAPABILITY_SESSION_READ,
  Capability.CAPABILITY_SESSION_CREATE,
  Capability.CAPABILITY_PROMPT_COMMAND,
  Capability.CAPABILITY_ABORT_COMMAND,
  Capability.CAPABILITY_SESSION_EVENTS,
  Capability.CAPABILITY_HEALTH,
  Capability.CAPABILITY_CANCELLATION,
  Capability.CAPABILITY_FLOW_CONTROL,
  Capability.CAPABILITY_TRANSFER,
  Capability.CAPABILITY_PROJECT_DISCOVERY,
  Capability.CAPABILITY_PROJECT_TRUST,
  Capability.CAPABILITY_SESSION_ADMIN,
};
final _knownHealthStatuses = <HealthStatus>{
  HealthStatus.HEALTH_STATUS_STARTING,
  HealthStatus.HEALTH_STATUS_SERVING,
  HealthStatus.HEALTH_STATUS_DEGRADED,
  HealthStatus.HEALTH_STATUS_STOPPING,
};
final _knownProjectTrustStatuses = <ProjectTrustStatus>{
  ProjectTrustStatus.PROJECT_TRUST_STATUS_NOT_REQUIRED,
  ProjectTrustStatus.PROJECT_TRUST_STATUS_TRUSTED,
  ProjectTrustStatus.PROJECT_TRUST_STATUS_APPROVAL_REQUIRED,
  ProjectTrustStatus.PROJECT_TRUST_STATUS_DENIED,
};
final _knownProjectTrustReasons = <ProjectTrustReason>{
  ProjectTrustReason.PROJECT_TRUST_REASON_PI_SETTINGS,
  ProjectTrustReason.PROJECT_TRUST_REASON_PI_EXTENSIONS,
  ProjectTrustReason.PROJECT_TRUST_REASON_PI_SKILLS,
  ProjectTrustReason.PROJECT_TRUST_REASON_PI_PROMPTS,
  ProjectTrustReason.PROJECT_TRUST_REASON_PI_THEMES,
  ProjectTrustReason.PROJECT_TRUST_REASON_PI_SYSTEM_PROMPT,
  ProjectTrustReason.PROJECT_TRUST_REASON_AGENT_SKILLS,
  ProjectTrustReason.PROJECT_TRUST_REASON_SAVED_APPROVAL,
  ProjectTrustReason.PROJECT_TRUST_REASON_SAVED_DENIAL,
};
final _knownMessageRoles = <MessageRole>{
  MessageRole.MESSAGE_ROLE_USER,
  MessageRole.MESSAGE_ROLE_ASSISTANT,
  MessageRole.MESSAGE_ROLE_TOOL,
  MessageRole.MESSAGE_ROLE_SYSTEM,
};
final _knownTransferDirections = <TransferDirection>{
  TransferDirection.TRANSFER_DIRECTION_UPLOAD,
  TransferDirection.TRANSFER_DIRECTION_DOWNLOAD,
};
final _knownTransferPurposes = <TransferPurpose>{
  TransferPurpose.TRANSFER_PURPOSE_FILE,
  TransferPurpose.TRANSFER_PURPOSE_ATTACHMENT,
  TransferPurpose.TRANSFER_PURPOSE_EXPORT,
};
final _knownErrorCodes = <ErrorCode>{
  ErrorCode.ERROR_CODE_AUTHENTICATION_REQUIRED,
  ErrorCode.ERROR_CODE_PERMISSION_DENIED,
  ErrorCode.ERROR_CODE_NOT_FOUND,
  ErrorCode.ERROR_CODE_INVALID_REQUEST,
  ErrorCode.ERROR_CODE_CONFLICT,
  ErrorCode.ERROR_CODE_NODE_BUSY,
  ErrorCode.ERROR_CODE_PROTOCOL_VERSION_UNSUPPORTED,
  ErrorCode.ERROR_CODE_CANCELLED,
  ErrorCode.ERROR_CODE_DEADLINE_EXCEEDED,
  ErrorCode.ERROR_CODE_UNAVAILABLE,
  ErrorCode.ERROR_CODE_DATA_LOSS,
  ErrorCode.ERROR_CODE_INTERNAL,
  ErrorCode.ERROR_CODE_PROTOCOL_VIOLATION,
  ErrorCode.ERROR_CODE_RESOURCE_EXHAUSTED,
  ErrorCode.ERROR_CODE_ALREADY_EXISTS,
  ErrorCode.ERROR_CODE_FAILED_PRECONDITION,
};

final class FrameValidationException implements Exception {
  FrameValidationException(this.message);

  final String message;

  @override
  String toString() => 'FrameValidationException: $message';
}

Uint8List encodeTransportFrame(PiTransportFrame frame) {
  validateTransportFrame(frame);
  final bytes = frame.writeToBuffer();
  _validateFrameByteLength(bytes.length);
  return bytes;
}

PiTransportFrame decodeTransportFrame(List<int> bytes) {
  _validateFrameByteLength(bytes.length);
  final frame = PiTransportFrame.fromBuffer(bytes);
  validateTransportFrame(frame);
  return frame;
}

void validateTransportFrame(PiTransportFrame frame) {
  _validatePositiveUint64('frame_sequence', frame.frameSequence);

  switch (frame.whichOperation()) {
    case PiTransportFrame_Operation.clientProtocolOffer:
      final offer = frame.clientProtocolOffer;
      _validateProtocolVersions(
        'client protocol offer',
        offer.protocolVersions,
        required: true,
      );
      _validateCapabilities(offer.capabilities);
      _validateIdentifier('client_instance_id', offer.clientInstanceId);
      _validateRequiredShortText(
        'implementation_name',
        offer.implementationName,
      );
      _validateSemanticVersion(
        'implementation_version',
        offer.implementationVersion,
      );
      _validateAdvertisedLimits(
        offer.maxFrameBytes,
        offer.maxTransferChunkBytes,
      );
      return;
    case PiTransportFrame_Operation.serverHandshakeAccepted:
      final accepted = frame.serverHandshakeAccepted;
      if (!accepted.hasSelectedProtocolVersion()) {
        _fail('accepted handshake must contain a selected protocol version');
      }
      _validateProtocolVersion(accepted.selectedProtocolVersion);
      _validateCapabilities(accepted.capabilities);
      _validateIdentifier('node_instance_id', accepted.nodeInstanceId);
      _validateRequiredShortText(
        'implementation_name',
        accepted.implementationName,
      );
      _validateSemanticVersion(
        'implementation_version',
        accepted.implementationVersion,
      );
      _validateAdvertisedLimits(
        accepted.maxFrameBytes,
        accepted.maxTransferChunkBytes,
      );
      return;
    case PiTransportFrame_Operation.serverHandshakeRejected:
      final rejected = frame.serverHandshakeRejected;
      _requireStableError(
        'handshake rejection',
        rejected.hasError(),
        rejected.error,
      );
      _validateProtocolVersions(
        'server supported protocol versions',
        rejected.supportedProtocolVersions,
        required: false,
      );
      return;
    case PiTransportFrame_Operation.healthRequest:
      _validateRequestId(frame.healthRequest.requestId);
      return;
    case PiTransportFrame_Operation.healthResponse:
      final response = frame.healthResponse;
      _validateRequestId(response.requestId);
      _validateKnownEnum(
        'health response status',
        response.status,
        _knownHealthStatuses,
      );
      _validateSemanticVersion('node_version', response.nodeVersion);
      return;
    case PiTransportFrame_Operation.getProjectBootstrapRequest:
      _validateRequestId(frame.getProjectBootstrapRequest.requestId);
      return;
    case PiTransportFrame_Operation.getProjectBootstrapResponse:
      final response = frame.getProjectBootstrapResponse;
      _validateRequestId(response.requestId);
      _validatePath('home_directory', response.homeDirectory);
      _requireProjectSnapshot(
        'project bootstrap',
        response.hasDefaultProject(),
        response.defaultProject,
      );
      return;
    case PiTransportFrame_Operation.browseDirectoryRequest:
      final request = frame.browseDirectoryRequest;
      _validateRequestId(request.requestId);
      _validatePath('directory', request.directory);
      _validateBoundedUint32(
        'max_children',
        request.maxChildren,
        maxDirectoryChildren,
        allowZero: true,
      );
      return;
    case PiTransportFrame_Operation.browseDirectoryResponse:
      final response = frame.browseDirectoryResponse;
      _validateRequestId(response.requestId);
      _requireDirectoryListing(
        'browse directory response',
        response.hasDirectory(),
        response.directory,
      );
      return;
    case PiTransportFrame_Operation.validateProjectRequest:
      final request = frame.validateProjectRequest;
      _validateRequestId(request.requestId);
      _validatePath('candidate_directory', request.candidateDirectory);
      return;
    case PiTransportFrame_Operation.validateProjectResponse:
      final response = frame.validateProjectResponse;
      _validateRequestId(response.requestId);
      _requireProjectSnapshot(
        'validate project response',
        response.hasProject(),
        response.project,
      );
      return;
    case PiTransportFrame_Operation.listKnownProjectsRequest:
      final request = frame.listKnownProjectsRequest;
      _validateRequestId(request.requestId);
      _validateBoundedUint32(
        'max_projects',
        request.maxProjects,
        maxKnownProjects,
        allowZero: true,
      );
      return;
    case PiTransportFrame_Operation.listKnownProjectsResponse:
      final response = frame.listKnownProjectsResponse;
      _validateRequestId(response.requestId);
      if (response.projects.length > maxKnownProjects) {
        _fail('known project response exceeds the local hard limit');
      }
      for (final known in response.projects) {
        _requireProjectSnapshot(
          'known project',
          known.hasProject(),
          known.project,
        );
        _validatePositiveUint64(
          'last_session_at_unix_millis',
          known.lastSessionAtUnixMillis,
        );
        _validateBoundedUint32(
          'session_count',
          known.sessionCount,
          0xffffffff,
          allowZero: false,
        );
      }
      return;
    case PiTransportFrame_Operation.approveProjectTrustRequest:
      final request = frame.approveProjectTrustRequest;
      _validateRequestId(request.requestId);
      _validateIdentifier('project_id', request.projectId);
      _validateIdentifier('trust_revision', request.trustRevision);
      return;
    case PiTransportFrame_Operation.approveProjectTrustResponse:
      final response = frame.approveProjectTrustResponse;
      _validateRequestId(response.requestId);
      _requireProjectSnapshot(
        'project trust approval',
        response.hasProject(),
        response.project,
      );
      return;
    case PiTransportFrame_Operation.listSessionsRequest:
      _validateRequestId(frame.listSessionsRequest.requestId);
      _validateIdentifier('project_id', frame.listSessionsRequest.projectId);
      return;
    case PiTransportFrame_Operation.listSessionsResponse:
      final response = frame.listSessionsResponse;
      _validateRequestId(response.requestId);
      if (response.sessions.length > maxSessionsPerResponse) {
        _fail('session response count exceeds the local hard limit');
      }
      final sessionIds = <String>{};
      for (final session in response.sessions) {
        _validateSessionSummary(session);
        if (!sessionIds.add(session.sessionId)) {
          _fail('session response contains a duplicate session_id');
        }
      }
      return;
    case PiTransportFrame_Operation.getSessionRequest:
      final request = frame.getSessionRequest;
      _validateRequestId(request.requestId);
      _validateIdentifier('session_id', request.sessionId);
      _validateIdentifier('project_id', request.projectId);
      return;
    case PiTransportFrame_Operation.getSessionResponse:
      final response = frame.getSessionResponse;
      _validateRequestId(response.requestId);
      _requireSessionDetail(
        'get session response',
        response.hasSession(),
        response.session,
      );
      return;
    case PiTransportFrame_Operation.createSessionRequest:
      final request = frame.createSessionRequest;
      _validateRequestId(request.requestId);
      _validateIdentifier('project_id', request.projectId);
      return;
    case PiTransportFrame_Operation.createSessionResponse:
      final response = frame.createSessionResponse;
      _validateRequestId(response.requestId);
      _requireSessionDetail(
        'create session response',
        response.hasSession(),
        response.session,
      );
      return;
    case PiTransportFrame_Operation.promptCommand:
      final command = frame.promptCommand;
      _validateRequestId(command.requestId);
      _validateIdentifier('command_id', command.commandId);
      _validateIdentifier('session_id', command.sessionId);
      _validateContentText('prompt', command.prompt, required: true);
      return;
    case PiTransportFrame_Operation.abortCommand:
      final command = frame.abortCommand;
      _validateRequestId(command.requestId);
      _validateIdentifier('command_id', command.commandId);
      _validateIdentifier('session_id', command.sessionId);
      return;
    case PiTransportFrame_Operation.renameSessionCommand:
      final command = frame.renameSessionCommand;
      _validateSessionAdminCommand(
        command.requestId,
        command.commandId,
        command.projectId,
        command.sessionId,
      );
      _validateRequiredShortText('session name', command.name);
      return;
    case PiTransportFrame_Operation.clearSessionNameCommand:
      final command = frame.clearSessionNameCommand;
      _validateSessionAdminCommand(
        command.requestId,
        command.commandId,
        command.projectId,
        command.sessionId,
      );
      return;
    case PiTransportFrame_Operation.autoNameSessionCommand:
      final command = frame.autoNameSessionCommand;
      _validateSessionAdminCommand(
        command.requestId,
        command.commandId,
        command.projectId,
        command.sessionId,
      );
      if (command.timeoutMillis < 1000 || command.timeoutMillis > 30000) {
        _fail('auto-name timeout is outside the supported bounds');
      }
      return;
    case PiTransportFrame_Operation.deleteSessionCommand:
      final command = frame.deleteSessionCommand;
      _validateSessionAdminCommand(
        command.requestId,
        command.commandId,
        command.projectId,
        command.sessionId,
      );
      if (!command.hasConfirmation()) {
        _fail('delete session command must contain confirmation evidence');
      }
      final confirmation = command.confirmation;
      _validateIdentifier('confirmation session_id', confirmation.sessionId);
      _validateIdentifier(
        'confirmation admin_revision',
        confirmation.adminRevision,
      );
      _validateRequiredShortText(
        'confirmation displayed_title',
        confirmation.displayedTitle,
      );
      if (!confirmation.destructiveActionAcknowledged ||
          confirmation.sessionId != command.sessionId) {
        _fail('delete confirmation evidence is incomplete');
      }
      return;
    case PiTransportFrame_Operation.sessionAdminCommandOutcome:
      final outcome = frame.sessionAdminCommandOutcome;
      _validateRequestId(outcome.requestId);
      _validateIdentifier('command_id', outcome.commandId);
      if (outcome.operation ==
          SessionAdminOperation.SESSION_ADMIN_OPERATION_UNSPECIFIED) {
        _fail('session administration outcome must identify its operation');
      }
      switch (outcome.whichOutcome()) {
        case SessionAdminCommandOutcome_Outcome.session:
          _validateSessionSummary(outcome.session);
          if (outcome.operation ==
              SessionAdminOperation.SESSION_ADMIN_OPERATION_DELETE) {
            _fail('delete outcome cannot contain an updated session');
          }
          return;
        case SessionAdminCommandOutcome_Outcome.deletion:
          _validateIdentifier('deleted session_id', outcome.deletion.sessionId);
          if (outcome.operation !=
              SessionAdminOperation.SESSION_ADMIN_OPERATION_DELETE) {
            _fail('only delete outcomes may contain deletion evidence');
          }
          return;
        case SessionAdminCommandOutcome_Outcome.error:
          _requireStableError(
            'session administration outcome',
            outcome.hasError(),
            outcome.error,
          );
          return;
        case SessionAdminCommandOutcome_Outcome.notSet:
          _fail('session administration outcome must contain a typed result');
      }
    case PiTransportFrame_Operation.requestRejected:
      final rejected = frame.requestRejected;
      _validateRequestId(rejected.requestId);
      _requireStableError(
        'request rejection',
        rejected.hasError(),
        rejected.error,
      );
      return;
    case PiTransportFrame_Operation.commandAccepted:
      final accepted = frame.commandAccepted;
      _validateRequestId(accepted.requestId);
      _validateIdentifier('command_id', accepted.commandId);
      return;
    case PiTransportFrame_Operation.commandRejected:
      final rejected = frame.commandRejected;
      _validateRequestId(rejected.requestId);
      _validateIdentifier('command_id', rejected.commandId);
      _requireStableError(
        'command rejection',
        rejected.hasError(),
        rejected.error,
      );
      return;
    case PiTransportFrame_Operation.sessionEventStream:
      final stream = frame.sessionEventStream;
      _validateIdentifier('stream_id', stream.streamId);
      _validateIdentifier('session_id', stream.sessionId);
      _validatePositiveUint64('event_sequence', stream.eventSequence);
      switch (stream.whichEvent()) {
        case SessionEventStreamEnvelope_Event.messageAdded:
          if (!stream.messageAdded.hasMessage()) {
            _fail('message added event must contain a message snapshot');
          }
          _validateMessageSnapshot(stream.messageAdded.message);
          return;
        case SessionEventStreamEnvelope_Event.messageDelta:
          _validateIdentifier('message_id', stream.messageDelta.messageId);
          _validateContentText(
            'message delta',
            stream.messageDelta.delta,
            required: true,
          );
          return;
        case SessionEventStreamEnvelope_Event.runningChanged:
          return;
        case SessionEventStreamEnvelope_Event.commandCompleted:
          final completed = stream.commandCompleted;
          _validateIdentifier('command_id', completed.commandId);
          _validateCompletionError(completed);
          return;
        case SessionEventStreamEnvelope_Event.streamClosed:
          _validateStreamClosed(stream.streamClosed);
          return;
        case SessionEventStreamEnvelope_Event.notSet:
          _fail('session event stream must contain a typed event');
      }
    case PiTransportFrame_Operation.eventStream:
      final stream = frame.eventStream;
      _validateIdentifier('stream_id', stream.streamId);
      _validatePositiveUint64('event_sequence', stream.eventSequence);
      switch (stream.whichEvent()) {
        case EventStreamEnvelope_Event.heartbeat:
          _validatePositiveUint64(
            'observed_unix_millis',
            stream.heartbeat.observedUnixMillis,
          );
          return;
        case EventStreamEnvelope_Event.healthStatusChanged:
          final event = stream.healthStatusChanged;
          _validateKnownEnum(
            'health status event',
            event.status,
            _knownHealthStatuses,
          );
          _validateShortText('health summary', event.summary, required: false);
          return;
        case EventStreamEnvelope_Event.streamClosed:
          _validateStreamClosed(stream.streamClosed);
          return;
        case EventStreamEnvelope_Event.notSet:
          _fail('event stream envelope must contain a typed event');
      }
    case PiTransportFrame_Operation.cancel:
      final cancel = frame.cancel;
      switch (cancel.whichTarget()) {
        case Cancel_Target.requestId:
          _validateRequestId(cancel.requestId);
        case Cancel_Target.streamId:
          _validateIdentifier('stream_id', cancel.streamId);
        case Cancel_Target.transferId:
          _validateIdentifier('transfer_id', cancel.transferId);
        case Cancel_Target.notSet:
          _fail('cancel must contain a target identifier');
      }
      _validateShortText('cancel reason', cancel.reason, required: false);
      return;
    case PiTransportFrame_Operation.windowUpdate:
      final update = frame.windowUpdate;
      switch (update.whichTarget()) {
        case WindowUpdate_Target.streamId:
          _validateIdentifier('stream_id', update.streamId);
        case WindowUpdate_Target.transferId:
          _validateIdentifier('transfer_id', update.transferId);
        case WindowUpdate_Target.notSet:
          _fail('window update must contain a target identifier');
      }
      if (update.creditMessages == 0 && update.creditBytes.isZero) {
        _fail('window update must grant message or byte credit');
      }
      return;
    case PiTransportFrame_Operation.transferOpen:
      final transfer = frame.transferOpen;
      _validateIdentifier('transfer_id', transfer.transferId);
      _validateKnownEnum(
        'transfer direction',
        transfer.direction,
        _knownTransferDirections,
      );
      _validateKnownEnum(
        'transfer purpose',
        transfer.purpose,
        _knownTransferPurposes,
      );
      _validateShortText('content_type', transfer.contentType, required: false);
      _validateShortText('file_name', transfer.fileName, required: false);
      if (transfer.chunkBytes <= 0 ||
          transfer.chunkBytes > maxTransferChunkBytes) {
        _fail('transfer chunk_bytes is outside the local hard limit');
      }
      _validateDigest(transfer.sha256);
      return;
    case PiTransportFrame_Operation.transferChunk:
      final chunk = frame.transferChunk;
      _validateIdentifier('transfer_id', chunk.transferId);
      _validatePositiveUint64('chunk_sequence', chunk.chunkSequence);
      if (chunk.data.isEmpty || chunk.data.length > maxTransferChunkBytes) {
        _fail('transfer chunk data is outside the local hard limit');
      }
      return;
    case PiTransportFrame_Operation.transferAck:
      final ack = frame.transferAck;
      _validateIdentifier('transfer_id', ack.transferId);
      _validatePositiveUint64(
        'acknowledged_sequence',
        ack.acknowledgedSequence,
      );
      return;
    case PiTransportFrame_Operation.transferComplete:
      final complete = frame.transferComplete;
      _validateIdentifier('transfer_id', complete.transferId);
      _validateDigest(complete.sha256);
      return;
    case PiTransportFrame_Operation.transferAbort:
      final abort = frame.transferAbort;
      _validateIdentifier('transfer_id', abort.transferId);
      _requireStableError('transfer abort', abort.hasError(), abort.error);
      return;
    case PiTransportFrame_Operation.error:
      final envelope = frame.error;
      switch (envelope.whichCorrelation()) {
        case ErrorEnvelope_Correlation.requestId:
          _validateRequestId(envelope.requestId);
        case ErrorEnvelope_Correlation.streamId:
          _validateIdentifier('stream_id', envelope.streamId);
        case ErrorEnvelope_Correlation.transferId:
          _validateIdentifier('transfer_id', envelope.transferId);
        case ErrorEnvelope_Correlation.notSet:
          break;
      }
      _requireStableError(
        'error envelope',
        envelope.hasError(),
        envelope.error,
      );
      return;
    case PiTransportFrame_Operation.notSet:
      _fail('transport frame must contain a typed operation');
  }
}

void _validateAdvertisedLimits(
  int advertisedFrameBytes,
  int advertisedTransferChunkBytes,
) {
  if (advertisedFrameBytes <= 0 || advertisedFrameBytes > maxFrameBytes) {
    _fail('advertised max_frame_bytes is outside the local hard limit');
  }
  if (advertisedTransferChunkBytes <= 0 ||
      advertisedTransferChunkBytes > maxTransferChunkBytes) {
    _fail(
      'advertised max_transfer_chunk_bytes is outside the local hard limit',
    );
  }
}

void _validateProtocolVersions(
  String label,
  List<ProtocolVersion> versions, {
  required bool required,
}) {
  if (required && versions.isEmpty) {
    _fail('$label must contain at least one protocol version');
  }
  if (versions.length > maxProtocolVersions) {
    _fail('$label exceeds the local protocol version limit');
  }
  final seen = <String>{};
  for (final version in versions) {
    _validateProtocolVersion(version);
    final key = '${version.major}.${version.minor}.${version.patch}';
    if (!seen.add(key)) {
      _fail('$label contains a duplicate protocol version');
    }
  }
}

void _validateProtocolVersion(ProtocolVersion version) {
  if (version.major != 0) {
    _fail('v0 protocol versions must use major zero');
  }
}

void _validateCapabilities(List<Capability> capabilities) {
  if (capabilities.length > maxCapabilities) {
    _fail('capability count exceeds the local hard limit');
  }
  final seen = <Capability>{};
  for (final capability in capabilities) {
    _validateKnownEnum('capability', capability, _knownCapabilities);
    if (!seen.add(capability)) {
      _fail('capability list contains a duplicate');
    }
  }
}

void _requireDirectoryListing(
  String label,
  bool present,
  DirectoryListingSnapshot listing,
) {
  if (!present) {
    _fail('$label must contain a directory listing');
  }
  _validatePath('canonical_directory', listing.canonicalDirectory);
  if (listing.parentDirectory.isNotEmpty) {
    _validatePath('parent_directory', listing.parentDirectory);
  }
  if (listing.children.length > maxDirectoryChildren) {
    _fail('directory child count exceeds the local hard limit');
  }
  final names = <String>{};
  for (final child in listing.children) {
    _validateRequiredShortText('directory child name', child.name);
    _validatePath('directory child canonical_path', child.canonicalPath);
    if (!names.add(child.name)) {
      _fail('directory listing contains a duplicate child name');
    }
  }
}

void _requireProjectSnapshot(
  String label,
  bool present,
  ProjectSnapshot project,
) {
  if (!present || !project.hasIdentity() || !project.hasTrust()) {
    _fail('$label must contain project identity and trust snapshots');
  }
  final identity = project.identity;
  _validateIdentifier('project_id', identity.projectId);
  _validatePath(
    'canonical_working_directory',
    identity.canonicalWorkingDirectory,
  );
  _validateIdentifier('worktree_id', identity.worktreeId);
  _validateIdentifier('main_project_id', identity.mainProjectId);
  if (identity.isGitRepository) {
    _validatePath('git_root', identity.gitRoot);
    _validatePath('main_worktree_root', identity.mainWorktreeRoot);
    _validateShortText('branch', identity.branch, required: false);
    if (identity.isDetachedHead && identity.branch.isNotEmpty) {
      _fail('a detached project identity must not contain a branch');
    }
  } else if (identity.gitRoot.isNotEmpty ||
      identity.mainWorktreeRoot.isNotEmpty ||
      identity.branch.isNotEmpty ||
      identity.isLinkedWorktree ||
      identity.isDetachedHead) {
    _fail('a non-Git project identity contains Git-only fields');
  }

  final trust = project.trust;
  _validateKnownEnum(
    'project trust status',
    trust.status,
    _knownProjectTrustStatuses,
  );
  _validateIdentifier('project trust revision', trust.revision);
  final reasons = <ProjectTrustReason>{};
  for (final reason in trust.reasons) {
    _validateKnownEnum(
      'project trust reason',
      reason,
      _knownProjectTrustReasons,
    );
    if (!reasons.add(reason)) {
      _fail('project trust reasons contain a duplicate');
    }
  }
  if (trust.status == ProjectTrustStatus.PROJECT_TRUST_STATUS_NOT_REQUIRED &&
      trust.reasons.isNotEmpty) {
    _fail('a not-required project trust snapshot must not contain reasons');
  }
  if (trust.status != ProjectTrustStatus.PROJECT_TRUST_STATUS_NOT_REQUIRED &&
      trust.reasons.isEmpty) {
    _fail('a restricted or trusted project must contain a trust reason');
  }
}

void _requireSessionDetail(
  String label,
  bool hasDetail,
  SessionDetailSnapshot detail,
) {
  if (!hasDetail) {
    _fail('$label must contain a session detail snapshot');
  }
  _validateSessionDetail(detail);
}

void _validateSessionDetail(SessionDetailSnapshot detail) {
  if (!detail.hasSummary()) {
    _fail('session detail must contain a summary snapshot');
  }
  _validateSessionSummary(detail.summary);
  if (detail.messages.length > maxMessagesPerSessionSnapshot) {
    _fail('session message count exceeds the local hard limit');
  }
  final messageIds = <String>{};
  for (final message in detail.messages) {
    _validateMessageSnapshot(message);
    if (!messageIds.add(message.messageId)) {
      _fail('session detail contains a duplicate message_id');
    }
  }
}

void _validateSessionAdminCommand(
  Int64 requestId,
  String commandId,
  String projectId,
  String sessionId,
) {
  _validateRequestId(requestId);
  _validateIdentifier('command_id', commandId);
  _validateIdentifier('project_id', projectId);
  _validateIdentifier('session_id', sessionId);
}

void _validateSessionSummary(SessionSummarySnapshot summary) {
  _validateIdentifier('session_id', summary.sessionId);
  _validateIdentifier('admin_revision', summary.adminRevision);
  _validateRequiredShortText('session title', summary.title);
  _validatePath('working_directory', summary.workingDirectory);
  _validatePositiveUint64(
    'created_at_unix_millis',
    summary.createdAtUnixMillis,
  );
  _validatePositiveUint64(
    'updated_at_unix_millis',
    summary.updatedAtUnixMillis,
  );
  if (_compareUnsigned(
        summary.updatedAtUnixMillis,
        summary.createdAtUnixMillis,
      ) <
      0) {
    _fail('session updated time must not precede its created time');
  }
}

void _validateMessageSnapshot(MessageSnapshot message) {
  _validateIdentifier('message_id', message.messageId);
  _validateKnownEnum('message role', message.role, _knownMessageRoles);
  _validateContentText('message text', message.text, required: false);
  _validatePositiveUint64(
    'created_at_unix_millis',
    message.createdAtUnixMillis,
  );
}

void _validateCompletionError(CommandCompletedEvent completed) {
  if (completed.succeeded) {
    if (completed.hasError()) {
      _fail('successful command completion must not contain an error');
    }
    return;
  }
  _requireStableError(
    'failed command completion',
    completed.hasError(),
    completed.error,
  );
}

void _validateStreamClosed(StreamClosedEvent event) {
  if (event.graceful) {
    if (event.hasError()) {
      _fail('graceful stream close must not contain an error');
    }
    return;
  }
  _requireStableError('ungraceful stream close', event.hasError(), event.error);
}

void _requireStableError(String label, bool hasError, StableError error) {
  if (!hasError) {
    _fail('$label must contain a stable error');
  }
  _validateStableError(error);
}

void _validateStableError(StableError error) {
  _validateKnownEnum('stable error code', error.code, _knownErrorCodes);
  _validateTextBytes(
    'stable error safe_message',
    error.safeMessage,
    maxErrorMessageBytes,
    required: false,
  );
  if (error.retryAfterMillis > 0 && !error.retryable) {
    _fail('retry_after_millis requires retryable=true');
  }
}

void _validateDigest(List<int> digest) {
  if (digest.isNotEmpty && digest.length != sha256Bytes) {
    _fail('sha256 must be empty or exactly 32 bytes');
  }
}

void _validateBoundedUint32(
  String label,
  int value,
  int maximum, {
  required bool allowZero,
}) {
  if (value < (allowZero ? 0 : 1) || value > maximum) {
    _fail('$label is outside the local uint32 limit');
  }
}

void _validateRequestId(Int64 value) {
  _validatePositiveUint64('request_id', value);
}

void _validatePositiveUint64(String label, Int64 value) {
  if (value.isZero) {
    _fail('$label must be a non-zero uint64');
  }
}

int _compareUnsigned(Int64 left, Int64 right) {
  if (left.isNegative != right.isNegative) {
    return left.isNegative ? 1 : -1;
  }
  return left.compareTo(right);
}

void _validateIdentifier(String label, String value) {
  final length = utf8.encode(value).length;
  if (length == 0 ||
      length > maxIdentifierBytes ||
      value.trim() != value ||
      _containsForbiddenControl(value)) {
    _fail('$label is outside the local identifier limit');
  }
}

void _validatePath(String label, String value) {
  final length = utf8.encode(value).length;
  if (length == 0 ||
      length > maxPathBytes ||
      value.trim() != value ||
      _containsForbiddenControl(value)) {
    _fail('$label is outside the local path limit');
  }
}

void _validateRequiredShortText(String label, String value) {
  _validateShortText(label, value, required: true);
}

void _validateShortText(String label, String value, {required bool required}) {
  _validateTextBytes(label, value, maxShortTextBytes, required: required);
}

void _validateContentText(
  String label,
  String value, {
  required bool required,
}) {
  _validateTextBytes(label, value, maxContentTextBytes, required: required);
}

void _validateTextBytes(
  String label,
  String value,
  int maximum, {
  required bool required,
}) {
  final length = utf8.encode(value).length;
  if ((required && value.trim().isEmpty) ||
      length > maximum ||
      value.contains('\u0000')) {
    _fail('$label is outside the local text limit');
  }
}

void _validateSemanticVersion(String label, String value) {
  _validateRequiredShortText(label, value);
  if (!_semanticVersionPattern.hasMatch(value)) {
    _fail('$label must be a SemVer 2.0.0 version');
  }
}

void _validateKnownEnum<T>(String label, T value, Set<T> known) {
  if (!known.contains(value)) {
    _fail('$label must contain a known non-zero enum value');
  }
}

bool _containsForbiddenControl(String value) =>
    value.codeUnits.any((unit) => unit <= 0x1f || unit == 0x7f);

void _validateFrameByteLength(int length) {
  if (length <= 0) {
    _fail('transport frame must contain at least one byte');
  }
  if (length > maxFrameBytes) {
    _fail('transport frame exceeds $maxFrameBytes bytes');
  }
}

Never _fail(String message) {
  throw FrameValidationException(message);
}
