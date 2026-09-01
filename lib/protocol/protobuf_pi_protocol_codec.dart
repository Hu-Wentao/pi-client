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
      PiProtocolGetSessionTreeRequest(
        :final requestId,
        :final projectId,
        :final sessionId,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          getSessionTreeRequest: wire.GetSessionTreeRequest(
            requestId: _wirePositiveInt(requestId),
            projectId: projectId,
            sessionId: sessionId,
          ),
        ),
      PiProtocolGetSessionHistoryRequest(
        :final requestId,
        :final projectId,
        :final sessionId,
        :final cursor,
        :final limit,
        :final expectedActiveBranchRevision,
        :final expectedTreeRevision,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          getSessionHistoryRequest: wire.GetSessionHistoryRequest(
            requestId: _wirePositiveInt(requestId),
            projectId: projectId,
            sessionId: sessionId,
            cursor: cursor ?? '',
            limit: limit,
            expectedActiveBranchRevision: expectedActiveBranchRevision ?? '',
            expectedTreeRevision: expectedTreeRevision ?? '',
          ),
        ),
      PiProtocolGetMessageContentRequest(
        :final requestId,
        :final projectId,
        :final binding,
        :final expectedMimeType,
        :final expectedTotalBytes,
        :final expectedSha256,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          getMessageContentRequest: wire.GetMessageContentRequest(
            requestId: _wirePositiveInt(requestId),
            projectId: projectId,
            binding: _wireMessageContentBinding(binding),
            expectedMimeType: expectedMimeType,
            expectedTotalBytes: _wirePositiveInt(expectedTotalBytes),
            expectedSha256: expectedSha256,
          ),
        ),
      PiProtocolGetSessionStatsRequest(
        :final requestId,
        :final projectId,
        :final sessionId,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          getSessionStatsRequest: wire.GetSessionStatsRequest(
            requestId: _wirePositiveInt(requestId),
            projectId: projectId,
            sessionId: sessionId,
          ),
        ),
      PiProtocolExportSessionRequest(
        :final requestId,
        :final projectId,
        :final sessionId,
        :final format,
        :final expectedActiveBranchRevision,
        :final expectedTreeRevision,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          exportSessionRequest: wire.ExportSessionRequest(
            requestId: _wirePositiveInt(requestId),
            projectId: projectId,
            sessionId: sessionId,
            format: switch (format) {
              PiProtocolSessionExportFormat.html =>
                wire.SessionExportFormat.SESSION_EXPORT_FORMAT_HTML,
              PiProtocolSessionExportFormat.jsonl =>
                wire.SessionExportFormat.SESSION_EXPORT_FORMAT_JSONL,
            },
            expectedActiveBranchRevision: expectedActiveBranchRevision ?? '',
            expectedTreeRevision: expectedTreeRevision ?? '',
          ),
        ),
      PiProtocolTransferWindowUpdate(:final transferId, :final creditBytes) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          windowUpdate: wire.WindowUpdate(
            transferId: transferId,
            creditBytes: _wirePositiveInt(creditBytes),
          ),
        ),
      PiProtocolTransferAckMessage(
        :final transferId,
        :final acknowledgedSequence,
        :final committedBytes,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          transferAck: wire.TransferAck(
            transferId: transferId,
            acknowledgedSequence: _wirePositiveInt(acknowledgedSequence),
            committedBytes: _wirePositiveInt(committedBytes),
          ),
        ),
      PiProtocolCancelTransferMessage(:final transferId) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          cancel: wire.Cancel(transferId: transferId, reason: 'client_cancel'),
        ),
      PiProtocolNavigateSessionTreeCommandRequest(
        :final requestId,
        :final commandId,
        :final projectId,
        :final sessionId,
        :final entryId,
        :final expectedAdminRevision,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          navigateSessionTreeCommand: wire.NavigateSessionTreeCommand(
            requestId: _wirePositiveInt(requestId),
            commandId: commandId,
            projectId: projectId,
            sessionId: sessionId,
            entryId: entryId,
            expectedAdminRevision: expectedAdminRevision,
          ),
        ),
      PiProtocolForkSessionCommandRequest(
        :final requestId,
        :final commandId,
        :final projectId,
        :final sessionId,
        :final userEntryId,
        :final expectedAdminRevision,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          forkSessionCommand: wire.ForkSessionCommand(
            requestId: _wirePositiveInt(requestId),
            commandId: commandId,
            projectId: projectId,
            sessionId: sessionId,
            userEntryId: userEntryId,
            expectedAdminRevision: expectedAdminRevision,
          ),
        ),
      PiProtocolCloneSessionCommandRequest(
        :final requestId,
        :final commandId,
        :final projectId,
        :final sessionId,
        :final expectedAdminRevision,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          cloneSessionCommand: wire.CloneSessionCommand(
            requestId: _wirePositiveInt(requestId),
            commandId: commandId,
            projectId: projectId,
            sessionId: sessionId,
            expectedAdminRevision: expectedAdminRevision,
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
      PiProtocolRenameSessionCommandRequest(
        :final requestId,
        :final commandId,
        :final projectId,
        :final sessionId,
        :final name,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          renameSessionCommand: wire.RenameSessionCommand(
            requestId: _wirePositiveInt(requestId),
            commandId: commandId,
            projectId: projectId,
            sessionId: sessionId,
            name: name,
          ),
        ),
      PiProtocolClearSessionNameCommandRequest(
        :final requestId,
        :final commandId,
        :final projectId,
        :final sessionId,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          clearSessionNameCommand: wire.ClearSessionNameCommand(
            requestId: _wirePositiveInt(requestId),
            commandId: commandId,
            projectId: projectId,
            sessionId: sessionId,
          ),
        ),
      PiProtocolAutoNameSessionCommandRequest(
        :final requestId,
        :final commandId,
        :final projectId,
        :final sessionId,
        :final timeoutMillis,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          autoNameSessionCommand: wire.AutoNameSessionCommand(
            requestId: _wirePositiveInt(requestId),
            commandId: commandId,
            projectId: projectId,
            sessionId: sessionId,
            timeoutMillis: timeoutMillis,
          ),
        ),
      PiProtocolDeleteSessionCommandRequest(
        :final requestId,
        :final commandId,
        :final projectId,
        :final sessionId,
        :final confirmation,
      ) =>
        wire.PiTransportFrame(
          frameSequence: _wirePositiveInt(frameSequence),
          deleteSessionCommand: wire.DeleteSessionCommand(
            requestId: _wirePositiveInt(requestId),
            commandId: commandId,
            projectId: projectId,
            sessionId: sessionId,
            confirmation: wire.DeleteSessionConfirmationEvidence(
              sessionId: confirmation.sessionId,
              adminRevision: confirmation.adminRevision,
              displayedTitle: confirmation.displayedTitle,
              destructiveActionAcknowledged:
                  confirmation.destructiveActionAcknowledged,
            ),
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
    wire.PiTransportFrame_Operation.getSessionTreeResponse =>
      _decodeSessionTreeResponse(frame.getSessionTreeResponse),
    wire.PiTransportFrame_Operation.getSessionHistoryResponse =>
      _decodeSessionHistoryResponse(frame.getSessionHistoryResponse),
    wire.PiTransportFrame_Operation.getSessionStatsResponse =>
      _decodeSessionStatsResponse(frame.getSessionStatsResponse),
    wire.PiTransportFrame_Operation.transferOpen => _decodeTransferOpen(
      frame.transferOpen,
    ),
    wire.PiTransportFrame_Operation.transferChunk => _decodeTransferChunk(
      frame.transferChunk,
    ),
    wire.PiTransportFrame_Operation.transferComplete => _decodeTransferComplete(
      frame.transferComplete,
    ),
    wire.PiTransportFrame_Operation.transferAbort => _decodeTransferAbort(
      frame.transferAbort,
    ),
    wire.PiTransportFrame_Operation.sessionAdminCommandOutcome =>
      _decodeSessionAdminOutcome(frame.sessionAdminCommandOutcome),
    wire.PiTransportFrame_Operation.sessionTreeMutationOutcome =>
      _decodeSessionTreeMutationOutcome(frame.sessionTreeMutationOutcome),
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

  PiProtocolSessionTreeResponse _decodeSessionTreeResponse(
    wire.GetSessionTreeResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolSessionTreeResponse(
      requestId: requestId,
      tree: _semanticSessionTree(response.tree),
    );
  }

  PiProtocolSessionHistoryResponse _decodeSessionHistoryResponse(
    wire.GetSessionHistoryResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolSessionHistoryResponse(
      requestId: requestId,
      summary: _semanticSessionSummary(response.summary),
      conversation: _semanticConversationPage(response.conversation),
    );
  }

  PiProtocolSessionStatsResponse _decodeSessionStatsResponse(
    wire.GetSessionStatsResponse response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    final stats = response.stats;
    final projection = stats.projection;
    return PiProtocolSessionStatsResponse(
      requestId: requestId,
      stats: PiProtocolSessionStatsSnapshot(
        projection: PiProtocolSessionSafeProjection(
          sessionFileName: projection.sessionFileName,
          sessionId: projection.sessionId,
          projectId: projection.projectId,
          canonicalProjectDirectory: projection.canonicalProjectDirectory,
          worktreeId: projection.worktreeId,
          mainProjectId: projection.mainProjectId,
          branch: projection.branch.isEmpty ? null : projection.branch,
          isLinkedWorktree: projection.isLinkedWorktree,
          isDetachedHead: projection.isDetachedHead,
        ),
        userMessages: _semanticNonNegativeInt(stats.userMessages),
        assistantMessages: _semanticNonNegativeInt(stats.assistantMessages),
        toolCalls: _semanticNonNegativeInt(stats.toolCalls),
        toolResults: _semanticNonNegativeInt(stats.toolResults),
        totalMessages: _semanticNonNegativeInt(stats.totalMessages),
        inputTokens: _semanticNonNegativeInt(stats.inputTokens),
        outputTokens: _semanticNonNegativeInt(stats.outputTokens),
        cacheReadTokens: _semanticNonNegativeInt(stats.cacheReadTokens),
        cacheWriteTokens: _semanticNonNegativeInt(stats.cacheWriteTokens),
        totalTokens: _semanticNonNegativeInt(stats.totalTokens),
        cost: stats.cost,
        contextTokens: stats.hasContextUsage && stats.contextTokensKnown
            ? _semanticNonNegativeInt(stats.contextTokens)
            : null,
        contextWindow: stats.hasContextUsage
            ? _semanticPositiveInt(stats.contextWindow)
            : null,
        contextPercent: stats.hasContextUsage && stats.contextTokensKnown
            ? stats.contextPercent
            : null,
        activeTimeMillis: _semanticNonNegativeInt(stats.activeTimeMillis),
      ),
    );
  }

  PiProtocolTransferOpenMessage _decodeTransferOpen(
    wire.TransferOpen transfer,
  ) {
    final requestId = _semanticPositiveInt(transfer.requestId);
    _requestCorrelations.remove(requestId);
    return PiProtocolTransferOpenMessage(
      requestId: requestId,
      transferId: transfer.transferId,
      purpose: _semanticTransferPurpose(transfer.purpose),
      contentType: transfer.contentType,
      fileName: transfer.fileName,
      totalBytes: _semanticPositiveInt(transfer.totalBytes),
      chunkBytes: transfer.chunkBytes,
      sha256: transfer.sha256,
      messageContentBinding: transfer.hasMessageContentBinding()
          ? _semanticMessageContentBinding(transfer.messageContentBinding)
          : null,
    );
  }

  PiProtocolTransferChunkMessage _decodeTransferChunk(
    wire.TransferChunk chunk,
  ) => PiProtocolTransferChunkMessage(
    transferId: chunk.transferId,
    sequence: _semanticPositiveInt(chunk.chunkSequence),
    offset: _semanticNonNegativeInt(chunk.offset),
    data: chunk.data,
  );

  PiProtocolTransferCompleteMessage _decodeTransferComplete(
    wire.TransferComplete complete,
  ) => PiProtocolTransferCompleteMessage(
    transferId: complete.transferId,
    totalBytes: _semanticPositiveInt(complete.totalBytes),
    sha256: complete.sha256,
  );

  PiProtocolTransferAbortMessage _decodeTransferAbort(
    wire.TransferAbort abort,
  ) => PiProtocolTransferAbortMessage(
    transferId: abort.transferId,
    failure: _semanticFailure(abort.error),
  );

  PiProtocolSessionAdminOutcomeMessage _decodeSessionAdminOutcome(
    wire.SessionAdminCommandOutcome response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    final outcome = switch (response.whichOutcome()) {
      wire.SessionAdminCommandOutcome_Outcome.session =>
        PiProtocolSessionAdminUpdated(
          _semanticSessionSummary(response.session),
        ),
      wire.SessionAdminCommandOutcome_Outcome.deletion =>
        PiProtocolSessionAdminDeleted(
          sessionId: response.deletion.sessionId,
          reparentedChildCount: response.deletion.reparentedChildCount,
        ),
      wire.SessionAdminCommandOutcome_Outcome.error =>
        PiProtocolSessionAdminFailed(_semanticFailure(response.error)),
      wire.SessionAdminCommandOutcome_Outcome.notSet =>
        throw const PiProtocolCodecException(
          PiProtocolCodecErrorCode.malformedFrame,
        ),
    };
    return PiProtocolSessionAdminOutcomeMessage(
      requestId: requestId,
      commandId: response.commandId,
      operation: _semanticSessionAdminOperation(response.operation),
      outcome: outcome,
    );
  }

  PiProtocolSessionTreeMutationOutcomeMessage _decodeSessionTreeMutationOutcome(
    wire.SessionTreeMutationOutcome response,
  ) {
    final requestId = _semanticPositiveInt(response.requestId);
    _requestCorrelations.remove(requestId);
    final outcome = switch (response.whichOutcome()) {
      wire.SessionTreeMutationOutcome_Outcome.result =>
        PiProtocolSessionTreeMutationUpdated(
          session: _semanticSessionDetail(response.result.session),
          tree: _semanticSessionTree(response.result.tree),
          editorText: response.result.editorText.isEmpty
              ? null
              : response.result.editorText,
        ),
      wire.SessionTreeMutationOutcome_Outcome.error =>
        PiProtocolSessionTreeMutationFailed(_semanticFailure(response.error)),
      wire.SessionTreeMutationOutcome_Outcome.notSet =>
        throw const PiProtocolCodecException(
          PiProtocolCodecErrorCode.malformedFrame,
        ),
    };
    return PiProtocolSessionTreeMutationOutcomeMessage(
      requestId: requestId,
      commandId: response.commandId,
      operation: _semanticSessionTreeMutationOperation(response.operation),
      outcome: outcome,
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
    if (envelope.whichCorrelation() ==
        wire.ErrorEnvelope_Correlation.transferId) {
      return PiProtocolTransferAbortMessage(
        transferId: envelope.transferId,
        failure: _semanticFailure(envelope.error),
      );
    }
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
      wire.SessionEventStreamEnvelope_Event.entryUpsert =>
        PiProtocolConversationEntryUpsertEvent(
          entry: _semanticConversationEntry(envelope.entryUpsert.entry),
          expectedPreviousRevision:
              envelope.entryUpsert.hasExpectedPreviousRevision()
              ? _semanticPositiveInt(
                  envelope.entryUpsert.expectedPreviousRevision,
                )
              : null,
        ),
      wire.SessionEventStreamEnvelope_Event.partDelta =>
        PiProtocolConversationPartDeltaEvent(
          entryId: envelope.partDelta.entryId,
          expectedEntryRevision: _semanticPositiveInt(
            envelope.partDelta.expectedEntryRevision,
          ),
          resultingEntryRevision: _semanticPositiveInt(
            envelope.partDelta.resultingEntryRevision,
          ),
          partId: envelope.partDelta.partId,
          expectedPartRevision: _semanticPositiveInt(
            envelope.partDelta.expectedPartRevision,
          ),
          resultingPartRevision: _semanticPositiveInt(
            envelope.partDelta.resultingPartRevision,
          ),
          textDelta: envelope.partDelta.textDelta,
        ),
      wire.SessionEventStreamEnvelope_Event.entryFinalized =>
        PiProtocolConversationEntryFinalizedEvent(
          entry: _semanticConversationEntry(envelope.entryFinalized.entry),
          expectedPreviousRevision: _semanticNonNegativeInt(
            envelope.entryFinalized.expectedPreviousRevision,
          ),
        ),
      wire.SessionEventStreamEnvelope_Event.toolActivity =>
        PiProtocolConversationToolActivityEvent(
          entryId: envelope.toolActivity.entryId,
          expectedEntryRevision: _semanticPositiveInt(
            envelope.toolActivity.expectedEntryRevision,
          ),
          resultingEntryRevision: _semanticPositiveInt(
            envelope.toolActivity.resultingEntryRevision,
          ),
          activity: _semanticToolActivity(envelope.toolActivity.activity),
        ),
      wire.SessionEventStreamEnvelope_Event.metrics =>
        PiProtocolConversationMetricsEvent(
          entryId: envelope.metrics.entryId,
          expectedEntryRevision: _semanticPositiveInt(
            envelope.metrics.expectedEntryRevision,
          ),
          resultingEntryRevision: _semanticPositiveInt(
            envelope.metrics.resultingEntryRevision,
          ),
          metrics: _semanticConversationMetrics(envelope.metrics.metrics),
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
    adminRevision: summary.adminRevision,
    hasCustomName: summary.hasCustomName,
    parentSessionId: summary.parentSessionId.isEmpty
        ? null
        : summary.parentSessionId,
  );

  PiProtocolSessionDetail _semanticSessionDetail(
    wire.SessionDetailSnapshot detail,
  ) => PiProtocolSessionDetail(
    summary: _semanticSessionSummary(detail.summary),
    conversation: _semanticConversationSnapshot(detail.conversation),
  );

  PiProtocolConversationSnapshot _semanticConversationSnapshot(
    wire.ConversationSnapshot snapshot,
  ) => PiProtocolConversationSnapshot(
    sessionId: snapshot.sessionId,
    entries: snapshot.entries.map(_semanticConversationEntry),
    lastEventSequence: _semanticNonNegativeInt(snapshot.lastEventSequence),
  );

  PiProtocolConversationPage _semanticConversationPage(
    wire.ConversationPage page,
  ) => PiProtocolConversationPage(
    sessionId: page.sessionId,
    entries: page.entries.map(_semanticConversationEntry),
    nextCursor: page.nextCursor.isEmpty ? null : page.nextCursor,
    hasMore: page.hasMore,
    activeBranchRevision: page.activeBranchRevision,
    treeRevision: page.treeRevision,
    lastEventSequence: _semanticNonNegativeInt(page.lastEventSequence),
  );

  PiProtocolConversationEntry _semanticConversationEntry(
    wire.ConversationEntry entry,
  ) {
    return switch (entry.whichKind()) {
      wire.ConversationEntry_Kind.user => _semanticConversationEntryCommon(
        entry,
        PiProtocolConversationEntryType.user,
      ),
      wire.ConversationEntry_Kind.assistant => _semanticConversationEntryCommon(
        entry,
        PiProtocolConversationEntryType.assistant,
        provider: entry.assistant.provider,
        model: entry.assistant.model,
        stopReason: entry.assistant.stopReason,
        safeErrorMessage: entry.assistant.safeErrorMessage.isEmpty
            ? null
            : entry.assistant.safeErrorMessage,
      ),
      wire.ConversationEntry_Kind.toolResult =>
        _semanticConversationEntryCommon(
          entry,
          PiProtocolConversationEntryType.toolResult,
          toolCallId: entry.toolResult.toolCallId,
          toolName: entry.toolResult.toolName,
          isError: entry.toolResult.isError,
          safeDetails: _semanticSafeValue(entry.toolResult.safeDetails),
        ),
      wire.ConversationEntry_Kind.bash => _semanticConversationEntryCommon(
        entry,
        PiProtocolConversationEntryType.bash,
        command: entry.bash.command,
        exitCode: entry.bash.hasExitCode() ? entry.bash.exitCode : null,
        cancelled: entry.bash.cancelled,
        truncated: entry.bash.truncated,
        excludedFromContext: entry.bash.excludedFromContext,
      ),
      wire.ConversationEntry_Kind.custom => _semanticConversationEntryCommon(
        entry,
        PiProtocolConversationEntryType.custom,
        customType: entry.custom.customType,
        display: entry.custom.display,
        safeDetails: _semanticSafeValue(entry.custom.safeDetails),
      ),
      wire.ConversationEntry_Kind.compaction =>
        _semanticConversationEntryCommon(
          entry,
          PiProtocolConversationEntryType.compaction,
          firstKeptEntryId: entry.compaction.firstKeptEntryId,
          tokensBefore: _semanticNonNegativeInt(entry.compaction.tokensBefore),
          fromHook: entry.compaction.fromHook,
          safeDetails: _semanticSafeValue(entry.compaction.safeDetails),
        ),
      wire.ConversationEntry_Kind.branchSummary =>
        _semanticConversationEntryCommon(
          entry,
          PiProtocolConversationEntryType.branchSummary,
          fromEntryId: entry.branchSummary.fromEntryId,
          fromHook: entry.branchSummary.fromHook,
          safeDetails: _semanticSafeValue(entry.branchSummary.safeDetails),
        ),
      wire.ConversationEntry_Kind.marker => _semanticConversationEntryCommon(
        entry,
        PiProtocolConversationEntryType.marker,
        markerKind: _semanticMarkerKind(entry.marker.markerKind),
        targetEntryId: entry.marker.targetEntryId.isEmpty
            ? null
            : entry.marker.targetEntryId,
        label: entry.marker.label.isEmpty ? null : entry.marker.label,
        provider: entry.marker.provider.isEmpty ? null : entry.marker.provider,
        model: entry.marker.model.isEmpty ? null : entry.marker.model,
        thinkingLevel: entry.marker.thinkingLevel.isEmpty
            ? null
            : entry.marker.thinkingLevel,
      ),
      wire.ConversationEntry_Kind.unknown => _semanticConversationEntryCommon(
        entry,
        PiProtocolConversationEntryType.unknown,
        sourceType: entry.unknown.sourceType,
      ),
      wire.ConversationEntry_Kind.notSet =>
        throw const PiProtocolCodecException(
          PiProtocolCodecErrorCode.malformedFrame,
        ),
    };
  }

  PiProtocolConversationEntry _semanticConversationEntryCommon(
    wire.ConversationEntry entry,
    PiProtocolConversationEntryType type, {
    String? provider,
    String? model,
    String? stopReason,
    String? safeErrorMessage,
    String? toolCallId,
    String? toolName,
    bool? isError,
    PiProtocolSafeValue? safeDetails,
    String? command,
    int? exitCode,
    bool? cancelled,
    bool? truncated,
    bool? excludedFromContext,
    String? customType,
    bool? display,
    String? firstKeptEntryId,
    int? tokensBefore,
    bool? fromHook,
    String? fromEntryId,
    PiProtocolConversationMarkerKind? markerKind,
    String? targetEntryId,
    String? label,
    String? thinkingLevel,
    String? sourceType,
  }) => PiProtocolConversationEntry(
    entryId: entry.identity.entryId,
    scope: _semanticConversationIdentityScope(entry.identity.scope),
    originCommandId: entry.identity.originCommandId.isEmpty
        ? null
        : entry.identity.originCommandId,
    revision: _semanticPositiveInt(entry.revision),
    createdAt: _semanticInstant(entry.createdAtUnixMillis),
    finalized: entry.finalized,
    parts: entry.parts.map(_semanticConversationPart),
    toolActivities: entry.toolActivities.map(_semanticToolActivity),
    metrics: entry.hasMetrics()
        ? _semanticConversationMetrics(entry.metrics)
        : null,
    type: type,
    provider: provider,
    model: model,
    stopReason: stopReason,
    safeErrorMessage: safeErrorMessage,
    toolCallId: toolCallId,
    toolName: toolName,
    isError: isError,
    safeDetails: safeDetails,
    command: command,
    exitCode: exitCode,
    cancelled: cancelled,
    truncated: truncated,
    excludedFromContext: excludedFromContext,
    customType: customType,
    display: display,
    firstKeptEntryId: firstKeptEntryId,
    tokensBefore: tokensBefore,
    fromHook: fromHook,
    fromEntryId: fromEntryId,
    markerKind: markerKind,
    targetEntryId: targetEntryId,
    label: label,
    thinkingLevel: thinkingLevel,
    sourceType: sourceType,
  );

  PiProtocolConversationPart _semanticConversationPart(
    wire.ConversationPart part,
  ) => switch (part.whichKind()) {
    wire.ConversationPart_Kind.text => PiProtocolConversationPart(
      partId: part.partId,
      revision: _semanticPositiveInt(part.revision),
      type: PiProtocolConversationPartType.text,
      text: part.text.whichContent() == wire.BoundedTextPart_Content.inlineText
          ? part.text.inlineText
          : null,
      contentReference:
          part.text.whichContent() ==
              wire.BoundedTextPart_Content.contentReference
          ? _semanticContentReference(part.text.contentReference)
          : null,
    ),
    wire.ConversationPart_Kind.thinking => PiProtocolConversationPart(
      partId: part.partId,
      revision: _semanticPositiveInt(part.revision),
      type: PiProtocolConversationPartType.thinking,
      thinkingVisibility: _semanticThinkingVisibility(part.thinking.visibility),
      text: part.thinking.whichContent() == wire.ThinkingPart_Content.inlineText
          ? part.thinking.inlineText
          : null,
      contentReference:
          part.thinking.whichContent() ==
              wire.ThinkingPart_Content.contentReference
          ? _semanticContentReference(part.thinking.contentReference)
          : null,
    ),
    wire.ConversationPart_Kind.image => PiProtocolConversationPart(
      partId: part.partId,
      revision: _semanticPositiveInt(part.revision),
      type: PiProtocolConversationPartType.image,
      contentReference: _semanticContentReference(part.image.contentReference),
    ),
    wire.ConversationPart_Kind.toolCall => PiProtocolConversationPart(
      partId: part.partId,
      revision: _semanticPositiveInt(part.revision),
      type: PiProtocolConversationPartType.toolCall,
      toolCallId: part.toolCall.toolCallId,
      toolName: part.toolCall.toolName,
      safeArguments: _semanticSafeValue(part.toolCall.safeArguments),
    ),
    wire.ConversationPart_Kind.unsupported => PiProtocolConversationPart(
      partId: part.partId,
      revision: _semanticPositiveInt(part.revision),
      type: PiProtocolConversationPartType.unsupported,
      sourceType: part.unsupported.sourceType,
    ),
    wire.ConversationPart_Kind.notSet => throw const PiProtocolCodecException(
      PiProtocolCodecErrorCode.malformedFrame,
    ),
  };

  PiProtocolMessageContentReference _semanticContentReference(
    wire.MessageContentReference reference,
  ) => PiProtocolMessageContentReference(
    contentId: reference.contentId,
    mimeType: reference.mimeType,
    displayName: reference.displayName,
    totalBytes: _semanticPositiveInt(reference.totalBytes),
    sha256: Uint8List.fromList(reference.sha256),
  );

  PiProtocolMessageContentBinding _semanticMessageContentBinding(
    wire.MessageContentBinding binding,
  ) => PiProtocolMessageContentBinding(
    sessionId: binding.sessionId,
    entryId: binding.entryId,
    partId: binding.partId,
    entryRevision: _semanticPositiveInt(binding.entryRevision),
    partRevision: _semanticPositiveInt(binding.partRevision),
    contentId: binding.contentId,
  );

  PiProtocolSafeValue _semanticSafeValue(wire.SafeValue value) => switch (value
      .whichValue()) {
    wire.SafeValue_Value.sentinel => switch (value.sentinel) {
      wire.SafeValueKind.SAFE_VALUE_KIND_NULL => const PiProtocolSafeNull(),
      wire.SafeValueKind.SAFE_VALUE_KIND_REDACTED =>
        const PiProtocolSafeRedacted(),
      _ => throw const PiProtocolCodecException(
        PiProtocolCodecErrorCode.malformedFrame,
      ),
    },
    wire.SafeValue_Value.boolValue => PiProtocolSafeBool(value.boolValue),
    wire.SafeValue_Value.intValue => PiProtocolSafeInt(
      _semanticSignedInt(value.intValue),
    ),
    wire.SafeValue_Value.doubleValue => PiProtocolSafeDouble(value.doubleValue),
    wire.SafeValue_Value.stringValue => PiProtocolSafeString(value.stringValue),
    wire.SafeValue_Value.listValue => PiProtocolSafeList(
      value.listValue.values.map(_semanticSafeValue),
    ),
    wire.SafeValue_Value.objectValue => PiProtocolSafeObject(
      value.objectValue.fields.map(
        (field) => PiProtocolSafeObjectField(
          key: field.key,
          value: _semanticSafeValue(field.value),
        ),
      ),
    ),
    wire.SafeValue_Value.notSet => throw const PiProtocolCodecException(
      PiProtocolCodecErrorCode.malformedFrame,
    ),
  };

  PiProtocolToolActivity _semanticToolActivity(wire.ToolActivity activity) =>
      PiProtocolToolActivity(
        activityId: activity.activityId,
        toolCallId: activity.toolCallId,
        toolName: activity.toolName,
        sourceOrdinal: activity.sourceOrdinal,
        revision: _semanticPositiveInt(activity.revision),
        status: _semanticToolActivityStatus(activity.status),
        progressBasisPoints: activity.hasProgressBasisPoints()
            ? activity.progressBasisPoints
            : null,
        safeDetails: _semanticSafeValue(activity.safeDetails),
      );

  PiProtocolConversationMetrics _semanticConversationMetrics(
    wire.ConversationMetrics metrics,
  ) => PiProtocolConversationMetrics(
    usage: PiProtocolUsageMetrics(
      inputTokens: _semanticNonNegativeInt(metrics.usage.inputTokens),
      outputTokens: _semanticNonNegativeInt(metrics.usage.outputTokens),
      cacheReadTokens: _semanticNonNegativeInt(metrics.usage.cacheReadTokens),
      cacheWriteTokens: _semanticNonNegativeInt(metrics.usage.cacheWriteTokens),
      totalTokens: _semanticNonNegativeInt(metrics.usage.totalTokens),
    ),
    cost: PiProtocolMoneyAmount(
      currencyCode: metrics.cost.currencyCode,
      decimalAmount: metrics.cost.decimalAmount,
    ),
    context: metrics.hasContext()
        ? PiProtocolContextMetrics(
            tokens: metrics.context.hasTokens()
                ? _semanticNonNegativeInt(metrics.context.tokens)
                : null,
            contextWindow: _semanticPositiveInt(metrics.context.contextWindow),
            percentDecimal: metrics.context.hasPercentDecimal()
                ? metrics.context.percentDecimal
                : null,
          )
        : null,
  );

  PiProtocolSessionTreeSnapshot _semanticSessionTree(
    wire.SessionTreeSnapshot tree,
  ) => PiProtocolSessionTreeSnapshot(
    sessionId: tree.sessionId,
    nodes: tree.nodes.map(
      (node) => PiProtocolSessionTreeNodeSnapshot(
        entryId: node.entryId,
        parentEntryId: node.parentEntryId.isEmpty ? null : node.parentEntryId,
        kind: _semanticSessionTreeEntryKind(node.kind),
        text: node.text,
        createdAt: _semanticInstant(node.createdAtUnixMillis),
        label: node.label.isEmpty ? null : node.label,
        depth: node.depth,
        isOnActivePath: node.isOnActivePath,
        hasChildren: node.hasChildren,
        canEditFromHere: node.canEditFromHere,
        canFork: node.canFork,
      ),
    ),
    activePathEntryIds: tree.activePathEntryIds,
    activeLeafEntryId: tree.activeLeafEntryId.isEmpty
        ? null
        : tree.activeLeafEntryId,
    canCloneActiveBranch: tree.canCloneActiveBranch,
    adminRevision: tree.adminRevision,
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
      PiProtocolCreateSessionRequest() ||
      PiProtocolGetSessionTreeRequest() ||
      PiProtocolGetSessionHistoryRequest() ||
      PiProtocolGetMessageContentRequest() ||
      PiProtocolGetSessionStatsRequest() ||
      PiProtocolExportSessionRequest() => const _RegularRequestCorrelation(),
      PiProtocolPromptCommandRequest(:final commandId) ||
      PiProtocolAbortCommandRequest(:final commandId) ||
      PiProtocolSessionAdminCommandRequest(:final commandId) ||
      PiProtocolSessionTreeMutationCommandRequest(
        :final commandId,
      ) => _CommandCorrelation(commandId),
      PiProtocolHandshakeOfferMessage() ||
      PiProtocolTransferWindowUpdate() ||
      PiProtocolTransferAckMessage() ||
      PiProtocolCancelTransferMessage() => null,
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
final _minimumExactDartInt64 = Int64(-_maximumExactDartInt);
const _maximumExactDartInt = 9007199254740991;
const _maximumUint32 = 0xffffffff;

final _clientCapabilities = <wire.Capability>[
  wire.Capability.CAPABILITY_SESSION_READ,
  wire.Capability.CAPABILITY_SESSION_CREATE,
  wire.Capability.CAPABILITY_PROMPT_COMMAND,
  wire.Capability.CAPABILITY_ABORT_COMMAND,
  wire.Capability.CAPABILITY_SESSION_EVENTS,
  wire.Capability.CAPABILITY_CANCELLATION,
  wire.Capability.CAPABILITY_FLOW_CONTROL,
  wire.Capability.CAPABILITY_TRANSFER,
  wire.Capability.CAPABILITY_PROJECT_DISCOVERY,
  wire.Capability.CAPABILITY_PROJECT_TRUST,
  wire.Capability.CAPABILITY_SESSION_ADMIN,
  wire.Capability.CAPABILITY_SESSION_TREE,
  wire.Capability.CAPABILITY_SESSION_HISTORY,
  wire.Capability.CAPABILITY_SESSION_STATS,
  wire.Capability.CAPABILITY_SESSION_EXPORT,
  wire.Capability.CAPABILITY_RICH_CONVERSATION,
  wire.Capability.CAPABILITY_MESSAGE_CONTENT,
];

wire.MessageContentBinding _wireMessageContentBinding(
  PiProtocolMessageContentBinding binding,
) => wire.MessageContentBinding(
  sessionId: binding.sessionId,
  entryId: binding.entryId,
  partId: binding.partId,
  entryRevision: _wirePositiveInt(binding.entryRevision),
  partRevision: _wirePositiveInt(binding.partRevision),
  contentId: binding.contentId,
);

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

int _semanticSignedInt(Int64 value) {
  if (value.compareTo(_minimumExactDartInt64) < 0 ||
      value.compareTo(_maximumExactDartInt64) > 0) {
    throw const PiProtocolCodecException(
      PiProtocolCodecErrorCode.integerOutOfRange,
    );
  }
  return value.toInt();
}

int _semanticNonNegativeInt(Int64 value) {
  if (value.isNegative || value.compareTo(_maximumExactDartInt64) > 0) {
    throw const PiProtocolCodecException(
      PiProtocolCodecErrorCode.integerOutOfRange,
    );
  }
  return value.toInt();
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
  if (capability == wire.Capability.CAPABILITY_CANCELLATION) {
    return PiProtocolCapability.cancellation;
  }
  if (capability == wire.Capability.CAPABILITY_FLOW_CONTROL) {
    return PiProtocolCapability.flowControl;
  }
  if (capability == wire.Capability.CAPABILITY_TRANSFER) {
    return PiProtocolCapability.transfer;
  }
  if (capability == wire.Capability.CAPABILITY_PROJECT_DISCOVERY) {
    return PiProtocolCapability.projectDiscovery;
  }
  if (capability == wire.Capability.CAPABILITY_PROJECT_TRUST) {
    return PiProtocolCapability.projectTrust;
  }
  if (capability == wire.Capability.CAPABILITY_SESSION_ADMIN) {
    return PiProtocolCapability.sessionAdmin;
  }
  if (capability == wire.Capability.CAPABILITY_SESSION_TREE) {
    return PiProtocolCapability.sessionTree;
  }
  if (capability == wire.Capability.CAPABILITY_SESSION_HISTORY) {
    return PiProtocolCapability.sessionHistory;
  }
  if (capability == wire.Capability.CAPABILITY_SESSION_STATS) {
    return PiProtocolCapability.sessionStats;
  }
  if (capability == wire.Capability.CAPABILITY_SESSION_EXPORT) {
    return PiProtocolCapability.sessionExport;
  }
  if (capability == wire.Capability.CAPABILITY_RICH_CONVERSATION) {
    return PiProtocolCapability.richConversation;
  }
  if (capability == wire.Capability.CAPABILITY_MESSAGE_CONTENT) {
    return PiProtocolCapability.messageContent;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
}

PiProtocolConversationIdentityScope _semanticConversationIdentityScope(
  wire.ConversationIdentityScope scope,
) {
  if (scope ==
      wire.ConversationIdentityScope.CONVERSATION_IDENTITY_SCOPE_PERSISTENT) {
    return PiProtocolConversationIdentityScope.persistent;
  }
  if (scope ==
      wire.ConversationIdentityScope.CONVERSATION_IDENTITY_SCOPE_RUNTIME) {
    return PiProtocolConversationIdentityScope.runtime;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
}

PiProtocolConversationMarkerKind _semanticMarkerKind(wire.MarkerKind kind) {
  if (kind == wire.MarkerKind.MARKER_KIND_THINKING_LEVEL) {
    return PiProtocolConversationMarkerKind.thinkingLevel;
  }
  if (kind == wire.MarkerKind.MARKER_KIND_MODEL_CHANGE) {
    return PiProtocolConversationMarkerKind.modelChange;
  }
  if (kind == wire.MarkerKind.MARKER_KIND_LABEL) {
    return PiProtocolConversationMarkerKind.label;
  }
  if (kind == wire.MarkerKind.MARKER_KIND_SESSION_INFO) {
    return PiProtocolConversationMarkerKind.sessionInfo;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
}

PiProtocolThinkingVisibility _semanticThinkingVisibility(
  wire.ThinkingVisibility visibility,
) {
  if (visibility == wire.ThinkingVisibility.THINKING_VISIBILITY_VISIBLE) {
    return PiProtocolThinkingVisibility.visible;
  }
  if (visibility == wire.ThinkingVisibility.THINKING_VISIBILITY_REDACTED) {
    return PiProtocolThinkingVisibility.redacted;
  }
  if (visibility == wire.ThinkingVisibility.THINKING_VISIBILITY_DEFERRED) {
    return PiProtocolThinkingVisibility.deferred;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
}

PiProtocolToolActivityStatus _semanticToolActivityStatus(
  wire.ToolActivityStatus status,
) {
  if (status == wire.ToolActivityStatus.TOOL_ACTIVITY_STATUS_PENDING) {
    return PiProtocolToolActivityStatus.pending;
  }
  if (status == wire.ToolActivityStatus.TOOL_ACTIVITY_STATUS_RUNNING) {
    return PiProtocolToolActivityStatus.running;
  }
  if (status == wire.ToolActivityStatus.TOOL_ACTIVITY_STATUS_SUCCEEDED) {
    return PiProtocolToolActivityStatus.succeeded;
  }
  if (status == wire.ToolActivityStatus.TOOL_ACTIVITY_STATUS_FAILED) {
    return PiProtocolToolActivityStatus.failed;
  }
  if (status == wire.ToolActivityStatus.TOOL_ACTIVITY_STATUS_CANCELLED) {
    return PiProtocolToolActivityStatus.cancelled;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
}

PiProtocolTransferPurpose _semanticTransferPurpose(
  wire.TransferPurpose purpose,
) {
  if (purpose == wire.TransferPurpose.TRANSFER_PURPOSE_ATTACHMENT) {
    return PiProtocolTransferPurpose.attachment;
  }
  if (purpose == wire.TransferPurpose.TRANSFER_PURPOSE_EXPORT) {
    return PiProtocolTransferPurpose.export;
  }
  if (purpose == wire.TransferPurpose.TRANSFER_PURPOSE_MESSAGE_CONTENT) {
    return PiProtocolTransferPurpose.messageContent;
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

PiProtocolSessionAdminOperation _semanticSessionAdminOperation(
  wire.SessionAdminOperation operation,
) {
  if (operation == wire.SessionAdminOperation.SESSION_ADMIN_OPERATION_RENAME) {
    return PiProtocolSessionAdminOperation.rename;
  }
  if (operation ==
      wire.SessionAdminOperation.SESSION_ADMIN_OPERATION_CLEAR_NAME) {
    return PiProtocolSessionAdminOperation.clearName;
  }
  if (operation ==
      wire.SessionAdminOperation.SESSION_ADMIN_OPERATION_AUTO_NAME) {
    return PiProtocolSessionAdminOperation.autoName;
  }
  if (operation == wire.SessionAdminOperation.SESSION_ADMIN_OPERATION_DELETE) {
    return PiProtocolSessionAdminOperation.delete;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
}

PiProtocolSessionTreeMutationOperation _semanticSessionTreeMutationOperation(
  wire.SessionTreeMutationOperation operation,
) {
  if (operation ==
      wire
          .SessionTreeMutationOperation
          .SESSION_TREE_MUTATION_OPERATION_NAVIGATE) {
    return PiProtocolSessionTreeMutationOperation.navigate;
  }
  if (operation ==
      wire.SessionTreeMutationOperation.SESSION_TREE_MUTATION_OPERATION_FORK) {
    return PiProtocolSessionTreeMutationOperation.fork;
  }
  if (operation ==
      wire.SessionTreeMutationOperation.SESSION_TREE_MUTATION_OPERATION_CLONE) {
    return PiProtocolSessionTreeMutationOperation.clone;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
}

PiProtocolSessionTreeEntryKind _semanticSessionTreeEntryKind(
  wire.SessionTreeEntryKind kind,
) {
  if (kind == wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_USER_MESSAGE) {
    return PiProtocolSessionTreeEntryKind.userMessage;
  }
  if (kind ==
      wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_ASSISTANT_MESSAGE) {
    return PiProtocolSessionTreeEntryKind.assistantMessage;
  }
  if (kind == wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_TOOL_MESSAGE) {
    return PiProtocolSessionTreeEntryKind.toolMessage;
  }
  if (kind ==
      wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_CUSTOM_MESSAGE) {
    return PiProtocolSessionTreeEntryKind.customMessage;
  }
  if (kind ==
      wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_THINKING_LEVEL) {
    return PiProtocolSessionTreeEntryKind.thinkingLevel;
  }
  if (kind == wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_MODEL_CHANGE) {
    return PiProtocolSessionTreeEntryKind.modelChange;
  }
  if (kind == wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_COMPACTION) {
    return PiProtocolSessionTreeEntryKind.compaction;
  }
  if (kind ==
      wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_BRANCH_SUMMARY) {
    return PiProtocolSessionTreeEntryKind.branchSummary;
  }
  if (kind == wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_CUSTOM) {
    return PiProtocolSessionTreeEntryKind.custom;
  }
  if (kind == wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_LABEL) {
    return PiProtocolSessionTreeEntryKind.label;
  }
  if (kind == wire.SessionTreeEntryKind.SESSION_TREE_ENTRY_KIND_SESSION_INFO) {
    return PiProtocolSessionTreeEntryKind.sessionInfo;
  }
  throw const PiProtocolCodecException(
    PiProtocolCodecErrorCode.unsupportedOperation,
  );
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
