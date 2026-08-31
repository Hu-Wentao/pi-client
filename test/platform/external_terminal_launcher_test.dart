import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/platform/external_terminal/external_terminal_launcher.dart';
import 'package:pi_client/platform/external_terminal/external_terminal_launcher_io.dart';
import 'package:pi_client/platform/platform_capabilities.dart';

void main() {
  test('macOS launch uses exact argv without shell interpolation', () async {
    final adapter = _RecordingProcessAdapter(
      <ExternalTerminalProcessStartStatus>[
        ExternalTerminalProcessStartStatus.started,
      ],
    );
    final launcher = DesktopExternalTerminalLauncher(
      platform: ExternalTerminalDesktopPlatform.macos,
      processAdapter: adapter,
    );
    final identity = _identity(r'/Projects/Space & [safe]; $(ignored)');

    final result = await launcher.openTrustedProject(identity);

    expect(result.status, ExternalTerminalLaunchStatus.success);
    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.executable, '/usr/bin/open');
    expect(adapter.requests.single.arguments, <String>[
      '-a',
      'Terminal',
      identity.canonicalWorkingDirectory,
    ]);
    expect(adapter.requests.single.workingDirectory, isNull);
    expect(
      adapter.requests.single.toString(),
      isNot(contains(identity.canonicalWorkingDirectory)),
    );
  });

  test(
    'Windows Terminal receives canonical cwd as a separate argument',
    () async {
      final adapter = _RecordingProcessAdapter(
        <ExternalTerminalProcessStartStatus>[
          ExternalTerminalProcessStartStatus.started,
        ],
      );
      final launcher = DesktopExternalTerminalLauncher(
        platform: ExternalTerminalDesktopPlatform.windows,
        processAdapter: adapter,
      );
      final identity = _identity(r'C:\Projects\Space & [safe]; $(ignored)');

      final result = await launcher.openTrustedProject(identity);

      expect(result.status, ExternalTerminalLaunchStatus.success);
      expect(adapter.requests.single.executable, 'wt.exe');
      expect(adapter.requests.single.arguments, <String>[
        '-d',
        identity.canonicalWorkingDirectory,
      ]);
      expect(adapter.requests.single.workingDirectory, isNull);
    },
  );

  test(
    'Windows fallback opens cmd at cwd without a command argument',
    () async {
      final adapter =
          _RecordingProcessAdapter(<ExternalTerminalProcessStartStatus>[
            ExternalTerminalProcessStartStatus.notFound,
            ExternalTerminalProcessStartStatus.started,
          ]);
      final launcher = DesktopExternalTerminalLauncher(
        platform: ExternalTerminalDesktopPlatform.windows,
        processAdapter: adapter,
      );
      final identity = _identity(r'C:\Projects\fallback path');

      final result = await launcher.openTrustedProject(identity);

      expect(result.status, ExternalTerminalLaunchStatus.success);
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests.last.executable, 'cmd.exe');
      expect(adapter.requests.last.arguments, isEmpty);
      expect(
        adapter.requests.last.workingDirectory,
        identity.canonicalWorkingDirectory,
      );
    },
  );

  test('Windows does not hide a launch failure behind the fallback', () async {
    final adapter = _RecordingProcessAdapter(
      <ExternalTerminalProcessStartStatus>[
        ExternalTerminalProcessStartStatus.failed,
      ],
    );
    final launcher = DesktopExternalTerminalLauncher(
      platform: ExternalTerminalDesktopPlatform.windows,
      processAdapter: adapter,
    );

    final result = await launcher.openTrustedProject(
      _identity(r'C:\Projects\private'),
    );

    expect(result.status, ExternalTerminalLaunchStatus.failure);
    expect(adapter.requests, hasLength(1));
    expect(result.toString(), contains('details: <redacted>'));
    expect(result.toString(), isNot(contains('private')));
  });

  test(
    'Linux tries only the bounded terminal allowlist with exact cwd argv',
    () async {
      final adapter =
          _RecordingProcessAdapter(<ExternalTerminalProcessStartStatus>[
            ExternalTerminalProcessStartStatus.notFound,
            ExternalTerminalProcessStartStatus.started,
          ]);
      final launcher = DesktopExternalTerminalLauncher(
        platform: ExternalTerminalDesktopPlatform.linux,
        processAdapter: adapter,
      );
      final identity = _identity(r'/Projects/canonical target; $(ignored)');

      final result = await launcher.openTrustedProject(identity);

      expect(result.status, ExternalTerminalLaunchStatus.success);
      expect(adapter.requests.map((request) => request.executable), <String>[
        'kgx',
        'gnome-terminal',
      ]);
      expect(adapter.requests.last.arguments, <String>[
        '--working-directory',
        identity.canonicalWorkingDirectory,
      ]);
      expect(
        adapter.requests.every(
          (request) =>
              request.executable != 'sh' && request.executable != 'bash',
        ),
        isTrue,
      );
    },
  );

  test(
    'Linux reports unsupported when no allowlisted terminal exists',
    () async {
      final adapter = _RecordingProcessAdapter(
        List<ExternalTerminalProcessStartStatus>.filled(
          7,
          ExternalTerminalProcessStartStatus.notFound,
        ),
      );
      final launcher = DesktopExternalTerminalLauncher(
        platform: ExternalTerminalDesktopPlatform.linux,
        processAdapter: adapter,
      );

      final result = await launcher.openTrustedProject(
        _identity('/Projects/canonical'),
      );

      expect(result.status, ExternalTerminalLaunchStatus.unsupported);
      expect(result.code, ExternalTerminalLaunchCode.terminalUnavailable);
      expect(adapter.requests, hasLength(7));
    },
  );

  test(
    'connect-only factories return unsupported without process invocation',
    () async {
      final capabilities = <PlatformCapabilities>[
        PlatformCapabilities.resolve(
          isWeb: false,
          targetPlatform: TargetPlatform.android,
        ),
        PlatformCapabilities.resolve(
          isWeb: false,
          targetPlatform: TargetPlatform.iOS,
        ),
        PlatformCapabilities.resolve(
          isWeb: true,
          targetPlatform: TargetPlatform.macOS,
        ),
      ];

      for (final capability in capabilities) {
        final launcher = createPlatformExternalTerminalLauncher(
          capabilities: capability,
        );
        expect(launcher.isPlatformSupported, isFalse);
        final result = await launcher.openTrustedProject(
          _identity('/Projects/canonical'),
        );
        expect(result.status, ExternalTerminalLaunchStatus.unsupported);
        expect(result.code, ExternalTerminalLaunchCode.unsupportedPlatform);
      }
    },
  );

  test(
    'real process adapter launches a fake terminal executable with exact argv',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'pi-client-external-terminal ',
      );
      addTearDown(() => root.delete(recursive: true));
      final project = Directory('${root.path}/project & [safe]')..createSync();
      final output = File('${root.path}/launch output.txt');
      final executable = File('${root.path}/fake terminal');
      await executable.writeAsString(r'''#!/bin/sh
printf "%s\n%s\n" "$PWD" "$1" > "$2"
''');
      final chmod = await Process.run('/bin/chmod', <String>[
        '+x',
        executable.path,
      ]);
      expect(chmod.exitCode, 0);

      const adapter = DartIoExternalTerminalProcessAdapter();
      final status = await adapter.start(
        ExternalTerminalProcessRequest(
          executable: executable.path,
          arguments: <String>[project.path, output.path],
          workingDirectory: project.path,
        ),
      );
      expect(status, ExternalTerminalProcessStartStatus.started);

      await _waitUntil(output.existsSync);
      final lines = await output.readAsLines();
      expect(lines, hasLength(2));
      expect(lines[0], await project.resolveSymbolicLinks());
      expect(lines[1], project.path);
    },
    skip: Platform.isWindows
        ? 'The fake POSIX terminal smoke is owned by macOS/Linux runners.'
        : false,
  );
}

PiProjectIdentity _identity(String canonicalWorkingDirectory) =>
    PiProjectIdentity(
      projectId: PiProjectId('project-id'),
      canonicalWorkingDirectory: canonicalWorkingDirectory,
      isGitRepository: false,
      isLinkedWorktree: false,
      isDetachedHead: false,
      worktreeId: PiWorktreeId('worktree-id'),
      mainProjectId: PiMainProjectId('main-project-id'),
    );

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Fake terminal process did not complete.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

final class _RecordingProcessAdapter implements ExternalTerminalProcessAdapter {
  _RecordingProcessAdapter(Iterable<ExternalTerminalProcessStartStatus> results)
    : _results = Queue<ExternalTerminalProcessStartStatus>.of(results);

  final Queue<ExternalTerminalProcessStartStatus> _results;
  final List<ExternalTerminalProcessRequest> requests =
      <ExternalTerminalProcessRequest>[];

  @override
  Future<ExternalTerminalProcessStartStatus> start(
    ExternalTerminalProcessRequest request,
  ) async {
    requests.add(request);
    return _results.removeFirst();
  }
}
