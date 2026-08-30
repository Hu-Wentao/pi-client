import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

Future<void> main(List<String> arguments) async {
  final mode = arguments.singleOrNull ?? 'echo';
  switch (mode) {
    case 'echo':
      await _runEchoFixture();
    case 'malformed':
      await Future<void>.delayed(const Duration(milliseconds: 50));
      stdout.add(const <int>[0, 0, 0, 0]);
      await stdout.flush();
    case 'exit':
      await Future<void>.delayed(const Duration(milliseconds: 50));
      stderr.add('bounded fixture exit'.codeUnits);
      await stderr.flush();
      exitCode = 7;
    default:
      exitCode = 64;
  }
}

Future<void> _runEchoFixture() async {
  stderr.add(List<int>.filled(256 * 1024, 120));
  await stderr.flush();

  final decoder = _FixtureDecoder();
  await for (final chunk in stdin) {
    for (final payload in decoder.push(chunk)) {
      final frame = _lengthPrefix(payload);
      stdout.add(frame.sublist(0, 2));
      await stdout.flush();
      stdout.add(frame.sublist(2, 5));
      await stdout.flush();
      stdout.add(frame.sublist(5));
      await stdout.flush();
    }
  }
  decoder.finish();
}

Uint8List _lengthPrefix(List<int> payload) {
  final result = Uint8List(4 + payload.length);
  ByteData.sublistView(result).setUint32(0, payload.length, Endian.big);
  result.setRange(4, result.length, payload);
  return result;
}

final class _FixtureDecoder {
  Uint8List _pending = Uint8List(0);

  List<Uint8List> push(List<int> chunk) {
    final combined = Uint8List(_pending.length + chunk.length)
      ..setRange(0, _pending.length, _pending)
      ..setRange(_pending.length, _pending.length + chunk.length, chunk);
    final frames = <Uint8List>[];
    var offset = 0;
    while (combined.length - offset >= 4) {
      final length = ByteData.sublistView(
        combined,
        offset,
        offset + 4,
      ).getUint32(0, Endian.big);
      if (length <= 0 || length > 1024 * 1024) {
        throw StateError('invalid fixture frame');
      }
      final end = offset + 4 + length;
      if (combined.length < end) break;
      frames.add(Uint8List.sublistView(combined, offset + 4, end));
      offset = end;
    }
    _pending = Uint8List.fromList(combined.sublist(offset));
    return frames;
  }

  void finish() {
    if (_pending.isNotEmpty) throw StateError('truncated fixture frame');
  }
}
