import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';

export const repositoryRoot = resolve(import.meta.dirname, '..');
export const repositorySlug = 'Hu-Wentao/pi-client';
export const requiredFlutterVersion = '3.41.6';
export const legacyPreviewVersion = '0.0.2';
export const legacyPreviewBuildNumber = '2';
export const linuxRuntimeBaseline =
  'ubuntu-24.04-compatible; system libsecret/keyring required';

const target = (
  id,
  platform,
  architecture,
  artifactLabel,
  extension,
  executionRole,
  signing,
  installability,
  runtimeBaseline = null,
) => ({
  id,
  platform,
  architecture,
  artifactLabel,
  extension,
  executionRole,
  signing,
  installability,
  hostRuntimeIncluded: false,
  runtimeBaseline,
});

export const artifactProfiles = Object.freeze({
  'macos-preview-v1': Object.freeze({
    id: 'macos-preview-v1',
    immutableLegacy: true,
    primaryTarget: 'macos-universal',
    targets: Object.freeze([
      target(
        'macos-universal',
        'macos',
        'universal',
        'macOS-universal',
        'zip',
        'agent-host-capable',
        'unsigned',
        'unsigned-preview',
      ),
    ]),
  }),
  'six-platform-preview-v1': Object.freeze({
    id: 'six-platform-preview-v1',
    immutableLegacy: false,
    primaryTarget: 'macos-universal',
    targets: Object.freeze([
      target(
        'android-armeabi-v7a',
        'android',
        'armeabi-v7a',
        'Android-armeabi-v7a',
        'apk',
        'remote-client-only',
        'unsigned',
        'requires-signing-before-install',
      ),
      target(
        'android-arm64-v8a',
        'android',
        'arm64-v8a',
        'Android-arm64-v8a',
        'apk',
        'remote-client-only',
        'unsigned',
        'requires-signing-before-install',
      ),
      target(
        'android-x86_64',
        'android',
        'x86_64',
        'Android-x86_64',
        'apk',
        'remote-client-only',
        'unsigned',
        'requires-signing-before-install',
      ),
      target(
        'ios-arm64',
        'ios',
        'arm64',
        'iOS-arm64',
        'xcarchive.zip',
        'remote-client-only',
        'no-codesign',
        'development-archive-only',
      ),
      target(
        'macos-universal',
        'macos',
        'universal',
        'macOS-universal',
        'zip',
        'agent-host-capable',
        'unsigned',
        'unsigned-preview',
      ),
      target(
        'windows-amd64-portable',
        'windows',
        'amd64',
        'Windows-amd64-portable',
        'zip',
        'agent-host-capable',
        'unsigned',
        'portable-archive',
      ),
      target(
        'linux-amd64',
        'linux',
        'amd64',
        'Linux-amd64',
        'tar.gz',
        'agent-host-capable',
        'unsigned',
        'requires-linux-desktop-runtime',
        linuxRuntimeBaseline,
      ),
      target(
        'web-js',
        'web',
        'javascript',
        'Web-js',
        'zip',
        'remote-client-only',
        'not-applicable',
        'static-web-bundle',
      ),
    ]),
  }),
});

function parseSemVerParts(value, label = 'version') {
  const match = String(value).match(/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$/);
  if (!match) throw new Error(`${label} must be an exact stable MAJOR.MINOR.PATCH version.`);
  return match.slice(1).map((part) => BigInt(part));
}

export function compareSemVer(left, right) {
  const leftParts = parseSemVerParts(left, 'left version');
  const rightParts = parseSemVerParts(right, 'right version');
  for (let index = 0; index < leftParts.length; index += 1) {
    if (leftParts[index] < rightParts[index]) return -1;
    if (leftParts[index] > rightParts[index]) return 1;
  }
  return 0;
}

export function parseStableTag(tag) {
  const match = String(tag).match(/^v((?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*))$/);
  return match?.[1] ?? null;
}

function parseRemoteTagRows(source) {
  if (source === '') return [];
  const rows = [];
  for (const line of source.split('\n')) {
    if (line === '') continue;
    const match = line.match(/^([0-9a-f]{40})\t(refs\/tags\/[^\s]+)$/);
    if (!match) throw new Error(`Invalid git ls-remote tag row: ${line}.`);
    rows.push({ objectId: match[1], ref: match[2] });
  }
  return rows;
}

