import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';

import 'deferred_image_backing.dart';

export 'deferred_image_backing.dart' show DeferredImageStorageKind;

/// State Ownership: none
/// Capabilities:
/// - Fetch typed message image content only through [PiNodeApi] MESSAGE_CONTENT
///   transfers; no path, URI, or arbitrary file-read input is accepted.
/// - Verify compressed length, SHA-256, MIME signature, dimensions, pixels,
///   animation frames, and decoder acceptance before display.
/// - Bound cached memory with LRU eviction and use private temporary backing for
///   larger native images.
/// Public Widgets:
/// - [DeferredImageView] — deferred safe image presentation.
/// Public Controllers:
/// - [DeferredImageController] — bounded transfer, verification, cache, and
///   cancellation owner.
enum DeferredImageFormat { png, jpeg, webp, gif, svg }

enum DeferredImageFailureCode {
  unsupportedMime,
  compressedLimit,
  lengthMismatch,
  digestMismatch,
  mimeMismatch,
  invalidDimensions,
  pixelLimit,
  animationLimit,
  decodeFailed,
  transferFailed,
  cancelled,
  disposed,
  resourceExhausted,
}

final class DeferredImageException implements Exception {
  const DeferredImageException(this.code, this.safeMessage);

  final DeferredImageFailureCode code;
  final String safeMessage;

  @override
  String toString() => 'DeferredImageException($code, $safeMessage)';
}

final class DeferredImageLimits {
  const DeferredImageLimits({
    this.maxCompressedBytes = 12 * 1024 * 1024,
    this.maxWidth = 8192,
    this.maxHeight = 8192,
    this.maxPixels = 40 * 1024 * 1024,
    this.maxAnimationFrames = 120,
    this.maxAnimationPixelFrames = 240 * 1024 * 1024,
    this.nativeMemoryThresholdBytes = 1024 * 1024,
    this.maxCacheMemoryBytes = 24 * 1024 * 1024,
    this.maxCacheEntries = 12,
    this.maxConcurrentTransfers = 4,
  });

  final int maxCompressedBytes;
  final int maxWidth;
  final int maxHeight;
  final int maxPixels;
  final int maxAnimationFrames;
  final int maxAnimationPixelFrames;
  final int nativeMemoryThresholdBytes;
  final int maxCacheMemoryBytes;
  final int maxCacheEntries;
  final int maxConcurrentTransfers;

  void validate() {
    final values = <int>[
      maxCompressedBytes,
      maxWidth,
      maxHeight,
      maxPixels,
      maxAnimationFrames,
      maxAnimationPixelFrames,
      nativeMemoryThresholdBytes,
      maxCacheMemoryBytes,
      maxCacheEntries,
      maxConcurrentTransfers,
    ];
    if (values.any((value) => value <= 0)) {
      throw StateError('Deferred image limits must be positive.');
    }
  }
}

final class DeferredImageData {
  DeferredImageData._({
    required this.format,
    required this.width,
    required this.height,
    required this.frameCount,
    required this.compressedBytes,
    required DeferredImageBacking backing,
  }) : _backing = backing;

  final DeferredImageFormat format;
  final int width;
  final int height;
  final int frameCount;
  final int compressedBytes;
  final DeferredImageBacking _backing;

  DeferredImageStorageKind get storageKind => _backing.storageKind;
}

final class DeferredImageLease {
  DeferredImageLease._(this.data, this._release);

  final DeferredImageData data;
  final Future<void> Function() _release;
  bool _released = false;

  Future<void> release() async {
    if (_released) return;
    _released = true;
    await _release();
  }
}

final class DeferredImageLoad {
  DeferredImageLoad._(this.result, this._cancel);

  final Future<DeferredImageLease> result;
  final Future<void> Function() _cancel;

  Future<void> cancel() => _cancel();
}

final class DeferredImageController {
  DeferredImageController({
    required this.api,
    this.limits = const DeferredImageLimits(),
  }) {
    limits.validate();
  }

