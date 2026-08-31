import 'dart:typed_data';

import '../../protocol/pi_protocol.dart';
import 'pi_node_errors.dart';

final class PiSessionId {
  PiSessionId(String value) : value = _validatedOpaqueId(value, 'sessionId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiSessionId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiSessionId(<redacted>)';
}

final class PiMessageId {
  PiMessageId(String value) : value = _validatedOpaqueId(value, 'messageId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiMessageId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiMessageId(<redacted>)';
}

final class PiSessionTreeEntryId {
  PiSessionTreeEntryId(String value)
    : value = _validatedOpaqueId(value, 'sessionTreeEntryId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiSessionTreeEntryId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiSessionTreeEntryId(<redacted>)';
}

final class PiSessionHistoryCursor {
  PiSessionHistoryCursor(String value)
    : value = _validatedShortOpaqueText(value, 'historyCursor');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiSessionHistoryCursor && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiSessionHistoryCursor(<redacted>)';
}

final class PiSessionBranchRevision {
  PiSessionBranchRevision(String value)
    : value = _validatedOpaqueId(value, 'activeBranchRevision');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiSessionBranchRevision && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

final class PiSessionTreeRevision {
  PiSessionTreeRevision(String value)
    : value = _validatedOpaqueId(value, 'treeRevision');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiSessionTreeRevision && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

final class PiSessionAdminRevision {
  PiSessionAdminRevision(String value)
    : value = _validatedOpaqueId(value, 'adminRevision');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiSessionAdminRevision && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiSessionAdminRevision(<redacted>)';
}

final class PiCommandId {
  PiCommandId(String value) : value = _validatedOpaqueId(value, 'commandId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiCommandId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiCommandId(<redacted>)';
}

final class PiProjectId {
  PiProjectId(String value) : value = _validatedOpaqueId(value, 'projectId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiProjectId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiProjectId(<redacted>)';
}

final class PiWorktreeId {
  PiWorktreeId(String value) : value = _validatedOpaqueId(value, 'worktreeId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiWorktreeId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiWorktreeId(<redacted>)';
}

final class PiMainProjectId {
  PiMainProjectId(String value)
    : value = _validatedOpaqueId(value, 'mainProjectId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiMainProjectId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiMainProjectId(<redacted>)';
}

final class PiProjectTrustRevision {
  PiProjectTrustRevision(String value)
    : value = _validatedOpaqueId(value, 'trustRevision');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiProjectTrustRevision && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiProjectTrustRevision(<redacted>)';
}

enum PiProjectTrustStatus { notRequired, trusted, approvalRequired, denied }

enum PiProjectTrustReason {
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

final class PiProjectTrustSnapshot {
  PiProjectTrustSnapshot({
    required this.status,
    required Iterable<PiProjectTrustReason> reasons,
    required this.revision,
  }) : reasons = List<PiProjectTrustReason>.unmodifiable(reasons) {
    if (status == PiProjectTrustStatus.notRequired && this.reasons.isNotEmpty) {
      throw ArgumentError('A trust-free project must not contain reasons.');
    }
    if (status != PiProjectTrustStatus.notRequired && this.reasons.isEmpty) {
      throw ArgumentError('A restricted or trusted project requires reasons.');
    }
  }

  final PiProjectTrustStatus status;
  final List<PiProjectTrustReason> reasons;
  final PiProjectTrustRevision revision;

  bool get allowsProjectResources => status == PiProjectTrustStatus.trusted;
  bool get requiresApproval =>
      status == PiProjectTrustStatus.approvalRequired ||
      status == PiProjectTrustStatus.denied;

  @override
  bool operator ==(Object other) =>
      other is PiProjectTrustSnapshot &&
      status == other.status &&
      revision == other.revision &&
      _sameList(reasons, other.reasons);

  @override
  int get hashCode => Object.hash(status, revision, Object.hashAll(reasons));

  @override
  String toString() =>
      'PiProjectTrustSnapshot(status: $status, reasons: ${reasons.length}, <redacted>)';
}

final class PiProjectIdentity {
  PiProjectIdentity({
    required this.projectId,
    required String canonicalWorkingDirectory,
    required this.isGitRepository,
    String? gitRoot,
    String? mainWorktreeRoot,
    String? branch,
    required this.isLinkedWorktree,
    required this.isDetachedHead,
    required this.worktreeId,
    required this.mainProjectId,
  }) : canonicalWorkingDirectory = _validatedPath(canonicalWorkingDirectory),
       gitRoot = gitRoot == null ? null : _validatedPath(gitRoot),
       mainWorktreeRoot = mainWorktreeRoot == null
           ? null
           : _validatedPath(mainWorktreeRoot),
       branch = branch == null
           ? null
           : _validatedText(branch, 'branch', allowEmpty: false) {
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

  final PiProjectId projectId;
  final String canonicalWorkingDirectory;
  final bool isGitRepository;
  final String? gitRoot;
  final String? mainWorktreeRoot;
  final String? branch;
  final bool isLinkedWorktree;
  final bool isDetachedHead;
  final PiWorktreeId worktreeId;
  final PiMainProjectId mainProjectId;

  @override
  bool operator ==(Object other) =>
      other is PiProjectIdentity &&
      projectId == other.projectId &&
      canonicalWorkingDirectory == other.canonicalWorkingDirectory &&
      isGitRepository == other.isGitRepository &&
      gitRoot == other.gitRoot &&
      mainWorktreeRoot == other.mainWorktreeRoot &&
      branch == other.branch &&
      isLinkedWorktree == other.isLinkedWorktree &&
      isDetachedHead == other.isDetachedHead &&
      worktreeId == other.worktreeId &&
      mainProjectId == other.mainProjectId;

  @override
  int get hashCode => Object.hash(
    projectId,
    canonicalWorkingDirectory,
    isGitRepository,
    gitRoot,
    mainWorktreeRoot,
    branch,
    isLinkedWorktree,
    isDetachedHead,
    worktreeId,
    mainProjectId,
  );

  @override
  String toString() => 'PiProjectIdentity(<redacted>)';
}

final class PiProject {
  const PiProject({required this.identity, required this.trust});

  final PiProjectIdentity identity;
  final PiProjectTrustSnapshot trust;

  @override
  bool operator ==(Object other) =>
      other is PiProject && identity == other.identity && trust == other.trust;

  @override
  int get hashCode => Object.hash(identity, trust);

  @override
  String toString() => 'PiProject(<redacted>)';
}

final class PiKnownProject {
  PiKnownProject({
    required this.project,
    required DateTime lastSessionAt,
    required int sessionCount,
  }) : lastSessionAt = _validatedUtcInstant(lastSessionAt, 'lastSessionAt'),
       sessionCount = _validatedPositiveInt(sessionCount, 'sessionCount');

  final PiProject project;
  final DateTime lastSessionAt;
  final int sessionCount;

  @override
  bool operator ==(Object other) =>
      other is PiKnownProject &&
      project == other.project &&
      lastSessionAt == other.lastSessionAt &&
      sessionCount == other.sessionCount;

