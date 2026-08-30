import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart';
import 'package:test/test.dart';

final _maximumUint64 = Int64(-1);

ProtocolVersion _protocolVersion([int minor = 1, int patch = 0]) =>
    ProtocolVersion(major: 0, minor: minor, patch: patch);

StableError _stableError([ErrorCode code = ErrorCode.ERROR_CODE_NOT_FOUND]) =>
    StableError(
      code: code,
      retryable: false,
      safeMessage: 'The requested resource was not found.',
    );

SessionSummarySnapshot _sessionSummary() => SessionSummarySnapshot(
  sessionId: 'session-1',
  title: 'Protocol work',
  workingDirectory: '/tmp/pi-client-protocol',
  createdAtUnixMillis: Int64.parseInt('9007199254740993'),
  updatedAtUnixMillis: Int64.parseInt('9007199254740999'),
  isRunning: true,
  hasUnread: false,
  adminRevision: 'revision-session-1',
  hasCustomName: true,
);

SessionDetailSnapshot _sessionDetail() => SessionDetailSnapshot(
  summary: _sessionSummary(),
  messages: [
    MessageSnapshot(
      messageId: 'message-1',
      role: MessageRole.MESSAGE_ROLE_USER,
      text: 'Implement the typed protocol boundary.',
      createdAtUnixMillis: Int64.parseInt('9007199254741001'),
      isStreaming: false,
    ),
    MessageSnapshot(
      messageId: 'message-2',
      role: MessageRole.MESSAGE_ROLE_ASSISTANT,
      text: 'Working on it.',
      createdAtUnixMillis: Int64.parseInt('9007199254741003'),
      isStreaming: true,
    ),
  ],
);

PiTransportFrame _validHealthFrame() => PiTransportFrame(
  frameSequence: _maximumUint64,
  healthResponse: HealthResponse(
    requestId: Int64.parseInt('9007199254740999'),
    status: HealthStatus.HEALTH_STATUS_SERVING,
    nodeVersion: '0.1.0-alpha.1+spike',
    uptimeMillis: Int64.parseInt('9007199254741111'),
  ),
);

