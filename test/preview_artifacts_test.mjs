import assert from 'node:assert/strict';
import {
  cp,
  mkdir,
  mkdtemp,
  readFile,
  rename,
  rm,
  symlink,
  writeFile,
} from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import test from 'node:test';
import {
  applicationArtifacts,
  expectedReleaseNotes,
  getArtifactProfile,
  linuxRuntimeBaseline,
  repositoryRoot,
} from '../tool/release_contract.mjs';
import {
  assembleArtifacts,
  hostRuntimeVerification,
  scanPackageContents,
  stageArtifact,
  verifyArtifacts,
} from '../tool/preview_artifacts.mjs';

const profileId = 'six-platform-preview-v1';
const version = '0.0.3';
const buildNumber = '3';
const commit = '0123456789abcdef0123456789abcdef01234567';
const flutterVersion = '3.41.6';
const artifacts = applicationArtifacts(version, getArtifactProfile(profileId));

async function futureReleaseRoot() {
  const root = await mkdtemp(resolve(tmpdir(), 'pi-preview-contract-'));
  for (const file of ['pubspec.yaml', '.fvmrc']) {
    await cp(resolve(repositoryRoot, file), resolve(root, file));
  }
  for (const directory of ['release', 'site/src/content', '.github/release-notes']) {
    await cp(resolve(repositoryRoot, directory), resolve(root, directory), { recursive: true });
  }
  await cp(resolve(repositoryRoot, 'site/package.json'), resolve(root, 'site/package.json'));
  const pubspecPath = resolve(root, 'pubspec.yaml');
  await writeFile(
    pubspecPath,
    (await readFile(pubspecPath, 'utf8')).replace(
      /^version:.*$/m,
      `version: ${version}+${buildNumber}`,
    ),
  );
  await writeFile(
    resolve(root, 'release/release.json'),
    '{\n  "schemaVersion": 1,\n  "artifactProfile": "six-platform-preview-v1",\n  "primaryTarget": "macos-universal"\n}\n',
  );
  const sitePackagePath = resolve(root, 'site/package.json');
  const sitePackage = JSON.parse(await readFile(sitePackagePath, 'utf8'));
  sitePackage.version = version;
  await writeFile(sitePackagePath, `${JSON.stringify(sitePackage, null, 2)}\n`);
  const tag = `v${version}`;
  const asset = `Pi-Client-${version}-macOS-universal.zip`;
  const copyPath = resolve(root, 'site/src/content/copy.ts');
  const releaseBlock = `export const release = {\n  version: '${version}',\n  tag: '${tag}',\n  asset: '${asset}',\n  downloadUrl:\n    'https://github.com/Hu-Wentao/pi-client/releases/download/${tag}/${asset}',\n  releaseUrl: 'https://github.com/Hu-Wentao/pi-client/releases/tag/${tag}',\n} as const;`;
  await writeFile(
    copyPath,
    (await readFile(copyPath, 'utf8')).replace(
      /export const release = \{[\s\S]*?\n\} as const;/,
      releaseBlock,
    ),
  );
  await writeFile(
    resolve(root, `.github/release-notes/${tag}.md`),
    expectedReleaseNotes({ version, asset, artifactProfile: profileId }),
  );
  return root;
}

async function workspace(sourceLayout = 'flat') {
  const root = await mkdtemp(resolve(tmpdir(), 'pi-preview-artifacts-'));
  const contractRoot = await futureReleaseRoot();
  const staged = resolve(root, 'staged');
  await mkdir(staged);
  for (const [index, artifact] of artifacts.entries()) {
    const input = resolve(root, `raw-${index}.bin`);
    const contents = resolve(root, `contents-${index}`);
    await mkdir(contents);
    await writeFile(resolve(contents, `safe-${index}.txt`), `contents-${index}\n`);
    await writeFile(input, `artifact-${index}\n`);
    const outputDir =
      sourceLayout === 'workflow'
        ? resolve(staged, `preview-${artifact.platform}-${commit}`)
        : staged;
    await stageArtifact({
      root: contractRoot,
      profileId,
      targetId: artifact.id,
      inputPath: input,
      contentsRoot: contents,
      outputDir,
    });
  }
  return { root, contractRoot, staged };
}

function evidenceName(artifact) {
  return `${artifact.file}.stage-evidence.json`;
}

