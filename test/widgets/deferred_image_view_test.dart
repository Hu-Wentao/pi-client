import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/widgets/deferred_image/deferred_image.dart';

import '../components/support/component_test_support.dart';
import '../fixtures/output_renderer_fixtures.dart';
import '../support/fake_pi_node_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeferredImageController formats and integrity', () {
    testWidgets('accepts verified PNG, JPEG, WebP, and GIF content', (
      tester,
    ) async {
      final formats = <String, (Uint8List, DeferredImageFormat)>{
        'image/png': (fixturePng(), DeferredImageFormat.png),
        'image/jpeg': (fixtureJpeg(), DeferredImageFormat.jpeg),
        'image/webp': (fixtureWebp(), DeferredImageFormat.webp),
        'image/gif': (fixtureGif(), DeferredImageFormat.gif),
      };

      for (final entry in formats.entries) {
        final api = FakePiNodeApi();
        final request = imageRequest(
          entry.value.$1,
          mimeType: entry.key,
          identity: entry.value.$2.name,
        );
        api.messageContentHandler = (received) async => FakeContentHandle(
          request: received,
          chunks: <Uint8List>[entry.value.$1],
        );
        final controller = DeferredImageController(api: api);
        addTearDown(controller.dispose);

        final lease = await controller.load(request).result;
        expect(lease.data.format, entry.value.$2, reason: entry.key);
        expect(lease.data.width, 1, reason: entry.key);
        expect(lease.data.height, 1, reason: entry.key);
        expect(lease.data.frameCount, greaterThanOrEqualTo(1));
        await lease.release();
        await controller.dispose();
      }
    });

    testWidgets('uses private native temporary backing above threshold', (
      tester,
    ) async {
      final bytes = fixturePng();
      final api = FakePiNodeApi();
      final request = imageRequest(bytes, mimeType: 'image/png');
      api.messageContentHandler = (received) async =>
          FakeContentHandle(request: received, chunks: <Uint8List>[bytes]);
      final controller = DeferredImageController(
        api: api,
        limits: const DeferredImageLimits(nativeMemoryThresholdBytes: 1),
      );

      await tester.runAsync(() async {
        final lease = await controller.load(request).result;
        expect(
          lease.data.storageKind,
          DeferredImageStorageKind.nativeTemporaryFile,
        );
        expect(controller.cachedMemoryBytes, 0);
        await lease.release();
        await controller.dispose();
      });
    });

    testWidgets('bounds the in-memory LRU cache', (tester) async {
      final api = FakePiNodeApi();
      api.messageContentHandler = (request) async {
        final bytes = request.reference.contentId.endsWith('one')
            ? fixturePng()
            : fixtureGif();
        return FakeContentHandle(request: request, chunks: <Uint8List>[bytes]);
      };
      final controller = DeferredImageController(
        api: api,
        limits: const DeferredImageLimits(
          maxCacheEntries: 1,
          maxCacheMemoryBytes: 1024,
          nativeMemoryThresholdBytes: 1024,
        ),
      );
      final first = await controller
          .load(
            imageRequest(fixturePng(), mimeType: 'image/png', identity: 'one'),
          )
          .result;
      await first.release();
      final second = await controller
          .load(
            imageRequest(fixtureGif(), mimeType: 'image/gif', identity: 'two'),
          )
          .result;
      await second.release();

      expect(controller.cachedEntries, 1);
      expect(controller.cachedMemoryBytes, lessThanOrEqualTo(1024));
      await controller.dispose();
    });

    testWidgets('rejects digest tampering and length mismatch', (tester) async {
      final bytes = fixturePng();
      final tampered = Uint8List.fromList(bytes)..[bytes.length - 1] ^= 0xff;
      final api = FakePiNodeApi();
      final digestRequest = imageRequest(bytes, mimeType: 'image/png');
      api.messageContentHandler = (request) async =>
          FakeContentHandle(request: request, chunks: <Uint8List>[tampered]);
      final controller = DeferredImageController(api: api);

      await expectLater(
        controller.load(digestRequest).result,
        throwsA(
          isA<DeferredImageException>().having(
            (error) => error.code,
            'code',
            DeferredImageFailureCode.digestMismatch,
          ),
        ),
      );

      final shortRequest = imageRequest(
        bytes,
        mimeType: 'image/png',
        totalBytes: bytes.length + 1,
      );
      api.messageContentHandler = (request) async =>
          FakeContentHandle(request: request, chunks: <Uint8List>[bytes]);
      await expectLater(
        controller.load(shortRequest).result,
        throwsA(
          isA<DeferredImageException>().having(
            (error) => error.code,
            'code',
            DeferredImageFailureCode.lengthMismatch,
          ),
        ),
      );
      await controller.dispose();
    });

    testWidgets('rejects MIME mismatch without rendering SVG bytes', (
      tester,
    ) async {
      final bytes = fixturePng();
      final api = FakePiNodeApi();
      final mismatch = imageRequest(bytes, mimeType: 'image/jpeg');
      api.messageContentHandler = (request) async =>
          FakeContentHandle(request: request, chunks: <Uint8List>[bytes]);
      final controller = DeferredImageController(api: api);

      await expectLater(
        controller.load(mismatch).result,
        throwsA(
          isA<DeferredImageException>().having(
            (error) => error.code,
            'code',
            DeferredImageFailureCode.mimeMismatch,
          ),
        ),
      );

      final svg = Uint8List.fromList(utf8.encode('<svg><script/></svg>'));
      final svgRequest = imageRequest(svg, mimeType: 'image/svg+xml');
      await expectLater(
        controller.load(svgRequest).result,
        throwsA(
          isA<DeferredImageException>().having(
            (error) => error.code,
            'code',
            DeferredImageFailureCode.unsupportedMime,
          ),
        ),
      );
      expect(api.messageContentCalls, 1);
      await controller.dispose();
    });

    testWidgets('rejects compressed, dimension, pixel, and animation bombs', (
      tester,
    ) async {
      final api = FakePiNodeApi();
      final controller = DeferredImageController(api: api);
      final small = fixturePng();
      expect(
        () => controller.load(
          imageRequest(
            small,
            mimeType: 'image/png',
            totalBytes: 13 * 1024 * 1024,
          ),
        ),
        throwsA(
          isA<DeferredImageException>().having(
            (error) => error.code,
            'code',
            DeferredImageFailureCode.compressedLimit,
          ),
        ),
      );
      expect(api.messageContentCalls, 0);

      Future<void> expectRejected(
        Uint8List bytes,
        DeferredImageFailureCode code, {
        String mimeType = 'image/png',
        DeferredImageLimits limits = const DeferredImageLimits(),
        String identity = 'bomb',
      }) async {
        final request = imageRequest(
          bytes,
          mimeType: mimeType,
          identity: identity,
        );
        api.messageContentHandler = (received) async =>
            FakeContentHandle(request: received, chunks: <Uint8List>[bytes]);
        final boundedController = DeferredImageController(
          api: api,
          limits: limits,
        );
        await expectLater(
          boundedController.load(request).result,
          throwsA(
            isA<DeferredImageException>().having(
              (error) => error.code,
              'code',
              code,
            ),
          ),
        );
        await boundedController.dispose();
      }

      await expectRejected(
        pngHeaderWithDimensions(9000, 1),
        DeferredImageFailureCode.invalidDimensions,
        identity: 'dimension',
      );
      await expectRejected(
        pngHeaderWithDimensions(7000, 7000),
        DeferredImageFailureCode.pixelLimit,
        identity: 'pixels',
      );
      await expectRejected(
        fixtureAnimatedGif(),
        DeferredImageFailureCode.animationLimit,
        mimeType: 'image/gif',
        limits: const DeferredImageLimits(maxAnimationFrames: 1),
        identity: 'animation',
      );
      await controller.dispose();
    });
  });

  group('Deferred image cancellation', () {
    testWidgets('cancelSession cancels the active MESSAGE_CONTENT transfer', (
      tester,
    ) async {
      final bytes = fixturePng();
      final gate = Completer<void>();
      late FakeContentHandle handle;
      final api = FakePiNodeApi();
      final request = imageRequest(bytes, mimeType: 'image/png');
      api.messageContentHandler = (received) async {
        handle = FakeContentHandle(
          request: received,
          chunks: <Uint8List>[bytes],
          gate: gate,
        );
        return handle;
      };
      final controller = DeferredImageController(api: api);
      final load = controller.load(request);
      await tester.pump();

      await controller.cancelSession(request.binding.sessionId);
      expect(handle.cancelled, isTrue);
      await expectLater(
        load.result,
        throwsA(
          isA<DeferredImageException>().having(
            (error) => error.code,
            'code',
            DeferredImageFailureCode.cancelled,
          ),
        ),
      );
      await controller.dispose();
    });

    testWidgets('cancelStaleRevision cancels an older part revision', (
      tester,
    ) async {
      final bytes = fixturePng();
      final gate = Completer<void>();
      late FakeContentHandle handle;
      final api = FakePiNodeApi();
      final oldRequest = imageRequest(
        bytes,
        mimeType: 'image/png',
        entryRevision: 1,
        partRevision: 1,
      );
      api.messageContentHandler = (received) async {
        handle = FakeContentHandle(
          request: received,
          chunks: <Uint8List>[bytes],
          gate: gate,
        );
        return handle;
      };
      final controller = DeferredImageController(api: api);
      final load = controller.load(oldRequest);
      await tester.pump();
      final current = PiMessageContentBinding(
        sessionId: oldRequest.binding.sessionId,
        entryId: oldRequest.binding.entryId,
        partId: oldRequest.binding.partId,
        entryRevision: 2,
        partRevision: 2,
        contentId: 'content-current',
      );

      await controller.cancelStaleRevision(current);
      expect(handle.cancelled, isTrue);
      await expectLater(
        load.result,
        throwsA(
          isA<DeferredImageException>().having(
            (error) => error.code,
            'code',
            DeferredImageFailureCode.cancelled,
          ),
        ),
      );
      await controller.dispose();
    });

    testWidgets('view disposal cancels its active transfer', (tester) async {
      final bytes = fixturePng();
      final gate = Completer<void>();
      late FakeContentHandle handle;
      final api = FakePiNodeApi();
      final request = imageRequest(bytes, mimeType: 'image/png');
      api.messageContentHandler = (received) async {
        handle = FakeContentHandle(
          request: received,
          chunks: <Uint8List>[bytes],
          gate: gate,
        );
        return handle;
      };
      final controller = DeferredImageController(api: api);

      await tester.pumpWidget(
        componentTestApp(
          DeferredImageView(
            controller: controller,
            projectId: request.projectId,
            binding: request.binding,
            reference: request.reference,
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('deferredImageLoading')), findsOneWidget);

      await tester.pumpWidget(componentTestApp(const SizedBox()));
      await tester.pump();
      expect(handle.cancelled, isTrue);
      await controller.dispose();
    });
  });

  group('DeferredImageView accessibility', () {
    testWidgets('renders verified image semantics at 200% scale', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.binding.setSurfaceSize(const Size(320, 300));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final bytes = fixturePng();
      final request = imageRequest(
        bytes,
        mimeType: 'image/png',
        displayName: '/not/a/readable/path.png',
      );
      final api = FakePiNodeApi();
      api.messageContentHandler = (received) async =>
          FakeContentHandle(request: received, chunks: <Uint8List>[bytes]);
      final controller = DeferredImageController(api: api);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: componentTestApp(
            DeferredImageView(
              controller: controller,
              projectId: request.projectId,
              binding: request.binding,
              reference: request.reference,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          RegExp(r'Image: /not/a/readable/path\.png, 1 by 1 pixels'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await controller.dispose();
      semantics.dispose();
    });

    testWidgets('SVG uses a non-rendering fallback without transfer', (
      tester,
    ) async {
      final svg = Uint8List.fromList(utf8.encode('<svg/>'));
      final request = imageRequest(svg, mimeType: 'image/svg+xml');
      final api = FakePiNodeApi();
      final controller = DeferredImageController(api: api);

      await tester.pumpWidget(
        componentTestApp(
          DeferredImageView(
            controller: controller,
            projectId: request.projectId,
            binding: request.binding,
            reference: request.reference,
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('SVG preview is disabled'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(api.messageContentCalls, 0);
      await controller.dispose();
    });

    testWidgets('retry action is keyboard reachable', (tester) async {
      final bytes = fixturePng();
      final tampered = Uint8List.fromList(bytes)..[bytes.length - 1] ^= 0xff;
      final request = imageRequest(bytes, mimeType: 'image/png');
      final api = FakePiNodeApi();
      var calls = 0;
      api.messageContentHandler = (received) async {
        calls += 1;
        return FakeContentHandle(
          request: received,
          chunks: <Uint8List>[calls == 1 ? tampered : bytes],
        );
      };
      final controller = DeferredImageController(api: api);

      await tester.pumpWidget(
        componentTestApp(
          DeferredImageView(
            controller: controller,
            projectId: request.projectId,
            binding: request.binding,
            reference: request.reference,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('deferredImageRetryButton')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.byKey(const Key('deferredImageLoaded')), findsOneWidget);
      await controller.dispose();
    });
  });
}

PiMessageContentRequest imageRequest(
  Uint8List bytes, {
  required String mimeType,
  String identity = 'image',
  String displayName = 'preview',
  int entryRevision = 1,
  int partRevision = 1,
  int? totalBytes,
  Uint8List? digest,
}) {
  final contentId = 'content-$identity';
  return PiMessageContentRequest(
    projectId: PiProjectId('project-output-renderer'),
    binding: PiMessageContentBinding(
      sessionId: PiSessionId('session-output-renderer'),
      entryId: 'entry-output-renderer',
      partId: 'part-output-renderer',
      entryRevision: entryRevision,
      partRevision: partRevision,
      contentId: contentId,
    ),
    reference: PiMessageContentReference(
      contentId: contentId,
      mimeType: mimeType,
      displayName: displayName,
      totalBytes: totalBytes ?? bytes.length,
      sha256: digest ?? Uint8List.fromList(sha256.convert(bytes).bytes),
    ),
  );
}

final class FakeContentHandle implements PiMessageContentHandle {
  FakeContentHandle({
    required this.request,
    required Iterable<Uint8List> chunks,
    this.gate,
  }) : chunks = List<Uint8List>.unmodifiable(chunks);

  final PiMessageContentRequest request;
  final List<Uint8List> chunks;
  final Completer<void>? gate;
  final Completer<void> _done = Completer<void>();
  bool cancelled = false;

  @override
  PiMessageContentBinding get binding => request.binding;

  @override
  PiMessageContentReference get reference => request.reference;

  @override
  Stream<Uint8List> get bytes async* {
    final currentGate = gate;
    if (currentGate != null) await currentGate.future;
    if (cancelled) {
      if (!_done.isCompleted) _done.complete();
      return;
    }
    for (final chunk in chunks) {
      if (cancelled) break;
      yield Uint8List.fromList(chunk);
    }
    if (!_done.isCompleted) _done.complete();
  }

  @override
  Future<void> get done => _done.future;

  @override
  Future<void> cancel() async {
    cancelled = true;
    final currentGate = gate;
    if (currentGate != null && !currentGate.isCompleted) currentGate.complete();
    if (!_done.isCompleted) _done.complete();
  }
}
