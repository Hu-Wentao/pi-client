import 'dart:io';

import '../../api/pi_node/pi_node.dart';
import 'external_terminal_launcher_types.dart';

ExternalTerminalLauncher createDesktopExternalTerminalLauncher(
  ExternalTerminalDesktopPlatform platform,
) => DesktopExternalTerminalLauncher(platform: platform);

enum ExternalTerminalProcessStartStatus { started, notFound, failed }

final class ExternalTerminalProcessRequest {
  ExternalTerminalProcessRequest({
    required this.executable,
    required Iterable<String> arguments,
    this.workingDirectory,
  }) : arguments = List<String>.unmodifiable(arguments);

  final String executable;
  final List<String> arguments;
  final String? workingDirectory;

  @override
  String toString() =>
      'ExternalTerminalProcessRequest(executable: <redacted>, arguments: ${arguments.length}, workingDirectory: <redacted>)';
}

abstract interface class ExternalTerminalProcessAdapter {
  Future<ExternalTerminalProcessStartStatus> start(
    ExternalTerminalProcessRequest request,
  );
}

final class DartIoExternalTerminalProcessAdapter
    implements ExternalTerminalProcessAdapter {
  const DartIoExternalTerminalProcessAdapter();

  @override
  Future<ExternalTerminalProcessStartStatus> start(
    ExternalTerminalProcessRequest request,
  ) async {
    try {
      await Process.start(
        request.executable,
        request.arguments,
        workingDirectory: request.workingDirectory,
        runInShell: false,
        mode: ProcessStartMode.detached,
      );
      return ExternalTerminalProcessStartStatus.started;
    } on ProcessException catch (error) {
      return _isExecutableMissing(error.errorCode)
          ? ExternalTerminalProcessStartStatus.notFound
          : ExternalTerminalProcessStartStatus.failed;
    } on Object {
      return ExternalTerminalProcessStartStatus.failed;
    }
  }
}

final class DesktopExternalTerminalLauncher
    implements ExternalTerminalLauncher {
  DesktopExternalTerminalLauncher({
    required this.platform,
    ExternalTerminalProcessAdapter? processAdapter,
  }) : _processAdapter =
           processAdapter ?? const DartIoExternalTerminalProcessAdapter();

  final ExternalTerminalDesktopPlatform platform;
  final ExternalTerminalProcessAdapter _processAdapter;

  @override
  bool get isPlatformSupported => true;

  @override
  Future<ExternalTerminalLaunchResult> openTrustedProject(
    PiProjectIdentity projectIdentity,
  ) => switch (platform) {
    ExternalTerminalDesktopPlatform.macos => _openMacOs(
      projectIdentity.canonicalWorkingDirectory,
    ),
    ExternalTerminalDesktopPlatform.windows => _openWindows(
      projectIdentity.canonicalWorkingDirectory,
    ),
    ExternalTerminalDesktopPlatform.linux => _openLinux(
      projectIdentity.canonicalWorkingDirectory,
    ),
  };

  Future<ExternalTerminalLaunchResult> _openMacOs(String canonicalCwd) async {
    final status = await _processAdapter.start(
      ExternalTerminalProcessRequest(
        executable: '/usr/bin/open',
        arguments: <String>['-a', 'Terminal', canonicalCwd],
      ),
    );
    return _singleAttemptResult(status);
  }

  Future<ExternalTerminalLaunchResult> _openWindows(String canonicalCwd) async {
    final windowsTerminal = await _processAdapter.start(
      ExternalTerminalProcessRequest(
        executable: 'wt.exe',
        arguments: <String>['-d', canonicalCwd],
      ),
    );
    if (windowsTerminal == ExternalTerminalProcessStartStatus.started) {
      return const ExternalTerminalLaunchResult.success();
    }
    if (windowsTerminal == ExternalTerminalProcessStartStatus.failed) {
      return const ExternalTerminalLaunchResult.failure();
    }

    // Windows Console is the only fallback. It receives no command or shell
    // argument; Process.start sets the canonical project cwd directly.
    final platformTerminal = await _processAdapter.start(
      ExternalTerminalProcessRequest(
        executable: 'cmd.exe',
        arguments: const <String>[],
        workingDirectory: canonicalCwd,
      ),
    );
    return _singleAttemptResult(platformTerminal);
  }

  Future<ExternalTerminalLaunchResult> _openLinux(String canonicalCwd) async {
    for (final candidate in _linuxTerminalCandidates) {
      final status = await _processAdapter.start(
        ExternalTerminalProcessRequest(
          executable: candidate.executable,
          arguments: candidate.arguments(canonicalCwd),
        ),
      );
      if (status == ExternalTerminalProcessStartStatus.started) {
        return const ExternalTerminalLaunchResult.success();
      }
      if (status == ExternalTerminalProcessStartStatus.failed) {
        return const ExternalTerminalLaunchResult.failure();
      }
    }
    return const ExternalTerminalLaunchResult.terminalUnavailable();
  }
}

ExternalTerminalLaunchResult _singleAttemptResult(
  ExternalTerminalProcessStartStatus status,
) => switch (status) {
  ExternalTerminalProcessStartStatus.started =>
    const ExternalTerminalLaunchResult.success(),
  ExternalTerminalProcessStartStatus.notFound =>
    const ExternalTerminalLaunchResult.terminalUnavailable(),
  ExternalTerminalProcessStartStatus.failed =>
    const ExternalTerminalLaunchResult.failure(),
};

bool _isExecutableMissing(int errorCode) => errorCode == 2 || errorCode == 3;

final class _LinuxTerminalCandidate {
  const _LinuxTerminalCandidate(this.executable, this.arguments);

  final String executable;
  final List<String> Function(String canonicalCwd) arguments;
}

final List<_LinuxTerminalCandidate> _linuxTerminalCandidates =
    <_LinuxTerminalCandidate>[
      _LinuxTerminalCandidate(
        'kgx',
        (cwd) => <String>['--working-directory', cwd],
      ),
      _LinuxTerminalCandidate(
        'gnome-terminal',
        (cwd) => <String>['--working-directory', cwd],
      ),
      _LinuxTerminalCandidate('konsole', (cwd) => <String>['--workdir', cwd]),
      _LinuxTerminalCandidate(
        'xfce4-terminal',
        (cwd) => <String>['--working-directory', cwd],
      ),
      _LinuxTerminalCandidate(
        'mate-terminal',
        (cwd) => <String>['--working-directory', cwd],
      ),
      _LinuxTerminalCandidate('kitty', (cwd) => <String>['--directory', cwd]),
      _LinuxTerminalCandidate(
        'alacritty',
        (cwd) => <String>['--working-directory', cwd],
      ),
    ];