test('stage normalizes one built file and records successful package-boundary evidence', async () => {
  const root = await mkdtemp(resolve(tmpdir(), 'pi-stage-'));
  const contractRoot = await futureReleaseRoot();
  const input = resolve(root, 'raw.apk');
  const contents = resolve(root, 'apk-contents');
  const output = resolve(root, 'stage-output');
  await writeFile(input, 'apk bytes');
  await mkdir(contents);
  await writeFile(resolve(contents, 'AndroidManifest.xml'), '<manifest/>');
  const result = await stageArtifact({
    root: contractRoot,
    profileId,
    targetId: 'android-arm64-v8a',
    inputPath: input,
    contentsRoot: contents,
    outputDir: output,
  });
  assert.equal(result.file, 'Pi-Client-0.0.3-Android-arm64-v8a.apk');
  assert.equal(await readFile(result.path, 'utf8'), 'apk bytes');
  assert.deepEqual(result.hostRuntimeVerification, hostRuntimeVerification);
  assert.deepEqual(
    JSON.parse(await readFile(result.evidencePath, 'utf8')),
    {
      schemaVersion: 1,
      target: 'android-arm64-v8a',
      file: result.file,
      hostRuntimeIncluded: false,
      hostRuntimeVerification,
    },
  );
  await assert.rejects(() =>
    stageArtifact({
      root: contractRoot,
      profileId,
      targetId: 'android-arm64-v8a',
      inputPath: input,
      contentsRoot: contents,
      outputDir: output,
    }),
  );
});

test('package contents scan confines symlinks and rejects reserved future host runtime basenames', async (t) => {
  await t.test('reserved executable filename with extension', async () => {
    const root = await mkdtemp(resolve(tmpdir(), 'pi-host-scan-'));
    await writeFile(resolve(root, 'pi-client-agent-host.exe'), 'forbidden');
    await assert.rejects(() => scanPackageContents(root), /Reserved future host runtime basename/);
  });
  await t.test('reserved directory basename with extension', async () => {
    const root = await mkdtemp(resolve(tmpdir(), 'pi-host-scan-'));
    await mkdir(resolve(root, 'PiClientAgentHost.framework'));
    await assert.rejects(() => scanPackageContents(root), /Reserved future host runtime basename/);
  });
  await t.test('all reserved spelling families are case-insensitive', async () => {
    for (const name of ['PI_CLIENT_AGENT_HOST', 'PI-SDK-HOST.bin', 'pi_sdk_host.bundle']) {
      const root = await mkdtemp(resolve(tmpdir(), 'pi-host-scan-'));
      await writeFile(resolve(root, name), 'forbidden');
      await assert.rejects(() => scanPackageContents(root), /Reserved future host runtime basename/);
    }
  });
  await t.test('contained framework-style symlink', async () => {
    const root = await mkdtemp(resolve(tmpdir(), 'pi-host-scan-'));
    await mkdir(resolve(root, 'Versions/A'), { recursive: true });
    await writeFile(resolve(root, 'Versions/A/safe'), 'safe');
    await symlink('A', resolve(root, 'Versions/Current'));
    await symlink('Versions/Current/safe', resolve(root, 'safe-link'));
    assert.deepEqual(await scanPackageContents(root), hostRuntimeVerification);
  });
  await t.test('escaping symlink', async () => {
    const root = await mkdtemp(resolve(tmpdir(), 'pi-host-scan-'));
    const outside = await mkdtemp(resolve(tmpdir(), 'pi-host-outside-'));
    await writeFile(resolve(outside, 'safe'), 'safe');
    await symlink(resolve(outside, 'safe'), resolve(root, 'linked'));
    await assert.rejects(() => scanPackageContents(root), /escapes the contents root/);
  });
  await t.test('broken symlink', async () => {
    const root = await mkdtemp(resolve(tmpdir(), 'pi-host-scan-'));
    await symlink('missing', resolve(root, 'linked'));
    await assert.rejects(() => scanPackageContents(root), /must resolve successfully/);
  });
  await t.test('empty unrelated root', async () => {
    const root = await mkdtemp(resolve(tmpdir(), 'pi-host-scan-'));
    await assert.rejects(() => scanPackageContents(root), /at least one package entry/);
  });
});