  @override
  int get hashCode => Object.hash(project, lastSessionAt, sessionCount);

  @override
  String toString() => 'PiKnownProject(<redacted>)';
}

final class PiProjectBootstrap {
  PiProjectBootstrap({
    required String homeDirectory,
    required this.defaultProject,
  }) : homeDirectory = _validatedPath(homeDirectory);

  final String homeDirectory;
  final PiProject defaultProject;

  @override
  String toString() => 'PiProjectBootstrap(<redacted>)';
}

final class PiDirectoryEntry {
  PiDirectoryEntry({
    required String name,
    required String canonicalPath,
    required this.isSymbolicLink,
  }) : name = _validatedText(name, 'name', allowEmpty: false),
       canonicalPath = _validatedPath(canonicalPath);

  final String name;
  final String canonicalPath;
  final bool isSymbolicLink;

  @override
  bool operator ==(Object other) =>
      other is PiDirectoryEntry &&
      name == other.name &&
      canonicalPath == other.canonicalPath &&
      isSymbolicLink == other.isSymbolicLink;

  @override
  int get hashCode => Object.hash(name, canonicalPath, isSymbolicLink);

  @override
  String toString() => 'PiDirectoryEntry(<redacted>)';
}

final class PiDirectoryListing {
  PiDirectoryListing({
    required String canonicalDirectory,
    String? parentDirectory,
    required Iterable<PiDirectoryEntry> children,
    required this.truncated,
  }) : canonicalDirectory = _validatedPath(canonicalDirectory),
       parentDirectory = parentDirectory == null
           ? null
           : _validatedPath(parentDirectory),
       children = List<PiDirectoryEntry>.unmodifiable(children);

  final String canonicalDirectory;
  final String? parentDirectory;
  final List<PiDirectoryEntry> children;
  final bool truncated;

  @override
  String toString() => 'PiDirectoryListing(<redacted>)';
}

final class PiBrowseDirectoryRequest {
  PiBrowseDirectoryRequest({required String directory, this.maxChildren = 64})
    : directory = _validatedPath(directory) {
    _validatedBoundedCount(maxChildren, 'maxChildren', 128);
  }

  final String directory;
  final int maxChildren;

  @override
  String toString() => 'PiBrowseDirectoryRequest(<redacted>)';
}

final class PiValidateProjectRequest {
  PiValidateProjectRequest({required String candidateDirectory})
    : candidateDirectory = _validatedPath(candidateDirectory);

  final String candidateDirectory;

  @override
  String toString() => 'PiValidateProjectRequest(<redacted>)';
}

final class PiProjectTrustApproval {
  const PiProjectTrustApproval({
    required this.projectId,
    required this.revision,
  });

  final PiProjectId projectId;
  final PiProjectTrustRevision revision;

  @override
  String toString() => 'PiProjectTrustApproval(<redacted>)';
}

enum PiNodeConnectionStatus {
  disconnected,
  connecting,
  connected,
  closing,
  closed,
}

final class PiNodeConnectionSnapshot {
  const PiNodeConnectionSnapshot._(
    this.status,
    this.negotiatedVersion,
    this.capabilities,
  );

  const PiNodeConnectionSnapshot.disconnected()
    : this._(
        PiNodeConnectionStatus.disconnected,
        null,
        const <PiProtocolCapability>{},
      );

  const PiNodeConnectionSnapshot.connecting()
    : this._(
        PiNodeConnectionStatus.connecting,
        null,
        const <PiProtocolCapability>{},
      );

  factory PiNodeConnectionSnapshot.connected(
    PiProtocolVersion negotiatedVersion, {
    Iterable<PiProtocolCapability> capabilities =
        const <PiProtocolCapability>[],
  }) => PiNodeConnectionSnapshot._(
    PiNodeConnectionStatus.connected,
    negotiatedVersion,
    Set<PiProtocolCapability>.unmodifiable(capabilities),
  );

  const PiNodeConnectionSnapshot.closing()
    : this._(
        PiNodeConnectionStatus.closing,
        null,
        const <PiProtocolCapability>{},
      );

  const PiNodeConnectionSnapshot.closed()
    : this._(
        PiNodeConnectionStatus.closed,
        null,
        const <PiProtocolCapability>{},
      );

  final PiNodeConnectionStatus status;
  final PiProtocolVersion? negotiatedVersion;
  final Set<PiProtocolCapability> capabilities;

  @override
  bool operator ==(Object other) =>
      other is PiNodeConnectionSnapshot &&
      status == other.status &&
      negotiatedVersion == other.negotiatedVersion &&
      _sameCapabilities(capabilities, other.capabilities);

  @override
  int get hashCode => Object.hash(
    status,
    negotiatedVersion,
    Object.hashAll(
      capabilities.toList(growable: false)
        ..sort((left, right) => left.index.compareTo(right.index)),
    ),
  );

  @override
  String toString() =>
      'PiNodeConnectionSnapshot(status: $status, '
      'protocol: ${negotiatedVersion ?? '<none>'}, '
      'capabilities: ${capabilities.length})';
}

bool _sameCapabilities(
  Set<PiProtocolCapability> left,
  Set<PiProtocolCapability> right,
) => left.length == right.length && left.containsAll(right);

enum PiConversationIdentityScope { persistent, runtime }

enum PiThinkingVisibility { visible, redacted, deferred }

enum PiToolActivityStatus { pending, running, succeeded, failed, cancelled }

enum PiConversationMarkerKind { thinkingLevel, modelChange, label, sessionInfo }

final class PiConversationEntryIdentity {
  PiConversationEntryIdentity({
    required String entryId,
    required this.scope,
    this.originCommandId,
  }) : entryId = _validatedOpaqueId(entryId, 'entryId');

  final String entryId;
  final PiConversationIdentityScope scope;
  final PiCommandId? originCommandId;
}

final class PiMessageContentReference {
  PiMessageContentReference({
    required String contentId,
    required String mimeType,
    required String displayName,
    required int totalBytes,
    required Uint8List sha256,
  }) : contentId = _validatedOpaqueId(contentId, 'contentId'),
       mimeType = _validatedText(mimeType, 'mimeType', allowEmpty: false),
       displayName = _validatedText(
         displayName,
         'displayName',
         allowEmpty: false,
       ),
       totalBytes = _validatedPositiveInt(totalBytes, 'totalBytes'),
       sha256 = Uint8List.fromList(sha256) {
    if (this.sha256.length != 32) {
      throw ArgumentError('sha256 must contain 32 bytes.');
    }
  }

  final String contentId;
  final String mimeType;
  final String displayName;
  final int totalBytes;
  final Uint8List sha256;
}

final class PiMessageContentBinding {
  PiMessageContentBinding({
    required this.sessionId,
    required String entryId,
    required String partId,
    required int entryRevision,
    required int partRevision,
    required String contentId,
  }) : entryId = _validatedOpaqueId(entryId, 'entryId'),
       partId = _validatedOpaqueId(partId, 'partId'),
       entryRevision = _validatedPositiveInt(entryRevision, 'entryRevision'),
       partRevision = _validatedPositiveInt(partRevision, 'partRevision'),
       contentId = _validatedOpaqueId(contentId, 'contentId');

