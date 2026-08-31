import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart';
import 'package:test/test.dart';

void main() {
  group('rich conversation frame codec', () {
    test('round-trips a sealed conversation snapshot', () {
      final frame = PiTransportFrame(
        frameSequence: Int64(1),
        getSessionResponse: GetSessionResponse(
          requestId: Int64(1),
          session: _sessionDetail(),
        ),
      );

      final decoded = decodeTransportFrame(encodeTransportFrame(frame));
      final conversation = decoded.getSessionResponse.session.conversation;
      expect(conversation.sessionId, 'session-1');
      expect(conversation.lastEventSequence.toInt(), 7);
      expect(
        conversation.entries.single.whichKind(),
        ConversationEntry_Kind.assistant,
      );
      expect(
        conversation.entries.single.parts.map((part) => part.whichKind()),
        [ConversationPart_Kind.text, ConversationPart_Kind.thinking],
      );
    });

    test('accepts message content requests with exact bindings', () {
      final frame = PiTransportFrame(
        frameSequence: Int64(2),
        getMessageContentRequest: GetMessageContentRequest(
          requestId: Int64(2),
          projectId: 'project-1',
          binding: _binding(),
          expectedMimeType: 'image/png',
          expectedTotalBytes: Int64(4),
          expectedSha256: Uint8List(32),
        ),
      );

      expect(() => encodeTransportFrame(frame), returnsNormally);
    });

    test('accepts bound message content downloads', () {
      final frame = PiTransportFrame(
        frameSequence: Int64(3),
        transferOpen: TransferOpen(
          requestId: Int64(2),
          transferId: 'transfer-1',
          direction: TransferDirection.TRANSFER_DIRECTION_DOWNLOAD,
          purpose: TransferPurpose.TRANSFER_PURPOSE_MESSAGE_CONTENT,
          contentType: 'image/png',
          fileName: 'image.png',
          totalBytes: Int64(4),
          chunkBytes: 4,
          sha256: Uint8List(32),
          messageContentBinding: _binding(),
        ),
      );

      expect(() => encodeTransportFrame(frame), returnsNormally);
    });

    test('rejects unbound message content downloads', () {
      final frame = PiTransportFrame(
        frameSequence: Int64(4),
        transferOpen: TransferOpen(
          requestId: Int64(2),
          transferId: 'transfer-1',
          direction: TransferDirection.TRANSFER_DIRECTION_DOWNLOAD,
          purpose: TransferPurpose.TRANSFER_PURPOSE_MESSAGE_CONTENT,
          contentType: 'image/png',
          fileName: 'image.png',
          totalBytes: Int64(4),
          chunkBytes: 4,
          sha256: Uint8List(32),
        ),
      );

      expect(
        () => encodeTransportFrame(frame),
        throwsA(isA<FrameValidationException>()),
      );
    });

    test('rejects plaintext on redacted thinking parts', () {
      final detail = _sessionDetail();
      detail.conversation.entries.single.parts[1] = ConversationPart(
        partId: 'part-thinking',
        revision: Int64(1),
        thinking: ThinkingPart(
          visibility: ThinkingVisibility.THINKING_VISIBILITY_REDACTED,
          inlineText: 'must not cross the boundary',
        ),
      );
      final frame = PiTransportFrame(
        frameSequence: Int64(5),
        getSessionResponse: GetSessionResponse(
          requestId: Int64(1),
          session: detail,
        ),
      );

      expect(
        () => encodeTransportFrame(frame),
        throwsA(isA<FrameValidationException>()),
      );
    });

    test('rejects revision gaps in part delta events', () {
      final frame = PiTransportFrame(
        frameSequence: Int64(6),
        sessionEventStream: SessionEventStreamEnvelope(
          streamId: 'stream-1',
          sessionId: 'session-1',
          eventSequence: Int64(8),
          partDelta: ConversationPartDeltaEvent(
            entryId: 'entry-1',
            expectedEntryRevision: Int64(2),
            resultingEntryRevision: Int64(4),
            partId: 'part-text',
            expectedPartRevision: Int64(2),
            resultingPartRevision: Int64(3),
            textDelta: 'next',
          ),
        ),
      );

      expect(
        () => encodeTransportFrame(frame),
        throwsA(isA<FrameValidationException>()),
      );
    });

    test('rejects safe values beyond the item limit', () {
      final detail = _sessionDetail();
      detail.conversation.entries.single.assistant.safeErrorMessage = '';
      detail.conversation.entries.single.parts.add(
        ConversationPart(
          partId: 'part-tool',
          revision: Int64(1),
          toolCall: ToolCallPart(
            toolCallId: 'call-1',
            toolName: 'bounded-tool',
            safeArguments: SafeValue(
              listValue: SafeList(
                values: List<SafeValue>.generate(
                  maxSafeValueItems + 1,
                  (_) =>
                      SafeValue(sentinel: SafeValueKind.SAFE_VALUE_KIND_NULL),
                ),
              ),
            ),
          ),
        ),
      );
      final frame = PiTransportFrame(
        frameSequence: Int64(7),
        getSessionResponse: GetSessionResponse(
          requestId: Int64(1),
          session: detail,
        ),
      );

      expect(
        () => encodeTransportFrame(frame),
        throwsA(isA<FrameValidationException>()),
      );
    });

    test('accepts ordered parallel tool activities and exact metrics', () {
      final detail = _sessionDetail();
      final entry = detail.conversation.entries.single;
      entry.toolActivities.addAll([
        _activity('activity-1', 'call-1', 0),
        _activity('activity-2', 'call-2', 1),
      ]);
      entry.metrics = ConversationMetrics(
        usage: UsageMetrics(
          inputTokens: Int64(11),
          outputTokens: Int64(7),
          cacheReadTokens: Int64(3),
          cacheWriteTokens: Int64(2),
          totalTokens: Int64(23),
        ),
        cost: MoneyAmount(currencyCode: 'USD', decimalAmount: '0.00125'),
        context: ContextMetrics(
          tokens: Int64(23),
          contextWindow: Int64(200000),
          percentDecimal: '0.0115',
        ),
      );
      final frame = PiTransportFrame(
        frameSequence: Int64(8),
        getSessionResponse: GetSessionResponse(
          requestId: Int64(1),
          session: detail,
        ),
      );

      expect(() => encodeTransportFrame(frame), returnsNormally);
    });
  });
}