  final PiNodeApi api;
  final DeferredImageLimits limits;
  final DeferredImageBackingStore _backingStore =
      const DeferredImageBackingStore();
  final LinkedHashMap<String, _CacheEntry> _cache =
      LinkedHashMap<String, _CacheEntry>();
  final Set<_DeferredImageOperation> _operations = <_DeferredImageOperation>{};
  var _cacheMemoryBytes = 0;
  var _disposed = false;

  int get cachedEntries => _cache.length;
  int get cachedMemoryBytes => _cacheMemoryBytes;
  int get activeTransfers => _operations.length;

  DeferredImageLoad load(PiMessageContentRequest request) {
    if (_disposed) {
      return DeferredImageLoad._(
        Future<DeferredImageLease>.error(
          const DeferredImageException(
            DeferredImageFailureCode.disposed,
            'The image controller is closed.',
          ),
        ),
        () async {},
      );
    }
    _validateReference(request.reference);
    final format = _formatForMime(request.reference.mimeType);
    if (format == null || format == DeferredImageFormat.svg) {
      return DeferredImageLoad._(
        Future<DeferredImageLease>.error(
          const DeferredImageException(
            DeferredImageFailureCode.unsupportedMime,
            'This image format is not rendered.',
          ),
        ),
        () async {},
      );
    }

    final key = _cacheKey(request);
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      cached.references += 1;
      return DeferredImageLoad._(
        Future<DeferredImageLease>.value(_lease(cached)),
        () async {},
      );
    }
    if (_operations.length >= limits.maxConcurrentTransfers) {
      return DeferredImageLoad._(
        Future<DeferredImageLease>.error(
          const DeferredImageException(
            DeferredImageFailureCode.resourceExhausted,
            'Too many images are loading. Try again shortly.',
          ),
        ),
        () async {},
      );
    }