  final PiSessionId sessionId;
  final String entryId;
  final String partId;
  final int entryRevision;
  final int partRevision;
  final String contentId;
}

final class PiMessageContentRequest {
  const PiMessageContentRequest({
    required this.projectId,
    required this.binding,
    required this.reference,
  });

  final PiProjectId projectId;
  final PiMessageContentBinding binding;
  final PiMessageContentReference reference;
}

abstract interface class PiMessageContentHandle {
  PiMessageContentBinding get binding;
  PiMessageContentReference get reference;
  Stream<Uint8List> get bytes;
  Future<void> get done;
  Future<void> cancel();
}

sealed class PiSafeValue {
  const PiSafeValue();
}

final class PiSafeNull extends PiSafeValue {
  const PiSafeNull();
}

final class PiSafeRedacted extends PiSafeValue {
  const PiSafeRedacted();
}

final class PiSafeBool extends PiSafeValue {
  const PiSafeBool(this.value);
  final bool value;
}

final class PiSafeInt extends PiSafeValue {
  const PiSafeInt(this.value);
  final int value;
}

final class PiSafeDouble extends PiSafeValue {
  PiSafeDouble(this.value) {
    if (!value.isFinite) throw ArgumentError('Safe doubles must be finite.');
  }
  final double value;
}

final class PiSafeString extends PiSafeValue {
  PiSafeString(String value) : value = _validatedText(value, 'safeString');
  final String value;
}

final class PiSafeList extends PiSafeValue {
  PiSafeList(Iterable<PiSafeValue> values)
    : values = List<PiSafeValue>.unmodifiable(values);
  final List<PiSafeValue> values;
}

final class PiSafeObjectField {
  PiSafeObjectField({required String key, required this.value})
    : key = _validatedText(key, 'safeObjectKey', allowEmpty: false);
  final String key;
  final PiSafeValue value;
}

final class PiSafeObject extends PiSafeValue {
  PiSafeObject(Iterable<PiSafeObjectField> fields)
    : fields = List<PiSafeObjectField>.unmodifiable(fields);
  final List<PiSafeObjectField> fields;
}

final class PiUsageMetrics {
  PiUsageMetrics({
    required int inputTokens,
    required int outputTokens,
    required int cacheReadTokens,
    required int cacheWriteTokens,
    required int totalTokens,
  }) : inputTokens = _validatedNonNegativeInt(inputTokens, 'inputTokens'),
       outputTokens = _validatedNonNegativeInt(outputTokens, 'outputTokens'),
       cacheReadTokens = _validatedNonNegativeInt(
         cacheReadTokens,
         'cacheReadTokens',
       ),
       cacheWriteTokens = _validatedNonNegativeInt(
         cacheWriteTokens,
         'cacheWriteTokens',
       ),
       totalTokens = _validatedNonNegativeInt(totalTokens, 'totalTokens');

  final int inputTokens;
  final int outputTokens;
  final int cacheReadTokens;
  final int cacheWriteTokens;
  final int totalTokens;
}

final class PiMoneyAmount {
  PiMoneyAmount({required String currencyCode, required String decimalAmount})
    : currencyCode = _validatedText(
        currencyCode,
        'currencyCode',
        allowEmpty: false,
      ),
      decimalAmount = _validatedText(
        decimalAmount,
        'decimalAmount',
        allowEmpty: false,
      );

  final String currencyCode;
  final String decimalAmount;
}

final class PiContextMetrics {
  PiContextMetrics({
    this.tokens,
    required int contextWindow,
    this.percentDecimal,
  }) : contextWindow = _validatedPositiveInt(contextWindow, 'contextWindow') {
    if (tokens != null) _validatedNonNegativeInt(tokens!, 'contextTokens');
  }

  final int? tokens;
  final int contextWindow;
  final String? percentDecimal;
}

final class PiConversationMetrics {
  const PiConversationMetrics({
    required this.usage,
    required this.cost,
    this.context,
  });

  final PiUsageMetrics usage;
  final PiMoneyAmount cost;
  final PiContextMetrics? context;
}

sealed class PiConversationPart {
  PiConversationPart({required String partId, required int revision})
    : partId = _validatedOpaqueId(partId, 'partId'),
      revision = _validatedPositiveInt(revision, 'partRevision');

  final String partId;
  final int revision;
}

final class PiTextConversationPart extends PiConversationPart {
  PiTextConversationPart({
    required super.partId,
    required super.revision,
    this.text,
    this.contentReference,
  }) {
    if ((text == null) == (contentReference == null)) {
      throw ArgumentError('Text parts require exactly one content source.');
    }
  }

  final String? text;
  final PiMessageContentReference? contentReference;
}

final class PiThinkingConversationPart extends PiConversationPart {
  PiThinkingConversationPart({
    required super.partId,
    required super.revision,
    required this.visibility,
    this.text,
    this.contentReference,
  }) {
    if (visibility == PiThinkingVisibility.visible) {
      if ((text == null) == (contentReference == null)) {
        throw ArgumentError(
          'Visible thinking requires exactly one content source.',
        );
      }
    } else if (text != null || contentReference != null) {
      throw ArgumentError('Hidden thinking must not expose content.');
    }
  }

  final PiThinkingVisibility visibility;
  final String? text;
  final PiMessageContentReference? contentReference;
}

final class PiImageConversationPart extends PiConversationPart {
  PiImageConversationPart({
    required super.partId,
    required super.revision,
    required this.contentReference,
  });

  final PiMessageContentReference contentReference;
}

final class PiToolCallConversationPart extends PiConversationPart {
  PiToolCallConversationPart({
    required super.partId,
    required super.revision,
    required String toolCallId,
    required String toolName,
    required this.safeArguments,
  }) : toolCallId = _validatedOpaqueId(toolCallId, 'toolCallId'),
       toolName = _validatedText(toolName, 'toolName', allowEmpty: false);

  final String toolCallId;
  final String toolName;
  final PiSafeValue safeArguments;
}

final class PiUnsupportedConversationPart extends PiConversationPart {
  PiUnsupportedConversationPart({
    required super.partId,
    required super.revision,
    required String sourceType,
  }) : sourceType = _validatedText(sourceType, 'sourceType', allowEmpty: false);

