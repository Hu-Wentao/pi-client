final class PiProtocolVersion implements Comparable<PiProtocolVersion> {
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
  int compareTo(PiProtocolVersion other) {
    final majorComparison = major.compareTo(other.major);
    if (majorComparison != 0) return majorComparison;
    final minorComparison = minor.compareTo(other.minor);
    if (minorComparison != 0) return minorComparison;
    return patch.compareTo(other.patch);
  }

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

/// An ordered, non-empty set of protocol versions supported by the client.
///
/// Preference order is significant. Negotiation is performed by the Pi Node
/// handshake, never by a raw transport implementation.
final class PiProtocolOffer {
  factory PiProtocolOffer(Iterable<PiProtocolVersion> versions) {
    final offered = List<PiProtocolVersion>.unmodifiable(versions);
    if (offered.isEmpty) {
      throw ArgumentError('At least one protocol version must be offered.');
    }
    if (offered.toSet().length != offered.length) {
      throw ArgumentError('Protocol offers must not contain duplicates.');
    }
    return PiProtocolOffer._(offered);
  }

  const PiProtocolOffer._(this.versions);

  final List<PiProtocolVersion> versions;

  bool supports(PiProtocolVersion version) => versions.contains(version);

  @override
  bool operator ==(Object other) {
    if (other is! PiProtocolOffer || versions.length != other.versions.length) {
      return false;
    }
    for (var index = 0; index < versions.length; index += 1) {
      if (versions[index] != other.versions[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(versions);

  @override
  String toString() => 'PiProtocolOffer(${versions.join(', ')})';
}
