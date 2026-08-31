import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'pi_node_host_controller.dart';
import 'pi_node_runtime_locator_types.dart';

const _manifestName = 'capsule-manifest.json';
const _expectedNodeVersion = '22.19.0';
const _expectedPiSdkVersion = '0.84.3';
const _expectedProtobufVersion = '2.14.0';
const _expectedBunBuilderVersion = '1.4.0';
const _expectedApplicationPackagePath = 'app/package.json';
const _expectedApplicationEntrypoint = 'app/dist/stdio-main.js';
const _expectedProtocolPackagePath = 'app/node_modules/@pi-client/protocol';
const _fileExecutableMask = 0x49; // POSIX 0111.

const _allowConfiguredDevelopmentFallback = bool.fromEnvironment(
  'PI_CLIENT_ALLOW_DEVELOPMENT_RUNTIME_FALLBACK',
);
const _configuredDevelopmentNodeExecutable = String.fromEnvironment(
  'PI_CLIENT_DEVELOPMENT_NODE_EXECUTABLE',
);
const _configuredDevelopmentNodeEntrypoint = String.fromEnvironment(
  'PI_CLIENT_DEVELOPMENT_NODE_ENTRYPOINT',
);
const _configuredDevelopmentWorkingDirectory = String.fromEnvironment(
  'PI_CLIENT_DEVELOPMENT_NODE_CWD',
);
const _configuredDevelopmentAgentDirectory = String.fromEnvironment(
  'PI_CLIENT_DEVELOPMENT_AGENT_DIR',
);
const _configuredCapsuleSourceCommit = String.fromEnvironment(
  'PI_CLIENT_RUNTIME_CAPSULE_SOURCE_COMMIT',
);

PiNodeRuntimeLocator createPlatformPiNodeRuntimeLocator() {
  final developmentFallback =
      _allowConfiguredDevelopmentFallback &&
          _configuredDevelopmentNodeExecutable.isNotEmpty &&
          _configuredDevelopmentNodeEntrypoint.isNotEmpty &&
          _configuredDevelopmentWorkingDirectory.isNotEmpty &&
          _configuredDevelopmentAgentDirectory.isNotEmpty
      ? const PiNodeDevelopmentRuntimeConfiguration(
          nodeExecutable: _configuredDevelopmentNodeExecutable,
          entrypoint: _configuredDevelopmentNodeEntrypoint,
          workingDirectory: _configuredDevelopmentWorkingDirectory,
          agentDirectory: _configuredDevelopmentAgentDirectory,
        )
      : null;
  return PlatformPiNodeRuntimeLocator(
    allowDevelopmentFallback:
        !kReleaseMode && _allowConfiguredDevelopmentFallback,
    developmentFallback: developmentFallback,
    expectedSourceCommit: _configuredCapsuleSourceCommit,
  );
}

/// Resolves the immutable runtime capsule installed in a desktop app bundle.
///
/// A missing capsule may fall back only in a non-release build whose caller
/// explicitly supplies complete absolute development process inputs. An
/// installed but invalid capsule always fails closed.
final class PlatformPiNodeRuntimeLocator implements PiNodeRuntimeLocator {
  PlatformPiNodeRuntimeLocator({
    Directory? bundledCapsuleDirectory,
    this.allowDevelopmentFallback = false,
    this.developmentFallback,
    String? expectedSourceCommit,
    String? expectedTargetId,
    String? homeDirectory,
    this.agentDirectory,
    Map<String, String>? parentEnvironment,
  }) : bundledCapsuleDirectory =
           bundledCapsuleDirectory ?? _defaultBundledCapsuleDirectory(),
       expectedSourceCommit = (expectedSourceCommit ?? '').trim(),
       expectedTargetId = expectedTargetId ?? _currentCapsuleTargetId(),
       homeDirectory =
           homeDirectory ??
           _firstNonEmpty(<String?>[
             Platform.environment['HOME'],
             Platform.environment['USERPROFILE'],
           ]),
       parentEnvironment = Map<String, String>.unmodifiable(
         parentEnvironment ?? Platform.environment,
       );

  final Directory bundledCapsuleDirectory;
  final bool allowDevelopmentFallback;
  final PiNodeDevelopmentRuntimeConfiguration? developmentFallback;
  final String expectedSourceCommit;
  final String expectedTargetId;
  final String homeDirectory;
  final String? agentDirectory;
  final Map<String, String> parentEnvironment;

  Future<PiNodeDesktopProcessConfiguration>? _located;

  @override
  Future<PiNodeDesktopProcessConfiguration> locate() => _located ??= _locate();

  Future<PiNodeDesktopProcessConfiguration> _locate() async {
    try {
      return await _locateBundledCapsule();
    } on PiNodeRuntimeLocationException catch (error) {
      if (error.code != PiNodeRuntimeLocationErrorCode.bundledCapsuleMissing ||
          kReleaseMode ||
          !allowDevelopmentFallback) {
        rethrow;
      }
      return _locateDevelopmentFallback();
    }
  }