void main() {
  group('bounded Protobuf frame codec', () {
    test('round-trips exact v0 SemVer offers and full-range uint64 values', () {
      final offered = PiTransportFrame(
        frameSequence: _maximumUint64,
        clientProtocolOffer: ClientProtocolOffer(
          protocolVersions: [_protocolVersion(3), _protocolVersion(2, 4)],
          capabilities: [
            Capability.CAPABILITY_SESSION_READ,
            Capability.CAPABILITY_PROMPT_COMMAND,
            Capability.CAPABILITY_SESSION_EVENTS,
          ],
          clientInstanceId: 'client-1',
          implementationName: 'Pi Client',
          implementationVersion: '0.1.0-alpha.1+spike',
          maxFrameBytes: maxFrameBytes,
          maxTransferChunkBytes: maxTransferChunkBytes,
        ),
      );

      final decoded = decodeTransportFrame(encodeTransportFrame(offered));
      expect(decoded.frameSequence.toHexString(), 'FFFFFFFFFFFFFFFF');
      expect(
        decoded.whichOperation(),
        PiTransportFrame_Operation.clientProtocolOffer,
      );
      expect(
        decoded.clientProtocolOffer.protocolVersions
            .map(
              (version) => '${version.major}.${version.minor}.${version.patch}',
            )
            .toList(),
        ['0.3.0', '0.2.4'],
      );
    });

    test('round-trips handshake and core session operations', () {
      final detail = _sessionDetail();
      final frames = <PiTransportFrame>[
        PiTransportFrame(
          frameSequence: Int64(1),
          serverHandshakeAccepted: ServerHandshakeAccepted(
            selectedProtocolVersion: _protocolVersion(),
            capabilities: [
              Capability.CAPABILITY_SESSION_READ,
              Capability.CAPABILITY_SESSION_EVENTS,
            ],
            nodeInstanceId: 'node-1',
            implementationName: 'Pi Node',
            implementationVersion: '0.1.0',
            maxFrameBytes: maxFrameBytes,
            maxTransferChunkBytes: maxTransferChunkBytes,
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(2),
          serverHandshakeRejected: ServerHandshakeRejected(
            error: _stableError(
              ErrorCode.ERROR_CODE_PROTOCOL_VERSION_UNSUPPORTED,
            ),
            supportedProtocolVersions: [_protocolVersion()],
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(3),
          listSessionsRequest: ListSessionsRequest(
            requestId: Int64(1),
            projectId: 'project-1',
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(4),
          listSessionsResponse: ListSessionsResponse(
            requestId: Int64(2),
            sessions: [_sessionSummary()],
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(5),
          getSessionRequest: GetSessionRequest(
            requestId: Int64(3),
            sessionId: 'session-1',
            projectId: 'project-1',
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(6),
          getSessionResponse: GetSessionResponse(
            requestId: Int64(4),
            session: detail,
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(7),
          createSessionRequest: CreateSessionRequest(
            requestId: Int64(5),
            projectId: 'project-1',
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(8),
          createSessionResponse: CreateSessionResponse(
            requestId: Int64(6),
            session: detail,
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(9),
          promptCommand: PromptCommand(
            requestId: Int64(7),
            commandId: 'command-1',
            sessionId: 'session-1',
            prompt: 'Continue.',
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(10),
          abortCommand: AbortCommand(
            requestId: Int64(8),
            commandId: 'command-2',
            sessionId: 'session-1',
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(11),
          requestRejected: RequestRejected(
            requestId: Int64(9),
            error: _stableError(),
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(12),
          commandAccepted: CommandAccepted(
            requestId: Int64(10),
            commandId: 'command-1',
          ),
        ),
        PiTransportFrame(
          frameSequence: Int64(13),
          commandRejected: CommandRejected(
            requestId: Int64(11),
            commandId: 'command-2',
            error: _stableError(ErrorCode.ERROR_CODE_CONFLICT),
          ),
        ),
      ];

      for (final frame in frames) {
        final decoded = decodeTransportFrame(encodeTransportFrame(frame));
        expect(decoded.whichOperation(), frame.whichOperation());
      }
    });

    test('round-trips every typed per-session stream event', () {
      final streams = <SessionEventStreamEnvelope>[
        SessionEventStreamEnvelope(
          streamId: 'stream-1',
          sessionId: 'session-1',
          eventSequence: Int64(1),
          messageAdded: MessageAddedEvent(
            message: _sessionDetail().messages.first,
          ),
        ),
        SessionEventStreamEnvelope(
          streamId: 'stream-1',
          sessionId: 'session-1',
          eventSequence: Int64(2),
          messageDelta: MessageDeltaEvent(
            messageId: 'message-2',
            delta: 'More output',
          ),
        ),
        SessionEventStreamEnvelope(
          streamId: 'stream-1',
          sessionId: 'session-1',
          eventSequence: Int64(3),
          runningChanged: SessionRunningChangedEvent(isRunning: false),
        ),
        SessionEventStreamEnvelope(
          streamId: 'stream-1',
          sessionId: 'session-1',
          eventSequence: Int64(4),
          commandCompleted: CommandCompletedEvent(
            commandId: 'command-1',
            succeeded: true,
          ),
        ),
      ];

      for (var index = 0; index < streams.length; index += 1) {
        final decoded = decodeTransportFrame(
          encodeTransportFrame(
            PiTransportFrame(
              frameSequence: Int64(index + 1),
              sessionEventStream: streams[index],
            ),
          ),
        );
        expect(
          decoded.whichOperation(),
          PiTransportFrame_Operation.sessionEventStream,
        );
      }
    });

    test('rejects truncated, malformed, and semantically invalid frames', () {
      expect(() => decodeTransportFrame([0x80]), throwsA(anything));
      expect(() => decodeTransportFrame([0x0a, 0x02, 0x01]), throwsA(anything));
      expect(
        () => decodeTransportFrame(Uint8List(maxFrameBytes + 1)),
        throwsA(isA<FrameValidationException>()),
      );
      expect(
        () => decodeTransportFrame([0x08, 0x01]),
        throwsA(isA<FrameValidationException>()),
      );

      final duplicateOffer = PiTransportFrame(
        frameSequence: Int64(1),
        clientProtocolOffer: ClientProtocolOffer(
          protocolVersions: [_protocolVersion(), _protocolVersion()],
          capabilities: [Capability.CAPABILITY_SESSION_READ],
          clientInstanceId: 'client-1',
          implementationName: 'Pi Client',
          implementationVersion: '0.1.0',
          maxFrameBytes: maxFrameBytes,
          maxTransferChunkBytes: maxTransferChunkBytes,
        ),
      );
      expect(
        () => encodeTransportFrame(duplicateOffer),
        throwsA(isA<FrameValidationException>()),
      );

      final invalidChunk = PiTransportFrame(
        frameSequence: Int64(2),
        transferChunk: TransferChunk(
          transferId: 'transfer-1',
          chunkSequence: Int64(1),
          data: Uint8List(maxTransferChunkBytes + 1),
        ),
      );
      expect(
        () => decodeTransportFrame(invalidChunk.writeToBuffer()),
        throwsA(isA<FrameValidationException>()),
      );
    });
  });

  group('stream IPC length prefix', () {
    test('decodes split and coalesced frames', () {
      final first = encodeIpcLengthPrefixedFrame(
        encodeTransportFrame(_validHealthFrame()),
      );
      final second = encodeIpcLengthPrefixedFrame(
        encodeTransportFrame(_validHealthFrame()),
      );
      final joined = Uint8List(first.length + second.length)
        ..setAll(0, first)
        ..setAll(first.length, second);

      final decoder = IpcLengthPrefixDecoder();
      expect(decoder.push(joined.sublist(0, 3)), isEmpty);
      expect(decoder.push(joined.sublist(3)), hasLength(2));
      decoder.finish();
    });

    test('rejects truncated, zero-length, and oversized stream frames', () {
      final truncated = IpcLengthPrefixDecoder()..push([0, 0, 0, 5, 1, 2]);
      expect(truncated.finish, throwsA(isA<IpcFrameException>()));

      expect(
        () => IpcLengthPrefixDecoder().push([0, 0, 0, 0]),
        throwsA(isA<IpcFrameException>()),
      );

      final header = ByteData(4)..setUint32(0, maxFrameBytes + 1, Endian.big);
      expect(
        () => IpcLengthPrefixDecoder().push(header.buffer.asUint8List()),
        throwsA(isA<IpcFrameException>()),
      );
    });
  });
}