export function assertCandidateExceedsRemoteStableTags(candidateTag, source) {
  const candidateVersion = parseStableTag(candidateTag);
  if (!candidateVersion) throw new Error(`Candidate tag ${candidateTag} is not a stable release tag.`);
  const stableTags = new Set();
  for (const { ref } of parseRemoteTagRows(source)) {
    const withoutPrefix = ref.slice('refs/tags/'.length).replace(/\^\{\}$/, '');
    if (parseStableTag(withoutPrefix)) stableTags.add(withoutPrefix);
  }
  for (const remoteTag of [...stableTags].sort()) {
    if (remoteTag === candidateTag) continue;
    const remoteVersion = parseStableTag(remoteTag);
    if (compareSemVer(candidateVersion, remoteVersion) <= 0) {
      throw new Error(
        `Candidate ${candidateTag} must be greater than remote stable tag ${remoteTag}.`,
      );
    }
  }
  return [...stableTags].sort();
}

export function inspectRemoteCandidateTag(candidateTag, candidateCommit, source) {
  if (!/^[0-9a-f]{40}$/.test(candidateCommit ?? '')) {
    throw new Error('Candidate commit must be an exact lowercase 40-character Git commit.');
  }
  if (!parseStableTag(candidateTag)) {
    throw new Error(`Candidate tag ${candidateTag} is not a stable release tag.`);
  }
  const rawRef = `refs/tags/${candidateTag}`;
  const peeledRef = `${rawRef}^{}`;
  const rows = parseRemoteTagRows(source);
  const raw = rows.filter(({ ref }) => ref === rawRef);
  const peeled = rows.filter(({ ref }) => ref === peeledRef);
  if (raw.length === 0 && peeled.length === 0) return { state: 'absent' };
  if (raw.length !== 1 || peeled.length !== 1) {
    throw new Error(
      `Existing remote tag ${candidateTag} must be one annotated tag with one peeled commit.`,
    );
  }
  if (peeled[0].objectId !== candidateCommit) {
    throw new Error(
      `Existing remote tag ${candidateTag} peels to ${peeled[0].objectId}, not ${candidateCommit}.`,
    );
  }
  return {
    state: 'existing-annotated',
    tagObject: raw[0].objectId,
    peeledCommit: peeled[0].objectId,
  };
}

