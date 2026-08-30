import 'dart:io';

import '../platform/agent_host/pi_node_host_controller.dart';

const _definedNodeExecutable = String.fromEnvironment(
  'PI_CLIENT_NODE_EXECUTABLE',
);
const _definedNodeEntrypoint = String.fromEnvironment(
  'PI_CLIENT_NODE_ENTRYPOINT',
);
const _definedNodeCwd = String.fromEnvironment('PI_CLIENT_NODE_CWD');
const _definedAgentDir = String.fromEnvironment('PI_CODING_AGENT_DIR');

PiNodeDesktopProcessConfiguration createDefaultPiNodeProcessConfiguration() {
  final workingDirectory = _firstNonEmpty(<String?>[
    _definedNodeCwd,
    Platform.environment['PI_CLIENT_NODE_CWD'],
    Directory.current.absolute.path,
  ]);
  final executable = _firstNonEmpty(<String?>[
    _definedNodeExecutable,
    Platform.environment['PI_CLIENT_NODE_EXECUTABLE'],
    'node',
  ]);
  final entrypoint = _firstNonEmpty(<String?>[
    _definedNodeEntrypoint,
    Platform.environment['PI_CLIENT_NODE_ENTRYPOINT'],
    File('node/dist/stdio-main.js').absolute.path,
  ]);
  final homeDirectory = _firstNonEmpty(<String?>[
    Platform.environment['HOME'],
    Platform.environment['USERPROFILE'],
    workingDirectory,
  ]);
  final agentDirectory = _firstNonEmpty(<String?>[
    _definedAgentDir,
    Platform.environment['PI_CODING_AGENT_DIR'],
    '$homeDirectory${Platform.pathSeparator}.pi${Platform.pathSeparator}agent',
  ]);

  return PiNodeDesktopProcessConfiguration(
    nodeExecutable: executable,
    serverArguments: <String>[
      entrypoint,
      '--cwd',
      workingDirectory,
      '--agent-dir',
      agentDirectory,
    ],
    workingDirectory: workingDirectory,
    environment: const <String, String>{
      'PI_SKIP_VERSION_CHECK': '1',
      'PI_TELEMETRY': '0',
    },
    includeParentEnvironment: true,
    shutdownTimeout: const Duration(seconds: 10),
  );
}

String _firstNonEmpty(Iterable<String?> candidates) => candidates.firstWhere(
  (candidate) => candidate != null && candidate.trim().isNotEmpty,
)!;