  final String sourceType;
}

final class PiToolActivity {
  PiToolActivity({
    required String activityId,
    required String toolCallId,
    required String toolName,
    required int sourceOrdinal,
    required int revision,
    required this.status,
    this.progressBasisPoints,
    required this.safeDetails,
  }) : activityId = _validatedOpaqueId(activityId, 'activityId'),
       toolCallId = _validatedOpaqueId(toolCallId, 'toolCallId'),
       toolName = _validatedText(toolName, 'toolName', allowEmpty: false),
       sourceOrdinal = _validatedNonNegativeInt(sourceOrdinal, 'sourceOrdinal'),
       revision = _validatedPositiveInt(revision, 'activityRevision') {
    if (progressBasisPoints != null &&
        (progressBasisPoints! < 0 || progressBasisPoints! > 10000)) {
      throw ArgumentError(
        'progressBasisPoints is outside the supported range.',
      );
    }
  }

  final String activityId;
  final String toolCallId;
  final String toolName;
  final int sourceOrdinal;
  final int revision;
  final PiToolActivityStatus status;
  final int? progressBasisPoints;
  final PiSafeValue safeDetails;
}

sealed class PiConversationEntry {
  PiConversationEntry({
    required this.identity,
    required int revision,
    required DateTime createdAt,
    required this.finalized,
    required Iterable<PiConversationPart> parts,
    required Iterable<PiToolActivity> toolActivities,
    this.metrics,
  }) : revision = _validatedPositiveInt(revision, 'entryRevision'),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt'),
       parts = List<PiConversationPart>.unmodifiable(parts),
       toolActivities = List<PiToolActivity>.unmodifiable(toolActivities);

  final PiConversationEntryIdentity identity;
  final int revision;
  final DateTime createdAt;
  final bool finalized;
  final List<PiConversationPart> parts;
  final List<PiToolActivity> toolActivities;
  final PiConversationMetrics? metrics;
}

final class PiUserConversationEntry extends PiConversationEntry {
  PiUserConversationEntry({
    required super.identity,
    required super.revision,
    required super.createdAt,
    required super.finalized,
    required super.parts,
    required super.toolActivities,
    super.metrics,
  });
}

final class PiAssistantConversationEntry extends PiConversationEntry {
  PiAssistantConversationEntry({
    required super.identity,
    required super.revision,
    required super.createdAt,
    required super.finalized,
    required super.parts,
    required super.toolActivities,
    super.metrics,
    required String provider,
    required String model,
    required String stopReason,
    this.safeErrorMessage,
  }) : provider = _validatedText(provider, 'provider', allowEmpty: false),
       model = _validatedText(model, 'model', allowEmpty: false),
       stopReason = _validatedText(stopReason, 'stopReason', allowEmpty: false);

  final String provider;
  final String model;
  final String stopReason;
  final String? safeErrorMessage;
}

final class PiToolResultConversationEntry extends PiConversationEntry {
  PiToolResultConversationEntry({
    required super.identity,
    required super.revision,
    required super.createdAt,
    required super.finalized,
    required super.parts,
    required super.toolActivities,
    super.metrics,
    required String toolCallId,
    required String toolName,
    required this.isError,
    required this.safeDetails,
  }) : toolCallId = _validatedOpaqueId(toolCallId, 'toolCallId'),
       toolName = _validatedText(toolName, 'toolName', allowEmpty: false);

  final String toolCallId;
  final String toolName;
  final bool isError;
  final PiSafeValue safeDetails;
}

final class PiBashConversationEntry extends PiConversationEntry {
  PiBashConversationEntry({
    required super.identity,
    required super.revision,
    required super.createdAt,
    required super.finalized,
    required super.parts,
    required super.toolActivities,
    super.metrics,
    required String command,
    this.exitCode,
    required this.cancelled,
    required this.truncated,
    required this.excludedFromContext,
  }) : command = _validatedText(command, 'command');

  final String command;
  final int? exitCode;
  final bool cancelled;
  final bool truncated;
  final bool excludedFromContext;
}

final class PiCustomConversationEntry extends PiConversationEntry {
  PiCustomConversationEntry({
    required super.identity,
    required super.revision,
    required super.createdAt,
    required super.finalized,
    required super.parts,
    required super.toolActivities,
    super.metrics,
    required String customType,
    required this.display,
    required this.safeDetails,
  }) : customType = _validatedText(customType, 'customType', allowEmpty: false);

  final String customType;
  final bool display;
  final PiSafeValue safeDetails;
}

final class PiCompactionConversationEntry extends PiConversationEntry {
  PiCompactionConversationEntry({
    required super.identity,
    required super.revision,
    required super.createdAt,
    required super.finalized,
    required super.parts,
    required super.toolActivities,
    super.metrics,
    required String firstKeptEntryId,
    required int tokensBefore,
    required this.fromHook,
    required this.safeDetails,
  }) : firstKeptEntryId = _validatedOpaqueId(
         firstKeptEntryId,
         'firstKeptEntryId',
       ),
       tokensBefore = _validatedNonNegativeInt(tokensBefore, 'tokensBefore');

  final String firstKeptEntryId;
  final int tokensBefore;
  final bool fromHook;
  final PiSafeValue safeDetails;
}

final class PiBranchSummaryConversationEntry extends PiConversationEntry {
  PiBranchSummaryConversationEntry({
    required super.identity,
    required super.revision,
    required super.createdAt,
    required super.finalized,
    required super.parts,
    required super.toolActivities,
    super.metrics,
    required String fromEntryId,
    required this.fromHook,
    required this.safeDetails,
  }) : fromEntryId = _validatedOpaqueId(fromEntryId, 'fromEntryId');

  final String fromEntryId;
  final bool fromHook;
  final PiSafeValue safeDetails;
}

final class PiMarkerConversationEntry extends PiConversationEntry {
  PiMarkerConversationEntry({
    required super.identity,
    required super.revision,
    required super.createdAt,
    required super.finalized,
    required super.parts,
    required super.toolActivities,
    super.metrics,
    required this.markerKind,
    this.targetEntryId,
    this.label,
    this.provider,
    this.model,
    this.thinkingLevel,
  });

  final PiConversationMarkerKind markerKind;
  final String? targetEntryId;
  final String? label;
  final String? provider;
  final String? model;
  final String? thinkingLevel;
}

final class PiUnknownConversationEntry extends PiConversationEntry {
  PiUnknownConversationEntry({
    required super.identity,
    required super.revision,
    required super.createdAt,
    required super.finalized,
    required super.parts,
    required super.toolActivities,
    super.metrics,
    required String sourceType,
  }) : sourceType = _validatedText(sourceType, 'sourceType', allowEmpty: false);

  final String sourceType;
}

final class PiConversationSnapshot {
  PiConversationSnapshot({
    required this.sessionId,
    required Iterable<PiConversationEntry> entries,
    required int lastEventSequence,
  }) : entries = List<PiConversationEntry>.unmodifiable(entries),
       lastEventSequence = _validatedNonNegativeInt(
         lastEventSequence,
         'lastEventSequence',
       );

  final PiSessionId sessionId;
  final List<PiConversationEntry> entries;
  final int lastEventSequence;

