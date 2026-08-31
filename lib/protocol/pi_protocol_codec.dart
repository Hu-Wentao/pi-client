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

final class PiProtocolGetSessionTreeRequest extends PiProtocolRequestMessage {
  PiProtocolGetSessionTreeRequest({
    required super.requestId,
    required String projectId,
    required String sessionId,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId'),
       sessionId = _validatedOpaqueId(sessionId, 'sessionId');

  final String projectId;
  final String sessionId;
}

final class PiProtocolGetSessionHistoryRequest
    extends PiProtocolRequestMessage {
  PiProtocolGetSessionHistoryRequest({
    required super.requestId,
    required String projectId,
    required String sessionId,
    String? cursor,
    required int limit,
    String? expectedActiveBranchRevision,
    String? expectedTreeRevision,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId'),
       sessionId = _validatedOpaqueId(sessionId, 'sessionId'),
       cursor = cursor == null ? null : _validatedShortText(cursor, 'cursor'),
       limit = _validatedBoundedCount(limit, 'limit', 200),
       expectedActiveBranchRevision = expectedActiveBranchRevision == null
           ? null
           : _validatedOpaqueId(
               expectedActiveBranchRevision,
               'expectedActiveBranchRevision',
             ),
       expectedTreeRevision = expectedTreeRevision == null
           ? null
           : _validatedOpaqueId(expectedTreeRevision, 'expectedTreeRevision') {
    if (limit < 1) throw ArgumentError('limit must be positive.');
  }

  final String projectId;
  final String sessionId;
  final String? cursor;
  final int limit;
  final String? expectedActiveBranchRevision;
  final String? expectedTreeRevision;
}

final class PiProtocolGetMessageContentRequest
    extends PiProtocolRequestMessage {
  PiProtocolGetMessageContentRequest({
    required super.requestId,
    required String projectId,
    required this.binding,
    required String expectedMimeType,
    required int expectedTotalBytes,
    required Uint8List expectedSha256,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId'),
       expectedMimeType = _validatedShortText(
         expectedMimeType,
         'expectedMimeType',
       ),
       expectedTotalBytes = _validatedPositiveInt(
         expectedTotalBytes,
         'expectedTotalBytes',
       ),
       expectedSha256 = Uint8List.fromList(expectedSha256) {
    if (this.expectedSha256.length != 32) {
      throw ArgumentError('expectedSha256 must contain 32 bytes.');
    }
  }

  final String projectId;
  final PiProtocolMessageContentBinding binding;
  final String expectedMimeType;
  final int expectedTotalBytes;
  final Uint8List expectedSha256;
}

final class PiProtocolGetSessionStatsRequest extends PiProtocolRequestMessage {
  PiProtocolGetSessionStatsRequest({
    required super.requestId,
    required String projectId,
    required String sessionId,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId'),
       sessionId = _validatedOpaqueId(sessionId, 'sessionId');

  final String projectId;
  final String sessionId;
}

enum PiProtocolSessionExportFormat { html, jsonl }

final class PiProtocolExportSessionRequest extends PiProtocolRequestMessage {
  PiProtocolExportSessionRequest({
    required super.requestId,
    required String projectId,
    required String sessionId,
    required this.format,
    String? expectedActiveBranchRevision,
    String? expectedTreeRevision,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId'),
       sessionId = _validatedOpaqueId(sessionId, 'sessionId'),
       expectedActiveBranchRevision = expectedActiveBranchRevision == null
           ? null
           : _validatedOpaqueId(
               expectedActiveBranchRevision,
               'expectedActiveBranchRevision',
             ),
       expectedTreeRevision = expectedTreeRevision == null
           ? null
           : _validatedOpaqueId(expectedTreeRevision, 'expectedTreeRevision');

  final String projectId;
  final String sessionId;
  final PiProtocolSessionExportFormat format;
  final String? expectedActiveBranchRevision;
  final String? expectedTreeRevision;
}

final class PiProtocolTransferWindowUpdate extends PiClientProtocolMessage {
  PiProtocolTransferWindowUpdate({
    required String transferId,
    required int creditBytes,
  }) : transferId = _validatedOpaqueId(transferId, 'transferId'),
       creditBytes = _validatedPositiveInt(creditBytes, 'creditBytes') {
    if (creditBytes > 8 * 1024 * 1024) {
      throw ArgumentError('creditBytes is outside the supported range.');
    }
  }

  final String transferId;
  final int creditBytes;
}

final class PiProtocolTransferAckMessage extends PiClientProtocolMessage {
  PiProtocolTransferAckMessage({
    required String transferId,
    required int acknowledgedSequence,
    required int committedBytes,
  }) : transferId = _validatedOpaqueId(transferId, 'transferId'),
       acknowledgedSequence = _validatedPositiveInt(
         acknowledgedSequence,
         'acknowledgedSequence',
       ),
       committedBytes = _validatedPositiveInt(committedBytes, 'committedBytes');

  final String transferId;
  final int acknowledgedSequence;
  final int committedBytes;
}

final class PiProtocolCancelTransferMessage extends PiClientProtocolMessage {
  PiProtocolCancelTransferMessage({required String transferId})
    : transferId = _validatedOpaqueId(transferId, 'transferId');

  final String transferId;
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

enum PiProtocolSessionAdminOperation { rename, clearName, autoName, delete }

enum PiProtocolSessionTreeMutationOperation { navigate, fork, clone }

sealed class PiProtocolSessionTreeMutationCommandRequest
    extends PiProtocolCommandRequest {
  PiProtocolSessionTreeMutationCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.sessionId,
    required String projectId,
    required String expectedAdminRevision,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId'),
       expectedAdminRevision = _validatedOpaqueId(
         expectedAdminRevision,
         'expectedAdminRevision',
       );

  final String projectId;
  final String expectedAdminRevision;
}

final class PiProtocolNavigateSessionTreeCommandRequest
    extends PiProtocolSessionTreeMutationCommandRequest {
  PiProtocolNavigateSessionTreeCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required super.expectedAdminRevision,
    required String entryId,
  }) : entryId = _validatedOpaqueId(entryId, 'entryId');

  final String entryId;
}

final class PiProtocolForkSessionCommandRequest
    extends PiProtocolSessionTreeMutationCommandRequest {
  PiProtocolForkSessionCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required super.expectedAdminRevision,
    required String userEntryId,
  }) : userEntryId = _validatedOpaqueId(userEntryId, 'userEntryId');

  final String userEntryId;
}

final class PiProtocolCloneSessionCommandRequest
    extends PiProtocolSessionTreeMutationCommandRequest {
  PiProtocolCloneSessionCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required super.expectedAdminRevision,
  });
}

sealed class PiProtocolSessionAdminCommandRequest
    extends PiProtocolCommandRequest {
  PiProtocolSessionAdminCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.sessionId,
    required String projectId,
  }) : projectId = _validatedOpaqueId(projectId, 'projectId');

  final String projectId;
}

final class PiProtocolRenameSessionCommandRequest
    extends PiProtocolSessionAdminCommandRequest {
  PiProtocolRenameSessionCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required String name,
  }) : name = _validatedText(name, 'name', allowEmpty: false);

  final String name;
}

final class PiProtocolClearSessionNameCommandRequest
    extends PiProtocolSessionAdminCommandRequest {
  PiProtocolClearSessionNameCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.projectId,
    required super.sessionId,
  });
}

