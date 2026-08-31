import assert from 'node:assert/strict';
import test from 'node:test';
import {
  activeHomebrewCask,
  renderHomebrewCask,
} from '../tool/homebrew_cask.mjs';
import {
  homebrewInstallCommand,
  homebrewTap,
  loadReleaseContract,
} from '../tool/release_contract.mjs';

const digest = 'a'.repeat(64);
const commit = '0123456789abcdef0123456789abcdef01234567';
const futureMetadata = Object.freeze({
  version: '0.2.0',
  tag: 'v0.2.0',
  asset: 'Pi-Client-0.2.0-macOS-universal.zip',
  publicationEnabled: true,
  artifacts: [
    {
      id: 'macos-universal',
      platform: 'macos',
      architecture: 'universal',
      extension: 'zip',
      hostRuntimeIncluded: true,
      file: 'Pi-Client-0.2.0-macOS-universal.zip',
    },
  ],
});
const evidence = Object.freeze({
  tag: futureMetadata.tag,
  asset: futureMetadata.asset,
  sha256: digest,
  commit,
  published: true,
});

test('Homebrew tooling is dormant for the unpublished development profile', async () => {
  const metadata = await loadReleaseContract();
  assert.equal(metadata.publicationEnabled, false);
  await assert.rejects(
    () => activeHomebrewCask(digest, evidence),
    /publication-disabled/,
  );
  assert.throws(
    () => renderHomebrewCask(metadata, digest, evidence),
    /dormant|publication-disabled/,
  );
});

test('future Cask rendering requires exact qualified published Release evidence', () => {
  const source = renderHomebrewCask(futureMetadata, digest, evidence);
  assert.match(source, /^cask "pi-client" do$/m);
  assert.match(source, /version "0\.2\.0"/);
  assert.match(source, new RegExp(`sha256 "${digest}"`));
  assert.match(source, /releases\/download\/v#\{version\}/);
  assert.match(source, /first-party Pi Node runtime/);
  assert.match(source, /never disables Gatekeeper/);
  assert.ok(!source.includes('pi-web'));
  assert.ok(!source.includes('--no-quarantine'));
  assert.ok(!source.includes('xattr'));
  assert.equal(homebrewInstallCommand, 'brew install --cask hu-wentao/tap/pi-client');
  assert.equal(homebrewTap, 'Hu-Wentao/homebrew-tap');
});

test('Homebrew Cask rejects placeholder digests, unqualified bytes, and wrong identities', () => {
  for (const invalid of ['', 'A'.repeat(64), 'a'.repeat(63), `${'a'.repeat(64)}0`]) {
    assert.throws(
      () => renderHomebrewCask(futureMetadata, invalid, { ...evidence, sha256: invalid }),
      /SHA-256/,
    );
  }
  for (const invalidEvidence of [
    { ...evidence, published: false },
    { ...evidence, tag: 'v0.0.2' },
    { ...evidence, asset: 'Pi-Client-0.0.3-macOS-universal.zip' },
    { ...evidence, sha256: 'b'.repeat(64) },
    { ...evidence, commit: 'short' },
  ]) {
    assert.throws(
      () => renderHomebrewCask(futureMetadata, digest, invalidEvidence),
      /Qualified Release evidence/,
    );
  }
  assert.throws(
    () => renderHomebrewCask({ ...futureMetadata, publicationEnabled: false }, digest, evidence),
    /dormant/,
  );
});
