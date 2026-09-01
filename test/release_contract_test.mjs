import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import test from 'node:test';
import {
  applicationArtifacts,
  assertArtifactProfileVersion,
  assertCandidateExceedsRemoteStableTags,
  compareSemVer,
  expectedReleaseNotes,
  getArtifactProfile,
  independentDevelopmentBuildNumber,
  independentDevelopmentVersion,
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

const profileId = 'independent-six-platform-development-v1';

const remoteTags = [
  '1111111111111111111111111111111111111111\trefs/tags/v0.0.2',
  '2222222222222222222222222222222222222222\trefs/tags/v0.0.2^{}',
  '3333333333333333333333333333333333333333\trefs/tags/v0.0.3',
  '4444444444444444444444444444444444444444\trefs/tags/v0.0.3^{}',
  '5555555555555555555555555555555555555555\trefs/tags/decision-016',
  '',
].join('\n');

test('active contract is the unpublished first-party 0.1.0+3 development profile', async () => {
  const metadata = await loadReleaseContract(undefined, { requireProfile: profileId });
  assert.equal(metadata.version, independentDevelopmentVersion);
  assert.equal(metadata.buildNumber, independentDevelopmentBuildNumber);
  assert.equal(metadata.tag, 'v0.1.0');
  assert.equal(metadata.publicationEnabled, false);
  assert.equal(metadata.distribution, 'independent-development-candidate');
  assert.equal(metadata.primaryTarget, 'macos-host-native');
  assert.equal(metadata.artifacts.length, 9);
  assert.ok(
    metadata.artifacts
      .filter(({ platform }) => ['macos', 'windows', 'linux'].includes(platform))
      .every(({ hostRuntimeIncluded }) => hostRuntimeIncluded === true),
  );
  assert.ok(
    metadata.artifacts
      .filter(({ platform }) => ['android', 'ios', 'web'].includes(platform))
      .every(({ hostRuntimeIncluded }) => hostRuntimeIncluded === false),
  );
  assert.equal(
    metadata.artifacts.find(({ platform }) => platform === 'linux').runtimeBaseline,
    linuxRuntimeBaseline,
  );
  assert.deepEqual(
    metadata.expectedAssets,
    releaseAssets(metadata.version, getArtifactProfile(profileId)),
  );
  assert.equal(
    await readFile(resolve(repositoryRoot, metadata.releaseNotesPath), 'utf8'),
    expectedReleaseNotes(metadata),
  );
  await assert.rejects(
    () => loadReleaseContract(undefined, { requirePublication: true }),
    /publication-disabled/,
  );
});

test('version and stable-tag parsing remain generic and exact', () => {
  assert.deepEqual(parsePubspecVersion('name: sample\nversion: 12.34.56+789\n'), {
    version: '12.34.56',
    buildNumber: '789',
  });
  for (const invalid of ['1.2.3', '01.2.3+4', '1.2.3+0', '1.2+3', 'v1.2.3+4']) {
    assert.throws(() => parsePubspecVersion(`version: ${invalid}\n`));
  }
  assert.equal(compareSemVer('0.1.0', '0.0.3'), 1);
  assert.equal(compareSemVer('0.0.3', '0.1.0'), -1);
  assert.equal(parseStableTag('v0.1.0'), '0.1.0');
  for (const invalid of ['0.1.0', 'v0.1.0-rc.1', 'v01.0.0', 'decision-019']) {
    assert.equal(parseStableTag(invalid), null);
  }
});

test('old v0.0.2 and v0.0.3 identities cannot be reused, moved, or overwritten', () => {
  assert.throws(
    () => assertCandidateExceedsRemoteStableTags('v0.0.2', remoteTags),
    /greater than remote stable tag v0\.0\.3/,
  );
  assert.deepEqual(assertCandidateExceedsRemoteStableTags('v0.1.0', remoteTags), [
    'v0.0.2',
    'v0.0.3',
  ]);

  const commit = '0123456789abcdef0123456789abcdef01234567';
  assert.throws(
    () => inspectRemoteCandidateTag('v0.0.3', commit, remoteTags),
    /not 0123456789abcdef/,
  );
  assert.deepEqual(
    inspectRemoteCandidateTag('v0.0.3', '4444444444444444444444444444444444444444', remoteTags),
    {
      state: 'existing-annotated',
      tagObject: '3333333333333333333333333333333333333333',
      peeledCommit: '4444444444444444444444444444444444444444',
    },
  );
  assert.throws(
    () => inspectRemoteCandidateTag('v0.1.0', commit, `${commit}\trefs/tags/v0.1.0\n`),
    /annotated tag/,
  );
  assert.deepEqual(inspectRemoteCandidateTag('v0.1.0', commit, ''), { state: 'absent' });
});

test('legacy v0.0.2 profile remains immutable and separate from current metadata', () => {
  assert.equal(legacyPreviewVersion, '0.0.2');
  assert.equal(legacyPreviewBuildNumber, '2');
  const legacy = getArtifactProfile('macos-preview-v1');
  assert.throws(
    () => assertArtifactProfileVersion(legacy, '0.0.3', '3'),
    /only valid for 0\.0\.2\+2/,
  );
  assert.equal(legacy.immutableLegacy, true);
  assert.equal(legacy.targets[0].hostRuntimeIncluded, false);
});

test('development artifact names identify first-party development evidence, not v0.0.3 Preview bytes', () => {
  const artifacts = applicationArtifacts(
    independentDevelopmentVersion,
    getArtifactProfile(profileId),
  );
  assert.ok(artifacts.every(({ file }) => file.includes('0.1.0')));
  assert.ok(artifacts.every(({ file }) => !file.includes('0.0.3')));
  assert.ok(artifacts.some(({ file }) => file.includes('Web-wasm-development')));
  assert.ok(artifacts.some(({ file }) => file.includes('macOS-host-native-ad-hoc-development')));
});