  List<PiMessage> get messages =>
      List<PiMessage>.unmodifiable(entries.map(piConversationEntryToMessage));
}

final class PiConversationPage {
  PiConversationPage({
    required this.sessionId,
    required Iterable<PiConversationEntry> entries,
    this.nextCursor,
    required this.hasMore,
    required this.activeBranchRevision,
    required this.treeRevision,
    required int lastEventSequence,
  }) : entries = List<PiConversationEntry>.unmodifiable(entries),
       lastEventSequence = _validatedNonNegativeInt(
         lastEventSequence,
         'lastEventSequence',
       ) {
    if (hasMore != (nextCursor != null)) {
      throw ArgumentError('hasMore and nextCursor must agree.');
    }
  }

  final PiSessionId sessionId;
  final List<PiConversationEntry> entries;
  final PiSessionHistoryCursor? nextCursor;
  final bool hasMore;
  final PiSessionBranchRevision activeBranchRevision;
  final PiSessionTreeRevision treeRevision;
  final int lastEventSequence;
}

enum PiMessageRole { user, assistant, tool, system }

final class PiMessage {
  PiMessage({
    required this.id,
    required this.role,
    required String text,
    required DateTime createdAt,
    required this.isStreaming,
  }) : text = _validatedText(text, 'text'),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt');

  final PiMessageId id;
  final PiMessageRole role;
  final String text;
  final DateTime createdAt;
  final bool isStreaming;

  @override
  bool operator ==(Object other) =>
      other is PiMessage &&
      id == other.id &&
      role == other.role &&
      text == other.text &&
      createdAt == other.createdAt &&
      isStreaming == other.isStreaming;

  @override
  int get hashCode => Object.hash(id, role, text, createdAt, isStreaming);

  @override
  String toString() => 'PiMessage(role: $role, <redacted>)';
}

PiMessage piConversationEntryToMessage(PiConversationEntry entry) {
  final role = switch (entry) {
    PiUserConversationEntry() => PiMessageRole.user,
    PiAssistantConversationEntry() => PiMessageRole.assistant,
    PiToolResultConversationEntry() => PiMessageRole.tool,
    _ => PiMessageRole.system,
  };
  final text = entry.parts
      .map((part) {
        return switch (part) {
          PiTextConversationPart(:final text, :final contentReference) =>
            text ?? '[Content: ${contentReference!.displayName}]',
          PiThinkingConversationPart(
            visibility: PiThinkingVisibility.visible,
            :final text,
            :final contentReference,
          ) =>
            text ?? '[Thinking: ${contentReference!.displayName}]',
          PiThinkingConversationPart() => '',
          PiImageConversationPart(:final contentReference) =>
            '[Image: ${contentReference.mimeType}]',
          PiToolCallConversationPart(:final toolName) =>
            '[Tool call: $toolName]',
          PiUnsupportedConversationPart(:final sourceType) =>
            '[Unsupported content: $sourceType]',
        };
      })
      .where((value) => value.isNotEmpty)
      .join('\n');
  return PiMessage(
    id: PiMessageId(entry.identity.entryId),
    role: role,
    text: text,
    createdAt: entry.createdAt,
    isStreaming: !entry.finalized,
  );
}

final class PiSessionSummary {
  PiSessionSummary({
    required this.id,
    required String title,
    required String workingDirectory,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.isRunning,
    required this.hasUnread,
    required this.adminRevision,
    required this.hasCustomName,
    this.parentSessionId,
  }) : title = _validatedText(title, 'title', allowEmpty: false),
       workingDirectory = _validatedPath(workingDirectory),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt'),
       updatedAt = _validatedUtcInstant(updatedAt, 'updatedAt') {
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt must not be before createdAt.');
    }
  }

  final PiSessionId id;
  final String title;
  final String workingDirectory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRunning;
  final bool hasUnread;
  final PiSessionAdminRevision adminRevision;
  final bool hasCustomName;
  final PiSessionId? parentSessionId;

  @override
  bool operator ==(Object other) =>
      other is PiSessionSummary &&
      id == other.id &&
      title == other.title &&
      workingDirectory == other.workingDirectory &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt &&
      isRunning == other.isRunning &&
      hasUnread == other.hasUnread &&
      adminRevision == other.adminRevision &&
      hasCustomName == other.hasCustomName &&
      parentSessionId == other.parentSessionId;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    workingDirectory,
    createdAt,
    updatedAt,
    isRunning,
    hasUnread,
    adminRevision,
    hasCustomName,
    parentSessionId,
  );

  @override
  String toString() => 'PiSessionSummary(<redacted>)';
}

final class PiSessionHistoryPage {
  PiSessionHistoryPage({required this.summary, required this.conversation}) {
    if (conversation.entries.length > 200) {
      throw ArgumentError('Session history page is too large.');
    }
    if (conversation.sessionId != summary.id) {
      throw ArgumentError('Conversation session does not match its summary.');
    }
  }

  final PiSessionSummary summary;
  final PiConversationPage conversation;

  List<PiMessage> get messages => List<PiMessage>.unmodifiable(
    conversation.entries.map(piConversationEntryToMessage),
  );
  PiSessionHistoryCursor? get nextCursor => conversation.nextCursor;
  bool get hasMore => conversation.hasMore;
  PiSessionBranchRevision get activeBranchRevision =>
      conversation.activeBranchRevision;
  PiSessionTreeRevision get treeRevision => conversation.treeRevision;
}

final class PiSessionHistoryRequest {
  PiSessionHistoryRequest({
    required this.projectId,
    required this.sessionId,
    this.cursor,
    this.limit = 50,
    this.expectedActiveBranchRevision,
    this.expectedTreeRevision,
  }) {
    if (limit < 1 || limit > 200) {
      throw ArgumentError('limit is outside the supported range.');
    }
  }

  final PiProjectId projectId;
  final PiSessionId sessionId;
  final PiSessionHistoryCursor? cursor;
  final int limit;
  final PiSessionBranchRevision? expectedActiveBranchRevision;
  final PiSessionTreeRevision? expectedTreeRevision;
}

final class PiSessionSafeProjection {
  PiSessionSafeProjection({
    required String sessionFileName,
    required this.sessionId,
    required this.projectId,
    required String canonicalProjectDirectory,
    required this.worktreeId,
    required this.mainProjectId,
    String? branch,
    required this.isLinkedWorktree,
    required this.isDetachedHead,
  }) : sessionFileName = _validatedText(
         sessionFileName,
         'sessionFileName',
         allowEmpty: false,
       ),
       canonicalProjectDirectory = _validatedPath(canonicalProjectDirectory),
       branch = branch == null
           ? null
           : _validatedText(branch, 'branch', allowEmpty: false) {
    if (isDetachedHead && this.branch != null) {
      throw ArgumentError('Detached projection must not contain branch.');
    }
  }

