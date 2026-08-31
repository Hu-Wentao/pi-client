import 'dart:typed_data';

import 'package:flutter/material.dart';

enum DeferredImageStorageKind { memory, nativeTemporaryFile }

final class DeferredImageBackingStore {
  const DeferredImageBackingStore();

  Future<DeferredImageBacking> store(
    Uint8List bytes, {
    required String cacheKey,
    required int memoryThresholdBytes,
  }) async => DeferredImageBacking._memory(Uint8List.fromList(bytes));
}

final class DeferredImageBacking {
  DeferredImageBacking._memory(Uint8List bytes)
    : _bytes = bytes,
      length = bytes.length,
      memoryBytes = bytes.length,
      storageKind = DeferredImageStorageKind.memory;

  final Uint8List _bytes;
  final int length;
  final int memoryBytes;
  final DeferredImageStorageKind storageKind;

  Widget buildImage({
    required BoxFit fit,
    required String semanticLabel,
    required ImageErrorWidgetBuilder errorBuilder,
  }) => Image.memory(
    _bytes,
    fit: fit,
    semanticLabel: semanticLabel,
    gaplessPlayback: true,
    filterQuality: FilterQuality.medium,
    errorBuilder: errorBuilder,
  );

  Future<void> dispose() async {}
}
