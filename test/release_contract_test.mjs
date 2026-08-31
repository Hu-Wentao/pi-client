import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { cp, mkdir, mkdtemp, readFile, readdir, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, resolve } from 'node:path';
import { promisify } from 'node:util';
import test from 'node:test';
import {
  applicationArtifacts,
  assertCandidateExceedsRemoteStableTags,
  compareSemVer,
  expectedReleaseNotes,
  getArtifactProfile,
  homebrewCask,
  homebrewInstallCommand,
  homebrewTap,
  inspectRemoteCandidateTag,
  legacyPreviewBuildNumber,
  legacyPreviewVersion,
  linuxRuntimeBaseline,
  loadReleaseContract,
  parsePubspecVersion,
  parseStableTag,
  releaseAssets,
  repositoryRoot,
} from '../tool/release_contract.mjs';

const execFileAsync = promisify(execFile);
const legacyFixtureSpec = Object.freeze({
  version: '0.0.2',
  buildNumber: '2',
  profileId: 'macos-preview-v1',
});
const futureFixtureSpec = Object.freeze({
  version: '0.0.3',
  buildNumber: '3',
  profileId: 'six-platform-preview-v1',
});

function fixtureMetadata({ version, buildNumber, profileId }) {
  const profile = getArtifactProfile(profileId);
  const primary = applicationArtifacts(version, profile).find(
    ({ id }) => id === profile.primaryTarget,
  );
  const tag = `v${version}`;
  return {
    version,
    buildNumber,
    tag,
    asset: primary.file,
    artifactProfile: profileId,
    primaryTarget: profile.primaryTarget,
    releaseNotesPath: `.github/release-notes/${tag}.md`,
  };
}

async function copyFixtureSkeleton(root) {
  for (const path of [
    'site/src/content',
    '.github/release-notes',
    'release',
  ]) {
    await mkdir(resolve(root, path), { recursive: true });
  }
  for (const file of ['pubspec.yaml', '.fvmrc', 'site/package.json']) {
    await cp(resolve(repositoryRoot, file), resolve(root, file));
  }
  await cp(
    resolve(repositoryRoot, 'site/src/content/copy.ts'),
    resolve(root, 'site/src/content/copy.ts'),
  );
}

async function configureFixture(root, spec) {
  const metadata = fixtureMetadata(spec);
  const pubspecPath = resolve(root, 'pubspec.yaml');
  await writeFile(
    pubspecPath,
    (await readFile(pubspecPath, 'utf8')).replace(
      /^version:.*$/m,
      `version: ${metadata.version}+${metadata.buildNumber}`,
    ),
  );
  await writeFile(
    resolve(root, 'release/release.json'),
    `${JSON.stringify(
      {
        schemaVersion: 1,
        artifactProfile: metadata.artifactProfile,
        primaryTarget: metadata.primaryTarget,
      },
      null,
      2,
    )}\n`,
  );

  const sitePackagePath = resolve(root, 'site/package.json');
  const sitePackage = JSON.parse(await readFile(sitePackagePath, 'utf8'));
  sitePackage.version = metadata.version;
  await writeFile(sitePackagePath, `${JSON.stringify(sitePackage, null, 2)}\n`);

  const copyPath = resolve(root, 'site/src/content/copy.ts');
  const releaseBlock = `export const release = {\n  version: '${metadata.version}',\n  tag: '${metadata.tag}',\n  asset: '${metadata.asset}',\n  downloadUrl:\n    'https://github.com/Hu-Wentao/pi-client/releases/download/${metadata.tag}/${metadata.asset}',\n  releaseUrl: 'https://github.com/Hu-Wentao/pi-client/releases/tag/${metadata.tag}',\n} as const;`;
  await writeFile(
    copyPath,
    (await readFile(copyPath, 'utf8')).replace(
      /export const release = \{[\s\S]*?\n\} as const;/,
      releaseBlock,
    ),
  );
  await writeFile(
    resolve(root, metadata.releaseNotesPath),
    expectedReleaseNotes(metadata),
  );
  return { root, metadata };
}

async function releaseFixture(spec) {
  const root = await mkdtemp(resolve(tmpdir(), 'pi-release-contract-'));
  await copyFixtureSkeleton(root);
  return configureFixture(root, spec);
}

async function legacyReleaseFixture() {
  return releaseFixture(legacyFixtureSpec);
}

export async function futureReleaseFixture() {
  return releaseFixture(futureFixtureSpec);
}

