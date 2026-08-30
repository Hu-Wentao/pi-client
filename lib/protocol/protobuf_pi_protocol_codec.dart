import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart' as wire;

import 'pi_protocol_codec.dart';
import 'pi_protocol_version.dart';

/// A stable, redacted failure raised while adapting semantic protocol messages.
enum PiProtocolCodecErrorCode {
  malformedFrame,
  unsupportedOperation,
  integerOutOfRange,
  invalidCorrelation,
}

final class PiProtocolCodecException implements Exception {
  const PiProtocolCodecException(this.code);

  final PiProtocolCodecErrorCode code;

  @override
  String toString() =>
      'PiProtocolCodecException(code: ${code.name}, details: <redacted>)';
}

/// Protobuf v0 adapter for the hand-written Flutter protocol boundary.
///
/// The generated package remains a wire-only dependency. No generated message
/// escapes this codec, and unsupported operations fail closed.
final class ProtobufPiProtocolCodec implements PiProtocolCodec {
  ProtobufPiProtocolCodec({
    required this.clientInstanceId,
    required this.implementationVersion,
    this.implementationName = 'pi-client',
  });

  final String clientInstanceId;
  final String implementationName;
  final String implementationVersion;

  final Map<int, _RequestCorrelation> _requestCorrelations =
      <int, _RequestCorrelation>{};
  var _nextFrameSequence = 1;
  var _frameSequenceExhausted = false;

