import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { mkdir, mkdtemp, readFile, readdir, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { promisify } from 'node:util';
import test from 'node:test';
import { repositoryRoot } from '../tool/release_contract.mjs';

const execFileAsync = promisify(execFile);
const workflowsRoot = resolve(repositoryRoot, '.github/workflows');
const actionsRoot = resolve(repositoryRoot, '.github/actions');

async function workflow(name) {
  return readFile(resolve(workflowsRoot, name), 'utf8');
}

async function yamlFiles(root) {
  const files = [];
  async function visit(directory) {
    for (const entry of await readdir(directory, { withFileTypes: true })) {
      const path = resolve(directory, entry.name);
      if (entry.isDirectory()) await visit(path);
      else if (/\.ya?ml$/.test(entry.name)) files.push(path);
    }
  }
  await visit(root);
  return files;
}

test('all external Actions remain pinned to full commit SHAs', async () => {
  const files = [...(await yamlFiles(workflowsRoot)), ...(await yamlFiles(actionsRoot))];
  for (const path of files) {
    const source = await readFile(path, 'utf8');
    for (const match of source.matchAll(/^\s*uses:\s*([^\s#]+).*$/gm)) {
      const reference = match[1];
      if (reference.startsWith('./')) continue;
      assert.match(reference, /^[^@\s]+@[0-9a-f]{40}$/, `${path}: ${reference}`);
    }
  }
});

test('composite Flutter setup carries the Dart problem-matcher fix across hosts', async () => {
  const source = await readFile(resolve(actionsRoot, 'setup-flutter/action.yml'), 'utf8');
  assert.ok(source.includes('problem-matcher: false'));
  assert.ok(source.includes('dart pub global run fvm:main install 3.41.6'));
  assert.ok(source.includes('cygpath'));
  assert.ok(source.includes('GITHUB_PATH'));
  assert.ok(!source.includes('$HOME/.pub-cache/bin/fvm'));
});

test('CI combines Flutter, Protocol, Pi Node, release, site, WASM, connect-only, and six-platform gates', async () => {
  const source = await workflow('ci.yml');
  for (const required of [
    'workflow_dispatch:',
    'build_runner build',
    'flutter analyze',
    'flutter test',
    'test/homebrew_cask_test.mjs',
    'bun run validate',
    'Run the full Protocol check',
    'runtime Capsule',
    'assert-no-runtime-capsule.mjs',
    'flutter build apk',
    'flutter build ios',
    'flutter build macos',
    'flutter build windows',
    'flutter build linux',
    'flutter build web --wasm',
    'assert-connect-only-artifact.mjs android',
    'assert-connect-only-artifact.mjs ios',
    'assert-connect-only-artifact.mjs web-wasm',
    'Dart matcher conflicts',
  ]) {
    assert.ok(source.includes(required), `ci.yml must contain ${required}`);
  }
  assert.match(source, /permissions:\n\s+contents: read/);
  assert.ok(source.includes('concurrency:'));
});

test('ordinary desktop artifact scan rejects an embedded runtime Capsule', async () => {
  const script = resolve(
    repositoryRoot,
    '.github/scripts/assert-no-runtime-capsule.mjs',
  );
  const safe = await mkdtemp(resolve(tmpdir(), 'pi-no-runtime-safe-'));
  await writeFile(resolve(safe, 'Pi Client'), 'application\n');
  await execFileAsync(process.execPath, [script, safe]);
  await mkdir(resolve(safe, 'PiNode'));
  await assert.rejects(
    () => execFileAsync(process.execPath, [script, safe]),
    /runtime Capsule/i,
  );
});

test('aggregated development qualification is Capsule-aware and publication-disabled', async () => {
  const source = await workflow('release-preview.yml');
  for (const required of [
    'independent-six-platform-development-v1',
    '--require-publication',
    'capsule:build --target',
    'verify-macos-app-runtime-capsule.mjs',
    'sign-macos-app.mjs',
    'install-runtime-capsule-in-desktop-bundle.mjs',
    '--platform windows',
    '--platform linux',
    '--target macos-host-native',
    '--target windows-x64-portable',
    '--target linux-x64',
    '--target web-js',
    '--target web-wasm',
    'assert-connect-only-artifact.mjs android',
    'assert-connect-only-artifact.mjs ios',
    'assert-connect-only-artifact.mjs web-wasm',
    'preview_artifacts.mjs assemble',
    'preview_artifacts.mjs verify',
    'Existing remote Tag or Release for $TAG requires resume_run_id',
    'Published release $TAG is missing $NAME and must not be mutated',
    'git tag -a "$TAG" "$GITHUB_SHA"',
  ]) {
    assert.ok(source.includes(required), `release-preview.yml must contain ${required}`);
  }
  for (const forbidden of [
    'six-platform-preview-v1',
    'hostRuntimeIncluded: false',
    'v0.0.3',
    'git tag -f',
    'git push --force',
    '--clobber',
    'gh workflow run pages.yml --ref main',
  ]) {
    assert.ok(!source.includes(forbidden), `release-preview.yml must not contain ${forbidden}`);
  }
});

test('Capsule-aware macOS and Windows/Linux candidate workflows remain available', async () => {
  const macos = await workflow('release-macos.yml');
  const desktop = await workflow('release-desktop-candidates.yml');
  for (const required of [
    'capsule:build',
    'verify-macos-app-runtime-capsule.mjs',
    'sign-macos-app.mjs',
    'run_macos_bundled_app_e2e.mjs',
  ]) {
    assert.ok(macos.includes(required), `release-macos.yml must contain ${required}`);
  }
  for (const required of [
    'channel:',
    '- candidate',
    '- stable',
    'require_desktop_signing.mjs',
    'capsule:build',
    'install-runtime-capsule-in-desktop-bundle.mjs',
    'run_desktop_bundled_app_e2e.mjs',
    'generate_desktop_artifact_manifest.mjs',
  ]) {
    assert.ok(desktop.includes(required), `release-desktop-candidates.yml must contain ${required}`);
  }
});

test('stable desktop admission fails closed when signing credentials are absent', async () => {
  const script = resolve(repositoryRoot, 'tool/require_desktop_signing.mjs');
  const env = { ...process.env };
  for (const key of [
    'WINDOWS_SIGNING_CERTIFICATE_BASE64',
    'WINDOWS_SIGNING_CERTIFICATE_PASSWORD',
    'LINUX_GPG_PRIVATE_KEY_BASE64',
    'LINUX_GPG_PASSPHRASE',
  ]) {
    delete env[key];
  }
  await assert.rejects(
    () => execFileAsync(process.execPath, [script, '--platform', 'windows', '--channel', 'stable'], { env }),
    /signing/i,
  );
  await assert.rejects(
    () => execFileAsync(process.execPath, [script, '--platform', 'linux', '--channel', 'stable'], { env }),
    /signing/i,
  );
  await execFileAsync(
    process.execPath,
    [script, '--platform', 'windows', '--channel', 'candidate'],
    { env },
  );
});

test('Pages deploys the source-only public site while release dispatch stays exact-tag gated', async () => {
  const source = await workflow('pages.yml');
  for (const required of [
    'pi.wyattcoder.top',
    'source_commit and release_tag must be provided together',
    'git cat-file -t "$LOCAL_TAG_REF"',
    'git rev-parse "$REMOTE_TAG_REF^{}"',
    '.object.type == "tag"',
    '.object.type == "commit" and .object.sha == $commit',
    'node tool/release_metadata.mjs --require-publication',
    'exact published Release',
    "echo 'complete=true'",
  ]) {
    assert.ok(source.includes(required), `pages.yml must contain ${required}`);
  }
  assert.ok(!source.includes('v0.0.3'));
  assert.ok(!source.includes('workspace-preview'));
});

test('site validation rejects unpublished downloads, Homebrew commands, and stale screenshots', async () => {
  const source = await readFile(
    resolve(repositoryRoot, 'site/scripts/validate-built-site.mjs'),
    'utf8',
  );
  for (const required of [
    "['releases/download/', 'unpublished download URL']",
    "['brew install --cask', 'Homebrew installation flow']",
    "['v0.1.0', 'unpublished development version']",
    "['v0.0.3', 'unpublished abandoned Preview version']",
    "['workspace-preview', 'retired workspace screenshot']",
  ]) {
    assert.ok(source.includes(required), `site validation must contain ${required}`);
  }
});