  Future<PiNodeDesktopProcessConfiguration> _locateBundledCapsule() async {
    if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.unsupportedPlatform,
      );
    }
    final rootType = await FileSystemEntity.type(
      bundledCapsuleDirectory.path,
      followLinks: false,
    );
    if (rootType == FileSystemEntityType.notFound) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.bundledCapsuleMissing,
      );
    }
    if (rootType != FileSystemEntityType.directory) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.integrityMismatch,
      );
    }

    final manifest = await _readManifest(bundledCapsuleDirectory);
    _validateManifestCompatibility(manifest);
    await _verifyPayloadIntegrity(bundledCapsuleDirectory, manifest);
    await _verifyKeyPackageMetadata(bundledCapsuleDirectory, manifest);

    final executable = _resolveCapsulePath(
      bundledCapsuleDirectory,
      manifest.runtimeExecutable,
    );
    final entrypoint = _resolveCapsulePath(
      bundledCapsuleDirectory,
      manifest.applicationEntrypoint,
    );
    final runtimeBin = File(executable).parent.path;
    final runtimeArchitecture = _targetArchitecture(expectedTargetId);
    final runtimeArguments = manifest.runtimeArguments[runtimeArchitecture];
    if (runtimeArguments == null) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.incompatibleCapsule,
      );
    }
    final inheritedPath = parentEnvironment['PATH'];
    final isolatedRuntimeFirstPath =
        inheritedPath == null || inheritedPath.isEmpty
        ? runtimeBin
        : '$runtimeBin${Platform.isWindows ? ';' : ':'}$inheritedPath';
    final resolvedAgentDirectory =
        agentDirectory ??
        parentEnvironment['PI_CODING_AGENT_DIR'] ??
        '$homeDirectory${Platform.pathSeparator}.pi${Platform.pathSeparator}agent';

    return PiNodeDesktopProcessConfiguration(
      nodeExecutable: executable,
      serverArguments: <String>[
        ...runtimeArguments,
        entrypoint,
        '--cwd',
        homeDirectory,
        '--agent-dir',
        resolvedAgentDirectory,
      ],
      workingDirectory: homeDirectory,
      environment: <String, String>{
        'PATH': isolatedRuntimeFirstPath,
        'PI_SKIP_VERSION_CHECK': '1',
        'PI_TELEMETRY': '0',
      },
      includeParentEnvironment: true,
      shutdownTimeout: const Duration(seconds: 10),
    );
  }

  PiNodeDesktopProcessConfiguration _locateDevelopmentFallback() {
    final fallback = developmentFallback;
    if (fallback == null ||
        !_isAbsolute(fallback.nodeExecutable) ||
        !_isAbsolute(fallback.entrypoint) ||
        !_isAbsolute(fallback.workingDirectory) ||
        !_isAbsolute(fallback.agentDirectory)) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.developmentFallbackUnavailable,
      );
    }
    final executable = File(fallback.nodeExecutable);
    final entrypoint = File(fallback.entrypoint);
    final workingDirectory = Directory(fallback.workingDirectory);
    if (!executable.existsSync() ||
        !entrypoint.existsSync() ||
        !workingDirectory.existsSync() ||
        (!Platform.isWindows &&
            (executable.statSync().mode & _fileExecutableMask) == 0)) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.developmentFallbackUnavailable,
      );
    }
    return PiNodeDesktopProcessConfiguration(
      nodeExecutable: executable.absolute.path,
      serverArguments: <String>[
        entrypoint.absolute.path,
        '--cwd',
        workingDirectory.absolute.path,
        '--agent-dir',
        Directory(fallback.agentDirectory).absolute.path,
      ],
      workingDirectory: workingDirectory.absolute.path,
      environment: const <String, String>{
        'PI_SKIP_VERSION_CHECK': '1',
        'PI_TELEMETRY': '0',
      },
      includeParentEnvironment: true,
      shutdownTimeout: const Duration(seconds: 10),
    );
  }

  void _validateManifestCompatibility(_CapsuleManifest manifest) {
    if ((kReleaseMode && expectedSourceCommit.isEmpty) ||
        manifest.sourceCommit.length != 40 ||
        !_lowercaseHex.hasMatch(manifest.sourceCommit)) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.invalidManifest,
      );
    }
    if (expectedSourceCommit.isNotEmpty &&
        manifest.sourceCommit != expectedSourceCommit) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.incompatibleCapsule,
      );
    }
    final expectedArchitecture = _targetArchitecture(expectedTargetId);
    final targetMatches =
        manifest.targetId == expectedTargetId ||
        (Platform.isMacOS &&
            manifest.targetId == 'darwin-universal' &&
            expectedArchitecture.isNotEmpty &&
            manifest.targetArchitectures.contains(expectedArchitecture));
    if (!targetMatches ||
        manifest.targetPlatform != _currentManifestPlatform() ||
        !manifest.targetArchitectures.contains(expectedArchitecture) ||
        (manifest.targetArchitecture != expectedArchitecture &&
            manifest.targetArchitecture != 'universal')) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.incompatibleCapsule,
      );
    }
    if (manifest.nodeVersion != _expectedNodeVersion ||
        manifest.piSdkVersion != _expectedPiSdkVersion ||
        manifest.protobufVersion != _expectedProtobufVersion ||
        manifest.bunBuilderVersion != _expectedBunBuilderVersion ||
        manifest.applicationPackagePath != _expectedApplicationPackagePath ||
        manifest.applicationEntrypoint != _expectedApplicationEntrypoint ||
        manifest.protocolPackagePath != _expectedProtocolPackagePath ||
        manifest.applicationLaunch.length != 2 ||
        manifest.applicationLaunch[0] != manifest.runtimeExecutable ||
        manifest.applicationLaunch[1] != manifest.applicationEntrypoint) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.incompatibleCapsule,
      );
    }
    final executableEntry = manifest.entries[manifest.runtimeExecutable];
    final entrypointEntry = manifest.entries[manifest.applicationEntrypoint];
    if (executableEntry == null ||
        executableEntry.type != _CapsuleEntryType.file ||
        !executableEntry.executable ||
        entrypointEntry == null ||
        entrypointEntry.type != _CapsuleEntryType.file ||
        entrypointEntry.executable ||
        manifest.entries.values.any(
          (entry) =>
              entry.executable != (entry.path == manifest.runtimeExecutable),
        )) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.invalidManifest,
      );
    }
    for (final path in <String>{
      manifest.applicationPackagePath,
      '${manifest.protocolPackagePath}/package.json',
      ...manifest.lockDigests.keys,
      ...manifest.runtimeLicenses,
    }) {
      if (manifest.entries[path]?.type != _CapsuleEntryType.file) {
        throw const PiNodeRuntimeLocationException(
          PiNodeRuntimeLocationErrorCode.invalidManifest,
        );
      }
    }
  }
}