async function copyPath(sourceRoot, targetRoot, path) {
  const target = resolve(targetRoot, path);
  await mkdir(dirname(target), { recursive: true });
  await cp(resolve(sourceRoot, path), target, { recursive: true });
}

async function switchedRepositoryFixture() {
  const root = await mkdtemp(resolve(tmpdir(), 'pi-release-switched-repository-'));
  for (const path of [
    'tool',
    'test',
    '.github/actions',
    '.github/workflows',
    '.github/release-notes',
    'release',
    'site/scripts',
    'site/src/content',
    'site/package.json',
    'pubspec.yaml',
    '.fvmrc',
    'android/app/build.gradle.kts',
  ]) {
    await copyPath(repositoryRoot, root, path);
  }
  return configureFixture(root, futureFixtureSpec);
}

test('parses generic MAJOR.MINOR.PATCH+BUILD versions', () => {
  assert.deepEqual(parsePubspecVersion('name: sample\nversion: 12.34.56+789\n'), {
    version: '12.34.56',
    buildNumber: '789',
  });
  for (const invalid of ['1.2.3', '01.2.3+4', '1.2.3+0', '1.2+3', 'v1.2.3+4']) {
    assert.throws(() => parsePubspecVersion(`version: ${invalid}\n`));
  }
  assert.throws(() => parsePubspecVersion('version: 1.2.3+4\nversion: 1.2.4+5\n'));
});

test('compares stable SemVer values and parses only exact stable tags', () => {
  assert.equal(compareSemVer('0.0.2', '0.0.2'), 0);
  assert.equal(compareSemVer('0.0.3', '0.0.2'), 1);
  assert.equal(compareSemVer('1.0.0', '99.99.99'), -1);
  assert.equal(compareSemVer('999999999999999999999.0.0', '2.0.0'), 1);
  assert.equal(parseStableTag('v12.34.56'), '12.34.56');
  for (const ignored of ['0.0.3', 'v0.0.3-rc.1', 'v01.2.3', 'decision-016', 'release/v1.2.3']) {
    assert.equal(parseStableTag(ignored), null);
  }
  assert.throws(() => compareSemVer('1.2.3-rc.1', '1.2.3'));
});

test('remote stable-tag monotonicity ignores candidate resumes and non-stable tags', () => {
  const remote = [
    '1111111111111111111111111111111111111111\trefs/tags/v0.0.2',
    '2222222222222222222222222222222222222222\trefs/tags/v0.0.2^{}',
    '3333333333333333333333333333333333333333\trefs/tags/v0.0.3-rc.1',
    '4444444444444444444444444444444444444444\trefs/tags/decision-016',
    '5555555555555555555555555555555555555555\trefs/tags/v0.0.3',
    '0123456789abcdef0123456789abcdef01234567\trefs/tags/v0.0.3^{}',
    '',
  ].join('\n');
  assert.deepEqual(assertCandidateExceedsRemoteStableTags('v0.0.3', remote), [
    'v0.0.2',
    'v0.0.3',
  ]);
  assert.throws(
    () => assertCandidateExceedsRemoteStableTags('v0.0.2', remote),
    /greater than remote stable tag v0\.0\.3/,
  );
  assert.throws(
    () => assertCandidateExceedsRemoteStableTags('v0.0.3', 'not valid ls-remote output\n'),
    /Invalid git ls-remote/,
  );
});

test('remote candidate tag admission is absent or an annotated exact-commit resume', () => {
  const commit = '0123456789abcdef0123456789abcdef01234567';
  assert.deepEqual(inspectRemoteCandidateTag('v0.0.3', commit, ''), { state: 'absent' });
  assert.deepEqual(
    inspectRemoteCandidateTag(
      'v0.0.3',
      commit,
      [
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\trefs/tags/v0.0.3',
        `${commit}\trefs/tags/v0.0.3^{}`,
        '',
      ].join('\n'),
    ),
    {
      state: 'existing-annotated',
      tagObject: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      peeledCommit: commit,
    },
  );
  assert.throws(
    () => inspectRemoteCandidateTag('v0.0.3', commit, `${commit}\trefs/tags/v0.0.3\n`),
    /annotated tag/,
  );
  assert.throws(
    () =>
      inspectRemoteCandidateTag(
        'v0.0.3',
        commit,
        [
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\trefs/tags/v0.0.3',
          'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\trefs/tags/v0.0.3^{}',
          '',
        ].join('\n'),
      ),
    /not 0123456789abcdef/,
  );
});