  final String sessionFileName;
  final PiSessionId sessionId;
  final PiProjectId projectId;
  final String canonicalProjectDirectory;
  final PiWorktreeId worktreeId;
  final PiMainProjectId mainProjectId;
  final String? branch;
  final bool isLinkedWorktree;
  final bool isDetachedHead;
}

final class PiSessionStats {
  PiSessionStats({
    required this.projection,
    required int userMessages,
    required int assistantMessages,
    required int toolCalls,
    required int toolResults,
    required int totalMessages,
    required int inputTokens,
    required int outputTokens,
    required int cacheReadTokens,
    required int cacheWriteTokens,
    required int totalTokens,
    required double cost,
    int? contextTokens,
    int? contextWindow,
    double? contextPercent,
    required this.activeTime,
  }) : userMessages = _validatedNonNegativeInt(userMessages, 'userMessages'),
       assistantMessages = _validatedNonNegativeInt(
         assistantMessages,
         'assistantMessages',
       ),
       toolCalls = _validatedNonNegativeInt(toolCalls, 'toolCalls'),
       toolResults = _validatedNonNegativeInt(toolResults, 'toolResults'),
       totalMessages = _validatedNonNegativeInt(totalMessages, 'totalMessages'),
       inputTokens = _validatedNonNegativeInt(inputTokens, 'inputTokens'),
       outputTokens = _validatedNonNegativeInt(outputTokens, 'outputTokens'),
       cacheReadTokens = _validatedNonNegativeInt(
         cacheReadTokens,
         'cacheReadTokens',
       ),
       cacheWriteTokens = _validatedNonNegativeInt(
         cacheWriteTokens,
         'cacheWriteTokens',
       ),
       totalTokens = _validatedNonNegativeInt(totalTokens, 'totalTokens'),
       cost = _validatedNonNegativeDouble(cost, 'cost'),
       contextTokens = contextTokens == null
           ? null
           : _validatedNonNegativeInt(contextTokens, 'contextTokens'),
       contextWindow = contextWindow == null
           ? null
           : _validatedPositiveInt(contextWindow, 'contextWindow'),
       contextPercent = contextPercent == null
           ? null
           : _validatedNonNegativeDouble(contextPercent, 'contextPercent') {
    if (activeTime.isNegative) {
      throw ArgumentError('activeTime must be non-negative.');
    }
    if (this.contextWindow == null &&
        (this.contextTokens != null || this.contextPercent != null)) {
      throw ArgumentError('Context values require a context window.');
    }
  }

  final PiSessionSafeProjection projection;
  final int userMessages;
  final int assistantMessages;
  final int toolCalls;
  final int toolResults;
  final int totalMessages;
  final int inputTokens;
  final int outputTokens;
  final int cacheReadTokens;
  final int cacheWriteTokens;
  final int totalTokens;
  final double cost;
  final int? contextTokens;
  final int? contextWindow;
  final double? contextPercent;
  final Duration activeTime;
}

enum PiSessionExportFormat { html, jsonl }

final class PiSessionExportRequest {
  const PiSessionExportRequest({
    required this.projectId,
    required this.sessionId,
    required this.format,
    this.expectedActiveBranchRevision,
    this.expectedTreeRevision,
  });

  final PiProjectId projectId;
  final PiSessionId sessionId;
  final PiSessionExportFormat format;
  final PiSessionBranchRevision? expectedActiveBranchRevision;
  final PiSessionTreeRevision? expectedTreeRevision;
}

abstract interface class PiSessionExportHandle {
  String get fileName;
  String get contentType;
  int get totalBytes;
  List<int> get sha256;
  Stream<Uint8List> get bytes;
  Future<void> get done;
  Future<void> cancel();
}

final class PiSessionDetail {
  PiSessionDetail({required this.summary, required this.conversation}) {
    if (conversation.sessionId != summary.id) {
      throw ArgumentError('Conversation session does not match its summary.');
    }
  }

  final PiSessionSummary summary;
  final PiConversationSnapshot conversation;
  List<PiMessage> get messages => conversation.messages;

  @override
  String toString() => 'PiSessionDetail(<redacted>)';
}

enum PiSessionTreeEntryKind {
  userMessage,
  assistantMessage,
  toolMessage,
  customMessage,
  thinkingLevel,
  modelChange,
  compaction,
  branchSummary,
  custom,
  label,
  sessionInfo,
}

final class PiSessionTreeNode {
  PiSessionTreeNode({
    required this.id,
    this.parentId,
    required this.kind,
    required String text,
    required DateTime createdAt,
    this.label,
    required int depth,
    required this.isOnActivePath,
    required this.hasChildren,
    required this.canEditFromHere,
    required this.canFork,
  }) : text = _validatedText(text, 'text'),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt'),
       depth = _validatedBoundedCount(depth, 'depth', 0xffffffff) {
    if (label != null) _validatedText(label!, 'label', allowEmpty: false);
  }

  final PiSessionTreeEntryId id;
  final PiSessionTreeEntryId? parentId;
  final PiSessionTreeEntryKind kind;
  final String text;
  final DateTime createdAt;
  final String? label;
  final int depth;
  final bool isOnActivePath;
  final bool hasChildren;
  final bool canEditFromHere;
  final bool canFork;

  @override
  bool operator ==(Object other) =>
      other is PiSessionTreeNode &&
      id == other.id &&
      parentId == other.parentId &&
      kind == other.kind &&
      text == other.text &&
      createdAt == other.createdAt &&
      label == other.label &&
      depth == other.depth &&
      isOnActivePath == other.isOnActivePath &&
      hasChildren == other.hasChildren &&
      canEditFromHere == other.canEditFromHere &&
      canFork == other.canFork;

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    kind,
    text,
    createdAt,
    label,
    depth,
    isOnActivePath,
    hasChildren,
    canEditFromHere,
    canFork,
  );
}

final class PiSessionTree {
  PiSessionTree({
    required this.sessionId,
    required Iterable<PiSessionTreeNode> nodes,
    required Iterable<PiSessionTreeEntryId> activePathEntryIds,
    this.activeLeafEntryId,
    required this.canCloneActiveBranch,
    required this.adminRevision,
  }) : nodes = List<PiSessionTreeNode>.unmodifiable(nodes),
       activePathEntryIds = List<PiSessionTreeEntryId>.unmodifiable(
         activePathEntryIds,
       );

  final PiSessionId sessionId;
  final List<PiSessionTreeNode> nodes;
  final List<PiSessionTreeEntryId> activePathEntryIds;
  final PiSessionTreeEntryId? activeLeafEntryId;
  final bool canCloneActiveBranch;
  final PiSessionAdminRevision adminRevision;

  PiSessionTreeNode? nodeById(PiSessionTreeEntryId id) =>
      nodes.where((node) => node.id == id).firstOrNull;

  @override
  bool operator ==(Object other) =>
      other is PiSessionTree &&
      sessionId == other.sessionId &&
      _sameList(nodes, other.nodes) &&
      _sameList(activePathEntryIds, other.activePathEntryIds) &&
      activeLeafEntryId == other.activeLeafEntryId &&
      canCloneActiveBranch == other.canCloneActiveBranch &&
      adminRevision == other.adminRevision;

