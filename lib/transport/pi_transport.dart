import 'dart:typed_data';

/// A defensively copied binary protocol frame.
///
/// Frame contents are never included in diagnostics because they may contain
/// prompts, messages, paths, credentials, or tool output.
final class PiTransportFrame {
  PiTransportFrame(Uint8List bytes) : _bytes = _validatedBytes(bytes);

  final Uint8List _bytes;

  Uint8List get bytes => Uint8List.fromList(_bytes);

  int get length => _bytes.length;

  @override
  String toString() => 'PiTransportFrame(length: $length, data: <redacted>)';
}

enum PiTransportErrorCode {
  invalidFrame,
  invalidFraming,
  unsupported,
  processStartFailed,
  processExited,
  writeFailed,
  closed,
}

final class PiTransportException implements Exception {
  const PiTransportException(this.code);

  final PiTransportErrorCode code;

  @override
  String toString() => 'PiTransportException(code: ${code.name}, <redacted>)';
}

/// One already-established ordered, duplex, binary connection.
///
/// Implementations must preserve frame order, complete [done] only after
/// [incoming] has ended, reject sends after termination, and make [close]
/// idempotent. Protocol negotiation belongs above this raw boundary.
abstract interface class PiTransport {
  Stream<PiTransportFrame> get incoming;

  Future<void> get done;

  Future<void> send(PiTransportFrame frame);

  Future<void> close();
}

Uint8List _validatedBytes(Uint8List value) {
  if (value.isEmpty) {
    throw const PiTransportException(PiTransportErrorCode.invalidFrame);
  }
  return Uint8List.fromList(value);
}
