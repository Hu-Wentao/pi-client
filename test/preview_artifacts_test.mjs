import assert from 'node:assert/strict';
import {
  mkdir,
  mkdtemp,
  readFile,
  rm,
  symlink,
  writeFile,
} from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import test from 'node:test';
import {
  applicationArtifacts,
  getArtifactProfile,
  repositoryRoot,
} from '../tool/release_contract.mjs';
import {
  assembleArtifacts,
  connectOnlyHostRuntimeVerification,
  firstPartyHostRuntimeVerification,
  scanPackageContents,
  stageArtifact,
  verifyArtifacts,
} from '../tool/preview_artifacts.mjs';

const profileId = 'independent-first-party-preview-v1';
const version = '0.1.0';
const commit = '0123456789abcdef0123456789abcdef01234567';
const flutterVersion = '3.41.6';
const artifacts = applicationArtifacts(version, getArtifactProfile(profileId));

async function writeContents(root, artifact, index) {
  await mkdir(root, { recursive: true });
  if (!artifact.hostRuntimeIncluded) {
    await writeFile(resolve(root, `connect-only-${index}.txt`), 'safe\n');
    return;
  }
  const capsule = resolve(root, 'PiNode');
  await mkdir(resolve(capsule, 'app/dist'), { recursive: true });
  await mkdir(resolve(capsule, 'metadata'), { recursive: true });
  await mkdir(resolve(capsule, 'runtime/bin'), { recursive: true });
  await writeFile(resolve(capsule, 'capsule-manifest.json'), '{}\n');
  await writeFile(resolve(capsule, 'app/dist/stdio-main.js'), 'entrypoint\n');
  await writeFile(resolve(capsule, 'metadata/licenses.json'), '{}\n');
  await writeFile(resolve(capsule, 'runtime/bin/node'), 'node\n');
}

async function stagedWorkspace(sourceLayout = 'flat') {
  const root = await mkdtemp(resolve(tmpdir(), 'pi-independent-artifacts-'));
  const staged = resolve(root, 'staged');
  await mkdir(staged);
  for (const [index, artifact] of artifacts.entries()) {
    const input = resolve(root, `artifact-${index}.bin`);
    const contents = resolve(root, `contents-${index}`);
    await writeFile(input, `artifact-${index}\n`);
    await writeContents(contents, artifact, index);
    const outputDir =
      sourceLayout === 'workflow'
        ? resolve(staged, `preview-${artifact.platform}-${commit}`)
        : staged;
    await stageArtifact({
      root: repositoryRoot,
      profileId,
      targetId: artifact.id,
      inputPath: input,
      contentsRoot: contents,
      outputDir,
    });
  }
  return { root, staged };
}

test('connect-only package scan rejects first-party runtime paths and escaping symlinks', async () => {
  const safe = await mkdtemp(resolve(tmpdir(), 'pi-connect-only-safe-'));
  await writeFile(resolve(safe, 'main.dart.js'), 'safe\n');
  assert.deepEqual(
    await scanPackageContents(safe, { hostRuntimeIncluded: false }),
    connectOnlyHostRuntimeVerification,
  );

  const withRuntime = await mkdtemp(resolve(tmpdir(), 'pi-connect-only-runtime-'));
  await mkdir(resolve(withRuntime, 'PiNode'));
  await assert.rejects(
    () => scanPackageContents(withRuntime, { hostRuntimeIncluded: false }),
    /forbidden/i,
  );

  const withShellHost = await mkdtemp(resolve(tmpdir(), 'pi-connect-only-shell-'));
  await writeFile(resolve(withShellHost, 'pi-client-shell-host'), 'forbidden\n');
  await assert.rejects(
    () => scanPackageContents(withShellHost, { hostRuntimeIncluded: false }),
    /forbidden/i,
  );

  const outside = await mkdtemp(resolve(tmpdir(), 'pi-connect-only-outside-'));
  await writeFile(resolve(outside, 'file'), 'outside\n');
  await symlink(resolve(outside, 'file'), resolve(safe, 'escape'));
  await assert.rejects(
    () => scanPackageContents(safe, { hostRuntimeIncluded: false }),
    /escapes the contents root/,
  );
});