  @override
  int get hashCode => Object.hash(
    sessionId,
    Object.hashAll(nodes),
    Object.hashAll(activePathEntryIds),
    activeLeafEntryId,
    canCloneActiveBranch,
    adminRevision,
  );
}

final class PiCreateSessionRequest {
  const PiCreateSessionRequest({required this.projectId});

  final PiProjectId projectId;

  @override
  String toString() => 'PiCreateSessionRequest(<redacted>)';
}

enum PiSessionAdminOperation { rename, clearName, autoName, delete }

sealed class PiSessionAdminCommand {
  const PiSessionAdminCommand({
    required this.commandId,
    required this.projectId,
    required this.sessionId,
  });

  final PiCommandId commandId;
  final PiProjectId projectId;
  final PiSessionId sessionId;
}

final class PiRenameSessionCommand extends PiSessionAdminCommand {
  PiRenameSessionCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required String name,
  }) : name = _validatedText(name, 'name', allowEmpty: false);

  final String name;

  @override
  String toString() => 'PiRenameSessionCommand(<redacted>)';
}

final class PiClearSessionNameCommand extends PiSessionAdminCommand {
  const PiClearSessionNameCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
  });

  @override
  String toString() => 'PiClearSessionNameCommand(<redacted>)';
}

final class PiAutoNameSessionCommand extends PiSessionAdminCommand {
  PiAutoNameSessionCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    this.timeout = const Duration(seconds: 15),
  }) {
    if (timeout < const Duration(seconds: 1) ||
        timeout > const Duration(seconds: 30)) {
      throw ArgumentError('timeout is outside the supported range.');
    }
  }

  final Duration timeout;

  @override
  String toString() => 'PiAutoNameSessionCommand(<redacted>)';
}

final class PiDeleteSessionConfirmation {
  const PiDeleteSessionConfirmation({
    required this.sessionId,
    required this.adminRevision,
    required this.displayedTitle,
    required this.destructiveActionAcknowledged,
  });

  factory PiDeleteSessionConfirmation.confirmed(PiSessionSummary session) =>
      PiDeleteSessionConfirmation(
        sessionId: session.id,
        adminRevision: session.adminRevision,
        displayedTitle: session.title,
        destructiveActionAcknowledged: true,
      );

  final PiSessionId sessionId;
  final PiSessionAdminRevision adminRevision;
  final String displayedTitle;
  final bool destructiveActionAcknowledged;

  @override
  String toString() => 'PiDeleteSessionConfirmation(<redacted>)';
}

final class PiDeleteSessionCommand extends PiSessionAdminCommand {
  const PiDeleteSessionCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required this.confirmation,
  });

  final PiDeleteSessionConfirmation confirmation;

  @override
  String toString() => 'PiDeleteSessionCommand(<redacted>)';
}

sealed class PiSessionAdminResult {
  const PiSessionAdminResult({
    required this.commandId,
    required this.operation,
  });

  final PiCommandId commandId;
  final PiSessionAdminOperation operation;
}

final class PiSessionAdminUpdated extends PiSessionAdminResult {
  const PiSessionAdminUpdated({
    required super.commandId,
    required super.operation,
    required this.session,
  });

  final PiSessionSummary session;
}

final class PiSessionAdminDeleted extends PiSessionAdminResult {
  const PiSessionAdminDeleted({
    required super.commandId,
    required this.sessionId,
    required this.reparentedChildCount,
  }) : super(operation: PiSessionAdminOperation.delete);

  final PiSessionId sessionId;
  final int reparentedChildCount;
}

final class PiSessionAdminRejected extends PiSessionAdminResult {
  const PiSessionAdminRejected({
    required super.commandId,
    required super.operation,
    required this.error,
  });

  final PiNodeException error;
}

final class PiSessionAdminUncertain extends PiSessionAdminResult {
  const PiSessionAdminUncertain({
    required super.commandId,
    required super.operation,
    required this.error,
  });

  final PiNodeException error;
}

enum PiSessionTreeMutationOperation { navigate, fork, clone }

sealed class PiSessionTreeMutationCommand {
  const PiSessionTreeMutationCommand({
    required this.commandId,
    required this.projectId,
    required this.sessionId,
    required this.expectedAdminRevision,
  });

  final PiCommandId commandId;
  final PiProjectId projectId;
  final PiSessionId sessionId;
  final PiSessionAdminRevision expectedAdminRevision;
}

final class PiNavigateSessionTreeCommand extends PiSessionTreeMutationCommand {
  const PiNavigateSessionTreeCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required super.expectedAdminRevision,
    required this.entryId,
  });

  final PiSessionTreeEntryId entryId;
}

final class PiForkSessionCommand extends PiSessionTreeMutationCommand {
  const PiForkSessionCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required super.expectedAdminRevision,
    required this.userEntryId,
  });

  final PiSessionTreeEntryId userEntryId;
}

final class PiCloneSessionCommand extends PiSessionTreeMutationCommand {
  const PiCloneSessionCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required super.expectedAdminRevision,
  });
}

sealed class PiSessionTreeMutationResult {
  const PiSessionTreeMutationResult({
    required this.commandId,
    required this.operation,
  });

  final PiCommandId commandId;
  final PiSessionTreeMutationOperation operation;
}

final class PiSessionTreeMutationUpdated extends PiSessionTreeMutationResult {
  const PiSessionTreeMutationUpdated({
    required super.commandId,
    required super.operation,
    required this.session,
    required this.tree,
    this.editorText,
  });

  final PiSessionDetail session;
  final PiSessionTree tree;
  final String? editorText;
}

final class PiSessionTreeMutationRejected extends PiSessionTreeMutationResult {
  const PiSessionTreeMutationRejected({
    required super.commandId,
    required super.operation,
    required this.error,
  });

  final PiNodeException error;
}

final class PiSessionTreeMutationUncertain extends PiSessionTreeMutationResult {
  const PiSessionTreeMutationUncertain({
    required super.commandId,
    required super.operation,
    required this.error,
  });

  final PiNodeException error;
}

sealed class PiSessionCommand {
  const PiSessionCommand({required this.commandId, required this.sessionId});

  final PiCommandId commandId;
  final PiSessionId sessionId;
}

final class PiPromptCommand extends PiSessionCommand {
  PiPromptCommand({
    required super.commandId,
    required super.sessionId,
    required String prompt,
  }) : prompt = _validatedText(prompt, 'prompt', allowEmpty: false);

  final String prompt;

  @override
  String toString() => 'PiPromptCommand(<redacted>)';
}

final class PiAbortCommand extends PiSessionCommand {
  const PiAbortCommand({required super.commandId, required super.sessionId});

  @override
  String toString() => 'PiAbortCommand(<redacted>)';
}

sealed class PiCommandResult {
  const PiCommandResult(this.commandId);

  final PiCommandId commandId;
}

final class PiCommandAccepted extends PiCommandResult {
  const PiCommandAccepted(super.commandId);

  @override
  String toString() => 'PiCommandAccepted(<redacted>)';
}

