import 'dart:typed_data';

import 'pi_protocol_version.dart';

/// Semantic adapter boundary for the future generated Protobuf codec.
///
/// Implementations own binary encoding and decoding. The Flutter client only
/// depends on these hand-written messages and never interprets wire bytes.
abstract interface class PiProtocolCodec {
  Uint8List encode(PiClientProtocolMessage message);

  PiServerProtocolMessage decode(Uint8List frame);
}

sealed class PiClientProtocolMessage {
  const PiClientProtocolMessage();
}

final class PiProtocolHandshakeOfferMessage extends PiClientProtocolMessage {
  const PiProtocolHandshakeOfferMessage(this.offer);

  final PiProtocolOffer offer;
}

sealed class PiProtocolRequestMessage extends PiClientProtocolMessage {
  PiProtocolRequestMessage({required int requestId})
    : requestId = _validatedPositiveInt(requestId, 'requestId');

  final int requestId;
}

final class PiProtocolGetProjectBootstrapRequest
    extends PiProtocolRequestMessage {
  PiProtocolGetProjectBootstrapRequest({required super.requestId});
}

final class PiProtocolBrowseDirectoryRequest extends PiProtocolRequestMessage {
  PiProtocolBrowseDirectoryRequest({
    required super.requestId,
    required String directory,
    required int maxChildren,
  }) : directory = _validatedPath(directory),
       maxChildren = _validatedBoundedCount(maxChildren, 'maxChildren', 128);

  final String directory;
  final int maxChildren;

  @override
  String toString() =>
      'PiProtocolBrowseDirectoryRequest(requestId: $requestId, <redacted>)';
}

final class PiProtocolValidateProjectRequest extends PiProtocolRequestMessage {
  PiProtocolValidateProjectRequest({
    required super.requestId,
    required String candidateDirectory,
  }) : candidateDirectory = _validatedPath(candidateDirectory);

  final String candidateDirectory;

  @override
  String toString() =>
      'PiProtocolValidateProjectRequest(requestId: $requestId, <redacted>)';
}

final class PiProtocolListKnownProjectsRequest
    extends PiProtocolRequestMessage {
  PiProtocolListKnownProjectsRequest({
    required super.requestId,
    required int maxProjects,
  }) : maxProjects = _validatedBoundedCount(maxProjects, 'maxProjects', 64);

  final int maxProjects;
}

