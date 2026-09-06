import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';

export const repositoryRoot = resolve(import.meta.dirname, '..');
export const repositorySlug = 'Hu-Wentao/pi-client';
export const homebrewTap = 'Hu-Wentao/homebrew-tap';
export const homebrewCask = 'pi-client';
export const homebrewTapCaskPath = 'Casks/pi-client.rb';
export const homebrewInstallCommand = 'brew install --cask hu-wentao/tap/pi-client';
export const requiredFlutterVersion = '3.41.6';
export const legacyPreviewVersion = '0.0.2';
export const legacyPreviewBuildNumber = '2';
export const independentDevelopmentVersion = '0.1.0';
export const independentDevelopmentBuildNumber = '3';
export const independentPreviewProfileId = 'independent-first-party-preview-v1';
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
  hostRuntimeIncluded,
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
  hostRuntimeIncluded,
  runtimeBaseline,
});

export const artifactProfiles = Object.freeze({
  'macos-preview-v1': Object.freeze({
    id: 'macos-preview-v1',
    immutableLegacy: true,
    publicationEnabled: false,
    distribution: 'historical-unsigned-preview',
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
        'historical-unsigned-preview',
        false,
      ),
    ]),
  }),
  'independent-six-platform-development-v1': Object.freeze({
    id: 'independent-six-platform-development-v1',
    immutableLegacy: false,
    publicationEnabled: false,
    distribution: 'independent-development-candidate',
    primaryTarget: 'macos-host-native',
    targets: Object.freeze([
      target(
        'android-armeabi-v7a',
        'android',
        'armeabi-v7a',
        'Android-armeabi-v7a-development',
        'apk',
        'remote-client-only',
        'unsigned',
        'requires-signing-before-install',
        false,
      ),
      target(
        'android-arm64-v8a',
        'android',
        'arm64-v8a',
        'Android-arm64-v8a-development',
        'apk',
        'remote-client-only',
        'unsigned',
        'requires-signing-before-install',
        false,
      ),
      target(
        'android-x86_64',
        'android',
        'x86_64',
        'Android-x86_64-development',
        'apk',
        'remote-client-only',
        'unsigned',
        'requires-signing-before-install',
        false,
      ),
      target(
        'ios-arm64',
        'ios',
        'arm64',
        'iOS-arm64-development',
        'xcarchive.zip',
        'remote-client-only',
        'no-codesign',
        'development-archive-only',
        false,
      ),
      target(
        'macos-host-native',
        'macos',
        'host-native',
        'macOS-host-native-ad-hoc-development',
        'zip',
        'agent-host-capable',
        'ad-hoc',
        'development-candidate',
        true,
      ),
      target(
        'windows-x64-portable',
        'windows',
        'x64',
        'Windows-x64-portable-development',
        'zip',
        'agent-host-capable',
        'unsigned',
        'development-candidate',
        true,
      ),
      target(
        'linux-x64',
        'linux',
        'x64',
        'Linux-x64-development',
        'tar.gz',
        'agent-host-capable',
        'unsigned',
        'development-candidate',
        true,
        linuxRuntimeBaseline,
      ),
      target(
        'web-js',
        'web',
        'javascript',
        'Web-js-development',
        'zip',
        'remote-client-only',
        'not-applicable',
        'static-web-bundle',
        false,
      ),
      target(
        'web-wasm',
        'web',
        'wasm',
        'Web-wasm-development',
        'zip',
        'remote-client-only',
        'not-applicable',
        'static-web-bundle',
        false,
      ),
    ]),
  }),
  [independentPreviewProfileId]: Object.freeze({
    id: independentPreviewProfileId,
    immutableLegacy: false,
    publicationEnabled: true,
    distribution: 'independent-public-preview',
    primaryTarget: 'macos-universal',
    targets: Object.freeze([
      target(
        'android-armeabi-v7a',
        'android',
        'armeabi-v7a',
        'Android-armeabi-v7a-preview',
        'apk',
        'remote-client-only',
        'unsigned',
        'requires-signing-before-install',
        false,
      ),
      target(
        'android-arm64-v8a',
        'android',
        'arm64-v8a',
        'Android-arm64-v8a-preview',
        'apk',
        'remote-client-only',
        'unsigned',
        'requires-signing-before-install',
        false,
      ),
      target(
        'android-x86_64',
        'android',
        'x86_64',
        'Android-x86_64-preview',
        'apk',
        'remote-client-only',
        'unsigned',
        'requires-signing-before-install',
        false,
      ),
      target(
        'ios-arm64',
        'ios',
        'arm64',
        'iOS-arm64-preview',
        'xcarchive.zip',
        'remote-client-only',
        'no-codesign',
        'development-archive-only',
        false,
      ),
      target(
        'macos-universal',
        'macos',
        'universal',
        'macOS-universal-ad-hoc-preview',
        'zip',
        'agent-host-capable',
        'ad-hoc',
        'public-preview',
        true,
      ),
      target(
        'windows-x64-portable',
        'windows',
        'x64',
        'Windows-x64-portable-preview',
        'zip',
        'agent-host-capable',
        'unsigned',
        'public-preview',
        true,
      ),
      target(
        'linux-x64',
        'linux',
        'x64',
        'Linux-x64-preview',
        'tar.gz',
        'agent-host-capable',
        'unsigned',
        'public-preview',
        true,
        linuxRuntimeBaseline,
      ),
      target(
        'web-js',
        'web',
        'javascript',
        'Web-js-preview',
        'zip',
        'remote-client-only',
        'not-applicable',
        'static-web-bundle',
        false,
      ),
      target(
        'web-wasm',
        'web',
        'wasm',
        'Web-wasm-preview',
        'zip',
        'remote-client-only',
        'not-applicable',
        'static-web-bundle',
        false,
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
    const expectedHostRuntime = !['android', 'ios', 'web'].includes(artifact.platform) && !profile.immutableLegacy;
    const expectedRuntimeBaseline = artifact.platform === 'linux' ? linuxRuntimeBaseline : null;
    if (
      artifact.executionRole !== expectedRole ||
      artifact.hostRuntimeIncluded !== expectedHostRuntime ||
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
  if (profile.id === 'independent-six-platform-development-v1') {
    if (
      version !== independentDevelopmentVersion ||
      String(buildNumber) !== independentDevelopmentBuildNumber
    ) {
      throw new Error(
        `independent-six-platform-development-v1 is currently bound to ${independentDevelopmentVersion}+${independentDevelopmentBuildNumber}.`,
      );
    }
    return;
  }
  if (profile.id === independentPreviewProfileId) {
    if (compareSemVer(version, independentDevelopmentVersion) < 0) {
      throw new Error(
        `${independentPreviewProfileId} must not precede ${independentDevelopmentVersion}.`,
      );
    }
    return;
  }
  throw new Error(`Unhandled artifact profile version gate: ${profile.id}.`);
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
    return `## Pi Client ${metadata.version} unsigned macOS preview\n\nThis file describes the immutable historical v0.0.2 release only. Its legacy runtime requirements are not current product architecture or installation guidance.\n`;
  }
  if (metadata.artifactProfile === independentPreviewProfileId) {
    return `## Pi Client ${metadata.version} independent public Preview\n\nThis public Preview is the first project-owned Pi Client distribution. It bundles the verified first-party Pi Node Runtime Capsule and is published as an exact, immutable release for evaluation.\n\n### Artifact roles\n\n- The macOS asset is a Universal arm64/x86_64 app with the first-party Pi Node Runtime Capsule.\n- Android, iOS, JavaScript Web, and WebAssembly assets remain connect-only and do not include the host runtime.\n- The macOS Preview is ad-hoc signed and not notarized; Homebrew preserves macOS quarantine and Gatekeeper may require an explicit first launch approval.\n- Windows and Linux Preview artifacts are unsigned and may require platform-specific trust approval.\n\n### Homebrew\n\nInstall the current macOS Preview with:\n\n\`\`\`bash\nbrew install --cask hu-wentao/tap/pi-client\n\`\`\`\n\nThe Homebrew Tap tracks the exact published macOS asset and SHA-256 for each Preview release. Do not disable Gatekeeper or remove quarantine metadata.\n`;
  }
  return `## Pi Client ${metadata.version} independent development candidate\n\nThis unpublished development candidate exercises the project-owned Pi Protocol, first-party Pi Node, and verified desktop runtime Capsules. It does not authorize a Git tag, GitHub Release, Homebrew update, or public download.\n\n### Artifact roles\n\n- macOS, Windows, and Linux development artifacts include the first-party Pi Node runtime Capsule and remain Agent-host-capable.\n- Android, iOS, JavaScript Web, and WebAssembly artifacts remain connect-only and must not include the host runtime.\n- Android and iOS artifacts are unsigned/no-codesign development evidence.\n- macOS uses ad-hoc signing for local Hardened Runtime qualification and is not Developer ID signed or notarized.\n- Windows and Linux development artifacts are not stable signed distributions.\n\n### Publication boundary\n\nThe active profile is deliberately publication-disabled. A future release decision must freeze an exact commit, enable an approved profile, provide required signing evidence for a stable channel, and requalify every published byte. Existing v0.0.2 bytes and tags remain immutable.\n`;
}

export async function loadReleaseContract(root = repositoryRoot, options = {}) {
  const [pubspecSource, fvmSource, releaseSource] = await Promise.all([
    readFile(resolve(root, 'pubspec.yaml'), 'utf8'),
    readFile(resolve(root, '.fvmrc'), 'utf8'),
    readFile(resolve(root, 'release/release.json'), 'utf8'),
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
    ['schemaVersion', 'artifactProfile', 'primaryTarget', 'publicationEnabled'],
    'release/release.json',
  );
  if (releaseConfig.schemaVersion !== 2) {
    throw new Error('release/release.json schemaVersion must be 2.');
  }
  const profile = getArtifactProfile(releaseConfig.artifactProfile);
  assertArtifactProfileVersion(profile, version, buildNumber);
  if (releaseConfig.primaryTarget !== profile.primaryTarget) {
    throw new Error(`release primaryTarget must be ${profile.primaryTarget} for ${profile.id}.`);
  }
  if (releaseConfig.publicationEnabled !== profile.publicationEnabled) {
    throw new Error(
      `release publicationEnabled must be ${profile.publicationEnabled} for ${profile.id}.`,
    );
  }
  if (options.requireProfile && profile.id !== options.requireProfile) {
    throw new Error(
      `Release profile ${profile.id} does not satisfy required profile ${options.requireProfile}.`,
    );
  }
  if (options.requirePublication && !releaseConfig.publicationEnabled) {
    throw new Error(`Release profile ${profile.id} is publication-disabled.`);
  }

  const artifacts = applicationArtifacts(version, profile);
  const primary = artifacts.find(({ id }) => id === profile.primaryTarget);
  const tag = `v${version}`;
  const asset = primary.file;
  const checksumAsset = `${asset}.sha256`;
  const downloadUrl = `https://github.com/${repositorySlug}/releases/download/${tag}/${asset}`;
  const releaseNotesPath = profile.immutableLegacy
    ? `.github/release-notes/${tag}.md`
    : profile.id === independentPreviewProfileId
      ? `.github/release-notes/${tag}-preview.md`
      : `.github/release-notes/${tag}-development.md`;
  const metadata = {
    version,
    buildNumber,
    tag,
    asset,
    checksumAsset,
    downloadUrl,
    artifactProfile: profile.id,
    primaryTarget: profile.primaryTarget,
    publicationEnabled: releaseConfig.publicationEnabled,
    distribution: profile.distribution,
    expectedAssets: releaseAssets(version, profile),
    releaseTitle: profile.immutableLegacy
      ? `Pi Client ${version} historical unsigned macOS preview`
      : profile.id === independentPreviewProfileId
        ? `Pi Client ${version} independent public Preview`
        : `Pi Client ${version} independent development candidate`,
    releaseNotesPath,
    flutterVersion: fvm.flutter,
    artifacts,
  };

  const notes = await readFile(resolve(root, releaseNotesPath), 'utf8');
  if (notes !== expectedReleaseNotes(metadata)) {
    throw new Error(`${releaseNotesPath} does not exactly match the release contract.`);
  }
  return metadata;
}
