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
    'flutter test --no-pub --exclude-tags golden',
    'flutter test test/workspace_golden_test.dart --no-pub',
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

test('macOS Debug uses an isolated PiClientDev identity while Release keeps Pi Client', async () => {
  const project = await readFile(
    resolve(repositoryRoot, 'macos/Runner.xcodeproj/project.pbxproj'),
    'utf8',
  );
  const debugTarget = project.match(
    /33CC10FC2044A3C60003C045 \/\* Debug \*\/[\s\S]*?\n\t\t};\n\t\t33CC10FD/,
  )?.[0];
  const debugTests = project.match(
    /331C80DB294CF71000263BE5 \/\* Debug \*\/[\s\S]*?\n\t\t};\n\t\t331C80DC/,
  )?.[0];
  const appInfo = await readFile(
    resolve(repositoryRoot, 'macos/Runner/Configs/AppInfo.xcconfig'),
    'utf8',
  );
  assert.ok(debugTarget, 'macOS Debug target configuration must exist');
  assert.ok(debugTests, 'macOS Debug test configuration must exist');
  assert.match(debugTarget, /PRODUCT_NAME = PiClientDev;/);
  assert.match(
    debugTarget,
    /PRODUCT_BUNDLE_IDENTIFIER = io\.github\.huwentao\.piClient\.dev;/,
  );
  assert.match(
    debugTests,
    /TEST_HOST = "\$\(BUILT_PRODUCTS_DIR\)\/PiClientDev\.app\/\$\(BUNDLE_EXECUTABLE_FOLDER_PATH\)\/PiClientDev";/,
  );
  assert.match(appInfo, /PRODUCT_NAME = Pi Client\n/);
  assert.match(appInfo, /PRODUCT_BUNDLE_IDENTIFIER = io\.github\.huwentao\.piClient\n/);
  assert.ok(!appInfo.includes('PiClientDev'));
  const ci = await workflow('ci.yml');
  assert.ok(ci.includes("APP='build/macos/Build/Products/Debug/PiClientDev.app'"));
});

test('connect-only scan keeps the external-terminal desktop process boundary out of Web', async () => {
  const source = await readFile(
    resolve(repositoryRoot, '.github/scripts/assert-connect-only-artifact.mjs'),
    'utf8',
  );
  for (const required of [
    'assertExternalTerminalBoundary',
    'external_terminal_launcher_stub.dart',
    'external_terminal_launcher_io.dart',
    'PiProjectIdentity projectIdentity',
    'runInShell: false',
    'desktop external-terminal process implementation',
    'Shell host',
    'remote command executor',
  ]) {
    assert.ok(source.includes(required), `connect-only scan must contain ${required}`);
  }
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

test('aggregated public Preview qualification is Capsule-aware and publication-gated', async () => {
  const source = await workflow('release-preview.yml');
  for (const required of [
    'independent-first-party-preview-v1',
    'flutter test --exclude-tags golden',
    'flutter test test/workspace_golden_test.dart',
    "ProductVersion -ne '$VERSION+$BUILD_NUMBER'",
    '--require-publication',
    'capsule:build --target',
    'verify-macos-app-runtime-capsule.mjs',
    'sign-macos-app.mjs',
    'install-runtime-capsule-in-desktop-bundle.mjs',
    '--platform windows',
    '--platform linux',
    '--target macos-universal',
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
    'Update the authorized Homebrew Tap',
    'HOMEBREW_TAP_TOKEN',
    'homebrew-smoke:',
    'brew install --cask hu-wentao/tap/pi-client',
    'PUBLIC_HOMEBREW_PREVIEW_ENABLED',
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
    'release_metadata.mjs --require-profile macos-preview-v1 --require-publication',
  ]) {
    assert.ok(macos.includes(required), `release-macos.yml must contain ${required}`);
  }
  assert.ok(
    macos.indexOf('release_metadata.mjs --require-profile macos-preview-v1 --require-publication') <
      macos.indexOf('Reject existing release identity'),
    'release-macos.yml must fail closed before any remote release read or write',
  );
  for (const required of [
    'channel:',
    '- candidate',
    '- stable',
    'require_desktop_signing.mjs',
    'capsule:build',
    'install-runtime-capsule-in-desktop-bundle.mjs',
    'run_desktop_bundled_app_e2e.mjs',
    'generate_desktop_artifact_manifest.mjs',
    'desktop_release_metadata.mjs',
  ]) {
    assert.ok(desktop.includes(required), `release-desktop-candidates.yml must contain ${required}`);
  }
});

test('desktop candidate metadata matches the active contract and stable fails before packaging', async () => {
  const script = resolve(repositoryRoot, 'tool/desktop_release_metadata.mjs');
  const { stdout } = await execFileAsync(process.execPath, [
    script,
    '--platform',
    'windows',
    '--architecture',
    'x64',
    '--channel',
    'candidate',
  ]);
  const metadata = JSON.parse(stdout);
  assert.equal(metadata.version, '0.1.0');
  assert.equal(metadata.buildNumber, '3');
  assert.equal(metadata.channel, 'candidate');
  await assert.rejects(
    () =>
      execFileAsync(process.execPath, [
        script,
        '--platform',
        'windows',
        '--architecture',
        'x64',
        '--channel',
        'stable',
      ]),
    /independent-stable publication profile/,
  );
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

test('Pages keeps ordinary main source-only and release Preview exact-tag gated', async () => {
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
    'PUBLIC_HOMEBREW_PREVIEW_ENABLED',
    'actual-homebrew-cask.rb',
    'raw.githubusercontent.com/Hu-Wentao/homebrew-tap/main/Casks/pi-client.rb',
    "echo 'complete=true'",
  ]) {
    assert.ok(source.includes(required), `pages.yml must contain ${required}`);
  }
  assert.ok(!source.includes('v0.0.3'));
  assert.ok(!source.includes('workspace-preview'));
});

test('strict release contract inputs keep LF line endings on every runner', async () => {
  const source = await readFile(resolve(repositoryRoot, '.gitattributes'), 'utf8');
  for (const rule of [
    '/.fvmrc text eol=lf',
    '/pubspec.yaml text eol=lf',
    '/release/*.json text eol=lf',
    '/site/package.json text eol=lf',
    '/site/src/content/*.ts text eol=lf',
    '/.github/release-notes/*.md text eol=lf',
  ]) {
    assert.ok(source.includes(`${rule}\n`), `.gitattributes must contain ${rule}`);
  }
});

test('site validation gates Homebrew copy to the published Preview build', async () => {
  const source = await readFile(
    resolve(repositoryRoot, 'site/scripts/validate-built-site.mjs'),
    'utf8',
  );
  for (const required of [
    "['releases/download/', 'unpublished download URL']",
    "['v0.1.0', 'unpublished development version']",
    "['v0.0.3', 'unpublished abandoned Preview version']",
    "['workspace-preview', 'retired workspace screenshot']",
    'PUBLIC_HOMEBREW_PREVIEW_ENABLED',
    'Homebrew installation command',
  ]) {
    assert.ok(source.includes(required), `site validation must contain ${required}`);
  }
});
