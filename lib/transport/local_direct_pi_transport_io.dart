import 'dart:async';
import 'dart:io';

import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart' as wire;

import 'local_direct_pi_transport_config.dart';
import 'pi_transport.dart';

/// Desktop Local Direct transport backed by one injected Pi Node process.
///
/// Stdout is exclusively a binary frame channel. Stderr is drained and
/// discarded without decoding or logging its potentially sensitive content.
final class LocalDirectPiTransport implements PiTransport {
  LocalDirectPiTransport._(this._process, this._configuration) {
    _startDrainingProcess();
  }

  static Future<LocalDirectPiTransport> start(
    LocalDirectPiProcessConfiguration configuration,
  ) async {
    if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
      throw const PiTransportException(PiTransportErrorCode.unsupported);
    }

    late final Process process;
    try {
      process = await Process.start(
        configuration.executable,
        configuration.arguments,
        workingDirectory: configuration.workingDirectory,
        environment: configuration.environment,
        includeParentEnvironment: configuration.includeParentEnvironment,
        runInShell: false,
      );
    } catch (_) {
      throw const PiTransportException(PiTransportErrorCode.processStartFailed);
    }
    return LocalDirectPiTransport._(process, configuration);
  }

  final Process _process;
  final LocalDirectPiProcessConfiguration _configuration;
  final StreamController<PiTransportFrame> _incomingController =
      StreamController<PiTransportFrame>.broadcast(sync: true);
  final Completer<void> _doneCompleter = Completer<void>();
  final Completer<void> _stdoutDone = Completer<void>();
  final Completer<void> _stderrDone = Completer<void>();
  late final wire.IpcLengthPrefixDecoder _decoder;
  late final StreamSubscription<List<int>> _stdoutSubscription;
  late final StreamSubscription<List<int>> _stderrSubscription;
  Future<void> _writeTail = Future<void>.value();
  Future<void>? _closeFuture;
  PiTransportException? _streamFailure;
  var _streamFailureDelivered = false;
  var _closeRequested = false;
  var _processExited = false;

  @override
  Stream<PiTransportFrame> get incoming => _incomingController.stream;

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<void> send(PiTransportFrame frame) {
    if (_closeRequested) {
      return Future<void>.error(
        const PiTransportException(PiTransportErrorCode.closed),
      );
    }
    if (_processExited) {
      return Future<void>.error(
        const PiTransportException(PiTransportErrorCode.processExited),
      );
    }

    final operation = _writeTail.then<void>((_) => _writeFrame(frame));
    _writeTail = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  @override
  Future<void> close() => _closeFuture ??= _close();

  void _startDrainingProcess() {
    unawaited(_doneCompleter.future.catchError((Object _) {}));
    _decoder = wire.IpcLengthPrefixDecoder(
      maximumFrameBytes: _configuration.maximumFrameBytes,
    );
    _stdoutSubscription = _process.stdout.listen(
      _handleStdoutData,
      onError: (Object _, StackTrace _) {
        _recordStreamFailure(PiTransportErrorCode.processExited);
        _process.kill();
      },
      onDone: _handleStdoutDone,
      cancelOnError: false,
    );
    _stderrSubscription = _process.stderr.listen(
      (List<int> _) {
        // Deliberately discard stderr bytes. They may contain prompts, paths,
        // provider output, or credentials and must never enter application
        // logging from this transport boundary.
      },
      onError: (Object _, StackTrace _) {
        if (!_stderrDone.isCompleted) _stderrDone.complete();
      },
      onDone: () {
        if (!_stderrDone.isCompleted) _stderrDone.complete();
      },
      cancelOnError: false,
    );
    unawaited(_watchProcessExit());
  }

  void _handleStdoutData(List<int> chunk) {
    if (_streamFailure != null) return;
    try {
      for (final payload in _decoder.push(chunk)) {
        _incomingController.add(PiTransportFrame(payload));
      }
    } catch (_) {
      _recordStreamFailure(PiTransportErrorCode.invalidFraming);
      _process.kill();
    }
  }

  void _handleStdoutDone() {
    if (_streamFailure == null) {
      try {
        _decoder.finish();
      } catch (_) {
        _recordStreamFailure(PiTransportErrorCode.invalidFraming);
      }
    }
    if (!_stdoutDone.isCompleted) _stdoutDone.complete();
  }

  void _recordStreamFailure(PiTransportErrorCode code) {
    if (_streamFailure != null) return;
    final failure = PiTransportException(code);
    _streamFailure = failure;
    _deliverStreamFailure(failure);
  }

  void _deliverStreamFailure(PiTransportException failure) {
    if (_streamFailureDelivered || _incomingController.isClosed) return;
    _streamFailureDelivered = true;
    _incomingController.addError(failure);
  }

  Future<void> _writeFrame(PiTransportFrame frame) async {
    if (_processExited) {
      throw const PiTransportException(PiTransportErrorCode.processExited);
    }

    late final List<int> encoded;
    try {
      encoded = wire.encodeIpcLengthPrefixedFrame(
        frame.bytes,
        maximumFrameBytes: _configuration.maximumFrameBytes,
      );
    } catch (_) {
      throw const PiTransportException(PiTransportErrorCode.invalidFrame);
    }

    try {
      _process.stdin.add(encoded);
      await _process.stdin.flush();
    } catch (_) {
      _recordStreamFailure(PiTransportErrorCode.writeFailed);
      _process.kill();
      throw const PiTransportException(PiTransportErrorCode.writeFailed);
    }
  }

  Future<void> _watchProcessExit() async {
    await _process.exitCode;
    _processExited = true;
    await Future.wait<void>(<Future<void>>[
      _stdoutDone.future,
      _stderrDone.future,
    ]);

    final failure =
        _streamFailure ??
        (_closeRequested
            ? null
            : const PiTransportException(PiTransportErrorCode.processExited));
    if (failure != null) _deliverStreamFailure(failure);

    await _incomingController.close();
    if (_doneCompleter.isCompleted) return;
    if (failure == null) {
      _doneCompleter.complete();
    } else {
      _doneCompleter.completeError(failure);
    }
  }

  Future<void> _close() async {
    _closeRequested = true;
    await _writeTail;

    try {
      await _process.stdin.close();
    } catch (_) {
      // The process may already have closed its input after exiting.
    }

    try {
      await _process.exitCode.timeout(_configuration.shutdownTimeout);
    } on TimeoutException {
      _process.kill();
      await _process.exitCode;
    }

    try {
      await done;
    } catch (_) {
      // Close is idempotent and never exposes already-recorded process details.
    }
    await _stdoutSubscription.cancel();
    await _stderrSubscription.cancel();
  }
}