final class PiProtocolApproveProjectTrustRequest
    extends PiProtocolRequestMessage {
  PiProtocolApproveProjectTrustRequest({
    required super.requestId,
    required String projectId,
    required String trustRevision,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId'),
       trustRevision = _validatedOpaqueId(trustRevision, 'trustRevision');

  final String projectId;
  final String trustRevision;

  @override
  String toString() =>
      'PiProtocolApproveProjectTrustRequest(requestId: $requestId, <redacted>)';
}

final class PiProtocolListSessionsRequest extends PiProtocolRequestMessage {
  PiProtocolListSessionsRequest({
    required super.requestId,
    required String projectId,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId');

  final String projectId;
}

final class PiProtocolGetSessionRequest extends PiProtocolRequestMessage {
  PiProtocolGetSessionRequest({
    required super.requestId,
    required String sessionId,
    required String projectId,
  }) : sessionId = _validatedOpaqueId(sessionId, 'sessionId'),
       projectId = _validatedOpaqueId(projectId, 'projectId');

  final String sessionId;
  final String projectId;
}

final class PiProtocolCreateSessionRequest extends PiProtocolRequestMessage {
  PiProtocolCreateSessionRequest({
    required super.requestId,
    required String projectId,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId');

  final String projectId;

  @override
  String toString() =>
      'PiProtocolCreateSessionRequest(requestId: $requestId, <redacted>)';
}

sealed class PiProtocolCommandRequest extends PiProtocolRequestMessage {
  PiProtocolCommandRequest({
    required super.requestId,
    required String commandId,
    required String sessionId,
  }) : commandId = _validatedOpaqueId(commandId, 'commandId'),
       sessionId = _validatedOpaqueId(sessionId, 'sessionId');

  final String commandId;
  final String sessionId;
}

final class PiProtocolPromptCommandRequest extends PiProtocolCommandRequest {
  PiProtocolPromptCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.sessionId,
    required String prompt,
  }) : prompt = _validatedText(prompt, 'prompt', allowEmpty: false);

  final String prompt;

  @override
  String toString() =>
      'PiProtocolPromptCommandRequest(requestId: $requestId, <redacted>)';
}

final class PiProtocolAbortCommandRequest extends PiProtocolCommandRequest {
  PiProtocolAbortCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.sessionId,
  });

  @override
  String toString() =>
      'PiProtocolAbortCommandRequest(requestId: $requestId, <redacted>)';
}

sealed class PiServerProtocolMessage {
  const PiServerProtocolMessage();
}

enum PiProtocolCapability {
  sessionRead,
  sessionCreate,
  promptCommand,
  abortCommand,
  sessionEvents,
  projectDiscovery,
  projectTrust,
}

final class PiProtocolHandshakeAcceptedMessage extends PiServerProtocolMessage {
  PiProtocolHandshakeAcceptedMessage({
    required this.negotiatedVersion,
    Iterable<PiProtocolCapability> capabilities =
        const <PiProtocolCapability>[],
  }) : capabilities = Set<PiProtocolCapability>.unmodifiable(capabilities);

  final PiProtocolVersion negotiatedVersion;
  final Set<PiProtocolCapability> capabilities;
}

final class PiProtocolHandshakeRejectedMessage extends PiServerProtocolMessage {
  PiProtocolHandshakeRejectedMessage({required this.failure});

  final PiProtocolFailure failure;
}

sealed class PiProtocolResponseMessage extends PiServerProtocolMessage {
  PiProtocolResponseMessage({required int requestId})
    : requestId = _validatedPositiveInt(requestId, 'requestId');

  final int requestId;
}

final class PiProtocolProjectBootstrapResponse
    extends PiProtocolResponseMessage {
  PiProtocolProjectBootstrapResponse({
    required super.requestId,
    required String homeDirectory,
    required this.defaultProject,
  }) : homeDirectory = _validatedPath(homeDirectory);

  final String homeDirectory;
  final PiProtocolProjectSnapshot defaultProject;
}

final class PiProtocolDirectoryResponse extends PiProtocolResponseMessage {
  PiProtocolDirectoryResponse({
    required super.requestId,
    required this.directory,
  });

  final PiProtocolDirectoryListing directory;
}

final class PiProtocolProjectValidatedResponse
    extends PiProtocolResponseMessage {
  PiProtocolProjectValidatedResponse({
    required super.requestId,
    required this.project,
  });

  final PiProtocolProjectSnapshot project;
}

final class PiProtocolKnownProjectsResponse extends PiProtocolResponseMessage {
  PiProtocolKnownProjectsResponse({
    required super.requestId,
    required Iterable<PiProtocolKnownProjectSnapshot> projects,
  }) : projects = List<PiProtocolKnownProjectSnapshot>.unmodifiable(projects);

  final List<PiProtocolKnownProjectSnapshot> projects;
}

final class PiProtocolProjectTrustApprovedResponse
    extends PiProtocolResponseMessage {
  PiProtocolProjectTrustApprovedResponse({
    required super.requestId,
    required this.project,
  });

  final PiProtocolProjectSnapshot project;
}

final class PiProtocolSessionsResponse extends PiProtocolResponseMessage {
  PiProtocolSessionsResponse({
    required super.requestId,
    required Iterable<PiProtocolSessionSummary> sessions,
  }) : sessions = List<PiProtocolSessionSummary>.unmodifiable(sessions);

  final List<PiProtocolSessionSummary> sessions;
}

final class PiProtocolSessionResponse extends PiProtocolResponseMessage {
  PiProtocolSessionResponse({required super.requestId, required this.session});

  final PiProtocolSessionDetail session;
}

final class PiProtocolSessionCreatedResponse extends PiProtocolResponseMessage {
  PiProtocolSessionCreatedResponse({
    required super.requestId,
    required this.session,
  });

  final PiProtocolSessionDetail session;
}

final class PiProtocolRequestRejectedMessage extends PiProtocolResponseMessage {
  PiProtocolRequestRejectedMessage({
    required super.requestId,
    required this.failure,
  });

  final PiProtocolFailure failure;
}

sealed class PiProtocolCommandResponseMessage
    extends PiProtocolResponseMessage {
  PiProtocolCommandResponseMessage({
    required super.requestId,
    required String commandId,
  }) : commandId = _validatedOpaqueId(commandId, 'commandId');

  final String commandId;
}

final class PiProtocolCommandAcceptedMessage
    extends PiProtocolCommandResponseMessage {
  PiProtocolCommandAcceptedMessage({
    required super.requestId,
    required super.commandId,
  });
}

final class PiProtocolCommandRejectedMessage
    extends PiProtocolCommandResponseMessage {
  PiProtocolCommandRejectedMessage({
    required super.requestId,
    required super.commandId,
    required this.failure,
  });

  final PiProtocolFailure failure;
}

final class PiProtocolCommandUncertainMessage
    extends PiProtocolCommandResponseMessage {
  PiProtocolCommandUncertainMessage({
    required super.requestId,
    required super.commandId,
    required this.failure,
  });

  final PiProtocolFailure failure;
}

final class PiProtocolSessionEventMessage extends PiServerProtocolMessage {
  PiProtocolSessionEventMessage({
    required String sessionId,
    required int sequence,
    required this.event,
  }) : sessionId = _validatedOpaqueId(sessionId, 'sessionId'),
       sequence = _validatedPositiveInt(sequence, 'sequence');

  final String sessionId;
  final int sequence;
  final PiProtocolSessionEventPayload event;
}

final class PiProtocolFailure {
  PiProtocolFailure({required String code, required this.retryable})
    : code = _validatedMachineCode(code);

  final String code;
  final bool retryable;

  @override
  String toString() =>
      'PiProtocolFailure(code: <redacted>, retryable: $retryable)';
}

enum PiProtocolProjectTrustStatus {
  notRequired,
  trusted,
  approvalRequired,
  denied,
}

enum PiProtocolProjectTrustReason {
  piSettings,
  piExtensions,
  piSkills,
  piPrompts,
  piThemes,
  piSystemPrompt,
  agentSkills,
  savedApproval,
  savedDenial,
}

final class PiProtocolProjectIdentity {
  PiProtocolProjectIdentity({
    required String projectId,
    required String canonicalWorkingDirectory,
    required this.isGitRepository,
    String? gitRoot,
    String? mainWorktreeRoot,
    String? branch,
    required this.isLinkedWorktree,
    required this.isDetachedHead,
    required String worktreeId,
    required String mainProjectId,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId'),
       canonicalWorkingDirectory = _validatedPath(canonicalWorkingDirectory),
       gitRoot = gitRoot == null ? null : _validatedPath(gitRoot),
       mainWorktreeRoot = mainWorktreeRoot == null
           ? null
           : _validatedPath(mainWorktreeRoot),
       branch = branch == null
           ? null
           : _validatedText(branch, 'branch', allowEmpty: false),
       worktreeId = _validatedOpaqueId(worktreeId, 'worktreeId'),
       mainProjectId = _validatedOpaqueId(mainProjectId, 'mainProjectId') {
    if (isGitRepository &&
        (this.gitRoot == null || this.mainWorktreeRoot == null)) {
      throw ArgumentError('Git project identity requires Git roots.');
    }
    if (!isGitRepository &&
        (this.gitRoot != null ||
            this.mainWorktreeRoot != null ||
            this.branch != null ||
            isLinkedWorktree ||
            isDetachedHead)) {
      throw ArgumentError('Non-Git project identity contains Git-only fields.');
    }
    if (isDetachedHead && this.branch != null) {
      throw ArgumentError(
        'Detached project identity must not contain a branch.',
      );
    }
  }

  final String projectId;
  final String canonicalWorkingDirectory;
  final bool isGitRepository;
  final String? gitRoot;
  final String? mainWorktreeRoot;
  final String? branch;
  final bool isLinkedWorktree;
  final bool isDetachedHead;
  final String worktreeId;
  final String mainProjectId;

  @override
  String toString() => 'PiProtocolProjectIdentity(<redacted>)';
}

final class PiProtocolProjectTrustSnapshot {
  PiProtocolProjectTrustSnapshot({
    required this.status,
    required Iterable<PiProtocolProjectTrustReason> reasons,
    required String revision,
  }) : reasons = List<PiProtocolProjectTrustReason>.unmodifiable(reasons),
       revision = _validatedOpaqueId(revision, 'trustRevision') {
    if (status == PiProtocolProjectTrustStatus.notRequired &&
        this.reasons.isNotEmpty) {
      throw ArgumentError(
        'A trust-free project must not contain trust reasons.',
      );
    }
    if (status != PiProtocolProjectTrustStatus.notRequired &&
        this.reasons.isEmpty) {
      throw ArgumentError(
        'A restricted or trusted project requires trust reasons.',
      );
    }
  }

  final PiProtocolProjectTrustStatus status;
  final List<PiProtocolProjectTrustReason> reasons;
  final String revision;

  @override
  String toString() => 'PiProtocolProjectTrustSnapshot(<redacted>)';
}

final class PiProtocolProjectSnapshot {
  const PiProtocolProjectSnapshot({
    required this.identity,
    required this.trust,
  });

  final PiProtocolProjectIdentity identity;
  final PiProtocolProjectTrustSnapshot trust;

  @override
  String toString() => 'PiProtocolProjectSnapshot(<redacted>)';
}

final class PiProtocolKnownProjectSnapshot {
  PiProtocolKnownProjectSnapshot({
    required this.project,
    required DateTime lastSessionAt,
    required int sessionCount,
  }) : lastSessionAt = _validatedUtcInstant(lastSessionAt, 'lastSessionAt'),
       sessionCount = _validatedPositiveInt(sessionCount, 'sessionCount');

  final PiProtocolProjectSnapshot project;
  final DateTime lastSessionAt;
  final int sessionCount;

  @override
  String toString() => 'PiProtocolKnownProjectSnapshot(<redacted>)';
}

final class PiProtocolDirectoryEntry {
  PiProtocolDirectoryEntry({
    required String name,
    required String canonicalPath,
    required this.isSymbolicLink,
  }) : name = _validatedText(name, 'name', allowEmpty: false),
       canonicalPath = _validatedPath(canonicalPath);

  final String name;
  final String canonicalPath;
  final bool isSymbolicLink;

  @override
  String toString() => 'PiProtocolDirectoryEntry(<redacted>)';
}

final class PiProtocolDirectoryListing {
  PiProtocolDirectoryListing({
    required String canonicalDirectory,
    String? parentDirectory,
    required Iterable<PiProtocolDirectoryEntry> children,
    required this.truncated,
  }) : canonicalDirectory = _validatedPath(canonicalDirectory),
       parentDirectory = parentDirectory == null
           ? null
           : _validatedPath(parentDirectory),
       children = List<PiProtocolDirectoryEntry>.unmodifiable(children);

  final String canonicalDirectory;
  final String? parentDirectory;
  final List<PiProtocolDirectoryEntry> children;
  final bool truncated;

  @override
  String toString() => 'PiProtocolDirectoryListing(<redacted>)';
}

enum PiProtocolMessageRole { user, assistant, tool, system }

final class PiProtocolSessionSummary {
  PiProtocolSessionSummary({
    required String id,
    required String title,
    required String workingDirectory,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.isRunning,
    required this.hasUnread,
  }) : id = _validatedOpaqueId(id, 'sessionId'),
       title = _validatedText(title, 'title', allowEmpty: false),
       workingDirectory = _validatedPath(workingDirectory),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt'),
       updatedAt = _validatedUtcInstant(updatedAt, 'updatedAt') {
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt must not be before createdAt.');
    }
  }

  final String id;
  final String title;
  final String workingDirectory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRunning;
  final bool hasUnread;

  @override
  String toString() => 'PiProtocolSessionSummary(<redacted>)';
}

final class PiProtocolSessionDetail {
  PiProtocolSessionDetail({
    required this.summary,
    required Iterable<PiProtocolMessageSnapshot> messages,
  }) : messages = List<PiProtocolMessageSnapshot>.unmodifiable(messages);

  final PiProtocolSessionSummary summary;
  final List<PiProtocolMessageSnapshot> messages;

  @override
  String toString() => 'PiProtocolSessionDetail(<redacted>)';
}

final class PiProtocolMessageSnapshot {
  PiProtocolMessageSnapshot({
    required String id,
    required this.role,
    required String text,
    required DateTime createdAt,
    required this.isStreaming,
  }) : id = _validatedOpaqueId(id, 'messageId'),
       text = _validatedText(text, 'text'),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt');

  final String id;
  final PiProtocolMessageRole role;
  final String text;
  final DateTime createdAt;
  final bool isStreaming;

  @override
  String toString() => 'PiProtocolMessageSnapshot(role: $role, <redacted>)';
}

sealed class PiProtocolSessionEventPayload {
  const PiProtocolSessionEventPayload();
}

final class PiProtocolMessageAddedEvent extends PiProtocolSessionEventPayload {
  const PiProtocolMessageAddedEvent(this.message);

  final PiProtocolMessageSnapshot message;
}

final class PiProtocolMessageDeltaEvent extends PiProtocolSessionEventPayload {
  PiProtocolMessageDeltaEvent({
    required String messageId,
    required String delta,
  }) : messageId = _validatedOpaqueId(messageId, 'messageId'),
       delta = _validatedText(delta, 'delta');

  final String messageId;
  final String delta;

  @override
  String toString() => 'PiProtocolMessageDeltaEvent(<redacted>)';
}

final class PiProtocolSessionRunningChangedEvent
    extends PiProtocolSessionEventPayload {
  const PiProtocolSessionRunningChangedEvent({required this.isRunning});

  final bool isRunning;
}

final class PiProtocolCommandCompletedEvent
    extends PiProtocolSessionEventPayload {
  PiProtocolCommandCompletedEvent({
    required String commandId,
    required this.succeeded,
  }) : commandId = _validatedOpaqueId(commandId, 'commandId');

  final String commandId;
  final bool succeeded;
}

int _validatedBoundedCount(int value, String name, int maximum) {
  if (value < 0 || value > maximum) {
    throw ArgumentError('$name is outside the supported range.');
  }
  return value;
}

int _validatedPositiveInt(int value, String name) {
  if (value <= 0) throw ArgumentError('$name must be positive.');
  return value;
}

String _validatedOpaqueId(String value, String name) {
  if (value.isEmpty ||
      value.length > 256 ||
      value.trim() != value ||
      _containsForbiddenControl(value)) {
    throw ArgumentError('Invalid $name.');
  }
  return value;
}

String _validatedMachineCode(String value) {
  if (!RegExp(r'^[a-z][a-z0-9_]{0,127}$').hasMatch(value)) {
    throw ArgumentError('Invalid protocol failure code.');
  }
  return value;
}

String _validatedPath(String value) {
  if (value.isEmpty ||
      value.length > 32768 ||
      value.trim() != value ||
      _containsForbiddenControl(value)) {
    throw ArgumentError('Invalid workingDirectory.');
  }
  return value;
}

String _validatedText(String value, String name, {bool allowEmpty = true}) {
  if ((!allowEmpty && value.trim().isEmpty) ||
      value.length > 1048576 ||
      value.contains('\u0000')) {
    throw ArgumentError('Invalid $name.');
  }
  return value;
}

DateTime _validatedUtcInstant(DateTime value, String name) {
  if (!value.isUtc) throw ArgumentError('$name must be in UTC.');
  return value;
}

bool _containsForbiddenControl(String value) =>
    value.codeUnits.any((unit) => unit <= 0x1f || unit == 0x7f);
