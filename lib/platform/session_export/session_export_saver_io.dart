import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';

import '../../api/pi_node/pi_node.dart';
import 'session_export_saver.dart';

PiSessionExportSaver createPlatformSessionExportSaver() =>
    const _NativeSessionExportSaver();

final class _NativeSessionExportSaver implements PiSessionExportSaver {
  const _NativeSessionExportSaver();

  static const MethodChannel _mobileChannel = MethodChannel(
    'io.github.huwentao.pi_client/session_export',
  );

  @override
  Future<PiSessionExportSaveResult> save(
    PiSessionExportHandle handle, {
    required void Function(int savedBytes, int totalBytes) onProgress,
  }) => Platform.isAndroid || Platform.isIOS
      ? _saveMobile(handle, onProgress)
      : _saveDesktop(handle, onProgress);

  Future<PiSessionExportSaveResult> _saveDesktop(
    PiSessionExportHandle handle,
    void Function(int savedBytes, int totalBytes) onProgress,
  ) async {
    final fileName = safePiSessionExportFileName(handle);
    File? temporary;
    try {
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: <XTypeGroup>[
          XTypeGroup(
            label: handle.contentType.startsWith('text/html')
                ? 'HTML session export'
                : 'JSONL session export',
            extensions: <String>[
              handle.contentType.startsWith('text/html') ? 'html' : 'jsonl',
            ],
            mimeTypes: <String>[handle.contentType.split(';').first],
          ),
        ],
        confirmButtonText: 'Export',
        canCreateDirectories: true,
      );
      if (location == null) {
        await handle.cancel();
        return PiSessionExportSaveResult.cancelled(fileName);
      }

      final destination = File(location.path);
      temporary = File(
        '${destination.path}.pi-client-${DateTime.now().microsecondsSinceEpoch}.part',
      );
      await _streamToFile(handle, temporary, onProgress);
      if (await destination.exists()) await destination.delete();
      await temporary.rename(destination.path);
      temporary = null;
      return PiSessionExportSaveResult.saved(fileName);
    } catch (error, stackTrace) {
      await handle.cancel();
      if (temporary != null && await temporary.exists()) {
        await temporary.delete().catchError((Object _) => temporary!);
      }
      _throwSaveError(error, stackTrace);
    }
  }

  Future<PiSessionExportSaveResult> _saveMobile(
    PiSessionExportHandle handle,
    void Function(int savedBytes, int totalBytes) onProgress,
  ) async {
    final fileName = safePiSessionExportFileName(handle);
    final directory = await Directory.systemTemp.createTemp(
      'pi-client-session-export-',
    );
    final temporary = File(
      '${directory.path}${Platform.pathSeparator}$fileName',
    );
    try {
      await _streamToFile(handle, temporary, onProgress);
      final saved =
          await _mobileChannel
              .invokeMethod<bool>('saveExport', <String, Object>{
                'temporaryPath': temporary.path,
                'fileName': fileName,
                'contentType': handle.contentType.split(';').first,
              }) ??
          false;
      return saved
          ? PiSessionExportSaveResult.saved(fileName)
          : PiSessionExportSaveResult.cancelled(fileName);
    } catch (error, stackTrace) {
      await handle.cancel();
      _throwSaveError(error, stackTrace);
    } finally {
      await directory
          .delete(recursive: true)
          .catchError((Object _) => directory);
    }
  }

  Future<void> _streamToFile(
    PiSessionExportHandle handle,
    File file,
    void Function(int savedBytes, int totalBytes) onProgress,
  ) async {
    IOSink? sink;
    var savedBytes = 0;
    try {
      sink = file.openWrite(mode: FileMode.writeOnly);
      await for (final chunk in handle.bytes) {
        sink.add(chunk);
        savedBytes += chunk.length;
        onProgress(savedBytes, handle.totalBytes);
      }
      await sink.flush();
      await sink.close();
      sink = null;
      await handle.done;
      if (savedBytes != handle.totalBytes) {
        throw const PiSessionExportSaveException(
          PiSessionExportSaveErrorCode.integrityFailed,
        );
      }
    } finally {
      await sink?.close().catchError((Object _) {});
    }
  }

  Never _throwSaveError(Object error, StackTrace stackTrace) {
    if (error is PiSessionExportSaveException || error is PiNodeException) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    Error.throwWithStackTrace(
      const PiSessionExportSaveException(
        PiSessionExportSaveErrorCode.writeFailed,
      ),
      stackTrace,
    );
  }
}