SessionDetailSnapshot _sessionDetail() => SessionDetailSnapshot(
  summary: SessionSummarySnapshot(
    sessionId: 'session-1',
    title: 'Rich conversation',
    workingDirectory: '/tmp/project',
    createdAtUnixMillis: Int64(1),
    updatedAtUnixMillis: Int64(2),
    adminRevision: 'admin-revision-1',
  ),
  conversation: ConversationSnapshot(
    sessionId: 'session-1',
    lastEventSequence: Int64(7),
    entries: [
      ConversationEntry(
        identity: ConversationEntryIdentity(
          entryId: 'entry-1',
          scope: ConversationIdentityScope.CONVERSATION_IDENTITY_SCOPE_RUNTIME,
          originCommandId: 'command-1',
        ),
        revision: Int64(2),
        createdAtUnixMillis: Int64(3),
        finalized: false,
        parts: [
          ConversationPart(
            partId: 'part-text',
            revision: Int64(2),
            text: BoundedTextPart(inlineText: 'Hello'),
          ),
          ConversationPart(
            partId: 'part-thinking',
            revision: Int64(1),
            thinking: ThinkingPart(
              visibility: ThinkingVisibility.THINKING_VISIBILITY_DEFERRED,
            ),
          ),
        ],
        assistant: AssistantConversationEntry(
          provider: 'provider',
          model: 'model',
          stopReason: 'streaming',
        ),
      ),
    ],
  ),
);

MessageContentBinding _binding() => MessageContentBinding(
  sessionId: 'session-1',
  entryId: 'entry-1',
  partId: 'part-image',
  entryRevision: Int64(2),
  partRevision: Int64(1),
  contentId: 'content-1',
);

ToolActivity _activity(String activityId, String toolCallId, int ordinal) =>
    ToolActivity(
      activityId: activityId,
      toolCallId: toolCallId,
      toolName: 'tool-$ordinal',
      sourceOrdinal: ordinal,
      revision: Int64(1),
      status: ToolActivityStatus.TOOL_ACTIVITY_STATUS_RUNNING,
      safeDetails: SafeValue(sentinel: SafeValueKind.SAFE_VALUE_KIND_NULL),
    );