Future<_CapsuleManifest> _readManifest(Directory capsuleRoot) async {
  try {
    final manifestFile = File(
      '${capsuleRoot.path}${Platform.pathSeparator}$_manifestName',
    );
    if (await FileSystemEntity.type(manifestFile.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const FormatException('Missing capsule manifest.');
    }
    final decoded = jsonDecode(await manifestFile.readAsString());
    return _CapsuleManifest.parse(decoded);
  } on PiNodeRuntimeLocationException {
    rethrow;
  } on Object {
    throw const PiNodeRuntimeLocationException(
      PiNodeRuntimeLocationErrorCode.invalidManifest,
    );
  }
}

Future<void> _verifyPayloadIntegrity(
  Directory capsuleRoot,
  _CapsuleManifest manifest,
) async {
  try {
    final actualEntries = <String, _CapsuleEntry>{};
    await for (final entity in capsuleRoot.list(
      recursive: true,
      followLinks: false,
    )) {
      final relativePath = _relativeCapsulePath(capsuleRoot, entity.path);
      if (relativePath == _manifestName) continue;
      final type = await FileSystemEntity.type(entity.path, followLinks: false);
      if (type == FileSystemEntityType.directory) continue;
      if (type == FileSystemEntityType.file) {
        final file = File(entity.path);
        final metadata = await file.stat();
        actualEntries[relativePath] = _CapsuleEntry.file(
          path: relativePath,
          size: metadata.size,
          sha256: (await sha256.bind(file.openRead()).first).toString(),
          executable: Platform.isWindows
              ? relativePath == manifest.runtimeExecutable
              : (metadata.mode & _fileExecutableMask) != 0,
        );
        continue;
      }
      if (type == FileSystemEntityType.link) {
        final link = Link(entity.path);
        final target = await link.target();
        if (_isAbsolute(target)) {
          throw const PiNodeRuntimeLocationException(
            PiNodeRuntimeLocationErrorCode.integrityMismatch,
          );
        }
        final rootResolved = await capsuleRoot.resolveSymbolicLinks();
        final targetResolved = await link.resolveSymbolicLinks();
        if (!_isInside(rootResolved, targetResolved)) {
          throw const PiNodeRuntimeLocationException(
            PiNodeRuntimeLocationErrorCode.integrityMismatch,
          );
        }
        final targetBytes = utf8.encode(target);
        actualEntries[relativePath] = _CapsuleEntry.symlink(
          path: relativePath,
          target: target,
          size: targetBytes.length,
          sha256: sha256.convert(targetBytes).toString(),
        );
        continue;
      }
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.integrityMismatch,
      );
    }

    if (actualEntries.length != manifest.entries.length) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.integrityMismatch,
      );
    }
    var payloadSize = 0;
    for (final expected in manifest.entries.values) {
      final actual = actualEntries[expected.path];
      if (actual == null || actual != expected) {
        throw const PiNodeRuntimeLocationException(
          PiNodeRuntimeLocationErrorCode.integrityMismatch,
        );
      }
      payloadSize += actual.size;
    }
    if (payloadSize != manifest.payloadSize) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.integrityMismatch,
      );
    }
    for (final entry in manifest.lockDigests.entries) {
      if (manifest.entries[entry.key]?.sha256 != entry.value) {
        throw const PiNodeRuntimeLocationException(
          PiNodeRuntimeLocationErrorCode.integrityMismatch,
        );
      }
    }
  } on PiNodeRuntimeLocationException {
    rethrow;
  } on Object {
    throw const PiNodeRuntimeLocationException(
      PiNodeRuntimeLocationErrorCode.integrityMismatch,
    );
  }
}

