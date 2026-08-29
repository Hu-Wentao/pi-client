import 'dart:convert';

import 'package:dio/dio.dart';

abstract interface class PiWebApi {
  String normalizeBaseUrl(String value);

  Future<Map<String, dynamic>> loadSessions({
    required String baseUrl,
    required String password,
    bool force = false,
  });

  Future<Map<String, dynamic>> loadSession({
    required String baseUrl,
    required String password,
    required String sessionId,
  });

  Future<String> ensureSession({
    required String baseUrl,
    required String password,
    required String cwd,
  });

  Future<void> sendPrompt({
    required String baseUrl,
    required String password,
    required String sessionId,
    required String message,
  });

  Future<void> abort({
    required String baseUrl,
    required String password,
    required String sessionId,
  });

  Stream<Map<String, dynamic>> watchEvents({
    required String baseUrl,
    required String password,
    required String sessionId,
  });
}

final class PiWebGateway implements PiWebApi {
  PiWebGateway(this._dio);

  final Dio _dio;

  @override
  String normalizeBaseUrl(String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) {
      throw const PiWebGatewayException('Server URL is required.');
    }
    if (!normalized.contains('://')) normalized = 'http://$normalized';
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty) {
      throw const PiWebGatewayException(
        'Enter an absolute http(s) URL without credentials, query, or fragment.',
      );
    }
    final path = uri.path == '/'
        ? ''
        : uri.path.replaceFirst(RegExp(r'/+$'), '');
    return uri.replace(path: path).toString();
  }

  @override
  Future<Map<String, dynamic>> loadSessions({
    required String baseUrl,
    required String password,
    bool force = false,
  }) async {
    final response = await _request(
      'GET',
      _endpoint(baseUrl, 'api/sessions'),
      password: password,
      queryParameters: force ? const <String, dynamic>{'force': '1'} : null,
    );
    return _object(response.data);
  }

  @override
  Future<Map<String, dynamic>> loadSession({
    required String baseUrl,
    required String password,
    required String sessionId,
  }) async {
    final encoded = Uri.encodeComponent(sessionId);
    final response = await _request(
      'GET',
      _endpoint(baseUrl, 'api/sessions/$encoded'),
      password: password,
      queryParameters: const <String, dynamic>{
        'deferThinking': '1',
        'deferMedia': '1',
        'tail': '100',
      },
    );
    return _object(response.data);
  }

  @override
  Future<String> ensureSession({
    required String baseUrl,
    required String password,
    required String cwd,
  }) async {
    final response = await _request(
      'POST',
      _endpoint(baseUrl, 'api/agent/new'),
      password: password,
      data: <String, dynamic>{'cwd': cwd, 'type': 'ensure_session'},
    );
    final data = _object(response.data);
    final sessionId = data['sessionId'];
    if (sessionId is! String || sessionId.isEmpty) {
      throw const PiWebGatewayException('pi-web did not return a session id.');
    }
    return sessionId;
  }

  @override
  Future<void> sendPrompt({
    required String baseUrl,
    required String password,
    required String sessionId,
    required String message,
  }) async {
    final encoded = Uri.encodeComponent(sessionId);
    await _request(
      'POST',
      _endpoint(baseUrl, 'api/agent/$encoded'),
      password: password,
      data: <String, dynamic>{'type': 'prompt', 'message': message},
    );
  }

  @override
  Future<void> abort({
    required String baseUrl,
    required String password,
    required String sessionId,
  }) async {
    final encoded = Uri.encodeComponent(sessionId);
    await _request(
      'POST',
      _endpoint(baseUrl, 'api/agent/$encoded'),
      password: password,
      data: const <String, dynamic>{'type': 'abort'},
    );
  }

  @override
  Stream<Map<String, dynamic>> watchEvents({
    required String baseUrl,
    required String password,
    required String sessionId,
  }) async* {
    final encoded = Uri.encodeComponent(sessionId);
    final response = await _request(
      'GET',
      _endpoint(baseUrl, 'api/agent/$encoded/events'),
      password: password,
      responseType: ResponseType.stream,
      receiveTimeout: Duration.zero,
    );
    final body = response.data;
    if (body is! ResponseBody) {
      throw const PiWebGatewayException('pi-web returned an invalid SSE body.');
    }

    final dataLines = <String>[];
    await for (final line
        in utf8.decoder.bind(body.stream).transform(const LineSplitter())) {
      if (line.isEmpty) {
        if (dataLines.isEmpty) continue;
        final raw = dataLines.join('\n');
        dataLines.clear();
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          yield Map<String, dynamic>.from(decoded);
        }
        continue;
      }
      if (line.startsWith(':')) continue;
      if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trimLeft());
      }
    }
  }

  Uri _endpoint(String baseUrl, String relativePath) {
    final root = Uri.parse('${normalizeBaseUrl(baseUrl)}/');
    return root.resolve(relativePath);
  }

  Options _options(
    String password, {
    ResponseType responseType = ResponseType.json,
    Duration? receiveTimeout,
  }) {
    final headers = <String, dynamic>{
      Headers.acceptHeader: responseType == ResponseType.stream
          ? 'text/event-stream'
          : Headers.jsonContentType,
    };
    if (password.isNotEmpty) {
      headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('pi:$password'))}';
    }
    return Options(
      responseType: responseType,
      headers: headers,
      contentType: Headers.jsonContentType,
      receiveTimeout: receiveTimeout,
      sendTimeout: const Duration(seconds: 20),
    );
  }

  Future<Response<dynamic>> _request(
    String method,
    Uri uri, {
    required String password,
    Object? data,
    Map<String, dynamic>? queryParameters,
    ResponseType responseType = ResponseType.json,
    Duration? receiveTimeout = const Duration(seconds: 45),
  }) async {
    final requestUri = queryParameters == null
        ? uri
        : uri.replace(queryParameters: queryParameters);
    try {
      return await _dio.requestUri<dynamic>(
        requestUri,
        data: data,
        options: _options(
          password,
          responseType: responseType,
          receiveTimeout: receiveTimeout,
        ).copyWith(method: method),
      );
    } on DioException catch (error) {
      final response = error.response;
      final body = response?.data;
      final object = body is Map ? Map<String, dynamic>.from(body) : null;
      throw PiWebGatewayException(
        object?['error']?.toString() ??
            error.message ??
            'pi-web request failed.',
        statusCode: response?.statusCode,
        code: object?['code']?.toString(),
        accepted: object?['accepted'] as bool?,
      );
    }
  }

  Map<String, dynamic> _object(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const PiWebGatewayException('pi-web returned invalid JSON.');
  }
}

final class PiWebGatewayException implements Exception {
  const PiWebGatewayException(
    this.message, {
    this.statusCode,
    this.code,
    this.accepted,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final bool? accepted;

  @override
  String toString() => message;
}
