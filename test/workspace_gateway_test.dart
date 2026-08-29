import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';

void main() {
  test('normalizes loopback and reverse-proxy base URLs', () {
    final gateway = PiWebGateway(Dio());

    expect(
      gateway.normalizeBaseUrl('127.0.0.1:30141/'),
      'http://127.0.0.1:30141',
    );
    expect(
      gateway.normalizeBaseUrl('https://example.test/pi-web/'),
      'https://example.test/pi-web',
    );
    expect(
      () => gateway.normalizeBaseUrl('file:///tmp/pi-web'),
      throwsA(isA<PiWebGatewayException>()),
    );
  });

  test('sends Basic Auth without putting credentials in the URL', () async {
    late RequestOptions captured;
    final dio = Dio()
      ..httpClientAdapter = _CallbackAdapter((options, requestStream) async {
        captured = options;
        return ResponseBody.fromString(
          jsonEncode(<String, dynamic>{
            'sessions': <Object>[],
            'runningSessionIds': <Object>[],
          }),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );
      });
    final gateway = PiWebGateway(dio);

    await gateway.loadSessions(
      baseUrl: 'http://127.0.0.1:30141',
      password: 'secret',
      force: true,
    );

    expect(captured.uri.path, '/api/sessions');
    expect(captured.uri.queryParameters['force'], '1');
    expect(captured.uri.userInfo, isEmpty);
    expect(
      captured.headers['Authorization'],
      'Basic ${base64Encode(utf8.encode('pi:secret'))}',
    );
  });

  test('parses pi-web SSE data frames and ignores heartbeats', () async {
    final bytes = utf8.encode(
      ':\n\n'
      'data: {"type":"connected","sessionId":"s1"}\n\n'
      'data: {"type":"message_update","assistantMessageEvent":{"type":"text_delta","delta":"Hi"}}\n\n',
    );
    final dio = Dio()
      ..httpClientAdapter = _CallbackAdapter((options, requestStream) async {
        return ResponseBody(
          Stream<Uint8List>.fromIterable(<Uint8List>[
            Uint8List.fromList(bytes),
          ]),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>['text/event-stream'],
          },
        );
      });
    final gateway = PiWebGateway(dio);

    final events = await gateway
        .watchEvents(
          baseUrl: 'http://127.0.0.1:30141',
          password: '',
          sessionId: 's1',
        )
        .toList();

    expect(events, hasLength(2));
    expect(events.first['type'], 'connected');
    expect(events.last['assistantMessageEvent'], isA<Map<String, dynamic>>());
  });
}

typedef _AdapterCallback =
    Future<ResponseBody> Function(
      RequestOptions options,
      Stream<Uint8List>? requestStream,
    );

final class _CallbackAdapter implements HttpClientAdapter {
  _CallbackAdapter(this.callback);

  final _AdapterCallback callback;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => callback(options, requestStream);

  @override
  void close({bool force = false}) {}
}