Future<void> _verifyKeyPackageMetadata(
  Directory capsuleRoot,
  _CapsuleManifest manifest,
) async {
  try {
    final appPackage = _asRecord(
      jsonDecode(
        await File(
          _resolveCapsulePath(capsuleRoot, manifest.applicationPackagePath),
        ).readAsString(),
      ),
      'application package',
    );
    final protocolPackage = _asRecord(
      jsonDecode(
        await File(
          _resolveCapsulePath(
            capsuleRoot,
            '${manifest.protocolPackagePath}/package.json',
          ),
        ).readAsString(),
      ),
      'protocol package',
    );
    final appDependencies = _asRecord(
      appPackage['dependencies'],
      'application dependencies',
    );
    if (appPackage['name'] != '@pi-client/node' ||
        appPackage['version'] != manifest.piNodeVersion ||
        appDependencies['@earendil-works/pi-coding-agent'] !=
            manifest.piSdkVersion ||
        appDependencies['@bufbuild/protobuf'] != manifest.protobufVersion ||
        appDependencies['@pi-client/protocol'] != manifest.protocolVersion ||
        protocolPackage['name'] != '@pi-client/protocol' ||
        protocolPackage['version'] != manifest.protocolVersion) {
      throw const PiNodeRuntimeLocationException(
        PiNodeRuntimeLocationErrorCode.incompatibleCapsule,
      );
    }
  } on PiNodeRuntimeLocationException {
    rethrow;
  } on Object {
    throw const PiNodeRuntimeLocationException(
      PiNodeRuntimeLocationErrorCode.incompatibleCapsule,
    );
  }
}

final class _CapsuleManifest {
  const _CapsuleManifest({
    required this.sourceCommit,
    required this.targetId,
    required this.targetPlatform,
    required this.targetArchitecture,
    required this.targetArchitectures,
    required this.piNodeVersion,
    required this.protocolVersion,
    required this.piSdkVersion,
    required this.protobufVersion,
    required this.nodeVersion,
    required this.bunBuilderVersion,
    required this.applicationPackagePath,
    required this.applicationEntrypoint,
    required this.protocolPackagePath,
    required this.applicationLaunch,
    required this.runtimeExecutable,
    required this.runtimeArguments,
    required this.runtimeLicenses,
    required this.lockDigests,
    required this.payloadSize,
    required this.entries,
  });