    final operation = _DeferredImageOperation(
      controller: this,
      request: request,
      cacheKey: key,
      expectedFormat: format,
    );
    _operations.add(operation);
    operation.start();
    return DeferredImageLoad._(operation.result, operation.cancel);
  }

  Future<void> cancelSession(PiSessionId sessionId) async {
    final operations = _operations
        .where((operation) => operation.request.binding.sessionId == sessionId)
        .toList(growable: false);
    await Future.wait<void>(operations.map((operation) => operation.cancel()));
    final keys = _cache.entries
        .where((entry) => entry.value.sessionId == sessionId)
        .map((entry) => entry.key)
        .toList(growable: false);
    for (final key in keys) {
      await _evict(key);
    }
  }

  Future<void> cancelStaleRevision(PiMessageContentBinding current) async {
    bool samePart(PiMessageContentBinding binding) =>
        binding.sessionId == current.sessionId &&
        binding.entryId == current.entryId &&
        binding.partId == current.partId;
    bool exact(PiMessageContentBinding binding) =>
        samePart(binding) &&
        binding.entryRevision == current.entryRevision &&
        binding.partRevision == current.partRevision &&
        binding.contentId == current.contentId;

    final operations = _operations
        .where(
          (operation) =>
              samePart(operation.request.binding) &&
              !exact(operation.request.binding),
        )
        .toList(growable: false);
    await Future.wait<void>(operations.map((operation) => operation.cancel()));
    final keys = _cache.entries
        .where(
          (entry) =>
              samePart(entry.value.binding) && !exact(entry.value.binding),
        )
        .map((entry) => entry.key)
        .toList(growable: false);
    for (final key in keys) {
      await _evict(key);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final operations = _operations.toList(growable: false);
    await Future.wait<void>(operations.map((operation) => operation.cancel()));
    final entries = _cache.values.toList(growable: false);
    _cache.clear();
    _cacheMemoryBytes = 0;
    for (final entry in entries) {
      entry.evicted = true;
      if (entry.references == 0) await entry.data._backing.dispose();
    }
  }

  Future<DeferredImageLease> _perform(_DeferredImageOperation operation) async {
    PiMessageContentHandle? handle;
    DeferredImageBacking? backing;
    try {
      handle = await api.getMessageContent(operation.request);
      operation.handle = handle;
      if (operation.cancelled) {
        await _cancelHandle(handle);
        throw const DeferredImageException(
          DeferredImageFailureCode.cancelled,
          'Image loading was cancelled.',
        );
      }
      _validateHandle(handle, operation.request);

      final builder = BytesBuilder(copy: false);
      var received = 0;
      await for (final chunk in handle.bytes) {
        if (operation.cancelled) {
          await _cancelHandle(handle);
          throw const DeferredImageException(
            DeferredImageFailureCode.cancelled,
            'Image loading was cancelled.',
          );
        }
        received += chunk.length;
        if (received > operation.request.reference.totalBytes ||
            received > limits.maxCompressedBytes) {
          await _cancelHandle(handle);
          throw const DeferredImageException(
            DeferredImageFailureCode.compressedLimit,
            'The image exceeds the compressed-size limit.',
          );
        }
        builder.add(chunk);
      }
      await handle.done;
      if (operation.cancelled) {
        throw const DeferredImageException(
          DeferredImageFailureCode.cancelled,
          'Image loading was cancelled.',
        );
      }
      final bytes = builder.takeBytes();
      if (bytes.length != operation.request.reference.totalBytes) {
        throw const DeferredImageException(
          DeferredImageFailureCode.lengthMismatch,
          'The image length does not match its reference.',
        );
      }
      final digest = sha256.convert(bytes).bytes;
      if (!_sameBytes(digest, operation.request.reference.sha256)) {
        throw const DeferredImageException(
          DeferredImageFailureCode.digestMismatch,
          'The image failed integrity verification.',
        );
      }

      final descriptor = _sniffImage(bytes);
      if (descriptor == null || descriptor.format != operation.expectedFormat) {
        throw const DeferredImageException(
          DeferredImageFailureCode.mimeMismatch,
          'The image bytes do not match the declared MIME type.',
        );
      }
      _validateDimensions(descriptor);
      final frameCount = await _decodeFrameCount(bytes);
      if (frameCount > limits.maxAnimationFrames ||
          descriptor.pixels * frameCount > limits.maxAnimationPixelFrames) {
        throw const DeferredImageException(
          DeferredImageFailureCode.animationLimit,
          'The animated image exceeds the frame safety limit.',
        );
      }
      if (operation.cancelled) {
        throw const DeferredImageException(
          DeferredImageFailureCode.cancelled,
          'Image loading was cancelled.',
        );
      }

      backing = await _backingStore.store(
        bytes,
        cacheKey: operation.cacheKey,
        memoryThresholdBytes: limits.nativeMemoryThresholdBytes,
      );
      if (operation.cancelled || _disposed) {
        await backing.dispose();
        backing = null;
        throw DeferredImageException(
          operation.cancelled
              ? DeferredImageFailureCode.cancelled
              : DeferredImageFailureCode.disposed,
          operation.cancelled
              ? 'Image loading was cancelled.'
              : 'The image controller is closed.',
        );
      }

      final existing = _cache.remove(operation.cacheKey);
      if (existing != null) {
        _cache[operation.cacheKey] = existing;
        existing.references += 1;
        await backing.dispose();
        backing = null;
        return _lease(existing);
      }

      final data = DeferredImageData._(
        format: descriptor.format,
        width: descriptor.width,
        height: descriptor.height,
        frameCount: frameCount,
        compressedBytes: bytes.length,
        backing: backing,
      );
      backing = null;
      final entry = _CacheEntry(
        key: operation.cacheKey,
        data: data,
        binding: operation.request.binding,
        references: 1,
      );
      _cache[entry.key] = entry;
      _cacheMemoryBytes += data._backing.memoryBytes;
      await _trimCache();
      return _lease(entry);
    } on DeferredImageException {
      rethrow;
    } on PiNodeException catch (error) {
      if (error.code == PiNodeErrorCode.cancelled || operation.cancelled) {
        throw const DeferredImageException(
          DeferredImageFailureCode.cancelled,
          'Image loading was cancelled.',
        );
      }
      throw const DeferredImageException(
        DeferredImageFailureCode.transferFailed,
        'The image could not be transferred from Pi Node.',
      );
    } catch (_) {
      if (operation.cancelled) {
        throw const DeferredImageException(
          DeferredImageFailureCode.cancelled,
          'Image loading was cancelled.',
        );
      }
      throw const DeferredImageException(
        DeferredImageFailureCode.transferFailed,
        'The image could not be loaded safely.',
      );
    } finally {
      if (backing != null) await backing.dispose();
      _operations.remove(operation);
    }
  }

  void _validateReference(PiMessageContentReference reference) {
    if (reference.totalBytes > limits.maxCompressedBytes) {
      throw const DeferredImageException(
        DeferredImageFailureCode.compressedLimit,
        'The image exceeds the compressed-size limit.',
      );
    }
  }

  void _validateHandle(
    PiMessageContentHandle handle,
    PiMessageContentRequest request,
  ) {
    final binding = handle.binding;
    final reference = handle.reference;
    if (!_sameBinding(binding, request.binding) ||
        reference.contentId != request.reference.contentId ||
        reference.mimeType != request.reference.mimeType ||
        reference.totalBytes != request.reference.totalBytes ||
        !_sameBytes(reference.sha256, request.reference.sha256)) {
      throw const DeferredImageException(
        DeferredImageFailureCode.transferFailed,
        'Pi Node returned content for a different message revision.',
      );
    }
  }

  void _validateDimensions(_ImageDescriptor descriptor) {
    if (descriptor.width <= 0 || descriptor.height <= 0) {
      throw const DeferredImageException(
        DeferredImageFailureCode.invalidDimensions,
        'The image dimensions are invalid.',
      );
    }
    if (descriptor.width > limits.maxWidth ||
        descriptor.height > limits.maxHeight) {
      throw const DeferredImageException(
        DeferredImageFailureCode.invalidDimensions,
        'The image dimensions exceed the safety limit.',
      );
    }
    if (descriptor.pixels > limits.maxPixels) {
      throw const DeferredImageException(
        DeferredImageFailureCode.pixelLimit,
        'The image pixel count exceeds the safety limit.',
      );
    }
  }

  Future<int> _decodeFrameCount(Uint8List bytes) async {
    ui.Codec? codec;
    try {
      codec = await ui.instantiateImageCodec(bytes, allowUpscaling: false);
      return codec.frameCount;
    } catch (_) {
      throw const DeferredImageException(
        DeferredImageFailureCode.decodeFailed,
        'The image decoder rejected this content.',
      );
    } finally {
      codec?.dispose();
    }
  }

  DeferredImageLease _lease(_CacheEntry entry) =>
      DeferredImageLease._(entry.data, () async {
        if (entry.references > 0) entry.references -= 1;
        if (entry.evicted && entry.references == 0) {
          await entry.data._backing.dispose();
        }
      });

  Future<void> _trimCache() async {
    while (_cache.length > limits.maxCacheEntries ||
        _cacheMemoryBytes > limits.maxCacheMemoryBytes) {
      if (_cache.isEmpty) break;
      await _evict(_cache.keys.first);
    }
  }

  Future<void> _evict(String key) async {
    final entry = _cache.remove(key);
    if (entry == null) return;
    entry.evicted = true;
    _cacheMemoryBytes -= entry.data._backing.memoryBytes;
    if (entry.references == 0) await entry.data._backing.dispose();
  }
}

