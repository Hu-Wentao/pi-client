import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/platform/session_export/session_export_saver.dart';

void main() {
  test('export save result and exceptions redact destination details', () {
    const saved = PiSessionExportSaveResult.saved('session.html');
    const cancelled = PiSessionExportSaveResult.cancelled('session.jsonl');
    const error = PiSessionExportSaveException(
      PiSessionExportSaveErrorCode.writeFailed,
    );

    expect(saved.saved, isTrue);
    expect(cancelled.saved, isFalse);
    expect(error.toString(), contains('<redacted>'));
  });

  test('sanitizes untrusted transfer file names without retaining paths', () {
    final handle = _ChunkedHandle(<Uint8List>[
      Uint8List(1),
    ], fileName: r'../../private\\session:secret');

    expect(safePiSessionExportFileName(handle), 'Pi-Client-session.jsonl');
  });

  test(
    'streaming saver fixture never requires a whole-file byte list',
    () async {
      final handle = _ChunkedHandle(<Uint8List>[
        Uint8List(1024),
        Uint8List(2048),
        Uint8List(4096),
      ]);
      final progress = <int>[];
      final result = await const _StreamingTestSaver().save(
        handle,
        onProgress: (saved, total) => progress.add(saved),
      );

      expect(result.saved, isTrue);
      expect(progress, <int>[1024, 3072, 7168]);
      expect(handle.listenCount, 1);
      expect(await handle.done.then((_) => true), isTrue);
    },
  );
}

final class _StreamingTestSaver implements PiSessionExportSaver {
  const _StreamingTestSaver();

  @override
  Future<PiSessionExportSaveResult> save(
    PiSessionExportHandle handle, {
    required void Function(int savedBytes, int totalBytes) onProgress,
  }) async {
    var saved = 0;
    await for (final chunk in handle.bytes) {
      saved += chunk.length;
      onProgress(saved, handle.totalBytes);
    }
    await handle.done;
    return PiSessionExportSaveResult.saved(handle.fileName);
  }
}

final class _ChunkedHandle implements PiSessionExportHandle {
  _ChunkedHandle(this._chunks, {this.fileName = 'session.jsonl'})
    : totalBytes = _chunks.fold(0, (sum, chunk) => sum + chunk.length);

  final List<Uint8List> _chunks;
  final Completer<void> _done = Completer<void>();
  int listenCount = 0;

  @override
  final String fileName;

  @override
  String get contentType => 'application/x-ndjson';

  @override
  final int totalBytes;

  @override
  List<int> get sha256 => List<int>.filled(32, 0);

  @override
  Stream<Uint8List> get bytes async* {
    listenCount += 1;
    for (final chunk in _chunks) {
      yield chunk;
    }
    _done.complete();
  }

  @override
  Future<void> get done => _done.future;

  @override
  Future<void> cancel() async {
    if (!_done.isCompleted) _done.complete();
  }
}
