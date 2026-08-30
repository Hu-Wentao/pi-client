import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart' as wire;

const localDirectDefaultMaximumFrameBytes = wire.maxFrameBytes;

/// Injected process configuration for one desktop Pi Node server.
final class LocalDirectPiProcessConfiguration {
  factory LocalDirectPiProcessConfiguration({
    required String executable,
    required Iterable<String> arguments,
    String? workingDirectory,
    Map<String, String> environment = const <String, String>{},
    bool includeParentEnvironment = true,
    Duration shutdownTimeout = const Duration(seconds: 5),
    int maximumFrameBytes = localDirectDefaultMaximumFrameBytes,
  }) {
    if (executable.isEmpty || executable.contains('\u0000')) {
      throw ArgumentError('Invalid Pi Node executable.');
    }
    final copiedArguments = List<String>.unmodifiable(arguments);
    if (copiedArguments.any((argument) => argument.contains('\u0000'))) {
      throw ArgumentError('Invalid Pi Node server arguments.');
    }
    if (workingDirectory != null &&
        (workingDirectory.isEmpty || workingDirectory.contains('\u0000'))) {
      throw ArgumentError('Invalid Pi Node working directory.');
    }
    if (environment.entries.any(
      (entry) =>
          entry.key.isEmpty ||
          entry.key.contains('\u0000') ||
          entry.value.contains('\u0000'),
    )) {
      throw ArgumentError('Invalid Pi Node process environment.');
    }
    if (shutdownTimeout <= Duration.zero) {
      throw ArgumentError('shutdownTimeout must be positive.');
    }
    if (maximumFrameBytes <= 0 || maximumFrameBytes > wire.maxFrameBytes) {
      throw ArgumentError('maximumFrameBytes is outside the protocol limit.');
    }

    return LocalDirectPiProcessConfiguration._(
      executable: executable,
      arguments: copiedArguments,
      workingDirectory: workingDirectory,
      environment: Map<String, String>.unmodifiable(environment),
      includeParentEnvironment: includeParentEnvironment,
      shutdownTimeout: shutdownTimeout,
      maximumFrameBytes: maximumFrameBytes,
    );
  }

  const LocalDirectPiProcessConfiguration._({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
    required this.environment,
    required this.includeParentEnvironment,
    required this.shutdownTimeout,
    required this.maximumFrameBytes,
  });

  final String executable;
  final List<String> arguments;
  final String? workingDirectory;
  final Map<String, String> environment;
  final bool includeParentEnvironment;
  final Duration shutdownTimeout;
  final int maximumFrameBytes;

  @override
  String toString() =>
      'LocalDirectPiProcessConfiguration(<process details redacted>)';
}
