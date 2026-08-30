import 'dart:typed_data';

final class PiProtocolVersion {
  factory PiProtocolVersion(int major, int minor, int patch) {
    if (major < 0) {
      throw ArgumentError.value(major, 'major', 'Must not be negative.');
    }
    if (minor < 0) {
      throw ArgumentError.value(minor, 'minor', 'Must not be negative.');
    }
    if (patch < 0) {
      throw ArgumentError.value(patch, 'patch', 'Must not be negative.');
    }
    return PiProtocolVersion._(major, minor, patch);
  }

  const PiProtocolVersion._(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  @override
  bool operator ==(Object other) =>
      other is PiProtocolVersion &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

final class PiTransportFrame {
  PiTransportFrame(Uint8List bytes) : _bytes = Uint8List.fromList(bytes);

  final Uint8List _bytes;

  Uint8List get bytes => Uint8List.fromList(_bytes);

  int get length => _bytes.length;

  @override
  String toString() => 'PiTransportFrame(length: $length, data: <redacted>)';
}

abstract interface class PiTransport {
  Future<PiTransportConnection> connect({
    required PiProtocolVersion protocolVersion,
  });
}

abstract interface class PiTransportConnection {
  PiProtocolVersion get negotiatedVersion;

  Stream<PiTransportFrame> get incomingFrames;

  Future<void> send(PiTransportFrame frame);

  Future<void> close();
}
