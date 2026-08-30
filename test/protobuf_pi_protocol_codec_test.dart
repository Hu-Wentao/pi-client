import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/protocol/pi_protocol.dart';
import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart' as wire;

void main() {
  group('ProtobufPiProtocolCodec', () {
    late ProtobufPiProtocolCodec codec;
    late _ServerFrameEncoder server;

    setUp(() {
      codec = ProtobufPiProtocolCodec(
        clientInstanceId: 'flutter-test-client',
        implementationVersion: '0.1.0',
      );
      server = _ServerFrameEncoder();
    });

    test('preserves version preference and encodes every client operation', () {
      final preferred = PiProtocolVersion(0, 2, 0);
      final fallback = PiProtocolVersion(0, 1, 0);
      final handshake = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolHandshakeOfferMessage(
            PiProtocolOffer(<PiProtocolVersion>[preferred, fallback]),
          ),
        ),
      );

      expect(
        handshake.whichOperation(),
        wire.PiTransportFrame_Operation.clientProtocolOffer,
      );
      expect(
        handshake.clientProtocolOffer.protocolVersions.map(
          (version) => '${version.major}.${version.minor}.${version.patch}',
        ),
        <String>['0.2.0', '0.1.0'],
      );
      expect(
        handshake.clientProtocolOffer.capabilities,
        containsAll(<wire.Capability>[
          wire.Capability.CAPABILITY_SESSION_READ,
          wire.Capability.CAPABILITY_SESSION_CREATE,
          wire.Capability.CAPABILITY_PROMPT_COMMAND,
          wire.Capability.CAPABILITY_ABORT_COMMAND,
          wire.Capability.CAPABILITY_SESSION_EVENTS,
        ]),
      );

      final list = wire.decodeTransportFrame(
        codec.encode(PiProtocolListSessionsRequest(requestId: 1)),
      );
      final get = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolGetSessionRequest(requestId: 2, sessionId: 'session-1'),
        ),
      );
      final create = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolCreateSessionRequest(
            requestId: 3,
            workingDirectory: '/safe/project',
          ),
        ),
      );
      final prompt = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolPromptCommandRequest(
            requestId: 4,
            commandId: 'command-1',
            sessionId: 'session-1',
            prompt: 'private prompt',
          ),
        ),
      );
      final abort = wire.decodeTransportFrame(
        codec.encode(
          PiProtocolAbortCommandRequest(
            requestId: 5,
            commandId: 'command-2',
            sessionId: 'session-1',
          ),
        ),
      );

      expect(
        list.whichOperation(),
        wire.PiTransportFrame_Operation.listSessionsRequest,
      );
      expect(list.listSessionsRequest.requestId.toInt(), 1);
      expect(
        get.whichOperation(),
        wire.PiTransportFrame_Operation.getSessionRequest,
      );
      expect(get.getSessionRequest.sessionId, 'session-1');
      expect(
        create.whichOperation(),
        wire.PiTransportFrame_Operation.createSessionRequest,
      );
      expect(create.createSessionRequest.workingDirectory, '/safe/project');
      expect(
        prompt.whichOperation(),
        wire.PiTransportFrame_Operation.promptCommand,
      );
      expect(prompt.promptCommand.prompt, 'private prompt');
      expect(
        abort.whichOperation(),
        wire.PiTransportFrame_Operation.abortCommand,
      );
      expect(abort.abortCommand.commandId, 'command-2');
      expect(
        <int>[
          handshake.frameSequence.toInt(),
          list.frameSequence.toInt(),
          get.frameSequence.toInt(),
          create.frameSequence.toInt(),
          prompt.frameSequence.toInt(),
          abort.frameSequence.toInt(),
        ],
        <int>[1, 2, 3, 4, 5, 6],
      );
    });

    test('decodes handshake, request, and command outcomes', () {
      final accepted =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    serverHandshakeAccepted: wire.ServerHandshakeAccepted(
                      selectedProtocolVersion: wire.ProtocolVersion(
                        major: 0,
                        minor: 1,
                        patch: 0,
                      ),
                      nodeInstanceId: 'node-1',
                      implementationName: 'pi-node',
                      implementationVersion: '0.1.0',
                      maxFrameBytes: wire.maxFrameBytes,
                      maxTransferChunkBytes: wire.maxTransferChunkBytes,
                    ),
                  ),
                ),
              )
              as PiProtocolHandshakeAcceptedMessage;
      expect(accepted.negotiatedVersion, PiProtocolVersion(0, 1, 0));

      final rejected =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    serverHandshakeRejected: wire.ServerHandshakeRejected(
                      error: _stableError(
                        wire.ErrorCode.ERROR_CODE_PERMISSION_DENIED,
                      ),
                    ),
                  ),
                ),
              )
              as PiProtocolHandshakeRejectedMessage;
      expect(rejected.failure.code, 'permission_denied');

      final sessions =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    listSessionsResponse: wire.ListSessionsResponse(
                      requestId: Int64(1),
                      sessions: <wire.SessionSummarySnapshot>[
                        _summary('session-1'),
                      ],
                    ),
                  ),
                ),
              )
              as PiProtocolSessionsResponse;
      expect(sessions.requestId, 1);
      expect(sessions.sessions.single.id, 'session-1');

      final detail =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    getSessionResponse: wire.GetSessionResponse(
                      requestId: Int64(2),
                      session: _detail('session-2'),
                    ),
                  ),
                ),
              )
              as PiProtocolSessionResponse;
      expect(
        detail.session.messages.single.role,
        PiProtocolMessageRole.assistant,
      );
      expect(detail.session.messages.single.createdAt.isUtc, isTrue);

      final created =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    createSessionResponse: wire.CreateSessionResponse(
                      requestId: Int64(3),
                      session: _detail('session-3'),
                    ),
                  ),
                ),
              )
              as PiProtocolSessionCreatedResponse;
      expect(created.session.summary.id, 'session-3');

      final requestRejected =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    requestRejected: wire.RequestRejected(
                      requestId: Int64(4),
                      error: _stableError(wire.ErrorCode.ERROR_CODE_NOT_FOUND),
                    ),
                  ),
                ),
              )
              as PiProtocolRequestRejectedMessage;
      expect(requestRejected.failure.code, 'not_found');

      final commandAccepted =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    commandAccepted: wire.CommandAccepted(
                      requestId: Int64(5),
                      commandId: 'command-accepted',
                    ),
                  ),
                ),
              )
              as PiProtocolCommandAcceptedMessage;
      expect(commandAccepted.commandId, 'command-accepted');

      final commandRejected =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    commandRejected: wire.CommandRejected(
                      requestId: Int64(6),
                      commandId: 'command-rejected',
                      error: _stableError(wire.ErrorCode.ERROR_CODE_CONFLICT),
                    ),
                  ),
                ),
              )
              as PiProtocolCommandRejectedMessage;
      expect(commandRejected.failure.code, 'conflict');
    });

    test('maps correlated error envelopes to command uncertainty', () {
      codec.encode(
        PiProtocolPromptCommandRequest(
          requestId: 7,
          commandId: 'command-uncertain',
          sessionId: 'session-1',
          prompt: 'private prompt',
        ),
      );

      final result =
          codec.decode(
                server.encode(
                  wire.PiTransportFrame(
                    error: wire.ErrorEnvelope(
                      requestId: Int64(7),
                      error: _stableError(wire.ErrorCode.ERROR_CODE_NODE_BUSY),
                    ),
                  ),
                ),
              )
              as PiProtocolCommandUncertainMessage;

      expect(result.requestId, 7);
      expect(result.commandId, 'command-uncertain');
      expect(result.failure.code, 'node_busy');
      expect(result.failure.retryable, isTrue);
    });

    test('decodes every current session event payload', () {
      final added =
          codec.decode(
                server.encode(
                  _sessionEventFrame(
                    sequence: 1,
                    messageAdded: wire.MessageAddedEvent(
                      message: _message('message-added'),
                    ),
                  ),
                ),
              )
              as PiProtocolSessionEventMessage;
      expect(added.event, isA<PiProtocolMessageAddedEvent>());

      final delta =
          codec.decode(
                server.encode(
                  _sessionEventFrame(
                    sequence: 2,
                    messageDelta: wire.MessageDeltaEvent(
                      messageId: 'message-added',
                      delta: 'delta',
                    ),
                  ),
                ),
              )
              as PiProtocolSessionEventMessage;
      expect((delta.event as PiProtocolMessageDeltaEvent).delta, 'delta');

      final running =
          codec.decode(
                server.encode(
                  _sessionEventFrame(
                    sequence: 3,
                    runningChanged: wire.SessionRunningChangedEvent(
                      isRunning: true,
                    ),
                  ),
                ),
              )
              as PiProtocolSessionEventMessage;
      expect(
        (running.event as PiProtocolSessionRunningChangedEvent).isRunning,
        isTrue,
      );

      final completed =
          codec.decode(
                server.encode(
                  _sessionEventFrame(
                    sequence: 4,
                    commandCompleted: wire.CommandCompletedEvent(
                      commandId: 'command-completed',
                      succeeded: true,
                    ),
                  ),
                ),
              )
              as PiProtocolSessionEventMessage;
      expect(completed.sequence, 4);
      expect(
        (completed.event as PiProtocolCommandCompletedEvent).succeeded,
        isTrue,
      );
    });

    test('maps all stable Protobuf error codes to machine-safe names', () {
      final expected = <wire.ErrorCode, String>{
        wire.ErrorCode.ERROR_CODE_AUTHENTICATION_REQUIRED:
            'authentication_required',
        wire.ErrorCode.ERROR_CODE_PERMISSION_DENIED: 'permission_denied',
        wire.ErrorCode.ERROR_CODE_NOT_FOUND: 'not_found',
        wire.ErrorCode.ERROR_CODE_INVALID_REQUEST: 'invalid_request',
        wire.ErrorCode.ERROR_CODE_CONFLICT: 'conflict',
        wire.ErrorCode.ERROR_CODE_NODE_BUSY: 'node_busy',
        wire.ErrorCode.ERROR_CODE_PROTOCOL_VERSION_UNSUPPORTED:
            'protocol_version_unsupported',
        wire.ErrorCode.ERROR_CODE_CANCELLED: 'cancelled',
        wire.ErrorCode.ERROR_CODE_DEADLINE_EXCEEDED: 'deadline_exceeded',
        wire.ErrorCode.ERROR_CODE_UNAVAILABLE: 'unavailable',
        wire.ErrorCode.ERROR_CODE_DATA_LOSS: 'data_loss',
        wire.ErrorCode.ERROR_CODE_INTERNAL: 'internal',
        wire.ErrorCode.ERROR_CODE_PROTOCOL_VIOLATION: 'protocol_violation',
        wire.ErrorCode.ERROR_CODE_RESOURCE_EXHAUSTED: 'resource_exhausted',
        wire.ErrorCode.ERROR_CODE_ALREADY_EXISTS: 'already_exists',
        wire.ErrorCode.ERROR_CODE_FAILED_PRECONDITION: 'failed_precondition',
      };

      var requestId = 100;
      for (final entry in expected.entries) {
        final response =
            codec.decode(
                  server.encode(
                    wire.PiTransportFrame(
                      requestRejected: wire.RequestRejected(
                        requestId: Int64(requestId),
                        error: _stableError(entry.key),
                      ),
                    ),
                  ),
                )
                as PiProtocolRequestRejectedMessage;
        expect(response.failure.code, entry.value);
        requestId += 1;
      }
    });

    test('fails closed for committed out-of-range and unknown vectors', () {
      final vectors = Directory.current.uri.resolve('protocol/test-vectors/');

      for (final name in <String>[
        'dart_session_event.pb',
        'ts_session_response.pb',
      ]) {
        expect(
          () => codec.decode(
            Uint8List.fromList(
              File.fromUri(vectors.resolve(name)).readAsBytesSync(),
            ),
          ),
          throwsA(
            isA<PiProtocolCodecException>().having(
              (error) => error.code,
              'code',
              PiProtocolCodecErrorCode.integerOutOfRange,
            ),
          ),
        );
      }

      for (final name in <String>['unknown_enum.pb', 'unknown_operation.pb']) {
        expect(
          () => codec.decode(
            Uint8List.fromList(
              File.fromUri(vectors.resolve(name)).readAsBytesSync(),
            ),
          ),
          throwsA(isA<PiProtocolCodecException>()),
        );
      }
    });

    test('rejects unsupported known operations and oversized Dart IDs', () {
      expect(
        () => codec.decode(
          server.encode(
            wire.PiTransportFrame(
              healthResponse: wire.HealthResponse(
                requestId: Int64(1),
                status: wire.HealthStatus.HEALTH_STATUS_SERVING,
                nodeVersion: '0.1.0',
                uptimeMillis: Int64(1),
              ),
            ),
          ),
        ),
        throwsA(
          isA<PiProtocolCodecException>().having(
            (error) => error.code,
            'code',
            PiProtocolCodecErrorCode.unsupportedOperation,
          ),
        ),
      );

      expect(
        () => codec.encode(
          PiProtocolListSessionsRequest(requestId: 9007199254740992),
        ),
        throwsA(
          isA<PiProtocolCodecException>().having(
            (error) => error.code,
            'code',
            PiProtocolCodecErrorCode.integerOutOfRange,
          ),
        ),
      );
    });
  });
}