  factory _CapsuleManifest.parse(Object? value) {
    final root = _asRecord(value, 'manifest');
    _expectExactKeys(root, const <String>{
      'schemaVersion',
      'capsuleKind',
      'sourceCommit',
      'target',
      'versions',
      'locks',
      'runtime',
      'application',
      'nativeCode',
      'integrity',
    });
    if (root['schemaVersion'] != 2 ||
        root['capsuleKind'] != 'pi-node-runtime') {
      throw const FormatException('Unsupported capsule manifest.');
    }
    final target = _asRecord(root['target'], 'target');
    _expectExactKeys(target, const <String>{
      'id',
      'platform',
      'architecture',
      'architectures',
    });
    final versions = _asRecord(root['versions'], 'versions');
    _expectExactKeys(versions, const <String>{
      'piNode',
      'protocol',
      'piSdk',
      'protobuf',
      'node',
      'npm',
      'bunBuilder',
    });
    final runtime = _asRecord(root['runtime'], 'runtime');
    _expectExactKeys(runtime, const <String>{
      'distributions',
      'architectureArguments',
      'executable',
      'npmCli',
      'licenses',
    });
    final rawTargetArchitectures = _asList(
      target['architectures'],
      'target architectures',
    );
    final targetArchitectures = rawTargetArchitectures
        .map((value) => _stringValue(value, 'target architecture'))
        .toList(growable: false);
    final targetArchitecture = _stringValue(
      target['architecture'],
      'target architecture',
    );
    final expectedArchitectures = targetArchitecture == 'universal'
        ? const <String>['arm64', 'x64']
        : <String>[targetArchitecture];
    if (targetArchitectures.isEmpty ||
        targetArchitectures.length > 2 ||
        targetArchitectures.toSet().length != targetArchitectures.length ||
        targetArchitectures.any(
          (architecture) => architecture != 'arm64' && architecture != 'x64',
        ) ||
        !_listEquals(targetArchitectures, expectedArchitectures)) {
      throw const FormatException('Invalid target architecture inventory.');
    }
    final distributions = _asList(
      runtime['distributions'],
      'runtime distributions',
    );
    if (distributions.length != targetArchitectures.length) {
      throw const FormatException('Invalid runtime distribution inventory.');
    }
    for (var index = 0; index < distributions.length; index += 1) {
      final distribution = _asRecord(
        distributions[index],
        'runtime distribution',
      );
      _expectExactKeys(distribution, const <String>{
        'architecture',
        'archiveName',
        'archiveUrl',
        'checksumsUrl',
        'archiveSha256',
        'checksumsSha256',
      });
      if (distribution['architecture'] != targetArchitectures[index]) {
        throw const FormatException('Invalid runtime distribution ordering.');
      }
      _stringValue(distribution['archiveName'], 'archive name');
      _stringValue(distribution['archiveUrl'], 'archive URL');
      _stringValue(distribution['checksumsUrl'], 'checksums URL');
      _sha256Value(distribution['archiveSha256'], 'archive digest');
      _sha256Value(distribution['checksumsSha256'], 'checksums digest');
    }
    final architectureArguments = _asList(
      runtime['architectureArguments'],
      'runtime architecture arguments',
    );
    if (architectureArguments.length != targetArchitectures.length) {
      throw const FormatException('Invalid runtime argument inventory.');
    }
    final runtimeArguments = <String, List<String>>{};
    for (var index = 0; index < architectureArguments.length; index += 1) {
      final entry = _asRecord(
        architectureArguments[index],
        'runtime architecture arguments',
      );
      _expectExactKeys(entry, const <String>{'architecture', 'arguments'});
      final architecture = _stringValue(
        entry['architecture'],
        'runtime argument architecture',
      );
      final arguments = _asList(entry['arguments'], 'runtime arguments')
          .map((value) => _stringValue(value, 'runtime argument'))
          .toList(growable: false);
      const expectedArguments = <String>[];
      if (architecture != targetArchitectures[index] ||
          !_listEquals(arguments, expectedArguments)) {
        throw const FormatException('Invalid runtime architecture arguments.');
      }
      runtimeArguments[architecture] = List<String>.unmodifiable(arguments);
    }
    final application = _asRecord(root['application'], 'application');
    _expectExactKeys(application, const <String>{
      'packagePath',
      'entrypoint',
      'protocolPackagePath',
      'launch',
    });
    final integrity = _asRecord(root['integrity'], 'integrity');
    _expectExactKeys(integrity, const <String>{
      'algorithm',
      'manifestExcludedPath',
      'payloadFileCount',
      'payloadSize',
      'files',
    });
    if (integrity['algorithm'] != 'sha256' ||
        integrity['manifestExcludedPath'] != _manifestName) {
      throw const FormatException('Unsupported capsule integrity policy.');
    }

    final rawEntries = _asList(integrity['files'], 'integrity files');
    if (integrity['payloadFileCount'] != rawEntries.length) {
      throw const FormatException('Invalid payload file count.');
    }
    final entries = <String, _CapsuleEntry>{};
    var previousPath = '';
    for (final value in rawEntries) {
      final entry = _CapsuleEntry.parse(value);
      if (entry.path == _manifestName ||
          entries.containsKey(entry.path) ||
          (previousPath.isNotEmpty &&
              previousPath.compareTo(entry.path) >= 0)) {
        throw const FormatException('Invalid capsule payload ordering.');
      }
      entries[entry.path] = entry;
      previousPath = entry.path;
    }

    final runtimeExecutable = _relativePathValue(
      runtime['executable'],
      'runtime executable',
    );
    final nativeCode = _asRecord(root['nativeCode'], 'native code');
    _expectExactKeys(nativeCode, const <String>{
      'format',
      'objects',
      'signingOrder',
    });
    if (nativeCode['format'] !=
        (target['platform'] == 'darwin' ? 'mach-o' : 'platform-native')) {
      throw const FormatException('Invalid native-code format.');
    }
    final nativeObjects = <String, _NativeCodeObject>{};
    var previousNativePath = '';
    for (final value in _asList(nativeCode['objects'], 'native objects')) {
      final object = _NativeCodeObject.parse(value);
      if (nativeObjects.containsKey(object.path) ||
          (previousNativePath.isNotEmpty &&
              previousNativePath.compareTo(object.path) >= 0)) {
        throw const FormatException('Invalid native-code object ordering.');
      }
      final payloadEntry = entries[object.path];
      if (payloadEntry == null || payloadEntry.type != _CapsuleEntryType.file) {
        throw const FormatException(
          'Native-code object is absent from payload.',
        );
      }
      if ((object.kind == 'native-addon') != object.path.endsWith('.node') ||
          (object.kind == 'runtime-executable') !=
              (object.path == runtimeExecutable)) {
        throw const FormatException('Invalid native-code classification.');
      }
      nativeObjects[object.path] = object;
      previousNativePath = object.path;
    }
    final expectedNativeObjectFormat = switch (target['platform']) {
      'darwin' => 'mach-o',
      'linux' => 'elf',
      'win32' => 'pe-coff',
      _ => '',
    };
    final runtimeObject = nativeObjects[runtimeExecutable];
    if (runtimeObject == null ||
        runtimeObject.format != expectedNativeObjectFormat ||
        !_listEquals(runtimeObject.architectures, targetArchitectures)) {
      throw const FormatException('Invalid runtime native-code inventory.');
    }
    if (nativeObjects.values.any(
      (object) =>
          object.format != expectedNativeObjectFormat ||
          object.architectures.isEmpty ||
          object.architectures.any(
            (architecture) => !targetArchitectures.contains(architecture),
          ),
    )) {
      throw const FormatException('Native-code object does not match target.');
    }
    for (final entry in entries.values) {
      if (entry.path.endsWith('.node') &&
          !nativeObjects.containsKey(entry.path)) {
        throw const FormatException('Native addon is absent from inventory.');
      }
    }
    final signingOrder = _asList(
      nativeCode['signingOrder'],
      'native signing order',
    ).map((value) => _relativePathValue(value, 'signing path')).toList();
    final expectedSigningOrder =
        nativeObjects.values
            .where((object) => object.format == 'mach-o')
            .toList()
          ..sort(_compareNativeSigningOrder);
    if (!_listEquals(
      signingOrder,
      expectedSigningOrder.map((object) => object.path).toList(),
    )) {
      throw const FormatException('Invalid native-code signing order.');
    }

    final locks = _asList(root['locks'], 'locks');
    if (locks.length != 2) {
      throw const FormatException('Invalid capsule locks.');
    }
    final lockDigests = <String, String>{};
    for (var index = 0; index < locks.length; index += 1) {
      final lock = _asRecord(locks[index], 'lock');
      _expectExactKeys(lock, const <String>{
        'name',
        'sourcePath',
        'capsulePath',
        'sha256',
      });
      final expectedName = index == 0 ? 'node' : 'protocol';
      if (lock['name'] != expectedName) {
        throw const FormatException('Invalid capsule lock ordering.');
      }
      final capsulePath = _relativePathValue(lock['capsulePath'], 'lock path');
      final digest = _sha256Value(lock['sha256'], 'lock digest');
      lockDigests[capsulePath] = digest;
    }

    final runtimeLicenses = _asList(runtime['licenses'], 'runtime licenses')
        .map((value) => _relativePathValue(value, 'runtime license'))
        .toList(growable: false);
    if (runtimeLicenses.length != 2) {
      throw const FormatException('Invalid runtime license inventory.');
    }

    return _CapsuleManifest(
      sourceCommit: _stringValue(root['sourceCommit'], 'sourceCommit'),
      targetId: _stringValue(target['id'], 'target id'),
      targetPlatform: _stringValue(target['platform'], 'target platform'),
      targetArchitecture: targetArchitecture,
      targetArchitectures: List<String>.unmodifiable(targetArchitectures),
      piNodeVersion: _stringValue(versions['piNode'], 'Pi Node version'),
      protocolVersion: _stringValue(versions['protocol'], 'protocol version'),
      piSdkVersion: _stringValue(versions['piSdk'], 'Pi SDK version'),
      protobufVersion: _stringValue(versions['protobuf'], 'protobuf version'),
      nodeVersion: _stringValue(versions['node'], 'Node version'),
      bunBuilderVersion: _stringValue(
        versions['bunBuilder'],
        'Bun builder version',
      ),
      applicationPackagePath: _relativePathValue(
        application['packagePath'],
        'application package',
      ),
      applicationEntrypoint: _relativePathValue(
        application['entrypoint'],
        'application entrypoint',
      ),
      protocolPackagePath: _relativePathValue(
        application['protocolPackagePath'],
        'protocol package',
      ),
      applicationLaunch: _asList(application['launch'], 'application launch')
          .map((value) => _relativePathValue(value, 'launch path'))
          .toList(growable: false),
      runtimeExecutable: runtimeExecutable,
      runtimeArguments: Map<String, List<String>>.unmodifiable(
        runtimeArguments,
      ),
      runtimeLicenses: runtimeLicenses,
      lockDigests: Map<String, String>.unmodifiable(lockDigests),
      payloadSize: _integerValue(integrity['payloadSize'], 'payload size'),
      entries: Map<String, _CapsuleEntry>.unmodifiable(entries),
    );
  }