final class PiProtocolAutoNameSessionCommandRequest
    extends PiProtocolSessionAdminCommandRequest {
  PiProtocolAutoNameSessionCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required int timeoutMillis,
  }) : timeoutMillis = _validatedBoundedCount(
         timeoutMillis,
         'timeoutMillis',
         30000,
       ) {
    if (timeoutMillis < 1000) {
      throw ArgumentError('timeoutMillis is outside the supported range.');
    }
  }

  final int timeoutMillis;
}

final class PiProtocolDeleteSessionConfirmationEvidence {
  PiProtocolDeleteSessionConfirmationEvidence({
    required String sessionId,
    required String adminRevision,
    required String displayedTitle,
    required this.destructiveActionAcknowledged,
  }) : sessionId = _validatedOpaqueId(sessionId, 'sessionId'),
       adminRevision = _validatedOpaqueId(adminRevision, 'adminRevision'),
       displayedTitle = _validatedText(
         displayedTitle,
         'displayedTitle',
         allowEmpty: false,
       );

  final String sessionId;
  final String adminRevision;
  final String displayedTitle;
  final bool destructiveActionAcknowledged;
}

final class PiProtocolDeleteSessionCommandRequest
    extends PiProtocolSessionAdminCommandRequest {
  PiProtocolDeleteSessionCommandRequest({
    required super.requestId,
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required this.confirmation,
  });

  final PiProtocolDeleteSessionConfirmationEvidence confirmation;
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
  cancellation,
  flowControl,
  transfer,
  projectDiscovery,
  projectTrust,
  sessionAdmin,
  sessionTree,
  sessionHistory,
  sessionStats,
  sessionExport,
  richConversation,
  messageContent,
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

final class PiProtocolSessionTreeResponse extends PiProtocolResponseMessage {
  PiProtocolSessionTreeResponse({required super.requestId, required this.tree});

  final PiProtocolSessionTreeSnapshot tree;
}

final class PiProtocolSessionHistoryResponse extends PiProtocolResponseMessage {
  PiProtocolSessionHistoryResponse({
    required super.requestId,
    required this.summary,
    required this.conversation,
  });

  final PiProtocolSessionSummary summary;
  final PiProtocolConversationPage conversation;
}

final class PiProtocolSessionSafeProjection {
  PiProtocolSessionSafeProjection({
    required String sessionFileName,
    required String sessionId,
    required String projectId,
    required String canonicalProjectDirectory,
    required String worktreeId,
    required String mainProjectId,
    String? branch,
    required this.isLinkedWorktree,
    required this.isDetachedHead,
  }) : sessionFileName = _validatedShortText(
         sessionFileName,
         'sessionFileName',
       ),
       sessionId = _validatedOpaqueId(sessionId, 'sessionId'),
       projectId = _validatedOpaqueId(projectId, 'projectId'),
       canonicalProjectDirectory = _validatedPath(canonicalProjectDirectory),
       worktreeId = _validatedOpaqueId(worktreeId, 'worktreeId'),
       mainProjectId = _validatedOpaqueId(mainProjectId, 'mainProjectId'),
       branch = branch == null ? null : _validatedShortText(branch, 'branch') {
    if (isDetachedHead && this.branch != null) {
      throw ArgumentError('Detached stats projection must not contain branch.');
    }
  }

  final String sessionFileName;
  final String sessionId;
  final String projectId;
  final String canonicalProjectDirectory;
  final String worktreeId;
  final String mainProjectId;
  final String? branch;
  final bool isLinkedWorktree;
  final bool isDetachedHead;
}

final class PiProtocolSessionStatsSnapshot {
  PiProtocolSessionStatsSnapshot({
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
    this.contextTokens,
    this.contextWindow,
    this.contextPercent,
    required int activeTimeMillis,
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
       activeTimeMillis = _validatedNonNegativeInt(
         activeTimeMillis,
         'activeTimeMillis',
       ) {
    if (contextTokens != null) {
      _validatedNonNegativeInt(contextTokens!, 'contextTokens');
    }
    if (contextWindow != null) {
      _validatedPositiveInt(contextWindow!, 'contextWindow');
    }
    if (contextPercent != null) {
      _validatedNonNegativeDouble(contextPercent!, 'contextPercent');
    }
    if (contextWindow == null &&
        (contextTokens != null || contextPercent != null)) {
      throw ArgumentError('Context values require a context window.');
    }
  }

  final PiProtocolSessionSafeProjection projection;
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
  final int activeTimeMillis;
}

final class PiProtocolSessionStatsResponse extends PiProtocolResponseMessage {
  PiProtocolSessionStatsResponse({
    required super.requestId,
    required this.stats,
  });

  final PiProtocolSessionStatsSnapshot stats;
}

enum PiProtocolTransferPurpose { attachment, export, messageContent }

final class PiProtocolTransferOpenMessage extends PiProtocolResponseMessage {
  PiProtocolTransferOpenMessage({
    required super.requestId,
    required String transferId,
    required this.purpose,
    required String contentType,
    required String fileName,
    required int totalBytes,
    required int chunkBytes,
    required Iterable<int> sha256,
    this.messageContentBinding,
  }) : transferId = _validatedOpaqueId(transferId, 'transferId'),
       contentType = _validatedShortText(contentType, 'contentType'),
       fileName = _validatedShortText(fileName, 'fileName'),
       totalBytes = _validatedPositiveInt(totalBytes, 'totalBytes'),
       chunkBytes = _validatedPositiveInt(chunkBytes, 'chunkBytes'),
       sha256 = List<int>.unmodifiable(sha256) {
    if (chunkBytes > 1024 * 1024 || this.sha256.length != 32) {
      throw ArgumentError('Invalid transfer metadata.');
    }
    if ((purpose == PiProtocolTransferPurpose.messageContent) !=
        (messageContentBinding != null)) {
      throw ArgumentError(
        'Message content transfers require an exact binding.',
      );
    }
  }

  final String transferId;
  final PiProtocolTransferPurpose purpose;
  final String contentType;
  final String fileName;
  final int totalBytes;
  final int chunkBytes;
  final List<int> sha256;
  final PiProtocolMessageContentBinding? messageContentBinding;
}

final class PiProtocolTransferChunkMessage extends PiServerProtocolMessage {
  PiProtocolTransferChunkMessage({
    required String transferId,
    required int sequence,
    required int offset,
    required Iterable<int> data,
  }) : transferId = _validatedOpaqueId(transferId, 'transferId'),
       sequence = _validatedPositiveInt(sequence, 'sequence'),
       offset = _validatedNonNegativeInt(offset, 'offset'),
       data = List<int>.unmodifiable(data) {
    if (this.data.isEmpty || this.data.length > 1024 * 1024) {
      throw ArgumentError('Invalid transfer chunk.');
    }
  }

  final String transferId;
  final int sequence;
  final int offset;
  final List<int> data;
}

final class PiProtocolTransferCompleteMessage extends PiServerProtocolMessage {
  PiProtocolTransferCompleteMessage({
    required String transferId,
    required int totalBytes,
    required Iterable<int> sha256,
  }) : transferId = _validatedOpaqueId(transferId, 'transferId'),
       totalBytes = _validatedPositiveInt(totalBytes, 'totalBytes'),
       sha256 = List<int>.unmodifiable(sha256) {
    if (this.sha256.length != 32) {
      throw ArgumentError('Invalid transfer digest.');
    }
  }

  final String transferId;
  final int totalBytes;
  final List<int> sha256;
}

final class PiProtocolTransferAbortMessage extends PiServerProtocolMessage {
  PiProtocolTransferAbortMessage({
    required String transferId,
    required this.failure,
  }) : transferId = _validatedOpaqueId(transferId, 'transferId');

  final String transferId;
  final PiProtocolFailure failure;
}

sealed class PiProtocolSessionAdminOutcome {
  const PiProtocolSessionAdminOutcome();
}

final class PiProtocolSessionAdminUpdated
    extends PiProtocolSessionAdminOutcome {
  const PiProtocolSessionAdminUpdated(this.session);

  final PiProtocolSessionSummary session;
}

final class PiProtocolSessionAdminDeleted
    extends PiProtocolSessionAdminOutcome {
  PiProtocolSessionAdminDeleted({
    required String sessionId,
    required int reparentedChildCount,
  }) : sessionId = _validatedOpaqueId(sessionId, 'sessionId'),
       reparentedChildCount = _validatedBoundedCount(
         reparentedChildCount,
         'reparentedChildCount',
         0xffffffff,
       );

  final String sessionId;
  final int reparentedChildCount;
}

final class PiProtocolSessionAdminFailed extends PiProtocolSessionAdminOutcome {
  const PiProtocolSessionAdminFailed(this.failure);

  final PiProtocolFailure failure;
}

final class PiProtocolSessionAdminOutcomeMessage
    extends PiProtocolCommandResponseMessage {
  PiProtocolSessionAdminOutcomeMessage({
    required super.requestId,
    required super.commandId,
    required this.operation,
    required this.outcome,
  });

  final PiProtocolSessionAdminOperation operation;
  final PiProtocolSessionAdminOutcome outcome;
}

sealed class PiProtocolSessionTreeMutationOutcome {
  const PiProtocolSessionTreeMutationOutcome();
}

final class PiProtocolSessionTreeMutationUpdated
    extends PiProtocolSessionTreeMutationOutcome {
  const PiProtocolSessionTreeMutationUpdated({
    required this.session,
    required this.tree,
    this.editorText,
  });

  final PiProtocolSessionDetail session;
  final PiProtocolSessionTreeSnapshot tree;
  final String? editorText;
}

final class PiProtocolSessionTreeMutationFailed
    extends PiProtocolSessionTreeMutationOutcome {
  const PiProtocolSessionTreeMutationFailed(this.failure);

  final PiProtocolFailure failure;
}

final class PiProtocolSessionTreeMutationOutcomeMessage
    extends PiProtocolCommandResponseMessage {
  PiProtocolSessionTreeMutationOutcomeMessage({
    required super.requestId,
    required super.commandId,
    required this.operation,
    required this.outcome,
  });

  final PiProtocolSessionTreeMutationOperation operation;
  final PiProtocolSessionTreeMutationOutcome outcome;
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
    required String adminRevision,
    required this.hasCustomName,
    String? parentSessionId,
  }) : id = _validatedOpaqueId(id, 'sessionId'),
       title = _validatedText(title, 'title', allowEmpty: false),
       workingDirectory = _validatedPath(workingDirectory),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt'),
       updatedAt = _validatedUtcInstant(updatedAt, 'updatedAt'),
       adminRevision = _validatedOpaqueId(adminRevision, 'adminRevision'),
       parentSessionId = parentSessionId == null
           ? null
           : _validatedOpaqueId(parentSessionId, 'parentSessionId') {
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
  final String adminRevision;
  final bool hasCustomName;
  final String? parentSessionId;

  @override
  String toString() => 'PiProtocolSessionSummary(<redacted>)';
}

enum PiProtocolConversationIdentityScope { persistent, runtime }

enum PiProtocolConversationEntryType {
  user,
  assistant,
  toolResult,
  bash,
  custom,
  compaction,
  branchSummary,
  marker,
  unknown,
}

enum PiProtocolConversationPartType {
  text,
  thinking,
  image,
  toolCall,
  unsupported,
}

enum PiProtocolThinkingVisibility { visible, redacted, deferred }

enum PiProtocolToolActivityStatus {
  pending,
  running,
  succeeded,
  failed,
  cancelled,
}

enum PiProtocolConversationMarkerKind {
  thinkingLevel,
  modelChange,
  label,
  sessionInfo,
}

sealed class PiProtocolSafeValue {
  const PiProtocolSafeValue();
}

final class PiProtocolSafeNull extends PiProtocolSafeValue {
  const PiProtocolSafeNull();
}

final class PiProtocolSafeRedacted extends PiProtocolSafeValue {
  const PiProtocolSafeRedacted();
}

final class PiProtocolSafeBool extends PiProtocolSafeValue {
  const PiProtocolSafeBool(this.value);
  final bool value;
}

final class PiProtocolSafeInt extends PiProtocolSafeValue {
  const PiProtocolSafeInt(this.value);
  final int value;
}

final class PiProtocolSafeDouble extends PiProtocolSafeValue {
  const PiProtocolSafeDouble(this.value);
  final double value;
}

final class PiProtocolSafeString extends PiProtocolSafeValue {
  const PiProtocolSafeString(this.value);
  final String value;
}

final class PiProtocolSafeList extends PiProtocolSafeValue {
  PiProtocolSafeList(Iterable<PiProtocolSafeValue> values)
    : values = List<PiProtocolSafeValue>.unmodifiable(values);
  final List<PiProtocolSafeValue> values;
}

final class PiProtocolSafeObjectField {
  const PiProtocolSafeObjectField({required this.key, required this.value});
  final String key;
  final PiProtocolSafeValue value;
}

final class PiProtocolSafeObject extends PiProtocolSafeValue {
  PiProtocolSafeObject(Iterable<PiProtocolSafeObjectField> fields)
    : fields = List<PiProtocolSafeObjectField>.unmodifiable(fields);
  final List<PiProtocolSafeObjectField> fields;
}

final class PiProtocolMessageContentReference {
  PiProtocolMessageContentReference({
    required this.contentId,
    required this.mimeType,
    required this.displayName,
    required this.totalBytes,
    required Uint8List sha256,
  }) : sha256 = Uint8List.fromList(sha256);

  final String contentId;
  final String mimeType;
  final String displayName;
  final int totalBytes;
  final Uint8List sha256;
}

final class PiProtocolMessageContentBinding {
  const PiProtocolMessageContentBinding({
    required this.sessionId,
    required this.entryId,
    required this.partId,
    required this.entryRevision,
    required this.partRevision,
    required this.contentId,
  });

  final String sessionId;
  final String entryId;
  final String partId;
  final int entryRevision;
  final int partRevision;
  final String contentId;
}

final class PiProtocolConversationPart {
  const PiProtocolConversationPart({
    required this.partId,
    required this.revision,
    required this.type,
    this.text,
    this.contentReference,
    this.thinkingVisibility,
    this.toolCallId,
    this.toolName,
    this.safeArguments,
    this.sourceType,
  });

  final String partId;
  final int revision;
  final PiProtocolConversationPartType type;
  final String? text;
  final PiProtocolMessageContentReference? contentReference;
  final PiProtocolThinkingVisibility? thinkingVisibility;
  final String? toolCallId;
  final String? toolName;
  final PiProtocolSafeValue? safeArguments;
  final String? sourceType;
}

final class PiProtocolToolActivity {
  const PiProtocolToolActivity({
    required this.activityId,
    required this.toolCallId,
    required this.toolName,
    required this.sourceOrdinal,
    required this.revision,
    required this.status,
    this.progressBasisPoints,
    required this.safeDetails,
  });

  final String activityId;
  final String toolCallId;
  final String toolName;
  final int sourceOrdinal;
  final int revision;
  final PiProtocolToolActivityStatus status;
  final int? progressBasisPoints;
  final PiProtocolSafeValue safeDetails;
}

final class PiProtocolUsageMetrics {
  const PiProtocolUsageMetrics({
    required this.inputTokens,
    required this.outputTokens,
    required this.cacheReadTokens,
    required this.cacheWriteTokens,
    required this.totalTokens,
  });

  final int inputTokens;
  final int outputTokens;
  final int cacheReadTokens;
  final int cacheWriteTokens;
  final int totalTokens;
}

final class PiProtocolMoneyAmount {
  const PiProtocolMoneyAmount({
    required this.currencyCode,
    required this.decimalAmount,
  });
  final String currencyCode;
  final String decimalAmount;
}

final class PiProtocolContextMetrics {
  const PiProtocolContextMetrics({
    this.tokens,
    required this.contextWindow,
    this.percentDecimal,
  });
  final int? tokens;
  final int contextWindow;
  final String? percentDecimal;
}

final class PiProtocolConversationMetrics {
  const PiProtocolConversationMetrics({
    required this.usage,
    required this.cost,
    this.context,
  });
  final PiProtocolUsageMetrics usage;
  final PiProtocolMoneyAmount cost;
  final PiProtocolContextMetrics? context;
}

final class PiProtocolConversationEntry {
  PiProtocolConversationEntry({
    required this.entryId,
    required this.scope,
    this.originCommandId,
    required this.revision,
    required this.createdAt,
    required this.finalized,
    required Iterable<PiProtocolConversationPart> parts,
    required Iterable<PiProtocolToolActivity> toolActivities,
    this.metrics,
    required this.type,
    this.provider,
    this.model,
    this.stopReason,
    this.safeErrorMessage,
    this.toolCallId,
    this.toolName,
    this.isError,
    this.safeDetails,
    this.command,
    this.exitCode,
    this.cancelled,
    this.truncated,
    this.excludedFromContext,
    this.customType,
    this.display,
    this.firstKeptEntryId,
    this.tokensBefore,
    this.fromHook,
    this.fromEntryId,
    this.markerKind,
    this.targetEntryId,
    this.label,
    this.thinkingLevel,
    this.sourceType,
  }) : parts = List<PiProtocolConversationPart>.unmodifiable(parts),
       toolActivities = List<PiProtocolToolActivity>.unmodifiable(
         toolActivities,
       );

  final String entryId;
  final PiProtocolConversationIdentityScope scope;
  final String? originCommandId;
  final int revision;
  final DateTime createdAt;
  final bool finalized;
  final List<PiProtocolConversationPart> parts;
  final List<PiProtocolToolActivity> toolActivities;
  final PiProtocolConversationMetrics? metrics;
  final PiProtocolConversationEntryType type;
  final String? provider;
  final String? model;
  final String? stopReason;
  final String? safeErrorMessage;
  final String? toolCallId;
  final String? toolName;
  final bool? isError;
  final PiProtocolSafeValue? safeDetails;
  final String? command;
  final int? exitCode;
  final bool? cancelled;
  final bool? truncated;
  final bool? excludedFromContext;
  final String? customType;
  final bool? display;
  final String? firstKeptEntryId;
  final int? tokensBefore;
  final bool? fromHook;
  final String? fromEntryId;
  final PiProtocolConversationMarkerKind? markerKind;
  final String? targetEntryId;
  final String? label;
  final String? thinkingLevel;
  final String? sourceType;
}

final class PiProtocolConversationSnapshot {
  PiProtocolConversationSnapshot({
    required this.sessionId,
    required Iterable<PiProtocolConversationEntry> entries,
    required this.lastEventSequence,
  }) : entries = List<PiProtocolConversationEntry>.unmodifiable(entries);

  final String sessionId;
  final List<PiProtocolConversationEntry> entries;
  final int lastEventSequence;
}

final class PiProtocolConversationPage {
  PiProtocolConversationPage({
    required this.sessionId,
    required Iterable<PiProtocolConversationEntry> entries,
    this.nextCursor,
    required this.hasMore,
    required this.activeBranchRevision,
    required this.treeRevision,
    required this.lastEventSequence,
  }) : entries = List<PiProtocolConversationEntry>.unmodifiable(entries);

  final String sessionId;
  final List<PiProtocolConversationEntry> entries;
  final String? nextCursor;
  final bool hasMore;
  final String activeBranchRevision;
  final String treeRevision;
  final int lastEventSequence;
}

final class PiProtocolSessionDetail {
  const PiProtocolSessionDetail({
    required this.summary,
    required this.conversation,
  });

  final PiProtocolSessionSummary summary;
  final PiProtocolConversationSnapshot conversation;

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

enum PiProtocolSessionTreeEntryKind {
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

final class PiProtocolSessionTreeNodeSnapshot {
  PiProtocolSessionTreeNodeSnapshot({
    required String entryId,
    String? parentEntryId,
    required this.kind,
    required String text,
    required DateTime createdAt,
    String? label,
    required int depth,
    required this.isOnActivePath,
    required this.hasChildren,
    required this.canEditFromHere,
    required this.canFork,
  }) : entryId = _validatedOpaqueId(entryId, 'entryId'),
       parentEntryId = parentEntryId == null
           ? null
           : _validatedOpaqueId(parentEntryId, 'parentEntryId'),
       text = _validatedText(text, 'text'),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt'),
       label = label == null
           ? null
           : _validatedText(label, 'label', allowEmpty: false),
       depth = _validatedBoundedCount(depth, 'depth', 0xffffffff);

  final String entryId;
  final String? parentEntryId;
  final PiProtocolSessionTreeEntryKind kind;
  final String text;
  final DateTime createdAt;
  final String? label;
  final int depth;
  final bool isOnActivePath;
  final bool hasChildren;
  final bool canEditFromHere;
  final bool canFork;
}

final class PiProtocolSessionTreeSnapshot {
  PiProtocolSessionTreeSnapshot({
    required String sessionId,
    required Iterable<PiProtocolSessionTreeNodeSnapshot> nodes,
    required Iterable<String> activePathEntryIds,
    String? activeLeafEntryId,
    required this.canCloneActiveBranch,
    required String adminRevision,
  }) : sessionId = _validatedOpaqueId(sessionId, 'sessionId'),
       nodes = List<PiProtocolSessionTreeNodeSnapshot>.unmodifiable(nodes),
       activePathEntryIds = List<String>.unmodifiable(
         activePathEntryIds.map(
           (entryId) => _validatedOpaqueId(entryId, 'activePathEntryId'),
         ),
       ),
       activeLeafEntryId = activeLeafEntryId == null
           ? null
           : _validatedOpaqueId(activeLeafEntryId, 'activeLeafEntryId'),
       adminRevision = _validatedOpaqueId(adminRevision, 'adminRevision');

  final String sessionId;
  final List<PiProtocolSessionTreeNodeSnapshot> nodes;
  final List<String> activePathEntryIds;
  final String? activeLeafEntryId;
  final bool canCloneActiveBranch;
  final String adminRevision;
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

final class PiProtocolConversationEntryUpsertEvent
    extends PiProtocolSessionEventPayload {
  const PiProtocolConversationEntryUpsertEvent({
    required this.entry,
    this.expectedPreviousRevision,
  });
  final PiProtocolConversationEntry entry;
  final int? expectedPreviousRevision;
}

final class PiProtocolConversationPartDeltaEvent
    extends PiProtocolSessionEventPayload {
  const PiProtocolConversationPartDeltaEvent({
    required this.entryId,
    required this.expectedEntryRevision,
    required this.resultingEntryRevision,
    required this.partId,
    required this.expectedPartRevision,
    required this.resultingPartRevision,
    required this.textDelta,
  });
  final String entryId;
  final int expectedEntryRevision;
  final int resultingEntryRevision;
  final String partId;
  final int expectedPartRevision;
  final int resultingPartRevision;
  final String textDelta;
}

final class PiProtocolConversationEntryFinalizedEvent
    extends PiProtocolSessionEventPayload {
  const PiProtocolConversationEntryFinalizedEvent({
    required this.entry,
    required this.expectedPreviousRevision,
  });
  final PiProtocolConversationEntry entry;
  final int expectedPreviousRevision;
}

final class PiProtocolConversationToolActivityEvent
    extends PiProtocolSessionEventPayload {
  const PiProtocolConversationToolActivityEvent({
    required this.entryId,
    required this.expectedEntryRevision,
    required this.resultingEntryRevision,
    required this.activity,
  });
  final String entryId;
  final int expectedEntryRevision;
  final int resultingEntryRevision;
  final PiProtocolToolActivity activity;
}

final class PiProtocolConversationMetricsEvent
    extends PiProtocolSessionEventPayload {
  const PiProtocolConversationMetricsEvent({
    required this.entryId,
    required this.expectedEntryRevision,
    required this.resultingEntryRevision,
    required this.metrics,
  });
  final String entryId;
  final int expectedEntryRevision;
  final int resultingEntryRevision;
  final PiProtocolConversationMetrics metrics;
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

int _validatedNonNegativeInt(int value, String name) {
  if (value < 0) throw ArgumentError('$name must be non-negative.');
  return value;
}

int _validatedPositiveInt(int value, String name) {
  if (value <= 0) throw ArgumentError('$name must be positive.');
  return value;
}

String _validatedShortText(String value, String name) {
  if (value.isEmpty || value.length > 1024 || value.contains('\u0000')) {
    throw ArgumentError('Invalid $name.');
  }
  return value;
}

double _validatedNonNegativeDouble(double value, String name) {
  if (!value.isFinite || value < 0) {
    throw ArgumentError('$name must be finite and non-negative.');
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
