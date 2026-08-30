import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/platform/agent_host/pi_node_runtime_locator_io.dart';
import 'package:pi_client/platform/agent_host/pi_node_runtime_locator_types.dart';

void main() {
  group('PlatformPiNodeRuntimeLocator', () {
    test('resolves and verifies the bundled immutable capsule', () async {
      if (!Platform.isMacOS) return;
      final fixture = await _CapsuleFixture.create();
      addTearDown(fixture.dispose);

      final configuration = await PlatformPiNodeRuntimeLocator(
        bundledCapsuleDirectory: fixture.capsule,
        expectedSourceCommit: fixture.sourceCommit,
        expectedTargetId: fixture.targetId,
        homeDirectory: fixture.home.path,
        agentDirectory: fixture.agent.path,
        parentEnvironment: const <String, String>{'PATH': '/system/bin'},
      ).locate();
      final process = configuration.transportConfiguration;

      expect(process.executable, '${fixture.capsule.path}/runtime/bin/node');
      expect(process.arguments, <String>[
        ..._runtimeArgumentsForCurrentArchitecture(),
        '${fixture.capsule.path}/app/dist/stdio-main.js',
        '--cwd',
        fixture.home.path,
        '--agent-dir',
        fixture.agent.path,
      ]);
      expect(process.workingDirectory, fixture.home.path);
      expect(
        process.environment['PATH'],
        '${fixture.capsule.path}/runtime/bin:/system/bin',
      );
      expect(process.includeParentEnvironment, isTrue);
      expect(configuration.toString(), isNot(contains(fixture.capsule.path)));
    });

    test(
      'accepts a Universal Capsule for the current macOS architecture',
      () async {
        if (!Platform.isMacOS) return;
        final fixture = await _CapsuleFixture.create(universal: true);
        addTearDown(fixture.dispose);

        final configuration = await PlatformPiNodeRuntimeLocator(
          bundledCapsuleDirectory: fixture.capsule,
          expectedSourceCommit: fixture.sourceCommit,
          expectedTargetId: _currentTargetId(),
          homeDirectory: fixture.home.path,
          agentDirectory: fixture.agent.path,
        ).locate();

        expect(
          configuration.transportConfiguration.executable,
          '${fixture.capsule.path}/runtime/bin/node',
        );
      },
    );

    test('fails closed when the bundled capsule is missing', () async {
      if (!Platform.isMacOS) return;
      final root = await Directory.systemTemp.createTemp(
        'pi-node-runtime-missing-',
      );
      addTearDown(() => root.delete(recursive: true));

      await expectLater(
        PlatformPiNodeRuntimeLocator(
          bundledCapsuleDirectory: Directory('${root.path}/missing'),
          expectedTargetId: _currentTargetId(),
          homeDirectory: root.path,
        ).locate(),
        throwsA(
          isA<PiNodeRuntimeLocationException>().having(
            (error) => error.code,
            'code',
            PiNodeRuntimeLocationErrorCode.bundledCapsuleMissing,
          ),
        ),
      );
    });

    test('rejects payload tampering before returning process inputs', () async {
      if (!Platform.isMacOS) return;
      final fixture = await _CapsuleFixture.create();
      addTearDown(fixture.dispose);
      await File(
        '${fixture.capsule.path}/app/dist/stdio-main.js',
      ).writeAsString('tampered\n');

      await expectLater(
        fixture.locator().locate(),
        throwsA(
          isA<PiNodeRuntimeLocationException>().having(
            (error) => error.code,
            'code',
            PiNodeRuntimeLocationErrorCode.integrityMismatch,
          ),
        ),
      );
    });

    test('rejects a capsule built from another source commit', () async {
      if (!Platform.isMacOS) return;
      final fixture = await _CapsuleFixture.create();
      addTearDown(fixture.dispose);

      await expectLater(
        fixture.locator(expectedSourceCommit: 'b' * 40).locate(),
        throwsA(
          isA<PiNodeRuntimeLocationException>().having(
            (error) => error.code,
            'code',
            PiNodeRuntimeLocationErrorCode.incompatibleCapsule,
          ),
        ),
      );
    });

    test(
      'uses only a complete explicitly opted-in development fallback',
      () async {
        if (!Platform.isMacOS) return;
        final root = await Directory.systemTemp.createTemp(
          'pi-node-runtime-development-',
        );
        addTearDown(() => root.delete(recursive: true));
        final node = File('${root.path}/node')..writeAsStringSync('node\n');
        await Process.run('chmod', <String>['755', node.path]);
        final entrypoint = File('${root.path}/stdio-main.js')
          ..writeAsStringSync('entrypoint\n');
        final workingDirectory = Directory('${root.path}/project')
          ..createSync();
        final agentDirectory = Directory('${root.path}/agent')..createSync();

        final configuration = await PlatformPiNodeRuntimeLocator(
          bundledCapsuleDirectory: Directory('${root.path}/missing'),
          expectedTargetId: _currentTargetId(),
          homeDirectory: root.path,
          allowDevelopmentFallback: true,
          developmentFallback: PiNodeDevelopmentRuntimeConfiguration(
            nodeExecutable: node.path,
            entrypoint: entrypoint.path,
            workingDirectory: workingDirectory.path,
            agentDirectory: agentDirectory.path,
          ),
        ).locate();

        expect(configuration.transportConfiguration.executable, node.path);
        expect(configuration.transportConfiguration.arguments, <String>[
          entrypoint.path,
          '--cwd',
          workingDirectory.path,
          '--agent-dir',
          agentDirectory.path,
        ]);
      },
    );

    test(
      'never masks an installed capsule integrity failure with fallback',
      () async {
        if (!Platform.isMacOS) return;
        final fixture = await _CapsuleFixture.create();
        addTearDown(fixture.dispose);
        final node = File('${fixture.root.path}/development-node')
          ..writeAsStringSync('node\n');
        await Process.run('chmod', <String>['755', node.path]);
        await File(
          '${fixture.capsule.path}/app/dist/stdio-main.js',
        ).writeAsString('tampered\n');

        await expectLater(
          PlatformPiNodeRuntimeLocator(
            bundledCapsuleDirectory: fixture.capsule,
            expectedTargetId: fixture.targetId,
            homeDirectory: fixture.home.path,
            allowDevelopmentFallback: true,
            developmentFallback: PiNodeDevelopmentRuntimeConfiguration(
              nodeExecutable: node.path,
              entrypoint: '${fixture.root.path}/missing-entrypoint',
              workingDirectory: fixture.home.path,
              agentDirectory: fixture.agent.path,
            ),
          ).locate(),
          throwsA(
            isA<PiNodeRuntimeLocationException>().having(
              (error) => error.code,
              'code',
              PiNodeRuntimeLocationErrorCode.integrityMismatch,
            ),
          ),
        );
      },
    );
  });
}