  final String sourceCommit;
  final String targetId;
  final String targetPlatform;
  final String targetArchitecture;
  final List<String> targetArchitectures;
  final String piNodeVersion;
  final String protocolVersion;
  final String piSdkVersion;
  final String protobufVersion;
  final String nodeVersion;
  final String bunBuilderVersion;
  final String applicationPackagePath;
  final String applicationEntrypoint;
  final String protocolPackagePath;
  final List<String> applicationLaunch;
  final String runtimeExecutable;
  final Map<String, List<String>> runtimeArguments;
  final List<String> runtimeLicenses;
  final Map<String, String> lockDigests;
  final int payloadSize;
  final Map<String, _CapsuleEntry> entries;
}

final class _NativeCodeObject {
  const _NativeCodeObject({
    required this.path,
    required this.kind,
    required this.format,
    required this.architectures,
  });

  factory _NativeCodeObject.parse(Object? value) {
    final object = _asRecord(value, 'native-code object');
    _expectExactKeys(object, const <String>{
      'path',
      'kind',
      'format',
      'architectures',
    });
    final kind = _stringValue(object['kind'], 'native-code kind');
    final format = _stringValue(object['format'], 'native-code format');
    final architectures = _asList(
      object['architectures'],
      'native-code architectures',
    ).map((value) => _stringValue(value, 'native-code architecture')).toList();
    if (!const <String>{
          'runtime-executable',
          'native-addon',
          'dynamic-library',
          'executable',
        }.contains(kind) ||
        !const <String>{
          'elf',
          'mach-o',
          'pe-coff',
          'unknown',
        }.contains(format) ||
        architectures.toSet().length != architectures.length ||
        architectures.any(
          (architecture) => architecture != 'arm64' && architecture != 'x64',
        ) ||
        (format == 'unknown'
            ? architectures.isNotEmpty
            : architectures.isEmpty)) {
      throw const FormatException('Invalid native-code object.');
    }
    return _NativeCodeObject(
      path: _relativePathValue(object['path'], 'native-code path'),
      kind: kind,
      format: format,
      architectures: List<String>.unmodifiable(architectures),
    );
  }