class DeferredImageView extends StatefulWidget {
  const DeferredImageView({
    required this.controller,
    required this.projectId,
    required this.binding,
    required this.reference,
    this.fit = BoxFit.contain,
    this.maxWidth = 900,
    this.maxHeight = 640,
    super.key,
  });

  final DeferredImageController controller;
  final PiProjectId projectId;
  final PiMessageContentBinding binding;
  final PiMessageContentReference reference;
  final BoxFit fit;
  final double maxWidth;
  final double maxHeight;

  @override
  State<DeferredImageView> createState() => _DeferredImageViewState();
}

class _DeferredImageViewState extends State<DeferredImageView> {
  DeferredImageLoad? _load;
  DeferredImageLease? _lease;
  DeferredImageException? _error;
  var _loading = false;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant DeferredImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.projectId != widget.projectId ||
        !_sameBinding(oldWidget.binding, widget.binding) ||
        !_sameReference(oldWidget.reference, widget.reference)) {
      _start();
    }
  }

  @override
  void dispose() {
    _generation += 1;
    final load = _load;
    final lease = _lease;
    _load = null;
    _lease = null;
    if (load != null) unawaited(load.cancel());
    if (lease != null) unawaited(lease.release());
    super.dispose();
  }

  Future<void> _start() async {
    final generation = ++_generation;
    final previousLoad = _load;
    final previousLease = _lease;
    _load = null;
    _lease = null;
    if (previousLoad != null) await previousLoad.cancel();
    if (previousLease != null) await previousLease.release();
    if (!mounted || generation != _generation) return;

    final format = _formatForMime(widget.reference.mimeType);
    if (format == null || format == DeferredImageFormat.svg) {
      setState(() {
        _loading = false;
        _error = const DeferredImageException(
          DeferredImageFailureCode.unsupportedMime,
          'This image format is not rendered.',
        );
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    DeferredImageLoad load;
    try {
      load = widget.controller.load(
        PiMessageContentRequest(
          projectId: widget.projectId,
          binding: widget.binding,
          reference: widget.reference,
        ),
      );
    } on DeferredImageException catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = false;
          _error = error;
        });
      }
      return;
    }
    _load = load;
    try {
      final lease = await load.result;
      if (!mounted || generation != _generation) {
        await lease.release();
        return;
      }
      setState(() {
        _load = null;
        _lease = lease;
        _loading = false;
        _error = null;
      });
    } on DeferredImageException catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _load = null;
        _loading = false;
        _error = error;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _load = null;
        _loading = false;
        _error = const DeferredImageException(
          DeferredImageFailureCode.transferFailed,
          'The image could not be loaded safely.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lease = _lease;
    final error = _error;
    final label = 'Image: ${widget.reference.displayName}';
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: _loading
            ? Semantics(
                key: const Key('deferredImageLoading'),
                container: true,
                liveRegion: true,
                label: 'Loading $label',
                child: const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            : lease != null
            ? Semantics(
                key: const Key('deferredImageLoaded'),
                container: true,
                image: true,
                label:
                    '$label, ${lease.data.width} by ${lease.data.height} pixels'
                    '${lease.data.frameCount > 1 ? ', animated' : ''}',
                child: ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: lease.data._backing.buildImage(
                      fit: widget.fit,
                      semanticLabel: label,
                      errorBuilder: (context, error, stackTrace) =>
                          _ImageFallback(
                            label: label,
                            message:
                                'The verified image could not be displayed.',
                            retryable: true,
                            onRetry: _start,
                          ),
                    ),
                  ),
                ),
              )
            : _ImageFallback(
                key: const Key('deferredImageFallback'),
                label: label,
                message: error?.code == DeferredImageFailureCode.unsupportedMime
                    ? _unsupportedMessage(widget.reference.mimeType)
                    : error?.safeMessage ?? 'The image is unavailable.',
                retryable:
                    error?.code != DeferredImageFailureCode.unsupportedMime,
                onRetry: _start,
              ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({
    required this.label,
    required this.message,
    required this.retryable,
    required this.onRetry,
    super.key,
  });

  final String label;
  final String message;
  final bool retryable;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: '$label. $message',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.image_not_supported_outlined),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Text(message),
            ),
            if (retryable)
              FilledButton.tonalIcon(
                key: const Key('deferredImageRetryButton'),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry image'),
              ),
          ],
        ),
      ),
    ),
  );
}