test('assemble is deterministic and verify checks the exact bundle and evidence', async () => {
  const { root, contractRoot, staged } = await workspace();
  const first = resolve(root, 'first');
  const second = resolve(root, 'second');
  await assembleArtifacts({
    root: contractRoot,
    profileId,
    inputDir: staged,
    outputDir: first,
    commit,
    flutterVersion,
  });
  await assembleArtifacts({
    root: contractRoot,
    profileId,
    inputDir: staged,
    outputDir: second,
    commit,
    flutterVersion,
  });
  for (const file of [
    'artifact-manifest.json',
    'SHA256SUMS',
    'Pi-Client-0.0.3-macOS-universal.zip.sha256',
  ]) {
    assert.deepEqual(await readFile(resolve(first, file)), await readFile(resolve(second, file)));
  }
  const manifest = await verifyArtifacts({
    root: contractRoot,
    profileId,
    directory: first,
    commit,
    flutterVersion,
  });
  assert.equal(manifest.product, 'Pi Client');
  assert.equal(manifest.distribution, 'unsigned-preview');
  assert.equal(manifest.commit, commit);
  assert.equal(manifest.artifacts.length, 8);
  assert.ok(manifest.artifacts.every(({ hostRuntimeIncluded }) => hostRuntimeIncluded === false));
  assert.ok(
    manifest.artifacts.every(
      ({ hostRuntimeVerification: verification }) =>
        JSON.stringify(verification) === JSON.stringify(hostRuntimeVerification),
    ),
  );
  assert.equal(
    manifest.artifacts.find(({ platform }) => platform === 'linux').runtimeBaseline,
    linuxRuntimeBaseline,
  );
  assert.ok(
    manifest.artifacts
      .filter(({ platform }) => platform !== 'linux')
      .every(({ runtimeBaseline }) => runtimeBaseline === null),
  );
});

test('workflow source layout accepts exactly six isolated platform directories', async () => {
  const { root, contractRoot, staged } = await workspace('workflow');
  const output = resolve(root, 'output');
  await assembleArtifacts({
    root: contractRoot,
    profileId,
    inputDir: staged,
    outputDir: output,
    commit,
    flutterVersion,
    sourceLayout: 'workflow',
  });
  await verifyArtifacts({
    root: contractRoot,
    profileId,
    directory: output,
    commit,
    flutterVersion,
  });
});

test('workflow source layout rejects wrong source, duplicate, missing, and extra inputs', async (t) => {
  await t.test('wrong platform source', async () => {
    const { root, contractRoot, staged } = await workspace('workflow');
    const artifact = artifacts.find(({ platform }) => platform === 'android');
    const androidDir = resolve(staged, `preview-android-${commit}`);
    const webDir = resolve(staged, `preview-web-${commit}`);
    await rename(resolve(androidDir, artifact.file), resolve(webDir, artifact.file));
    await rename(resolve(androidDir, evidenceName(artifact)), resolve(webDir, evidenceName(artifact)));
    await assert.rejects(
      () =>
        assembleArtifacts({
          root: contractRoot,
          profileId,
          inputDir: staged,
          outputDir: resolve(root, 'out'),
          commit,
          flutterVersion,
          sourceLayout: 'workflow',
        }),
      /wrong platform source/,
    );
  });
  await t.test('duplicate artifact across sources', async () => {
    const { root, contractRoot, staged } = await workspace('workflow');
    const artifact = artifacts.find(({ platform }) => platform === 'android');
    await cp(
      resolve(staged, `preview-android-${commit}`, artifact.file),
      resolve(staged, `preview-web-${commit}`, artifact.file),
    );
    await assert.rejects(
      () =>
        assembleArtifacts({
          root: contractRoot,
          profileId,
          inputDir: staged,
          outputDir: resolve(root, 'out'),
          commit,
          flutterVersion,
          sourceLayout: 'workflow',
        }),
      /Duplicate staged artifact/,
    );
  });
  await t.test('missing platform directory', async () => {
    const { root, contractRoot, staged } = await workspace('workflow');
    await rm(resolve(staged, `preview-ios-${commit}`), { recursive: true });
    await assert.rejects(
      () =>
        assembleArtifacts({
          root: contractRoot,
          profileId,
          inputDir: staged,
          outputDir: resolve(root, 'out'),
          commit,
          flutterVersion,
          sourceLayout: 'workflow',
        }),
      /exactly/,
    );
  });
  await t.test('missing application and evidence', async () => {
    const { root, contractRoot, staged } = await workspace('workflow');
    const artifact = artifacts.find(({ platform }) => platform === 'ios');
    const directory = resolve(staged, `preview-ios-${commit}`);
    await rm(resolve(directory, artifact.file));
    await rm(resolve(directory, evidenceName(artifact)));
    await assert.rejects(
      () =>
        assembleArtifacts({
          root: contractRoot,
          profileId,
          inputDir: staged,
          outputDir: resolve(root, 'out'),
          commit,
          flutterVersion,
          sourceLayout: 'workflow',
        }),
      /Missing staged artifacts/,
    );
  });
  await t.test('extra platform directory', async () => {
    const { root, contractRoot, staged } = await workspace('workflow');
    await mkdir(resolve(staged, `preview-extra-${commit}`));
    await assert.rejects(
      () =>
        assembleArtifacts({
          root: contractRoot,
          profileId,
          inputDir: staged,
          outputDir: resolve(root, 'out'),
          commit,
          flutterVersion,
          sourceLayout: 'workflow',
        }),
      /exactly/,
    );
  });
  await t.test('extra file', async () => {
    const { root, contractRoot, staged } = await workspace('workflow');
    await writeFile(resolve(staged, `preview-web-${commit}`, 'unexpected.bin'), 'x');
    await assert.rejects(
      () =>
        assembleArtifacts({
          root: contractRoot,
          profileId,
          inputDir: staged,
          outputDir: resolve(root, 'out'),
          commit,
          flutterVersion,
          sourceLayout: 'workflow',
        }),
      /Unexpected staged artifact/,
    );
  });
});