  final String path;
  final String kind;
  final String format;
  final List<String> architectures;
}

int _compareNativeSigningOrder(
  _NativeCodeObject left,
  _NativeCodeObject right,
) {
  final leftRuntime = left.kind == 'runtime-executable';
  final rightRuntime = right.kind == 'runtime-executable';
  if (leftRuntime != rightRuntime) return leftRuntime ? 1 : -1;
  final depth = right.path.split('/').length - left.path.split('/').length;
  return depth != 0 ? depth : left.path.compareTo(right.path);
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

enum _CapsuleEntryType { file, symlink }

final class _CapsuleEntry {
  const _CapsuleEntry._({
    required this.path,
    required this.type,
    required this.size,
    required this.sha256,
    required this.executable,
    required this.target,
  });

  factory _CapsuleEntry.file({
    required String path,
    required int size,
    required String sha256,
    required bool executable,
  }) => _CapsuleEntry._(
    path: path,
    type: _CapsuleEntryType.file,
    size: size,
    sha256: sha256,
    executable: executable,
    target: null,
  );

  factory _CapsuleEntry.symlink({
    required String path,
    required String target,
    required int size,
    required String sha256,
  }) => _CapsuleEntry._(
    path: path,
    type: _CapsuleEntryType.symlink,
    size: size,
    sha256: sha256,
    executable: false,
    target: target,
  );

  factory _CapsuleEntry.parse(Object? value) {
    final entry = _asRecord(value, 'integrity entry');
    final type = entry['type'];
    if (type == 'file') {
      _expectExactKeys(entry, const <String>{
        'path',
        'type',
        'size',
        'sha256',
        'executable',
      });
      final executable = entry['executable'];
      if (executable is! bool) {
        throw const FormatException('Invalid executable field.');
      }
      return _CapsuleEntry.file(
        path: _relativePathValue(entry['path'], 'file path'),
        size: _integerValue(entry['size'], 'file size'),
        sha256: _sha256Value(entry['sha256'], 'file digest'),
        executable: executable,
      );
    }
    if (type == 'symlink') {
      _expectExactKeys(entry, const <String>{
        'path',
        'type',
        'target',
        'size',
        'sha256',
      });
      final target = _stringValue(entry['target'], 'symlink target');
      if (_isAbsolute(target)) {
        throw const FormatException('Absolute symlink target.');
      }
      return _CapsuleEntry.symlink(
        path: _relativePathValue(entry['path'], 'symlink path'),
        target: target,
        size: _integerValue(entry['size'], 'symlink size'),
        sha256: _sha256Value(entry['sha256'], 'symlink digest'),
      );
    }
    throw const FormatException('Unsupported capsule entry type.');
  }

  final String path;
  final _CapsuleEntryType type;
  final int size;
  final String sha256;
  final bool executable;
  final String? target;

  @override
  bool operator ==(Object other) =>
      other is _CapsuleEntry &&
      path == other.path &&
      type == other.type &&
      size == other.size &&
      sha256 == other.sha256 &&
      executable == other.executable &&
      target == other.target;

  @override
  int get hashCode => Object.hash(path, type, size, sha256, executable, target);
}

Directory _defaultBundledCapsuleDirectory() {
  final executable = File(Platform.resolvedExecutable);
  if (Platform.isMacOS) {
    final contents = executable.parent.parent;
    return Directory(
      '${contents.path}${Platform.pathSeparator}Resources${Platform.pathSeparator}PiNode',
    );
  }
  if (Platform.isWindows) {
    return Directory(
      '${executable.parent.path}${Platform.pathSeparator}PiNode',
    );
  }
  if (Platform.isLinux) {
    return Directory(
      '${executable.parent.path}${Platform.pathSeparator}lib${Platform.pathSeparator}pi-client${Platform.pathSeparator}PiNode',
    );
  }
  return Directory('');
}

String _currentCapsuleTargetId() => switch (Abi.current()) {
  Abi.macosArm64 => 'darwin-arm64',
  Abi.macosX64 => 'darwin-x64',
  Abi.windowsX64 => 'win32-x64',
  Abi.linuxArm64 => 'linux-arm64',
  Abi.linuxX64 => 'linux-x64',
  _ => '',
};

String _currentManifestPlatform() {
  if (Platform.isMacOS) return 'darwin';
  if (Platform.isWindows) return 'win32';
  if (Platform.isLinux) return 'linux';
  return '';
}

String _targetArchitecture(String targetId) => switch (targetId) {
  'darwin-arm64' || 'linux-arm64' => 'arm64',
  'darwin-x64' || 'linux-x64' || 'win32-x64' => 'x64',
  'darwin-universal' => switch (Abi.current()) {
    Abi.macosArm64 => 'arm64',
    Abi.macosX64 => 'x64',
    _ => '',
  },
  _ => '',
};

String _resolveCapsulePath(Directory root, String relativePath) {
  final normalized = _relativePathValue(relativePath, 'capsule path');
  final path = <String>[
    root.path,
    ...normalized.split('/'),
  ].join(Platform.pathSeparator);
  if (!_isInside(root.absolute.path, File(path).absolute.path)) {
    throw const PiNodeRuntimeLocationException(
      PiNodeRuntimeLocationErrorCode.integrityMismatch,
    );
  }
  return path;
}

String _relativeCapsulePath(Directory root, String path) {
  final prefix = '${root.absolute.path}${Platform.pathSeparator}';
  final absolute = File(path).absolute.path;
  if (!absolute.startsWith(prefix)) {
    throw const PiNodeRuntimeLocationException(
      PiNodeRuntimeLocationErrorCode.integrityMismatch,
    );
  }
  return absolute
      .substring(prefix.length)
      .replaceAll(Platform.pathSeparator, '/');
}

bool _isInside(String root, String candidate) {
  final normalizedRoot = Directory(root).absolute.path;
  final normalizedCandidate = File(candidate).absolute.path;
  return normalizedCandidate == normalizedRoot ||
      normalizedCandidate.startsWith(
        '$normalizedRoot${Platform.pathSeparator}',
      );
}

bool _isAbsolute(String value) =>
    value.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value);

