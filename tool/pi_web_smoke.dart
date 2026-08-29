import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';

Future<void> main(List<String> arguments) async {
  final baseUrl = arguments.isEmpty
      ? 'http://127.0.0.1:30141'
      : arguments.first;
  final password = Platform.environment['PI_WEB_PASSWORD'] ?? '';
  final dio = Dio();
  final gateway = PiWebGateway(dio);

  try {
    final payload = await gateway.loadSessions(
      baseUrl: baseUrl,
      password: password,
      force: true,
    );
    final sessions = payload['sessions'];
    final running = payload['runningSessionIds'];
    stdout.writeln(
      'pi-web smoke OK: sessions=${sessions is List ? sessions.length : 0}, '
      'running=${running is List ? running.length : 0}',
    );
  } finally {
    dio.close(force: true);
  }
}