test('repository-active release contract is internally synchronized without a fixed profile', async () => {
  const metadata = await loadReleaseContract();
  const profile = getArtifactProfile(metadata.artifactProfile);
  assert.equal(metadata.tag, `v${metadata.version}`);
  assert.equal(metadata.primaryTarget, profile.primaryTarget);
  assert.deepEqual(metadata.artifacts, applicationArtifacts(metadata.version, profile));
  assert.deepEqual(metadata.expectedAssets, releaseAssets(metadata.version, profile));
  assert.equal(
    await readFile(resolve(repositoryRoot, metadata.releaseNotesPath), 'utf8'),
    expectedReleaseNotes(metadata),
  );
  assert.deepEqual(
    await loadReleaseContract(undefined, { requireProfile: metadata.artifactProfile }),
    metadata,
  );
});

test('synthesized legacy fixture permanently proves immutable 0.0.2+2 compatibility', async () => {
  assert.equal(legacyPreviewVersion, legacyFixtureSpec.version);
  assert.equal(legacyPreviewBuildNumber, legacyFixtureSpec.buildNumber);
  const { root, metadata: fixtureMetadataValue } = await legacyReleaseFixture();
  const metadata = await loadReleaseContract(root, {
    requireProfile: legacyFixtureSpec.profileId,
  });
  assert.equal(metadata.version, '0.0.2');
  assert.equal(metadata.buildNumber, '2');
  assert.equal(metadata.tag, 'v0.0.2');
  assert.equal(metadata.artifactProfile, 'macos-preview-v1');
  assert.equal(metadata.asset, 'Pi-Client-0.0.2-macOS-universal.zip');
  assert.equal(metadata.releaseNotesPath, fixtureMetadataValue.releaseNotesPath);
  assert.deepEqual(metadata.expectedAssets, [
    'Pi-Client-0.0.2-macOS-universal.zip',
    'Pi-Client-0.0.2-macOS-universal.zip.sha256',
  ]);
});

test('profile version gates use explicit fixtures rather than repository-active metadata', async () => {
  const { root: legacyRoot, metadata: legacyMetadata } = await legacyReleaseFixture();
  const legacyPubspec = resolve(legacyRoot, 'pubspec.yaml');
  await writeFile(
    legacyPubspec,
    (await readFile(legacyPubspec, 'utf8')).replace(
      /^version:.*$/m,
      `version: ${legacyMetadata.version}+${Number(legacyMetadata.buildNumber) + 1}`,
    ),
  );
  await assert.rejects(() => loadReleaseContract(legacyRoot), /only valid for 0\.0\.2\+2/);

  const invalidSixSpec = {
    ...legacyFixtureSpec,
    profileId: futureFixtureSpec.profileId,
  };
  const { root: sixRoot } = await releaseFixture(invalidSixSpec);
  await assert.rejects(
    () => loadReleaseContract(sixRoot),
    /requires a version greater than 0\.0\.2/,
  );
});

test('future six-platform profile defines exact roles, baselines, and artifacts', () => {
  const profile = getArtifactProfile(futureFixtureSpec.profileId);
  const artifacts = applicationArtifacts(futureFixtureSpec.version, profile);
  assert.deepEqual(
    artifacts.map(({ file }) => file),
    [
      'Pi-Client-0.0.3-Android-armeabi-v7a.apk',
      'Pi-Client-0.0.3-Android-arm64-v8a.apk',
      'Pi-Client-0.0.3-Android-x86_64.apk',
      'Pi-Client-0.0.3-iOS-arm64.xcarchive.zip',
      'Pi-Client-0.0.3-macOS-universal.zip',
      'Pi-Client-0.0.3-Windows-amd64-portable.zip',
      'Pi-Client-0.0.3-Linux-amd64.tar.gz',
      'Pi-Client-0.0.3-Web-js.zip',
    ],
  );
  for (const artifact of artifacts) {
    assert.equal(artifact.hostRuntimeIncluded, false);
    assert.equal(
      artifact.executionRole,
      ['android', 'ios', 'web'].includes(artifact.platform)
        ? 'remote-client-only'
        : 'agent-host-capable',
    );
    assert.equal(
      artifact.runtimeBaseline,
      artifact.platform === 'linux' ? linuxRuntimeBaseline : null,
    );
  }
  assert.deepEqual(releaseAssets(futureFixtureSpec.version, profile), [
    'Pi-Client-0.0.3-Android-arm64-v8a.apk',
    'Pi-Client-0.0.3-Android-armeabi-v7a.apk',
    'Pi-Client-0.0.3-Android-x86_64.apk',
    'Pi-Client-0.0.3-Linux-amd64.tar.gz',
    'Pi-Client-0.0.3-Web-js.zip',
    'Pi-Client-0.0.3-Windows-amd64-portable.zip',
    'Pi-Client-0.0.3-iOS-arm64.xcarchive.zip',
    'Pi-Client-0.0.3-macOS-universal.zip',
    'Pi-Client-0.0.3-macOS-universal.zip.sha256',
    'SHA256SUMS',
    'artifact-manifest.json',
  ].sort());
});