String _relativePathValue(Object? value, String field) {
  final text = _stringValue(value, field);
  if (_isAbsolute(text) ||
      text.contains('\\') ||
      text.startsWith('./') ||
      text.endsWith('/') ||
      text
          .split('/')
          .any(
            (segment) => segment.isEmpty || segment == '.' || segment == '..',
          )) {
    throw FormatException('Invalid $field.');
  }
  return text;
}

String _sha256Value(Object? value, String field) {
  final text = _stringValue(value, field);
  if (text.length != 64 || !_lowercaseHex.hasMatch(text)) {
    throw FormatException('Invalid $field.');
  }
  return text;
}

String _stringValue(Object? value, String field) {
  if (value is! String || value.isEmpty) {
    throw FormatException('Invalid $field.');
  }
  return value;
}

int _integerValue(Object? value, String field) {
  if (value is! int || value < 0) {
    throw FormatException('Invalid $field.');
  }
  return value;
}

Map<String, Object?> _asRecord(Object? value, String field) {
  if (value is! Map) throw FormatException('Invalid $field.');
  return value.map<String, Object?>(
    (key, value) => MapEntry(_stringValue(key, '$field key'), value),
  );
}

List<Object?> _asList(Object? value, String field) {
  if (value is! List) throw FormatException('Invalid $field.');
  return List<Object?>.from(value);
}

void _expectExactKeys(Map<String, Object?> value, Set<String> expected) {
  if (value.length != expected.length || !value.keys.every(expected.contains)) {
    throw const FormatException('Unexpected manifest fields.');
  }
}

String _firstNonEmpty(Iterable<String?> candidates) {
  for (final candidate in candidates) {
    if (candidate != null && candidate.trim().isNotEmpty) {
      return candidate;
    }
  }
  throw const PiNodeRuntimeLocationException(
    PiNodeRuntimeLocationErrorCode.incompatibleCapsule,
  );
}

final _lowercaseHex = RegExp(r'^[0-9a-f]+$');