final class _DeferredImageOperation {
  _DeferredImageOperation({
    required this.controller,
    required this.request,
    required this.cacheKey,
    required this.expectedFormat,
  });

  final DeferredImageController controller;
  final PiMessageContentRequest request;
  final String cacheKey;
  final DeferredImageFormat expectedFormat;
  final Completer<DeferredImageLease> _result = Completer<DeferredImageLease>();
  PiMessageContentHandle? handle;
  bool cancelled = false;

  Future<DeferredImageLease> get result => _result.future;

  void start() {
    unawaited(
      controller
          ._perform(this)
          .then(
            (lease) {
              if (!_result.isCompleted) _result.complete(lease);
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!_result.isCompleted) {
                _result.completeError(error, stackTrace);
              }
            },
          ),
    );
  }

  Future<void> cancel() async {
    if (cancelled) return;
    cancelled = true;
    final currentHandle = handle;
    if (currentHandle != null) await _cancelHandle(currentHandle);
  }
}

final class _CacheEntry {
  _CacheEntry({
    required this.key,
    required this.data,
    required this.binding,
    required this.references,
  });

  final String key;
  final DeferredImageData data;
  final PiMessageContentBinding binding;
  PiSessionId get sessionId => binding.sessionId;
  int references;
  bool evicted = false;
}