final class PiCommandRejected extends PiCommandResult {
  const PiCommandRejected(super.commandId, this.error);

  final PiNodeException error;

  @override
  String toString() =>
      'PiCommandRejected(error: ${error.code.name}, <redacted>)';
}

final class PiCommandUncertain extends PiCommandResult {
  const PiCommandUncertain(super.commandId, this.error);

  final PiNodeException error;

  @override
  String toString() =>
      'PiCommandUncertain(error: ${error.code.name}, <redacted>)';
}

sealed class PiSessionEvent {
  PiSessionEvent({required this.sessionId, required int sequence})
    : sequence = _validatedPositiveInt(sequence, 'sequence');

  final PiSessionId sessionId;
  final int sequence;
}

final class PiSessionMessageAddedEvent extends PiSessionEvent {
  PiSessionMessageAddedEvent({
    required super.sessionId,
    required super.sequence,
    required this.message,
  });

  final PiMessage message;
}

final class PiSessionMessageDeltaEvent extends PiSessionEvent {
  PiSessionMessageDeltaEvent({
    required super.sessionId,
    required super.sequence,
    required this.messageId,
    required String delta,
  }) : delta = _validatedText(delta, 'delta');

  final PiMessageId messageId;
  final String delta;

  @override
  String toString() => 'PiSessionMessageDeltaEvent(<redacted>)';
}

final class PiSessionEntryUpsertEvent extends PiSessionEvent {
  PiSessionEntryUpsertEvent({
    required super.sessionId,
    required super.sequence,
    required this.entry,
    this.expectedPreviousRevision,
  });

  final PiConversationEntry entry;
  final int? expectedPreviousRevision;
}

final class PiSessionPartDeltaEvent extends PiSessionEvent {
  PiSessionPartDeltaEvent({
    required super.sessionId,
    required super.sequence,
    required String entryId,
    required int expectedEntryRevision,
    required int resultingEntryRevision,
    required String partId,
    required int expectedPartRevision,
    required int resultingPartRevision,
    required String textDelta,
  }) : entryId = _validatedOpaqueId(entryId, 'entryId'),
       expectedEntryRevision = _validatedPositiveInt(
         expectedEntryRevision,
         'expectedEntryRevision',
       ),
       resultingEntryRevision = _validatedPositiveInt(
         resultingEntryRevision,
         'resultingEntryRevision',
       ),
       partId = _validatedOpaqueId(partId, 'partId'),
       expectedPartRevision = _validatedPositiveInt(
         expectedPartRevision,
         'expectedPartRevision',
       ),
       resultingPartRevision = _validatedPositiveInt(
         resultingPartRevision,
         'resultingPartRevision',
       ),
       textDelta = _validatedText(textDelta, 'textDelta');

  final String entryId;
  final int expectedEntryRevision;
  final int resultingEntryRevision;
  final String partId;
  final int expectedPartRevision;
  final int resultingPartRevision;
  final String textDelta;
}

final class PiSessionEntryFinalizedEvent extends PiSessionEvent {
  PiSessionEntryFinalizedEvent({
    required super.sessionId,
    required super.sequence,
    required this.entry,
    required int expectedPreviousRevision,
  }) : expectedPreviousRevision = _validatedNonNegativeInt(
         expectedPreviousRevision,
         'expectedPreviousRevision',
       );

  final PiConversationEntry entry;
  final int expectedPreviousRevision;
}

final class PiSessionToolActivityEvent extends PiSessionEvent {
  PiSessionToolActivityEvent({
    required super.sessionId,
    required super.sequence,
    required String entryId,
    required int expectedEntryRevision,
    required int resultingEntryRevision,
    required this.activity,
  }) : entryId = _validatedOpaqueId(entryId, 'entryId'),
       expectedEntryRevision = _validatedPositiveInt(
         expectedEntryRevision,
         'expectedEntryRevision',
       ),
       resultingEntryRevision = _validatedPositiveInt(
         resultingEntryRevision,
         'resultingEntryRevision',
       );

  final String entryId;
  final int expectedEntryRevision;
  final int resultingEntryRevision;
  final PiToolActivity activity;
}

final class PiSessionMetricsEvent extends PiSessionEvent {
  PiSessionMetricsEvent({
    required super.sessionId,
    required super.sequence,
    required String entryId,
    required int expectedEntryRevision,
    required int resultingEntryRevision,
    required this.metrics,
  }) : entryId = _validatedOpaqueId(entryId, 'entryId'),
       expectedEntryRevision = _validatedPositiveInt(
         expectedEntryRevision,
         'expectedEntryRevision',
       ),
       resultingEntryRevision = _validatedPositiveInt(
         resultingEntryRevision,
         'resultingEntryRevision',
       );

  final String entryId;
  final int expectedEntryRevision;
  final int resultingEntryRevision;
  final PiConversationMetrics metrics;
}

final class PiSessionRevisionGapEvent extends PiSessionEvent {
  PiSessionRevisionGapEvent({
    required super.sessionId,
    required super.sequence,
    required String entryId,
  }) : entryId = _validatedOpaqueId(entryId, 'entryId');

  final String entryId;
}

final class PiSessionRunningChangedEvent extends PiSessionEvent {
  PiSessionRunningChangedEvent({
    required super.sessionId,
    required super.sequence,
    required this.isRunning,
  });

  final bool isRunning;
}

final class PiSessionCommandCompletedEvent extends PiSessionEvent {
  PiSessionCommandCompletedEvent({
    required super.sessionId,
    required super.sequence,
    required this.commandId,
    required this.succeeded,
  });

  final PiCommandId commandId;
  final bool succeeded;
}

/// A local recovery signal. The event received at [receivedSequence] is not
/// emitted because one or more earlier events were missing.
final class PiSessionSequenceGapEvent extends PiSessionEvent {
  PiSessionSequenceGapEvent({
    required super.sessionId,
    required int expectedSequence,
    required int receivedSequence,
  }) : expectedSequence = _validatedPositiveInt(
         expectedSequence,
         'expectedSequence',
       ),
       receivedSequence = _validatedPositiveInt(
         receivedSequence,
         'receivedSequence',
       ),
       super(sequence: receivedSequence) {
    if (receivedSequence <= expectedSequence) {
      throw ArgumentError(
        'A sequence gap must advance beyond the expectation.',
      );
    }
  }

  final int expectedSequence;
  final int receivedSequence;
}

bool _sameList<T>(List<T> left, List<T> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

int _validatedNonNegativeInt(int value, String name) {
  if (value < 0) throw ArgumentError('$name must be non-negative.');
  return value;
}

double _validatedNonNegativeDouble(double value, String name) {
  if (!value.isFinite || value < 0) {
    throw ArgumentError('$name must be finite and non-negative.');
  }
  return value;
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

String _validatedShortOpaqueText(String value, String name) {
  if (value.isEmpty ||
      value.length > 1024 ||
      value.trim() != value ||
      _containsForbiddenControl(value)) {
    throw ArgumentError('Invalid $name.');
  }
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
