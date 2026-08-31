import 'dart:js_interop';
import 'dart:typed_data';

import '../../api/pi_node/pi_node.dart';
import 'session_export_saver.dart';

PiSessionExportSaver createPlatformSessionExportSaver() =>
    const _BrowserSessionExportSaver();

@JS('globalThis.showSaveFilePicker')
external JSPromise<JSObject> _showSaveFilePicker(JSObject options);

extension type _BrowserFileHandle(JSObject _) implements JSObject {
  external JSPromise<_BrowserWritableFileStream> createWritable();
}

extension type _BrowserWritableFileStream(JSObject _) implements JSObject {
  external JSPromise<JSAny?> write(JSAny data);
  external JSPromise<JSAny?> close();
  external JSPromise<JSAny?> abort();
}

final class _BrowserSessionExportSaver implements PiSessionExportSaver {
  const _BrowserSessionExportSaver();

  @override
  Future<PiSessionExportSaveResult> save(
    PiSessionExportHandle handle, {
    required void Function(int savedBytes, int totalBytes) onProgress,
  }) async {
    _BrowserWritableFileStream? writable;
    final fileName = safePiSessionExportFileName(handle);
    try {
      final options =
          <String, Object?>{
                'suggestedName': fileName,
                'types': <Object?>[
                  <String, Object?>{
                    'description': 'Pi Client session export',
                    'accept': <String, Object?>{
                      handle.contentType.split(';').first: <String>[
                        handle.contentType.startsWith('text/html')
                            ? '.html'
                            : '.jsonl',
                      ],
                    },
                  },
                ],
              }.jsify()!
              as JSObject;
      final handleObject = await _showSaveFilePicker(options).toDart;
      final fileHandle = _BrowserFileHandle(handleObject);
      writable = await fileHandle.createWritable().toDart;
      var savedBytes = 0;
      await for (final chunk in handle.bytes) {
        final transferable = Uint8List.fromList(chunk).toJS;
        await writable.write(transferable).toDart;
        savedBytes += chunk.length;
        onProgress(savedBytes, handle.totalBytes);
      }
      await writable.close().toDart;
      writable = null;
      await handle.done;
      if (savedBytes != handle.totalBytes) {
        throw const PiSessionExportSaveException(
          PiSessionExportSaveErrorCode.integrityFailed,
        );
      }
      return PiSessionExportSaveResult.saved(fileName);
    } catch (error, stackTrace) {
      await handle.cancel();
      if (writable != null) {
        await writable.abort().toDart.catchError((Object _) => null);
      }
      if (_isBrowserPickerCancellation(error)) {
        return PiSessionExportSaveResult.cancelled(fileName);
      }
      if (error is PiSessionExportSaveException || error is PiNodeException) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      Error.throwWithStackTrace(
        const PiSessionExportSaveException(
          PiSessionExportSaveErrorCode.unsupported,
        ),
        stackTrace,
      );
    }
  }
}

bool _isBrowserPickerCancellation(Object error) =>
    error.toString().contains('AbortError');