test('desktop package scan requires exactly one first-party runtime Capsule layout', async () => {
  const root = await mkdtemp(resolve(tmpdir(), 'pi-desktop-runtime-'));
  const artifact = artifacts.find(({ platform }) => platform === 'linux');
  await writeContents(root, artifact, 0);
  assert.deepEqual(
    await scanPackageContents(root, { hostRuntimeIncluded: true }),
    firstPartyHostRuntimeVerification,
  );
  await rm(resolve(root, 'PiNode/app/dist/stdio-main.js'));
  await assert.rejects(
    () => scanPackageContents(root, { hostRuntimeIncluded: true }),
    /missing/,
  );
});

test('staging records truthful runtime inclusion for desktop and connect-only targets', async () => {
  const root = await mkdtemp(resolve(tmpdir(), 'pi-stage-runtime-'));
  for (const targetId of ['android-arm64-v8a', 'linux-x64']) {
    const artifact = artifacts.find(({ id }) => id === targetId);
    const input = resolve(root, `${targetId}.bin`);
    const contents = resolve(root, `${targetId}-contents`);
    const output = resolve(root, `${targetId}-stage`);
    await writeFile(input, 'bytes\n');
    await writeContents(contents, artifact, 1);
    const result = await stageArtifact({
      root: repositoryRoot,
      profileId,
      targetId,
      inputPath: input,
      contentsRoot: contents,
      outputDir: output,
    });
    const evidence = JSON.parse(await readFile(result.evidencePath, 'utf8'));
    assert.equal(evidence.schemaVersion, 2);
    assert.equal(evidence.hostRuntimeIncluded, artifact.hostRuntimeIncluded);
    assert.deepEqual(
      evidence.hostRuntimeVerification,
      artifact.hostRuntimeIncluded
        ? firstPartyHostRuntimeVerification
        : connectOnlyHostRuntimeVerification,
    );
  }
});

test('assembly creates deterministic mixed-role manifest and exact checksums', async () => {
  const { root, staged } = await stagedWorkspace();
  const first = resolve(root, 'first');
  const second = resolve(root, 'second');
  for (const outputDir of [first, second]) {
    await assembleArtifacts({
      root: repositoryRoot,
      profileId,
      inputDir: staged,
      outputDir,
      commit,
      flutterVersion,
    });
  }
  assert.deepEqual(
    await readFile(resolve(first, 'artifact-manifest.json')),
    await readFile(resolve(second, 'artifact-manifest.json')),
  );
  const manifest = await verifyArtifacts({
    root: repositoryRoot,
    profileId,
    directory: first,
    commit,
    flutterVersion,
  });
  assert.equal(manifest.distribution, 'independent-public-preview');
  assert.equal(manifest.artifacts.length, 9);
  assert.ok(
    manifest.artifacts
      .filter(({ platform }) => ['macos', 'windows', 'linux'].includes(platform))
      .every(({ hostRuntimeIncluded }) => hostRuntimeIncluded === true),
  );
  assert.ok(
    manifest.artifacts
      .filter(({ platform }) => ['android', 'ios', 'web'].includes(platform))
      .every(({ hostRuntimeIncluded }) => hostRuntimeIncluded === false),
  );
});

test('workflow source layout accepts six isolated platform producers with two Web artifacts', async () => {
  const { root, staged } = await stagedWorkspace('workflow');
  const output = resolve(root, 'output');
  await assembleArtifacts({
    root: repositoryRoot,
    profileId,
    inputDir: staged,
    outputDir: output,
    commit,
    flutterVersion,
    sourceLayout: 'workflow',
  });
  await verifyArtifacts({
    root: repositoryRoot,
    profileId,
    directory: output,
    commit,
    flutterVersion,
  });
});

test('verification rejects changed desktop bytes and unexpected release files', async () => {
  const { root, staged } = await stagedWorkspace();
  const output = resolve(root, 'output');
  await assembleArtifacts({
    root: repositoryRoot,
    profileId,
    inputDir: staged,
    outputDir: output,
    commit,
    flutterVersion,
  });
  const desktop = artifacts.find(({ platform }) => platform === 'windows');
  await writeFile(resolve(output, desktop.file), 'tampered\n');
  await assert.rejects(
    () =>
      verifyArtifacts({
        root: repositoryRoot,
        profileId,
        directory: output,
        commit,
        flutterVersion,
      }),
    /digest|size/i,
  );
});