final class _ImageDescriptor {
  const _ImageDescriptor({
    required this.format,
    required this.width,
    required this.height,
  });

  final DeferredImageFormat format;
  final int width;
  final int height;
  int get pixels => width * height;
}

_ImageDescriptor? _sniffImage(Uint8List bytes) {
  if (_isPng(bytes)) {
    if (bytes.length < 24 || _ascii(bytes, 12, 16) != 'IHDR') return null;
    return _ImageDescriptor(
      format: DeferredImageFormat.png,
      width: _be32(bytes, 16),
      height: _be32(bytes, 20),
    );
  }
  if (_isGif(bytes)) {
    if (bytes.length < 10) return null;
    return _ImageDescriptor(
      format: DeferredImageFormat.gif,
      width: _le16(bytes, 6),
      height: _le16(bytes, 8),
    );
  }
  if (_isWebp(bytes)) return _sniffWebp(bytes);
  if (_isJpeg(bytes)) return _sniffJpeg(bytes);
  if (_looksLikeSvg(bytes)) {
    return const _ImageDescriptor(
      format: DeferredImageFormat.svg,
      width: 1,
      height: 1,
    );
  }
  return null;
}

_ImageDescriptor? _sniffWebp(Uint8List bytes) {
  if (bytes.length < 30) return null;
  final chunk = _ascii(bytes, 12, 16);
  if (chunk == 'VP8X') {
    return _ImageDescriptor(
      format: DeferredImageFormat.webp,
      width: 1 + _le24(bytes, 24),
      height: 1 + _le24(bytes, 27),
    );
  }
  if (chunk == 'VP8L' && bytes[20] == 0x2f) {
    final b1 = bytes[21];
    final b2 = bytes[22];
    final b3 = bytes[23];
    final b4 = bytes[24];
    return _ImageDescriptor(
      format: DeferredImageFormat.webp,
      width: 1 + (((b2 & 0x3f) << 8) | b1),
      height: 1 + (((b4 & 0x0f) << 10) | (b3 << 2) | ((b2 & 0xc0) >> 6)),
    );
  }
  if (chunk == 'VP8 ' &&
      bytes[23] == 0x9d &&
      bytes[24] == 0x01 &&
      bytes[25] == 0x2a) {
    return _ImageDescriptor(
      format: DeferredImageFormat.webp,
      width: _le16(bytes, 26) & 0x3fff,
      height: _le16(bytes, 28) & 0x3fff,
    );
  }
  return null;
}

_ImageDescriptor? _sniffJpeg(Uint8List bytes) {
  var index = 2;
  while (index + 3 < bytes.length) {
    if (bytes[index] != 0xff) {
      index += 1;
      continue;
    }
    while (index < bytes.length && bytes[index] == 0xff) {
      index += 1;
    }
    if (index >= bytes.length) return null;
    final marker = bytes[index];
    index += 1;
    if (marker == 0xd8 || marker == 0x01) continue;
    if (marker == 0xd9 || marker == 0xda) return null;
    if (index + 1 >= bytes.length) return null;
    final length = _be16(bytes, index);
    if (length < 2 || index + length > bytes.length) return null;
    if (_jpegSofMarkers.contains(marker)) {
      if (length < 7) return null;
      return _ImageDescriptor(
        format: DeferredImageFormat.jpeg,
        width: _be16(bytes, index + 5),
        height: _be16(bytes, index + 3),
      );
    }
    index += length;
  }
  return null;
}

DeferredImageFormat? _formatForMime(String mimeType) {
  final normalized = mimeType.split(';').first.trim().toLowerCase();
  return switch (normalized) {
    'image/png' => DeferredImageFormat.png,
    'image/jpeg' || 'image/jpg' => DeferredImageFormat.jpeg,
    'image/webp' => DeferredImageFormat.webp,
    'image/gif' => DeferredImageFormat.gif,
    'image/svg+xml' => DeferredImageFormat.svg,
    _ => null,
  };
}