final class _CapsuleFixture {
  const _CapsuleFixture({
    required this.root,
    required this.capsule,
    required this.home,
    required this.agent,
    required this.sourceCommit,
    required this.targetId,
  });

  static Future<_CapsuleFixture> create({bool universal = false}) async {
    final root = await Directory.systemTemp.createTemp('pi-node-runtime-');
    final capsule = Directory('${root.path}/PiNode')..createSync();
    final home = Directory('${root.path}/home')..createSync();
    final agent = Directory('${root.path}/agent')..createSync();
    final sourceCommit = 'a' * 40;
    final currentTargetId = _currentTargetId();
    final currentArchitecture = currentTargetId == 'darwin-arm64'
        ? 'arm64'
        : 'x64';
    final targetId = universal ? 'darwin-universal' : currentTargetId;
    final targetArchitecture = universal ? 'universal' : currentArchitecture;
    final targetArchitectures = universal
        ? const <String>['arm64', 'x64']
        : <String>[currentArchitecture];
    final files = <String, String>{
      'app/dist/stdio-main.js': 'export const server = true;\n',
      'app/package.json': jsonEncode(<String, Object>{
        'name': '@pi-client/node',
        'version': '0.1.0-dev.0',
        'dependencies': <String, String>{
          '@bufbuild/protobuf': '2.14.0',
          '@earendil-works/pi-coding-agent': '0.84.3',
          '@pi-client/protocol': '0.1.0-dev.0',
        },
      }),
      'app/node_modules/@pi-client/protocol/package.json': jsonEncode(
        <String, Object>{
          'name': '@pi-client/protocol',
          'version': '0.1.0-dev.0',
        },
      ),
      'metadata/locks/node.bun.lock': 'node-lock\n',
      'metadata/locks/protocol.bun.lock': 'protocol-lock\n',
      'metadata/schemas/capsule-manifest.schema.json': '{}\n',
      'runtime/LICENSE': 'Node license\n',
      'runtime/bin/node': 'embedded node\n',
      'runtime/lib/node_modules/npm/LICENSE': 'npm license\n',
      'runtime/lib/node_modules/npm/bin/npm-cli.js': 'npm\n',
    };
    for (final entry in files.entries) {
      final file = File('${capsule.path}/${entry.key}');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
    }
    await Process.run('chmod', <String>[
      '755',
      '${capsule.path}/runtime/bin/node',
    ]);

    final entries = <Map<String, Object>>[];
    for (final path in files.keys.toList()..sort()) {
      final file = File('${capsule.path}/$path');
      final metadata = file.statSync();
      entries.add(<String, Object>{
        'path': path,
        'type': 'file',
        'size': metadata.size,
        'sha256': (await sha256.bind(file.openRead()).first).toString(),
        'executable': (metadata.mode & 0x49) != 0,
      });
    }
    final entryByPath = <String, Map<String, Object>>{
      for (final entry in entries) entry['path']! as String: entry,
    };
    final payloadSize = entries.fold<int>(
      0,
      (total, entry) => total + (entry['size']! as int),
    );
    final manifest = <String, Object>{
      'schemaVersion': 2,
      'capsuleKind': 'pi-node-runtime',
      'sourceCommit': sourceCommit,
      'target': <String, Object>{
        'id': targetId,
        'platform': 'darwin',
        'architecture': targetArchitecture,
        'architectures': targetArchitectures,
      },
      'versions': <String, String>{
        'piNode': '0.1.0-dev.0',
        'protocol': '0.1.0-dev.0',
        'piSdk': '0.84.3',
        'protobuf': '2.14.0',
        'node': '22.19.0',
        'npm': '10.9.3',
        'bunBuilder': '1.4.0',
      },
      'locks': <Map<String, String>>[
        <String, String>{
          'name': 'node',
          'sourcePath': 'node/bun.lock',
          'capsulePath': 'metadata/locks/node.bun.lock',
          'sha256':
              entryByPath['metadata/locks/node.bun.lock']!['sha256']! as String,
        },
        <String, String>{
          'name': 'protocol',
          'sourcePath': 'protocol/bun.lock',
          'capsulePath': 'metadata/locks/protocol.bun.lock',
          'sha256':
              entryByPath['metadata/locks/protocol.bun.lock']!['sha256']!
                  as String,
        },
      ],
      'runtime': <String, Object>{
        'distributions': <Map<String, String>>[
          for (final architecture in targetArchitectures)
            <String, String>{
              'architecture': architecture,
              'archiveName': 'node-v22.19.0-darwin-$architecture.tar.gz',
              'archiveUrl':
                  'https://nodejs.org/dist/v22.19.0/node-$architecture.tar.gz',
              'checksumsUrl': 'https://nodejs.org/dist/v22.19.0/SHASUMS256.txt',
              'archiveSha256': 'b' * 64,
              'checksumsSha256': 'c' * 64,
            },
        ],
        'architectureArguments': <Map<String, Object>>[
          for (final architecture in targetArchitectures)
            <String, Object>{
              'architecture': architecture,
              'arguments': architecture == 'x64'
                  ? const <String>['--jitless']
                  : const <String>[],
            },
        ],
        'executable': 'runtime/bin/node',
        'npmCli': 'runtime/lib/node_modules/npm/bin/npm-cli.js',
        'licenses': <String>[
          'runtime/LICENSE',
          'runtime/lib/node_modules/npm/LICENSE',
        ],
      },
      'application': <String, Object>{
        'packagePath': 'app/package.json',
        'entrypoint': 'app/dist/stdio-main.js',
        'protocolPackagePath': 'app/node_modules/@pi-client/protocol',
        'launch': <String>['runtime/bin/node', 'app/dist/stdio-main.js'],
      },
      'nativeCode': <String, Object>{
        'format': 'mach-o',
        'objects': <Map<String, Object>>[
          <String, Object>{
            'path': 'runtime/bin/node',
            'kind': 'runtime-executable',
            'format': 'mach-o',
            'architectures': targetArchitectures,
          },
        ],
        'signingOrder': <String>['runtime/bin/node'],
      },
      'integrity': <String, Object>{
        'algorithm': 'sha256',
        'manifestExcludedPath': 'capsule-manifest.json',
        'payloadFileCount': entries.length,
        'payloadSize': payloadSize,
        'files': entries,
      },
    };
    File(
      '${capsule.path}/capsule-manifest.json',
    ).writeAsStringSync('${jsonEncode(manifest)}\n');
    return _CapsuleFixture(
      root: root,
      capsule: capsule,
      home: home,
      agent: agent,
      sourceCommit: sourceCommit,
      targetId: targetId,
    );
  }

  final Directory root;
  final Directory capsule;
  final Directory home;
  final Directory agent;
  final String sourceCommit;
  final String targetId;

  PlatformPiNodeRuntimeLocator locator({String? expectedSourceCommit}) =>
      PlatformPiNodeRuntimeLocator(
        bundledCapsuleDirectory: capsule,
        expectedSourceCommit: expectedSourceCommit ?? sourceCommit,
        expectedTargetId: targetId,
        homeDirectory: home.path,
        agentDirectory: agent.path,
        parentEnvironment: const <String, String>{'PATH': '/system/bin'},
      );

  Future<void> dispose() => root.delete(recursive: true);
}

List<String> _runtimeArgumentsForCurrentArchitecture() =>
    switch (Abi.current()) {
      Abi.macosX64 => const <String>['--jitless'],
      _ => const <String>[],
    };

String _currentTargetId() => switch (Abi.current()) {
  Abi.macosArm64 => 'darwin-arm64',
  Abi.macosX64 => 'darwin-x64',
  _ => throw UnsupportedError('macOS-only fixture'),
};