  @override
  Uint8List encode(PiClientProtocolMessage message) {
    final frameSequence = _currentFrameSequence();
    final frame = switch (message) {
      PiProtocolHandshakeOfferMessage(:final offer) => wire.PiTransportFrame(
        frameSequence: _wirePositiveInt(frameSequence),
        clientProtocolOffer: wire.ClientProtocolOffer(
          protocolVersions: offer.versions.map(_wireVersion),
          capabilities: _clientCapabilities,
          clientInstanceId: clientInstanceId,
          implementationName: implementationName,
          implementationVersion: implementationVersion,
          maxFrameBytes: wire.maxFrameBytes,
          maxTransferChunkBytes: wire.maxTransferChunkBytes,
        ),
      ),
      PiProtocolGetProjectBootstrapRequest(:final requestId) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          getProjectBootstrapRequest: wire.GetProjectBootstrapRequest(
            requestId: _wirePositiveInt(requestId),
          ),
        ),
      PiProtocolBrowseDirectoryRequest(
        :final requestId,
        :final directory,
        :final maxChildren,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          browseDirectoryRequest: wire.BrowseDirectoryRequest(
            requestId: _wirePositiveInt(requestId),
            directory: directory,
            maxChildren: maxChildren,
          ),
        ),
      PiProtocolValidateProjectRequest(
        :final requestId,
        :final candidateDirectory,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          validateProjectRequest: wire.ValidateProjectRequest(
            requestId: _wirePositiveInt(requestId),
            candidateDirectory: candidateDirectory,
          ),
        ),
      PiProtocolListKnownProjectsRequest(
        :final requestId,
        :final maxProjects,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          listKnownProjectsRequest: wire.ListKnownProjectsRequest(
            requestId: _wirePositiveInt(requestId),
            maxProjects: maxProjects,
          ),
        ),
      PiProtocolApproveProjectTrustRequest(
        :final requestId,
        :final projectId,
        :final trustRevision,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          approveProjectTrustRequest: wire.ApproveProjectTrustRequest(
            requestId: _wirePositiveInt(requestId),
            projectId: projectId,
            trustRevision: trustRevision,
          ),
        ),
      PiProtocolListSessionsRequest(:final requestId, :final projectId) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          listSessionsRequest: wire.ListSessionsRequest(
            requestId: _wirePositiveInt(requestId),
            projectId: projectId,
          ),
        ),
      PiProtocolGetSessionRequest(
        :final requestId,
        :final sessionId,
        :final projectId,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          getSessionRequest: wire.GetSessionRequest(
            requestId: _wirePositiveInt(requestId),
            sessionId: sessionId,
            projectId: projectId,
          ),
        ),
      PiProtocolCreateSessionRequest(:final requestId, :final projectId) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          createSessionRequest: wire.CreateSessionRequest(
            requestId: _wirePositiveInt(requestId),
            projectId: projectId,
          ),
        ),
      PiProtocolPromptCommandRequest(
        :final requestId,
        :final commandId,
        :final sessionId,
        :final prompt,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          promptCommand: wire.PromptCommand(
            requestId: _wirePositiveInt(requestId),
            commandId: commandId,
            sessionId: sessionId,
            prompt: prompt,
          ),
        ),
      PiProtocolAbortCommandRequest(
        :final requestId,
        :final commandId,
        :final sessionId,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          abortCommand: wire.AbortCommand(
            requestId: _wirePositiveInt(requestId),
            commandId: commandId,
            sessionId: sessionId,
          ),
        ),
    };

    Uint8List encoded;
    try {
      encoded = wire.encodeTransportFrame(frame);
    } catch (_) {
      throw const PiProtocolCodecException(
        PiProtocolCodecErrorCode.malformedFrame,
      );
    }

    _recordRequest(message);
    _advanceFrameSequence();
    return encoded;
  }

  @override
  PiServerProtocolMessage decode(Uint8List frame) {
    late final wire.PiTransportFrame decoded;
    try {
      decoded = wire.decodeTransportFrame(frame);
    } catch (_) {
      throw const PiProtocolCodecException(
        PiProtocolCodecErrorCode.malformedFrame,
      );
    }

    try {
      return _decodeValidatedFrame(decoded);
    } on PiProtocolCodecException {
      rethrow;
    } catch (_) {
      throw const PiProtocolCodecException(
        PiProtocolCodecErrorCode.malformedFrame,
      );
    }
  }

  PiServerProtocolMessage _decodeValidatedFrame(
    wire.PiTransportFrame frame,
  ) => switch (frame.whichOperation()) {
    wire.PiTransportFrame_Operation.serverHandshakeAccepted =>
      PiProtocolHandshakeAcceptedMessage(
        negotiatedVersion: _semanticVersion(
          frame.serverHandshakeAccepted.selectedProtocolVersion,
        ),
        capabilities: frame.serverHandshakeAccepted.capabilities.map(
          _semanticCapability,
        ),
      ),
    wire.PiTransportFrame_Operation.serverHandshakeRejected =>
      PiProtocolHandshakeRejectedMessage(
        failure: _semanticFailure(frame.serverHandshakeRejected.error),
      ),
    wire.PiTransportFrame_Operation.getProjectBootstrapResponse =>
      _decodeProjectBootstrapResponse(frame.getProjectBootstrapResponse),
    wire.PiTransportFrame_Operation.browseDirectoryResponse =>
      _decodeDirectoryResponse(frame.browseDirectoryResponse),
    wire.PiTransportFrame_Operation.validateProjectResponse =>
      _decodeProjectValidatedResponse(frame.validateProjectResponse),
    wire.PiTransportFrame_Operation.listKnownProjectsResponse =>
      _decodeKnownProjectsResponse(frame.listKnownProjectsResponse),
    wire.PiTransportFrame_Operation.approveProjectTrustResponse =>
      _decodeProjectTrustApprovedResponse(frame.approveProjectTrustResponse),
    wire.PiTransportFrame_Operation.listSessionsResponse =>
      _decodeSessionsResponse(frame.listSessionsResponse),
    wire.PiTransportFrame_Operation.getSessionResponse =>
      _decodeSessionResponse(frame.getSessionResponse),
    wire.PiTransportFrame_Operation.createSessionResponse =>
      _decodeSessionCreatedResponse(frame.createSessionResponse),
    wire.PiTransportFrame_Operation.requestRejected => _decodeRequestRejected(
      frame.requestRejected,
    ),
    wire.PiTransportFrame_Operation.commandAccepted => _decodeCommandAccepted(
      frame.commandAccepted,
    ),
    wire.PiTransportFrame_Operation.commandRejected => _decodeCommandRejected(
      frame.commandRejected,
    ),
    wire.PiTransportFrame_Operation.sessionEventStream => _decodeSessionEvent(
      frame.sessionEventStream,
    ),
    wire.PiTransportFrame_Operation.error => _decodeErrorEnvelope(frame.error),
    _ => throw const PiProtocolCodecException(
      PiProtocolCodecErrorCode.unsupportedOperation,
    ),
  };

  PiProtocolProjectBootstrapResponse _decodeProjectBootstrapResponse(
    wire.GetProjectBootstrapResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolProjectBootstrapResponse(
      requestId: requestId,
      homeDirectory: response.homeDirectory,
      defaultProject: _semanticProject(response.defaultProject),
    );
  }

  PiProtocolDirectoryResponse _decodeDirectoryResponse(
    wire.BrowseDirectoryResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolDirectoryResponse(
      requestId: requestId,
      directory: _semanticDirectory(response.directory),
    );
  }

  PiProtocolProjectValidatedResponse _decodeProjectValidatedResponse(
    wire.ValidateProjectResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolProjectValidatedResponse(
      requestId: requestId,
      project: _semanticProject(response.project),
    );
  }

  PiProtocolKnownProjectsResponse _decodeKnownProjectsResponse(
    wire.ListKnownProjectsResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolKnownProjectsResponse(
      requestId: requestId,
      projects: response.projects.map(
        (known) => PiProtocolKnownProjectSnapshot(
          project: _semanticProject(known.project),
          lastSessionAt: _semanticInstant(known.lastSessionAtUnixMillis),
          sessionCount: _semanticPositiveUint32(known.sessionCount),
        ),
      ),
    );
  }

  PiProtocolProjectTrustApprovedResponse _decodeProjectTrustApprovedResponse(
    wire.ApproveProjectTrustResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolProjectTrustApprovedResponse(
      requestId: requestId,
      project: _semanticProject(response.project),
    );
  }

  PiProtocolSessionsResponse _decodeSessionsResponse(
    wire.ListSessionsResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolSessionsResponse(
      requestId: requestId,
      sessions: response.sessions.map(_semanticSessionSummary),
    );
  }

  PiProtocolSessionResponse _decodeSessionResponse(
    wire.GetSessionResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolSessionResponse(
      requestId: requestId,
      session: _semanticSessionDetail(response.session),
    );
  }

  PiProtocolSessionCreatedResponse _decodeSessionCreatedResponse(
    wire.CreateSessionResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolSessionCreatedResponse(
      requestId: requestId,
      session: _semanticSessionDetail(response.session),
    );
  }

  PiProtocolRequestRejectedMessage _decodeRequestRejected(
    wire.RequestRejected rejected,
  ) {
    final requestId = _semanticPositiveInt(rejected.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolRequestRejectedMessage(
      requestId: requestId,
      failure: _semanticFailure(rejected.error),
    );
  }

  PiProtocolCommandAcceptedMessage _decodeCommandAccepted(
    wire.CommandAccepted accepted,
  ) {
    final requestId = _semanticPositiveInt(accepted.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolCommandAcceptedMessage(
      requestId: requestId,
      commandId: accepted.commandId,
    );
  }

  PiProtocolCommandRejectedMessage _decodeCommandRejected(
    wire.CommandRejected rejected,
  ) {
    final requestId = _semanticPositiveInt(rejected.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolCommandRejectedMessage(
      requestId: requestId,
      commandId: rejected.commandId,
      failure: _semanticFailure(rejected.error),
    );
  }

  PiServerProtocolMessage _decodeErrorEnvelope(wire.ErrorEnvelope envelope) {
    if (envelope.whichCorrelation() !=
        wire.ErrorEnvelope_Correlation.requestId) {
      throw const PiProtocolCodecException(
        PiProtocolCodecErrorCode.unsupportedOperation,
      );
    }

    final requestId = _semanticPositiveInt(envelope.requestId);
    final correlation = _requestCorrelations.remove(requestId);
    final failure = _semanticFailure(envelope.error);
    return switch (correlation) {
      _CommandCorrelation(:final commandId) =>
        PiProtocolCommandUncertainMessage(
          requestId: requestId,
          commandId: commandId,
          failure: failure,
        ),
      _RegularRequestCorrelation() || null => PiProtocolRequestRejectedMessage(
        requestId: requestId,
        failure: failure,
      ),
    };
  }

  PiProtocolSessionEventMessage _decodeSessionEvent(
    wire.SessionEventStreamEnvelope envelope,
  ) {
    final event = switch (envelope.whichEvent()) {
      wire.SessionEventStreamEnvelope_Event.messageAdded =>
        PiProtocolMessageAddedEvent(
          _semanticMessage(envelope.messageAdded.message),
        ),
      wire.SessionEventStreamEnvelope_Event.messageDelta =>
        PiProtocolMessageDeltaEvent(
          messageId: envelope.messageDelta.messageId,
          delta: envelope.messageDelta.delta,
        ),
      wire.SessionEventStreamEnvelope_Event.runningChanged =>
        PiProtocolSessionRunningChangedEvent(
          isRunning: envelope.runningChanged.isRunning,
        ),
      wire.SessionEventStreamEnvelope_Event.commandCompleted =>
        PiProtocolCommandCompletedEvent(
          commandId: envelope.commandCompleted.commandId,
          succeeded: envelope.commandCompleted.succeeded,
        ),
      wire.SessionEventStreamEnvelope_Event.streamClosed ||
      wire.SessionEventStreamEnvelope_Event.notSet =>
        throw const PiProtocolCodecException(
          PiProtocolCodecErrorCode.unsupportedOperation,
        ),
    };

    return PiProtocolSessionEventMessage(
      sessionId: envelope.sessionId,
      sequence: _semanticPositiveInt(envelope.eventSequence),
      event: event,
    );
  }

  PiProtocolProjectSnapshot _semanticProject(wire.ProjectSnapshot project) {
    final identity = project.identity;
    final trust = project.trust;
    return PiProtocolProjectSnapshot(
      identity: PiProtocolProjectIdentity(
        projectId: identity.projectId,
        canonicalWorkingDirectory: identity.canonicalWorkingDirectory,
        isGitRepository: identity.isGitRepository,
        gitRoot: identity.gitRoot.isEmpty ? null : identity.gitRoot,
        mainWorktreeRoot: identity.mainWorktreeRoot.isEmpty
            ? null
            : identity.mainWorktreeRoot,
        branch: identity.branch.isEmpty ? null : identity.branch,
        isLinkedWorktree: identity.isLinkedWorktree,
        isDetachedHead: identity.isDetachedHead,
        worktreeId: identity.worktreeId,
        mainProjectId: identity.mainProjectId,
      ),
      trust: PiProtocolProjectTrustSnapshot(
        status: _semanticProjectTrustStatus(trust.status),
        reasons: trust.reasons.map(_semanticProjectTrustReason),
        revision: trust.revision,
      ),
    );
  }

  PiProtocolDirectoryListing _semanticDirectory(
    wire.DirectoryListingSnapshot directory,
  ) => PiProtocolDirectoryListing(
    canonicalDirectory: directory.canonicalDirectory,
    parentDirectory: directory.parentDirectory.isEmpty
        ? null
        : directory.parentDirectory,
    children: directory.children.map(
      (child) => PiProtocolDirectoryEntry(
        name: child.name,
        canonicalPath: child.canonicalPath,
        isSymbolicLink: child.isSymbolicLink,
      ),
    ),
    truncated: directory.truncated,
  );

  PiProtocolSessionSummary _semanticSessionSummary(
    wire.SessionSummarySnapshot summary,
  ) => PiProtocolSessionSummary(
    id: summary.sessionId,
    title: summary.title,
    workingDirectory: summary.workingDirectory,
    createdAt: _semanticInstant(summary.createdAtUnixMillis),
    updatedAt: _semanticInstant(summary.updatedAtUnixMillis),
    isRunning: summary.isRunning,
    hasUnread: summary.hasUnread,
  );

  PiProtocolSessionDetail _semanticSessionDetail(
    wire.SessionDetailSnapshot detail,
  ) => PiProtocolSessionDetail(
    summary: _semanticSessionSummary(detail.summary),
    messages: detail.messages.map(_semanticMessage),
  );

  PiProtocolMessageSnapshot _semanticMessage(wire.MessageSnapshot message) =>
      PiProtocolMessageSnapshot(
        id: message.messageId,
        role: _semanticRole(message.role),
        text: message.text,
        createdAt: _semanticInstant(message.createdAtUnixMillis),
        isStreaming: message.isStreaming,
      );

  void _recordRequest(PiClientProtocolMessage message) {
    final correlation = switch (message) {
      PiProtocolGetProjectBootstrapRequest() ||
      PiProtocolBrowseDirectoryRequest() ||
      PiProtocolValidateProjectRequest() ||
      PiProtocolListKnownProjectsRequest() ||
      PiProtocolApproveProjectTrustRequest() ||
      PiProtocolListSessionsRequest() ||
      PiProtocolGetSessionRequest() ||
      PiProtocolCreateSessionRequest() => const _RegularRequestCorrelation(),
      PiProtocolPromptCommandRequest(:final commandId) ||
      PiProtocolAbortCommandRequest(
        :final commandId,
      ) => _CommandCorrelation(commandId),
      PiProtocolHandshakeOfferMessage() => null,
    };
    if (correlation == null) return;

    final requestId = (message as PiProtocolRequestMessage).requestId;
    if (_requestCorrelations.containsKey(requestId)) {
      throw const PiProtocolCodecException(
        PiProtocolCodecErrorCode.invalidCorrelation,
      );
    }
    _requestCorrelations[requestId] = correlation;
  }

  int _currentFrameSequence() {
    if (_frameSequenceExhausted) {
      throw const PiProtocolCodecException(
        PiProtocolCodecErrorCode.integerOutOfRange,
      );
    }
    return _nextFrameSequence;
  }

  void _advanceFrameSequence() {
    if (_nextFrameSequence == _maximumExactDartInt) {
      _frameSequenceExhausted = true;
    } else {
      _nextFrameSequence += 1;
    }
  }
}

sealed class _RequestCorrelation {
  const _RequestCorrelation();
}

final class _RegularRequestCorrelation extends _RequestCorrelation {
  const _RegularRequestCorrelation();
}

final class _CommandCorrelation extends _RequestCorrelation {
  const _CommandCorrelation(this.commandId);

  final String commandId;
}

final _maximumExactDartInt64 = Int64(_maximumExactDartInt);
const _maximumExactDartInt = 9007199254740991;
const _maximumUint32 = 0xffffffff;

final _clientCapabilities = <wire.Capability>[
  wire.Capability.CAPABILITY_SESSION_READ,
  wire.Capability.CAPABILITY_SESSION_CREATE,
  wire.Capability.CAPABILITY_PROMPT_COMMAND,
  wire.Capability.CAPABILITY_ABORT_COMMAND,
  wire.Capability.CAPABILITY_SESSION_EVENTS,
  wire.Capability.CAPABILITY_PROJECT_DISCOVERY,
  wire.Capability.CAPABILITY_PROJECT_TRUST,
];

wire.ProtocolVersion _wireVersion(PiProtocolVersion version) {
  if (version.major > _maximumUint32 ||
      version.minor > _maximumUint32 ||
      version.patch > _maximumUint32) {
    throw const PiProtocolCodecException(
      PiProtocolCodecErrorCode.integerOutOfRange,
    );
  }
  return wire.ProtocolVersion(
    major: version.major,
    minor: version.minor,
    patch: version.patch,
  );
}

PiProtocolVersion _semanticVersion(wire.ProtocolVersion version) =>
    PiProtocolVersion(version.major, version.minor, version.patch);

Int64 _wirePositiveInt(int value) {
  if (value <= 0 || value > _maximumExactDartInt) {
    throw const PiProtocolCodecException(
      PiProtocolCodecErrorCode.integerOutOfRange,
    );
  }
  return Int64(value);
}

int _semanticPositiveUint32(int value) {
  if (value <= 0) {
    throw const PiProtocolCodecException(
      PiProtocolCodecErrorCode.integerOutOfRange,
    );
  }
  return value;
}

int _semanticPositiveInt(Int64 value) {
  if (value.isZero ||
      value.isNegative ||
      value.compareTo(_maximumExactDartInt64) > 0) {
    throw const PiProtocolCodecException(
      PiProtocolCodecErrorCode.integerOutOfRange,
    );
  }
  return value.toInt();
}

DateTime _semanticInstant(Int64 unixMillis) {
  final value = _semanticPositiveInt(unixMillis);
  try {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  } catch (_) {
    throw const PiProtocolCodecException(
      PiProtocolCodecErrorCode.integerOutOfRange,
    );
  }
}

PiProtocolCapability _semanticCapability(wire.Capability capability) {
  if (capability == wire.Capability.CAPABILITY_SESSION_READ) {
    return PiProtocolCapability.sessionRead;
  }
  if (capability == wire.Capability.CAPABILITY_SESSION_CREATE) {
    return PiProtocolCapability.sessionCreate;
  }
  if (capability == wire.Capability.CAPABILITY_PROMPT_COMMAND) {
    return PiProtocolCapability.promptCommand;
  }
  if (capability == wire.Capability.CAPABILITY_ABORT_COMMAND) {
    return PiProtocolCapability.abortCommand;
  }
  if (capability == wire.Capability.CAPABILITY_SESSION_EVENTS) {
    return PiProtocolCapability.sessionEvents;
  }
  if (capability == wire.Capability.CAPABILITY_PROJECT_DISCOVERY) {
    return PiProtocolCapability.projectDiscovery;
  }
  if (capability == wire.Capability.CAPABILITY_PROJECT_TRUST) {
    return PiProtocolCapability.projectTrust;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
}

PiProtocolProjectTrustStatus _semanticProjectTrustStatus(
  wire.ProjectTrustStatus status,
) {
  if (status == wire.ProjectTrustStatus.PROJECT_TRUST_STATUS_NOT_REQUIRED) {
    return PiProtocolProjectTrustStatus.notRequired;
  }
  if (status == wire.ProjectTrustStatus.PROJECT_TRUST_STATUS_TRUSTED) {
    return PiProtocolProjectTrustStatus.trusted;
  }
  if (status ==
      wire.ProjectTrustStatus.PROJECT_TRUST_STATUS_APPROVAL_REQUIRED) {
    return PiProtocolProjectTrustStatus.approvalRequired;
  }
  if (status == wire.ProjectTrustStatus.PROJECT_TRUST_STATUS_DENIED) {
    return PiProtocolProjectTrustStatus.denied;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
}

PiProtocolProjectTrustReason _semanticProjectTrustReason(
  wire.ProjectTrustReason reason,
) {
  if (reason == wire.ProjectTrustReason.PROJECT_TRUST_REASON_PI_SETTINGS) {
    return PiProtocolProjectTrustReason.piSettings;
  }
  if (reason == wire.ProjectTrustReason.PROJECT_TRUST_REASON_PI_EXTENSIONS) {
    return PiProtocolProjectTrustReason.piExtensions;
  }
  if (reason == wire.ProjectTrustReason.PROJECT_TRUST_REASON_PI_SKILLS) {
    return PiProtocolProjectTrustReason.piSkills;
  }
  if (reason == wire.ProjectTrustReason.PROJECT_TRUST_REASON_PI_PROMPTS) {
    return PiProtocolProjectTrustReason.piPrompts;
  }
  if (reason == wire.ProjectTrustReason.PROJECT_TRUST_REASON_PI_THEMES) {
    return PiProtocolProjectTrustReason.piThemes;
  }
  if (reason == wire.ProjectTrustReason.PROJECT_TRUST_REASON_PI_SYSTEM_PROMPT) {
    return PiProtocolProjectTrustReason.piSystemPrompt;
  }
  if (reason == wire.ProjectTrustReason.PROJECT_TRUST_REASON_AGENT_SKILLS) {
    return PiProtocolProjectTrustReason.agentSkills;
  }
  if (reason == wire.ProjectTrustReason.PROJECT_TRUST_REASON_SAVED_APPROVAL) {
    return PiProtocolProjectTrustReason.savedApproval;
  }
  if (reason == wire.ProjectTrustReason.PROJECT_TRUST_REASON_SAVED_DENIAL) {
    return PiProtocolProjectTrustReason.savedDenial;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
}

PiProtocolMessageRole _semanticRole(wire.MessageRole role) {
  if (role == wire.MessageRole.MESSAGE_ROLE_USER) {
    return PiProtocolMessageRole.user;
  }
  if (role == wire.MessageRole.MESSAGE_ROLE_ASSISTANT) {
    return PiProtocolMessageRole.assistant;
  }
  if (role == wire.MessageRole.MESSAGE_ROLE_TOOL) {
    return PiProtocolMessageRole.tool;
  }
  if (role == wire.MessageRole.MESSAGE_ROLE_SYSTEM) {
    return PiProtocolMessageRole.system;
  }
  throw const PiProtocolCodecException(PiProtocolCodecErrorCode.malformedFrame);
}

PiProtocolFailure _semanticFailure(wire.StableError error) => PiProtocolFailure(
  code: _semanticErrorCode(error.code),
  retryable: error.retryable,
);

String _semanticErrorCode(wire.ErrorCode code) {
  if (code == wire.ErrorCode.ERROR_CODE_AUTHENTICATION_REQUIRED) {
    return 'authentication_required';
  }
  if (code == wire.ErrorCode.ERROR_CODE_PERMISSION_DENIED) {
    return 'permission_denied';
  }
  if (code == wire.ErrorCode.ERROR_CODE_NOT_FOUND) return 'not_found';
  if (code == wire.ErrorCode.ERROR_CODE_INVALID_REQUEST) {
    return 'invalid_request';
  }
  if (code == wire.ErrorCode.ERROR_CODE_CONFLICT) return 'conflict';
  if (code == wire.ErrorCode.ERROR_CODE_NODE_BUSY) return 'node_busy';
  if (code == wire.ErrorCode.ERROR_CODE_PROTOCOL_VERSION_UNSUPPORTED) {
    return 'protocol_version_unsupported';
  }
  if (code == wire.ErrorCode.ERROR_CODE_CANCELLED) return 'cancelled';
  if (code == wire.ErrorCode.ERROR_CODE_DEADLINE_EXCEEDED) {
    return 'deadline_exceeded';
  }
  if (code == wire.ErrorCode.ERROR_CODE_UNAVAILABLE) return 'unavailable';
  if (code == wire.ErrorCode.ERROR_CODE_DATA_LOSS) return 'data_loss';
  if (code == wire.ErrorCode.ERROR_CODE_INTERNAL) return 'internal';
  if (code == wire.ErrorCode.ERROR_CODE_PROTOCOL_VIOLATION) {
    return 'protocol_violation';
  }
  if (code == wire.ErrorCode.ERROR_CODE_RESOURCE_EXHAUSTED) {
    return 'resource_exhausted';
  }
  if (code == wire.ErrorCode.ERROR_CODE_ALREADY_EXISTS) {
    return 'already_exists';
  }
  if (code == wire.ErrorCode.ERROR_CODE_FAILED_PRECONDITION) {
    return 'failed_precondition';
  }
  throw const PiProtocolCodecException(PiProtocolCodecErrorCode.malformedFrame);
}
