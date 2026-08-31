import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import test from 'node:test';
import {
  activeHomebrewCask,
  renderHomebrewCask,
  verifyHomebrewCask,
} from '../tool/homebrew_cask.mjs';
import {
  homebrewInstallCommand,
  homebrewTap,
  loadReleaseContract,
} from '../tool/release_contract.mjs';

const digest = 'a'.repeat(64);

test('renders the active unsigned macOS Preview as a deterministic Cask', async () => {
  const metadata = await loadReleaseContract();
  const source = renderHomebrewCask(metadata, digest);
  assert.match(source, /^cask "pi-client" do$/m);
  assert.match(source, /version "0\.0\.3"/);
  assert.match(source, new RegExp(`sha256 "${digest}"`));
  assert.match(
    source,
    /releases\/download\/v#\{version\}\/Pi-Client-#\{version\}-macOS-universal\.zip/,
  );
  assert.match(source, /depends_on macos: :big_sur/);
  assert.match(source, /app "Pi Client\.app"/);
  assert.match(source, /unsigned, unnotarized Preview/);
  assert.match(source, /Homebrew preserves\n    macOS quarantine metadata/);
  assert.match(source, /Control-click \/Applications\/Pi Client\.app/);
  assert.match(source, /Do not remove quarantine metadata or disable Gatekeeper/);
  assert.match(source, /transitional pi-web compatibility boundary/);
  assert.ok(!source.includes('--no-quarantine'));
  assert.ok(!source.includes('xattr'));
  assert.equal(homebrewInstallCommand, 'brew install --cask hu-wentao/tap/pi-client');
  assert.equal(homebrewTap, 'Hu-Wentao/homebrew-tap');
});

test('rejects invalid digests and immutable legacy metadata', async () => {
  const metadata = await loadReleaseContract();
  for (const invalid of ['', 'A'.repeat(64), 'a'.repeat(63), `${'a'.repeat(64)}0`]) {
    assert.throws(() => renderHomebrewCask(metadata, invalid), /SHA-256/);
  }
  assert.throws(
    () => renderHomebrewCask({ ...metadata, artifactProfile: 'macos-preview-v1' }, digest),
    /immutable v0\.0\.2 legacy Preview/,
  );
});

test('verifies exact generated Cask bytes and rejects drift', async () => {
  const root = await mkdtemp(resolve(tmpdir(), 'pi-homebrew-cask-'));
  const path = resolve(root, 'pi-client.rb');
  const expected = await activeHomebrewCask(digest);
  await writeFile(path, expected);
  assert.deepEqual(await verifyHomebrewCask(path, digest), {
    path,
    installCommand: homebrewInstallCommand,
    tap: homebrewTap,
  });
  await writeFile(path, `${await readFile(path, 'utf8')}# drift\n`);
  await assert.rejects(() => verifyHomebrewCask(path, digest), /does not exactly match/);
});
