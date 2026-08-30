import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart';

void main() {
  final vectorDirectory = Directory('../test-vectors')
    ..createSync(recursive: true);
  final frame = PiTransportFrame(
    frameSequence: Int64.parseInt('9007199254740995'),
    eventStream: EventStreamEnvelope(
      streamId: 'events-dart-1',
      eventSequence: Int64.parseInt('9007199254740997'),
      heartbeat: HeartbeatEvent(
        observedUnixMillis: Int64.parseInt('1735689600123'),
      ),
    ),
  );
  File.fromUri(
    vectorDirectory.uri.resolve('dart_event_stream.pb'),
  ).writeAsBytesSync(encodeTransportFrame(frame));
}
