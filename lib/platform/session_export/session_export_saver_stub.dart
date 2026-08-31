import '../../api/pi_node/pi_node.dart';
import 'session_export_saver.dart';

PiSessionExportSaver createPlatformSessionExportSaver() =>
    const _UnsupportedSessionExportSaver();

final class _UnsupportedSessionExportSaver implements PiSessionExportSaver {
  const _UnsupportedSessionExportSaver();

  @override
  Future<PiSessionExportSaveResult> save(
    PiSessionExportHandle handle, {
    required void Function(int savedBytes, int totalBytes) onProgress,
  }) async {
    await handle.cancel();
    throw const PiSessionExportSaveException(
      PiSessionExportSaveErrorCode.unsupported,
    );
  }
}