final class _ServerFrameEncoder {
  var _sequence = 1;

  Uint8List encode(wire.PiTransportFrame frame) {
    frame.frameSequence = Int64(_sequence);
    _sequence += 1;
    return wire.encodeTransportFrame(frame);
  }
}

wire.StableError _stableError(wire.ErrorCode code) => wire.StableError(
  code: code,
  retryable: code == wire.ErrorCode.ERROR_CODE_NODE_BUSY,
  safeMessage: 'Safe remote failure.',
);

wire.SessionSummarySnapshot _summary(String id) => wire.SessionSummarySnapshot(
  sessionId: id,
  title: 'Session title',
  workingDirectory: '/safe/project',
  createdAtUnixMillis: Int64(1767268800000),
  updatedAtUnixMillis: Int64(1767268860000),
  isRunning: false,
  hasUnread: false,
);

wire.SessionDetailSnapshot _detail(String id) => wire.SessionDetailSnapshot(
  summary: _summary(id),
  messages: <wire.MessageSnapshot>[_message('message-1')],
);

wire.MessageSnapshot _message(String id) => wire.MessageSnapshot(
  messageId: id,
  role: wire.MessageRole.MESSAGE_ROLE_ASSISTANT,
  text: 'Message text',
  createdAtUnixMillis: Int64(1767268800000),
  isStreaming: false,
);

wire.PiTransportFrame _sessionEventFrame({
  required int sequence,
  wire.MessageAddedEvent? messageAdded,
  wire.MessageDeltaEvent? messageDelta,
  wire.SessionRunningChangedEvent? runningChanged,
  wire.CommandCompletedEvent? commandCompleted,
}) => wire.PiTransportFrame(
  sessionEventStream: wire.SessionEventStreamEnvelope(
    streamId: 'session-events-1',
    sessionId: 'session-1',
    eventSequence: Int64(sequence),
    messageAdded: messageAdded,
    messageDelta: messageDelta,
    runningChanged: runningChanged,
    commandCompleted: commandCompleted,
  ),
);