export function parsePubspecVersion(source) {
  const matches = [...source.matchAll(/^version:\s*([^\s#]+)\s*$/gm)];
  if (matches.length !== 1) {
    throw new Error('pubspec.yaml must contain exactly one version field.');
  }
  const match = matches[0][1].match(
    /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)\+([1-9]\d*)$/,
  );
  if (!match) {
    throw new Error('pubspec.yaml version must be MAJOR.MINOR.PATCH+BUILD with no leading zeroes.');
  }
  return { version: `${match[1]}.${match[2]}.${match[3]}`, buildNumber: match[4] };
}

function assertExactKeys(value, expected, label) {
  const actual = Object.keys(value).sort();
  const wanted = [...expected].sort();
  if (JSON.stringify(actual) !== JSON.stringify(wanted)) {
    throw new Error(`${label} keys must be exactly: ${wanted.join(', ')}.`);
  }
}

export function getArtifactProfile(id) {
  const profile = artifactProfiles[id];
  if (!profile) throw new Error(`Unknown artifact profile: ${id}.`);
  const ids = profile.targets.map(({ id: targetId }) => targetId);
  if (new Set(ids).size !== ids.length || !ids.includes(profile.primaryTarget)) {
    throw new Error(`Artifact profile ${id} has duplicate targets or an invalid primary target.`);
  }
  for (const artifact of profile.targets) {
    const expectedRole = ['android', 'ios', 'web'].includes(artifact.platform)
      ? 'remote-client-only'
      : 'agent-host-capable';
    const expectedRuntimeBaseline =
      artifact.platform === 'linux' ? linuxRuntimeBaseline : null;
    if (
      artifact.executionRole !== expectedRole ||
      artifact.hostRuntimeIncluded !== false ||
      artifact.runtimeBaseline !== expectedRuntimeBaseline
    ) {
      throw new Error(`Artifact profile ${id} violates a platform release boundary.`);
    }
  }
  return profile;
}

export function assertArtifactProfileVersion(profile, version, buildNumber) {
  parseSemVerParts(version);
  if (!/^[1-9]\d*$/.test(String(buildNumber))) {
    throw new Error('Build number must be a positive decimal integer.');
  }
  if (profile.id === 'macos-preview-v1') {
    if (version !== legacyPreviewVersion || String(buildNumber) !== legacyPreviewBuildNumber) {
      throw new Error(
        `macos-preview-v1 is immutable and only valid for ${legacyPreviewVersion}+${legacyPreviewBuildNumber}.`,
      );
    }
    return;
  }
  if (
    profile.id === 'six-platform-preview-v1' &&
    compareSemVer(version, legacyPreviewVersion) <= 0
  ) {
    throw new Error(
      `six-platform-preview-v1 requires a version greater than ${legacyPreviewVersion}.`,
    );
  }
}

export function artifactFileName(version, artifactTarget) {
  return `Pi-Client-${version}-${artifactTarget.artifactLabel}.${artifactTarget.extension}`;
}

export function applicationArtifacts(version, profile) {
  const artifacts = profile.targets.map((item) => ({
    ...item,
    file: artifactFileName(version, item),
  }));
  if (new Set(artifacts.map(({ file }) => file)).size !== artifacts.length) {
    throw new Error(`Artifact profile ${profile.id} produces duplicate file names.`);
  }
  return artifacts;
}

export function releaseAssets(version, profile) {
  const applications = applicationArtifacts(version, profile).map(({ file }) => file);
  const primary = applicationArtifacts(version, profile).find(
    ({ id }) => id === profile.primaryTarget,
  );
  if (!primary) throw new Error(`Profile ${profile.id} has no primary target ${profile.primaryTarget}.`);
  if (profile.immutableLegacy) return [primary.file, `${primary.file}.sha256`];
  return [
    ...applications,
    'artifact-manifest.json',
    'SHA256SUMS',
    `${primary.file}.sha256`,
  ].sort();
}

export function expectedReleaseNotes(metadata) {
  if (metadata.artifactProfile === 'macos-preview-v1') {
    return `## Pi Client ${metadata.version} unsigned macOS preview

This preview provides a Universal macOS app for Apple silicon and Intel Macs.

### Before you install

This app is **not signed with an Apple Developer ID and is not notarized**. macOS Gatekeeper will warn before opening it. Install it only if you trust this repository and the published SHA-256 checksum. A signed, notarized DMG is not available in this release.

The unsigned preview uses an isolated preferences directory and a fixed public storage key so it can start without Keychain entitlement access. The public key provides no secrecy. The preview does not persist the pi-web password, and a future signed release will not automatically inherit preview preferences.

### Requirements

- macOS 11.0 or newer.
- A running pi-web \`0.8.11\` service.
- A model provider configured for pi when you want to execute prompts.

### Install

1. Download \`${metadata.asset}\` and its \`.sha256\` file.
2. Verify the checksum.
3. Extract \`Pi Client.app\`.
4. In Finder, Control-click \`Pi Client.app\`, select **Open**, then confirm **Open** in the warning dialog. Do not remove quarantine metadata with a shell command.

For setup and security guidance, see the [Pi Client README](https://github.com/${repositorySlug}#start-pi-client).

### Current scope

Pi Client can browse sessions, create and continue work, follow live output, and stop an active run through the transitional pi-web \`0.8.11\` compatibility boundary. This release does not include WebAssembly support, a signed DMG, or the planned versioned Pi SDK-based transport.
`;
  }
  return `## Pi Client ${metadata.version} unsigned cross-platform preview

This prerelease contains unsigned preview artifacts for Android, iOS, macOS, Windows, Linux, and the JavaScript Web target.

### Security and installability

- Android APKs are unsigned and require signing before installation.
- The iOS artifact is a no-codesign development archive, not an installable IPA.
- macOS and Windows artifacts are unsigned; macOS is not notarized.
- The Linux archive is not self-contained. It targets Ubuntu 24.04-compatible desktop runtimes and requires system libsecret/keyring libraries.
- The Dart application is compiled to JavaScript. Flutter renderer framework assets may include WebAssembly.
- No artifact includes the planned Pi SDK Agent Host runtime. This is package filename-boundary evidence, not proof about arbitrary embedded file contents.

Use these artifacts only for evaluation. Verify \`SHA256SUMS\` and \`artifact-manifest.json\` before use.
`;
}

function parseReleaseBlock(source) {
  const block = source.match(/export const release = \{([\s\S]*?)\n\} as const;/);
  if (!block) throw new Error('site/src/content/copy.ts must contain the release block.');
  const fields = {};
  for (const key of ['version', 'tag', 'asset', 'downloadUrl', 'releaseUrl']) {
    const match = block[1].match(new RegExp(`${key}:\\s*(?:\\n\\s*)?'([^']+)'`));
    if (!match) throw new Error(`Landing-page release block is missing ${key}.`);
    fields[key] = match[1];
  }
  const fieldNames = [...block[1].matchAll(/^\s*([A-Za-z]+):/gm)]
    .map((match) => match[1])
    .sort();
  if (
    JSON.stringify(fieldNames) !==
    JSON.stringify(['asset', 'downloadUrl', 'releaseUrl', 'tag', 'version'])
  ) {
    throw new Error('Landing-page release block contains unexpected or duplicate fields.');
  }
  return fields;
}

export async function loadReleaseContract(root = repositoryRoot, options = {}) {
  const [pubspecSource, fvmSource, releaseSource, sitePackageSource, siteCopySource] =
    await Promise.all([
      readFile(resolve(root, 'pubspec.yaml'), 'utf8'),
      readFile(resolve(root, '.fvmrc'), 'utf8'),
      readFile(resolve(root, 'release/release.json'), 'utf8'),
      readFile(resolve(root, 'site/package.json'), 'utf8'),
      readFile(resolve(root, 'site/src/content/copy.ts'), 'utf8'),
    ]);

  const { version, buildNumber } = parsePubspecVersion(pubspecSource);
  const fvm = JSON.parse(fvmSource);
  assertExactKeys(fvm, ['flutter'], '.fvmrc');
  if (fvm.flutter !== requiredFlutterVersion) {
    throw new Error(`.fvmrc must pin Flutter ${requiredFlutterVersion}.`);
  }

  const releaseConfig = JSON.parse(releaseSource);
  assertExactKeys(
    releaseConfig,
    ['schemaVersion', 'artifactProfile', 'primaryTarget'],
    'release/release.json',
  );
  if (releaseConfig.schemaVersion !== 1) {
    throw new Error('release/release.json schemaVersion must be 1.');
  }
  const profile = getArtifactProfile(releaseConfig.artifactProfile);
  assertArtifactProfileVersion(profile, version, buildNumber);
  if (releaseConfig.primaryTarget !== profile.primaryTarget) {
    throw new Error(`release primaryTarget must be ${profile.primaryTarget} for ${profile.id}.`);
  }
  if (options.requireProfile && profile.id !== options.requireProfile) {
    throw new Error(
      `Release profile ${profile.id} does not satisfy required profile ${options.requireProfile}.`,
    );
  }

  const artifacts = applicationArtifacts(version, profile);
  const primary = artifacts.find(({ id }) => id === profile.primaryTarget);
  const tag = `v${version}`;
  const asset = primary.file;
  const checksumAsset = `${asset}.sha256`;
  const downloadUrl = `https://github.com/${repositorySlug}/releases/download/${tag}/${asset}`;
  const releaseUrl = `https://github.com/${repositorySlug}/releases/tag/${tag}`;
  const releaseNotesPath = `.github/release-notes/${tag}.md`;
  const metadata = {
    version,
    buildNumber,
    tag,
    asset,
    checksumAsset,
    downloadUrl,
    artifactProfile: profile.id,
    primaryTarget: profile.primaryTarget,
    expectedAssets: releaseAssets(version, profile),
    releaseTitle:
      profile.id === 'macos-preview-v1'
        ? `Pi Client ${version} unsigned macOS preview`
        : `Pi Client ${version} unsigned cross-platform preview`,
    releaseNotesPath,
    flutterVersion: fvm.flutter,
    artifacts,
  };

  const sitePackage = JSON.parse(sitePackageSource);
  if (sitePackage.version !== version) {
    throw new Error(`site/package.json version must be ${version}.`);
  }
  const actualReleaseBlock = parseReleaseBlock(siteCopySource);
  const expectedReleaseBlock = { version, tag, asset, downloadUrl, releaseUrl };
  if (JSON.stringify(actualReleaseBlock) !== JSON.stringify(expectedReleaseBlock)) {
    throw new Error('Landing-page release block does not exactly match the release contract.');
  }

  const notes = await readFile(resolve(root, releaseNotesPath), 'utf8');
  if (notes !== expectedReleaseNotes(metadata)) {
    throw new Error(`${releaseNotesPath} does not exactly match the release contract.`);
  }
  return metadata;
}