String _unsupportedMessage(String mimeType) {
  final format = _formatForMime(mimeType);
  if (format == DeferredImageFormat.svg) {
    return 'SVG preview is disabled for safety. Download is not available from this view.';
  }
  return 'This image MIME type is not supported.';
}

String _cacheKey(PiMessageContentRequest request) => <String>[
  request.projectId.value,
  request.binding.sessionId.value,
  request.binding.entryId,
  '${request.binding.entryRevision}',
  request.binding.partId,
  '${request.binding.partRevision}',
  request.binding.contentId,
  request.reference.contentId,
  base64UrlEncode(request.reference.sha256),
].join('|');

bool _sameBinding(
  PiMessageContentBinding left,
  PiMessageContentBinding right,
) =>
    left.sessionId == right.sessionId &&
    left.entryId == right.entryId &&
    left.partId == right.partId &&
    left.entryRevision == right.entryRevision &&
    left.partRevision == right.partRevision &&
    left.contentId == right.contentId;

bool _sameReference(
  PiMessageContentReference left,
  PiMessageContentReference right,
) =>
    left.contentId == right.contentId &&
    left.mimeType == right.mimeType &&
    left.displayName == right.displayName &&
    left.totalBytes == right.totalBytes &&
    _sameBytes(left.sha256, right.sha256);

bool _sameBytes(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  var difference = 0;
  for (var index = 0; index < left.length; index += 1) {
    difference |= left[index] ^ right[index];
  }
  return difference == 0;
}

Future<void> _cancelHandle(PiMessageContentHandle handle) async {
  try {
    await handle.cancel();
  } catch (_) {
    // Local cancellation remains authoritative after a transfer disconnect.
  }
}

bool _isPng(Uint8List bytes) =>
    bytes.length >= 8 &&
    bytes[0] == 0x89 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x4e &&
    bytes[3] == 0x47 &&
    bytes[4] == 0x0d &&
    bytes[5] == 0x0a &&
    bytes[6] == 0x1a &&
    bytes[7] == 0x0a;

bool _isGif(Uint8List bytes) =>
    bytes.length >= 6 &&
    (_ascii(bytes, 0, 6) == 'GIF87a' || _ascii(bytes, 0, 6) == 'GIF89a');

bool _isWebp(Uint8List bytes) =>
    bytes.length >= 12 &&
    _ascii(bytes, 0, 4) == 'RIFF' &&
    _ascii(bytes, 8, 12) == 'WEBP';

bool _isJpeg(Uint8List bytes) =>
    bytes.length >= 4 && bytes[0] == 0xff && bytes[1] == 0xd8;

bool _looksLikeSvg(Uint8List bytes) {
  final length = bytes.length.clamp(0, 2048);
  final prefix = utf8.decode(bytes.sublist(0, length), allowMalformed: true);
  final normalized = prefix.replaceFirst('\ufeff', '').trimLeft().toLowerCase();
  return normalized.startsWith('<svg') ||
      (normalized.startsWith('<?xml') && normalized.contains('<svg'));
}

String _ascii(Uint8List bytes, int start, int end) =>
    String.fromCharCodes(bytes.sublist(start, end));

int _be16(Uint8List bytes, int offset) =>
    (bytes[offset] << 8) | bytes[offset + 1];

int _be32(Uint8List bytes, int offset) =>
    (bytes[offset] << 24) |
    (bytes[offset + 1] << 16) |
    (bytes[offset + 2] << 8) |
    bytes[offset + 3];

int _le16(Uint8List bytes, int offset) =>
    bytes[offset] | (bytes[offset + 1] << 8);

int _le24(Uint8List bytes, int offset) =>
    bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16);

const _jpegSofMarkers = <int>{
  0xc0,
  0xc1,
  0xc2,
  0xc3,
  0xc5,
  0xc6,
  0xc7,
  0xc9,
  0xca,
  0xcb,
  0xcd,
  0xce,
  0xcf,
};