test('future profile fixture uses synchronized 0.0.3+3 site, notes, and Homebrew metadata', async () => {
  const { root, metadata: fixtureMetadataValue } = await futureReleaseFixture();
  const metadata = await loadReleaseContract(root, {
    requireProfile: futureFixtureSpec.profileId,
  });
  assert.equal(metadata.version, futureFixtureSpec.version);
  assert.equal(metadata.buildNumber, futureFixtureSpec.buildNumber);
  assert.equal(metadata.tag, fixtureMetadataValue.tag);
  assert.equal(metadata.releaseNotesPath, fixtureMetadataValue.releaseNotesPath);
  assert.equal(metadata.artifacts.length, 8);
  assert.equal(metadata.expectedAssets.length, 11);
  const notes = await readFile(resolve(root, metadata.releaseNotesPath), 'utf8');
  assert.match(notes, /Linux archive is not self-contained/);
  assert.match(notes, new RegExp(homebrewInstallCommand));
  assert.match(notes, /Do not remove quarantine metadata or disable Gatekeeper/);
  assert.equal(homebrewTap, 'Hu-Wentao/homebrew-tap');
  assert.equal(homebrewCask, 'pi-client');
});

test('strict contract drift tests target explicit fixture metadata and notes paths', async (t) => {
  const cases = [
    [
      'release config',
      async (root, metadata) =>
        writeFile(
          resolve(root, 'release/release.json'),
          `${JSON.stringify(
            {
              schemaVersion: 1,
              artifactProfile: metadata.artifactProfile,
              primaryTarget: 'wrong',
            },
            null,
            2,
          )}\n`,
        ),
    ],
    ['Flutter pin', async (root) => writeFile(resolve(root, '.fvmrc'), '{"flutter":"3.40.0"}\n')],
    [
      'site package',
      async (root) =>
        writeFile(
          resolve(root, 'site/package.json'),
          `${JSON.stringify({ name: 'pi-client-site', version: '9.9.9' })}\n`,
        ),
    ],
    [
      'release notes',
      async (root, metadata) => writeFile(resolve(root, metadata.releaseNotesPath), 'drift\n'),
    ],
  ];
  for (const [name, mutate] of cases) {
    await t.test(name, async () => {
      const { root, metadata } = await futureReleaseFixture();
      await mutate(root, metadata);
      await assert.rejects(() => loadReleaseContract(root));
    });
  }

  const { root, metadata } = await futureReleaseFixture();
  const copyPath = resolve(root, 'site/src/content/copy.ts');
  await writeFile(
    copyPath,
    (await readFile(copyPath, 'utf8')).replace(
      `version: '${metadata.version}'`,
      "version: '9.9.9'",
    ),
  );
  await assert.rejects(() => loadReleaseContract(root));
});

test(
  'the complete Node suite survives a repository-active switch to 0.0.3+3 six-platform',
  { skip: process.env.PI_NESTED_ACTIVE_PROFILE_PROOF === '1' },
  async () => {
    const { root } = await switchedRepositoryFixture();
    const testFiles = (await readdir(resolve(root, 'test')))
      .filter((name) => name.endsWith('_test.mjs'))
      .sort()
      .map((name) => resolve('test', name));
    const childEnv = { ...process.env, PI_NESTED_ACTIVE_PROFILE_PROOF: '1' };
    delete childEnv.NODE_TEST_CONTEXT;
    const { stdout, stderr } = await execFileAsync(process.execPath, ['--test', ...testFiles], {
      cwd: root,
      env: childEnv,
      maxBuffer: 20 * 1024 * 1024,
      timeout: 120_000,
    });
    assert.match(`${stdout}\n${stderr}`, /fail 0\b/);
  },
);
