import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

enum DeferredImageStorageKind { memory, nativeTemporaryFile }

final class DeferredImageBackingStore {
  const DeferredImageBackingStore();

  Future<DeferredImageBacking> store(
    Uint8List bytes, {
    required String cacheKey,
    required int memoryThresholdBytes,
  }) async {
    if (bytes.length <= memoryThresholdBytes) {
      return DeferredImageBacking._memory(Uint8List.fromList(bytes));
    }

    // Use only the OS-owned temporary root. No server-provided path, display
    // name, or token participates in filesystem selection.
    final root = Directory.systemTemp;
    final safeIdentity = sha256.convert(utf8.encode(cacheKey)).toString();
    final cacheRoot = Directory(
      '${root.path}${Platform.pathSeparator}pi-client-message-content',
    );
    await cacheRoot.create(recursive: true);
    final directory = await cacheRoot.createTemp('image-$safeIdentity-');
    final file = File('${directory.path}${Platform.pathSeparator}content.bin');
    try {
      await file.writeAsBytes(bytes, flush: true);
      return DeferredImageBacking._file(file, directory, bytes.length);
    } catch (_) {
      await _deleteDirectoryIfPresent(directory);
      rethrow;
    }
  }
}

final class DeferredImageBacking {
  DeferredImageBacking._memory(Uint8List bytes)
    : _bytes = bytes,
      _file = null,
      _directory = null,
      length = bytes.length,
      memoryBytes = bytes.length,
      storageKind = DeferredImageStorageKind.memory;

  DeferredImageBacking._file(File file, Directory directory, this.length)
    : _bytes = null,
      _file = file,
      _directory = directory,
      memoryBytes = 0,
      storageKind = DeferredImageStorageKind.nativeTemporaryFile;

  final Uint8List? _bytes;
  final File? _file;
  final Directory? _directory;
  final int length;
  final int memoryBytes;
  final DeferredImageStorageKind storageKind;
  bool _disposed = false;

  Widget buildImage({
    required BoxFit fit,
    required String semanticLabel,
    required ImageErrorWidgetBuilder errorBuilder,
  }) {
    final bytes = _bytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: fit,
        semanticLabel: semanticLabel,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: errorBuilder,
      );
    }
    return Image.file(
      _file!,
      fit: fit,
      semanticLabel: semanticLabel,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: errorBuilder,
    );
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final directory = _directory;
    if (directory != null) await _deleteDirectoryIfPresent(directory);
  }
}

Future<void> _deleteDirectoryIfPresent(Directory directory) async {
  try {
    if (await directory.exists()) await directory.delete(recursive: true);
  } catch (_) {
    // Temporary cache cleanup is best effort and never exposes the path.
  }
}
