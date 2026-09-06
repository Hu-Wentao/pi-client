import assert from 'node:assert/strict';
import {
  mkdir,
  mkdtemp,
  readFile,
  rm,
  writeFile,
} from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import test from 'node:test';
import {
  independentPreviewProfileId,
  loadReleaseContract,
  repositoryRoot,
} from '../tool/release_contract.mjs';
import { updateHomebrewTap } from '../tool/homebrew_tap.mjs';

const digest = 'a'.repeat(64);
const commit = '0123456789abcdef0123456789abcdef01234567';

async function releaseEvidence() {
  const metadata = await loadReleaseContract();
  assert.equal(metadata.artifactProfile, independentPreviewProfileId);
  return {
    tag: metadata.tag,
    asset: metadata.asset,
    sha256: digest,
    commit,
    published: true,
  };
}

test('Homebrew Tap update writes the deterministic public Preview Cask', async () => {
  const tapRoot = await mkdtemp(resolve(tmpdir(), 'pi-homebrew-tap-'));
  try {
    const result = await updateHomebrewTap({
      tapRoot,
      sha256: digest,
      evidence: await releaseEvidence(),
      root: repositoryRoot,
    });
    assert.equal(result.changed, true);
    assert.match(
      await readFile(resolve(tapRoot, 'Casks/pi-client.rb'), 'utf8'),
      /version "0\.1\.0"/,
    );
    assert.match(
      await readFile(resolve(tapRoot, 'Casks/pi-client.rb'), 'utf8'),
      /macOS-universal-ad-hoc-preview\.zip/,
    );
  } finally {
    await rm(tapRoot, { recursive: true, force: true });
  }
});

test('Homebrew Tap update is idempotent and check-only rejects drift', async () => {
  const tapRoot = await mkdtemp(resolve(tmpdir(), 'pi-homebrew-tap-idempotent-'));
  try {
    const evidence = await releaseEvidence();
    const first = await updateHomebrewTap({ tapRoot, sha256: digest, evidence });
    const second = await updateHomebrewTap({ tapRoot, sha256: digest, evidence });
    assert.equal(first.changed, true);
    assert.equal(second.changed, false);

    await writeFile(resolve(tapRoot, 'Casks/pi-client.rb'), 'cask "pi-client" do\nend\n');
    await assert.rejects(
      () => updateHomebrewTap({ tapRoot, sha256: digest, evidence, checkOnly: true }),
      /does not match/,
    );
  } finally {
    await rm(tapRoot, { recursive: true, force: true });
  }
});

test('Homebrew Tap update creates the expected Cask parent directory', async () => {
  const root = await mkdtemp(resolve(tmpdir(), 'pi-homebrew-tap-parent-'));
  const tapRoot = resolve(root, 'tap');
  try {
    await mkdir(root, { recursive: true });
    const result = await updateHomebrewTap({
      tapRoot,
      sha256: digest,
      evidence: await releaseEvidence(),
    });
    assert.equal(result.changed, true);
    assert.ok(await readFile(resolve(tapRoot, 'Casks/pi-client.rb'), 'utf8'));
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});
