import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { resolve } from 'node:path';
import test from 'node:test';
import { repositoryRoot } from '../tool/release_contract.mjs';

const workflowsRoot = resolve(repositoryRoot, '.github/workflows');
const actionsRoot = resolve(repositoryRoot, '.github/actions');
const setupAction = resolve(actionsRoot, 'setup-flutter/action.yml');

async function workflow(name) {
  return readFile(resolve(workflowsRoot, name), 'utf8');
}

async function actionFiles(root = actionsRoot) {
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

function assertPagesTagBindingPolicy(pagesSource, releaseSource) {
  assert.ok(releaseSource.includes('gh workflow run pages.yml --ref "$TAG"'));
  assert.ok(!releaseSource.includes('gh workflow run pages.yml --ref main'));
  assert.ok(pagesSource.includes('[[ "$GITHUB_REF" == "refs/tags/$INPUT_RELEASE_TAG" ]]'));
  assert.ok(pagesSource.includes('[[ "$GITHUB_SHA" == "$INPUT_SOURCE_COMMIT" ]]'));
  assert.ok(pagesSource.includes('git rev-parse "$LOCAL_TAG_REF^{}"'));
  assert.ok(pagesSource.includes('git rev-parse "$REMOTE_TAG_REF^{}"'));
  assert.ok(pagesSource.includes('.object.type == "tag"'));
  assert.ok(
    pagesSource.includes('.object.type == "commit" and .object.sha == $commit'),
  );
}

test('all external actions are pinned to full commit SHAs', async () => {
  const workflowFiles = (await readdir(workflowsRoot)).filter((name) => /\.ya?ml$/.test(name));
  const sources = [
    ...(await Promise.all(workflowFiles.map(async (name) => [name, await workflow(name)]))),
    ...(await Promise.all(
      (await actionFiles()).map(async (path) => [path, await readFile(path, 'utf8')]),
    )),
  ];
  for (const [name, source] of sources) {
    for (const match of source.matchAll(/^\s*uses:\s*([^\s#]+).*$/gm)) {
      const reference = match[1];
      if (reference.startsWith('./')) continue;
      assert.match(reference, /^[^@\s]+@[0-9a-f]{40}$/, `${name}: ${reference}`);
    }
  }
});

test('CI provides quality and all-platform native-runner smoke builds', async () => {
  const source = await workflow('ci.yml');
  for (const required of [
    'pull_request:',
    'branches: [main]',
    'workflow_dispatch:',
    'build_runner build',
    'flutter analyze',
    'flutter test',
    'node --test',
    'test/homebrew_cask_test.mjs',
    'bun run validate',
    'target: android',
    'target: ios',
    'target: macos',
    'target: windows',
    'target: linux',
    'target: web',
    'needs: quality',
    'main.dart.js',
    'main.dart.wasm',
    'main.dart.wasm.map',
    'ubuntu-24.04',
    'libsecret-1-dev',
  ]) {
    assert.ok(source.includes(required), `ci.yml must contain ${required}`);
  }
  assert.ok(!source.includes("-name '*.wasm'"));
  assert.match(source, /permissions:\n\s+contents: read/);
  assert.match(source, /concurrency:/);
});

test('prepare binds publish recovery to existing identity and one exact completed workflow run', async () => {
  const source = await workflow('release-preview.yml');
  const prepare = source.slice(
    source.indexOf('Validate and freeze recovery input mode'),
    source.indexOf('\n  qualification:'),
  );
  for (const required of [
    'resume_run_id is valid only in publish mode',
    'resume_run_id must be a positive numeric Actions run ID',
    'git ls-remote --tags origin',
    'git ls-remote failed with exit code',
    '--remote-tags-file',
    '--candidate-commit "$GITHUB_SHA"',
    'gh api --paginate --slurp',
    'Duplicate GitHub Releases',
    'REMOTE_IDENTITY_PRESENT',
    'Existing remote Tag or Release for $TAG requires resume_run_id',
    'resume_run_id must be empty when neither remote Tag nor Release exists',
    'actions/runs/$RESUME_RUN_ID',
    '.repository.full_name == $repository',
    '.path == $workflowPath',
    '.name == $workflowName',
    '.head_sha == $headSha',
    '.status == "completed"',
    'actions/runs/$RESUME_RUN_ID/artifacts?per_page=100',
    'release-preview-$GITHUB_SHA',
    'must contain exactly one',
    '.[0].expired == false and .[0].size_in_bytes > 0',
    'freshBundleRequired=$FRESH_BUNDLE_REQUIRED',
    'resumeRunId=$RESUME_RUN_ID',
  ]) {
    assert.ok(prepare.includes(required), `prepare admission must contain ${required}`);
  }
  assert.doesNotMatch(prepare, /if\s+gh\s+api\b/);
  assert.doesNotMatch(prepare, /gh api[^\n]+2>\/dev\/null/);
});

 test('exact qualified bundle resume skips rebuilds and downloads only from the admitted run', async () => {
  const source = await workflow('release-preview.yml');
  for (const required of [
    "build:\n    if: needs.prepare.outputs.freshBundleRequired == 'true'",
    "assemble:\n    if: needs.prepare.outputs.freshBundleRequired == 'true'",
    'always() &&',
    "needs.build.result == 'skipped'",
    "needs.assemble.result == 'skipped'",
    "needs.build.result == 'success'",
    "needs.assemble.result == 'success'",
    'Download qualified release bundle from this run',
    'Download exact qualified release bundle from recovery run',
    'run-id: ${{ needs.prepare.outputs.resumeRunId }}',
    'github-token: ${{ github.token }}',
  ]) {
    assert.ok(source.includes(required), `release-preview.yml must contain ${required}`);
  }
  assert.equal([...source.matchAll(/run-id: \$\{\{ needs\.prepare\.outputs\.resumeRunId \}\}/g)].length, 1);
});

test('preview release preserves artifact sources and scans actual package roots', async () => {
  const source = await workflow('release-preview.yml');
  assert.ok(!source.includes('merge-multiple: true'));
  assert.ok(source.includes('path: .release-staging/sources'));
  assert.ok(source.includes('--source-layout workflow'));
  for (const required of [
    '--contents-root "$APK_CONTENTS"',
    '--contents-root "$ARCHIVE"',
    '--contents-root "$APP"',
    '--contents-root "$BUNDLE"',
    '--contents-root build/web',
  ]) {
    assert.ok(source.includes(required), `release-preview.yml must contain ${required}`);
  }
  assert.equal([...source.matchAll(/--contents-root/g)].length, 6);
});

test('Linux preview validates every ELF dependency and Ubuntu 24.04 symbol baseline before packaging', async () => {
  const source = await workflow('release-preview.yml');
  for (const required of [
    'os: ubuntu-24.04',
    'libsecret-1-dev',
    'find "$BUNDLE" -type f -print0',
    'ldd "$ELF"',
    "grep -Fq 'not found'",
    'readelf --version-info "$ELF"',
    "GLIBC_BASELINE='GLIBC_2.39'",
    "GLIBCXX_BASELINE='GLIBCXX_3.4.33'",
    'exceeds Ubuntu 24.04 baseline',
  ]) {
    assert.ok(source.includes(required), `release-preview.yml must contain ${required}`);
  }
  assert.ok(source.indexOf('ldd "$ELF"') < source.indexOf('tar --sort=name'));
});

test('final publish recovers only failed Draft starters and rejects concurrent publication', async () => {
  const source = await workflow('release-preview.yml');
  const publish = source.slice(source.indexOf('\n  publish:'));
  for (const required of [
    'set -euo pipefail',
    'git ls-remote --tags origin',
    '--remote-tags-file',
    'git fetch --no-tags origin',
    'git cat-file -t',
    'existing-annotated',
    'gh api --paginate --slurp',
    'Duplicate GitHub Releases',
    'Create or reuse Draft, verify service assets, and publish last',
    'assert_release_identity',
    'assert_exact_assets',
    'upload_url',
    'Content-Type: application/octet-stream',
    'ASSET_STATE',
    'STARTER_ASSET_COUNT',
    'contains multiple failed starter assets; refusing ambiguous recovery deletion',
    "ASSET_STATE\" == 'starter'",
    "ASSET_SIZE\" == '0'",
    'starter-delete-admission.json',
    'state == "starter"',
    '--method DELETE',
    'starter-delete-readback.json',
    'still exists after bounded recovery deletion',
    'non-recoverable state=$ASSET_STATE size=$ASSET_SIZE; refusing overwrite or deletion',
    'Public release $TAG contains failed starter asset $NAME; refusing deletion',
    'differs from the qualified local artifact',
    'Published release $TAG is missing $NAME and must not be mutated',
    "Draft $TAG was changed or published concurrently before this workflow's final PATCH",
    'pre-publish-release.json',
    "Draft $TAG became public or changed before this workflow's final PATCH",
    'published-release.json',
    'Release $TAG was initially public; verified without mutation',
    'Accept: application/octet-stream',
    '-F draft=false -F prerelease=true',
    'gh workflow run pages.yml --ref "$TAG"',
    'source_commit="$GITHUB_SHA"',
    'release_tag="$TAG"',
  ]) {
    assert.ok(publish.includes(required), `publish state machine must contain ${required}`);
  }
  assert.equal([...publish.matchAll(/--method DELETE/g)].length, 1);
  assert.ok(publish.indexOf('--method DELETE') > publish.indexOf("ASSET_STATE\" == 'starter'"));
  assert.ok(publish.indexOf('--method DELETE') < publish.indexOf('Content-Type: application/octet-stream'));
  assert.ok(
    publish.indexOf('assert_release_identity "$RUNNER_TEMP/pre-publish-release.json" true') <
      publish.indexOf('-F draft=false -F prerelease=true'),
  );
  assert.ok(
    publish.indexOf('assert_release_identity "$RUNNER_TEMP/published-release.json" false') >
      publish.indexOf('-F draft=false -F prerelease=true'),
  );
  assert.doesNotMatch(publish, /if\s+gh\s+api\b/);
  assert.doesNotMatch(publish, /gh api[^\n]+2>\/dev\/null/);
  for (const forbidden of [
    'merge-multiple: true',
    'gh release create',
    'gh release upload',
    '--clobber',
    'git tag -f',
    'git tag -d',
    'git push --force',
    'gh workflow run pages.yml --ref main',
  ]) {
    assert.ok(!publish.includes(forbidden), `publish state machine must not contain ${forbidden}`);
  }
  assert.match(publish, /permissions:\n\s+contents: write\n\s+actions: write/);
  assert.ok(
    publish.indexOf('-F draft=false -F prerelease=true') >
      publish.indexOf('node tool/preview_artifacts.mjs verify'),
  );
});

test('preview release remains profile-gated, aggregated, and publish-last', async () => {
  const files = await readdir(workflowsRoot);
  assert.ok(files.includes('release-preview.yml'));
  assert.ok(!files.includes('release-macos.yml'));
  const source = await workflow('release-preview.yml');
  for (const required of [
    '--require-profile six-platform-preview-v1',
    'test/homebrew_cask_test.mjs',
    "inputs.mode == 'publish'",
    'refs/heads/main',
    '--split-per-abi',
    'apksigner',
    'Expected a no-codesign iOS archive',
    'Expected Gatekeeper to reject',
    'NotSigned',
    'ELF 64-bit',
    'main.dart.js',
    'main.dart.wasm',
    'main.dart.wasm.map',
    'preview_artifacts.mjs assemble',
    'preview_artifacts.mjs verify',
    'Accept: application/octet-stream',
    'Request frozen-source Pages deployment after publication',
  ]) {
    assert.ok(source.includes(required), `release-preview.yml must contain ${required}`);
  }
  assert.match(
    source,
    /actions\/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02/,
  );
  assert.match(
    source,
    /actions\/download-artifact@634f93cb2916e3fdff6788551b99b062d0335ce0/,
  );
  assert.ok(!source.includes("-name '*.wasm'"));
});

test('Pages binds release dispatch to one annotated tag object and its peeled source commit', async () => {
  const source = await workflow('pages.yml');
  const releaseSource = await workflow('release-preview.yml');
  assertPagesTagBindingPolicy(source, releaseSource);
  for (const required of [
    'source_commit:',
    'release_tag:',
    'source_commit and release_tag must be provided together',
    '^[0-9a-f]{40}$',
    'fetch-depth: 0',
    '[[ "$GITHUB_EVENT_NAME" == \'workflow_dispatch\' ]]',
    '[[ "$GITHUB_REF" == "refs/tags/$INPUT_RELEASE_TAG" ]]',
    '[[ "$GITHUB_SHA" == "$INPUT_SOURCE_COMMIT" ]]',
    'git rev-parse HEAD',
    'git cat-file -t "$LOCAL_TAG_REF"',
    'git rev-parse "$LOCAL_TAG_REF^{}"',
    'git fetch --no-tags origin "refs/tags/$INPUT_RELEASE_TAG:$REMOTE_TAG_REF"',
    'git cat-file -t "$REMOTE_TAG_REF"',
    'git rev-parse "$REMOTE_TAG_REF^{}"',
    'Remote and local tag objects differ',
    'git/ref/tags/$INPUT_RELEASE_TAG',
    '.object.type == "tag"',
    'git/tags/$REMOTE_TAG_OBJECT',
    '.object.type == "commit" and .object.sha == $commit',
    'ref: ${{ needs.source.outputs.commit }}',
    "github.event_name != 'pull_request' &&",
    "github.ref == 'refs/heads/main' || needs.source.outputs.releaseRequest == 'true'",
    'Requested release tag $REQUESTED_TAG does not match frozen metadata $METADATA_TAG',
    'gh api --paginate --slurp',
    'Verify canonical Pages domain',
    '.cname == "pi.wyattcoder.top" and .build_type == "workflow"',
    'Duplicate GitHub Releases',
    'exact non-zero asset set',
    'node tool/release_metadata.mjs',
  ]) {
    assert.ok(source.includes(required), `pages.yml must contain ${required}`);
  }
  assert.equal(
    [...source.matchAll(/ref: \$\{\{ needs\.source\.outputs\.commit \}\}/g)].length,
    2,
  );
  assert.doesNotMatch(source, /if\s+gh\s+api\b/);
});

test('Pages tag binding policy rejects main dispatch and unpeeled remote commit checks', async () => {
  const pagesSource = await workflow('pages.yml');
  const releaseSource = await workflow('release-preview.yml');
  assert.throws(() =>
    assertPagesTagBindingPolicy(
      pagesSource,
      releaseSource.replace('gh workflow run pages.yml --ref "$TAG"', 'gh workflow run pages.yml --ref main'),
    ),
  );
  assert.throws(() =>
    assertPagesTagBindingPolicy(
      pagesSource.replace(
        'git rev-parse "$REMOTE_TAG_REF^{}"',
        'git rev-parse "$REMOTE_TAG_REF"',
      ),
      releaseSource,
    ),
  );
});

test('site validation derives and rejects the active Preview and Homebrew install flow', async () => {
  const source = await readFile(
    resolve(repositoryRoot, 'site/scripts/validate-built-site.mjs'),
    'utf8',
  );
  assert.ok(source.includes('homebrewInstallCommand'));
  assert.ok(source.includes('const activeRelease = await loadReleaseContract();'));
  assert.ok(source.includes("[activeRelease.downloadUrl, 'current Preview download']"));
  assert.ok(source.includes("[activeRelease.tag, 'current Preview version']"));
  assert.ok(source.includes("[homebrewInstallCommand, 'Homebrew installation flow']"));
  assert.ok(source.includes('must not expose'));
  assert.ok(!source.includes('/releases/download/v0.0.2/'));
  assert.ok(!source.includes('/releases/download/v0.0.3/'));
});

test('composite Flutter setup does not depend on a Unix pub-cache executable path', async () => {
  const source = await readFile(setupAction, 'utf8');
  assert.ok(!source.includes('$HOME/.pub-cache/bin/fvm'));
  assert.ok(source.includes('dart pub global run fvm:main install 3.41.6'));
  assert.ok(source.includes('dart pub global run fvm:main use 3.41.6 --force'));
  assert.ok(source.includes("'exec dart pub global run fvm:main \"$@\"'"));
  assert.ok(source.includes('cygpath'));
  assert.ok(source.includes('GITHUB_PATH'));
});

test('Android release configuration has no debug signing fallback', async () => {
  const source = await readFile(resolve(repositoryRoot, 'android/app/build.gradle.kts'), 'utf8');
  assert.ok(!source.includes('signingConfigs.getByName("debug")'));
  assert.ok(source.includes('intentionally have no signingConfig'));
});
