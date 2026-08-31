import '../../api/pi_node/pi_node.dart';
import 'session_export_saver_stub.dart'
    if (dart.library.io) 'session_export_saver_io.dart'
    if (dart.library.js_interop) 'session_export_saver_web.dart'
    as implementation;

PiSessionExportSaver createPlatformSessionExportSaver() =>
    implementation.createPlatformSessionExportSaver();

String safePiSessionExportFileName(PiSessionExportHandle handle) =>
    handle.contentType.startsWith('text/html')
    ? 'Pi-Client-session.html'
    : 'Pi-Client-session.jsonl';

abstract interface class PiSessionExportSaver {
  Future<PiSessionExportSaveResult> save(
    PiSessionExportHandle handle, {
    required void Function(int savedBytes, int totalBytes) onProgress,
  });
}

final class PiSessionExportSaveResult {
  const PiSessionExportSaveResult._({
    required this.saved,
    required this.fileName,
  });

  const PiSessionExportSaveResult.saved(String fileName)
    : this._(saved: true, fileName: fileName);

  const PiSessionExportSaveResult.cancelled(String fileName)
    : this._(saved: false, fileName: fileName);

  final bool saved;
  final String fileName;
}

enum PiSessionExportSaveErrorCode { unsupported, writeFailed, integrityFailed }

final class PiSessionExportSaveException implements Exception {
  const PiSessionExportSaveException(this.code);

  final PiSessionExportSaveErrorCode code;

  @override
  String toString() =>
      'PiSessionExportSaveException(code: ${code.name}, details: <redacted>)';
}