test('assemble rejects zero-byte, symlink, invalid commit, and missing evidence inputs', async (t) => {
  await t.test('zero byte', async () => {
    const { root, contractRoot, staged } = await workspace();
    await writeFile(resolve(staged, artifacts[0].file), '');
    await assert.rejects(
      () =>
        assembleArtifacts({
          root: contractRoot,
          profileId,
          inputDir: staged,
          outputDir: resolve(root, 'out'),
          commit,
          flutterVersion,
        }),
      /Zero-byte/,
    );
  });
  await t.test('symlink', async () => {
    const { root, contractRoot, staged } = await workspace();
    await symlink(resolve(staged, artifacts[0].file), resolve(staged, 'linked-artifact'));
    await assert.rejects(
      () =>
        assembleArtifacts({
          root: contractRoot,
          profileId,
          inputDir: staged,
          outputDir: resolve(root, 'out'),
          commit,
          flutterVersion,
        }),
      /Symlink/,
    );
  });
  await t.test('commit', async () => {
    const { root, contractRoot, staged } = await workspace();
    await assert.rejects(
      () =>
        assembleArtifacts({
          root: contractRoot,
          profileId,
          inputDir: staged,
          outputDir: resolve(root, 'out'),
          commit: 'short',
          flutterVersion,
        }),
      /40-character/,
    );
  });
  await t.test('missing scan evidence', async () => {
    const { root, contractRoot, staged } = await workspace();
    await rm(resolve(staged, evidenceName(artifacts[0])));
    await assert.rejects(
      () =>
        assembleArtifacts({
          root: contractRoot,
          profileId,
          inputDir: staged,
          outputDir: resolve(root, 'out'),
          commit,
          flutterVersion,
        }),
      /Missing staged artifacts/,
    );
  });
});

test('verify requires hostRuntimeVerification and rejects tampering and extra files', async () => {
  const { root, contractRoot, staged } = await workspace();
  const output = resolve(root, 'output');
  await assembleArtifacts({
    root: contractRoot,
    profileId,
    inputDir: staged,
    outputDir: output,
    commit,
    flutterVersion,
  });
  const manifestPath = resolve(output, 'artifact-manifest.json');
  const manifest = JSON.parse(await readFile(manifestPath, 'utf8'));
  delete manifest.artifacts[0].hostRuntimeVerification;
  await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
  await assert.rejects(
    () =>
      verifyArtifacts({
        root: contractRoot,
        profileId,
        directory: output,
        commit,
        flutterVersion,
      }),
    /unexpected or missing fields/,
  );

  const second = resolve(root, 'second');
  await assembleArtifacts({
    root: contractRoot,
    profileId,
    inputDir: staged,
    outputDir: second,
    commit,
    flutterVersion,
  });
  await writeFile(resolve(second, artifacts[0].file), 'tampered');
  await assert.rejects(
    () =>
      verifyArtifacts({
        root: contractRoot,
        profileId,
        directory: second,
        commit,
        flutterVersion,
      }),
    /digest|size/i,
  );

  const third = resolve(root, 'third');
  await assembleArtifacts({
    root: contractRoot,
    profileId,
    inputDir: staged,
    outputDir: third,
    commit,
    flutterVersion,
  });
  await writeFile(resolve(third, 'extra.txt'), 'extra');
  await assert.rejects(
    () =>
      verifyArtifacts({
        root: contractRoot,
        profileId,
        directory: third,
        commit,
        flutterVersion,
      }),
    /file set mismatch/i,
  );
});
