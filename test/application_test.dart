import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/core/providers.dart';
import 'package:pi_client/main.dart' show Application;

void main() {
  testWidgets('builds the routed Pi Client application', (tester) async {
    final dio = Dio()
      ..httpClientAdapter = _StaticAdapter(
        ResponseBody.fromString(
          jsonEncode(<String, dynamic>{
            'sessions': <Object>[],
            'runningSessionIds': <Object>[],
          }),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        ),
      );

    await tester.pumpWidget(AppProviders(dio: dio, child: const Application()));
    await tester.pumpAndSettle();

    expect(find.text('Pi Client'), findsOneWidget);
    expect(find.byKey(const Key('connectButton')), findsOneWidget);
    expect(find.textContaining('No sessions'), findsOneWidget);
  });

  testWidgets('preserves an externally injected Dio owner', (tester) async {
    final dio = Dio();
    late Dio resolvedDio;

    await tester.pumpWidget(
      AppProviders(
        dio: dio,
        child: _RuntimeProbe(
          onMount: (context) => resolvedDio = context.read<Dio>(),
        ),
      ),
    );

    expect(resolvedDio, same(dio));
  });
}

class _RuntimeProbe extends StatefulWidget {
  const _RuntimeProbe({required this.onMount});

  final ValueChanged<BuildContext> onMount;

  @override
  State<_RuntimeProbe> createState() => _RuntimeProbeState();
}

class _RuntimeProbeState extends State<_RuntimeProbe> {
  var _mountedRuntime = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mountedRuntime) return;
    _mountedRuntime = true;
    widget.onMount(context);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

final class _StaticAdapter implements HttpClientAdapter {
  _StaticAdapter(this.response);

  final ResponseBody response;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => response;

  @override
  void close({bool force = false}) {}
}
