import 'dart:typed_data';

import 'limits.dart';

const _prefixBytes = 4;

final class IpcFrameException implements Exception {
  IpcFrameException(this.message);

  final String message;

  @override
  String toString() => 'IpcFrameException: $message';
}

Uint8List encodeIpcLengthPrefixedFrame(
  List<int> payload, {
  int maximumFrameBytes = maxFrameBytes,
}) {
  _validatePayloadLength(payload.length, maximumFrameBytes);
  final framed = Uint8List(_prefixBytes + payload.length);
  ByteData.sublistView(framed).setUint32(0, payload.length, Endian.big);
  framed.setRange(_prefixBytes, framed.length, payload);
  return framed;
}

/// Incrementally removes a four-byte big-endian length prefix from stream IPC.
/// The prefix is transport framing only and is not part of PiTransportFrame.
final class IpcLengthPrefixDecoder {
  IpcLengthPrefixDecoder({this.maximumFrameBytes = maxFrameBytes}) {
    if (maximumFrameBytes <= 0) {
      throw IpcFrameException('maximumFrameBytes must be positive');
    }
  }

  final int maximumFrameBytes;
  Uint8List _pending = Uint8List(0);

  List<Uint8List> push(List<int> chunk) {
    if (chunk.isEmpty) {
      return const [];
    }

    final combined = Uint8List(_pending.length + chunk.length)
      ..setRange(0, _pending.length, _pending)
      ..setRange(_pending.length, _pending.length + chunk.length, chunk);

    final frames = <Uint8List>[];
    var offset = 0;
    while (combined.length - offset >= _prefixBytes) {
      final length = ByteData.sublistView(
        combined,
        offset,
        offset + _prefixBytes,
      ).getUint32(0, Endian.big);
      _validatePayloadLength(length, maximumFrameBytes);
      final frameEnd = offset + _prefixBytes + length;
      if (combined.length < frameEnd) {
        break;
      }
      frames.add(
        Uint8List.sublistView(combined, offset + _prefixBytes, frameEnd),
      );
      offset = frameEnd;
    }

    _pending = Uint8List.fromList(combined.sublist(offset));
    return frames;
  }

  void finish() {
    if (_pending.isNotEmpty) {
      throw IpcFrameException(
        'truncated IPC frame: ${_pending.length} trailing byte(s)',
      );
    }
  }
}

void _validatePayloadLength(int length, int maximumFrameBytes) {
  if (length <= 0) {
    throw IpcFrameException('IPC frames must contain at least one byte');
  }
  if (length > maximumFrameBytes) {
    throw IpcFrameException(
      'IPC frame length $length exceeds maximum $maximumFrameBytes',
    );
  }
}
